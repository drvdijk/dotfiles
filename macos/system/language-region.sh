#!/usr/bin/env bash

###############################################################################
# Language & Region
###############################################################################

# Prefered languages (in order of preference)
defaults write -g AppleLanguages -array "en" "nl"

# Currency
# United States : `en_US@currency=USD`
# Great Britian : `en_GB@currency=EUR`
defaults write -g AppleLocale -string "en_NL@currency=EUR"

# Measure Units
# `Inches` or `Centimeters`
defaults write -g AppleMeasurementUnits -string "Centimeters"

# Force 12/24 hour time
#defaults write NSGlobalDomain AppleICUForce12HourTime -bool true
defaults write NSGlobalDomain AppleICUForce24HourTime -bool true

# Set Metric Units
defaults write NSGlobalDomain AppleMetricUnits -bool true

# Show language menu in the top right corner of the boot screen
#sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool true
