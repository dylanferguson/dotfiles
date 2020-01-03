#!/bin/bash
set -e

terminal-notifier -message 'Running daily update...'
echo 'Updating Brew...'
brew update
brew upgrade
brew cleanup -s
brew doctor
brew missing

pushd "$HOME/.dotfiles"

brew bundle dump --force
if [[ $(git diff --stat Brewfile) != '' ]]; then
  echo 'Updating Brewfile...'
  git add Brewfile
  git commit -m 'auto update Brewfile'
  git push
  echo 'Pushed'
fi

echo 'VSCode backup...'
code --list-extensions --show-versions > vscode/extensions.txt
[[ $(git diff --stat vscode/extensions.txt) != '' ]] && git add vscode/extensions.txt && git commit -m 'vscode extensions update' && git push

echo 'MAS update...'
mas outdated
mas upgrade

echo 'Updating NPM global packages...'
npm update -g
yarn global upgrade

popd