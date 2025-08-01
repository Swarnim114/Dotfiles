#!/bin/bash
cd ~/.dotfiles
if [[ `git status --porcelain` ]]; then
    git add .
    git commit -m "Daily auto-commit: $(date '+%Y-%m-%d %H:%M')"
    git push origin main
fi
