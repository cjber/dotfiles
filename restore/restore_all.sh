#!/bin/bash
sed -i 's,^#MAKEFLAGS=.*,MAKEFLAGS="-j$(nproc)",g' /etc/makepkg.conf \
        && sed -i "s,^PKGEXT=.*,PKGEXT='.pkg.tar',g" /etc/makepkg.conf
pacman -Syu --needed --noconfirm git reflector fish
reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist

su cjber
cd ~

# Install yay
git clone https://aur.archlinux.org/yay.git \
        && cd yay \
        && makepkg -sri --needed --noconfirm \
        && cd \
        && rm -rf .cache yay
yay -S --needed --noconfirm - < applist
dotdrop install
set -G DOTDROP_PROFILE home

sudo systemctl enable ly.service

pyenv install 3.8.6
pyenv virtualenv 3.8.6 py3nvim
pyenv activate py3nvim
pip install \
    wheel \
    neovim
