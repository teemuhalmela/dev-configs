#!/bin/bash

set -euo pipefail

main() {
	loadkeys fi
	timedatectl set-ntp true

	parted -s /dev/sda \
	    mklabel msdos \
	    mkpart primary ext4 1 100% \
	    set 1 boot on

	#Format & mount
	mkfs.ext4 -L ROOT /dev/sda1
	mount /dev/sda1 /mnt
	trap 'umount -R /mnt' ERR

	# Install base
	pacstrap /mnt base linux-lts

	# Set fstab
	genfstab -L /mnt > /mnt/etc/fstab

	echo "Copying install scripts to the new system."
	cp -r ../../dev-configs /mnt/.

	echo "Going to chroot and continuing the install there..."
	arch-chroot /mnt /bin/bash -c 'pushd /dev-configs/arch; ./in-chroot.sh;'

	trap - ERR
	umount -R /mnt
	echo "Installation is done... reboot is happening in 15 seconds"
	sleep 15
	reboot
}

main $@
