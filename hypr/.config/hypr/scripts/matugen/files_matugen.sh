#!/bin/bash
# Noctalia color generation hook — switch Colloid icon theme variant
# to match the current Noctalia accent palette.
#
# Hook argument from noctalia:
#   $1 = theme (dark/light)
#
# Setup: In Noctalia settings → Hooks, set:
#   hooks.enabled = true
#   hooks.colorGeneration = "/home/kalon/Extra/copycat/colloid-noctalia-hook.sh $1"

COLORS_JSON="$HOME/.config/noctalia/colors.json"
NOCTALIA_THEME="${1:-dark}"   # "dark" or "light" passed by Noctalia

if [ ! -f "$COLORS_JSON" ]; then
    echo "Error: $COLORS_JSON not found" >&2
    exit 1
fi

SETTINGS_JSON="$HOME/.config/noctalia/settings.json"
if [ -f "$SETTINGS_JSON" ]; then
    # Check if Noctalia is fetching colors from the wallpaper
    USE_WALLPAPER=$(python3 -c "import json, os; print(json.load(open(os.path.expanduser('~/.config/noctalia/settings.json'))).get('colorSchemes', {}).get('useWallpaperColors', False))" 2>/dev/null)
    if [ "$USE_WALLPAPER" = "True" ]; then
        echo "Skipping Colloid theme change: colors fetched from wallpaper."
        exit 0
    fi
fi

# ---- Pick the closest Colloid accent from mPrimary hue ----
ACCENT=$(python3 - <<'EOF'
import json, colorsys, sys

ACCENTS = {
    "Red":    15,    # hue ~15°  (red/coral)
    "Orange": 30,    # hue ~30°
    "Yellow": 50,    # hue ~50°
    "Green":  120,   # hue ~120°
    "Teal":   175,   # hue ~175°
    "Purple": 270,   # hue ~270°
    "Pink":   330,   # hue ~330°  (pink/rose)
    # "Grey" and default blue are fallbacks — not hue-matched
}
DEFAULT = "Purple"  # fallback if hue is ambiguous or very desaturated

import os
with open(os.path.expanduser("~/.config/noctalia/colors.json")) as f:
    palette = json.load(f)

primary = palette.get("mPrimary", "#6272a4").lstrip("#")
r, g, b = (int(primary[i:i+2], 16) / 255 for i in (0, 2, 4))
h, l, s = colorsys.rgb_to_hls(r, g, b)

# Very desaturated → fall back to default
if s < 0.15:
    print(DEFAULT)
    sys.exit(0)

hue_deg = h * 360

# Circular distance
def hue_dist(a, b):
    d = abs(a - b) % 360
    return min(d, 360 - d)

closest = min(ACCENTS.items(), key=lambda kv: hue_dist(hue_deg, kv[1]))
print(closest[0])
EOF
)

# ---- Determine dark/light suffix ----
if [ "$NOCTALIA_THEME" = "light" ]; then
    SUFFIX="Light"
else
    SUFFIX="Dark"
fi

# ---- Build theme name ----
THEME="Colloid-${ACCENT}-${SUFFIX}"

# Sanity check — fall back to plain Colloid-Dark if the theme doesn't exist
if [ ! -d "/usr/share/icons/$THEME" ]; then
    THEME="Colloid-${SUFFIX}"
fi

echo "Colloid: accent=$ACCENT  mode=$SUFFIX  → $THEME"

gsettings set org.gnome.desktop.interface icon-theme "$THEME"
echo "Applied icon theme '$THEME'"

# ---- Sync Qt5/Qt6 icon theme to match ----
for conf in "$HOME/.config/qt5ct/qt5ct.conf" "$HOME/.config/qt6ct/qt6ct.conf"; do
    [ -f "$conf" ] && sed -i "s|^icon_theme=.*|icon_theme=$THEME|" "$conf"
done
echo "Synced Qt icon theme to '$THEME'"

# ---- Regenerate qt5ct/qt6ct color palette from current Noctalia colors ----
python3 - << 'PYEOF'
import json, os

with open(os.path.expanduser("~/.config/noctalia/colors.json")) as f:
    c = json.load(f)

roles = [
    c.get('mOnSurface',        '#f4ded9'),  # windowText
    c.get('mSurface',          '#1c110e'),  # button
    '#ffffff',                               # light
    '#cacaca',                               # midlight
    '#9f9f9f',                               # dark
    '#b8b8b8',                               # mid
    c.get('mOnSurface',        '#f4ded9'),  # text
    '#ffffff',                               # brightText
    c.get('mOnSurface',        '#f4ded9'),  # buttonText
    c.get('mSurface',          '#1c110e'),  # base
    c.get('mSurface',          '#1c110e'),  # window
    c.get('mShadow',           '#000000'),  # shadow
    c.get('mPrimary',          '#6272a4'),  # highlight (accent color!)
    c.get('mOnPrimary',        '#ffffff'),  # highlightedText
    c.get('mSecondary',        '#6272a4'),  # link
    c.get('mTertiary',         '#6272a4'),  # linkVisited
    c.get('mSurfaceVariant',   '#291d1a'),  # alternateBase
    c.get('mSurface',          '#1c110e'),  # (unused)
    c.get('mSurfaceVariant',   '#291d1a'),  # toolTipBase
    c.get('mOnSurface',        '#f4ded9'),  # toolTipText
    c.get('mOnSurface',        '#f4ded9'),  # placeholderText
    c.get('mPrimary',          '#6272a4'),  # accent
]

line = ', '.join(roles)
content = f"[ColorScheme]\nactive_colors={line}\ndisabled_colors={line}\ninactive_colors={line}\n"

for path in [
    os.path.expanduser("~/.config/qt5ct/colors/noctalia.conf"),
    os.path.expanduser("~/.config/qt6ct/colors/noctalia.conf"),
]:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        f.write(content)

print(f"Qt palette synced — highlight: {c.get('mPrimary')}")
PYEOF
