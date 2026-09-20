#!/usr/bin/env bash

# Get dotfiles dir (so run this script from anywhere)
export DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"

# Exit immediately if anything exits with a non-zero status.
set -e

###
# some bash library helpers
# @author Adam Eivy
# https://github.com/atomantic/dotfiles
###

# Colors
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"34;01m"
COL_MAGENTA=$ESC_SEQ"35;01m"
COL_CYAN=$ESC_SEQ"36;01m"

function ok() {
    echo -e "$COL_GREEN[ok]$COL_RESET "$1
}

function bot() {
    echo -e "\n$COL_GREEN\[._.]/$COL_RESET - "$1
}

function running() {
    echo -en "$COL_YELLOW ⇒ $COL_RESET"$1": "
}

function action() {
    echo -e "\n$COL_YELLOW[action]:$COL_RESET\n ⇒ $1..."
}

function warn() {
    echo -e "$COL_YELLOW[warning]$COL_RESET "$1
}

function error() {
    echo -e "$COL_RED[error]$COL_RESET "$1
}


function require_sudo() {
    [ "$(sudo -n true 2>&1)" != "" ] && bot "I need you to enter your sudo password so I can install some things:"
    # Ask for the administrator password upfront
    sudo -v
    # Keep-alive: update existing `sudo` time stamp until the script has finished.
    # Runs with `set +e` because this file sets `set -e` above, and that would
    # otherwise be inherited by this backgrounded subshell: the first time
    # `sudo -n true` fails for any reason, errexit would kill the whole loop
    # silently, the ticket would then expire on its normal timeout, and every
    # sudo-requiring step after that would prompt again for the rest of the run.
    #
    # Note this only keeps *this shell's own* sudo calls (e.g. `softwareupdate`
    # below) from re-prompting. It can't help `brew install --cask` pkg
    # installers: Homebrew pipes their stdin/stdout instead of connecting them
    # to the real terminal, so `sudo` can't see this tty's cached ticket at all
    # and always re-authenticates. See offer_passwordless_installer() for that.
    ( set +e; while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done ) 2>/dev/null &
}

# Homebrew casks fall back to `sudo cp`/`sudo chmod` whenever their target
# (typically /Applications) isn't already writable by the current user - which
# it isn't for a deliberately non-admin account, even one with full sudo
# rights, since admin-group membership (not sudo) is what makes /Applications
# group-writable. Rather than grant this account any standing permission (ACL,
# admin-group membership, broad sudoers rules) to work around that, delegate
# just the package-installing work to a genuine admin user via `su`
# (authenticating with *that* user's own password), while anything the caller
# does *after* this returns - e.g. applying per-user prefs - stays under the
# original account, since that's inherently tied to a specific user's home
# and should never silently end up targeting the admin account instead.
#
# Use it to guard only the actual install work in a topic's install.sh:
#
#   if run_as_admin_if_needed homebrew "$@"; then
#       ... brew update / brew bundle / etc ...
#   fi
#   ... anything per-user, e.g. source_prefs, unconditionally after ...
#
# Returns 0 (run the install work yourself) if this account is already in
# `admin`, or if this *is* the delegated admin run (DOTFILES_ADMIN_PHASE is
# how it tells the two apart). Returns 1 (skip it, it already happened under
# the admin account) after a delegation completes.
function run_as_admin_if_needed() {
    local topic="$1"; shift

    if [ -n "$DOTFILES_ADMIN_PHASE" ]; then
        return 0 # we are the delegated admin run - just do the install work
    fi

    if id -Gn "$USER" 2>/dev/null | tr ' ' '\n' | grep -qx admin; then
        return 0 # already admin, nothing to delegate
    fi

    # Remember the chosen admin user across runs (also picked up by
    # homebrew/brew.zsh as the default for its own sudo -u delegation)
    # rather than asking or configuring it twice. Lives in the repo (like
    # git/gitconfig.symlink) but is gitignored - it's machine-specific, not
    # something to commit.
    local admin_user_file="$DOTFILES_DIR/.admin-user"
    local admin_user

    warn "$USER isn't in the admin group; installing apps needs one that is."
    if [ -r "$admin_user_file" ]; then
        admin_user="$(cat "$admin_user_file")"
        running "using cached admin user from $admin_user_file"
        echo "$admin_user"
    else
        read -p "Which admin user should run this install? [grandmaster] " -r admin_user
        admin_user="${admin_user:-grandmaster}"
        echo "$admin_user" > "$admin_user_file"
    fi

    bot "installing as $admin_user (you'll need that account's password); anything per-user (prefs, ...) will still apply to $USER afterward..."
    # Checked explicitly: this function is normally called as an `if`
    # condition, which disables `set -e` inside it, so a failed su (wrong
    # password, or the admin run itself failing) would otherwise be ignored
    # and the caller's per-user steps would run as if the install had happened.
    if ! su "$admin_user" -c "DOTFILES_ADMIN_PHASE=1 $(printf '%q ' "$DOTFILES_DIR/bin/dotfiles" install "$topic" "$@")"; then
        error "the install as $admin_user failed (wrong password? see output above); stopping so nothing continues as $USER."
        exit 1
    fi
    return 1 # already installed by the admin user - caller should skip its install step
}

