hl.config({
  general = {
    gaps_in = 6,
    gaps_out = 6,
    border_size = 1,
    resize_on_border = true,
    allow_tearing = false,

    col = {
      active_border = "rgb(FFFFFF)",
      inactive_border = "rgb(FFFFFF)",
    }
  },

  decoration = {
    rounding = 0,
    active_opacity = 1.0,
    inactive_opacity = 1.0,

    blur = {
      enabled = false,
      size = 2,
      passes = 2,
      xray = false,
      new_optimizations = true
    },

    shadow = {
      enabled = true,
      range = 18,
      render_power = 4,
      color = 0x88000000,
      offset = "0 2",
      scale = 1.0
    },

    dim_inactive = false,
    dim_strength = 0.1
  }
})
