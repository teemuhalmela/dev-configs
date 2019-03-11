#!/bin/bash

echo "Must be run as root!"

ln -sf $PWD/restart-ntp /etc/cron.d/.
