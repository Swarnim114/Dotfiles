_G.primary = "rgb(ebdbb2)"
_G.surface = "rgb(282828)"
_G.secondary = "rgb(8ec07c)"
_G.error = "rgb(fb4934)"
_G.tertiary = "rgb(83a598)"
_G.surface_lowest = "rgb(2c2b2a)"

hl.config({
  general = {
    col = {
      active_border = _G.primary,
      inactive_border = _G.surface
    }
  },
  group = {
    col = {
      border_active = _G.secondary,
      border_inactive = _G.surface,
      border_locked_active = _G.error,
      border_locked_inactive = _G.surface
    },
    groupbar = {
      col = {
        active = _G.secondary,
        inactive = _G.surface,
        locked_active = _G.error,
        locked_inactive = _G.surface
      }
    }
  }
})
