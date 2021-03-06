#!/bin/bash -eu

trap 'clean' 0

main() {
    sudo -v
    sudo apt-get update && sudo apt-get install -y build-essential
    sudo mkdir -p /media/cdrom
    sudo mount /dev/cdrom /media/cdrom
    sudo /media/cdrom/VBoxLinuxAdditions.run

    sudo usermod -G vboxsf -a $USER
}

clean() {
    echo ""
    echo "CLEANING"
    sudo umount /media/cdrom
    sudo -k
    eject
}

main $@
