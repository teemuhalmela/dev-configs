#!/bin/bash

# sudo apt install rxvt-unicode-256color

ln -sf $PWD/Xdefaults $HOME/.Xdefaults
ln -sf $PWD/Xresources $HOME/.Xresources

echo "You need to logout to colors from Xresources to take effect."
