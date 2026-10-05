#!/usr/bin/env zsh

# Atuin takes Ctrl-r; hstr stays on Ctrl-t (see hstr/init.zsh).
# --disable-up-arrow leaves the up arrow to zsh-history-substring-search
# (bound in zsh/antidote.sh).
if [ -x "$(command -v atuin)" ]; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi
