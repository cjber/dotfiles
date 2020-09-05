#!/bin/bash
git clone https://aur.archlinux.org/yay.git && \
    cd yay && \
    sudo pacman -U yay*.pkg.* --noconfirm && \
    cd && \
    rm -rf yay
yay -S --needed --noconfirm - < applist
