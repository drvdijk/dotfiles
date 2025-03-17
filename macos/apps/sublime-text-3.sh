#!/usr/bin/env bash

###############################################################################
# Sublime Text 3
###############################################################################

mkdir -p ~/Library/Application\ Support/Sublime\ Text\ 3/Packages
#ln -s ~/Dropbox/sync/Library/Application\ Support/Sublime\ Text\ 3/Packages/User ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User || true
cp -r ~/.dotfiles/sublime-text/Packages/User ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User || true
