#!/bin/bash -eu

mozdir="$HOME/.mozilla/firefox"

if [[ ! -d "$mozdir" ]]; then
    echo "Creating default profile"
    firefox -headless -CreateProfile default
fi

profiledir=$(find "$mozdir" -maxdepth 1 -type d -name '*.default' -print -quit)
echo "Profile: $profiledir"

if [[ -z "$profiledir" ]]; then
    echo "Firefox profile is empty"
    exit 1
fi

ln -sf "$PWD/user.js" "$profiledir/."
