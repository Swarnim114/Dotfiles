#!/usr/bin/env bash
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃              Reading Mode - Configuration                   ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
# Centralized configuration for reading mode
# Following Single Responsibility Principle

# ======= Paths =======
export READING_MODE_SHADER_PATH="$HOME/.config/hypr/shaders/reading_mode/grayscale.glsl"
export READING_MODE_STATE_DIR="$HOME/.cache/hypr/reading-mode"
export READING_MODE_STATE_FILE="$READING_MODE_STATE_DIR/active"
export READING_MODE_THEME_BACKUP="$READING_MODE_STATE_DIR/previous_theme"

# Wallpapers
export READING_MODE_WALLPAPER="$HOME/Pictures/desktop/WP/6.jpg"
export READING_MODE_DEFAULT_WALLPAPER="$HOME/Pictures/desktop/l2.png"

# ======= Brightness Levels =======
export READING_MODE_BRIGHTNESS=37
export READING_MODE_DEFAULT_BRIGHTNESS=60

# ======= Theme Integration =======
# Noctalia shell theme commands
export READING_MODE_THEME_LIGHT="qs -c noctalia-shell ipc call darkMode light"
export READING_MODE_THEME_DARK="qs -c noctalia-shell ipc call darkMode dark"
export READING_MODE_THEME_TOGGLE="qs -c noctalia-shell ipc call darkMode toggle"

# ======= Initialization =======
# Ensure state directory exists
mkdir -p "$READING_MODE_STATE_DIR"