# Safely install a sudoers.d fragment: writes `content` to a temp file first
# and validates it with `visudo -cf` *before* it ever touches the real config,
# only then copying it into place with the ownership/permissions sudo
# requires (root:wheel, 440). Always cleans up its temp file. `name` becomes
# the filename under /etc/sudoers.d/. Returns non-zero (installing nothing)
# if validation fails.
function install_sudoers_fragment() {
    local name="$1" content="$2"
    local dest="/private/etc/sudoers.d/$name"
    local tmp
    tmp="$(mktemp)"
    echo "$content" > "$tmp"
    if visudo -cf "$tmp"; then
        sudo cp "$tmp" "$dest"
        sudo chown root:wheel "$dest"
        sudo chmod 440 "$dest"
        rm -f "$tmp"
    else
        error "generated sudoers fragment failed validation, not installing '$name'"
        rm -f "$tmp"
        return 1
    fi
}

# Homebrew's `pkg`-cask installer always re-prompts for the sudo password, once
# per cask, no matter how fresh the caller's own sudo ticket is: it runs
# `/usr/sbin/installer` with stdin/stdout piped to itself (so it can relay and
# format the output) rather than connected to the real terminal, so `sudo`
# can't see this tty's cached credentials and falls back to authenticating
# fresh every time. There's no way to fix that from this side of the pipe.
#
# As an opt-in workaround, this installs a sudoers.d rule that allows
# passwordless `sudo /usr/sbin/installer` for the rest of the *current*
# process only. It tries to remove the rule again on exit via an EXIT trap,
# but that can't run if the process is killed outright (Ctrl-C landing on a
# different process group, terminal closed, `kill -9`, a crash) - so on top
# of that, any later call self-heals: it records the owning PID alongside
# the rule, and if that PID is no longer running, treats the rule as a stale
# leftover and removes it before deciding whether to offer a fresh one.
# Call this before a step that installs several pkg-based casks (gpg-suite,
# istat-menus, mountain-duck, ...) to avoid a password prompt after every
# single one.
function offer_passwordless_installer() {
    local sudoers_file="/private/etc/sudoers.d/dotfiles-installer-nopasswd"
    local pid_file="/private/tmp/dotfiles-installer-nopasswd.pid"

    if [ -f "$sudoers_file" ]; then
        if [ -f "$pid_file" ] && kill -0 "$(cat "$pid_file")" 2>/dev/null; then
            return # already active in this process tree
        fi
        bot "removing stale passwordless-installer sudoers rule left over from a previous run"
        sudo rm -f "$sudoers_file"
        rm -f "$pid_file"
    fi

    echo -e ' - Installing several apps can otherwise prompt for your password after every single one (a Homebrew limitation, not a security issue with your Mac).'
    read -p "   Temporarily allow passwordless \`sudo installer\` for the rest of this run? [y/N] " -n 1 -r
    echo
    # Explicit 0: a bare `return` would hand back the failed test's status,
    # and declining is not an error (set -e would abort the whole install).
    [[ $REPLY =~ ^[Yy]$ ]] || return 0

    # SETENV is required because Homebrew's installer invocation sets
    # LOGNAME/USER/USERNAME on the sudo command line itself (`sudo -E
    # LOGNAME=... -- /usr/sbin/installer ...`); without it sudo won't treat
    # that invocation as covered by this rule at all and re-prompts anyway.
    if install_sudoers_fragment dotfiles-installer-nopasswd "$USER ALL = NOPASSWD:SETENV: /usr/sbin/installer"; then
        echo "$$" > "$pid_file"
        ok "passwordless installer enabled for the rest of this run"
        # The sudo ticket from require_sudo can have lapsed by exit time
        # (its keep-alive only refreshes a live ticket, never re-prompts),
        # so say what a possible password prompt here is for.
        trap 'bot "removing the temporary passwordless-installer sudoers rule (may ask for your password)"; sudo rm -f "'"$sudoers_file"'"; rm -f "'"$pid_file"'"' EXIT
    fi
}

