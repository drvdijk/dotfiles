#!/usr/bin/env bash

###############################################################################
# Bartender 3
###############################################################################

# Bartender has launched before
defaults write com.surteesstudios.Bartender SUHasLaunchedBefore -bool true

# Insert a gap when Notification Center is hdden
defaults write com.surteesstudios.Bartender insertGap -bool true

# Check for Updates Automatically
defaults write com.surteesstudios.Bartender SUAutomaticallyUpdate -bool true

# When on battery, decrease update checking
defaults write com.surteesstudios.Bartender ReduceUpdateCheckFrequencyWhenOnBattery -bool true

# Bartender menu bar icon:
# Waistcoat, Bartender, Bowtie, Glasses, Star, Box
defaults write com.surteesstudios.Bartender statusBarImageNamed -string "Bartender"

# License, disabled because not sharing my license on github :o)
# defaults write com.surteesstudios.Bartender license "..."
# defaults write com.surteesstudios.Bartender license2 "..."
# defaults write com.surteesstudios.Bartender licenseHoldersName "..."
# defaults write com.surteesstudios.Bartender license2HoldersName "..."

# Individual app settings
defaults delete com.surteesstudios.Bartender appSettings 2>/dev/null
plutil -insert appSettings -json '{
	"com.google.Chrome": {
		"showForUpdates": true,
		"popupFix": false,
		"updateDisplayTime": 5,
		"controlled": 1
	},
	"com.lightheadsw.caffeine": {
		"showForUpdates": true,
		"popupFix": false,
		"updateDisplayTime": 5,
		"controlled": 0
	},
	"BatteryExtra": {
		"showForUpdates": true,
		"popupFix": false,
		"updateDisplayTime": 30,
		"controlled": 1
	},
	"AppleTimeMachineExtra": {
		"showForUpdates": true,
		"popupFix": false,
		"updateDisplayTime": 10,
		"controlled": 1
	},
	"NotificationCenter": {
		"showForUpdates": false,
		"popupFix": false,
		"updateDisplayTime": 5,
		"controlled": 1
	},
	"com.docker.docker": {
		"searchName": "Docker",
		"showForUpdates": true,
		"updateDisplayTime": 15,
		"controlled": 1
	},
	"Siri": {
		"searchName": "Siri",
		"showForUpdates": false,
		"updateDisplayTime": 15,
		"controlled": 1
	},
	"DisplaysExtra": {
		"showForUpdates": false,
		"popupFix": false,
		"updateDisplayTime": 5,
		"controlled": 1
	},
	"se.cocoabeans.apptivate": {
		"searchName": "Apptivate",
		"showForUpdates": true,
		"updateDisplayTime": 15,
		"controlled": 1
	},
	"com.apple.Spotlight": {
		"showForUpdates": false,
		"popupFix": false,
		"updateDisplayTime": 5,
		"controlled": 1
	},
	"net.tunnelblick.tunnelblick": {
		"searchName": "Tunnelblick",
		"showForUpdates": true,
		"updateDisplayTime": 15,
		"controlled": 1
	},
	"com.getdropbox.dropbox": {
		"showForUpdates": true,
		"popupFix": false,
		"updateDisplayTime": 5,
		"controlled": 1
	},
	"com.skype.skype": {
		"showForUpdates": true,
		"popupFix": false,
		"updateDisplayTime": 5,
		"controlled": 1
	},
	"AppleClockExtra": {
		"searchName": "Clock",
		"showForUpdates": false,
		"updateDisplayTime": 15,
		"controlled": 1
	},
	"AppleBluetoothExtra": {
		"showForUpdates": true,
		"popupFix": false,
		"updateDisplayTime": 10,
		"controlled": 1
	},
	"com.generalarcade.flycut": {
		"showForUpdates": true,
		"popupFix": false,
		"updateDisplayTime": 5,
		"controlled": 1
	},
	"AppleVolumeExtra": {
		"showForUpdates": true,
		"popupFix": false,
		"updateDisplayTime": 5,
		"controlled": 1
	},
	"menuExtra.spotlight": {
		"showForUpdates": true,
		"popupFix": false,
		"updateDisplayTime": 5,
		"controlled": 1
	},
	"com.bjango.istatmenusstatus": {
		"showForUpdates": false,
		"popupFix": false,
		"updateDisplayTime": 5,
		"controlled": 0
	},
	"AirPortExtra": {
		"showForUpdates": true,
		"popupFix": false,
		"updateDisplayTime": 10,
		"controlled": 1
	}
}' ~/Library/Preferences/com.surteesstudios.Bartender.plist

# Don't show welcome message spash screen when starting up
defaults write com.surteesstudios.Bartender UpdateWelcomeMessageShowAgain -bool true

