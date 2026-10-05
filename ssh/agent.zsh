#!/usr/bin/env zsh

# Make 1Password the SSH agent for everything started from a shell (ssh-add,
# ssh-copy-id, ...), not only for ssh itself, which already gets there through
# IdentityAgent in ~/.ssh/config.
#
# Not when logged in over SSH: SSH_AUTH_SOCK may then be a forwarded agent.
# Not when the socket is missing either (1Password's agent is off), so the
# macOS agent stays in place as a fallback.
() {
  local sock="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
  [[ -z $SSH_CONNECTION && -S $sock ]] && export SSH_AUTH_SOCK=$sock
  return 0
}
