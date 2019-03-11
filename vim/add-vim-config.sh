#!/bin/bash

if [ ! -d $HOME/.vim ]; then
    mkdir $HOME/.vim
fi

ln -sf $PWD/vimrc $HOME/.vim/.
