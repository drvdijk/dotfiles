#!/usr/bin/env bash
#
# Mackup
#
# Backup/sync configuration files to dropbox. This script installs mackup, dropbox, and restores configuration files.

# Load libs
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/../bin/lib.sh

require_osx

bot "Let's get Mackup up & running!"

running "Installing Mackup"
require_brew mackup
ok

running "Installing Dropbox"
require_cask dropbox
ok

running "Opening dropbox"
open -a Dropbox.app
ok

action "Please make sure you're signed in to to dropbox & the Mackup folder is synchronized fully"
running "Press enter when signed in & Mackup folder is synced to continue"
read -p ""
running "Sure the Mackup folder is synced? Press CTRL-C to cancel"
read -p ""

running "Restoring configuration"
mackup restore
ok

if [ -e ~/.ssh ]; then
    running "Restricting .ssh file permissions after syncing"
    chmod -R go-rwx ~/.ssh
    ok
fi

