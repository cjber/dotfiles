#!/bin/bash
cd ~/dotfiles/
git add .
git commit -m "minor updates on `date +'%Y-%m-%d %H:%M:%S'`"
git push origin master
