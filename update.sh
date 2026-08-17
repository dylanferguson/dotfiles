#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo 'Updating Brew...'
brew update
brew upgrade
brew cleanup -s
brew doctor || true
brew missing || true

echo 'Updating Mac App Store apps...'
mas outdated
mas upgrade

echo 'Updating global npm packages...'
npm update -g

#Report drift instead of committing it: `brew bundle dump` overwrites the
#curated Brewfile, including its comments, so review changes by hand.
echo
echo 'Brewfile drift:'
if brew bundle check --file="$DOTFILES/Brewfile" --verbose; then
  echo '  Brewfile is satisfied.'
fi
echo "  Anything installed but untracked shows up in: brew bundle cleanup --file=$DOTFILES/Brewfile"
brew bundle cleanup --file="$DOTFILES/Brewfile" || true

echo
echo 'VS Code extension drift:'
diff <(code --list-extensions | sed 's/^/vscode "/;s/$/"/' | sort) \
  <(grep '^vscode ' "$DOTFILES/Brewfile" | sort) || true
