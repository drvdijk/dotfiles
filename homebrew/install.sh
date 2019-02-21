#!/usr/bin/env bash
#
# homebrew, cask, and mas apps
#

# Load libs
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/../bin" && pwd )"/lib.sh

# Check OS X & sudo
require_osx
require_sudo
require_homebrew

# Install all available updates
sudo softwareupdate -ia --verbose

bot "installing tools via homebrew..."
# Make sure we’re using the latest Homebrew
action "update brew..."
brew update
ok "brew updated..."
# Need to run brew upgrade at this point to make sure `brew list` works correctly...
brew upgrade
ok "brew upgraded..."

# Install homebrew, cask, and mas stuff from brew file here
brew bundle --file=$(dirname ${BASH_SOURCE[0]})/Brewfile

# Add zsh to shells list
if [[ $(cat /etc/shells | grep $(which zsh) | wc -c) -eq 0 ]]; then
    echo $(which zsh) | sudo tee -a /etc/shells
fi

# Remove outdated versions from the cellar
brew cleanup
