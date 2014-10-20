#!/usr/bin/env bash

# Source: https://github.com/webpro/dotfiles/blob/master/install.sh

# Get current dir (so run this script from anywhere)
export DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Update dotfiles itself first
[ -d "$DOTFILES_DIR/.git" ] && git --work-tree="$DOTFILES_DIR" --git-dir="$DOTFILES_DIR/.git" pull origin master

# Call dotfiles gitconfig & bootstrap
$DOTFILES_DIR/bin/dotfiles gitconfig
$DOTFILES_DIR/bin/dotfiles bootstrap

