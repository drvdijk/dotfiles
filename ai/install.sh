#!/usr/bin/env bash
#
# homebrew and cask AI apps (coding agent sandboxes, Claude desktop, etc.)
#

# Load libs
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/../bin" && pwd )"/lib.sh

require_osx

install_brewfile ai "$(dirname "${BASH_SOURCE[0]}")/Brewfile" "$@"

# Agent skills: symlink this repo's personal skills into the tool-agnostic
# ~/.agents/skills/ merge point, then fan that out to the tool-specific
# dirs Claude/Gemini actually look in. Not a homebrew concern, so this runs
# unconditionally rather than inside install_brewfile's admin delegation
# above - and, like the prefs application in homebrew/install.sh, it's
# skipped during the delegated admin run itself so it always lands in the
# original (non-admin) account's home, not the admin delegate's.
if [ -z "$DOTFILES_ADMIN_PHASE" ]; then
	bot 'Installing agent skills'

	local overwrite_all=false backup_all=false skip_all=false

	mkdir -p "$HOME/.agents/skills"

	while IFS= read -r -d '' src
	do
		link_file "$src" "$HOME/.agents/skills/$(basename "$src")"
	done < <(find "$(dirname "${BASH_SOURCE[0]}")/skills" -maxdepth 1 -mindepth 1 -not -name '.gitkeep' -print0 2>/dev/null)

	mkdir -p "$HOME/.claude"
	mkdir -p "$HOME/.gemini"
	link_file "$HOME/.agents/skills" "$HOME/.claude/skills"
	link_file "$HOME/.agents/skills" "$HOME/.gemini/skills"

	ok 'agent skills installed'
fi
