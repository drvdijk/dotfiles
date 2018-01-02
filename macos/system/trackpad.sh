#!/usr/bin/env bash

###############################################################################
# Trackpad
###############################################################################

# # Disable "natural" scrolling
# #defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true # https://github.com/mathiasbynens/dotfiles/issues/793
defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1
defaults write -g com.apple.mouse.tapBehavior -int 1

# Tap with two fingers to emulate right click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true

# Map bottom right corner to right-click
# #defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
# #defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
# #defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
#
# # Swipe between pages with three fingers
# #defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool true
# #defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerHorizSwipeGesture -int 1
# #defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 1
#
# # Force Click and haptic feedback
# defaults write NSGlobalDomain com.apple.trackpad.forceClick -bool true
# defaults write com.apple.AppleMultitouchTrackpad ForceSuppressed -bool false
# defaults write com.apple.AppleMultitouchTrackpad ActuateDetents -bool true
#
# # Silent clicking
# defaults write com.apple.AppleMultitouchTrackpad ActuationStrength -int 0
#
# # Haptic feedback
# # 0: Light
# # 1: Medium
# # 2: Firm
# defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 0
# defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold -int 0

# Tracking Speed
# 0: Slow
# 3: Fast
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 1.5

# # Disable swipe between pages
# defaults write AppleEnableSwipeNavigateWithScrolls -bool false
#
# Enable three finger drag
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
