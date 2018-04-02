#!/usr/bin/env bash
#x-code
xcode-select --install

# Install brew with packages & casks
. "$DOTFILES_DIR/install/brew.sh"

# Setup macos defaults
. "$DOTFILES_DIR/macos/defaults.sh"