#!/usr/bin/env bash

###############################################################################
# Mountain Duck
###############################################################################

# -L as well as -e: a symlink whose target isn't mounted yet is dangling, so
# -e alone would call it missing and `ln -s` onto it would nest a new link
# inside the (resolved) target instead of doing nothing.
if [ ! -e "$HOME/Dropbox" ] && [ ! -L "$HOME/Dropbox" ]; then
  ln -s "$HOME/Library/Application Support/Mountain Duck/Volumes.noindex/Dropbox.localized" "$HOME/Dropbox"
fi