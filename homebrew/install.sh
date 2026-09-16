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

if run_as_admin_if_needed homebrew "$@"; then
	require_homebrew

	if [ "$#" -gt 0 ]; then
		# Install just the named Brewfile entries, skip the full-machine dance.
		brew update
		brew_install_from_file "$(dirname "${BASH_SOURCE[0]}")/Brewfile" "$@"
		brew cleanup
	else
		require_sudo
		offer_passwordless_installer

		# Install all available updates
		sudo softwareupdate -ia --verbose

		# Install Rosetta 2 if on M1 platform
		if [[ "$(uname -s)" == "Darwin" ]] && [[ "$(uname -p)" == "arm" ]]; then
			softwareupdate --install-rosetta --agree-to-license
		fi

		bot "installing tools via homebrew..."
		# Make sure we’re using the latest Homebrew
		action "update brew..."
		brew update
		ok "brew updated..."
		# Need to run brew upgrade at this point to make sure `brew list` works correctly...
		brew upgrade
		ok "brew upgraded..."

		# Install homebrew and cask stuff from the Brewfile. Mac App Store
		# entries are deliberately excluded here (see the mas section below,
		# after this admin-delegated block, for why) - a failed `mas install`
		# under the wrong account doesn't just fail quietly, it can disrupt
		# the shared App Store session state (storeaccountd) that the
		# correct, later attempt under the original account relies on,
		# turning an otherwise-silent install into one that needs the Apple
		# ID password re-entered.
		brewfile_no_mas="$(mktemp)"
		grep -v '^mas ' "$(dirname "${BASH_SOURCE[0]}")/Brewfile" > "$brewfile_no_mas"
		brew bundle --file="$brewfile_no_mas"
		rm -f "$brewfile_no_mas"

		# Add zsh to shells list
		if [[ $(cat /etc/shells | grep $(which zsh) | wc -c) -eq 0 ]]; then
		    echo $(which zsh) | sudo tee -a /etc/shells
		fi

		# Fix zsh audit errors
		# TODO compaudit is a zsh command, how to run from bash?
		# compaudit | xargs chmod g-w
		ok "Run the following command from zsh to fix zsh audit errors:"
		ok "compaudit | xargs chmod g-w"

		# Remove outdated versions from the cellar
		brew cleanup
	fi

	# 1Password's security-key (YubiKey) support only trusts the app bundle
	# when it's owned by root or by the account actually running 1Password -
	# never by some other account, which is exactly what grandmaster is from
	# the app's point of view. Homebrew Cask can't be told to install it that
	# way, so fix it up after the fact. This is a one-off, narrowly-scoped
	# exception: Homebrew Cask's own uninstall/reinstall logic assumes
	# whoever runs `brew remove`/`reinstall` owns the bundle being touched,
	# so `brew remove/reinstall 1password` run through this same admin
	# delegation will fail with permission errors from here on - to update,
	# either let 1Password's own built-in updater handle it, or temporarily
	# chown it back to grandmaster before reinstalling through brew.
	#
	# This also needs the calling terminal to hold the "App Management"
	# privacy permission (System Settings > Privacy & Security). macOS checks
	# that against the responsible GUI app in the process chain (Terminal,
	# iTerm, ...), not the effective uid - sudo grants real root here, but
	# doesn't bypass it - so without it this fails with a wall of
	# "Operation not permitted" errors on the app's contents that look like
	# a permissions bug but aren't.
	if [ -d /Applications/1Password.app ] && [ "$(stat -f '%Su' /Applications/1Password.app)" != root ]; then
		action "chown 1Password.app to root:wheel (needed for YubiKey support)..."
		if ! sudo chown -R root:wheel /Applications/1Password.app; then
			error "chown failed - your terminal app most likely needs the \"App Management\" privacy permission."
			warn "opening System Settings > Privacy & Security > App Management - enable it for this terminal app, then re-run this install."
			open "x-apple.systempreferences:com.apple.preference.security?Privacy_AppBundles" 2>/dev/null
		fi
	fi
fi

# Mac App Store installs go through the App Store's own daemon, tied to
# whichever account is actually signed into the App Store in the GUI - not
# to Unix admin permissions - and `su` doesn't carry a full GUI session
# anyway. So unlike casks/formulae above, these never delegate to an admin
# user, and (like prefs below) are skipped in the delegated admin run
# itself. Only covers the full install (no args) for now - a purely
# mas-named install (e.g. `dotfiles install homebrew Fantastical`) still
# goes through the admin path above today and would need the same treatment
# if that ever comes up.
if [ -z "$DOTFILES_ADMIN_PHASE" ] && [ "$#" -eq 0 ]; then
	require_homebrew
	brew install mas

	# Wait until app store sign-in is done
	# mas account is broken: https://github.com/mas-cli/mas/issues/417
	read -p "Make sure you're logged into the App Store!" -r
	#until mas account > /dev/null 2>&1; do
	#  echo "Please sign in to the Mac App store manually..."
	#  sleep 3
	#done

	mas_names=()
	while IFS= read -r name; do
		mas_names+=("$name")
	done < <(grep -oE '^mas "[^"]+"' "$(dirname "${BASH_SOURCE[0]}")/Brewfile" | sed -E 's/^mas "(.*)"$/\1/')
	if [ "${#mas_names[@]}" -gt 0 ]; then
		brew_install_from_file "$(dirname "${BASH_SOURCE[0]}")/Brewfile" "${mas_names[@]}"
	fi
fi

# Apply prefs for the third-party apps installed above. Skipped when this IS
# the delegated admin run (see run_as_admin_if_needed in bin/lib.sh) - the
# original, non-admin invocation applies them once control returns to it
# instead, so they always land in the right account's home.
if [ -z "$DOTFILES_ADMIN_PHASE" ]; then
	if [ "$#" -gt 0 ]; then
		if select_prefs "$@"; then
			get_open_affected_apps
			source_prefs
		fi
	else
		get_open_affected_apps
		source_prefs
	fi
fi
