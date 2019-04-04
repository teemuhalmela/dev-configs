#!/bin/bash

echo "Must be run as root!"
echo "Copying file..."

# We copy file because cron doesn't like symlinks if the real file isn't owned by the user who is running cron.
cp $PWD/restart-ntp /etc/cron.d/.

echo "DONE!"
