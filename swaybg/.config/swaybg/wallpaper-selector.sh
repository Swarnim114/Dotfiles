#!/bin/bash

# Source the config file
CONFIG_FILE="$HOME/.config/swaybg/config"
if [ ! -f "$CONFIG_FILE" ]; then
    touch "$CONFIG_FILE"
fi
source "$CONFIG_FILE"

# The wallpaper directory should be defined here or in the config file.
# Exit if the directory doesn't exist.
WALLPAPER_DIR="${WALLPAPER:-/home/kalon/Pictures/Wallpaper-Collection/Wallpapers}"
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Error: Wallpaper directory not found at $WALLPAPER_DIR" >&2
    exit 1
fi

# --- Utility Functions ---
# Function to select wallpaper and apply it
set_wallpaper() {
    # Create a temporary directory for symlinks
    TEMP_DIR="/tmp/wallpaper-selector-$$"
    mkdir -p "$TEMP_DIR"
    
    # Find all images and create symlinks. This block is corrected.
    find "$WALLPAPER_DIR" -type f \( \
        -iname "*.jpg" -o \
        -iname "*.jpeg" -o \
        -iname "*.png" -o \
        -iname "*.gif" -o \
        -iname "*.bmp" -o \
        -iname "*.webp" -o \
        -iname "*.tiff" -o \
        -iname "*.svg" \
    \) -exec sh -c '
        for img; do
            ln -sf "$img" "'"$TEMP_DIR"'/$(basename "$img")"
        done
    ' sh {} +
    
    # Check for rofi installation before running
    if ! command -v rofi >/dev/null; then
        echo "Error: rofi is not installed or not in PATH." >&2
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    # Show rofi with previews
    selected_name=$(cd "$TEMP_DIR" && \
    find . -maxdepth 1 -type l -printf "%P\n" | \
    rofi -dmenu -i -p "Select Wallpaper" \
         -theme-str 'configuration { show-icons: true; } 
                    window { width: 35%; }
                    listview { lines: 8; spacing: 0.3em; }
                    element { padding: 4px; }
                    element-icon { size: 64px; }
                    element-text { vertical-align: 0.5; }' \
         -theme-str 'entry { placeholder: "Type to filter..."; }')
         
    selected=""
    if [ -n "$selected_name" ]; then
        selected=$(readlink -f "$TEMP_DIR/$selected_name")
    fi
    
    # Clean up temp directory
    rm -rf "$TEMP_DIR"
    
    # Exit gracefully if no wallpaper was selected
    if [ -z "$selected" ]; then
        echo "No wallpaper selected. Exiting."
        exit 0
    fi
    
    # Use swaybg for immediate application
    if command -v swaybg >/dev/null; then
        pkill swaybg
        swaybg -o "*" -i "$selected" -m "fill" &
    else
        echo "Error: swaybg is not installed or not in PATH." >&2
        exit 1
    fi

    # Define the autostart file path
    AUTOSTART_CONF="$HOME/.config/hypr/config/autostart.conf"
    
    # Define the new autostart command for swaybg
    NEW_WALLPAPER_LINE="exec-once = swaybg -o \"*\" -i \"$selected\" -m fill"

    # Check if the file exists and update the swaybg line
    if [ -f "$AUTOSTART_CONF" ]; then
        # Use sed to replace any existing swaybg line
        sed -i "/^exec-once = swaybg/c\\$NEW_WALLPAPER_LINE" "$AUTOSTART_CONF"
    else
        echo "Warning: Autostart file not found at $AUTOSTART_CONF. Settings will not be saved."
    fi

    # Save settings to config for next script run
    CURRENT_FILE=$(basename "$selected")
    sed -i "s|^WALLPAPER=.*|WALLPAPER=\"$WALLPAPER_DIR\"|g" "$CONFIG_FILE"
    sed -i "s|^CURRENT_FILE=.*|CURRENT_FILE=\"$CURRENT_FILE\"|g" "$CONFIG_FILE" 2>/dev/null || echo "CURRENT_FILE=\"$CURRENT_FILE\"" >> "$CONFIG_FILE"
}

# Just run the wallpaper selector directly
set_wallpaper