#!/bin/bash
sed -i "s,^#MAKEFLAGS=.*,MAKEFLAGS='-j$(nproc)',g" /etc/makepkg.conf \
        && sed -i "s,^PKGEXT=.*,PKGEXT='.pkg.tar',g" /etc/makepkg.conf \
        && sed -i "s,^#Color,Color,g" /etc/makepkg.conf
pacman -Syu --needed --noconfirm git reflector zsh
reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
