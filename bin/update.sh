#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo 'Updating Brew...'
brew update
brew upgrade
brew cleanup -s
brew doctor || true

echo
echo 'Updating mise runtimes and CLIs...'
mise upgrade

#The Brewfile is a checklist for the next machine, so the only drift worth
#reporting is something installed here that is not written down yet.
echo
echo 'Installed but not in the Brewfile:'
comm -23 <(brew leaves | sort) \
  <(grep -oE '^brew "[^"]+"' "$DOTFILES/Brewfile" | sed 's/brew "//;s/"//' | sort) \
  | sed 's/^/  formula: /'
comm -23 <(brew list --cask | sort) \
  <(grep -oE '^cask "[^"]+"' "$DOTFILES/Brewfile" | sed 's/cask "//;s/"//;s|.*/||' | sort) \
  | sed 's/^/  cask: /'
comm -23 <(code --list-extensions | sort) \
  <(grep -oE '^vscode "[^"]+"' "$DOTFILES/Brewfile" | sed 's/vscode "//;s/"//' | sort) \
  | sed 's/^/  vscode: /'

#Apps installed outside Homebrew are the ones most easily forgotten
echo
echo 'Apps with no line in the Brewfile:'
for app in /Applications/*.app; do
  name="$(basename "$app" .app)"
  [[ "$name" == "Safari" ]] && continue #ships with macOS
  slug="$(echo "$name" | tr '[:upper:] ' '[:lower:]-')"
  #match the whole name or just its first word, since cask tokens are shorter
  #than app names: jellyfin against Jellyfin Desktop
  grep -qiE "${slug}|${slug%%-*}" "$DOTFILES/Brewfile" || echo "  $name"
done
