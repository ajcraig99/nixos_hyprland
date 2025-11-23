#!/run/current-system/sw/bin/bash

# Get Spotify data
artist=$(playerctl -p spotify metadata artist 2>/dev/null)
title=$(playerctl -p spotify metadata title 2>/dev/null)
position=$(playerctl -p spotify position 2>/dev/null)
length=$(playerctl -p spotify metadata mpris:length 2>/dev/null)
status=$(playerctl -p spotify status 2>/dev/null)

# Check if Spotify is available
if [ -z "$artist" ] || [ -z "$title" ]; then
    echo '{"text": "No Spotify", "class": "no-media"}'
    exit 0
fi

# Calculate progress percentage
if [ -n "$position" ] && [ -n "$length" ] && [ "$length" -gt 0 ]; then
    length_sec=$((length / 1000000))
    if [ "$length_sec" -gt 0 ]; then
        percentage=$(echo "scale=0; $position * 100 / $length_sec" | bc 2>/dev/null)
        if [ -z "$percentage" ]; then
            percentage=0
        fi
    else
        percentage=0
    fi
else
    percentage=0
fi

# Create progress bar (40 characters for better resolution)
bar_length=40
filled=$((percentage * bar_length / 100))
empty=$((bar_length - filled))

progress_bar=""
for ((i=0; i<filled; i++)); do
    progress_bar+="█"
done
for ((i=0; i<empty; i++)); do
    progress_bar+="░"
done

# Combine artist and title, truncate if too long
media_text="$artist - $title"
if [ ${#media_text} -gt 40 ]; then
    media_text="${media_text:0:37}..."
fi

# Determine CSS class based on status
css_class="playing"
if [ "$status" = "Paused" ]; then
    css_class="paused"
fi

# Output JSON with both lines
printf '{"text": "%s\\n%s", "tooltip": "Spotify: %s\\nProgress: %d%%", "class": "%s"}\n' \
    "$media_text" "$progress_bar" "$media_text" "$percentage" "$css_class"
