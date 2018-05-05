#!/usr/bin/bash
. brew.sh
. dock.sh

#Setup and tidy
mkdir ~/dev ~/books ~/books-jp
sudo rm -rf ~/Movies ~/Music ~/Pictures ~/Public ~/Documents

#Git config
rm -rf ~/.gitconfig
ln -s ~/.dotfiles/.gitconfig ~/.gitconfig

#Git ignore
rm -rf ~/.gitignore_global
ln -s ~/.dotfiles/.gitignore_global ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global
git config --list

#Symlink bash_profile
rm -rf ~/.bash_profile
ln -s ~/.dotfiles/.bash_profile ~/.bash_profile

#Sublime preferences and packages
wget https://packagecontrol.io/Package%20Control.sublime-package -P ~/Library/Application\ Support/Sublime\ Text\ 3/Installed\ Packages
rm -rf  ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Package\ Control.sublime-settings
mkdir -p ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/
cp ~/.dotfiles/Package\ Control.sublime-settings ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/
cp ~/.dotfiles/Preferences.sublime-settings ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/
#Package Control: List Packages

#Yarn global 
yarn global add prettier

. system_defaults.sh
