#!/bin/bash
git clone https://aur.archlinux.org/yay.git \
        && cd yay \
        && makepkg -sri --needed --noconfirm \
        && cd \
        && rm -rf .cache yay
yay -S --needed --noconfirm - < applist

pyenv install 3.8.6
pyenv virtualenv 3.8.6 py3nvim
pyenv activate py3nvim
pip install \
    wheel \
    neovim
#dotdrop --profile= install
