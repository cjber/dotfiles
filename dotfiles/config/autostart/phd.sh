#!/bin/bash
cd ~/drive/phd
git add .
git commit -m "`git show --pretty="" --name-only`"
git push origin master
