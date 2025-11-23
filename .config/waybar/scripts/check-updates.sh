#!/usr/bin/env bash

# NixOS update checker for Waybar
# Returns JSON format for Waybar custom module

# Check if we can reach the internet
if ! ping -c 1 8.8.8.8 &> /dev/null; then
    echo '{"text": "📦 ?", "tooltip": "No internet connection", "class": "disconnected"}'
    exit 0
fi

# For NixOS, check if there are updates available
# This is a simple approach - you might want to customize based on your update strategy

# Option 1: Check if nix-channel is newer (for channels)
if command -v nix-channel &> /dev/null; then
    # This is a basic check - customize as needed
    UPDATES=$(nix-channel --update --dry-run 2>&1 | grep -c "unpacking\|downloading" || true)
    # Make sure UPDATES is a valid number
    if ! [[ "$UPDATES" =~ ^[0-9]+$ ]]; then
        UPDATES=0
    fi
else
    UPDATES=0
fi

# Option 2: For flakes, you might want to check your flake inputs
# Uncomment and customize if you use flakes:
# cd /etc/nixos  # or wherever your flake is
# UPDATES=$(nix flake update --dry-run 2>&1 | grep -c "Updated\|updated" || true)

if [ "$UPDATES" -gt 0 ]; then
    echo "{\"text\": \"📦 $UPDATES\", \"tooltip\": \"$UPDATES updates available\", \"class\": \"updates-available\"}"
else
    echo "{\"text\": \"📦\", \"tooltip\": \"System up to date\", \"class\": \"up-to-date\"}"
fi
