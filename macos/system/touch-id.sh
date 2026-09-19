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
#
# The file may already hold other rules, notably pam_reattach.so, which makes
# Touch ID work inside tmux/screen and has to be listed *before* pam_tid.so.
# So this only ever appends the one missing line (`tee -a` also creates the
# file when it doesn't exist yet), and never rewrites what's already there.
#
# The paths can be overridden purely so this can be tested without touching
# /etc.
SUDO_LOCAL="${SUDO_LOCAL:-/etc/pam.d/sudo_local}"
PAM_SUDO="${PAM_SUDO:-/etc/pam.d/sudo}"
TID_RULE="auth       sufficient     pam_tid.so"

running "Enabling Touch ID for sudo"
if grep -qE '^auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so' "$SUDO_LOCAL" 2>/dev/null; then
    ok
elif ! grep -qE '^[^#]*sudo_local' "$PAM_SUDO" 2>/dev/null; then
    # Before Sonoma nothing reads sudo_local, so writing it would silently do
    # nothing. Editing /etc/pam.d/sudo directly is exactly what this avoids.
    warn "$PAM_SUDO doesn't include sudo_local (needs macOS Sonoma or later), not enabling Touch ID for sudo"
else
    # If the last line of an existing file has no trailing newline, end it
    # first so the new rule doesn't get glued onto it.
    [ ! -s "$SUDO_LOCAL" ] || [ -z "$(tail -c1 "$SUDO_LOCAL")" ] || echo | sudo tee -a "$SUDO_LOCAL" >/dev/null
    echo "$TID_RULE" | sudo tee -a "$SUDO_LOCAL" >/dev/null
    # sudo tee inherits our umask, so a strict one (e.g. 077) would leave the
    # file unreadable to the plain `grep` above, and every run would then
    # append the rule again. Only adds read permission; a no-op on 644.
    sudo chmod a+r "$SUDO_LOCAL"
    ok
fi
