#!/bin/bash -eu

mozdir="$HOME/.mozilla/firefox"
profilename="myprofile"
profiledir=$(find "$mozdir" -maxdepth 1 -type d -name "*.$profilename" -print -quit)

if [[ ! -d "$profiledir" ]]; then
    echo "Creating default profile"
    firefox -headless -CreateProfile "$profilename"
fi

profiledir=$(find "$mozdir" -maxdepth 1 -type d -name "*.$profilename" -print -quit)
echo "Profile: $profiledir"

if [[ -z "$profiledir" ]]; then
    echo "Firefox profile is empty"
    exit 1
fi

ln -sf "$PWD/user.js" "$profiledir/."
