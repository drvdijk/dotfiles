#!/usr/bin/env zsh

[[ -s "/opt/homebrew/opt/asdf/libexec/asdf.sh" ]] && source "/opt/homebrew/opt/asdf/libexec/asdf.sh"

export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

