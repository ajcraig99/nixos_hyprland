#!/usr/bin/env zsh
# copy-configs.sh - Copy active configs to dotfiles repo


# Create directories
mkdir -p nixos hypr waybar terminal apps fastfetch micro nemo swayidle swaylock

# Copy NixOS system config
echo "Copying NixOS configs..."
sudo cp /etc/nixos/configuration.nix nixos/
sudo cp /etc/nixos/hardware-configuration.nix nixos/

cp -r ~/.config/hypr/* hypr/
echo "Copying Waybar config..."
cp -r ~/.config/waybar/* waybar/
cp -r ~/.config/alacritty/* terminal/
cp -r ~/.config/fastfetch/* fastfetch/
cp -r ~/.config/micro/* micro/
cp -r ~/.config/nemo/* nemo/
cp -r ~/.config/swayidle/* swayidle/
cp -r ~/.config/swaylock/* swaylock/


echo "Done! Ready to commit and push."
