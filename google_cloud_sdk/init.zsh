#!/usr/bin/env zsh

if [ -x "$(command -v brew)" ]; then 
	[[ -s "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc" ]] && source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
	[[ -s "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc" ]] && source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
fi

if $(gcloud info --format="value(basic.python_location)") -m pip show numpy > /dev/null 2>&1; then
    export CLOUDSDK_PYTHON_SITEPACKAGES=1
fi
