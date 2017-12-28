#!/usr/bin/env bash

# Sets reasonable OS X defaults.
#
# Or, in other words, set shit how I like in OS X.
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

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

###############################################################################
# General UI/UX                                                               #
###############################################################################

# Disable menu bar transparency
defaults write -g AppleEnableMenuBarTransparency -bool false

# Enable shortcut to switch between dark and light mode (control+option+command+T)
sudo defaults write /Library/Preferences/.GlobalPreferences.plist _HIEnableThemeSwitchHotKey -bool true

# Ask to keep changes when closing documents
defaults write -g NSCloseAlwaysConfirmsChanges -bool true

##############################################################################
# Security                                                                   #
##############################################################################
# Based on:
# https://github.com/atomantic/dotfiles/blob/master/install.sh
# https://github.com/drduh/macOS-Security-and-Privacy-Guide
# https://benchmarks.cisecurity.org/tools2/osx/CIS_Apple_OSX_10.12_Benchmark_v1.0.0.pdf

# This part is disabled for now, as it doesn't seem to be supported by default
## Disable remote apple events
#sudo systemsetup -setremoteappleevents off
#
## Disable remote login
#sudo systemsetup -setremotelogin off
#
## Disable wake-on modem
#sudo systemsetup -setwakeonmodem off
#
## Disable wake-on LAN
#sudo systemsetup -setwakeonnetworkaccess off

# not disabling Gate Keeper anymore, let's find out where that gives problems!
## Disable OS X Gate Keeper, (you'll be able to install any app you want from here on, not just Mac App Store apps)
#sudo spctl --master-disable
#sudo defaults write /var/db/SystemPolicy-prefs.plist enabled -string no

###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
###############################################################################

# Enable three finger tap (look up)
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture -int 2

# Enable mouse right-click
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseButtonMode "TwoButton"
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseOneFingerDoubleTapGesture -bool true

# Set <s>trackpad &</s> mouse speed to a reasonable number
defaults write -g com.apple.mouse.scaling 1.5

###############################################################################
# Dock, Dashboard, and hot corners                                            #
###############################################################################

# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1


###############################################################################
# Safari & WebKit                                                             #
###############################################################################

# Press Tab to highlight each item on a web page
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true

# Hide Safari’s bookmarks bar by default
defaults write com.apple.Safari ShowFavoritesBar -bool false

# Hide Safari’s sidebar in Top Sites
defaults write com.apple.Safari ShowSidebarInTopSites -bool false

# Enable continuous spellchecking
defaults write com.apple.Safari WebContinuousSpellCheckingEnabled -bool true
# Disable auto-correct
defaults write com.apple.Safari WebAutomaticSpellingCorrectionEnabled -bool false

# Update extensions automatically
defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true

###############################################################################
# Photos                                                                      #
###############################################################################

# Prevent Photos from opening automatically when devices are plugged in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

### TODO Came to here in the macos-defaults.sh file while splitting it up

###############################################################################
# Kill affected applications                                                  #
###############################################################################

action "restarting (killing) affected apps"
set +e

for app in "cfprefsd" "Dock" "Finder" "Messages" "Safari" "SystemUIServer"; do
	killall "${app}" > /dev/null 2>&1
done

bot "woot!"
warn "Note that some of these changes require a logout/restart to take effect."
