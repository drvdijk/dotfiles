#!/usr/bin/env bash
#
# Homebrew cask
#
# This installs some GUI apps on OS X

# Exit immediately if anything exits with a non-zero status.
set -e

# Load libs
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/../bin" && pwd )"/lib.sh

# Check OS X
if [ "$(uname -s)" != "Darwin" ]; then
    error "Homebrew only supported on OS X"
    exit 0
fi

require_sudo



if [ -z "$HOMEBREW_CASK_OPTS" ]; then
    # Install to /Applications instead of ~/Applications
    export HOMEBREW_CASK_OPTS="--appdir=/Applications"
fi

# Get current directory
CURDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check for homebrew & install if necessary
if test ! $(which brew); then
    $CURDIR/homebrew.sh
fi

# Install cask
bot "Installing homebrew cask"
require_brew caskroom/cask/brew-cask

# Apps!
action "installing apps..."
require_cask caskroom/versions/google-chrome-beta

