#!/bin/bash
# Hook script to set Sioyek colors based on Noctalia generated palette.
#
# Hook argument from noctalia:
#   $1 = theme (dark/light)

COLORS_JSON="$HOME/.config/noctalia/colors.json"
SIOYEK_CONF="$HOME/.config/sioyek/prefs_user.config"

if [ ! -f "$COLORS_JSON" ]; then
    echo "Error: $COLORS_JSON not found" >&2
    exit 1
fi

if [ ! -f "$SIOYEK_CONF" ]; then
    echo "Error: $SIOYEK_CONF not found" >&2
    exit 1
fi

# Extract and convert colors to RGB float (0.00 to 1.00)
eval $(python3 - <<'PYEOF'
import json, os

with open(os.path.expanduser("~/.config/noctalia/colors.json")) as f:
    palette = json.load(f)

def hex_to_float_rgb(hex_str):
    hex_str = hex_str.lstrip('#')
    return tuple(round(int(hex_str[i:i+2], 16) / 255.0, 2) for i in (0, 2, 4))

def format_color(color_tuple):
    return f"{color_tuple[0]:.2f} {color_tuple[1]:.2f} {color_tuple[2]:.2f}"

bg_hex = palette.get("mSurface", "#1c110e")
text_hex = palette.get("mOnSurface", "#f4ded9")

bg_rgb = hex_to_float_rgb(bg_hex)
text_rgb = hex_to_float_rgb(text_hex)

print(f"BG_COLOR='{format_color(bg_rgb)}'")
print(f"TEXT_COLOR='{format_color(text_rgb)}'")
PYEOF
)

# Use sed to update Sioyek config
sed -i "s/^custom_background_color .*/custom_background_color ${BG_COLOR}/" "$SIOYEK_CONF"
sed -i "s/^custom_text_color.*/custom_text_color       ${TEXT_COLOR}/" "$SIOYEK_CONF"

sed -i "s/^custom_color_mode_empty_background_color .*/custom_color_mode_empty_background_color ${BG_COLOR}/" "$SIOYEK_CONF"

sed -i "s/^inverted_background_color .*/inverted_background_color ${BG_COLOR}/" "$SIOYEK_CONF"
sed -i "s/^inverted_text_color.*/inverted_text_color       ${TEXT_COLOR}/" "$SIOYEK_CONF"

sed -i "s/^inverted_color_mode_empty_background_color .*/inverted_color_mode_empty_background_color ${BG_COLOR}/" "$SIOYEK_CONF"

echo "Sioyek colors updated to ${BG_COLOR} (bg) and ${TEXT_COLOR} (text)."
