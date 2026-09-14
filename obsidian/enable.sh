#!/bin/bash
# Install or rebuild the dedicated backup app on this Mac.
set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

SOURCE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
readonly BASE="${OBSIDIAN_BACKUP_BASE:-$HOME/.obsidian-backup}"
readonly REPO="$BASE/repo"
readonly APP="$HOME/Applications/Obsidian Backup.app"
readonly LABEL='com.dylanferguson.obsidian-backup'
readonly PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
readonly IDENTITY="${OBSIDIAN_SIGNING_IDENTITY:--}"

write_launch_agent() {
  local plist=$1 bundle_id
  bundle_id=$(plutil -extract CFBundleIdentifier raw "$SOURCE/app/Info.plist")

  plutil -create xml1 "$plist"
  plutil -insert Label -string "$LABEL" "$plist"
  plutil -insert ProgramArguments -json '[]' "$plist"
  plutil -insert ProgramArguments.0 -string "$APP/Contents/MacOS/ObsidianBackup" "$plist"
  plutil -insert ProgramArguments.1 -json '"--background"' "$plist"
  plutil -insert AssociatedBundleIdentifiers -json '[]' "$plist"
  plutil -insert AssociatedBundleIdentifiers.0 -string "$bundle_id" "$plist"
  plutil -insert StartInterval -integer 3600 "$plist"
  plutil -insert RunAtLoad -bool YES "$plist"
  plutil -insert WorkingDirectory -string "$BASE" "$plist"
  plutil -insert StandardOutPath -string "$BASE/launchd.err" "$plist"
  plutil -insert StandardErrorPath -string "$BASE/launchd.err" "$plist"
  plutil -lint "$plist"
}

case "${1:-}" in
  --prepare-only) exec /bin/bash "$SOURCE/prepare-repo.sh" "$REPO" ;;
  '') ;;
  *) printf '%s\n' 'Usage: enable.sh [--prepare-only]' >&2; exit 64 ;;
esac

for dependency in git git-lfs xcrun; do
  if ! command -v "$dependency" >/dev/null; then
    printf '%s is required.\n' "$dependency" >&2
    exit 1
  fi
done

mkdir -p "$BASE" "$HOME/Applications" "$HOME/Library/LaunchAgents"
BUILD=$(mktemp -d "$BASE/.build.XXXXXX")
trap 'rm -rf "$BUILD"' EXIT
/bin/bash "$SOURCE/build.sh" "$BUILD/Obsidian Backup.app" "$IDENTITY"
write_launch_agent "$BUILD/agent.plist"

if launchctl print "gui/$UID/$LABEL" >/dev/null 2>&1; then
  launchctl bootout "gui/$UID/$LABEL"
fi
/bin/bash "$SOURCE/prepare-repo.sh" "$REPO"
if ! git -C "$REPO" remote get-url origin >/dev/null 2>&1; then
  if ! command -v gh >/dev/null; then
    printf '%s\n' 'Set the backup repo origin to an empty private GitHub repository.' >&2
    exit 1
  fi
  gh repo create obsidian-vaults --private --source="$REPO" --remote=origin
fi

if [[ -e "$APP" ]]; then
  mv "$APP" "$BUILD/previous.app"
fi
if ! mv "$BUILD/Obsidian Backup.app" "$APP"; then
  if [[ -d "$BUILD/previous.app" ]]; then
    mv "$BUILD/previous.app" "$APP"
  fi
  exit 1
fi

cp "$BUILD/agent.plist" "$PLIST"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP"
launchctl bootstrap "gui/$UID" "$PLIST"
touch "$BASE/enabled"

printf 'Installed: %s\n' "$APP"
printf '%s\n' 'Enable Obsidian Backup in System Settings > Privacy & Security > Full Disk Access.'
if [[ "$IDENTITY" == - ]]; then
  printf '%s\n' 'This local build is ad hoc signed. After rebuilding, macOS may require you to remove and re-add its permission.'
fi
printf 'Then run: launchctl kickstart gui/%s/%s\n' "$UID" "$LABEL"
printf 'Log: %s/backup.log\n' "$BASE"
