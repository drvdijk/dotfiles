#!/usr/bin/env bash
#
# asdf tool versions: plugins & versions from a tool-versions file, set as
# the defaults in ~/.tool-versions. asdf itself comes with the development
# topic's Brewfile. Per project, run `asdf-sync` in its directory instead.
#
#   dotfiles install asdf           asks for the file (default ~/dev/tool-versions)
#   dotfiles install asdf <file>
#

# Load libs
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/../bin" && pwd )"/lib.sh

tool_versions_file="${1:-}"
if [ -z "$tool_versions_file" ]; then
	bot "asdf tool versions"
	echo " - Where is your tool-versions file? (leave blank for ~/dev/tool-versions, see asdf/tool-versions.example)"
	read -e tool_versions_file
	tool_versions_file="${tool_versions_file:-$HOME/dev/tool-versions}"
fi

if [ -f "$tool_versions_file" ]; then
	"$DOTFILES_DIR/asdf/asdf-sync" --home "$tool_versions_file"
else
	warn "tool-versions file not found at $tool_versions_file, skipping"
fi
