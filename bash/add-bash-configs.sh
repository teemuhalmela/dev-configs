#!/bin/bash
bashrc=$HOME/.bashrc
lines=(
"if [ -f ~/.bashrc-mine ]; then"
"    . ~/.bashrc-mine"
"fi"
)
grep -q -F "${lines[1]}" $bashrc || printf "%s\n" "${lines[@]}" >> $bashrc

mine=$PWD/bashrc-mine
homemine=$HOME/.bashrc-mine
ln -sf $mine $homemine
ln -sf $PWD/bash_aliases $HOME/.bash_aliases
