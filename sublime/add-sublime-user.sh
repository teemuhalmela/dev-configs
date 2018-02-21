#!/bin/bash

sublime="$HOME/.config/sublime-text-3"
subtext="$sublime/Packages/User"

if [ ! -d "$sublime" ]; then
    echo "Please install sublime text 3."
    exit 1
fi

if [ -d $subtext ]; then
    rm -rf $subtext
fi

ln -sf $PWD/User $subtext

# TODO: Add other packages like jshint?
echo "Please install jq and xmllint"
echo "apt install jq"
echo "apt install libxml2-utils"
