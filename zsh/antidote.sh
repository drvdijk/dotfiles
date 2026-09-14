#
# antidote
#

zsh_plugins="$DOTFILES/zsh/zsh_plugins.txt"
zsh_plugins_static="$DOTFILES/zsh/zsh_plugins.zsh"

if [[ ! -s "$zsh_plugins_static" || "$zsh_plugins" -nt "$zsh_plugins_static" ]]; then
  if command -v brew >/dev/null 2>&1 && [[ -s "$(brew --prefix)/opt/antidote/share/antidote/antidote.zsh" ]]; then
    source "$(brew --prefix)/opt/antidote/share/antidote/antidote.zsh"
    antidote bundle <"$zsh_plugins" >"$zsh_plugins_static"
  else
    print -u2 "antidote: homebrew/antidote not installed yet, skipping plugin bundle (run \`dotfiles install homebrew\`)"
  fi
fi

[[ -s "$zsh_plugins_static" ]] && source "$zsh_plugins_static"

# zsh-completions only extends fpath; compinit isn't called for us.
#
# -u ("blindly trust") skips compinit's ownership/writability check on fpath
# entries entirely, instead of prompting on every new shell. Homebrew's own
# completions under $(brew --prefix)/share/zsh get flagged otherwise: brew
# installs can run under different admin accounts (see run_as_admin_if_needed
# in bin/lib.sh - dotfiles install homebrew/personal/development can end up
# running as whichever admin user was picked, e.g. grandmaster), so those
# files legitimately end up owned by someone other than this account or
# root. -i (silently exclude instead of trust) was the alternative, but that
# would just make brew/git/rclone/starship completions quietly stop working
# instead of fixing anything.
autoload -Uz compinit && compinit -u

if (( $+widgets[history-substring-search-up] )); then
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
fi

#
# end antidote
#