function require_osx() {
    if [ "$(uname -s)" != "Darwin" ]; then
        error "Only supported on macOS"
        exit 1
    fi
}

function require_homebrew() {
    # Refresh PATH in case brew was just installed by a sibling process in
    # this same run (e.g. an admin-delegated install - see
    # run_as_admin_if_needed) - a shell's PATH only picks up
    # /opt/homebrew/bin at startup (homebrew/path.zsh), so a brew that
    # didn't exist yet when *this* shell started won't otherwise be found
    # even after it's been installed on disk.
    [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

    # Install Homebrew if not installed - brew.sh
    running "checking homebrew"
    if ! hash brew 2>/dev/null; then
        action "installing homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # can do full pull instead if specific versions are needed again at some point:
        # ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" - --full
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
}

function require_full_disk_access() {
    if ! plutil -lint /Library/Preferences/com.apple.TimeMachine.plist >/dev/null ; then
        echo "This script requires your terminal app to have Full Disk Access."
        echo "Add this terminal to the Full Disk Access list in System Preferences > Security & Privacy, quit the app, and re-run this script."
        exit 1
    fi
}

###
# Shared "apply app/system prefs" machinery, used by macos/install.sh and by
# each Brewfile topic's install.sh for the apps it installs. Callers set
# PREFS_DIR before calling set_prefs, and initialize PREF_FILES, PREF_APPS,
# and AFFECTED_APPS as empty arrays first.
###

# Register a pref script (found at $PREFS_DIR/$1.sh) plus the process
# name(s) it affects.
function set_prefs() {
    PREF_FILES+=("${PREFS_DIR}/$1.sh")
    shift
    PREF_APPS+=("$(IFS='|'; echo "$*")")
    local app
    for app in "$@"; do
        add_affected_app "$app"
    done
}

# Add one process name to AFFECTED_APPS unless it's already there. Many prefs
# scripts affect the same few processes (every macOS pane lists cfprefsd,
# Dock, ...), and without this each one is queried and killed once per script.
function add_affected_app() {
    local existing
    for existing in "${AFFECTED_APPS[@]}"; do
        [ "$existing" == "$1" ] && return 0
    done
    AFFECTED_APPS+=("$1")
}

# Narrow PREF_FILES/AFFECTED_APPS (in place) down to just the registered
# entries whose script basename matches one of the given names. With -q, no
# error is printed when nothing matches (still returns 1) - for callers where
# "this entry has no prefs" is normal, e.g. `install homebrew <app>`.
function select_prefs() {
    local quiet=false
    if [ "$1" == "-q" ]; then
        quiet=true
        shift
    fi

    local matched_files=() matched_apps=() base name i parts app

    for i in "${!PREF_FILES[@]}"; do
        base="$(basename "${PREF_FILES[$i]}" .sh)"
        for name in "$@"; do
            if [ "$base" == "$name" ]; then
                matched_files+=("${PREF_FILES[$i]}")
                if [ -n "${PREF_APPS[$i]}" ]; then
                    IFS='|' read -ra parts <<< "${PREF_APPS[$i]}"
                    matched_apps+=("${parts[@]}")
                fi
            fi
        done
    done

    if [ "${#matched_files[@]}" -eq 0 ]; then
        [ "$quiet" == "true" ] || error "no prefs found for: $*"
        return 1
    fi

    PREF_FILES=("${matched_files[@]}")
    AFFECTED_APPS=()
    for app in "${matched_apps[@]}"; do
        add_affected_app "$app"
    done
}

# Sources all the registered preference files
function source_prefs() {
    for pref_file in "${PREF_FILES[@]}"; do
        [ -r "$pref_file" ] && [ -f "$pref_file" ] && source "$pref_file"
    done
}

# Quit affected applications
function quit_apps() {
    for app in "${AFFECTED_APPS[@]}"; do
        case "$app" in
            'Quick Look')
                # Restart Quick Look
                qlmanage -r
                ;;
            *)
                killall "$app" &>/dev/null || true
                ;;
        esac
    done
}

