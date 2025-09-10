#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo -e "\e[32mLet's create a new web app you can start with the app launcher.\n\e[0m"
  
  echo -n "Name> "
  read -r APP_NAME
  
  echo -n "URL (e.g., https://example.com)> "
  read -r APP_URL
  
  echo -n "Icon URL (must use PNG! See https://dashboardicons.com)> "
  read -r ICON_URL
else
  APP_NAME="$1"
  APP_URL="$2"
  ICON_URL="$3"
fi

if [[ -z "$APP_NAME" || -z "$APP_URL" || -z "$ICON_URL" ]]; then
  echo "You must set app name, app URL, and icon URL!"
  exit 1
fi

# Check if Brave browser is installed
if ! command -v brave >/dev/null 2>&1; then
  echo "Error: Brave browser is not installed or not in PATH"
  echo "Please install Brave browser first"
  exit 1
fi

ICON_DIR="$HOME/.local/share/applications/icons"
DESKTOP_FILE="$HOME/.local/share/applications/$APP_NAME.desktop"
ICON_PATH="$ICON_DIR/$APP_NAME.png"

mkdir -p "$ICON_DIR"

if ! curl -sL -o "$ICON_PATH" "$ICON_URL"; then
  echo "Error: Failed to download icon from $ICON_URL"
  exit 1
fi

# Verify icon was downloaded successfully
if [[ ! -f "$ICON_PATH" ]] || [[ ! -s "$ICON_PATH" ]]; then
  echo "Error: Icon file is empty or not found"
  exit 1
fi

cat >"$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Name=$APP_NAME
Comment=$APP_NAME
Exec=brave --app=$APP_URL
Terminal=false
Type=Application
Icon=$ICON_PATH
StartupNotify=true
Categories=Network;WebBrowser;
EOF

chmod +x "$DESKTOP_FILE"

if [ "$#" -ne 3 ]; then
  echo -e "You can now find $APP_NAME using the app launcher (SUPER + D)\n"
fi