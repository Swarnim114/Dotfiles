#!/bin/bash
# Script to restart waybar for hypridle

# Kill waybar
pkill -x waybar

# Start waybar in a new session
setsid waybar >/dev/null 2>&1 &
