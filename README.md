# Install
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

## Post-Reboot
- *Install Sublime packages:*
    1. [Install](https://packagecontrol.io/installation) Package Control
    2. Restart ST3

- *Update bash* (Since OSX ships with `3.2.57` &#128077;): 
```shell
echo $BASH_VERSION
sudo -s
echo /usr/local/bin/bash >> /etc/shells
chsh -s /usr/local/bin/bash
echo $BASH_VERSION
```

### Sublime Packages
 - ApplySyntax
 - BracketHighlighter
 - Git
 - JsPrettier
 - Markdown Preview
 - Non Text Files
 - Package Control
 - PackageResourceViewer
 - Pretty JSON
 - Python Improved
 - SideBarEnhancements
 - SublimeLinter
 - SublimeLinter-annotations
 - SublimeLinter-clang
 - SublimeLinter-csslint
 - SublimeLinter-eslint
 - SublimeLinter-flow
 - SublimeLinter-html-tidy
 - SublimeLinter-json
 - SublimeLinter-jsxhint
 - SublimeLinter-shellcheck
 - SublimeREPL
 - nginx