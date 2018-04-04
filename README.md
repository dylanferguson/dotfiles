## Install
For a fresh install, run: 
`sudo softwareupdate -i -a
xcode-select --install`

Then:
`git clone https://github.com/dylanferguson/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
sh install.sh`

Finally:
`sudo reboot`

###Some Notes
- *Update bash* (Since OSX ships with an `3.2.57` &#1F44D): 
`echo $BASH_VERSION
sudo -s
echo /usr/local/bin/bash >> /etc/shells
chsh -s /usr/local/bin/bash
echo $BASH_VERSION`

####Sublime Packages
 - Package Control
 - Git
 - JsPrettier
 - SideBarEnhancements
 - SublimeREPL
 - Non-Text-Files
 - PackageResourceViewer