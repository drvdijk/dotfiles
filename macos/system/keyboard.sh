#!/usr/bin/env bash

###############################################################################
# Keyboard
###############################################################################

# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Set key repeat rate (minimum 1)
# Note OS X Sierra issues: https://github.com/mathiasbynens/dotfiles/commit/5e2360b8df0dfa50bc42c566b22fccbc846d5cf3
# Off: 300000
# Slow: 120
# Fast: 2
defaults write NSGlobalDomain KeyRepeat -int 2

# Set delay until repeat (in milliseconds)
# Long: 120
# Short: 15
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# # Adjust keyboard brightness in low light
# defaults write com.apple.BezelServices kDim -bool true
# sudo defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor "Automatic Keyboard Enabled" -bool true
#
# # Dim keyboard after idle time (in seconds)
# defaults write com.apple.BezelServices kDimTime -int 300
# sudo defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor "Keyboard Dim Time" -int 300

# Full Keyboard Access
# In windows and dialogs, press Tab to move keyboard focus between:
# 1 : Text boxes and lists only
# 3 : All controls
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Use F1, F2, etc. keys as standard function keys
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true

# Press Globe (🌐) key to:
# 0 : Do Nothing
# 1 : Show Emoji & Symbols
# 2 : Start Dictation
# 3 : Change Input Source
defaults write com.apple.HIToolbox AppleFnUsageType -int 0

# # Stop iTunes from responding to the keyboard media keys
# #launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null

###############################################################################
# Keyboard Shortcuts > Spotlight & Services
###############################################################################

# `defaults write ... -dict-add` writes bare values as strings, not the
# bool/int types these domains need, so the two sections below edit the
# plists directly via PlistBuddy instead. That bypasses cfprefsd — the
# daemon that normally owns reads/writes to these prefs and caches them in
# memory — so if it's running with a stale cache while we edit the file on
# disk, it can silently flush that stale cache back over our change later
# (even surviving a logout). Kill it immediately before and after these
# direct edits so there's no stale cache on either side of them.
killall cfprefsd 2>/dev/null || true

HOTKEYS_PLIST="${HOME}/Library/Preferences/com.apple.symbolichotkeys.plist"

# Disable a symbolic hotkey by id, recreating its `enabled`/`value` entry
# with the given standard-shortcut parameters (keycode, unused, modifiers).
disable_symbolic_hotkey() {
  local id="$1" p0="$2" p1="$3" p2="$4"
  # `|| true`: this whole script runs under `set -e` (bin/dotfiles), and
  # PlistBuddy exits non-zero when the key doesn't exist yet — the normal
  # case on a fresh install that's never touched this plist — which would
  # otherwise silently abort the rest of this file right here.
  /usr/libexec/PlistBuddy -c "Delete :AppleSymbolicHotKeys:${id}" "$HOTKEYS_PLIST" 2>/dev/null || true
  /usr/libexec/PlistBuddy \
    -c "Add :AppleSymbolicHotKeys:${id}:enabled bool false" \
    -c "Add :AppleSymbolicHotKeys:${id}:value:type string standard" \
    -c "Add :AppleSymbolicHotKeys:${id}:value:parameters array" \
    -c "Add :AppleSymbolicHotKeys:${id}:value:parameters:0 integer ${p0}" \
    -c "Add :AppleSymbolicHotKeys:${id}:value:parameters:1 integer ${p1}" \
    -c "Add :AppleSymbolicHotKeys:${id}:value:parameters:2 integer ${p2}" \
    "$HOTKEYS_PLIST"
}

# 64 : Show Spotlight search
disable_symbolic_hotkey 64 32 49 1048576
# 65 : Show Finder search window
disable_symbolic_hotkey 65 32 49 1572864

###############################################################################
# Keyboard Shortcuts > Services
###############################################################################

# A handful of Services are enabled with a keyboard shortcut out of the box
# on a fresh install (e.g. Text > "Open man Page in Terminal" on ⇧⌘M).
# Disable them via PlistBuddy for correct bool typing (see
# disable_symbolic_hotkey above for why `defaults write -dict-add` isn't
# used here).
PBS_PLIST="${HOME}/Library/Preferences/pbs.plist"

