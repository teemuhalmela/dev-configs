#!/bin/bash

#for C in {0..255}; do
#    tput setab $C
#    echo -n "$C "
#done
#tput sgr0
#echo

# standard colors
for C in {40..47}; do
    echo -en "\e[${C}m$C "
done

# high intensity colors
for C in {100..107}; do
    echo -en "\e[${C}m$C "
done
# 256 colors
for C in {16..255}; do
    echo -en "\e[48;5;${C}m$C "
done
echo -e "\e(B\e[m"
