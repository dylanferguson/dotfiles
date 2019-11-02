# .dotfiles

## ToDo

- Rewrite repo as Ansible roles: set up a complete local dev environment with a single, idempotent command

## Install

First, do a [clean install](https://www.imore.com/how-do-clean-install-macos)

After that: 
```shell
sudo softwareupdate -i -a
xcode-select --install
```

Then:
```shell
git clone https://github.com/dylanferguson/dotfiles.git $HOME/.dotfiles
cd $HOME/.dotfiles
chmod +wx install.sh
sh install.sh
```

Finally:
```shell
sudo reboot
```

## Post-Reboot

- *Update bash*: 
```shell
sudo -s
echo /usr/local/bin/bash >> /etc/shells
chsh -s /usr/local/bin/bash
echo $BASH_VERSION
```
