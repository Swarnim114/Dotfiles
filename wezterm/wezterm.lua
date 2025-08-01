local wezterm = require 'wezterm'

local config = {}

-- 🎨 Gruvbox Hard Color Scheme (Modernized)
config.colors = {
  foreground = '#ebdbb2',
  background = '#282828',
  cursor_bg = '#fabd2f',
  cursor_fg = '#282828',
  selection_bg = '#3c3836',
  selection_fg = '#ebdbb2',
  ansi = {
    '#282828', -- Black
    '#fb4934', -- Red
    '#b8bb26', -- Green
    '#fabd2f', -- Yellow
    '#83a598', -- Blue
    '#d3869b', -- Magenta
    '#8ec07c', -- Cyan
    '#ebdbb2', -- White
  },
  brights = {
    '#928374', -- Bright Black
    '#fb4934', -- Bright Red
    '#b8bb26', -- Bright Green
    '#fabd2f', -- Bright Yellow
    '#83a598', -- Bright Blue
    '#d3869b', -- Bright Magenta
    '#8ec07c', -- Bright Cyan
    '#ebdbb2', -- Bright White
  },
}

-- 🖋️ Fixing font issue: Check installed fonts with `wezterm ls-fonts`
config.font = wezterm.font_with_fallback({
  "JetBrains Mono", -- Try this first
  "JetBrainsMono Nerd Font", -- Try this if available
  "Fira Code", -- Fallback
  "Monospace" -- Last resort
})
config.font_size = 14.0

-- 🌟 Modern Transparency (Optional)
config.window_background_opacity = 0.98 -- Adjust as needed

-- 🔄 Modern Cursor Animation
config.default_cursor_style = "BlinkingBlock"

-- 🚫 Disable Close Confirmation (Modern Workflow)
config.window_close_confirmation = "NeverPrompt"

-- 🖼️ Modern Window Styling (Subtle Borders)
config.window_decorations = "RESIZE"
config.window_frame = {
  border_left_color = "#3c3836", -- Darker border for Gruvbox
  border_right_color = "#3c3836",
  border_bottom_color = "#3c3836",
  border_top_color = "#3c3836",
  border_left_width = 1,   -- Thinner borders
  border_right_width = 1,
  border_bottom_height = 1,
  border_top_height = 1,
}

-- 📏 Modern Padding (Slightly Reduced)
config.window_padding = {
  left = 4,
  right = 4,
  top = 4,
  bottom = 4,
}

return config
