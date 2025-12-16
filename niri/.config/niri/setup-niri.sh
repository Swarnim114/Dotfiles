#!/bin/bash
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃                 Niri Setup & Testing Script                 ┃
# ┃              Converted from Hyprland setup                  ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

echo "🎯 Niri Configuration Setup Script"
echo "=================================="

# Check if Niri is installed
if ! command -v niri &> /dev/null; then
    echo "❌ Niri is not installed. Please install it first:"
    echo "   sudo pacman -S niri  # or your preferred method"
    exit 1
fi

echo "✅ Niri is installed"

# Validate the configuration
echo "🔍 Validating Niri configuration..."
if niri validate ~/.config/niri/config.kdl; then
    echo "✅ Niri configuration is valid!"
else
    echo "❌ Configuration has errors. Please check the syntax."
    exit 1
fi

# Check for required dependencies
echo "🔍 Checking dependencies..."

DEPS=("waybar" "kitty" "firefox" "thunar" "spotify" "obsidian" "rofi" "grim" "slurp" "swappy" "swaylock" "brightnessctl" "qalculate-gtk")
MISSING_DEPS=()

for dep in "${DEPS[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        MISSING_DEPS+=("$dep")
    fi
done

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo "⚠️  Missing dependencies:"
    printf '   %s\n' "${MISSING_DEPS[@]}"
    echo ""
    echo "Install them with:"
    echo "   sudo pacman -S ${MISSING_DEPS[*]}"
    echo ""
fi

# Show key differences between Hyprland and Niri
echo "📋 Key Differences from Hyprland:"
echo "================================"
echo "• Niri uses a scrollable tiling paradigm instead of traditional tiling"
echo "• Windows are arranged in columns that you can scroll through horizontally"
echo "• No traditional floating windows (limited floating support)"
echo "• Focus ring instead of window borders"
echo "• Different workspace model (dynamic workspaces)"
echo ""

echo "🎯 Key Bindings Summary:"
echo "========================"
echo "Application Launchers:"
echo "  Super + Space       → Terminal (kitty)"
echo "  Super + Return      → Browser (firefox)"
echo "  Super + F           → File Manager (thunar)"
echo "  Super + D           → App Launcher (rofi)"
echo "  Super + E           → Editor (code)"
echo ""
echo "Window Management:"
echo "  Super + Q           → Close window"
echo "  Super + W           → Fullscreen"
echo "  Super + C           → Toggle floating"
echo "  Super + R           → Switch column width presets"
echo ""
echo "Navigation:"
echo "  Super + Arrow Keys  → Focus movement"
echo "  Super + 1-9,0       → Switch workspaces"
echo "  Super + Period/Comma → Scroll workspaces"
echo ""
echo "System:"
echo "  Super + L           → Lock screen"
echo "  Super + Shift + E   → Quit Niri"
echo "  Super + Shift + R   → Reload config"
echo ""

# Test mode option
read -p "🚀 Would you like to test Niri in a nested window? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Starting Niri in test mode..."
    echo "   Press Super+Shift+E to quit and return to your current session"
    sleep 2
    niri --session
else
    echo "✅ Configuration complete!"
    echo ""
    echo "💡 To start using Niri:"
    echo "   1. Log out of your current session"
    echo "   2. Select 'Niri' from your display manager"
    echo "   3. Or run 'niri --session' from a TTY"
    echo ""
    echo "📁 Your original Niri config has been backed up to:"
    echo "   ~/.config/niri/config.kdl.backup"
fi