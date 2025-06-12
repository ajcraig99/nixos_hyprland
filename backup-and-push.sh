#!/usr/bin/env bash

# Change to dotfiles directory
cd ~/dotfiles

# Copy configs
echo "Copying configs..."
./copy-configs.sh

# Git operations
echo "Pushing to GitHub..."
git add .
git commit -m "Auto backup: $(date '+%Y-%m-%d %H:%M')"
git push origin main

# Show notification (optional)
if command -v notify-send &> /dev/null; then
    notify-send "Dotfiles" "Configs backed up to GitHub!" -t 3000
fi

echo "Backup complete!"
