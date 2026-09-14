#!/bin/bash
set -euo pipefail

SOURCE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
readonly APP=${1:?Usage: build.sh OUTPUT.app SIGNING_IDENTITY}
readonly IDENTITY=${2:?A signing identity or - for a disposable test build is required}

mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$SOURCE/app/Info.plist" "$APP/Contents/Info.plist"
cp "$SOURCE/backup.sh" "$APP/Contents/Resources/backup.sh"
chmod 644 "$APP/Contents/Resources/backup.sh"

xcrun clang -fobjc-arc -Os -Wall -Wextra -Werror \
  -mmacosx-version-min=13.0 -framework AppKit -framework Security \
  "$SOURCE/app/Launcher.m" -o "$APP/Contents/MacOS/ObsidianBackup"
codesign --force --sign "$IDENTITY" --options runtime --timestamp=none "$APP"
codesign --verify --strict "$APP"
"$APP/Contents/MacOS/ObsidianBackup" --verify
