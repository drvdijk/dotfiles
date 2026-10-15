#!/usr/bin/env bash
#
# homebrew and cask AI apps (coding agent sandboxes, Claude desktop, etc.)
#

# Load libs
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/../bin" && pwd )"/lib.sh

require_osx

install_brewfile ai "$(dirname "${BASH_SOURCE[0]}")/Brewfile" "$@"

# Agent skills: symlink this repo's personal skills, plus those of any other
# skills repos (e.g. a work or client one), into the tool-agnostic
# ~/.agents/skills/ merge point, then fan that out to the tool-specific
# dirs Claude/Gemini actually look in. Not a homebrew concern, so this runs
# unconditionally rather than inside install_brewfile's admin delegation
# above - and, like the prefs application in homebrew/install.sh, it's
# skipped during the delegated admin run itself so it always lands in the
# original (non-admin) account's home, not the admin delegate's.
if [ -z "$DOTFILES_ADMIN_PHASE" ]; then
	# The other skills repos are machine-specific, so they're asked once and
	# remembered in a gitignored file (like .admin-user). Edit or delete
	# that file to change them.
	skill_sources_file="$DOTFILES_DIR/ai/.skill-sources"
	if [ ! -f "$skill_sources_file" ]; then
		bot 'Other agent skills repos'
		: > "$skill_sources_file"
		while true; do
			echo ' - Where is another skills repo cloned (its skills/ folder, or the folder holding the skills)? (leave blank when done)'
			read -e skill_source
			[ -z "$skill_source" ] && break
			skill_source="${skill_source/#\~/$HOME}"
			if [ -d "$skill_source" ]; then
				(cd "$skill_source" && pwd) >> "$skill_sources_file"
			else
				warn "$skill_source is not a directory, not added"
			fi
		done
		ok "skills repos remembered in $skill_sources_file"
	fi

	bot 'Installing agent skills'

	local overwrite_all=false backup_all=false skip_all=false

	mkdir -p "$HOME/.agents/skills"

	# This repo's skills first, then those of each remembered skills repo.
	# Name clashes go through link_file's skip/overwrite/backup prompt.
	skill_dirs=("$(dirname "${BASH_SOURCE[0]}")/skills")
	while IFS= read -r skill_source <&3 || [ -n "$skill_source" ]; do
		[ -z "$skill_source" ] && continue
		if [ -d "$skill_source/skills" ]; then
			skill_dirs+=("$skill_source/skills")
		elif [ -d "$skill_source" ]; then
			skill_dirs+=("$skill_source")
		else
			warn "skills repo $skill_source not found (not cloned on this machine?), skipping"
		fi
	done 3< "$skill_sources_file"

	for skill_dir in "${skill_dirs[@]}"; do
		while IFS= read -r -d '' src
		do
			link_file "$src" "$HOME/.agents/skills/$(basename "$src")"
		done < <(find "$skill_dir" -maxdepth 1 -mindepth 1 -not -name '.*' -print0 2>/dev/null)
	done

	# Skills removed from their repo leave a dangling symlink behind
	for dst in "$HOME"/.agents/skills/*; do
		if [ -L "$dst" ] && [ ! -e "$dst" ]; then
			rm "$dst"
			ok "removed $dst (its skill no longer exists)"
		fi
	done

	mkdir -p "$HOME/.claude"
	mkdir -p "$HOME/.gemini"
	link_file "$HOME/.agents/skills" "$HOME/.claude/skills"
	link_file "$HOME/.agents/skills" "$HOME/.gemini/skills"

	ok 'agent skills installed'
fi
