#!/bin/bash

# Use tuned-ppd via D-Bus interface (compatible with power-profiles-daemon)

# Get current power profile
current_profile=$(busctl get-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile | cut -d'"' -f2)

# This part is for toggling the profile when the script is called with 'toggle'
if [[ "$1" == "toggle" ]]; then
    case "$current_profile" in
        "performance")
            if busctl set-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile s "power-saver" 2>/dev/null; then
                notify-send "Power Profile" "Switched to Power Saver 🔋" -i battery-low
            else
                notify-send "Power Profile Error" "Failed to switch to Power Saver" -i dialog-error -u critical
            fi
            ;;
        "power-saver")
            if busctl set-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile s "balanced" 2>/dev/null; then
                notify-send "Power Profile" "Switched to Balanced ⚖" -i battery-good
            else
                notify-send "Power Profile Error" "Failed to switch to Balanced" -i dialog-error -u critical
            fi
            ;;
        "balanced")
            if busctl set-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile s "performance" 2>/dev/null; then
                notify-send "Power Profile" "Switched to Performance ⚡" -i battery-full-charging
            else
                notify-send "Power Profile Error" "Failed to switch to Performance" -i dialog-error -u critical
            fi
            ;;
        *)
            # Fallback for unknown state, default to balanced
            if busctl set-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile s "balanced" 2>/dev/null; then
                notify-send "Power Profile" "Switched to Balanced ⚖ (fallback)" -i battery-good
            else
                notify-send "Power Profile Error" "Failed to switch to Balanced (fallback)" -i dialog-error -u critical
            fi
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