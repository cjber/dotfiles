#!/bin/bash
git clone https://aur.archlinux.org/yay.git \
        && cd yay \
        && makepkg -sri --needed --noconfirm \
        && cd .. \
        && rm -rf yay

yes | yay -Scc \
    && yay -S --needed --noconfirm - < applist

# cd ~/dotfiles/dotfiles/config/nvim/ \
#     && mkvenv \
#     && pip install \
#     wheel \
#     neovim
