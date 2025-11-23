#!/run/current-system/sw/bin/bash

HYPRIDLE_PID=$(pgrep hypridle)

case "$1" in
  "status")
    if [ -n "$HYPRIDLE_PID" ]; then
      echo '{"text": "󰒲", "class": "idle-on", "tooltip": "Hypridle is ON - Click to disable"}'
    else
      echo '{"text": "󰒳", "class": "idle-off", "tooltip": "Hypridle is OFF - Click to enable"}'
    fi
    ;;
  "toggle")
    if [ -n "$HYPRIDLE_PID" ]; then
      pkill hypridle
      notify-send "Hypridle" "Disabled - System will not sleep"
    else
      hypridle &
      notify-send "Hypridle" "Enabled - System will sleep normally"
    fi
    ;;
esac
