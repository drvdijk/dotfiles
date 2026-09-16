#!/usr/bin/env bash

###############################################################################
# Date & Time
###############################################################################

# Set the timezone; see `systemsetup -listtimezones` for other values
sudo systemsetup -settimezone "Europe/Amsterdam" 2>/dev/null

# Set date and time automatically
sudo systemsetup -setusingnetworktime on 2>/dev/null

# Set time server
sudo systemsetup -setnetworktimeserver "time.apple.com" 2>/dev/null

# Set time zome automatically using current location
sudo defaults write /Library/Preferences/com.apple.timezone.auto.plist Active -bool true

# Menu bar clock format
# "h:mm" Default
# "HH"   Use a 24-hour clock
# "a"    Show AM/PM
# "ss"   Display the time with seconds
#
# Since Big Sur, DateFormat alone is no longer enough — Show24Hour/ShowAMPM/
# ShowSeconds must be set explicitly. ControlCenter (not SystemUIServer) is
# restarted by macos/install.sh's set_prefs call for this to take effect.
defaults write com.apple.menuextra.clock DateFormat -string "HH:mm:ss"
defaults write com.apple.menuextra.clock Show24Hour -bool true
defaults write com.apple.menuextra.clock ShowAMPM -bool false
defaults write com.apple.menuextra.clock ShowSeconds -bool true

# Show only the time, not the date, in the menu bar
# ShowDate: 0 = When Space Allows, 1 = Always, 2 = Never
defaults write com.apple.menuextra.clock ShowDate -int 2
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool false

# Flash the time separators
defaults write com.apple.menuextra.clock FlashDateSeparators -bool true

# Analog menu bar clock
defaults write com.apple.menuextra.clock IsAnalog -bool false
