local M = {}

local home = os.getenv("HOME")
local colors_json_path = home .. "/.config/noctalia/colors.json"
local settings_json_path = home .. "/.config/noctalia/settings.json"

local function file_exists(path)
  local f = io.open(path, "r")
  if f then
    f:close()
    return true
  end
  return false
end

local function mkdir(path)
  os.execute("mkdir -p '" .. path .. "'")
end

local function parse_simple_json(filepath)
  local f = io.open(filepath, "r")
  if not f then return nil end
  local content = f:read("*a")
  f:close()

  local data = {}
  -- match string keys and string values: "key": "value"
  for k, v in content:gmatch('%"([^%"]+)%"%s*:%s*%"([^%"]+)%"') do
    data[k] = v
  end
  -- match booleans
  for k in content:gmatch('%"([^%"]+)%"%s*:%s*true') do
    data[k] = true
  end
  for k in content:gmatch('%"([^%"]+)%"%s*:%s*false') do
    data[k] = false
  end
  return data
end

local function use_wallpaper_colors(settings_path)
  local f = io.open(settings_path, "r")
  if not f then return false end
  local content = f:read("*a")
  f:close()
  return content:match('"useWallpaperColors"%s*:%s*true') ~= nil
end

local function hex_to_rgb(hex)
  hex = hex:gsub("#", "")
  local r = tonumber(hex:sub(1, 2), 16) / 255
  local g = tonumber(hex:sub(3, 4), 16) / 255
  local b = tonumber(hex:sub(5, 6), 16) / 255
  return r, g, b
end

local function rgb_to_hls(r, g, b)
  local max = math.max(r, g, b)
  local min = math.min(r, g, b)
  local h, l, s = 0, (max + min) / 2, 0

  if max ~= min then
    local d = max - min
    if l > 0.5 then
      s = d / (2 - max - min)
    else
      s = d / (max + min)
    end

    if max == r then
      h = (g - b) / d
      if g < b then h = h + 6 end
    elseif max == g then
      h = (b - r) / d + 2
    elseif max == b then
      h = (r - g) / d + 4
    end
    h = h / 6
  end
  return h, l, s
end

local function h_to_rgb(p, q, t)
  if t < 0 then t = t + 1 end
  if t > 1 then t = t - 1 end
  if t < 1/6 then return p + (q - p) * 6 * t end
  if t < 1/2 then return q end
  if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
  return p
end

local function hls_to_rgb(h, l, s)
  local r, g, b
  if s == 0 then
    r, g, b = l, l, l
  else
    local q
    if l < 0.5 then
      q = l * (1 + s)
    else
      q = l + s - l * s
    end
    local p = 2 * l - q
    r = h_to_rgb(p, q, h + 1/3)
    g = h_to_rgb(p, q, h)
    b = h_to_rgb(p, q, h - 1/3)
  end
  return r, g, b
end

local function hue_dist(a, b)
  local d = math.abs(a - b) % 360
  return math.min(d, 360 - d)
end

local function adjust_lightness(hex_color, delta)
  local r, g, b = hex_to_rgb(hex_color)
  local h, l, s = rgb_to_hls(r, g, b)
  l = math.max(0.0, math.min(1.0, l + delta))
  local r2, g2, b2 = hls_to_rgb(h, l, s)
  return string.format("#%02x%02x%02x", math.floor(r2 * 255 + 0.5), math.floor(g2 * 255 + 0.5), math.floor(b2 * 255 + 0.5))
end

