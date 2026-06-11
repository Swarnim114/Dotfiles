-- ============================================================================
-- animations.lua
-- Purpose: Only cursor zoom is animated; all other UI transitions are instant.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Global animation setting (must be ON for any animation to work)
-- ----------------------------------------------------------------------------
hl.config({
  animations = {
    enabled = true,
  }
})

-- ----------------------------------------------------------------------------
-- 2. Bezier curves (still needed for the manual zoom interpolation)
-- ----------------------------------------------------------------------------
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

-- ----------------------------------------------------------------------------
-- 3. Disable ALL built‑in animation leaves (windows, workspaces, layers, …)
--    → Only leaves that control non‑zoom transitions are turned off.
-- ----------------------------------------------------------------------------
hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })

hl.animation({ leaf = "border",        enabled = false })
hl.animation({ leaf = "windows",       enabled = false })
hl.animation({ leaf = "windowsIn",     enabled = false })
hl.animation({ leaf = "windowsOut",    enabled = false })
hl.animation({ leaf = "fadeIn",        enabled = false })
hl.animation({ leaf = "fade",          enabled = false })
hl.animation({ leaf = "layers",        enabled = false })
hl.animation({ leaf = "layersIn",      enabled = false })
hl.animation({ leaf = "fadeLayersIn",  enabled = false })
hl.animation({ leaf = "workspaces",    enabled = false })
hl.animation({ leaf = "workspacesIn",  enabled = false })
hl.animation({ leaf = "workspacesOut", enabled = false })

-- ----------------------------------------------------------------------------
-- 4. Manual smooth cursor zoom animation (NOT part of hl.animation)

-- ----------------------------------------------------------------------------
-- 5. Optional: Bind keys for zoom in/out/toggle (example)
--    Uncomment and adjust the key names to your liking.
-- ----------------------------------------------------------------------------
-- hl.bind({ key = "XF86ZoomIn",  action = function() zoom(0.2) end })
-- hl.bind({ key = "XF86ZoomOut", action = function() zoom(-0.2) end })
-- hl.bind({ key = "Mod4+Z",      action = function() zoom() end })   -- toggle
