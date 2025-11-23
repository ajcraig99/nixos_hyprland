#!/run/current-system/sw/bin/bash
if [ $(pgrep -c hyprpaper) -ne 0 ]; then
    hyprctl hyprpaper unload all
    pkill hyprpaper
fi

# Auto-detect monitor
MONITOR=$(hyprctl monitors | grep "Monitor" | head -n1 | awk '{print $2}')
echo "Using monitor: $MONITOR"

TARGET="$HOME/Pictures/wallpapers"
WALLPAPER=$(find "$TARGET" -type f -regex '.*\.\(jpg\|jpeg\|png\|webp\|gif\)' | shuf -n 1)
CONFIG_PATH="$HOME/.config/hypr/hyprpaper.conf"
echo "preload = $WALLPAPER" > "$CONFIG_PATH"
echo "wallpaper = $MONITOR, $WALLPAPER" >> "$CONFIG_PATH"  # Use detected monitor
echo "splash = off" >> "$CONFIG_PATH"
echo "ipc = off" >> "$CONFIG_PATH"
hyprpaper &
