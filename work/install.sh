#!/usr/bin/env bash

# Load libs
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/../bin" && pwd )"/lib.sh

# Link keys folder if exists
if [[ -e ~/Dropbox/sync/keys_loc && -d $(cat ~/Dropbox/sync/keys_loc) ]]; then
	mkdir -p ~/dev
	ln -sf "$(cat ~/Dropbox/sync/keys_loc)" ~/dev/keys;
fi

# Set up local resolver
sudo mkdir -p /etc/resolver
if [[ -e ~/dev/keys/resolver_local.conf ]]; then
	sudo cp ~/dev/keys/resolver_local.conf /etc/resolver/resolver_local.conf
fi

# Allow user to call sudo openfortivpn without password
sudo tee /private/etc/sudoers.d/openfortivpn > /dev/null <<EOF
$USER ALL = NOPASSWD: /opt/homebrew/bin/openfortivpn
$USER ALL = NOPASSWD: /usr/bin/killall openfortivpn
EOF

if [ -x "$(command -v asdf)" ]; then 
	asdf plugin add java
	asdf plugin add maven
	asdf plugin add tomcat
	asdf install java temurin-21.0.6+7.0.LTS
	asdf install maven 3.9.2
	asdf install tomcat 9.0.102
	asdf set java temurin-21.0.6+7.0.LTS
	asdf set maven 3.9.2
	asdf set tomcat 9.0.102
fi