-- 1. Sync Icons (Colloid) and Qt themes
local function sync_icons_and_qt(colors, theme_mode)
  if file_exists(settings_json_path) and use_wallpaper_colors(settings_json_path) then
    print("Skipping Colloid theme change: colors fetched from wallpaper.")
    return
  end

  local ACCENTS = {
    Red = 15,
    Orange = 30,
    Yellow = 50,
    Green = 120,
    Teal = 175,
    Purple = 270,
    Pink = 330
  }
  
  local primary_hex = colors.mPrimary or "#6272a4"
  local r, g, b = hex_to_rgb(primary_hex)
  local h, l, s = rgb_to_hls(r, g, b)
  
  local accent = "Purple"
  if s >= 0.15 then
    local hue_deg = h * 360
    local min_dist = 360
    for name, hue in pairs(ACCENTS) do
      local dist = hue_dist(hue_deg, hue)
      if dist < min_dist then
        min_dist = dist
        accent = name
      end
    end
  end

  local suffix = (theme_mode == "light") and "Light" or "Dark"
  local theme = "Colloid-" .. accent .. "-" .. suffix

  -- Check if folder exists
  local path_check = "/usr/share/icons/" .. theme
  local f = io.open(path_check, "r")
  if not f then
    theme = "Colloid-" .. suffix
  else
    f:close()
  end

  print("Colloid: accent=" .. accent .. " mode=" .. suffix .. " -> " .. theme)
  os.execute("gsettings set org.gnome.desktop.interface icon-theme '" .. theme .. "'")

  -- Sync Qt5/Qt6 icon themes
  local qt5_conf = home .. "/.config/qt5ct/qt5ct.conf"
  local qt6_conf = home .. "/.config/qt6ct/qt6ct.conf"
  for _, conf in ipairs({qt5_conf, qt6_conf}) do
    if file_exists(conf) then
      local fh = io.open(conf, "r")
      local content = fh:read("*a")
      fh:close()
      content = content:gsub("icon_theme=[^\n]*", "icon_theme=" .. theme)
      local fh_out = io.open(conf, "w")
      fh_out:write(content)
      fh_out:close()
    end
  end

  -- Sync Qt Palette
  local roles = {
    colors.mOnSurface or "#f4ded9",
    colors.mSurface or "#1c110e",
    "#ffffff",
    "#cacaca",
    "#9f9f9f",
    "#b8b8b8",
    colors.mOnSurface or "#f4ded9",
    "#ffffff",
    colors.mOnSurface or "#f4ded9",
    colors.mSurface or "#1c110e",
    colors.mSurface or "#1c110e",
    colors.mShadow or "#000000",
    colors.mPrimary or "#6272a4",
    colors.mOnPrimary or "#ffffff",
    colors.mSecondary or "#6272a4",
    colors.mTertiary or "#6272a4",
    colors.mSurfaceVariant or "#291d1a",
    colors.mSurface or "#1c110e",
    colors.mSurfaceVariant or "#291d1a",
    colors.mOnSurface or "#f4ded9",
    colors.mOnSurface or "#f4ded9",
    colors.mPrimary or "#6272a4"
  }
  local active_colors = table.concat(roles, ", ")
  local palette_content = "[ColorScheme]\nactive_colors=" .. active_colors .. "\ndisabled_colors=" .. active_colors .. "\ninactive_colors=" .. active_colors .. "\n"

  local palettes = {
    home .. "/.config/qt5ct/colors/noctalia.conf",
    home .. "/.config/qt6ct/colors/noctalia.conf"
  }
  for _, path in ipairs(palettes) do
    mkdir(path:match("(.*/)[^/]*$"))
    local fh = io.open(path, "w")
    if fh then
      fh:write(palette_content)
      fh:close()
    end
  end
end

-- 2. Sync Micro editor
local function sync_micro(colors)
  local micro_dir = home .. "/.config/micro/colorschemes"
  mkdir(micro_dir)

  local bg = colors.mSurface or "#1c110e"
  local fg = colors.mOnSurface or "#f4ded9"
  local primary = colors.mPrimary or "#6272a4"
  local secondary = colors.mSecondary or "#6272a4"
  local tertiary = colors.mTertiary or "#6272a4"
  local error = colors.mError or "#ffb4ab"
  local on_error = colors.mOnError or "#ffffff"
  local sv = colors.mSurfaceVariant or "#291d1a"
  local osv = colors.mOnSurfaceVariant or "#505857"
  local outline = colors.mOutline or "#8ec07c"

  local theme_content = string.format([[
color-link default "%s,%s"
color-link comment "%s"
color-link constant "%s"
color-link constant.string "%s"
color-link constant.string.char "%s"
color-link type "%s"
color-link variable "%s"
color-link variable.arg "%s"
color-link symbol "%s"
color-link symbol.tag "%s"
color-link keyword "%s"
color-link special "%s"
color-link preproc "%s"
color-link statement "%s"
color-link string "%s"
color-link number "%s"
color-link bool "%s"
color-link error "%s,%s"
color-link warn "%s"
color-link cursor-line "%s"
color-link cursor "#ffffff,%s"
color-link selection "#ffffff,%s"
color-link line-number "%s"
color-link gutter-background "%s"
color-link gutter-foreground "%s"
color-link whitespace "%s"
]], fg, bg, osv, tertiary, tertiary, secondary, secondary, fg, primary, primary, primary, primary, primary, secondary, primary, tertiary, secondary, secondary, error, on_error, secondary, sv, primary, outline, osv, bg, osv, outline)

  local fh = io.open(micro_dir .. "/noctalia.micro", "w")
  if fh then
    fh:write(theme_content)
    fh:close()
  end
