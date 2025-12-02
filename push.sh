#!/bin/sh
git remote set-url origin https://github.com/LynxSaiko/LazyFramework.git

git init
git add .
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/LynxSaiko/LazyFramework.git
git push -u origin main
