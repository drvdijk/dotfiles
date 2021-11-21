#!/usr/bin/env bash

###############################################################################
# Mission Control
###############################################################################

# # Mission Control animation duration
# defaults write com.apple.dock expose-animation-duration -float 0.1

# Automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# # When switching to an application, switch to a Space with open windows for the application
# defaults write NSGlobalDomain AppleSpacesSwitchOnActivate -bool true
#
# # Group windows by application in Mission Control
# # (i.e. use the old Exposé behavior instead)
# defaults write com.apple.dock expose-group-by-app -bool false
#
# # Displays have seperate Spaces
# defaults write com.apple.spaces spans-displays -bool false
#
# # Disable the Launchpad gesture (pinch with thumb and three fingers)
# #defaults write com.apple.dock showLaunchpadGestureEnabled -int 0
#
# # Reset Launchpad
# find "${HOME}/Library/Application Support/Dock" -name "*-*.db" -maxdepth 1 -delete
#
# # Add iOS Simulator to Launchpad
# if [ -e "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app" ]; then
#     sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app" \
#                 "/Applications/Simulator.app"
# fi
#
# Hot corners
#  0 : NOP
#  2 : Mission Control
#  3 : Show application windows
#  4 : Desktop
#  5 : Start screen saver
#  6 : Disable screen saver
#  7 : Dashboard
# 10 : Put display to sleep
# 11 : Launchpad
# 12 : Notification Center
# Top left screen corner → Start screen saver
defaults write com.apple.dock wvous-tl-corner   -int 5
defaults write com.apple.dock wvous-tl-modifier -int 0
# Top right screen corner
defaults write com.apple.dock wvous-tr-corner   -int 0
defaults write com.apple.dock wvous-tr-modifier -int 0
# Bottom left screen corner → Put screen to sleep
defaults write com.apple.dock wvous-bl-corner   -int 10
defaults write com.apple.dock wvous-bl-modifier -int 0
# Bottom right screen corner
defaults write com.apple.dock wvous-br-corner   -int 0
defaults write com.apple.dock wvous-br-modifier -int 0

# # Disable Dashboard
# defaults write com.apple.dashboard mcx-disabled -bool true
#
# # Dashboard:
# # 1: Off
# # 2: As Space
# # 3: As Overlay
# defaults write com.apple.dashboard enabled-state -int 1

# Don’t show Dashboard as a Space
defaults write com.apple.dock dashboard-in-overlay -bool true

# # Enable Dashboard dev mode (allows keeping widgets on the desktop)
# defaults write com.apple.dashboard devmode -bool true
