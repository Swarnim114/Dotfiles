#!/bin/bash

# Source the config file
CONFIG_FILE="$HOME/.config/swaybg/config"
if [ ! -f "$CONFIG_FILE" ]; then
    touch "$CONFIG_FILE"
fi
source "$CONFIG_FILE"

# The wallpaper directory should be defined here or in the config file.
WALLPAPER_DIR="${WALLPAPER:-/home/kalon/Pictures/Wallpaper-Collection/Wallpapers}"
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Error: Wallpaper directory not found at $WALLPAPER_DIR" >&2
    exit 1
fi

# Function to select wallpaper with preview
set_wallpaper() {
    # Check for required tools
    if ! command -v rofi >/dev/null; then
        echo "Error: rofi is not installed or not in PATH." >&2
        exit 1
    fi
    
    # Create array of image files
    mapfile -t images < <(find "$WALLPAPER_DIR" -type f \( \
        -iname "*.jpg" -o \
        -iname "*.jpeg" -o \
        -iname "*.png" -o \
        -iname "*.gif" -o \
        -iname "*.bmp" -o \
        -iname "*.webp" -o \
        -iname "*.tiff" -o \
        -iname "*.svg" \
    \) | sort)
    
    if [ ${#images[@]} -eq 0 ]; then
        echo "No images found in $WALLPAPER_DIR"
        exit 1
    fi
    
    # Create temporary files for rofi
    TEMP_LIST="/tmp/wallpaper-list-$$"
    PREVIEW_SCRIPT="/tmp/wallpaper-preview-$$"
    
    # Create the list file with just basenames for display
    for img in "${images[@]}"; do
        echo "$(basename "$img")"
    done > "$TEMP_LIST"
    
    # Create preview script
    cat > "$PREVIEW_SCRIPT" << 'EOF'
#!/bin/bash
selection="$1"
if [ -z "$selection" ]; then
    exit 0
fi

# Find the full path of the selected image
EOF
    
    # Add the images array to preview script
    echo "declare -a images=(" >> "$PREVIEW_SCRIPT"
    for img in "${images[@]}"; do
        echo "    \"$img\"" >> "$PREVIEW_SCRIPT"
    done
    echo ")" >> "$PREVIEW_SCRIPT"
    
    cat >> "$PREVIEW_SCRIPT" << 'EOF'

# Find matching image
selected_img=""
for img in "${images[@]}"; do
    if [ "$(basename "$img")" = "$selection" ]; then
        selected_img="$img"
        break
    fi
done

if [ -n "$selected_img" ] && [ -f "$selected_img" ]; then
    # Try different preview methods in order of preference
    if command -v chafa >/dev/null 2>&1; then
        # Use chafa for terminal image display
        chafa --size=40x20 --animate=off "$selected_img" 2>/dev/null
    elif command -v ueberzug >/dev/null 2>&1; then
        echo "Preview available with ueberzug"
    elif command -v feh >/dev/null 2>&1; then
        # Show image info instead of actual preview for feh
        echo "Image: $(basename "$selected_img")"
        if command -v identify >/dev/null 2>&1; then
            identify -format "Resolution: %wx%h\nFormat: %m\nSize: %b" "$selected_img" 2>/dev/null
        fi
    else
        # Fallback to basic info
        echo "Preview: $(basename "$selected_img")"
        echo "Path: $selected_img"
        if command -v file >/dev/null 2>&1; then
            file "$selected_img" | cut -d: -f2-
        fi
        if command -v du >/dev/null 2>&1; then
            echo "Size: $(du -h "$selected_img" | cut -f1)"
        fi
    fi
fi
EOF
    
    chmod +x "$PREVIEW_SCRIPT"
    
    # Show rofi with preview
    if command -v feh >/dev/null; then
        # Use feh for image selection with preview window
        selected_basename=$(echo "PREVIEW_MODE" | rofi -dmenu -p "Choose mode:" -theme-str 'window { width: 30%; }' -lines 2 -format s -mesg "Select Preview Mode or use FEH")
        
        if [ "$selected_basename" = "PREVIEW_MODE" ]; then
            # Use feh for visual selection
            echo "Opening feh for wallpaper selection..."
            echo "Use left/right arrows to browse, Enter to select, Q to quit"
            
            selected=$(feh --action1 'echo %F > /tmp/feh-selection' \
                          --action2 'echo %F > /tmp/feh-selection && feh --bg-fill %F' \
                          --auto-zoom --borderless --draw-filename \
                          --image-bg black --info "echo 'Press 1 to select, 2 to set immediately'" \
                          --title "Wallpaper Selector - Press 1 to select" \
                          "${images[@]}" 2>/dev/null || true)
            
            # Get selection from temp file
            if [ -f /tmp/feh-selection ]; then
                selected=$(cat /tmp/feh-selection)
                rm -f /tmp/feh-selection
            fi
        fi
    fi
    
    # Fallback to rofi with text preview
    if [ -z "$selected" ]; then
        selected_basename=$(rofi -dmenu -i -p "Select Wallpaper" \
                                 -input "$TEMP_LIST" \
                                 -theme-str 'window { width: 70%; height: 60%; } 
                                           listview { lines: 10; }
                                           element { padding: 6px; }' \
                                 -show-preview \
                                 -preview-command "$PREVIEW_SCRIPT {}" \
                                 -eh 2)
        
        # Find the full path
        if [ -n "$selected_basename" ]; then
            for img in "${images[@]}"; do
                if [ "$(basename "$img")" = "$selected_basename" ]; then
                    selected="$img"
                    break
                fi
            done
        fi
    fi
    
    # Clean up temp files
    rm -f "$TEMP_LIST" "$PREVIEW_SCRIPT"
    
    # Exit if no selection
    if [ -z "$selected" ] || [ ! -f "$selected" ]; then
        echo "No wallpaper selected or file not found. Exiting."
        exit 0
    fi
    
    echo "Selected wallpaper: $(basename "$selected")"
    
    # Apply wallpaper
    if command -v swaybg >/dev/null; then
        pkill swaybg 2>/dev/null || true
        swaybg -o "*" -i "$selected" -m "fill" &
        echo "✅ Wallpaper applied with swaybg"
    else
        echo "Error: swaybg is not installed or not in PATH." >&2
        exit 1
    fi

    # Generate pywal colors
    echo "Generating color scheme from wallpaper..."
    if command -v wal >/dev/null; then
        wal -i "$selected" -n
        
        if [ -f ~/.config/wal/update-colors.sh ]; then
            ~/.config/wal/update-colors.sh
            echo "Restarting waybar..."
            bash -c "pkill waybar; sleep 0.5; waybar &"
            echo "✅ Waybar restarted"
        else
            [ -f ~/.cache/wal/colors.css ] && cp ~/.cache/wal/colors.css ~/.config/wal/
            [ -f ~/.cache/wal/colors.rasi ] && cp ~/.cache/wal/colors.rasi ~/.config/wal/
            [ -f ~/.cache/wal/colors-hyprland.conf ] && cp ~/.cache/wal/colors-hyprland.conf ~/.config/wal/
            
            if command -v waybar >/dev/null && pgrep waybar >/dev/null; then
                echo "Reloading waybar..."
                pkill waybar
                waybar &
            fi
        fi
        echo "✅ Color scheme updated!"
    else
        echo "Warning: pywal (wal) is not installed."
    fi

    # Update autostart configuration
    AUTOSTART_CONF="$HOME/.config/hypr/config/autostart.conf"
    NEW_WALLPAPER_LINE="exec-once = swaybg -o \"*\" -i \"$selected\" -m fill"

    if [ -f "$AUTOSTART_CONF" ]; then
        sed -i "/^exec-once = swaybg/c\\$NEW_WALLPAPER_LINE" "$AUTOSTART_CONF"
    else
        echo "Warning: Autostart file not found at $AUTOSTART_CONF"
    fi

    # Save to config
    CURRENT_FILE=$(basename "$selected")
    sed -i "s|^WALLPAPER=.*|WALLPAPER=\"$WALLPAPER_DIR\"|g" "$CONFIG_FILE"
    sed -i "s|^CURRENT_FILE=.*|CURRENT_FILE=\"$CURRENT_FILE\"|g" "$CONFIG_FILE" 2>/dev/null || echo "CURRENT_FILE=\"$CURRENT_FILE\"" >> "$CONFIG_FILE"
}

# Run the wallpaper selector
set_wallpaper
