#!/usr/bin/env bash

# Paths
COLORS_FILE="$HOME/.config/noctalia/colors.json"
THEME_DIR="$HOME/Notes/.obsidian/themes/Noctalia"
THEME_FILE="$THEME_DIR/theme.css"
MANIFEST_FILE="$THEME_DIR/manifest.json"

mkdir -p "$THEME_DIR"

if [ ! -f "$COLORS_FILE" ]; then
    echo "Error: Colors file $COLORS_FILE not found."
    exit 1
fi

# Extract colors using jq
extract_color() {
    jq -r ".$1" "$COLORS_FILE"
}

mPrimary=$(extract_color mPrimary)
mOnPrimary=$(extract_color mOnPrimary)
mSecondary=$(extract_color mSecondary)
mOnSecondary=$(extract_color mOnSecondary)
mTertiary=$(extract_color mTertiary)
mOnTertiary=$(extract_color mOnTertiary)
mError=$(extract_color mError)
mOnError=$(extract_color mOnError)
mSurface=$(extract_color mSurface)
mOnSurface=$(extract_color mOnSurface)
mSurfaceVariant=$(extract_color mSurfaceVariant)
mOnSurfaceVariant=$(extract_color mOnSurfaceVariant)
mOutline=$(extract_color mOutline)
mShadow=$(extract_color mShadow)
mHover=$(extract_color mHover)
mOnHover=$(extract_color mOnHover)

# Create the CSS
cat <<CSS > "$THEME_FILE"
/* Noctalia theme for Obsidian generated from matugen colors */
.theme-dark, .theme-light {
    --bg2: $mSurface;
    --bg1: $mSurfaceVariant;
    --bg3: $mSurfaceVariant;
    --ui1: $mSurfaceVariant;
    --ui2: $mOutline;
    --ui3: $mOutline;
    --tx1: $mOnSurface;
    --tx2: $mOnSurfaceVariant;
    --tx3: $mOnSurfaceVariant;
    --hl1: $mPrimary;
    --hl2: $mSecondary;

    --background-primary: $mSurface;
    --background-primary-alt: $mSurfaceVariant;
    --background-secondary: $mSurfaceVariant;
    --background-secondary-alt: $mSurface;

    --text-normal: $mOnSurface;
    --text-muted: $mOnSurfaceVariant;
    --text-faint: $mShadow;
    --text-accent: $mPrimary;
    --text-accent-hover: $mHover;
    
    --text-error: $mError;

    --interactive-normal: $mSurfaceVariant;
    --interactive-hover: $mHover;
    --interactive-accent: $mPrimary;
    --interactive-accent-hover: $mHover;
    
    --text-on-accent: $mOnPrimary;
    
    --titlebar-background: $mSurface;
    --titlebar-text: $mOnSurface;
}
CSS

# Create manifest.json
cat <<JSON > "$MANIFEST_FILE"
{
    "name": "Noctalia",
    "version": "1.0.0",
    "minAppVersion": "1.0.0",
    "author": "Script Generated"
}
JSON

echo "Noctalia Obsidian theme generated successfully at $THEME_FILE!"
