#!/bin/bash

set -eu

read -p "Enter username: " username
useradd -m -s /bin/bash "$username"
passwd "$username"

cp -r ../../dev-configs "/home/$username/."
chown -R $username:$username "/home/$username/dev-configs"

pushd "/home/$username/dev-configs/arch"
./config.sh "$username"

##·Disable·root·login
##·passwd·-l·root
