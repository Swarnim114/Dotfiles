#!/usr/bin/env bash
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃              Reading Mode - Theme Manager                   ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
# Single Responsibility: Manage theme and visual environment
# Handles: theme switching, wallpaper changes, brightness adjustments

# Source configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# ======= Theme Control Functions =======

# Switch to light theme for reading mode
switch_to_light_theme() {
    # Switch to light theme
    eval "$READING_MODE_THEME_LIGHT" &>/dev/null
    
    return 0
}

# Restore the previously saved theme
# Args: $1 - theme name (optional, will read from backup if not provided)
restore_theme() {
    local theme="${1}"
    
    # If no theme provided, get from backup
    if [[ -z "$theme" ]]; then
        source "$SCRIPT_DIR/state-manager.sh"
        theme=$(get_previous_theme)
    fi
    
    # Apply the theme
    if [[ "$theme" == "light" ]]; then
        eval "$READING_MODE_THEME_LIGHT" &>/dev/null
    else
        eval "$READING_MODE_THEME_DARK" &>/dev/null
    fi
    
    return 0
}

# ======= Wallpaper Control Functions =======

# Set reading-friendly wallpaper
set_reading_wallpaper() {
    if [[ -f "$READING_MODE_WALLPAPER" ]]; then
        swww img "$READING_MODE_WALLPAPER" --transition-type none &>/dev/null &
    fi
}

# Restore default wallpaper
restore_wallpaper() {
    if [[ -f "$READING_MODE_DEFAULT_WALLPAPER" ]]; then
        swww img "$READING_MODE_DEFAULT_WALLPAPER" --transition-type none &>/dev/null &
    fi
}

# ======= Brightness Control Functions =======

# Set brightness level
# Args: $1 - brightness percentage (0-100)
set_brightness() {
    local level="${1:-$READING_MODE_BRIGHTNESS}"
    
    if command -v brightnessctl &>/dev/null; then
        brightnessctl set "${level}%" &>/dev/null &
    fi
}

# Set reading mode brightness
set_reading_brightness() {
    set_brightness "$READING_MODE_BRIGHTNESS"
}

# Restore default brightness
restore_brightness() {
    set_brightness "$READING_MODE_DEFAULT_BRIGHTNESS"
}

# ======= Combined Functions =======

# Apply all reading mode visual changes
apply_reading_environment() {
    switch_to_light_theme
    set_reading_wallpaper
    set_reading_brightness
}

# Restore all default visual settings
restore_default_environment() {
    local previous_theme="${1}"
    restore_theme "$previous_theme"
    restore_wallpaper
    restore_brightness
}
