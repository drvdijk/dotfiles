#!/usr/bin/env bash

###############################################################################
# Security & Privacy
###############################################################################

# Previous:
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


# Require password almost immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -bool true
defaults write com.apple.screensaver askForPasswordDelay -int 5

# # Disable automatic login
# sudo defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser &> /dev/null

# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# # Allow applications downloaded from anywhere
# sudo spctl --master-disable

# Enable firewall. Possible values:
#   0 = off
#   1 = on for specific sevices
#   2 = on for essential services
sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1

# # Allow signed apps
# sudo defaults write /Library/Preferences/com.apple.alf allowsignedenabled -bool true
#
# # Firewall logging
# sudo defaults write /Library/Preferences/com.apple.alf loggingenabled -bool false
#
# # Stealth mode
# sudo defaults write /Library/Preferences/com.apple.alf stealthenabled -bool true
#
# # Disable Infared Remote
# sudo defaults write /Library/Preferences/com.apple.driver.AppleIRController DeviceEnabled -bool false
#
# # Disable encrypted swap (secure virtual memory)
# #sudo defaults write /Library/Preferences/com.apple.virtualMemory DisableEncryptedSwap -boolean yes
#
# ###############################################################################
# # FileVault
# ###############################################################################
#
# # Enable FileVault (if not already enabled)
# # This requires a user password, and outputs a recovery key that should be
# # copied to a secure location
# if [[ $(sudo fdesetup status | head -1) == "FileVault is Off." ]]; then
#   sudo fdesetup enable -user `whoami`
# fi
#
# # Disable automatic login when FileVault is enabled
# #sudo defaults write /Library/Preferences/com.apple.loginwindow DisableFDEAutoLogin -bool true
#
# ###############################################################################
# # Privacy
# #
# # Privacy should be handled within each application's configuration using
# # the `tccutil` package installed via Homebrew.
# # Note: SIP must be disabled to modify the database.
# #
# # The below outlines an altenrative solution for configuring privacy.
# ###############################################################################
#
# # Databases located at:
# #   /Library/Application\ Support/com.apple.TCC/TCC.db
# #   ~/Library/Application\ Support/com.apple.TCC/TCC.db
#
# # All           : kTCCServiceAll
# # Accessibility : kTCCServiceAccessibility
# # Calendar      : kTCCServiceCalendar
# # Contacts      : kTCCServiceAddressBook
# # Location      : kTCCServiceLocation
# # Reminders     : kTCCServiceReminders
# # Facebook      : kTCCServiceFacebook
# # LinkedIn      : kTCCServiceLinkedIn
# # Twitter       : kTCCServiceTwitter
# # SinaWeibo     : kTCCServiceSinaWeibo
# # Liverpool     : kTCCServiceLiverpool
# # Ubiquity      : kTCCServiceUbiquity
# # TencentWeibo  : kTCCServiceTencentWeibo
#
# # service | client | client_type | allowed | prompt_count | csreq | policy_id
#
# # Grant access
# # sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db \
# #   "INSERT INTO access VALUES(${service},${bundle_id},0,1,1,NULL);"
#
# # Reset access
# # sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db \
# #   "DELETE FROM access WHERE client CLIENT '${bundle_id}';"
#
# # Revoke access
# # sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db \
# #   "INSERT INTO access VALUES(${service},${bundle_id},0,0,1,NULL);"
