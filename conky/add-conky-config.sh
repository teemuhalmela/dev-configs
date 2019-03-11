#!/bin/bash

if [ ! -d $HOME/.config/conky ]; then
    mkdir $HOME/.config/conky
fi

ln -sf $PWD/conky.conf $HOME/.config/conky/.
