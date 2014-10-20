#!/usr/bin/env bash

# Exit immediately if anything exits with a non-zero status.
set -e

# Get current directory
CURDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# osx-defaults
$CURDIR/osx-defaults.sh

# homebrew
$CURDIR/homebrew.sh

# cask
$CURDIR/cask.sh

