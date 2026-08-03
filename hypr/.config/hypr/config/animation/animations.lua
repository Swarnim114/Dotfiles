-- ============================================================================
-- animations.lua
-- Snappy + sticky slide-in for all windows, layers, workspaces
-- ============================================================================

-- 1. Global enable
hl.config({
  animations = {
    enabled = false,
  }
})

-- 2. Curves
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
-- hl.curve("quick",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

-- 3. Animations
-- WINDOWS
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 3,  bezier = "quick", style = "popin 90%" })
hl.animation({ leaf = "windowsOut",    enabled = false,  speed = 2,  bezier = "quick",        style = "slide" })
hl.animation({ leaf = "windowsMove",   enabled = true,  speed = 1,  bezier = "quick" , style= "slide" })

-- LAYERS (waybar, rofi, notifications, etc)
hl.animation({ leaf = "layersIn",      enabled = false,  speed = 3,  bezier = "quick", style = "slide" })
hl.animation({ leaf = "layersOut",     enabled = false,  speed = 2,  bezier = "quick",        style = "slide" })

-- WORKSPACES
hl.animation({ leaf = "workspacesIn",  enabled = false,  speed = 2,  bezier = "quick", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = false,  speed = 1,  bezier = "quick",        style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = false, speed = 2, bezier = "quick", style = "slidefade 20%" })

-- FADE (subtle, just for opacity not movement)
-- hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 3,  bezier = "quick" })
-- hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 2,  bezier = "quick"        })
-- hl.animation({ leaf = "fadeSwitch",    enabled = true,  speed = 2,  bezier = "quick"        })
-- hl.animation({ leaf = "fadeDim",       enabled = true,  speed = 2,  bezier = "quick"        })
-- hl.animation({ leaf = "fadeLayers",    enabled = true,  speed = 2,  bezier = "quick"        })

-- BORDER (off, no need)
hl.animation({ leaf = "border",        enabled = false })
hl.animation({ leaf = "borderangle",   enabled = false })
