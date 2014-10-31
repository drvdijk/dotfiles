#!/usr/bin/env zsh

alias sweep="find . -name .DS_Store -type f -delete ; find . -type d -print0 | xargs -0 dot_clean -m"

