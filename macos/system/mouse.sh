#!/usr/bin/env bash

###############################################################################
# Mouse
###############################################################################

# Enable mouse right-click
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseButtonMode "TwoButton"
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseOneFingerDoubleTapGesture -bool true

# Set <s>trackpad &</s> mouse speed to a reasonable number
defaults write -g com.apple.mouse.scaling 1.5
