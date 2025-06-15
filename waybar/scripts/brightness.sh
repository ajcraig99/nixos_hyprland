#!/run/current-system/sw/bin/bash
# First try ddcci, then fall back to ddcutil
BACKLIGHT_DEV=$(ls /sys/class/backlight/ 2>/dev/null | grep ddcci | head -1)

if [[ -n "$BACKLIGHT_DEV" ]]; then
    # Use ddcci method (fast)
    BACKLIGHT_PATH="/sys/class/backlight/$BACKLIGHT_DEV"
    
    get_brightness() {
        if [[ -f "$BACKLIGHT_PATH/brightness" && -f "$BACKLIGHT_PATH/max_brightness" ]]; then
            current=$(cat "$BACKLIGHT_PATH/brightness")
            max=$(cat "$BACKLIGHT_PATH/max_brightness")
            percentage=$((current * 100 / max))
            echo "$percentage"
        else
            echo "50"
        fi
    }
    
    set_brightness() {
        if [[ "$1" -ge 0 && "$1" -le 100 ]] 2>/dev/null; then
            max=$(cat "$BACKLIGHT_PATH/max_brightness")
            value=$((max * $1 / 100))
            echo "$value" | sudo tee "$BACKLIGHT_PATH/brightness" > /dev/null
        fi
    }
else
    # Fall back to ddcutil method (slower but works)
    CACHEFILE="/tmp/brightness_cache"
    
    get_brightness() {
        # Use cache if recent (less than 5 seconds old)
        if [[ -f "$CACHEFILE" ]] && [[ $(($(date +%s) - $(stat -c %Y "$CACHEFILE"))) -lt 5 ]]; then
            cat "$CACHEFILE"
            return
        fi
        
        brightness=$(ddcutil getvcp 10 2>/dev/null | grep -o 'current value = [0-9]*' | grep -o '[0-9]*')
        
        if [[ -z "$brightness" ]] || ! [[ "$brightness" =~ ^[0-9]+$ ]]; then
            if [[ -f "$CACHEFILE" ]]; then
                brightness=$(cat "$CACHEFILE")
            else
                brightness=50
            fi
        else
            echo "$brightness" > "$CACHEFILE"
        fi
        
        echo "$brightness"
    }
    
    set_brightness() {
        if [[ "$1" -ge 0 && "$1" -le 100 ]] 2>/dev/null; then
            ddcutil setvcp 10 "$1" 2>/dev/null &
            echo "$1" > "$CACHEFILE"
        fi
    }
fi

case "$1" in
    get)
        brightness=$(get_brightness)
        printf '{"text": "󰃞", "percentage": %d, "tooltip": "Brightness: %d%%"}\n' "$brightness" "$brightness"
        ;;
    set)
        set_brightness "$2"
        ;;
    get-percentage)
        get_brightness
        ;;
    *)
        echo "Usage: $0 {get|set|get-percentage} [value]"
        exit 1
        ;;
esac
