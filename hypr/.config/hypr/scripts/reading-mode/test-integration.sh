#!/usr/bin/env bash
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃              Reading Mode - Integration Test               ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
# Test the full reading mode toggle cycle

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
READING_MODE_SCRIPT="$SCRIPT_DIR/reading-mode.sh"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Reading Mode Integration Test"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# Test 1: Check if script exists and is executable
echo "Test 1: Script existence and permissions"
if [[ -f "$READING_MODE_SCRIPT" ]]; then
    echo "  ✓ Script exists"
else
    echo "  ✗ Script not found"
    exit 1
fi

if [[ -x "$READING_MODE_SCRIPT" ]]; then
    echo "  ✓ Script is executable"
else
    echo "  ⚠ Script not executable, setting permissions..."
    chmod +x "$READING_MODE_SCRIPT"
fi

# Test 2: Check shader file exists
echo
echo "Test 2: Shader file"
SHADER_PATH="$HOME/.config/hypr/shaders/reading_mode/grayscale.glsl"
if [[ -f "$SHADER_PATH" ]]; then
    echo "  ✓ Shader file exists"
    echo "  ✓ Size: $(wc -c < "$SHADER_PATH") bytes"
else
    echo "  ✗ Shader file not found at $SHADER_PATH"
    exit 1
fi

# Test 3: Check state directory
echo
echo "Test 3: State directory"
STATE_DIR="$HOME/.cache/hypr/reading-mode"
if [[ -d "$STATE_DIR" ]]; then
    echo "  ✓ State directory exists"
else
    echo "  ⚠ State directory doesn't exist (will be created on first run)"
fi

# Test 4: Activate reading mode
echo
echo "Test 4: Activating reading mode"
bash "$READING_MODE_SCRIPT"
sleep 2

# Check if shader is active
CURRENT_SHADER=$(hyprctl getoption decoration:screen_shader -j 2>/dev/null | grep -oP '(?<="str": ")[^"]*')
if [[ "$CURRENT_SHADER" == "$SHADER_PATH" ]]; then
    echo "  ✓ Shader activated successfully"
else
    echo "  ✗ Shader not active (got: $CURRENT_SHADER)"
fi

# Check if animations are disabled
ANIMATIONS=$(hyprctl getoption animations:enabled -j 2>/dev/null | grep -oP '(?<="int": )\d+')
if [[ "$ANIMATIONS" == "0" ]]; then
    echo "  ✓ Animations disabled"
else
    echo "  ✗ Animations still enabled"
fi

# Check state file
if [[ -f "$STATE_DIR/active" ]]; then
    echo "  ✓ State file created"
else
    echo "  ✗ State file not created"
fi

# Test 5: Deactivate reading mode
echo
echo "Test 5: Deactivating reading mode"
bash "$READING_MODE_SCRIPT"
sleep 2

# Check if shader is deactivated
CURRENT_SHADER=$(hyprctl getoption decoration:screen_shader -j 2>/dev/null | grep -oP '(?<="str": ")[^"]*')
if [[ "$CURRENT_SHADER" == "[[EMPTY]]" ]] || [[ -z "$CURRENT_SHADER" ]]; then
    echo "  ✓ Shader deactivated successfully"
else
    echo "  ✗ Shader still active (got: $CURRENT_SHADER)"
fi

# Check if animations are re-enabled
ANIMATIONS=$(hyprctl getoption animations:enabled -j 2>/dev/null | grep -oP '(?<="int": )\d+')
if [[ "$ANIMATIONS" == "1" ]]; then
    echo "  ✓ Animations re-enabled"
else
    echo "  ⚠ Animations still disabled (hyprctl reload may be needed)"
fi

# Check state file removed
if [[ ! -f "$STATE_DIR/active" ]]; then
    echo "  ✓ State file removed"
else
    echo "  ✗ State file still exists"
fi

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Test Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "Next steps:"
echo "  1. Press Super+R to toggle reading mode"
echo "  2. Verify visual appearance (grayscale, paper texture)"
echo "  3. Check that theme/wallpaper/brightness change"
echo
