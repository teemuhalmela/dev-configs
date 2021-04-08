#!/bin/bash

set -euo pipefail

setting() {
	echo "Setting...$1"
}

remove_comment() {
	sed -i "s/#$1/$1/g" "$2"
}

set_value() {
	sed -i "s/$1=.*$/$1=$3/g" "$2"
}

main() {
	username="${1:-}"
	if [[ -z "$username" ]]; then
		echo "First parameter must be given and it should be valid user."
		exit 1
	fi

	if [[ $(id -u) -ne 0 ]]; then
		echo "Script must be run as root."
		exit 1
	fi
	id "$username" >> /dev/null

	# Timezone
	setting "timezone"
	ln -sf /usr/share/zoneinfo/Europe/Helsinki /etc/localtime
	hwclock --systohc

	###
	###	LOCALE AND KEYBOARD
	###
	setting "locale"
	# echo "fi_FI.UTF-8 UTF-8" >> /etc/locale.gen
	remove_comment "en_US.UTF-8 UTF-8" /etc/locale.gen
	locale-gen
	# echo "LANG=fi_FI.UTF-8" > /etc/locale.conf
	echo "LANG=en_US.UTF-8" > /etc/locale.conf
	echo "LC_COLLATE=C" >> /etc/locale.conf

	# For Console
	setting "keymap"
	echo "KEYMAP=fi" > /etc/vconsole.conf

	###
	###	NETWORK ~ 
	###
	setting "hostname"
	echo "namehost" > /etc/hostname
	cat > /etc/hosts <<EOF
127.0.0.1	localhost
::1		localhost
127.0.1.1	namehost.localdomain namehost
EOF

	setting "wired network"
	cat > /etc/systemd/network/20-wired.network <<EOF
[Match]
Type=ether

[Network]
DHCP=yes
EOF

	setting "network services"
	#ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

	systemctl enable systemd-networkd
	systemctl enable systemd-resolved

	###
	### SUBLIME. Must be added before installing programs.
	###
	err=0
	pacman-key -l sublime >> /dev/null || err=$?
	if [[ $err -ne 0 ]]; then
		curl -O https://download.sublimetext.com/sublimehq-pub.gpg \
			&& pacman-key --add sublimehq-pub.gpg \
			&& pacman-key --lsign-key 8A8F901A \
			&& rm sublimehq-pub.gpg

		echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | tee -a /etc/pacman.conf
		pacman -Syu
	fi

	#pacman -Qqe > pkglist.txt
	pacman -S --needed - < pkglist.txt
	### Remove all not in list
	# pacman -Rsu $(comm -23 <(pacman -Qq | sort) <(sort pkglist.txt))

	###
	### Reflector: keep mirrorlist uptodate
	###
	cat > /etc/xdg/reflector/reflector.conf <<EOF
--save /etc/pacman.d/mirrorlist
--protocol https
--country Finland,Sweden
--fastest 20
--sort rate
--age 40
EOF
	systemctl enable reflector
	systemctl enable reflector.timer

	###
	###	SUDO
	###

	setting "sudo"
	cat > /etc/sudoers.d/25-vim-editor <<EOF
Defaults	env_reset
Defaults	editor=/usr/bin/vim, !env_editor
EOF

	cat > /etc/sudoers.d/30-env-keep <<EOF
Defaults	env_keep +="LANG LANGUAGE TERM"
EOF

	cat > /etc/sudoers.d/40-wheel <<EOF
%wheel		ALL=(ALL) ALL
EOF

	# Bootloader
	setting "grub"
	grub-install --target=i386-pc /dev/sda

	remove_comment "GRUB_CMDLINE_LINUX_DEFAULT" "/etc/default/grub"
	remove_comment "GRUB_GFXMODE" "/etc/default/grub"
	remove_comment "GRUB_GFXPAYLOAD_LINUX" "/etc/default/grub"
	remove_comment "GRUB_COLOR_NORMAL" "/etc/default/grub"
	remove_comment "GRUB_COLOR_HIGHLIGHT" "/etc/default/grub"

	set_value      "GRUB_CMDLINE_LINUX_DEFAULT" "/etc/default/grub" "\"video=1280x1024\""
	set_value      "GRUB_GFXMODE" "/etc/default/grub" "1280x1024x24"
	set_value      "GRUB_GFXPAYLOAD_LINUX" "/etc/default/grub" "keep"
	set_value      "GRUB_COLOR_NORMAL" "/etc/default/grub" "\"green\/black\""
	set_value      "GRUB_COLOR_HIGHLIGHT" "/etc/default/grub" "\"cyan\/white\""

	grub-mkconfig -o /boot/grub/grub.cfg

	mkdir -p /etc/systemd/system/getty@tty1.service.d
	cat > "/etc/systemd/system/getty@tty1.service.d/noclear.conf" <<EOF
[Service]
TTYVTDisallocate=no
EOF

	remove_comment "Color" "/etc/pacman.conf"

	###
	###	INSTALL AND CONFIGURE DESKTOP
	###

	## XDM
	# xlsfonts can list available fonts
	# xorg-mkfontscale is needed for bitmap fonts
	# Keyboard laytor for Xorg eq. desktop, needs libxkbcommon-x11 to be installed

	setting "X keyboard"
	# localectl does not work inside chroot
	#localectl --no-convert set-x11-keymap fi pc105 "" nbsp:none,ctrl:nocaps
	mkdir -p /etc/X11/xorg.conf.d
	cat > /etc/X11/xorg.conf.d/10-keyboard.conf <<EOF
Section "InputClass"
	Identifier "system-keyboard"
	MatchIsKeyboard "on"
	Option "XkbLayout" "fi"
	Option "XkbModel" "pc105"
	Option "XkbOptions" "nbsp:none,ctrl:nocaps"
EndSection
EOF

	setting "xdm"
	cat > /etc/X11/xdm/Xsetup_0 <<EOF
#!/bin/sh
xsetroot -solid gray17
EOF
	systemctl enable xdm

	# TODO: Is this needed?
	# ln -sf /usr/share/fontconfig/conf.avail/70-yes-bitmaps.conf /usr/share/fontconfig/conf.default/70-yes-bitmaps.conf

	# TODO: Rootless xorg. Might not work with xdm.

	userhome="/home/$username"
	setting "xsession"
	ln -sf $PWD/.xsession "$userhome/.xsession"
	chown -h "$username":"$username" "$userhome/.xsession"

	###
	###	VIRTUALBOX
	###
	setting "virtualbox"
	systemctl enable vboxservice

	# AUTOSTART VBoxClient-all has been added to .xsession file already.

	###
	### BASH
	###

	###
	### Enable periodic trim. Installed from util-linux (gets installed automatically).
	###
	setting "periodic trim"
	systemctl enable fstrim.timer

	setting "User groups"
	usermod -a -G wheel,vboxsf "$username"

	echo "Starting app configuration with user: $username."

	sudo -u $username ln -sf $PWD/.vimrc "$userhome/.vimrc"
	sudo -u $username ln -sf $PWD/.bashrc "$userhome/.bashrc"
	sudo -u $username ln -sf $PWD/.Xresources "$userhome/.Xresources"
	sudo -u $username mkdir -p "$userhome/.xmonad"
	sudo -u $username ln -sf $PWD/xmonad.hs "$userhome/.xmonad/xmonad.hs"

	sublimeuserdir="$userhome/.config/sublime-text-3/Packages/User"
	sudo -u $username mkdir -p "$sublimeuserdir"
	if [[ -d "$sublimeuserdir" ]] && [[ ! -L "$sublimeuserdir" ]]; then
		sudo -u $username rm -rf "$sublimeuserdir"
	fi
	if [[ ! -d "$sublimeuserdir" ]]; then
		sudo -u $username ln -sf "$PWD/../sublime/User" "$sublimeuserdir"
	fi

	sudo -u $username ln -sf $PWD/../tmux/tmux.conf "$userhome/.tmux.conf"
	if [[ -d "$userhome/.tmux/plugins/tpm" ]]; then
		pushd "$userhome/.tmux/plugins/tpm"
		sudo -u $username git pull
		popd
	else
		sudo -u $username git clone https://github.com/tmux-plugins/tpm "$userhome/.tmux/plugins/tpm"
	fi
	echo "App configuration done."
}

main $@
