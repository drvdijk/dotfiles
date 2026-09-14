#!/usr/bin/env zsh

# /opt/homebrew is shared across accounts (see run_as_admin_if_needed in
# bin/lib.sh), and its writable directories (Cellar, bin, Caskroom, ...) are
# group-writable by `admin` only. This account is deliberately kept
# non-admin, so any brew subcommand that would write there fails outright
# (Homebrew's formula installer never auto-elevates with sudo, unlike Cask's
# /Applications fallback). Rather than remembering to prefix every write with
# `sudo -u grandmaster -H`, wrap `brew` itself: only the subcommands that
# actually need write access get delegated to an admin account, authenticated
# with *this* account's own sudo password - read-only ones (list, info,
# search, ...) run directly, unchanged, no elevation or extra password.
#
# Defaults to whichever admin user was last picked in `dotfiles install ...`
# (bin/lib.sh's run_as_admin_if_needed writes it to $DOTFILES/.admin-user,
# gitignored) so this doesn't need configuring separately. Override either
# way with: export DOTFILES_BREW_ADMIN_USER=eindbaas
brew() {
  local write_subcommands=(
    install reinstall uninstall remove rm upgrade
    tap untap unlink link pin unpin
    cleanup postinstall bundle services cask
    update
  )

  # Not a write subcommand (or no subcommand at all) - just run it.
  if (( $# == 0 )) || (( ! ${write_subcommands[(Ie)$1]} )); then
    command brew "$@"
    return
  fi

  # Already admin (e.g. this *is* the admin account, or admin group got
  # added directly) - nothing to delegate.
  if id -Gn "$USER" 2>/dev/null | tr ' ' '\n' | grep -qx admin; then
    command brew "$@"
    return
  fi

  local default_admin_user="grandmaster"
  [[ -r "$DOTFILES/.admin-user" ]] && default_admin_user="$(<"$DOTFILES/.admin-user")"
  local admin_user="${DOTFILES_BREW_ADMIN_USER:-$default_admin_user}"
  local brew_bin
  brew_bin="$(whence -p brew)"
  print -u2 "brew: delegating '$*' to $admin_user (this account isn't in the admin group)"
  sudo -u "$admin_user" -H "$brew_bin" "$@"
}
