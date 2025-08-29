#!/bin/bash

# Script to ensure wallpaper loads properly on startup

# Wait for swww daemon to be ready
counter=0
while ! pgrep -x swww-daemon > /dev/null && [ $counter -lt 10 ]; do
    sleep 1
    counter=$((counter + 1))
done

if ! pgrep -x swww-daemon > /dev/null; then
    echo "swww daemon failed to start"
    exit 1
fi

# Give it a bit more time to initialize
sleep 1

# Load the wallpaper
WALLPAPER_LINK="$HOME/.config/themes/current/background"

if [ -L "$WALLPAPER_LINK" ] && [ -f "$(readlink "$WALLPAPER_LINK")" ]; then
    echo "Loading wallpaper: $(readlink "$WALLPAPER_LINK")"
    swww img "$WALLPAPER_LINK" --transition-type fade --transition-duration 1.0
else
    echo "No wallpaper found, using solid color"
    swww img --color "#1a1b26"
fi
