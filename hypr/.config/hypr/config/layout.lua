hl.config({
  general = {
    layout = "dwindle"
  },
  dwindle = {
    preserve_split = true,
  },
  scrolling = {
    fullscreen_on_one_column = true,
    focus_fit_method = 0,
    column_width = 0.7,
    explicit_column_widths = "0.3, 0.5, 0.65, 0.8, 0.985, 1.0",
    follow_focus = true
  }
})

-- hl.gesture({
--   fingers = 4,
--   direction = "left",
--   action = "exec",
--   exec = "hyprctl dispatch layoutmsg 'move +col'"
-- })

-- hl.gesture({
--   fingers = 4,
--   direction = "right",
--   action = "exec",
--   exec = "hyprctl dispatch layoutmsg 'move -col'"
-- })
