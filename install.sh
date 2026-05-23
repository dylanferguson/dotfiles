#!/usr/bin/bash
set -e

#Homebrew packages
brew bundle --file="$(dirname "$0")/Brewfile"

#Setup and tidy
read -p "Delete ~/Movies, ~/Music, ~/Pictures, ~/Public, ~/Documents? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  sudo rm -rf ~/Movies ~/Music ~/Pictures ~/Public ~/Documents
fi

#Git config
rm -f ~/.gitconfig
ln -s ~/.dotfiles/.gitconfig ~/.gitconfig

#Git ignore
rm -f ~/.gitignore_global
ln -s ~/.dotfiles/.gitignore_global ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global
git config --list

#Symlink bash_profile
rm -f ~/.bash_profile ~/.bashrc ~/.zshrc
ln -s ~/.dotfiles/.bash_profile ~/.bash_profile
ln -s ~/.dotfiles/.bashrc ~/.bashrc

#AI agent setup
mkdir -p ~/.claude
rm -f ~/.claude/CLAUDE.md
ln -s ~/.dotfiles/AGENTS.md ~/.claude/CLAUDE.md

#Skills live in dotfiles/agents (vendor-agnostic)
rm -rf ~/.claude/skills
ln -s ~/.dotfiles/agents/skills ~/.claude/skills
rm -rf ~/.agents/skills
ln -s ~/.dotfiles/agents/skills ~/.agents/skills

#Cursor also supports AGENTS.md per-project (no global path)
#Use `agents-here` alias to link it into a project

#Ghostty setup
mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
rm -f "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
ln -s "$HOME/.dotfiles/ghostty.config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"

#Cursor setup
mkdir -p "$HOME/Library/Application Support/Cursor/User"
rm -f "$HOME/Library/Application Support/Cursor/User/settings.json"
ln -s "$HOME/.dotfiles/cursor/settings.json" "$HOME/Library/Application Support/Cursor/User/settings.json"

#Volta
curl https://get.volta.sh | bash

. "$(dirname "$0")/system_defaults.sh"
