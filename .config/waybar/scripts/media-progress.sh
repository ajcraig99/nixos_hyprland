#!/run/current-system/sw/bin/bash


# Get current position and length from Spotify specifically
position=$(playerctl -p spotify position 2>/dev/null)
length=$(playerctl -p spotify metadata mpris:length 2>/dev/null)

if [ -z "$position" ] || [ -z "$length" ]; then
    echo '{"text": "No Spotify", "class": "no-media"}'
    exit 0
fi

# Convert microseconds to seconds for length
length_sec=$((length / 1000000))

# Calculate percentage
if [ "$length_sec" -gt 0 ]; then
    percentage=$(echo "scale=0; $position * 100 / $length_sec" | bc)
else
    percentage=0
fi

# Create progress bar (20 characters wide)
bar_length=20
filled=$((percentage * bar_length / 100))
empty=$((bar_length - filled))

progress_bar=""
for ((i=0; i<filled; i++)); do
    progress_bar+="█"
done
for ((i=0; i<empty; i++)); do
    progress_bar+="░"
done

# Format time
position_min=$((${position%.*} / 60))
position_sec=$((${position%.*} % 60))
length_min=$((length_sec / 60))
length_sec_display=$((length_sec % 60))

printf '{"text": "%s %02d:%02d/%02d:%02d", "tooltip": "Spotify Progress: %d%%", "class": "playing"}\n' \
    "$progress_bar" "$position_min" "$position_sec" "$length_min" "$length_sec_display" "$percentage"
