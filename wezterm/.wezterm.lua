local wezterm = require 'wezterm'
local config = wezterm.config_builder and wezterm.config_builder() or {}

-- 🎨 Dracula Color Scheme
config.colors = {
  foreground = '#f8f8f2',
  background = '#282a36',
  cursor_bg = '#f8f8f2',
  cursor_fg = '#282a36',
  selection_bg = '#44475a',
  selection_fg = '#f8f8f2',
  ansi = {
    '#21222c', -- Black
    '#ff5555', -- Red
    '#50fa7b', -- Green
    '#f1fa8c', -- Yellow
    '#bd93f9', -- Blue
    '#ff79c6', -- Magenta
    '#8be9fd', -- Cyan
    '#f8f8f2', -- White
  },
  brights = {
    '#6272a4', -- Bright Black
    '#ff6e6e', -- Bright Red
    '#69ff94', -- Bright Green
    '#ffffa5', -- Bright Yellow
    '#d6acff', -- Bright Blue
    '#ff92df', -- Bright Magenta
    '#a4ffff', -- Bright Cyan
    '#ffffff', -- Bright White
  },
}

-- 🖋️ Font settings
config.font = wezterm.font_with_fallback({
  "JetBrains Mono",
  "JetBrainsMono Nerd Font",
  "Fira Code",
  "Monospace"
})
config.font_size = 14.0

-- 🌟 Transparency
config.window_background_opacity = 0.98

-- 🔄 Cursor style
config.default_cursor_style = "BlinkingBlock"

-- 🚫 No close confirmation
config.window_close_confirmation = "NeverPrompt"

-- 🖼️ Window decorations (note: borders won't show in GNOME/Wayland)
config.window_decorations = "RESIZE"
config.window_frame = {
  border_left_color = "#44475a",
  border_right_color = "#44475a",
  border_bottom_color = "#44475a",
  border_top_color = "#44475a",
  border_left_width = 1,
  border_right_width = 1,
  border_bottom_height = 1,
  border_top_height = 1,
}

-- 📏 Padding
config.window_padding = {
  left = 4,
  right = 4,
  top = 4,
  bottom = 4,
}

return config
