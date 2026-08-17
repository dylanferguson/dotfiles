#!/usr/bin/env bash
set -euo pipefail

#App preferences worth surviving a rebuild. Apps with a real config file are
#tracked as files elsewhere in this repo; these keep theirs in a plist.
#
#  app_defaults.sh export   read this machine's prefs into macos/app_defaults
#  app_defaults.sh import   write them back, as bin/install.sh does

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PREFS_DIR="$DOTFILES/macos/app_defaults"

DOMAINS=(
  com.knollsoft.Rectangle
)

#Version and first-run state, which should not travel to a new machine
declare -A SKIP_KEYS=(
  [com.knollsoft.Rectangle]="SUHasLaunchedBefore installVersion lastVersion internalTilingNotified"
)

#The app that owns each domain, so it can be restarted around an import
declare -A APP_NAME=(
  [com.knollsoft.Rectangle]="Rectangle"
)

export_domain() {
  local domain="$1"
  local file="$PREFS_DIR/$domain.plist"
  defaults export "$domain" "$file"
  for key in ${SKIP_KEYS[$domain]:-}; do
    /usr/libexec/PlistBuddy -c "Delete :$key" "$file" > /dev/null 2>&1 || true
  done
  #xml1 so the file diffs like text
  plutil -convert xml1 "$file"
  echo "exported $domain"
}

import_domain() {
  local domain="$1"
  local file="$PREFS_DIR/$domain.plist"
  local app="${APP_NAME[$domain]:-}"
  if [[ ! -f "$file" ]]; then
    echo "no saved prefs for $domain, skipping" >&2
    return
  fi
  #A running app rewrites its plist when it quits, undoing the import
  local was_running=false
  if [[ -n "$app" ]] && pgrep -qx "$app"; then
    was_running=true
    osascript -e "quit app \"$app\"" > /dev/null 2>&1 || true
  fi
  defaults import "$domain" "$file"
  echo "imported $domain"
  [[ "$was_running" == true ]] && open -a "$app"
}

mkdir -p "$PREFS_DIR"
case "${1:-}" in
  export) for d in "${DOMAINS[@]}"; do export_domain "$d"; done ;;
  import) for d in "${DOMAINS[@]}"; do import_domain "$d"; done ;;
  *) echo "usage: $(basename "$0") export|import" >&2; exit 64 ;;
esac
