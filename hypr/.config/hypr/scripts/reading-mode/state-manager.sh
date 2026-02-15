#!/usr/bin/env bash
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃              Reading Mode - State Manager                   ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
# Single Responsibility: Manage reading mode state persistence
# Handles: state queries, theme backup/restore, state cleanup

# Source configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# ======= State Query Functions =======

# Check if reading mode is currently active
# Returns: 0 if active, 1 if inactive
is_reading_mode_active() {
    [[ -f "$READING_MODE_STATE_FILE" ]]
}

# ======= Theme State Management =======

# Save the current theme before activating reading mode
# Args: $1 - theme name (e.g., "dark", "light")
save_previous_theme() {
    local theme="${1:-dark}"
    echo "$theme" > "$READING_MODE_THEME_BACKUP"
}

# Get the previously saved theme
# Returns: theme name, or "dark" as fallback
get_previous_theme() {
    if [[ -f "$READING_MODE_THEME_BACKUP" ]]; then
        cat "$READING_MODE_THEME_BACKUP"
    else
        echo "dark"  # Safe fallback
    fi
}

# Detect current theme from noctalia cache
# Returns: "dark" or "light"
detect_current_theme() {
    local theme_cache="$HOME/.cache/quickshell/theme_mode"
    
    if [[ -f "$theme_cache" ]]; then
        local theme=$(cat "$theme_cache" | tr -d '[:space:]')
        echo "${theme:-dark}"
    else
        echo "dark"  # Default fallback
    fi
}

# ======= State Activation/Deactivation =======

# Mark reading mode as active
activate_state() {
    touch "$READING_MODE_STATE_FILE"
}

# Clear reading mode state
deactivate_state() {
    rm -f "$READING_MODE_STATE_FILE"
    rm -f "$READING_MODE_THEME_BACKUP"
}

# ======= Utility Functions =======

# Clean up all state files (for troubleshooting)
clear_all_state() {
    rm -rf "$READING_MODE_STATE_DIR"
    mkdir -p "$READING_MODE_STATE_DIR"
}
