#!/bin/bash

# Check for official Arch repository updates
UPDATES=$(checkupdates 2>/dev/null | wc -l)

# Check for AUR updates using yay (or paru if you use it)
# Make sure yay (or paru) is installed: yay -S yay
if command -v yay &> /dev/null; then
    AUR_UPDATES=$(yay -Qu 2>/dev/null | wc -l)
elif command -v paru &> /dev/null; then
    AUR_UPDATES=$(paru -Qu 2>/dev/null | wc -l)
else
    AUR_UPDATES=0
fi

TOTAL_UPDATES=$((UPDATES + AUR_UPDATES))

if [ "$TOTAL_UPDATES" -gt 0 ]; then
    echo "$TOTAL_UPDATES"
    # Optional: If you want to change color in Waybar based on updates
    # echo "{\"text\": \"$TOTAL_UPDATES\", \"class\": \"has-updates\"}"
else
    echo "0"
    # echo "{\"text\": \"0\", \"class\": \"no-updates\"}"
fi