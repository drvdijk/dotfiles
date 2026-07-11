#!/usr/bin/env bash

# Get dotfiles dir (so run this script from anywhere)
export DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"

# Exit immediately if anything exits with a non-zero status.
set -e

###
# some bash library helpers
# @author Adam Eivy
# https://github.com/atomantic/dotfiles
###

# Colors
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"34;01m"
COL_MAGENTA=$ESC_SEQ"35;01m"
COL_CYAN=$ESC_SEQ"36;01m"

function ok() {
    echo -e "$COL_GREEN[ok]$COL_RESET "$1
}

function bot() {
    echo -e "\n$COL_GREEN\[._.]/$COL_RESET - "$1
}

function running() {
    echo -en "$COL_YELLOW ⇒ $COL_RESET"$1": "
}

function action() {
    echo -e "\n$COL_YELLOW[action]:$COL_RESET\n ⇒ $1..."
}

function warn() {
    echo -e "$COL_YELLOW[warning]$COL_RESET "$1
}

function error() {
    echo -e "$COL_RED[error]$COL_RESET "$1
}


function require_sudo() {
    [ "$(sudo -n true 2>&1)" != "" ] && bot "I need you to enter your sudo password so I can install some things:"
    # Ask for the administrator password upfront
    sudo -v
    # Keep-alive: update existing `sudo` time stamp until `.osx` has finished
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}

function require_osx() {
    if [ "$(uname -s)" != "Darwin" ]; then
        error "Only supported on OS X"
        exit 0
    fi
}

function require_homebrew() {
    # Install Homebrew if not installed - brew.sh
    running "checking homebrew"
    if ! hash brew 2>/dev/null; then
        action "installing homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # can do full pull instead if specific versions are needed again at some point:
        # ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" - --full
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
}

function require_full_disk_access() {
    if ! plutil -lint /Library/Preferences/com.apple.TimeMachine.plist >/dev/null ; then
        echo "This script requires your terminal app to have Full Disk Access."
        echo "Add this terminal to the Full Disk Access list in System Preferences > Security & Privacy, quit the app, and re-run this script."
        exit -1
    fi
}

# Install just the named brew/cask/mas entries from a Brewfile, instead of
# running the whole file through `brew bundle`. Looks up each name as an
# exact match against a `brew "name"` / `cask "name"` / `mas "name", id: N`
# line and installs it with the right brew subcommand.
function brew_install_from_file() {
    local brewfile="$1"; shift
    local name line type id

    for name in "$@"; do
        line="$(grep -E "^(brew|cask|mas)[[:space:]]+\"${name}\"" "$brewfile" | head -1)"
        if [ -z "$line" ]; then
            error "no entry for '$name' in $(basename "$brewfile"), skipping"
            continue
        fi

        type="$(echo "$line" | awk '{print $1}')"
        case "$type" in
            brew)
                action "installing $name"
                brew install "$name"
                ;;
            cask)
                action "installing $name (cask)"
                brew install --cask "$name"
                ;;
            mas)
                hash mas 2>/dev/null || brew install mas
                id="$(echo "$line" | grep -oE 'id:[[:space:]]*[0-9]+' | grep -oE '[0-9]+')"
                if [ -n "$id" ]; then
                    action "installing $name (App Store, id $id)"
                    mas install "$id"
                else
                    error "could not parse App Store id for '$name'"
                fi
                ;;
        esac
    done
}
