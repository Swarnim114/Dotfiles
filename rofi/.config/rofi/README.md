# Rofi Clipboard Manager

A powerful clipboard manager for rofi that integrates with clipman for Wayland environments.

## Features

- 📋 View and search clipboard history
- 🔍 Fuzzy search through clipboard entries
- 🗑️ Clear clipboard history
- ⚙️ Configurable appearance and behavior
- 📱 Notification support
- 🔄 Automatic truncation for long entries
- 🎨 Integrates with your existing rofi theme

## Requirements

- `rofi` - Application launcher
- `clipman` - Clipboard manager for Wayland
- `wl-clipboard` - Wayland clipboard utilities
- `libnotify` (for notifications)

## Installation

The clipboard manager is already set up! The following files have been created:

- `~/.config/rofi/clipboard-manager.sh` - Main script
- `~/.config/rofi/clipboard-config` - Configuration file
- `~/.config/systemd/user/clipman.service` - Systemd service for clipman

The clipman service has been enabled and started automatically.

## Usage

### Basic Usage

```bash
# Show clipboard history (default action)
~/.config/rofi/clipboard-manager.sh

# Show options menu
~/.config/rofi/clipboard-manager.sh --menu

# Clear clipboard history
~/.config/rofi/clipboard-manager.sh --clear

# Show help
~/.config/rofi/clipboard-manager.sh --help
```

### Keyboard Shortcuts

Add these to your window manager configuration (e.g., Hyprland):

```
# Hyprland example
bind = SUPER, V, exec, ~/.config/rofi/clipboard-manager.sh
bind = SUPER SHIFT, V, exec, ~/.config/rofi/clipboard-manager.sh --menu
```

For other window managers, bind the script to your preferred key combination.

## Configuration

Edit `~/.config/rofi/clipboard-config` to customize:

```bash
# Maximum number of clipboard entries to show
MAX_ITEMS=50

# Maximum display length for truncated entries
MAX_DISPLAY_LENGTH=80

# Rofi appearance settings
ROFI_THEME_WINDOW='window { width: 60%; }'
ROFI_THEME_LISTVIEW='listview { lines: 10; }'

# Notification timeout (milliseconds)
NOTIFICATION_TIMEOUT=1500
```

## How It Works

1. **clipman** runs as a systemd user service, monitoring clipboard changes
2. **clipboard-manager.sh** queries clipman for history and displays it in rofi
3. Selected entries are copied back to the clipboard using `wl-copy`
4. Long entries are truncated for display but full content is preserved

## Troubleshooting

### Clipman service not running

```bash
# Check service status
systemctl --user status clipman.service

# Restart service
systemctl --user restart clipman.service

# View logs
journalctl --user -u clipman.service
```

### No clipboard history

- Make sure you've copied some text after starting the service
- Check that `wl-clipboard` is installed
- Verify your Wayland session is working properly

### Rofi styling issues

- The script inherits your rofi theme from `~/.config/themes/current/rofi.rasi`
- You can override specific elements in the configuration file
- Test with different theme settings in the config

## Integration with Other Scripts

The clipboard manager follows the same pattern as your other rofi scripts:

- `power-menu.sh` - System power options
- `theme-selector.sh` - Theme selection
- `wallpaper-cycler.sh` - Wallpaper cycling
- `clipboard-manager.sh` - Clipboard management

All scripts can be bound to keyboard shortcuts for quick access.

## Tips

- Use the search function to quickly find specific clipboard entries
- The most recent entries appear at the top
- Long text is truncated for display but the full content is copied
- Clear history periodically to maintain performance
- The service starts automatically on login
