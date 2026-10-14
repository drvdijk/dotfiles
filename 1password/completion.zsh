#!/usr/bin/env zsh

# 1Password CLI (op) autocompletion
if [ -x "$(command -v op)" ]; then
  eval "$(op completion zsh)"
  compdef _op op
fi
