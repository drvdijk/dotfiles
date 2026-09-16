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
    cleanup postinstall services cask
    update
  )

  # `bundle`'s own subcommand decides whether it writes: bare `bundle`/
  # `bundle install` and `bundle cleanup` can install/uninstall, but `dump`,
  # `check`, `list`, and `exec` only read - no reason to delegate those.
  local is_write_bundle=0
  [[ $1 == bundle && ( $2 == install || $2 == cleanup || -z $2 || $2 == -* ) ]] && is_write_bundle=1

  # Not a write subcommand (or no subcommand at all) - just run it.
  if (( $# == 0 )) || { (( ! ${write_subcommands[(Ie)$1]} )) && (( ! is_write_bundle )); }; then
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

  # $PWD carries over unchanged, but macOS locks down Desktop/Documents/
  # Downloads (and possibly other dirs) to mode 700 by default, so
  # $admin_user often can't even traverse into it - getcwd() then fails
  # outright ("$PWD must be set to run brew") before brew gets to run at
  # all. Sidestep that by always running from /tmp (world-traversable)
  # instead of wherever this shell happens to be: no brew subcommand above
  # cares about cwd, except `bundle` with an implicit ./Brewfile - pass
  # `--file` explicitly for that.
  sudo -u "$admin_user" -H sh -c 'cd /tmp && exec "$@"' -- "$brew_bin" "$@"

  # 1Password's YubiKey/security-key support only trusts its app bundle when
  # it's owned by root (see homebrew/install.sh for the full story) - any
  # brew-driven install/reinstall/upgrade above, even a bare `brew upgrade`
  # that touches it incidentally without naming it, resets that back to
  # $admin_user ownership. Fix it up here too, not just in `dotfiles
  # install`, since this wrapper is the everyday path apps actually get
  # updated through.
  if [[ -d /Applications/1Password.app ]] && [[ "$(stat -f '%Su' /Applications/1Password.app)" != root ]]; then
    print -u2 "brew: chown'ing 1Password.app to root:wheel (needed for YubiKey support)..."
    if ! sudo chown -R root:wheel /Applications/1Password.app; then
      print -u2 "brew: chown failed - this terminal likely needs the \"App Management\" privacy permission (System Settings > Privacy & Security)."
    fi
  fi
}
