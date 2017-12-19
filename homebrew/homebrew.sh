#!/usr/bin/env bash
#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

# Load libs
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/../bin" && pwd )"/lib.sh

# Check OS X & sudo
require_osx
require_sudo

# Check for Homebrew
running "checking homebrew"
if test ! $(which brew); then
    action "installing homebrew"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" - --full
fi
ok


bot "installing tools via homebrew..."
# Make sure we’re using the latest Homebrew
action "update brew..."
brew update
ok "brew updated..."
# Need to run brew upgrade at this point to make sure `brew list` works correctly...
brew upgrade
ok "brew upgrade..."

# Install other common packages
action "installing packages..."
require_brew coreutils
if test ! -e /usr/local/bin/tac; then
    action "linking gtac to tac"
    ln -s /usr/local/bin/gtac /usr/local/bin/tac
fi
require_brew findutils
#require_brew kdiff3
require_brew trash
require_brew wget  --with-iri
require_brew tree

# ZSH, and add it to the shells list
require_brew zsh
echo $(which zsh) | sudo tee -a /etc/shells

bot "formulas brewed"

