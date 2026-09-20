#!/usr/bin/env bash
#
# homebrew, cask, and mas apps
#

# Load libs
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/../bin" && pwd )"/lib.sh

require_osx

# Prefs for third-party apps installed from this Brewfile (see
# bin/lib.sh for set_prefs/source_prefs/etc.) - always applied under this
# account, even when the installs below run as a different admin user.
PREF_FILES=()
AFFECTED_APPS=()
PREF_APPS=()
PREFS_DIR="$(dirname "${BASH_SOURCE[0]}")/apps"
set_prefs google-chrome "Google Chrome"
set_prefs iterm "iTerm"
set_prefs mountain-duck "Mountain Duck"
set_prefs sublime-text "Sublime Text"

# OS-level prep for the full-machine install. Unlike the Brewfile install
# below, softwareupdate/Rosetta only need root via sudo, not admin-group
# membership (that constraint is specific to Homebrew Cask's un-sudo'd
# writes into /Applications - see run_as_admin_if_needed in bin/lib.sh), so
# this runs directly under this account instead of piggybacking on
# install_brewfile's admin delegation. Skipped for named-entry installs
# (matches the original single-entry fast path) and during
# install_brewfile's own delegated re-invocation of this whole script
# below (DOTFILES_ADMIN_PHASE) - without that second guard this would run
# twice, once here and once again as the admin user.
if [ "$#" -eq 0 ] && [ -z "$DOTFILES_ADMIN_PHASE" ]; then
	require_sudo

	# Install all available updates
	sudo softwareupdate -ia --verbose

	# Install Rosetta 2 if on M1 platform
	if [[ "$(uname -s)" == "Darwin" ]] && [[ "$(uname -p)" == "arm" ]]; then
		softwareupdate --install-rosetta --agree-to-license
	fi
fi

install_brewfile homebrew "$(dirname "${BASH_SOURCE[0]}")/Brewfile" "$@"

# Add zsh (installed by the Brewfile above) to the shells list. Same
# full-install/DOTFILES_ADMIN_PHASE gating as the OS-level prep above, and
# needs require_homebrew re-run first: when the Brewfile install just above
# delegated to the admin user, zsh landed in the shared Homebrew prefix
# from a *different* process, so this process's PATH may not have picked
# it up yet (see require_homebrew's own comment on this).
if [ "$#" -eq 0 ] && [ -z "$DOTFILES_ADMIN_PHASE" ]; then
	require_homebrew
	if [[ $(cat /etc/shells | grep $(which zsh) | wc -c) -eq 0 ]]; then
	    echo $(which zsh) | sudo tee -a /etc/shells
	fi
fi

# 1Password's security-key (YubiKey) support only trusts the app bundle
# when it's owned by root or by the account actually running 1Password -
# never by some other account, which is what an admin delegate would be
# from the app's point of view. Homebrew Cask can't be told to install it
# that way, so fix it up after the fact, directly under this account (only
# needs root via sudo, same reasoning as the OS-level prep above). This is
# a one-off, narrowly-scoped exception: Homebrew Cask's own uninstall/
# reinstall logic assumes whoever runs `brew remove`/`reinstall` owns the
# bundle being touched, so `brew remove/reinstall 1password` run through
# install_brewfile's admin delegation will fail with permission errors
# from here on - to update, either let 1Password's own built-in updater
# handle it, or temporarily chown it back to the admin user before
# reinstalling through brew.
#
# This also needs the calling terminal to hold the "App Management"
# privacy permission (System Settings > Privacy & Security). macOS checks
# that against the responsible GUI app in the process chain (Terminal,
# iTerm, ...), not the effective uid - sudo grants real root here, but
# doesn't bypass it - so without it this fails with a wall of
# "Operation not permitted" errors on the app's contents that look like
# a permissions bug but aren't.
if [ -z "$DOTFILES_ADMIN_PHASE" ] && [ -d /Applications/1Password.app ] && [ "$(stat -f '%Su' /Applications/1Password.app)" != root ]; then
	action "chown 1Password.app to root:wheel (needed for YubiKey support)..."
	if ! sudo chown -R root:wheel /Applications/1Password.app; then
		error "chown failed - your terminal app most likely needs the \"App Management\" privacy permission."
		warn "opening System Settings > Privacy & Security > App Management - enable it for this terminal app, then re-run this install."
		open "x-apple.systempreferences:com.apple.preference.security?Privacy_AppBundles" 2>/dev/null
	fi
fi

# Mountain Duck also refuses to work when its app bundle is left owned by
# the admin delegate (grandmaster:admin) from Homebrew Cask's install -
# same root cause as the 1Password case above, so it gets the same
# root:wheel fixup here.
if [ -z "$DOTFILES_ADMIN_PHASE" ] && [ -d "/Applications/Mountain Duck.app" ] && [ "$(stat -f '%Su' "/Applications/Mountain Duck.app")" != root ]; then
	action "chown Mountain Duck.app to root:wheel..."
	if ! sudo chown -R root:wheel "/Applications/Mountain Duck.app"; then
		error "chown failed - your terminal app most likely needs the \"App Management\" privacy permission."
		warn "opening System Settings > Privacy & Security > App Management - enable it for this terminal app, then re-run this install."
		open "x-apple.systempreferences:com.apple.preference.security?Privacy_AppBundles" 2>/dev/null
	fi
fi

# Apply prefs for the third-party apps installed above. Skipped when this IS
# the delegated admin run (see run_as_admin_if_needed in bin/lib.sh) - the
# original, non-admin invocation applies them once control returns to it
# instead, so they always land in the right account's home.
if [ -z "$DOTFILES_ADMIN_PHASE" ]; then
	if [ "$#" -gt 0 ]; then
		if select_prefs -q "$@"; then
			get_open_affected_apps
			source_prefs
		fi
	else
		get_open_affected_apps
		source_prefs
	fi
fi
