#!/usr/bin/env bash

STATE_FILE="/tmp/hypr_focus_mode"

toggle_bar() {
    qs -c noctalia-shell ipc call bar toggle >/dev/null 2>&1 || true
}

if [[ -f "$STATE_FILE" ]]; then
    # --- disable focus mode ---
    hyprctl keyword general:gaps_in 6
    hyprctl keyword general:gaps_out 8
    hyprctl keyword general:border_size 3
    hyprctl keyword decoration:rounding 0
    hyprctl keyword decoration:shadow:enabled true

    toggle_bar
    rm -f "$STATE_FILE"
else
    # --- enable focus mode ---
    hyprctl keyword general:gaps_in 0
    hyprctl keyword general:gaps_out 0
    hyprctl keyword general:border_size 1
    hyprctl keyword decoration:shadow:enabled false

    toggle_bar
    touch "$STATE_FILE"
fi
