#!/usr/bin/env bash
#
# Idea from Joey Hoer, split mac prefs and application prefs, have a script
# setting prefs specifically for each, and clean up afterwards.
#
# https://github.com/joeyhoer/starter
#
# The original idea (and a couple settings) came from a couple of places:
#   https://github.com/mathiasbynens/dotfiles/blob/master/.osx
#   https://gist.github.com/MatthewMueller/e22d9840f9ea2fee4716
#   https://gist.github.com/saetia/1623487
#

# Load libs
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/../bin" && pwd )"/lib.sh

require_full_disk_access
require_osx
require_sudo

bot "Let's set some reasonable OS X defaults!"

# Set global variables (see bin/lib.sh for set_prefs/source_prefs/etc.)
PREF_FILES=()
AFFECTED_APPS=()
PREF_APPS=()

# Prompt if user wants to restart the machine
function prompt_restart {
  echo "Done. Note that some of these changes require a logout/restart to take effect."
  read -p "Would you like to restart the computer now? [Y/n] " -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      osascript -e 'tell app "System Events" to restart'
  fi
}

# System Prefrences
system_preferences=(
  icloud

  general
  # desktop-screen-saver
  dock
  mission-control
  siri
  # spotlight
  language-region
  # notifications

  # internet-accounts
  # passwords
  # wallet-apple-pay
  users-groups
  accessibility
  # screen-time
  # extensions
  security-privacy


  # software-update
  # network
  # bluetooth
  sound
  # touch-id
  keyboard
  trackpad
  mouse

  # displays
  printers-scanners
  battery
  date-time
  sharing
  time-machine
  # startup-disk

  other
)

PREFS_DIR="$(dirname "${BASH_SOURCE[0]}")/system"
for pane in "${system_preferences[@]}"; do
  set_prefs "$pane" cfprefsd SystemUIServer Dock SpeechSynthesisServer
done

# Default Apps (built into macOS, so they live here rather than in a
# Brewfile topic's apps/ dir)
PREFS_DIR="$(dirname "${BASH_SOURCE[0]}")/apps"
# set_prefs activity-monitor "Activity Monitor"
set_prefs app-store "App Store"
set_prefs calendar "Calendar"
set_prefs contacts "Contacts"
set_prefs disk-utility "Disk Utility"
set_prefs finder "Finder"
# set_prefs font-book "Font Book"
# set_prefs iwork "Keynote" "Numbers" "Pages"
# set_prefs mail "Mail"
set_prefs messages "Messages"
set_prefs photos "Photos"
# set_prefs quicktime "QuickTime Player"
set_prefs safari "Safari" "WebKit"
set_prefs terminal # Do not kill "Terminal" - it will stop script execution
set_prefs textedit "TextEdit"

# Third-party app prefs live next to the Brewfile that installs them (e.g.
# homebrew/apps/sublime-text.sh) and are applied via
# `dotfiles install homebrew <app>` or a full `dotfiles install homebrew`.

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

if [ "$#" -gt 0 ]; then
  # Only apply the named app/pane prefs (e.g. "finder", "dock"), instead of
  # the whole set.
  if select_prefs "$@"; then
    get_open_affected_apps
    source_prefs
  fi
else
  get_open_affected_apps
  source_prefs

  prompt_restart
fi
