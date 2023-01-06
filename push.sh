#/bin/bash

git checkout master
git add .
git commit -m "update"

git push origin master --force

git checkout release/beta
git merge master
git checkout master
git push origin release/beta --force