# Obsidian backup

Hourly backups to GitHub through `~/.obsidian-backup/repo`, plus a plain-file
Dropbox mirror at `Backups/Obsidian`. Replaced Dropbox files stay in
`Backups/Obsidian-attic` for 90 days. See [restore instructions](backup-readme.md).

## Setup

Run `~/.dotfiles/obsidian/enable.sh` on one Mac, then grant **Full Disk Access**
to `~/Applications/Obsidian Backup.app` in System Settings > Privacy & Security.
Bash does not need its own grant. Rerun after code changes; rebuilding may
require re-adding the app's permission.

Keep iCloud vaults downloaded and Dropbox running. Vaults are discovered by
their `.obsidian` folder; add other paths to `~/.obsidian-backup/vaults.conf`,
one per line. Vault folder names must be unique.

## Use

```sh
launchctl kickstart gui/$UID/com.dylanferguson.obsidian-backup  # Run now
tail -20 ~/.obsidian-backup/backup.log                        # Check results
~/.dotfiles/obsidian/check.sh                                # ShellCheck + tests
```

`~/.obsidian-backup/last-success` records the last successful Git push and local
Dropbox copy; Dropbox uploads separately. Startup errors go to `launchd.err`
in the same directory.

## Disable

```sh
launchctl bootout gui/$UID/com.dylanferguson.obsidian-backup
rm ~/Library/LaunchAgents/com.dylanferguson.obsidian-backup.plist
rm ~/.obsidian-backup/enabled
```
