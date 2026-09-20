#!/usr/bin/env bash
#
# homebrew and cask DEVELOPMENT apps
#

# Load libs
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/../bin" && pwd )"/lib.sh

require_osx

install_brewfile development "$(dirname "${BASH_SOURCE[0]}")/Brewfile" "$@"
