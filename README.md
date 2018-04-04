## Install
For a fresh install, run: 
```shell
sudo softwareupdate -i -a
xcode-select --install
```

Then:
```shell
git clone https://github.com/dylanferguson/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
sh install.sh
```

Finally:
```shell
sudo reboot
```

### Some Notes
- *Update bash* (Since OSX ships with an `3.2.57` &#128077;): 
```shell
echo $BASH_VERSION
sudo -s
echo /usr/local/bin/bash >> /etc/shells
chsh -s /usr/local/bin/bash
echo $BASH_VERSION
```

#### Sublime Packages
 - Package Control
 - Git
 - JsPrettier
 - SideBarEnhancements
 - SublimeREPL
 - Non-Text-Files
 - PackageResourceViewer