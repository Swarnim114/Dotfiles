#!/bin/bash

# Use the absolute path if 'which powerprofilesctl' doesn't consistently work
# or if you prefer explicit paths. You can find it with 'which powerprofilesctl'.
POWER_PROFILES_CTL="/usr/bin/powerprofilesctl" # <-- Verify this path for your system!

current_profile=$($POWER_PROFILES_CTL get)

# This part is for toggling the profile when the script is called with 'toggle'
if [[ "$1" == "toggle" ]]; then
    case "$current_profile" in
        "performance")
            $POWER_PROFILES_CTL set power-saver
            ;;
        "power-saver")
            $POWER_PROFILES_CTL set balanced
            ;;
        "balanced")
            $POWER_PROFILES_CTL set performance
            ;;
        *)
            # Fallback for unknown state, default to balanced
            $POWER_PROFILES_CTL set balanced
            ;;
    esac
    exit 0 # Exit after toggling
fi

# This part is for getting the current profile and formatting it for Waybar
# when the script is called with 'get' (or no argument, if you remove the 'if' for toggle)

icon=""
case "$current_profile" in
    "performance")
        icon="⚡" # Lightning bolt for performance
        ;;
    "balanced")
        icon="⚖"  # Scales for balanced
        ;;
    "power-saver")
        icon="🔋"  # Battery for power saver
        ;;
    *)
        icon="?" # Default icon if profile is unknown
        ;;
esac

# Output JSON for Waybar's custom module
echo "{\"text\": \"$current_profile\", \"tooltip\": \"Power Profile: $current_profile\", \"alt\": \"$current_profile\", \"class\": \"$current_profile\", \"icon\": \"$icon\"}"

exit 0 # Exit after providing output