# Offer to quit whichever AFFECTED_APPS are currently open
function get_open_affected_apps() {
    open_apps=()

    for app in "${AFFECTED_APPS[@]}"; do
        (( $(osascript -e "tell app \"System Events\" to count processes whose name is \"${app}\"") > 0 )) \
        && open_apps+=("$app")
    done

    [ "${#open_apps[@]}" -eq 0 ] && return

    echo "The following open applications will be affected:"
    printf -- '%s\n' "${open_apps[@]}" | column -x

    read -p "Would you like to quit these apps now? [Y/n] " -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        quit_apps
    fi
}

# Install just the named brew/cask/mas entries from a Brewfile, instead of
# running the whole file through `brew bundle`. Looks up each name as an
# exact match against a `brew "name"` / `cask "name"` / `mas "name", id: N`
# line and installs it with the right brew subcommand.
function brew_install_from_file() {
    local brewfile="$1"; shift
    local name line type id

    for name in "$@"; do
        # Literal (not regex) match on the quoted name: entries like
        # `cask "logi-options+"` contain regex metacharacters, and names with
        # spaces (`mas "Paprika Recipe Manager 3", ...`) rule out splitting
        # into fields.
        line="$(NAME="$name" awk '
            match($0, /^(brew|cask|mas)[[:space:]]+"/) {
                rest = substr($0, RLENGTH + 1)
                if (index(rest, ENVIRON["NAME"] "\"") == 1) { print; exit }
            }' "$brewfile")"
        if [ -z "$line" ]; then
            error "no entry for '$name' in $(basename "$brewfile"), skipping"
            continue
        fi

        type="$(echo "$line" | awk '{print $1}')"
        case "$type" in
            brew)
                action "installing $name"
                brew install "$name"
                ;;
            cask)
                action "installing $name (cask)"
                brew install --cask "$name"
                ;;
            mas)
                hash mas 2>/dev/null || brew install mas
                id="$(echo "$line" | grep -oE 'id:[[:space:]]*[0-9]+' | grep -oE '[0-9]+')"
                if [ -n "$id" ]; then
                    action "installing $name (App Store, id $id)"
                    mas install "$id"
                else
                    error "could not parse App Store id for '$name'"
                fi
                ;;
        esac
    done
}

# Runs `brew bundle` against a Brewfile with all `mas "..."` lines filtered
# out. Mac App Store entries must go through install_mas_apps_from_file
# instead (see there for why) - never through an admin-delegated bundle run.
function brew_bundle_no_mas() {
    local brewfile="$1"
    local tmp
    tmp="$(mktemp)"
    grep -v '^mas ' "$brewfile" > "$tmp"
    brew bundle --file="$tmp"
    rm -f "$tmp"
}