end

-- 3. Sync Obsidian
local function sync_obsidian(colors)
  local theme_dir = home .. "/Notes/.obsidian/themes/Noctalia"
  mkdir(theme_dir)

  local p = colors.mPrimary or "#6272a4"
  local op = colors.mOnPrimary or "#ffffff"
  local s = colors.mSecondary or "#6272a4"
  local err = colors.mError or "#ffb4ab"
  local bg = colors.mSurface or "#1c110e"
  local fg = colors.mOnSurface or "#f4ded9"
  local sv = colors.mSurfaceVariant or "#291d1a"
  local osv = colors.mOnSurfaceVariant or "#505857"
  local outline = colors.mOutline or "#8ec07c"
  local shadow = colors.mShadow or "#000000"
  local hover = colors.mHover or "#ffffff"

  local css_content = string.format([[
/* Noctalia theme for Obsidian generated from matugen colors */
.theme-dark, .theme-light {
    --bg2: %s;
    --bg1: %s;
    --bg3: %s;
    --ui1: %s;
    --ui2: %s;
    --ui3: %s;
    --tx1: %s;
    --tx2: %s;
    --tx3: %s;
    --hl1: %s;
    --hl2: %s;

    --background-primary: %s;
    --background-primary-alt: %s;
    --background-secondary: %s;
    --background-secondary-alt: %s;

    --text-normal: %s;
    --text-muted: %s;
    --text-faint: %s;
    --text-accent: %s;
    --text-accent-hover: %s;
    
    --text-error: %s;

    --interactive-normal: %s;
    --interactive-hover: %s;
    --interactive-accent: %s;
    --interactive-accent-hover: %s;
    
    --text-on-accent: %s;
    
    --titlebar-background: %s;
    --titlebar-text: %s;
}
]], bg, sv, sv, sv, outline, outline, fg, osv, osv, p, s, bg, sv, sv, bg, fg, osv, shadow, p, hover, err, sv, hover, p, hover, op, bg, fg)

  local fh = io.open(theme_dir .. "/theme.css", "w")
  if fh then
    fh:write(css_content)
    fh:close()
  end

  local manifest_content = [[
{
    "name": "Noctalia",
    "version": "1.0.0",
    "minAppVersion": "1.0.0",
    "author": "Script Generated"
}
]]
  local fm = io.open(theme_dir .. "/manifest.json", "w")
  if fm then
    fm:write(manifest_content)
    fm:close()
  end
end

-- 4. Sync Sioyek PDF reader
local function sync_sioyek(colors)
  local sioyek_conf = home .. "/.config/sioyek/prefs_user.config"
  if not file_exists(sioyek_conf) then return end

  local bg_hex = colors.mSurface or "#1c110e"
  local text_hex = colors.mOnSurface or "#f4ded9"

  local function hex_to_float_string(hex)
    local r, g, b = hex_to_rgb(hex)
    return string.format("%.2f %.2f %.2f", r, g, b)
  end

  local bg_rgb = hex_to_float_string(bg_hex)
  local text_rgb = hex_to_float_string(text_hex)

  local fh = io.open(sioyek_conf, "r")
  local content = fh:read("*a")
  fh:close()

  local keys = {
    custom_background_color = bg_rgb,
    custom_text_color = text_rgb,
    custom_color_mode_empty_background_color = bg_rgb,
    inverted_background_color = bg_rgb,
    inverted_text_color = text_rgb,
    inverted_color_mode_empty_background_color = bg_rgb,
  }

  for k, v in pairs(keys) do
    if content:match("\n" .. k .. " ") or content:match("^" .. k .. " ") then
      content = content:gsub("(" .. k .. "%s+)[^\n]*", "%1" .. v)
    else
      if content ~= "" and content:sub(-1) ~= "\n" then
        content = content .. "\n"
      end
      content = content .. k .. " " .. v .. "\n"
    end
  end

  local fh_out = io.open(sioyek_conf, "w")
  if fh_out then
    fh_out:write(content)
    fh_out:close()
  end
