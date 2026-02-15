#!/usr/bin/env bash
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃              Reading Mode - System Configurator             ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
# Single Responsibility: Apply/restore Hyprland system settings
# Handles: e-ink visual overrides, settings backup/restore

# Source configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# ======= E-ink Settings Application =======

# Apply all e-ink visual settings to simulate e-ink display
# Uses hyprctl batch for efficiency
apply_eink_settings() {
    # Build batch command for all settings
    # Keeping this empty as user requested only grayscale shader
    # We maintain the function structure for future extensibility
    local batch_commands=(
    )
    
    # Only run if there are commands
    if [ ${#batch_commands[@]} -gt 0 ]; then
        local batch_cmd=$(IFS=';'; echo "${batch_commands[*]}")
        hyprctl --batch "$batch_cmd" &>/dev/null
    fi
    
    return 0
}

# Restore default Hyprland settings
# Reloads Hyprland config to restore all original values
restore_default_settings() {
    # No settings to restore since we didn't change layout
    return 0
}

# ======= Individual Setting Functions =======
# These can be used for fine-grained control if needed

disable_animations() {
    hyprctl keyword animations:enabled 0 &>/dev/null
}

enable_animations() {
    hyprctl keyword animations:enabled 1 &>/dev/null
}

set_minimal_borders() {
    hyprctl --batch "keyword general:border_size 2; keyword general:col.active_border rgba(000000ff); keyword general:col.inactive_border rgba(000000ff)" &>/dev/null
}

remove_gaps() {
    hyprctl --batch "keyword general:gaps_in 0; keyword general:gaps_out 0" &>/dev/null
}

disable_effects() {
    hyprctl --batch "keyword decoration:drop_shadow 0; keyword decoration:blur:enabled 0; keyword decoration:rounding 0" &>/dev/null
}
