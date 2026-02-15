#!/usr/bin/env bash
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃              Reading Mode - Main Orchestrator               ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
# Main entry point for reading mode toggle
# Follows Dependency Inversion Principle - depends on module interfaces

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all modules
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/state-manager.sh"
source "$SCRIPT_DIR/shader-controller.sh"
source "$SCRIPT_DIR/theme-manager.sh"
source "$SCRIPT_DIR/system-configurator.sh"

# ======= Main Toggle Logic =======

toggle_reading_mode() {
    if is_reading_mode_active; then
        # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        # DEACTIVATE: Turn OFF reading mode
        # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        
        # Get saved theme before clearing state
        local previous_theme=$(get_previous_theme)
        
        # Deactivate shader
        deactivate_shader
        
        # Restore visual environment
        restore_default_environment "$previous_theme"
        
        # Restore Hyprland settings
        restore_default_settings
        
        # Clear state
        deactivate_state
        
        echo "Reading mode deactivated"
        
    else
        # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        # ACTIVATE: Turn ON reading mode
        # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        
        # Detect and save current theme
        local current_theme=$(detect_current_theme)
        save_previous_theme "$current_theme"
        
        # Activate shader
        if ! activate_shader; then
            echo "Error: Failed to activate shader" >&2
            return 1
        fi
        
        # Apply reading environment (theme, wallpaper, brightness)
        apply_reading_environment
        
        # Apply e-ink system settings
        apply_eink_settings
        
        # Mark as active
        activate_state
        
        echo "Reading mode activated"
    fi
}

# ======= Entry Point =======

# Run the toggle
toggle_reading_mode

exit $?
