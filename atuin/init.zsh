#!/usr/bin/env zsh

# Atuin is on Ctrl-g; hstr stays on Ctrl-t (see hstr/init.zsh) and Ctrl-r
# keeps zsh's own incremental search.
# --disable-up-arrow leaves the up arrow to zsh-history-substring-search
# (bound in zsh/antidote.sh).
if [ -x "$(command -v atuin)" ]; then
  eval "$(atuin init zsh --disable-up-arrow --disable-ctrl-r)"
  bindkey '^g' atuin-search
fi
