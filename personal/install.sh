#!/usr/bin/env bash
#
# homebrew and cask personal apps
#

# Load libs
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/../bin" && pwd )"/lib.sh

require_osx

install_brewfile personal "$(dirname "${BASH_SOURCE[0]}")/Brewfile" "$@"
