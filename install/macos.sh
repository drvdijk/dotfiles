#!/usr/bin/env bash

# Load libs
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/../bin" && pwd )"/lib.sh

# Get current directory
CURDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# macos-defaults
$CURDIR/macos-defaults.sh

# homebrew
$CURDIR/homebrew.sh

# cask
$CURDIR/cask.sh

# mackup
$CURDIR/mackup.sh


