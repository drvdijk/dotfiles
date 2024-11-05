#!/usr/bin/env zsh

# HSTR configuration - add this to ~/.zshrc
alias hh=hstr                    # hh to be alias for hstr
#already done in ~/.dotfiles/zsh/history.zsh
#setopt histignorespace           # skip cmds w/ leading space from history
#export HSTR_CONFIG=hicolor       # get more colors
export HSTR_CONFIG=hicolor,raw-history-view,regexp-matching,help-on-opposite-side
bindkey -s "\C-t" "\C-a hstr -- \C-j"     # bind hstr to Ctrl-r (for Vi mode check doc)
export HSTR_TIOCSTI=y
