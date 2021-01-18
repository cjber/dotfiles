#!/bin/bash
git clone https://aur.archlinux.org/yay.git && \
    cd yay && \
    makepkg -si && \
    sudo pacman -U yay*.pkg.* --noconfirm && \
    cd && \
    rm -rf yay
yay -S --needed --noconfirm - < applist

sudo systemctl enable ly.service
sudo chsh cjber

pyenv install 3.8.5
pyenv virtualenv 3.8.5 py3nvim
pyenv activate py3nvim
pip install \
    wheel \
    neovim
