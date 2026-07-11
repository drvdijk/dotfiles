#!/usr/bin/env bash
#
# homebrew, cask, and mas apps
#

# Load libs
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/../bin" && pwd )"/lib.sh

require_osx
require_homebrew

if [ "$#" -gt 0 ]; then
	# Install just the named Brewfile entries, skip the full-machine dance.
	brew update
	brew_install_from_file "$(dirname "${BASH_SOURCE[0]}")/Brewfile" "$@"
	brew cleanup
else
	require_sudo

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

	# Make sure mas is installed
	brew install mas

	# Wait until app store sign-in is done
	# mas account is broken: https://github.com/mas-cli/mas/issues/417
	read -p "Make sure you're logged into the App Store!" -r
	#until mas account > /dev/null 2>&1; do
	#  echo "Please sign in to the Mac App store manually..."
	#  sleep 3
	#done

	# Install homebrew, cask, and mas stuff from brew file here
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
