# Pywal Complete Desktop Integration

This package contains a comprehensive pywal setup that themes your entire Hyprland desktop automatically when changing wallpapers.

## What's Included

### Core Pywal Configuration
- **~/.config/wal/**: Complete pywal cache directory with templates and automation
- **Templates**: Custom templates for all desktop components
- **update-colors.sh**: Comprehensive automation script that updates all components
- **Generated color files**: All current pywal color schemes

### Components Themed
1. **Hyprland**: Window manager colors and border theming
2. **Waybar**: Status bar with dynamic colors
3. **Rofi**: Application launcher with pywal colors
4. **Alacritty**: Terminal emulator theming
5. **Mako**: Notification daemon theming
6. **VS Code**: Complete workbench color overrides (requires separate vscode-pywal package)
7. **Zed**: Custom pywal theme integration (managed by zed package)

### Templates Available
- alacritty-colors.toml: Terminal colors
- colors-hyprland.conf: Hyprland window manager colors
- colors.css: General CSS colors for waybar
- colors.rasi: Rofi launcher colors
- mako-colors: Notification colors
- gtk3.css & gtk4.css: GTK application theming (using static Adwaita-dark)

## How It Works

1. **Wallpaper Selection**: Use $mainMod + W or run wallpaper selector script
2. **Automatic Processing**: Pywal generates colors from selected wallpaper
3. **Component Updates**: All desktop components are automatically updated
4. **Waybar Restart**: Waybar is automatically restarted to apply new colors

### Key Scripts
- ~/.config/wal/update-colors.sh: Main automation script
- ~/.config/swaybg/wallpaper-selector.sh: Enhanced with pywal integration (managed by swaybg package)

## Installation

### First Time Setup
```bash
# Navigate to dotfiles directory
cd ~/dotfiles

# Stow the wal package
stow wal

# Also stow related packages if not already done
stow swaybg  # Contains enhanced wallpaper selector
stow hypr    # Contains waybar restart keybind
stow zed     # Contains pywal theme
```

### VS Code Integration (Optional)
```bash
# For VS Code theming
stow vscode-pywal
```

## Dependencies

- pywal (python-pywal)
- swaybg (wallpaper manager)
- waybar (status bar)
- rofi (launcher)
- alacritty (terminal)
- mako (notifications)
- hyprland (window manager)

## Usage

### Change Wallpaper & Theme
- **Keybind**: $mainMod + W (defined in hyprland keybinds)
- **Manual**: Run ~/.config/swaybg/wallpaper-selector.sh

### Restart Waybar
- **Keybind**: $mainMod + Ctrl + R
- **Manual**: bash -c "pkill waybar; sleep 0.5; waybar &"

### Manual Color Update
```bash
# Run pywal on an image
wal -i /path/to/wallpaper.jpg -n

# Update all components
~/.config/wal/update-colors.sh
```

## Customization

### Adding New Components
1. Create a template in ~/.config/wal/templates/
2. Add update logic to update-colors.sh
3. Test with wal -R to reload current colors

### Template Variables
Templates use pywal variables like:
- {background}, {foreground}
- {color0} through {color15}
- {cursor}, {highlight}

## Integration Points

This package integrates with:
- **swaybg package**: Enhanced wallpaper selector
- **hypr package**: Keybinds and color integration
- **waybar package**: Dynamic color theming
- **rofi package**: Launcher theming
- **alacritty package**: Terminal theming
- **mako package**: Notification theming
- **zed package**: Editor theming
- **vscode-pywal package**: VS Code theming (optional)

## Notes

- GTK applications use static Adwaita-dark theme for consistency
- VS Code requires separate package due to complex override requirements
- Waybar restart automation is handled by wallpaper selector for proper session context
- All color changes persist across reboots via hyprland autostart configuration
