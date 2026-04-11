#!/bin/bash

# Sync noctalia colors to micro text editor
# Reads from ~/.config/noctalia/colors.json and generates a micro colorscheme

COLORS_FILE="$HOME/.config/noctalia/colors.json"
MICRO_COLORSCHEME_DIR="$HOME/.config/micro/colorschemes"
MICRO_THEME="noctalia"
MICRO_THEME_FILE="$MICRO_COLORSCHEME_DIR/$MICRO_THEME.micro"

# Check if colors file exists
if [[ ! -f "$COLORS_FILE" ]]; then
    echo "Error: $COLORS_FILE not found"
    exit 1
fi

# Create colorschemes directory if it doesn't exist
mkdir -p "$MICRO_COLORSCHEME_DIR"

# Generate micro colorscheme using color-link format
jq -r '
  .mSurface as $bg |
  .mOnSurface as $fg |
  .mPrimary as $primary |
  .mSecondary as $secondary |
  .mTertiary as $tertiary |
  .mError as $error |
  .mOnError as $on_error |
  .mSurfaceVariant as $surface_variant |
  .mOnSurfaceVariant as $on_surface_variant |
  .mOutline as $outline |
  "color-link default \"\($fg),\($bg)\"\n" +
  "color-link comment \"\($on_surface_variant)\"\n" +
  "color-link constant \"\($tertiary)\"\n" +
  "color-link constant.string \"\($tertiary)\"\n" +
  "color-link constant.string.char \"\($secondary)\"\n" +
  "color-link type \"\($secondary)\"\n" +
  "color-link variable \"\($fg)\"\n" +
  "color-link variable.arg \"\($primary)\"\n" +
  "color-link symbol \"\($primary)\"\n" +
  "color-link symbol.tag \"\($primary)\"\n" +
  "color-link keyword \"\($primary)\"\n" +
  "color-link special \"\($primary)\"\n" +
  "color-link preproc \"\($secondary)\"\n" +
  "color-link statement \"\($primary)\"\n" +
  "color-link string \"\($tertiary)\"\n" +
  "color-link number \"\($secondary)\"\n" +
  "color-link bool \"\($secondary)\"\n" +
  "color-link error \"\($error),\($on_error)\"\n" +
  "color-link warn \"\($secondary)\"\n" +
  "color-link cursor-line \"\($surface_variant)\"\n" +
  "color-link cursor \"\($primary)\"\n" +
  "color-link selection \"\($surface_variant)\"\n" +
  "color-link line-number \"\($on_surface_variant)\"\n" +
  "color-link gutter-background \"\($bg)\"\n" +
  "color-link gutter-foreground \"\($on_surface_variant)\"\n" +
  "color-link whitespace \"\($outline)\"\n"
' "$COLORS_FILE" > "$MICRO_THEME_FILE"

if [[ $? -eq 0 ]]; then
    echo "✓ Created micro colorscheme: $MICRO_THEME_FILE"
    echo ""
    echo "To use this theme in micro, add to your settings.json:"
    echo "  \"colorscheme\": \"$MICRO_THEME\""
else
    echo "Error: Failed to generate colorscheme"
    exit 1
fi
