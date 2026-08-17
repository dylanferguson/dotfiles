#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#link SRC DEST — replace DEST with a symlink to DOTFILES/SRC, whatever DEST is
link() {
  local src="$DOTFILES/$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  rm -rf "$dest"
  ln -s "$src" "$dest"
  echo "linked $dest -> $src"
}

#Homebrew — install it first, since everything below assumes it
if ! command -v brew > /dev/null; then
  echo 'Installing Homebrew...'
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

#Homebrew packages
brew update
brew bundle --file="$DOTFILES/Brewfile"

#Use the Homebrew bash as the login shell
BREW_BASH="$(brew --prefix)/bin/bash"
if [[ "${SHELL:-}" != "$BREW_BASH" ]]; then
  grep -qxF "$BREW_BASH" /etc/shells || sudo tee -a /etc/shells <<< "$BREW_BASH" > /dev/null
  chsh -s "$BREW_BASH"
fi

#Setup and tidy
read -p "Delete ~/Movies, ~/Music, ~/Pictures, ~/Public, ~/Documents? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  sudo rm -rf ~/Movies ~/Music ~/Pictures ~/Public ~/Documents
fi

#Git config
link .gitconfig ~/.gitconfig
link .gitignore_global ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global
#git also reads ~/.config/git/ignore, which would shadow the file above
rm -f ~/.config/git/ignore

#Bash
rm -f ~/.zshrc
link .bash_profile ~/.bash_profile
link .bashrc ~/.bashrc

#AI agent setup
link AGENTS.md ~/.codex/AGENTS.md
link AGENTS.md ~/.claude/CLAUDE.md
link agents/claude/settings.json ~/.claude/settings.json

#Skills live in dotfiles/agents (vendor-agnostic)
link agents/skills ~/.claude/skills
link agents/skills ~/.agents/skills

#pi coding agent extensions live in dotfiles/agents/extensions
link agents/extensions ~/.pi/agent/extensions

#Cursor also supports AGENTS.md per-project (no global path)
#Use `agents-here` alias to link it into a project

#Terminal and prompt
link ghostty.config "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
link starship.toml ~/.config/starship.toml

#Editors
link cursor/settings.json "$HOME/Library/Application Support/Cursor/User/settings.json"
link vscode/settings.json "$HOME/Library/Application Support/Code/User/settings.json"

"$DOTFILES/system_defaults.sh"
