#!/bin/bash -eu

trap 'clean' 0

main() {
    sudo -v
    #sudo apt-get update && sudo apt-get install -y build-essential
    sudo mkdir -p /mnt/cdrom
    sudo mount /dev/cdrom /media/cdrom
    sudo /media/cdrom/VBoxLinuxAdditions.run
}

clean() {
    echo ""
    echo "CLEANING"
    sudo umount /media/cdrom
    sudo -k
}

main $@
