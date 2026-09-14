# .dotfiles

## Install

First, do a [clean install](https://www.imore.com/how-do-clean-install-macos). Then:

```shell
sudo softwareupdate -i -a
xcode-select --install
git clone https://github.com/dylanferguson/dotfiles.git $HOME/.dotfiles
$HOME/.dotfiles/bin/install.sh
sudo reboot
```

`install.sh` installs Homebrew if it is missing, the Brewfile, Homebrew bash as the login shell, every config symlink, then `system_defaults.sh`. It is safe to re-run.

Apps with no cask are listed at the bottom of the [Brewfile](Brewfile).

## Obsidian vault backup

Hourly GitHub and Dropbox backups: [setup, commands and restore instructions](obsidian/README.md).
