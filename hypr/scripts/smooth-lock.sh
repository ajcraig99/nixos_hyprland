#!/usr/bin/env bash

# Get current brightness
CURRENT_BRIGHTNESS=$(ddcutil getvcp 10 --terse | cut -d' ' -f4)

# Set to hardware minimum
ddcutil setvcp 10 0

# Wait 3 seconds at minimum brightness
sleep 3

# Lock and suspend after 10 seconds delay
swaylock -f &
sleep 10  # Give yourself 10 seconds to unlock if needed
systemctl suspend

# Restore brightness when we wake up
ddcutil setvcp 10 $CURRENT_BRIGHTNESS
