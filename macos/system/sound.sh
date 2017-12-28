# #!/usr/bin/env bash

###############################################################################
# Sound
###############################################################################

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# Play feedback when volume is changed
defaults write NSGlobalDomain com.apple.sound.beep.feedback -bool false
