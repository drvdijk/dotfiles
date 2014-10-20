#!/usr/bin/env bash
# Source: https://github.com/webpro/dotfiles/blob/master/install.sh

# Load libs
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/bin/lib.sh


# Update dotfiles itself first
bot "Let's install some dotfiles! Updating repo..."
[ -d "$DOTFILES_DIR/.git" ] && git --work-tree="$DOTFILES_DIR" --git-dir="$DOTFILES_DIR/.git" pull origin master

# Call dotfiles gitconfig, bootstrap, and help
$DOTFILES_DIR/bin/dotfiles gitconfig
$DOTFILES_DIR/bin/dotfiles bootstrap

bot "Setup done, check out dotfiles!"
$DOTFILES_DIR/bin/dotfiles help

