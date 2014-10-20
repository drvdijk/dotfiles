#!/usr/bin/env bash
#
# Homebrew cask
#
# This installs some GUI apps on OS X

# Load libs
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/../bin/lib.sh

# Check OS X & sudo
require_osx
require_sudo


if [ -z "$HOMEBREW_CASK_OPTS" ]; then
    # Install to /Applications instead of ~/Applications
    export HOMEBREW_CASK_OPTS="--appdir=/Applications"
fi

# Install cask
bot "Installing homebrew cask"
require_brew caskroom/cask/brew-cask

# Apps!
action "installing apps..."
require_cask caskroom/versions/google-chrome-beta
require_cask dropbox

