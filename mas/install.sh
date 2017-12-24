#!/usr/bin/env bash
#
# mas
#
# This installs some GUI apps on OS X from the Mac App Store through the mas command line utility

# Load libs
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/../bin/lib.sh

# Check OS X & sudo
require_osx
require_sudo

bot "Running software updates"
sudo softwareupdate -i -a

# Install mas
bot "Installing mas (Mac App Store command line utility)"
require_brew mas

# Apps!
mas install 511324989 #JSON Accelerator (1.1.1)
mas install 411643860 #DaisyDisk (4.4)
#mas install 803453959 #Slack (3.0.0) # maybe Franz is good enough
mas install 442160987 #Flycut (1.5)
mas install 410628904 #Wunderlist (3.4.7)
mas install 918858936 #Airmail 3 (3.5.4)

bot "All done with app store apps!"

