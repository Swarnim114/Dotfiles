#!/bin/bash
# ~/.config/rofi/scripts/rofi-powermenu.sh

# --- Load Configuration ---
CONFIG_FILE="$HOME/.config/rofi/power-menu-config"

if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    # Fallback default configuration if the file doesn't exist
    POWER_OPTIONS=("Power Off" "Restart" "Suspend" "Lock" "Log Out")
    CONFIRMATION_ENABLED="true"
    ROFI_THEME_FILE="" # No theme file by default
    ROFI_THEME_WINDOW='window { width: 300px; }'
    ROFI_THEME_LISTVIEW='listview { lines: 5; }'
    ROFI_THEME_INPUT='entry { placeholder: "Power"; }'
fi

# --- Helper Functions ---
# Function to show a confirmation dialog
confirm() {
    local prompt="$1"
    local rofi_cmd=(rofi -dmenu -i -p "${prompt}?")

    # Use the theme file if it exists, otherwise use theme strings
    if [[ -f "$ROFI_THEME_FILE" ]]; then
        rofi_cmd+=(-theme "$ROFI_THEME_FILE" -theme-str 'listview { lines: 2; }')
    else
        rofi_cmd+=(-theme-str 'window { width: 300px; }' -theme-str 'listview { lines: 2; }')
    fi

    answer=$(echo -e "Yes\nNo" | "${rofi_cmd[@]}")

    if [[ "$answer" == "Yes" ]]; then
        return 0 # Success (user confirmed)
    else
        return 1 # Failure (user cancelled)
    fi
}

# --- Main Logic ---
# Dynamically adjust listview lines based on the number of options
option_count=${#POWER_OPTIONS[@]}
ROFI_THEME_LISTVIEW="listview { lines: ${option_count}; }"

# Build the Rofi command
rofi_command=(rofi -dmenu -i -p "Power")

if [[ -f "$ROFI_THEME_FILE" ]]; then
    rofi_command+=(-theme "$ROFI_THEME_FILE")
else
    # If no theme file, use the fallback overrides
    rofi_command+=(-theme-str "$ROFI_THEME_WINDOW" -theme-str "$ROFI_THEME_LISTVIEW" -theme-str "$ROFI_THEME_INPUT")
fi

# Show the menu and get the user's choice
chosen=$(printf '%s\n' "${POWER_OPTIONS[@]}" | "${rofi_command[@]}")

# If the user pressed Esc or chose nothing, exit
if [[ -z "$chosen" ]]; then
    exit 0
fi

# Execute the chosen action
case "$chosen" in
    *"Power Off")
        if [[ "$CONFIRMATION_ENABLED" == "true" ]]; then
            confirm "Power Off" && systemctl poweroff
        else
            systemctl poweroff
        fi
        ;;
    *"Restart")
        if [[ "$CONFIRMATION_ENABLED" == "true" ]]; then
            confirm "Restart" && systemctl reboot
        else
            systemctl reboot
        fi
        ;;
    *"Log Out")
        if [[ "$CONFIRMATION_ENABLED" == "true" ]]; then
            confirm "Log Out" && hyprctl dispatch exit
        else
            hyprctl dispatch exit
        fi
        ;;
    *"Suspend")
        # No confirmation for non-destructive actions
        systemctl suspend
        ;;
    *"Lock")
        # No confirmation for non-destructive actions
        hyprlock
        ;;
esac
