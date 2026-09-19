#!/usr/bin/env bash

# Load libs
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../bin" && pwd )"/lib.sh

###############################################################################
# Touch ID
###############################################################################

# Allow Touch ID to authenticate sudo. sudo_local (macOS Sonoma+) is included
# by /etc/pam.d/sudo and, unlike editing that file directly, survives macOS
# updates. iTerm2 offers to write this same file; doing it here means it also
# works on a fresh machine before any terminal asks.
SUDO_LOCAL=/etc/pam.d/sudo_local

running "Enabling Touch ID for sudo"
if grep -qE '^auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so' "$SUDO_LOCAL" 2>/dev/null; then
    ok
else
    echo "auth       sufficient     pam_tid.so" | sudo tee "$SUDO_LOCAL" >/dev/null
    sudo chmod 444 "$SUDO_LOCAL"
    ok
fi
