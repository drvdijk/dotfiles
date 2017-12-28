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

require_osx
require_sudo

bot "Let's set some reasonable OS X defaults!"

# TODO the macos-defaults.sh should become completely obsolete!
source $(dirname ${BASH_SOURCE[0]})/macos-defaults.sh

# Set global variables
PREF_FILES=()
AFFECTED_APPS=()
# Add preference file followed by any number of affected applications
function set_prefs {
  PREF_FILES+=("apps/$1.sh")
  shift
  AFFECTED_APPS+=("$@")
}

# Sources all the preference files
function source_prefs {
  for pref_file in "${PREF_FILES[@]}"; do
    file=$( dirname "${BASH_SOURCE[0]}" )/$pref_file
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
  done
}

# Check for open application
function get_open_affected_apps {
  open_apps=()

  # Store the open apps in an array
  for app in "${AFFECTED_APPS[@]}"; do
    (( $(osascript -e "tell app \"System Events\" to count processes whose name is \"${app}\"") > 0 )) \
    && open_apps+=("$app")
  done

  echo "The following open applications will be affected:"

  # Print the open apps in columns
  printf -- '%s\n' "${open_apps[@]}" | column -x

  echo "Would you like to quit these apps now? [Y/n] "
  echo "TODO these apps should then be quit ... Please do so manually for now.."
  read -p ""
}

# Quit affected applications
function quit_apps {
  for app in "${AFFECTED_APPS[@]}"; do
    case "$app" in
      'Quick Look')
        # Restart Quick Look
        qlmanage -r
        ;;
      *)
        killall "$app" &>/dev/null
        # osascript -e "tell application \"${app}\" to quit"
        ;;
    esac
  done
}

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
  general
  desktop-screen-saver
  dock
  mission-control
  language-region
  security-privacy
  spotlight
  notifications

  displays
  energy-saver
  keyboard
  # mouse
  trackpad
  printers-scanners
  sound
  # startup-disk

  icloud
  # internet-accounts
  extensions
  app-store
  # network
  bluetooth
  sharing #DONE

  users-groups
  # parental-controls
  siri
  date-time
  time-machine
  accessibility

  other
  dashboard
  cds-dvds
  # ssd
)

for pane in "${system_preferences[@]}"; do
  PREF_FILES+=("system/${pane}.sh")
done

for pane in "cfprefsd" "SystemUIServer" "Dock" "SpeechSynthesisServer"; do
  AFFECTED_APPS+=("$pane")
done

# Default Apps
set_prefs activity-monitor "Activity Monitor"
set_prefs app-store "App Store"
# set_prefs calendar "Calendar"
set_prefs contacts "Contacts"
set_prefs disk-utility "Disk Utility"
set_prefs finder "Finder"
set_prefs font-book "Font Book"
set_prefs iwork "Keynote" "Numbers" "Pages"
set_prefs mail "Mail"
set_prefs messages "Messages"
set_prefs quicktime "QuickTime Player"
set_prefs safari "Safari" "WebKit"
set_prefs terminal # Do not kill "Terminal" - it will stop script execution
set_prefs textedit "TextEdit"

# Third Party Apps
set_prefs adobe
set_prefs divvy "Divvy"
set_prefs dropbox "Dropbox"
set_prefs google-chrome "Google Chrome"
set_prefs qlcolorcode "Quick Look"
set_prefs sublime-text "Sublime Text"
set_prefs transmission "Transmission"

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Run
get_open_affected_apps
source_prefs
quit_apps

prompt_restart
