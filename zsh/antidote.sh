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
autoload -Uz compinit && compinit

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

#
# end antidote
#