# Disable a Services-menu entry by its full "bundle - Menu Title - method"
# key. with_key_equivalent clears out that entry's factory shortcut too,
# for services that ship with one (e.g. the Chinese text converters).
disable_service() {
  local key="$1" with_key_equivalent="$2"
  # The service key itself contains spaces and dashes ("bundle - Menu
  # Title - method"), so it must be quoted as a single PlistBuddy path
  # component — otherwise PlistBuddy's own whitespace-splitting command
  # parser mangles it into several bogus arguments.
  # `|| true`: see disable_symbolic_hotkey above — set -e would otherwise
  # abort here on a fresh install where this key doesn't exist yet.
  /usr/libexec/PlistBuddy -c "Delete :NSServicesStatus:\"${key}\"" "$PBS_PLIST" 2>/dev/null || true
  /usr/libexec/PlistBuddy \
    -c "Add :NSServicesStatus:\"${key}\":enabled_context_menu bool false" \
    -c "Add :NSServicesStatus:\"${key}\":enabled_services_menu bool false" \
    -c "Add :NSServicesStatus:\"${key}\":presentation_modes:ContextMenu bool false" \
    -c "Add :NSServicesStatus:\"${key}\":presentation_modes:ServicesMenu bool false" \
    "$PBS_PLIST"
  if [ "$with_key_equivalent" = "true" ]; then
    /usr/libexec/PlistBuddy -c "Add :NSServicesStatus:\"${key}\":key_equivalent string" "$PBS_PLIST"
  fi
}

# Text > Open man Page in Terminal (⇧⌘M by default)
disable_service "com.apple.Terminal - Open man Page in Terminal - openManPage" false
# Text > Search man Page Index in Terminal (⇧⌘A by default)
disable_service "com.apple.Terminal - Search man Page Index in Terminal - searchManPages" false
# Text > Convert Text from Traditional to Simplified Chinese (^⌥⇧⌘C by default)
disable_service "com.apple.ChineseTextConverterService - Convert Text from Traditional to Simplified Chinese - convertTextToSimplifiedChinese" true
# Text > Convert Text from Simplified to Traditional Chinese (^⇧⌘C by default)
disable_service "com.apple.ChineseTextConverterService - Convert Text from Simplified to Traditional Chinese - convertTextToTraditionalChinese" true
# Files and Folders > Send to Fantastical (⇧⌘M by default)
disable_service "com.flexibits.fantastical2.mac - Send to Fantastical - sendToFantastical" false

# Force cfprefsd to drop any cache it accumulated during the direct edits
# above and re-read both plists fresh from disk.
killall cfprefsd 2>/dev/null || true

# Use smart quotes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# # Set Double and Single quotes
# defaults write NSGlobalDomain NSUserQuotesArray -array '"\""' '"\""' '"'\''"' '"'\''"'

# Use smart dashes
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic period substitution
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable automatic capitalization as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Correct spelling automatically
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Continuously check spelling in (most) text views
# defaults write NSGlobalDomain NSAllowContinuousSpellChecking -bool false

# # Disable blinking cursor
# # defaults write -g NSTextInsertionPointBlinkPeriodOn  -float 1000000
# # defaults write -g NSTextInsertionPointBlinkPeriodOff -float 1000
#
# # Prevent accidental Power button presses from sleeping system
  # defaults write com.apple.loginwindow PowerButtonSleepsSystem -bool false
#
# # Keyboard Shortcuts (these are case insensitive)
# # Modifier key legend:
# #   ^    ⌃  Control
# #   ~    ⌥  Option
# #   $    ⇧  Shift
# #   @    ⌘  Command
# #   \033    Nested Option Delimiter
# #   nil     No shortcut
# # Note: Some of the characters above (e.g. "$" and "~") are special characters
# # and may need to be escaped in Bash commands
# # http://support.apple.com/kb/HT1343
# # Note: When adding shortcuts for nested options, entries must begin with
# # the '\033' escape sequence, in addition to seperating the options.
# # (e.g. '\033Edit\033Find\033Find Next")
#
#
# # Dictation
# ###############################################################################
#
# # Enable Dictation
# defaults write com.apple.assistant.support "Dictation Enabled" -bool true
# defaults write com.apple.speech.recognition.AppleSpeechRecognition.prefs \
#   DictationIMMasterDictationEnabled -bool true
# defaults write com.apple.speech.recognition.AppleSpeechRecognition.prefs \ DictationIMIntroMessagePresented -bool true
#
# # Use Enhanced Dictation
# # Allows offline use and continuous dictation with live feedback
# if [ -d '/System/Library/Speech/Recognizers/SpeechRecognitionCoreLanguages/en_US.SpeechRecognition' ]; then
#   defaults write com.apple.speech.recognition.AppleSpeechRecognition.prefs \
#      DictationIMPresentedOfflineUpgradeSuggestion -bool true
#   defaults write com.apple.speech.recognition.AppleSpeechRecognition.prefs \
#     DictationIMSIFolderWasUpdated -bool true
#   defaults write com.apple.speech.recognition.AppleSpeechRecognition.prefs \
#     DictationIMUseOnlyOfflineDictation -bool true
# fi
