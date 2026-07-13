#
# antidote
#

zsh_plugins="$DOTFILES/zsh/zsh_plugins.txt"
zsh_plugins_static="$DOTFILES/zsh/zsh_plugins.zsh"

if [[ ! -s "$zsh_plugins_static" || "$zsh_plugins" -nt "$zsh_plugins_static" ]]; then
  source "$(brew --prefix)/opt/antidote/share/antidote/antidote.zsh"
  antidote bundle <"$zsh_plugins" >"$zsh_plugins_static"
fi

source "$zsh_plugins_static"

# zsh-completions only extends fpath; compinit isn't called for us.
autoload -Uz compinit && compinit

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

#
# end antidote
#
