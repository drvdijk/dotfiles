#!/usr/bin/env bash

# Load libs
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/../bin" && pwd )"/lib.sh

# Link keys folder
bot "Work keys"
echo " - Where is your keys folder? (leave blank to skip)"
read -e keys_dir
if [[ -n "$keys_dir" && -d "$keys_dir" ]]; then
	mkdir -p ~/dev
	ln -sf "$keys_dir" ~/dev/keys
	ok "keys linked from $keys_dir"
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

# Link work agent skills into ~/.agents/skills/ (the tool-agnostic merge point)
bot "Work agent skills"
echo " - Where is your work agents repo cloned? (leave blank to skip)"
read -e work_agents_dir
if [[ -n "$work_agents_dir" && -d "$work_agents_dir/skills" ]]; then
  mkdir -p ~/.agents/skills
  for src in "$work_agents_dir"/skills/*; do
    [ -e "$src" ] || continue
    dst="$HOME/.agents/skills/$(basename "$src")"
    [ -L "$dst" ] && rm "$dst"
    ln -s "$src" "$dst"
  done
  ok "work agent skills linked from $work_agents_dir"
fi

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
