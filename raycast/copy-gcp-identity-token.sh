#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Copy GCP identity token to clipboard for ModHeader
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ☁️
# @raycast.packageName Developer Utils

# Documentation:
# @raycast.description Copies identity token from gcloud to clipboard with Bearer prefix for easy use in ModHeader
# @raycast.author Daan van Dijk

if ! command -v gcloud >/dev/null; then
	echo "gcloud not installed"
	exit 1
fi

echo Bearer $(gcloud auth print-identity-token) | pbcopy
echo "Bearer identity token copied to clipboard for ModHeader"
