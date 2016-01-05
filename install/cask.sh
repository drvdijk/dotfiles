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
brew tap caskroom/cask --full

# Apps!
action "installing apps..."
require_cask 1password
#require_cask adobe-photoshop-lightroom # this is lightroom 5, 6 is not available through caskroom
require_cask bartender
require_cask caffeine
require_cask daisydisk
require_cask dash
require_cask dropbox
#require_cask evernote
require_cask flash-player
require_cask firefox
require_cask forklift
require_cask google-chrome
#require_cask ifunbox
require_cask iterm2
require_cask kdiff3
require_cask macvim
#require_cask menumeters # disabled because it doesn't work with el capitan, see http://member.ipmu.jp/yuji.tachikawa/MenuMetersElCapitan/
#require_cask mou
#require_cask pycharm-ce
require_cask sequel-pro
#require_cask skitch
require_cask sizeup
require_cask silverlight
require_cask skype
require_cask sourcetree
#require_cask spotify
require_cask the-unarchiver
require_cask virtualbox
require_cask vlc

# Quicklook plugins
action "installing quicklook plugins..."
require_cask betterzipql

bot "All done with these lovely apps!"

