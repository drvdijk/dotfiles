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
		# entries in it are handled separately below instead of here, since
		# they need to run under the original account regardless (see that
		# comment) - brew bundle will still attempt them here too, and
		# that's fine; a failure for just those entries isn't fatal to the
		# rest of the bundle.
		brew bundle --file=$(dirname ${BASH_SOURCE[0]})/Brewfile

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
