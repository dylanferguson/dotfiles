# Install
First, do a [clean install](https://www.imore.com/how-do-clean-install-macos)

After that, run: 
```shell
sudo softwareupdate -i -a
xcode-select --install
```

Then:
```shell
git clone https://github.com/dylanferguson/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
chmod +wx install.sh
sh install.sh
```

Finally:
```shell
sudo reboot
```

## Post-Reboot
- *Install Sublime packages:*
    1. [Install](https://packagecontrol.io/installation) Package Control
    2. Restart ST3

- *Update bash*: 
```shell
echo $BASH_VERSION
sudo -s
echo /usr/local/bin/bash >> /etc/shells
chsh -s /usr/local/bin/bash
echo $BASH_VERSION
```