#!/bin/bash -e

configdir="$HOME/.config/Code - OSS"
userdir="$configdir/User"

if [ ! -d "$configdir" ]; then
    echo "Please install Visual studio code."
    exit 1
fi

if [ -d "$userdir" ]; then
    rm -rf "$userdir"
fi

ln -sf "$PWD/User" "$userdir"


./installExtensions.sh
