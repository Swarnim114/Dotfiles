#!/usr/bin/env bash

set -euo pipefail

STATE_DIR="$HOME/.cache/hypr/focus-mode"
STATE_FILE="$STATE_DIR/active"

mkdir -p "$STATE_DIR"

toggle_bar() {
    qs -c noctalia-shell ipc call bar toggle >/dev/null 2>&1 || true
}

enable_focus_mode() {
    toggle_bar
    hyprctl --batch "keyword general:gaps_in 0; keyword general:gaps_out 0; keyword general:border_size 0" >/dev/null 2>&1
    touch "$STATE_FILE"
}

disable_focus_mode() {
    toggle_bar
    hyprctl --batch "keyword general:gaps_in 6; keyword general:gaps_out 10; keyword general:border_size 3" >/dev/null 2>&1
    rm -f "$STATE_FILE"
}

if [[ -f "$STATE_FILE" ]]; then
    disable_focus_mode
else
    enable_focus_mode
fi