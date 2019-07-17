#!/usr/bin/env bash

###############################################################################
# Flycut
###############################################################################

mkdir -p ~/Library/Application\ Support/Flycut
cat <<EOMM >~/Library/Application\ Support/Flycut/com.generalarcade.flycut.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>ShortcutRecorder mainHotkey</key>
	<dict>
		<key>keyCode</key>
		<integer>9</integer>
		<key>modifierFlags</key>
		<integer>1179648</integer>
	</dict>
	<key>bezelAlpha</key>
	<real>0.25</real>
	<key>bezelHeight</key>
	<real>320</real>
	<key>bezelWidth</key>
	<real>500</real>
	<key>displayNum</key>
	<integer>10</integer>
	<key>loadOnStartup</key>
	<false/>
	<key>menuIcon</key>
	<integer>0</integer>
	<key>menuSelectionPastes</key>
	<true/>
	<key>popUpAnimation</key>
	<false/>
	<key>rememberNum</key>
	<integer>40</integer>
	<key>removeDuplicates</key>
	<false/>
	<key>savePreference</key>
	<integer>1</integer>
	<key>skipPasswordFields</key>
	<true/>
	<key>stickyBezel</key>
	<false/>
	<key>store</key>
	<dict>
		<key>displayLen</key>
		<integer>40</integer>
		<key>displayNum</key>
		<integer>10</integer>
		<key>jcList</key>
		<array/>
		<key>rememberNum</key>
		<integer>40</integer>
		<key>version</key>
		<string>0.7</string>
	</dict>
	<key>wraparoundBezel</key>
	<false/>
</dict>
</plist>
EOMM