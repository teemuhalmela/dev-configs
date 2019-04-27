#!/bin/bash -eu

mozdir="$HOME/.mozilla/firefox"

if [[ ! -d "$mozdir" ]]; then
    echo "Creating default profile"
    firefox -CreateProfile default
fi

profiledir=$(find "$mozdir" -maxdepth 1 -type d -name '*.default' -print -quit)
echo "Profile: $profiledir"
ln -sf "$PWD/user.js" "$profiledir/."
