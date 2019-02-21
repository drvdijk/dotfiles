#!/usr/bin/env bash
#
# homebrew and cask DEVELOPMENT apps
#

# Load libs
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/../bin" && pwd )"/lib.sh

# Check OS X & sudo
require_osx
require_sudo
require_homebrew

bot "installing tools via homebrew..."
# Make sure we’re using the latest Homebrew
action "update brew..."
brew update
ok "brew updated..."
# Need to run brew upgrade at this point to make sure `brew list` works correctly...
brew upgrade
ok "brew upgraded..."

# Accept xcode developer license
sudo xcodebuild -license accept

# Install homebrew, cask, and mas stuff from brew file here
brew bundle --file=$(dirname ${BASH_SOURCE[0]})/Brewfile

# Remove outdated versions from the cellar
brew cleanup
