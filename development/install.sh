#!/usr/bin/env bash
#
# homebrew and cask DEVELOPMENT apps
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

	bot "installing tools via homebrew..."
	# Make sure we’re using the latest Homebrew
	action "update brew..."
	brew update
	ok "brew updated..."
	# Need to run brew upgrade at this point to make sure `brew list` works correctly...
	brew upgrade
	ok "brew upgraded..."

	## Accept xcode developer license
	#sudo xcodebuild -license accept

	# Install homebrew, cask, and mas stuff from brew file here
	brew bundle --file=$(dirname ${BASH_SOURCE[0]})/Brewfile

	# Remove outdated versions from the cellar
	brew cleanup

	# Post homebrew installations
	GCLOUD_SDK="$(brew --prefix)/Caskroom/gcloud-cli/latest/google-cloud-sdk"
	if [[ -f "$GCLOUD_SDK/path.bash.inc" ]]; then
		source "$GCLOUD_SDK/path.bash.inc"
		gcloud components install gke-gcloud-auth-plugin
	else
		warn "gcloud SDK not found at $GCLOUD_SDK, skipping gke-gcloud-auth-plugin install"
	fi
fi
