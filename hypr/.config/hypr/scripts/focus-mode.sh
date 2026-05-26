#!/usr/bin/env bash

STATE_FILE="/tmp/hypr_focus_mode"

# Debug helper function
log_debug() {
    echo -e "[DEBUG] $(date '+%H:%M:%S') - $1" >&2
}

toggle_bar() {
    log_debug "Toggling Noctalia bar state..."
    if noctalia msg bar-toggle; then
        log_debug "Noctalia bar toggled successfully."
    else
        log_debug "ERROR: Failed to communicate with Noctalia."
    fi
}

log_debug "Starting Hyprland focus mode script."

if [[ -f "$STATE_FILE" ]]; then
    log_debug "State file found. Disabling focus mode (Restoring layout)..."

    hyprctl eval "hl.config({general = {gaps_in = _G.normal_gaps_in, gaps_out = _G.normal_gaps_out, border_size = _G.normal_border_size}, decoration = {rounding = _G.normal_rounding, shadow = {enabled = _G.normal_shadow}}}) hl.workspace_rule({workspace = 'w[tv1]', border_size = _G.normal_border_size})"

    toggle_bar
    rm -f "$STATE_FILE"
    log_debug "State file removed. Focus mode disabled."
else
    log_debug "No state file found. Enabling focus mode..."

    hyprctl eval "hl.config({general = {gaps_in = _G.focus_gaps_in, gaps_out = _G.focus_gaps_out, border_size = _G.focus_border_size}, decoration = {shadow = {enabled = _G.focus_shadow}}}) hl.workspace_rule({workspace = 'w[tv1]', border_size = 0})"

    toggle_bar
    touch "$STATE_FILE"
    log_debug "State file created at $STATE_FILE. Focus mode active."
fi

log_debug "Script execution completed."