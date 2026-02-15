#!/usr/bin/env bash
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃              Reading Mode - Shader Controller               ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
# Single Responsibility: Control shader activation/deactivation
# Abstracts hyprshade commands for shader management

# Source configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# ======= Shader Control Functions =======

# Activate the e-ink grayscale shader
# Returns: 0 on success, 1 on failure
activate_shader() {
    if [[ ! -f "$READING_MODE_SHADER_PATH" ]]; then
        echo "Error: Shader file not found at $READING_MODE_SHADER_PATH" >&2
        return 1
    fi
    
    hyprctl keyword decoration:screen_shader "$READING_MODE_SHADER_PATH" &>/dev/null
    return $?
}

# Deactivate the current shader
# Returns: 0 on success
deactivate_shader() {
    hyprctl keyword decoration:screen_shader "[[EMPTY]]" &>/dev/null
    return 0
}

# Get the currently active shader
# Returns: shader path or "none"
get_current_shader() {
    local shader_info=$(hyprctl getoption decoration:screen_shader -j 2>/dev/null)
    
    if [[ -n "$shader_info" ]]; then
        echo "$shader_info" | grep -oP '(?<="str": ")[^"]*' || echo "none"
    else
        echo "none"
    fi
}

# Check if reading mode shader is currently active
# Returns: 0 if active, 1 if not
is_shader_active() {
    local current=$(get_current_shader)
    [[ "$current" == "$READING_MODE_SHADER_PATH" ]]
}
