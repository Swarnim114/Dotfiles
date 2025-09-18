#!/bin/bash
if pgrep -x waybar > /dev/null
then
    # If Waybar is running, send the toggle signal
    pkill -SIGUSR1 waybar
else
    # If Waybar is not running, launch it
    waybar &
fi
