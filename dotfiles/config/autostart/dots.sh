#!/bin/bash
cd ~/dotfiles/
git add .
git commit -m "changed: `git show --pretty="" --name-only`"
git push origin master
