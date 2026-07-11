#!/usr/bin/env bash

###############################################################################
# Sublime Text (ST4 also reads from the ST3 path for backwards compatibility)
###############################################################################

mkdir -p ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User
cp -R ~/.dotfiles/sublime-text/Packages/User/. ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/ || true
