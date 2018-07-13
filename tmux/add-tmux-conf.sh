#!/bin/bash

# sudo apt install tmux
# $ git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

ln -sf $PWD/tmux.conf $HOME/.tmux.conf

autostartfile=$HOME/.config/systemd/user/tmux.service
if [[ -f "$autostartfile" ]]; then
    rm $autostartfile
fi
