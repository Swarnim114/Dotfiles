#!/bin/bash

# Waybar Restart Helper
# This script ensures waybar starts with proper environment

# Kill existing waybar
pkill waybar 2>/dev/null || true
sleep 1

# Start waybar with full environment
if [ -n "$WAYLAND_DISPLAY" ]; then
    # We have a Wayland display, start normally
    waybar &
elif [ -n "$DISPLAY" ]; then
    # X11 display, start with DISPLAY
    DISPLAY="$DISPLAY" waybar &
else
    # No display found, try to find it
    for display in /tmp/.X11-unix/X*; do
        if [ -e "$display" ]; then
            display_num="${display#/tmp/.X11-unix/X}"
            DISPLAY=":$display_num" waybar &
            break
        fi
    done
    
    # If still no luck, try Wayland
    if ! pgrep waybar >/dev/null; then
        # Try common Wayland display names
        for wd in wayland-0 wayland-1; do
            if [ -e "/run/user/$(id -u)/$wd" ]; then
                WAYLAND_DISPLAY="$wd" waybar &
                break
            fi
        done
    fi
fi

# Check if waybar started
sleep 2
if pgrep waybar >/dev/null; then
    echo "✅ Waybar started successfully"
else
    echo "❌ Failed to start waybar"
    exit 1
fi
