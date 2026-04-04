# WARP Manager Plugin for Noctalia

A plugin to manage Cloudflare WARP connection directly from your Noctalia shell.

## Features

- **Quick Toggle**: Click the widget to connect/disconnect WARP
- **Status Display**: Shows current connection status
- **Visual Indicators**: Different icons and colors for connected/disconnected states
- **Control Center Integration**: Add to your control center for quick access
- **Bar Widget**: Display WARP status in your bar

## Requirements

- Cloudflare WARP CLI (`warp-cli`) must be installed
- WARP daemon must be running

## Installation

1. Install Cloudflare WARP if you haven't already:
   ```bash
   # On Arch Linux
   yay -S cloudflare-warp-bin
   
   # Register WARP
   warp-cli register
   ```

2. The plugin should be automatically detected by Noctalia

3. Enable it in Noctalia settings

## Usage

### Bar Widget
- **Left Click**: Open WARP connection panel (like the macOS toggle UI)
- **Right Click**: Context menu with connect, disconnect, and refresh options

### Control Center Widget
- **Click**: Toggle connection

## Settings

- **Display Mode**: Choose how the bar widget is displayed (always show, on hover, always hide)
- **Connected Color**: Color scheme when WARP is connected (default: primary)
- **Disconnected Color**: Color scheme when WARP is disconnected (default: none)

## Commands Used

This plugin uses the following `warp-cli` commands:
- `warp-cli status` - Check connection status
- `warp-cli connect` - Connect to WARP
- `warp-cli disconnect` - Disconnect from WARP

## License

MIT
