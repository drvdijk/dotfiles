#!/usr/bin/env zsh

if [[ -x /opt/homebrew/bin/brew ]]
then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

path+=/usr/local/sbin
