#!/bin/bash

set -euf

mkdir -p $HOME/mail/a
chmod 700 $HOME/mail

ln -sf $PWD/muttrc $HOME/.muttrc
if [[ ! -f "$HOME/.muttrc-box" ]]; then
	cp muttrc-box $HOME/.muttrc-box
fi
chmod 600 $HOME/.muttrc-box

if [[ ! -f "$HOME/.mbsyncrc" ]]; then
	cp mbsyncrc $HOME/.mbsyncrc
fi
chmod 600 $HOME/.mbsyncrc

if [[ ! -f "$HOME/.esmtprc" ]]; then
	cp esmtprc $HOME/.esmtprc
fi
chmod 600 $HOME/.esmtprc
