#!/bin/bash

# Rofi Clipboard Manager
# Requires clipman to be installed and running as a service

# Load configuration
CONFIG_FILE="$HOME/.config/rofi/clipboard-config"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    # Default configuration
    MAX_ITEMS=50
    MAX_DISPLAY_LENGTH=80
    CLIPMAN_DB="$HOME/.local/share/clipman.json"
    ROFI_THEME_WINDOW='window { width: 60%; }'
    ROFI_THEME_LISTVIEW='listview { lines: 10; }'
    ROFI_THEME_ELEMENT='element-text { text-color: inherit; }'
    ROFI_THEME_INPUT='entry { placeholder: "Search clipboard history..."; }'
    NOTIFICATION_TIMEOUT=1500
fi

# Check if clipman is installed
if ! command -v clipman >/dev/null 2>&1; then
    notify-send "Clipboard Manager" "clipman is not installed!\nInstall with: sudo pacman -S clipman" -t 3000
    exit 1
fi

# Check if clipman database exists (optional check)
if [[ ! -f "$CLIPMAN_DB" ]]; then
    # Try to create initial clipboard entry to initialize database
    echo "Initializing clipboard manager..." | wl-copy 2>/dev/null
    sleep 1
fi

# Function to truncate long clipboard entries for display
truncate_text() {
    local text="$1"
    local max_length="${MAX_DISPLAY_LENGTH:-80}"

    # Remove newlines and replace with spaces
    text=$(echo "$text" | tr '\n' ' ' | sed 's/  */ /g' | sed 's/^ *//;s/ *$//')

    if [[ ${#text} -gt $max_length ]]; then
        echo "${text:0:$max_length}..."
    else
        echo "$text"
    fi
}

# Function to show clipboard entries in rofi
show_clipboard() {
    # Get clipboard history from clipman
    local entries=()
    local full_entries=()

    # Read clipman history and format for display
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            # Store full entry for copying
            full_entries+=("$line")
            # Create truncated display version
            display_text=$(truncate_text "$line")
            entries+=("$display_text")
        fi
    done < <(clipman pick --tool=STDOUT --max-items="${MAX_ITEMS:-50}" 2>/dev/null || echo "")

    if [[ ${#entries[@]} -eq 0 ]]; then
        notify-send "Clipboard Manager" "No clipboard history found" -t 2000
        exit 0
    fi

    # Show rofi menu
    local prompt="Clipboard History"
    local selected_index=-1
    local rofi_result

    # Create rofi menu with entries
    rofi_result=$(printf '%s\n' "${entries[@]}" | rofi \
        -dmenu \
        -i \
        -p "$prompt" \
        -theme-str "${ROFI_THEME_WINDOW}" \
        -theme-str "${ROFI_THEME_LISTVIEW}" \
        -theme-str "${ROFI_THEME_ELEMENT}" \
        -theme-str 'inputbar { children: [ entry, case-indicator ]; }' \
        -theme-str "${ROFI_THEME_INPUT}" \
        -format 'i' \
        -selected-row 0)

    # Get the exit code and selected index
    local exit_code=$?

    if [[ $exit_code -eq 0 ]] && [[ -n "$rofi_result" ]]; then
        selected_index="$rofi_result"

        # Copy selected entry to clipboard
        if [[ $selected_index -ge 0 ]] && [[ $selected_index -lt ${#full_entries[@]} ]]; then
            echo "${full_entries[$selected_index]}" | wl-copy
            notify-send "Clipboard Manager" "Copied to clipboard!" -t "${NOTIFICATION_TIMEOUT:-1500}"
        fi
    fi
}

# Function to clear clipboard history
clear_clipboard() {
    local confirm
    confirm=$(echo -e "Yes\nNo" | rofi \
        -dmenu \
        -i \
        -p "Clear clipboard history?" \
        -theme-str 'window { width: 300px; }' \
        -theme-str 'listview { lines: 2; }')

    if [[ "$confirm" == "Yes" ]]; then
        clipman clear --all
        notify-send "Clipboard Manager" "Clipboard history cleared!" -t 2000
    fi
}

# Function to show help/options menu
show_menu() {
    local options=(
        "📋 Show Clipboard History"
        "🗑️ Clear History"
        "ℹ️ Help"
    )

    local selected
    selected=$(printf '%s\n' "${options[@]}" | rofi \
        -dmenu \
        -i \
        -p "Clipboard Manager" \
        -theme-str 'window { width: 400px; }' \
        -theme-str 'listview { lines: 3; }')

    case "$selected" in
        "📋 Show Clipboard History")
            show_clipboard
            ;;
        "🗑️ Clear History")
            clear_clipboard
            ;;
        "ℹ️ Help")
            notify-send "Clipboard Manager Help" \
"Usage:
• Run without arguments to show clipboard history
• Use --clear to clear history
• Use --menu to show options menu

Make sure clipman is running:
systemctl --user enable --now clipman.service" -t 5000
            ;;
    esac
}

# Parse command line arguments
case "${1:-}" in
    --clear)
        clear_clipboard
        ;;
    --menu)
        show_menu
        ;;
    --help|-h)
        echo "Rofi Clipboard Manager"
        echo "Usage: $0 [--clear|--menu|--help]"
        echo ""
        echo "Options:"
        echo "  --clear  Clear clipboard history"
        echo "  --menu   Show options menu"
        echo "  --help   Show this help"
        echo ""
        echo "Default: Show clipboard history"
        ;;
    "")
        show_clipboard
        ;;
    *)
        echo "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac
