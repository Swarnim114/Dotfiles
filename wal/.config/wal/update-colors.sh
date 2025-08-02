#!/bin/bash

# Comprehensive Pywal Color Update Script
# This script updates all desktop components with pywal colors

echo "🎨 Updating desktop colors with pywal..."

# Check if pywal colors exist
if [ ! -f ~/.cache/wal/colors.css ]; then
    echo "❌ No pywal colors found. Run 'wal -i <wallpaper>' first."
    exit 1
fi

# Copy generated template files to ~/.config/wal/
echo "📁 Copying pywal colors to ~/.config/wal/..."
[ -f ~/.cache/wal/colors.css ] && cp ~/.cache/wal/colors.css ~/.config/wal/
[ -f ~/.cache/wal/colors.rasi ] && cp ~/.cache/wal/colors.rasi ~/.config/wal/
[ -f ~/.cache/wal/colors-hyprland.conf ] && cp ~/.cache/wal/colors-hyprland.conf ~/.config/wal/
[ -f ~/.cache/wal/alacritty-colors.toml ] && cp ~/.cache/wal/alacritty-colors.toml ~/.config/wal/

# Copy application-specific templates
echo "🎨 Updating application themes..."
[ -f ~/.cache/wal/mako-colors ] && cp ~/.cache/wal/mako-colors ~/.config/mako/pywal-colors

# Update VS Code theme
if [ -f ~/.cache/wal/colors-vscode.json ]; then
    echo "  → Updating VS Code theme..."
    
    # Extract colors from pywal
    bg_color=$(cat ~/.cache/wal/colors | head -1)
    fg_color=$(cat ~/.cache/wal/colors | sed -n '8p')
    color1=$(cat ~/.cache/wal/colors | sed -n '2p')
    color2=$(cat ~/.cache/wal/colors | sed -n '3p')
    color3=$(cat ~/.cache/wal/colors | sed -n '4p')
    color4=$(cat ~/.cache/wal/colors | sed -n '5p')
    color5=$(cat ~/.cache/wal/colors | sed -n '6p')
    color6=$(cat ~/.cache/wal/colors | sed -n '7p')
    color8=$(cat ~/.cache/wal/colors | sed -n '9p')
    
    # Update VS Code settings.json with complete theming
    if [ -f ~/.config/Code/User/settings.json ]; then
        # Update token colors (syntax highlighting)
        sed -i "s/\"functions\":.*\".*\"/\"functions\": \"$color1\"/" ~/.config/Code/User/settings.json
        sed -i "s/\"keywords\":.*\".*\"/\"keywords\": \"$color2\"/" ~/.config/Code/User/settings.json
        sed -i "s/\"numbers\":.*\".*\"/\"numbers\": \"$color3\"/" ~/.config/Code/User/settings.json
        sed -i "s/\"strings\":.*\".*\"/\"strings\": \"$color4\"/" ~/.config/Code/User/settings.json
        sed -i "s/\"types\":.*\".*\"/\"types\": \"$color5\"/" ~/.config/Code/User/settings.json
        sed -i "s/\"variables\":.*\".*\"/\"variables\": \"$color6\"/" ~/.config/Code/User/settings.json
        sed -i "s/\"comments\":.*\".*\"/\"comments\": \"$color8\"/" ~/.config/Code/User/settings.json
        
        # Update workbench colors (complete UI override)
        sed -i "s/\"editor.background\": \".*\"/\"editor.background\": \"$bg_color\"/" ~/.config/Code/User/settings.json
        sed -i "s/\"activityBar.background\": \".*\"/\"activityBar.background\": \"$bg_color\"/" ~/.config/Code/User/settings.json
        sed -i "s/\"sideBar.background\": \".*\"/\"sideBar.background\": \"$bg_color\"/" ~/.config/Code/User/settings.json
        sed -i "s/\"panel.background\": \".*\"/\"panel.background\": \"$bg_color\"/" ~/.config/Code/User/settings.json
        sed -i "s/\"titleBar.activeBackground\": \".*\"/\"titleBar.activeBackground\": \"$bg_color\"/" ~/.config/Code/User/settings.json
        sed -i "s/\"statusBar.background\": \".*\"/\"statusBar.background\": \"$bg_color\"/" ~/.config/Code/User/settings.json
        sed -i "s/\"statusBar.foreground\": \".*\"/\"statusBar.foreground\": \"$fg_color\"/" ~/.config/Code/User/settings.json
        sed -i "s/\"activityBar.foreground\": \".*\"/\"activityBar.foreground\": \"$fg_color\"/" ~/.config/Code/User/settings.json
        sed -i "s/\"sideBar.foreground\": \".*\"/\"sideBar.foreground\": \"$fg_color\"/" ~/.config/Code/User/settings.json
        sed -i "s/\"titleBar.activeForeground\": \".*\"/\"titleBar.activeForeground\": \"$fg_color\"/" ~/.config/Code/User/settings.json
        sed -i "s/\"tab.activeBackground\": \".*\"/\"tab.activeBackground\": \"$color8\"/" ~/.config/Code/User/settings.json
        sed -i "s/\"tab.inactiveBackground\": \".*\"/\"tab.inactiveBackground\": \"$bg_color\"/" ~/.config/Code/User/settings.json
        sed -i "s/\"editorGroupHeader.tabsBackground\": \".*\"/\"editorGroupHeader.tabsBackground\": \"$bg_color\"/" ~/.config/Code/User/settings.json
        sed -i "s/\"terminal.background\": \".*\"/\"terminal.background\": \"$bg_color\"/" ~/.config/Code/User/settings.json
        sed -i "s/\"terminal.foreground\": \".*\"/\"terminal.foreground\": \"$fg_color\"/" ~/.config/Code/User/settings.json
        
        echo "    ✅ VS Code complete theme updated (overrides Catppuccin)"
    fi
fi

# Update Zed theme
if [ -f ~/.cache/wal/colors-zed.json ]; then
    echo "  → Updating Zed theme..."
    mkdir -p ~/.config/zed/themes
    cp ~/.cache/wal/colors-zed.json ~/.config/zed/themes/pywal.json
    echo "    ✅ Zed theme updated (restart Zed to see changes)"
fi

# Note: GTK apps use static Adwaita-dark theme for consistency
echo "🎭 GTK apps use static Adwaita-dark theme (no pywal colors)"

# Reload components that use the colors
echo "🔄 Reloading desktop components..."

# Reload Hyprland configuration
if command -v hyprctl >/dev/null; then
    echo "  → Reloading Hyprland config..."
    hyprctl reload
fi

# Note: Waybar is restarted by the wallpaper selector script

# Reload any running terminal sessions (they should pick up new colors automatically)
# For alacritty, update the config file directly
if pgrep alacritty >/dev/null; then
    echo "  → Updating alacritty colors..."
    if [ -f ~/.cache/wal/alacritty-colors.toml ]; then
        # Create a simpler replacement by updating specific color values
        sed -i "s/background = \".*\"/background = \"$(grep 'background = ' ~/.cache/wal/alacritty-colors.toml | cut -d'"' -f2)\"/" ~/.config/alacritty/alacritty.toml
        sed -i "s/foreground = \".*\"/foreground = \"$(grep 'foreground = ' ~/.cache/wal/alacritty-colors.toml | cut -d'"' -f2)\"/" ~/.config/alacritty/alacritty.toml
        echo "    ✅ Alacritty colors updated - restart alacritty to see changes"
    fi
fi

# Note about GTK and other applications
echo "  → GTK apps: Using static Adwaita-dark (not affected by wallpaper)"
echo "  → VS Code: Restart to see theme changes"
echo "  → Discord: Theme updates on restart" 
echo "  → Zed: Theme updates on restart"

# Reload mako notifications
if pgrep mako >/dev/null; then
    echo "  → Reloading mako notifications..."
    makoctl reload
fi

# Note about other applications
echo "  → VS Code: Restart to see theme changes"
echo "  → Discord: Theme updates on restart" 
echo "  → Zed: Theme updates on restart"

echo "✅ Desktop colors updated successfully!"
echo ""
echo "🎨 Current colors:"
echo "  Background: $(cat ~/.cache/wal/colors | head -1)"
echo "  Foreground: $(cat ~/.cache/wal/colors | sed -n '8p')"
echo "  Accent:     $(cat ~/.cache/wal/colors | sed -n '5p')"
echo ""
echo "💡 Note: Some applications may need to be restarted to see changes."
echo "   (GTK apps, some terminals, etc.)"
