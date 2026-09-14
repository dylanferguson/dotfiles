#import <AppKit/AppKit.h>
#import <Security/Security.h>
#include <errno.h>
#include <fcntl.h>
#include <pwd.h>
#include <signal.h>
#include <spawn.h>
#include <sys/file.h>
#include <sys/wait.h>
#include <unistd.h>

static volatile sig_atomic_t childPID = 0;

static void forwardSignal(int signalNumber) {
    if (childPID > 0) kill(-childPID, signalNumber);
}

static int runBackup(NSString *bundle, NSString *userHome) {
    NSFileManager *files = NSFileManager.defaultManager;
    NSString *base = [userHome stringByAppendingPathComponent:@".obsidian-backup"];
    NSError *error = nil;
    if (![files createDirectoryAtPath:base withIntermediateDirectories:YES
                          attributes:@{NSFilePosixPermissions: @0700} error:&error]) {
        fprintf(stderr, "Cannot create backup directory: %s\n", error.localizedDescription.UTF8String);
        return 1;
    }
    NSString *lockPath = [base stringByAppendingPathComponent:@"run.lock"];
    int lock = open(lockPath.fileSystemRepresentation, O_CREAT | O_RDWR | O_NOFOLLOW, 0600);
    if (lock < 0 || flock(lock, LOCK_EX | LOCK_NB) != 0) {
        fprintf(stderr, "Backup is already running, or its lock cannot be opened.\n");
        if (lock >= 0) close(lock);
        return 1;
    }
    NSString *script = [bundle stringByAppendingPathComponent:@"Contents/Resources/backup.sh"];
    NSString *username = NSUserName();
    NSMutableArray<NSString *> *environment = [NSMutableArray arrayWithArray:@[
        [@"HOME=" stringByAppendingString:userHome],
        [@"USER=" stringByAppendingString:username],
        [@"LOGNAME=" stringByAppendingString:username],
        @"PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
        @"LANG=en_US.UTF-8", @"GIT_TERMINAL_PROMPT=0",
        @"GIT_SSH_COMMAND=/usr/bin/ssh -o BatchMode=yes -o ConnectTimeout=15",
        [@"TMPDIR=" stringByAppendingString:NSTemporaryDirectory()]
    ]];
    NSString *socket = NSProcessInfo.processInfo.environment[@"SSH_AUTH_SOCK"];
    if (socket.length) [environment addObject:[@"SSH_AUTH_SOCK=" stringByAppendingString:socket]];
    char **envp = calloc(environment.count + 1, sizeof(char *));
    if (!envp) { close(lock); return 1; }
    for (NSUInteger i = 0; i < environment.count; i++) envp[i] = (char *)environment[i].UTF8String;
    char *arguments[] = {"/bin/bash", "--noprofile", "--norc", (char *)script.fileSystemRepresentation, NULL};

    posix_spawnattr_t attributes;
    posix_spawnattr_init(&attributes);
    posix_spawnattr_setflags(&attributes, POSIX_SPAWN_SETPGROUP);
    posix_spawnattr_setpgroup(&attributes, 0);
    posix_spawn_file_actions_t actions;
    posix_spawn_file_actions_init(&actions);
    posix_spawn_file_actions_addopen(&actions, STDIN_FILENO, "/dev/null", O_RDONLY, 0);
    NSString *output = [base stringByAppendingPathComponent:@"launchd.err"];
    posix_spawn_file_actions_addopen(&actions, STDERR_FILENO, output.fileSystemRepresentation, O_CREAT | O_WRONLY | O_APPEND, 0600);
    posix_spawn_file_actions_adddup2(&actions, STDERR_FILENO, STDOUT_FILENO);
    signal(SIGTERM, forwardSignal);
    signal(SIGINT, forwardSignal);
    pid_t pid = 0;
    int result = posix_spawn(&pid, "/bin/bash", &actions, &attributes, arguments, envp);
    childPID = pid;
    posix_spawn_file_actions_destroy(&actions);
    posix_spawnattr_destroy(&attributes);
    free(envp);
    if (result != 0) {
        fprintf(stderr, "Cannot start backup: %s\n", strerror(result));
        close(lock);
        return 1;
    }
    int status = 0;
    pid_t waited;
    do { waited = waitpid(pid, &status, 0); } while (waited < 0 && errno == EINTR);
    childPID = 0;
    close(lock);
    if (waited < 0) return 1;
    return WIFEXITED(status) ? WEXITSTATUS(status) : 128 + WTERMSIG(status);
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        BOOL background = argc == 2 && strcmp(argv[1], "--background") == 0;
        BOOL verify = argc == 2 && strcmp(argv[1], "--verify") == 0;
        if (argc > 1 && !background && !verify) {
            fprintf(stderr, "Usage: ObsidianBackup [--background | --verify]\n");
            return 64;
        }
        NSBundle *bundle = NSBundle.mainBundle;
        SecStaticCodeRef code = NULL;
        OSStatus validity = SecStaticCodeCreateWithPath((__bridge CFURLRef)bundle.bundleURL, kSecCSDefaultFlags, &code);
        if (validity == errSecSuccess) {
            validity = SecStaticCodeCheckValidity(code, kSecCSStrictValidate, NULL);
            CFRelease(code);
        }
        if (validity != errSecSuccess) {
            fprintf(stderr, "App signature is invalid (%d). Rebuild with obsidian/enable.sh.\n", (int)validity);
            return 1;
        }
        if (verify) { puts("App signature and bundled resources verified."); return 0; }
        struct passwd *account = getpwuid(getuid());
        if (!account) return 1;
        NSString *userHome = [NSString stringWithUTF8String:account->pw_dir];
        int status = runBackup(bundle.bundlePath, userHome);
        if (!background) {
            [NSApplication sharedApplication];
            [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
            [NSApp activateIgnoringOtherApps:YES];
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = status == 0 ? @"Backup finished" : @"Backup needs attention";
            alert.informativeText = status == 0 ? @"Your vault backup is up to date." :
                @"Check the backup log for details. If iCloud access is denied, enable Obsidian Backup in System Settings → Privacy & Security → Full Disk Access.";
            [alert addButtonWithTitle:@"OK"];
            [alert addButtonWithTitle:@"Open Log"];
            if ([alert runModal] == NSAlertSecondButtonReturn) {
                [NSWorkspace.sharedWorkspace openURL:[NSURL fileURLWithPath:[userHome stringByAppendingPathComponent:@".obsidian-backup/backup.log"]]];
            }
        }
        return status;
    }
}
