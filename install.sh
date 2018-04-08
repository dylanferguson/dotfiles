#!/usr/bin/bash
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

wget https://packagecontrol.io/Package%20Control.sublime-package -P ~/Library/Application\ Support/Sublime\ Text\ 3/Installed\ Packages
rm -rf  ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Package\ Control.sublime-settings
mkdir -p ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/
cp ~/.dotfiles/Package\ Control.sublime-settings ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/
#Package Control: List Packages

. system_defaults.sh
