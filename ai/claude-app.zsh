#!/usr/bin/env zsh

# Profiles for the Claude desktop app. A profile is a separate Electron
# user-data-dir, "~/Library/Application Support/Claude<name>". The app's own
# default dir ("Claude", which is what Spotlight / the Dock start) can be made
# a symlink to one of them, so a plain launch opens that profile.
#
# Not called `claude`: that's the Claude Code CLI. See `claude-app --help`.

_claude_app_bin=/Applications/Claude.app/Contents/MacOS/Claude
_claude_app_support="$HOME/Library/Application Support"
# This file, for the --make-app launchers to source
_claude_app_script=${${(%):-%x}:A}

# Resolved user-data-dirs of the running Claude main processes (one per line);
# those started without --user-data-dir use the default dir.
_claude_app_running_dirs() {
  local args dir
  ps -axo args= | while IFS= read -r args; do
    [[ $args == "$_claude_app_bin" || $args == "$_claude_app_bin "* ]] || continue
    if [[ $args == *--user-data-dir=* ]]; then
      # Path may contain spaces; it runs up to the next " --" flag, if any
      dir=${${args#*--user-data-dir=}%% --*}
    else
      dir="$_claude_app_support/Claude"
    fi
    print -r -- ${dir:A}
  done
}

# PID of the main process using the given (resolved) user-data-dir, if any
_claude_app_pid_for() {
  local pid args dir
  ps -axo pid=,args= | while read -r pid args; do
    [[ $args == "$_claude_app_bin" || $args == "$_claude_app_bin "* ]] || continue
    if [[ $args == *--user-data-dir=* ]]; then
      dir=${${args#*--user-data-dir=}%% --*}
    else
      dir="$_claude_app_support/Claude"
    fi
    [[ ${dir:A} == $1 ]] && { print $pid; return 0 }
  done
  return 1
}

claude-app() {
  setopt localoptions extendedglob
  local default="$_claude_app_support/Claude"

  # The name ends up in a path, and for --make-app in a shell command
  local name=${${1:#-*}:-$2}
  if [[ -n $name && $name != [[:alnum:]_.-]## ]]; then
    echo "claude-app: invalid profile name $name (use letters, digits, _ . -)" >&2; return 1
  fi
  # APFS is case-insensitive, so `psg` opens ClaudePSG just fine. Use the
  # on-disk spelling though: the running-instance checks compare paths as
  # strings, and links/launchers should get the real name.
  if [[ -n $name ]]; then
    local matches=("$_claude_app_support"/Claude(#i)${name}(N/:t))
    (( $#matches && ! ${matches[(Ie)Claude$name]} )) && name=${matches[1]#Claude}
  fi

  case $1 in
    ''|-h|--help)
      cat <<'EOF'
usage: claude-app <name>            open profile Claude<name> (created when new)
       claude-app --list            list profiles, marking running ones and the default
       claude-app --default <name>  point the default dir (what Spotlight starts) at
                                    Claude<name>; the default instance must not be running
       claude-app --make-app <name> create ~/Applications/Claude <name>.app, a launcher
                                    for the profile that Spotlight finds
EOF
      ;;

    --list)
      local running=("${(@f)$(_claude_app_running_dirs)}") dir marks
      for dir in "$_claude_app_support"/Claude?*~*.backup-*(N/); do
        name=${${dir:t}#Claude}
        marks=()
        [[ -L $default && ${default:A} == ${dir:A} ]] && marks+=default
        (( ${running[(Ie)${dir:A}]} )) && marks+=running
        print -r -- "$name${marks:+ (${(j:, :)marks})}"
      done
      ;;

    --default)
      local target="$_claude_app_support/Claude$name"
      if [[ -z $name ]]; then
        echo "usage: claude-app --default <name>" >&2; return 1
      fi
      if [[ ! -d $target || -L $target ]]; then
        echo "no profile dir $target" >&2; return 1
      fi
      # A running default instance resolved its paths through the old link
      # target; swapping it underneath would mix two profiles' data.
      if (( ${${(@f)"$(_claude_app_running_dirs)"}[(Ie)${default:A}]} )); then
        echo "Claude is running on the default profile, quit it first" >&2; return 1
      fi
      if [[ -e $default && ! -L $default ]]; then
        local backup="$default.backup-$(date +%Y%m%d-%H%M%S)"
        read -q "?$default is a real dir, move it to ${backup:t} and continue? [y/N] " || { echo; return 1 }
        echo
        mv "$default" "$backup" || return 1
      fi
      # Relative link, so it survives a moved/renamed home dir
      ln -sfn "Claude$name" "$default" && echo "default profile is now Claude$name"
      ;;

    --make-app)
      if [[ -z $name ]]; then
        echo "usage: claude-app --make-app <name>" >&2; return 1
      fi
      local app="$HOME/Applications/Claude $name.app" icon
      mkdir -p "$HOME/Applications" && rm -rf "$app" || return 1
      # An AppleScript applet that runs this function, so it gets the same
      # bring-to-front-when-already-open behaviour. It sources this file by
      # its current path: rerun --make-app if the dotfiles move.
      osacompile -o "$app" -e "do shell script \"/bin/zsh -c \" & quoted form of \"source ${(qq)_claude_app_script} && claude-app $name\"" || return 1
      # Claude's icon. Current osacompile applets carry their script icon in an
      # asset catalog (Assets.car + CFBundleIconName), which takes precedence
      # over applet.icns, so drop that and use whichever form Claude ships.
      local src=/Applications/Claude.app/Contents plist="$app/Contents/Info.plist" res="$app/Contents/Resources"
      rm -f "$res/Assets.car"
      plutil -remove CFBundleIconName "$plist" 2>/dev/null
      icon=$(defaults read "$src/Info" CFBundleIconName 2>/dev/null)
      if [[ -n $icon && -f $src/Resources/Assets.car ]]; then
        cp "$src/Resources/Assets.car" "$res/" && plutil -replace CFBundleIconName -string "$icon" "$plist"
      fi
      icon=$(defaults read "$src/Info" CFBundleIconFile 2>/dev/null)
      [[ -n $icon ]] && cp "$src/Resources/${icon%.icns}.icns" "$res/applet.icns"
      # No Dock icon for the (short-lived) applet itself
      plutil -replace LSUIElement -bool true "$plist"
      # Editing the bundle broke osacompile's ad-hoc signature
      codesign --force --sign - "$app" 2>/dev/null
      touch "$app"
      # Register with Launch Services and have Spotlight index it now, rather
      # than waiting for the next background scan to notice the new bundle
      /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$app" 2>/dev/null
      mdimport -i "$app" 2>/dev/null
      echo "created $app"
      ;;

    -*)
      echo "claude-app: unknown option $1, see claude-app --help" >&2; return 1
      ;;

    *)
      local dir="$_claude_app_support/Claude$name" pid
      [[ -d $dir ]] || echo "new profile: $dir"
      # Already open (directly, or as the default)? Bring that instance to the
      # front instead of starting a second one on the same dir.
      if pid=$(_claude_app_pid_for ${dir:A}); then
        osascript -e "tell application \"System Events\" to set frontmost of (first process whose unix id is $pid) to true" >/dev/null
      else
        open -n -a Claude --args --user-data-dir="$dir"
      fi
      ;;
  esac
}
