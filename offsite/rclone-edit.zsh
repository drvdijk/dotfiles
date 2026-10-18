#!/usr/bin/env zsh

# Edit the encrypted rclone config ($RCLONE_CONFIG) by hand: decrypt it to a
# private temp dir, open it in $EDITOR, re-encrypt it (password from
# $RCLONE_PASSWORD_COMMAND) and only then move it back over the original.
# Nothing is written back if any step fails, and the plaintext copy is
# always removed.
rclone-edit() {
  local tmp; tmp=$(mktemp -d)
  rclone config show > "$tmp/rclone.conf" &&
  ${=EDITOR:-vi} "$tmp/rclone.conf" &&
  RCLONE_CONFIG="$tmp/rclone.conf" rclone config encryption set &&
  mv "$tmp/rclone.conf" "$RCLONE_CONFIG"
  rm -rf "$tmp"
}