end

-- 5. Sync Snappy Switcher
local function sync_snappy(colors, theme_mode)
  local snappy_theme = home .. "/.config/snappy-switcher/themes/noctalia.ini"
  local snappy_config = home .. "/.config/snappy-switcher/config.ini"
  if not file_exists(snappy_config) then return end

  local p = colors.mPrimary or "#1ea995"
  local op = colors.mOnPrimary or "#030404"
  local surface = colors.mSurface or "#e2e9e8"
  local sv = colors.mSurfaceVariant or "#d6e0df"
  local os = colors.mOnSurface or "#181b1a"
  local osv = colors.mOnSurfaceVariant or "#505857"

  local r, g, b = hex_to_rgb(surface)
  local luminance = (r * 255 * 299 + g * 255 * 587 + b * 255 * 114) / 1000

  local card_selected
  if luminance > 128 then
    card_selected = adjust_lightness(sv, -0.1)
  else
    card_selected = adjust_lightness(sv, 0.1)
  end

  local function aa(hex, alpha)
    return hex:gsub("#", "") .. alpha
  end

  local theme_content = string.format([[
# Noctalia — auto-generated by matugen.lua
# Mode: %s  |  DO NOT EDIT

[colors]
background       = %s
card_bg          = %s
card_selected    = %s
border_color     = %s
text_color       = %s
subtext_color    = %s
bundle_bg        = %s
badge_bg         = %s
badge_text_color = %s
]], theme_mode, aa(surface, "ee"), aa(sv, "ff"), aa(card_selected, "ff"), aa(p, "ff"), aa(os, "ff"), aa(osv, "ff"), aa(sv, "cc"), aa(p, "ff"), aa(op, "ff"))

  mkdir(snappy_theme:match("(.*/)[^/]*$"))
  local fh = io.open(snappy_theme, "w")
  if fh then
    fh:write(theme_content)
    fh:close()
  end

  -- Patch snappy config
  local fh_cfg = io.open(snappy_config, "r")
  local cfg_content = fh_cfg:read("*a")
  fh_cfg:close()

  cfg_content = cfg_content:gsub("name = [^\n]*", "name = noctalia.ini")
  cfg_content = cfg_content:gsub("border_width = [^\n]*", "border_width = 3")
  cfg_content = cfg_content:gsub("corner_radius = [^\n]*", "corner_radius = 0")

  local fh_cfg_out = io.open(snappy_config, "w")
  if fh_cfg_out then
    fh_cfg_out:write(cfg_content)
    fh_cfg_out:close()
  end

  -- Restart snappy switcher daemon asynchronously
  os.execute("pgrep -x snappy-switcher && snappy-switcher quit; sleep 0.3; snappy-switcher --daemon &")
end

