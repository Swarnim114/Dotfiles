hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_SIZE", "24")
hl.env("QT_CURSOR_SIZE", "24")

-- NOTE: Lua does not expand shell variables, so we use os.getenv("HOME")
local home = os.getenv("HOME")
hl.env("XDG_CACHE_HOME", home .. "/.cache")
hl.env("XDG_CONFIG_HOME", home .. "/.config")
hl.env("XDG_STATE_HOME", home .. "/.local/state")

hl.env("GDK_SCALE", "1")
hl.env("GDK_DPI_SCALE", "1")

hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_QPA_PLATFORMTHEME_QT6", "qt6ct")
