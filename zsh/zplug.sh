#
# zplug
#

if ! type "timeout" > /dev/null; then

  # https://unix.stackexchange.com/a/43346
  timeout() {

      time=$1

      # start the command in a subshell to avoid problem with pipes
      # (spawn accepts one command)
      command="/bin/sh -c \"$2\""

      expect -c "set echo \"-noecho\"; set timeout $time; spawn -noecho $command; expect timeout { exit 1 } eof { exit 0 }"    

      if [ $? = 1 ] ; then
          echo "Timeout after ${time} seconds"
      fi

  }
fi

# Install if not already installed
source ~/.zplug/init.zsh || { \
	curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh && 
  timeout 10 "while \[ ! -f ~/.zplug/init.zsh ]; do sleep 1; done" && \
	source ~/.zplug/init.zsh \
}

# zplug "miekg/lean"
zplug "eendroroy/alien-minimal"
zplug "zsh-users/zsh-completions"
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zplug "zsh-users/zsh-autosuggestions" # slows down terminal ..
zplug "zsh-users/zsh-syntax-highlighting",      defer:2
zplug "zsh-users/zsh-history-substring-search", defer:3
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

#zplug 'djui/alias-tips'
zplug 'xvoland/Extract', use:'*.sh'
zplug 'supercrabtree/k'

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
   printf "Install? [y/N]: "
   if read -q; then
       echo; zplug install
   else
       echo
   fi
fi

zplug load

#
# end zplug
#
