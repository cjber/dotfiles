#!/bin/bash
cd ~/
echo 'export DOTDROP_PROFILE=home'
echo 'export DOTDROP_PROFILE=home' >> .profile
cd dotfiles
dotdrop install