-- 6. Sync Spotify (Spicetify)
local function sync_spotify(colors)
  local theme_dir = home .. "/.config/spicetify/Themes/Noctalia"
  mkdir(theme_dir)

  local function get_c(key, fallback)
    local val = colors[key]
    if not val or val == "" then
      val = colors[fallback] or "e9f1da"
    end
    return val:gsub("#", "")
  end

  local ms = get_c("mSurface")
  local mos = get_c("mOnSurface")
  local msv = get_c("mSurfaceVariant", "mSurface")
  local mosv = get_c("mOnSurfaceVariant", "mOnSurface")
  local mp = get_c("mPrimary")
  local mop = get_c("mOnPrimary", "mOnSurface")
  local msec = get_c("mSecondary", "mPrimary")
  local mout = get_c("mOutline", "mOnSurfaceVariant")
  local merr = get_c("mError")
  local mshad = get_c("mShadow", "mSurfaceVariant")

  local ini_content = string.format([[
[Noctalia]
text               = %s
subtext            = %s
main               = %s
sidebar            = %s
player             = %s
card               = %s
shadow             = %s
selected-row       = %s
button             = %s
button-active      = %s
button-disabled    = %s
tab-active         = %s
notification       = %s
notification-error = %s
misc               = %s
]], mos, mosv, ms, msv, msv, msv, mshad, mout, mp, msec, mout, msec, msec, merr, msv)

  local fh = io.open(theme_dir .. "/color.ini", "w")
  if fh then
    fh:write(ini_content)
    fh:close()
  end

  local css_content = string.format([[
/* Inject CSS variables overriding Spotify's modern internal variables */
:root, .Root__top-container, #main, .Root__main-view, .main-view-container, [data-theme], body {
    --background-base: #%s !important;
    --background-highlight: #%s !important;
    --background-press: #%s !important;
    --background-elevated-base: #%s !important;
    --background-elevated-highlight: #%s !important;
    --background-elevated-press: #%s !important;
    --background-tinted-base: #%s !important;
    --background-tinted-highlight: #%s !important;
    --background-tinted-press: #%s !important;
    
    --text-base: #%s !important;
    --text-subdued: #%s !important;
    --text-bright: #%s !important;
    --text-negative: #%s !important;
    --text-warning: #%s !important;
    
    --essential-base: #%s !important;
    --essential-subdued: #%s !important;
    --essential-bright: #%s !important;
    --essential-warning: #%s !important;
}

/* Fix muddy gradients that extract colors from covers */
.main-home-homeHeader,
.main-entityHeader-backgroundColor,
.main-entityHeader-overlay,
.main-entityHeader-background,
.main-entityHeader-withBackgroundImage,
.main-actionBarBackground-background {
    background: transparent !important;
    background-image: none !important;
    box-shadow: none !important;
}

/* Specific component fixes */
/* Artist cards and standard cards */
.main-card-card, 
.artist-artistAbout-container, 
.main-trackCreditsModal-container,
.main-aboutRecsModal-container,
.search-searchCategory-SearchCategory {
    background-color: var(--background-elevated-base) !important;
    color: var(--text-base) !important;
}

/* Make sure PRIMARY big play buttons are the main focus color, 
   but leave inline/recently played small list buttons alone */
.main-playButton-Primary {
    background-color: var(--essential-base) !important;
    color: #%s !important;
}
/* Ensure the inner SVG doesn't grab a solid background block */
.main-playButton-Primary svg, .main-playButton-PlayButton svg {
    background-color: transparent !important;
}

/* Force recently played / inline list play buttons to inherit their natural transparent backgrounds */
.main-trackList-rowPlayPauseButton,
.main-yourLibraryX-listRow .main-playButton-PlayButton,
li .main-playButton-PlayButton {
    background-color: transparent !important;
    color: var(--text-base) !important;
}

/* Category Filter Chips */
.ChipInner__ChipInnerComponent-sc-1ly6j4j-0 {
    background-color: var(--background-highlight) !important;
    color: var(--text-base) !important;
}
.ChipInner__ChipInnerComponent-sc-1ly6j4j-0[aria-checked="true"] {
    background-color: var(--essential-base) !important;
    color: #%s !important;
}

/* Global Nav bar components */
.main-globalNav-historyButtons .main-globalNav-icon,
.main-globalNav-searchContainer input {
    background-color: var(--background-highlight) !important;
    color: var(--text-base) !important;
}
/* Ensure search icon resolves properly inside the input wrapper */
.main-globalNav-searchContainer .main-globalNav-searchIcon {
    color: var(--text-base) !important;
}
]], ms, msv, msv, msv, mout, mout, msv, mout, mout, mos, mosv, mos, merr, merr, mp, mout, msec, merr, mop, mop)

  local fh_css = io.open(theme_dir .. "/user.css", "w")
  if fh_css then
    fh_css:write(css_content)
    fh_css:close()
  end
end

M.sync = function(theme_mode)
  theme_mode = theme_mode or "dark"
  local colors = parse_simple_json(colors_json_path)
  if not colors then
    print("Error: colors.json not found at " .. colors_json_path)
    return false
  end

  print("Syncing all themes to Noctalia palette in mode: " .. theme_mode)
  sync_icons_and_qt(colors, theme_mode)
  sync_micro(colors)
  sync_obsidian(colors)
  sync_sioyek(colors)
  sync_snappy(colors, theme_mode)
  sync_spotify(colors)
  print("✓ Theme synchronization completed successfully!")
  return true
end

-- Expose globally
_G.sync_matugen = M.sync

return M
