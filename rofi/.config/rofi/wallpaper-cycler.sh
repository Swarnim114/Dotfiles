#!/bin/bash

# Cycles through the background images available

BACKGROUNDS_DIR="$HOME/.config/themes/current/backgrounds/"
CURRENT_BACKGROUND_LINK="$HOME/.config/themes/current/wallpaper"

# Get all background files using null-delimited mapfile for better handling of filenames with spaces
mapfile -d '' -t BACKGROUNDS < <(find "$BACKGROUNDS_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) -print0 | sort -z)
TOTAL=${#BACKGROUNDS[@]}

if [[ $TOTAL -eq 0 ]]; then
    notify-send "Wallpaper Cycler" "No backgrounds found in current theme!" -t 2000
    pkill -x swaybg
    swaybg --color '#000000' >/dev/null 2>&1 &
else
    # Get current background from symlink
    if [[ -L "$CURRENT_BACKGROUND_LINK" ]]; then
        CURRENT_BACKGROUND=$(readlink "$CURRENT_BACKGROUND_LINK")
    else
        # Default to empty if no symlink exists
        CURRENT_BACKGROUND=""
    fi

    # Find current background index
    INDEX=-1
    for i in "${!BACKGROUNDS[@]}"; do
        if [[ "${BACKGROUNDS[$i]}" == "$CURRENT_BACKGROUND" ]]; then
            INDEX=$i
            break
        fi
    done

    # Get next background (wrap around)
    if [[ $INDEX -eq -1 ]]; then
        # Use the first background when no match was found
        NEW_BACKGROUND="${BACKGROUNDS[0]}"
        NEXT_INDEX=0
    else
        NEXT_INDEX=$(((INDEX + 1) % TOTAL))
        NEW_BACKGROUND="${BACKGROUNDS[$NEXT_INDEX]}"
    fi

    # Set new background symlink
    ln -nsf "$NEW_BACKGROUND" "$CURRENT_BACKGROUND_LINK"

    # Get wallpaper name for notification
    wallpaper_name=$(basename "$NEW_BACKGROUND")

    # Check if swww is available for smooth transitions
    if command -v swww >/dev/null 2>&1; then
        # Use swww for animated transitions
        if ! pgrep -x swww-daemon >/dev/null; then
            swww-daemon &
            sleep 1
        fi
        
        # Get cursor position
        CURSOR_POS=$(hyprctl cursorpos | tr -d ' ')
        
        # Smooth animated transition with swww - circle from cursor
        swww img "$NEW_BACKGROUND" \
            --transition-type grow \
            --transition-duration 0.4 \
            --transition-fps 60 \
            --transition-pos "$CURSOR_POS" \
            >/dev/null 2>&1
    else
        # Enhanced swaybg approach with better preloading
        (
            # Pre-load the image by creating a temporary swaybg process
            # This helps reduce loading time for high-quality images
            swaybg -i "$NEW_BACKGROUND" -m fill >/dev/null 2>&1 &
            PRELOAD_PID=$!
            
            # Give more time for high-quality images to load
            sleep 0.5
            
            # Now start the actual transition
            swaybg -i "$NEW_BACKGROUND" -m fill >/dev/null 2>&1 &
            NEW_PID=$!
            
            # Wait for the new wallpaper to fully load and display
            sleep 0.8
            
            # Kill all old swaybg processes
            for pid in $(pgrep -x swaybg); do
                if [ "$pid" != "$NEW_PID" ]; then
                    kill "$pid" 2>/dev/null
                fi
            done
            
            # Clean up preload process
            kill "$PRELOAD_PID" 2>/dev/null
            
            # Final safety check
            if ! kill -0 "$NEW_PID" 2>/dev/null; then
                exec swaybg -i "$NEW_BACKGROUND" -m fill >/dev/null 2>&1
            fi
        ) &
    fi

    # Notify user
    #notify-send "Wallpaper Cycler" "Changed to: $wallpaper_name ($((NEXT_INDEX + 1))/$TOTAL)" -t 2000
fi
