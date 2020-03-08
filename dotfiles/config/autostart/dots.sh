#!/bin/fish
cd ~/dotfiles/
dotgit add .
dotgit commit -m "daily"
dotgit push origin master
