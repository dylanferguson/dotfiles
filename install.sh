#!/bin/sh
. brew.sh
. dock.sh

mkdir ~/dev ~/books ~/books-jp
sudo rm -rf ~/Movies ~/Music ~/Pictures ~/Public ~/Documents

rm -rf ~/.gitconfig
ln -s ~/.dotfiles/.gitconfig ~/.gitconfig

rm -rf ~/.gitignore_global
ln -s ~/.dotfiles/.gitignore_global ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global
git config --list

rm -rf ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User
ln -s ~/.dotfiles/sublime ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User

. system_defaults.sh
