#!/usr/bin/env bash

# Load libs
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../bin" && pwd )"/lib.sh

###############################################################################
# Sharing
###############################################################################

action "Computer name for this mac"
echo -e "Enter the computer name you want to use for this Mac (empty to skip):"
read computer_name
if [ ! -z $computer_name ]; then
	# Set computer name (as done via System Preferences → Sharing)
    running "Setting computer name"
	sudo scutil --set ComputerName "$computer_name"
	sudo scutil --set HostName "$computer_name"
	sudo scutil --set LocalHostName "$computer_name"
	sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$computer_name"
    ok
fi
