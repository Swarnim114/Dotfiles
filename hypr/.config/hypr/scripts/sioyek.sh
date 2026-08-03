#!/bin/bash
# Updates Sioyek PDF viewer colors from the Noctalia v5 generated noctalia.lua.
# Noctalia writes: local surface = "rgb(rrggbb)"  -> used as background
#                  local primary = "rgb(rrggbb)"  -> used as text

NOCTALIA_LUA="$HOME/.config/hypr/noctalia.lua"
SIOYEK_CONF="$HOME/.config/sioyek/prefs_user.config"

# Wait briefly for noctalia to finish writing noctalia.lua before reading it
sleep 0.5

if [ ! -f "$NOCTALIA_LUA" ]; then
    echo "Error: $NOCTALIA_LUA not found" >&2
    exit 1
fi

if [ ! -f "$SIOYEK_CONF" ]; then
    echo "Error: $SIOYEK_CONF not found" >&2
    exit 1
fi

# Parse rgb(rrggbb) hex values and convert to float RGB (0.00–1.00)
eval $(python3 - <<'PYEOF'
import re

with open('/home/kalon/.config/hypr/noctalia.lua') as f:
    content = f.read()

def parse_rgb(name):
    m = re.search(rf'local {name}\s*=\s*"rgb\(([0-9a-fA-F]{{6}})\)"', content)
    if not m:
        return None
    h = m.group(1)
    return tuple(round(int(h[i:i+2], 16) / 255.0, 2) for i in (0, 2, 4))

def fmt(t):
    return f"{t[0]:.2f} {t[1]:.2f} {t[2]:.2f}"

surface = parse_rgb("surface") or (0.07, 0.07, 0.07)
primary = parse_rgb("primary") or (0.90, 0.90, 0.90)

print(f"BG_COLOR='{fmt(surface)}'")
print(f"TEXT_COLOR='1.00 1.00 1.00'")
PYEOF
)

sed -i "s/^custom_background_color .*/custom_background_color ${BG_COLOR}/" "$SIOYEK_CONF"
sed -i "s/^custom_text_color.*/custom_text_color       ${TEXT_COLOR}/" "$SIOYEK_CONF"
sed -i "s/^custom_color_mode_empty_background_color .*/custom_color_mode_empty_background_color ${BG_COLOR}/" "$SIOYEK_CONF"
sed -i "s/^inverted_background_color .*/inverted_background_color ${BG_COLOR}/" "$SIOYEK_CONF"
sed -i "s/^inverted_text_color.*/inverted_text_color       ${TEXT_COLOR}/" "$SIOYEK_CONF"
sed -i "s/^inverted_color_mode_empty_background_color .*/inverted_color_mode_empty_background_color ${BG_COLOR}/" "$SIOYEK_CONF"

echo "Sioyek colors updated: bg=${BG_COLOR}  text=${TEXT_COLOR}"
