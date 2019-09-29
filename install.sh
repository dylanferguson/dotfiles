#!/usr/bin/bash
. brew.sh
. dock.sh

#change default shell to zsh 
sudo dscl . -create /Users/$USER UserShell /usr/local/bin/zsh
# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
curl -O https://raw.githubusercontent.com/MartinSeeler/iterm2-material-design/master/material-design-colors.itermcolors

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
rm -rf ~/.zshrc
ln -s ~/.dotfiles/.zshrc ~/.zshrc

#Jrnl config
rm -rf ~/.jrnl_config
ln -s ~/.dotfiles/.jrnl_config ~/.jrnl_config

#VSCode setup
rm -rf ~/Library/Application\ Support/Code/User/settings.json
ln -s ~/.dotfiles/vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json
cat vscode/extensions.txt | xargs -L 1 code --install-extension

#Sublime preferences and packages
wget https://packagecontrol.io/Package%20Control.sublime-package -P ~/Library/Application\ Support/Sublime\ Text\ 3/Installed\ Packages
rm -rf  ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Package\ Control.sublime-settings
mkdir -p ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/
cp ~/.dotfiles/Package\ Control.sublime-settings ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/
cp ~/.dotfiles/Preferences.sublime-settings ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/
#Package Control: List Packages

ln -s /Volumes/Samsung_T3/Calibre\ Library ~/Calibre\ Library  

#Yarn global 
yarn global add prettier

# Set cron job to do daily updates
(crontab -l ; echo "0 19 * * * cd ~/.dotfiles && sh update.sh") | crontab

. system_defaults.sh
