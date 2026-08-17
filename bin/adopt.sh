#!/usr/bin/env bash
set -euo pipefail

#Apps installed by hand have no Homebrew receipt, so `brew bundle` thinks they
#are missing and tries to install over the top of them. `--adopt` hands the
#existing app to Homebrew instead. Run this once on a machine that predates the
#Brewfile; a clean install never needs it.

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mapfile -t tracked < <(grep -oE '^cask "[^"]+"' "$DOTFILES/Brewfile" | sed 's/cask "//;s/"//')
installed="$(brew list --cask)"

to_adopt=()
for cask in "${tracked[@]}"; do
  token="${cask##*/}"
  grep -qxF "$token" <<< "$installed" || to_adopt+=("$token")
done

if [[ ${#to_adopt[@]} -eq 0 ]]; then
  echo 'Every cask in the Brewfile is already managed by Homebrew.'
  exit 0
fi

echo 'Homebrew does not manage these yet:'
printf '  %s\n' "${to_adopt[@]}"
echo
read -p "Adopt them? Homebrew may upgrade an app whose version it doesn't match. (y/n): " -n 1 -r
echo
[[ $REPLY =~ ^[Yy]$ ]] || exit 0

for token in "${to_adopt[@]}"; do
  echo "==> $token"
  brew install --cask --adopt "$token" || echo "  failed, install by hand: $token"
done
