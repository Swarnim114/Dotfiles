#!/bin/bash
# ~/.config/rofi/scripts/rofi-theme-selector.sh

# --- Load Configuration ---
CONFIG_FILE="$HOME/.config/rofi/theme-selector-config"

if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    # Fallback configuration if the file doesn't exist
    THEMES_DIR="$HOME/.config/themes"
    CURRENT_THEME_DIR_NAME="current"
    RELOAD_WAYBAR="true"
    RELOAD_MAKO="true"
    RELOAD_HYPRLAND="true"
    SET_GTK_THEME="true"
    GTK_LIGHT_THEME_NAME="WhiteSur-Light"
    GTK_DARK_THEME_NAME="WhiteSur-Dark"
    ROFI_THEME_FILE="" # No theme file by default
    ROFI_THEME_WINDOW='window { width: 250px; }'
    ROFI_THEME_LISTVIEW='listview { lines: 10; }'
    ROFI_THEME_INPUT='entry { placeholder: "Select Theme"; }'
fi

# --- Main Logic ---
CURRENT_DIR="$THEMES_DIR/$CURRENT_THEME_DIR_NAME"

# Get a list of theme directories, excluding the 'current' directory.
themes=$(ls -d "$THEMES_DIR"/*/ | xargs -n 1 basename | grep -v "$CURRENT_THEME_DIR_NAME")

# Build the Rofi command with theme handling
rofi_command=(rofi -dmenu -i -p "Theme")

if [[ -f "$ROFI_THEME_FILE" ]]; then
    rofi_command+=(-theme "$ROFI_THEME_FILE")
else
    # If no theme file, use the fallback overrides from the config
    rofi_command+=(-theme-str "$ROFI_THEME_WINDOW" -theme-str "$ROFI_THEME_LISTVIEW" -theme-str "$ROFI_THEME_INPUT")
fi

# Show the menu and get the user's choice
selected_theme=$(echo "$themes" | "${rofi_command[@]}")

# Exit if no theme was selected
if [[ -z "$selected_theme" ]]; then
    exit 0
fi

# --- Apply the Theme ---
SELECTED_THEME_DIR="$THEMES_DIR/$selected_theme"

# Clean and copy theme files
rm -rf "$CURRENT_DIR"/*
cp -r "$SELECTED_THEME_DIR"/* "$CURRENT_DIR/"

# Mako needs its config file copied to its default location to be reloaded.
if [[ -f "$CURRENT_DIR/mako.ini" ]]; then
    cp "$CURRENT_DIR/mako.ini" "$HOME/.config/mako/config"
fi

# --- Set Wallpaper ---
wallpaper=$(find "$CURRENT_DIR/backgrounds" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | sort | head -n 1)
if [[ -n "$wallpaper" && -f "$wallpaper" ]]; then
    # Create the wallpaper symlink for persistence
    ln -nsf "$wallpaper" "$CURRENT_DIR/background"
    # Set the wallpaper with swww
    swww img "$wallpaper" --transition-type grow --transition-duration 1.0
    echo "✓ Wallpaper set: $(basename "$wallpaper")"
else
    echo "⚠ No wallpaper found in theme backgrounds"
    # Use solid color fallback
    swww img --color '#1a1b26'
fi

# --- Reload Components (based on config) ---
if [[ "$RELOAD_WAYBAR" == "true" ]]; then
    pkill waybar
    sleep 0.5
    waybar &
    echo "✓ Waybar reloaded"
fi
if [[ "$RELOAD_MAKO" == "true" ]]; then
    makoctl reload
    echo "✓ Mako reloaded"
fi
if [[ "$RELOAD_HYPRLAND" == "true" ]]; then
    hyprctl reload
    echo "✓ Hyprland config reloaded"
fi

# --- Set GTK/Flatpak Theme (based on config) ---
if [[ "$SET_GTK_THEME" == "true" ]]; then
    if [[ -f "$CURRENT_DIR/light.mode" ]]; then
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
        gsettings set org.gnome.desktop.interface gtk-theme "$GTK_LIGHT_THEME_NAME"
        flatpak override --user --env=GTK_THEME="$GTK_LIGHT_THEME_NAME"
    else
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
        gsettings set org.gnome.desktop.interface gtk-theme "$GTK_DARK_THEME_NAME"
        flatpak override --user --env=GTK_THEME="$GTK_DARK_THEME_NAME"
    fi
fi


# --- Reload Kitty Colors ---
kitty @ set-colors --all ~/.config/themes/current/kitty.conf




echo "Theme switch to '$selected_theme' complete!"
