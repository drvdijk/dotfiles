#!/usr/bin/env zsh

if [ -x "$(command -v starship)" ]; then
  export STARSHIP_CONFIG="$DOTFILES/starship/starship.toml"
  eval "$(starship init zsh)"
fi
