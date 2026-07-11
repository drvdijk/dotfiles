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
    if [ -e "$dst" ]; then
      warn "skipping $dst: exists and is not a symlink"
    else
      ln -s "$src" "$dst"
    fi
  done
  ok "work agent skills linked from $work_agents_dir"
fi

if [ -x "$(command -v asdf)" ]; then
	asdf plugin list | grep -q java   || asdf plugin add java
	asdf plugin list | grep -q maven  || asdf plugin add maven
	asdf plugin list | grep -q tomcat || asdf plugin add tomcat
	asdf plugin list | grep -q nodejs || asdf plugin add nodejs
	bot "asdf tool versions"
	echo " - Where is your tool-versions file? (leave blank for ~/dev/tool-versions)"
	read -e tool_versions_file
	tool_versions_file="${tool_versions_file:-$HOME/dev/tool-versions}"
	if [[ -f "$tool_versions_file" ]]; then
		while IFS=' ' read -r tool version; do
			[[ -z "$tool" || "$tool" == \#* ]] && continue
			asdf install "$tool" "$version"
			asdf set --home "$tool" "$version"
		done < "$tool_versions_file"
		ok "asdf tools installed from $tool_versions_file"
	else
		warn "tool-versions file not found at $tool_versions_file, skipping"
	fi
fi