# Installs every `mas "..."` entry from a Brewfile under the current,
# non-delegated account. Mac App Store installs go through the App Store's
# own daemon, tied to whichever account is actually signed into the App
# Store in the GUI - not to Unix admin-group permissions - and `su` doesn't
# carry a full GUI session anyway. So unlike casks/formulae, these never
# delegate to an admin user (run_as_admin_if_needed), and this is a no-op
# during the delegated admin run itself (DOTFILES_ADMIN_PHASE) - the
# original, non-admin invocation handles it once control returns, same as
# prefs.
#
# Only covers the full-Brewfile case (no args) - a caller doing a
# single-entry install (e.g. `dotfiles install homebrew Fantastical`) still
# needs to route a mas-typed name through this instead of the admin path
# itself if that ever comes up.
function install_mas_apps_from_file() {
    local brewfile="$1"
    [ -n "$DOTFILES_ADMIN_PHASE" ] && return

    local mas_names=()
    while IFS= read -r name; do
        mas_names+=("$name")
    done < <(grep -oE '^mas "[^"]+"' "$brewfile" | sed -E 's/^mas "(.*)"$/\1/')
    [ "${#mas_names[@]}" -eq 0 ] && return

    # require_homebrew only matters here to refresh this process's PATH for
    # a `mas` a sibling admin-delegated process just installed (see
    # require_homebrew's own comment) - skip both it and the install
    # entirely once `mas` is already found, same short-circuit
    # brew_install_from_file's own mas case uses.
    hash mas 2>/dev/null || { require_homebrew; brew install mas; }

    # Wait until app store sign-in is done
    # mas account is broken: https://github.com/mas-cli/mas/issues/417
    read -p "Make sure you're logged into the App Store!" -r

    brew_install_from_file "$brewfile" "${mas_names[@]}"
}

# Installs a topic's whole Brewfile: casks/formulae go through admin
# delegation if this account needs it (run_as_admin_if_needed), Mac App
# Store entries never do (install_mas_apps_from_file) and always install
# under this account afterward instead. Handles both the full-Brewfile
# install (no args) and installing just a handful of named entries (args) -
# same two modes every topic's install.sh already branches on. Running
# brew_bundle_no_mas/install_mas_apps_from_file against a Brewfile with no
# `mas` lines is a harmless no-op, so this is safe to use even for topics
# that don't have any App Store entries today.
#
# A topic's other admin-only steps (e.g. homebrew/install.sh's
# softwareupdate/Rosetta/1Password fixup) don't need to share this call's
# admin session - they only need root via sudo, not admin-group membership
# (that's specific to Homebrew Cask's un-sudo'd writes into /Applications)
# - so they can run directly under this account before/after this call
# instead. Guard them with `[ -z "$DOTFILES_ADMIN_PHASE" ]` (and
# `[ "$#" -eq 0 ]` if they're full-install-only) so they don't also run
# during this function's own delegated re-invocation of the whole script.
function install_brewfile() {
    local topic="$1" brewfile="$2"; shift 2

    if run_as_admin_if_needed "$topic" "$@"; then
        require_homebrew

        if [ "$#" -gt 0 ]; then
            # Install just the named Brewfile entries, skip the full-machine dance.
            brew update
            brew_install_from_file "$brewfile" "$@"
            brew cleanup
        else
            require_sudo
            offer_passwordless_installer

            bot "installing tools via homebrew..."
            action "update brew..."
            brew update
            ok "brew updated..."
            # Need to run brew upgrade at this point to make sure `brew list` works correctly...
            brew upgrade
            ok "brew upgraded..."

            brew_bundle_no_mas "$brewfile"

            brew cleanup
        fi
    fi

    if [ "$#" -eq 0 ]; then
        install_mas_apps_from_file "$brewfile"
    fi
}
