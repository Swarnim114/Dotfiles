hl.config({
  input = {
    follow_mouse = 1,
    sensitivity = 0.4,
    accel_profile = "flat",

    touchpad = {
      natural_scroll = true,
      scroll_factor = 1.0,
      tap_to_click = true
    },

    kb_layout = "us",
    kb_options = "altgr:super",
    float_switch_override_focus = 2
  }
})

hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
  type = "swipe"
})

hl.gesture({
  fingers = 4,
  direction = "down",
  action = "close"
})
