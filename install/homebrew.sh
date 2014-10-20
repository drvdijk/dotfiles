#!/usr/bin/env bash
#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

# Exit immediately if anything exits with a non-zero status.
set -e

# Load libs
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/../bin" && pwd )"/lib.sh

# Check OS X
if [ "$(uname -s)" != "Darwin" ]; then
    error "  Homebrew only supported on OS X"
    exit 0
fi

require_sudo


# Check for Homebrew
running "checking homebrew"
if test ! $(which brew); then
    action "installing homebrew"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
ok


bot "installing tools via homebrew..."
# Make sure we’re using the latest Homebrew
action "update brew..."
brew update
ok "brew updated..."

action "installing packages..."

# Install GNU core utilities (those that come with OS X are outdated)
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
require_brew coreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed
require_brew findutils

# Install other common packages
require_brew mackup
require_brew trash
require_brew wget  --enable-iri

exit 0
