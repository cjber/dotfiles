#!/bin/bash
cd ~/drive/phd/modules
git add .
git commit -m "`git show --pretty="" --name-only`"
git push origin master

cd ~/drive/phd/literature/
git add .
git commit -m "`git show --pretty="" --name-only`"
git push origin master
