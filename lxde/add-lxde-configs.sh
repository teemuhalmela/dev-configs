#!/bin/bash

ln -sf $PWD/lubuntu-rc.xml $HOME/.config/openbox/.
rm -rf $HOME/.config/lxpanel/Lubuntu
ln -sf $PWD/Lubuntu $HOME/.config/lxpanel/.
