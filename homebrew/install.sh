#!/usr/bin/env bash
#
# homebrew and cask
#
# calls homebrew script first, followed by the caskroom script
# reorganizing the dotfiles, this will change (soon?) to just use a Brewfile followed
# by some app-specific stuff like the current homebrew/caskroom scripts currently do

source $(dirname ${BASH_SOURCE[0]})/homebrew.sh
source $(dirname ${BASH_SOURCE[0]})/cask.sh
