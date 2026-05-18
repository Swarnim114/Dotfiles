require("config.defaults")

hl.config({
  binds = {
    allow_workspace_cycles = 0,
    workspace_back_and_forth = 0,
    workspace_center_on = 1,
    movefocus_cycles_fullscreen = true,
    window_direction_monitor_fallback = true
  }
})

local mainMod = "SUPER"

-- ======= Application Launchers =======
hl.bind(mainMod .. " + SPACE",       hl.dsp.exec_cmd(_G.terminal))
hl.bind(mainMod .. " + RETURN",      hl.dsp.exec_cmd(_G.browser))
hl.bind(mainMod .. " + F",           hl.dsp.exec_cmd(_G.filemanager))
hl.bind(mainMod .. " + M",           hl.dsp.exec_cmd(_G.music))
hl.bind(mainMod .. " + E",           hl.dsp.exec_cmd(_G.editor))
hl.bind(mainMod .. " + N",           hl.dsp.exec_cmd(_G.notetaking))
hl.bind(mainMod .. " + S",           hl.dsp.exec_cmd(_G.shell_settings))
hl.bind(mainMod .. " + SHIFT + T",   hl.dsp.exec_cmd(_G.shell_theme_toggle))
hl.bind(mainMod .. " + P",           hl.dsp.exec_cmd(_G.shell_processlist))
hl.bind(mainMod .. " + D",           hl.dsp.exec_cmd(_G.shell_launcher))
hl.bind(mainMod .. " + TAB",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + F",   hl.dsp.exec_cmd(_G.shell_focus_mode))
hl.bind(mainMod .. " + V",           hl.dsp.exec_cmd(_G.shell_clipboard))
hl.bind(mainMod .. " + SHIFT + P",   hl.dsp.exec_cmd("gnome-calculator"))
hl.bind(mainMod .. " + SHIFT + C",   hl.dsp.exec_cmd("code ~/.config/"))

-- ======= System & Power =======
hl.bind(mainMod .. " + SHIFT + SPACE", hl.dsp.exec_cmd(_G.shell_powermenu))
hl.bind(mainMod .. " + SHIFT + Q",     hl.dsp.exec_cmd(_G.shell_lock))
hl.bind(mainMod .. " + CTRL + R",      hl.dsp.exec_cmd("bash -c 'pkill waybar; sleep 0.5; waybar &'"))
hl.bind(mainMod .. " + SHIFT + R",     hl.dsp.exec_cmd("pkill qs; " .. _G.shell_daemon))
hl.bind(mainMod .. " + SHIFT + W",     hl.dsp.exec_cmd("qs -c noctalia-shell ipc call plugin:wallcards toggle"))

-- ======= Screenshot =======
hl.bind(mainMod .. " + A",           hl.dsp.exec_cmd(_G.shell_screenshot_area))
hl.bind(mainMod .. " + SHIFT + A",   hl.dsp.exec_cmd(_G.shell_screenshot_full))

-- ======= Window Actions =======
hl.bind(mainMod .. " + Q",           hl.dsp.window.close())
hl.bind(mainMod .. " + C",           hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + C",           hl.dsp.exec_cmd("hyprctl dispatch resizeactive exact 1000 600"))
hl.bind(mainMod .. " + C",           hl.dsp.exec_cmd("hyprctl dispatch centerwindow"))
hl.bind(mainMod .. " + W",           hl.dsp.window.fullscreen({ mode = 0 }))
hl.bind("ALT + W",                   hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind(mainMod .. " + X",           hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + slash",       hl.dsp.focus({ workspace = "previous" }))

hl.bind(mainMod .. " + mouse:272",   hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273",   hl.dsp.window.resize(), { mouse = true })

-- switcher
hl.bind("ALT + Tab",         hl.dsp.exec_cmd("snappy-switcher next"))
hl.bind("ALT + SHIFT + Tab", hl.dsp.exec_cmd("snappy-switcher prev"))

-- --- Move Focus ---
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + T",     hl.dsp.exec_cmd("sudo ~/.config/hypr/scripts/restart-trackpad.sh"))
hl.bind(mainMod .. " + H",     hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L",     hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K",     hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J",     hl.dsp.focus({ direction = "down" }))

-- --- Move Window ---
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + H",     hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L",     hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K",     hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J",     hl.dsp.window.move({ direction = "down" }))

-- --- Resize Mode ---
hl.bind(mainMod .. " + Z",             hl.dsp.window.resize(), { mouse = true })

-- --- Quick Resize ---
hl.bind(mainMod .. " + CTRL + SHIFT + right", hl.dsp.exec_cmd("hyprctl dispatch resizeactive 15 0"))
hl.bind(mainMod .. " + CTRL + SHIFT + left",  hl.dsp.exec_cmd("hyprctl dispatch resizeactive -15 0"))
hl.bind(mainMod .. " + CTRL + SHIFT + up",    hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 -15"))
hl.bind(mainMod .. " + CTRL + SHIFT + down",  hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 15"))
hl.bind(mainMod .. " + CTRL + SHIFT + l",     hl.dsp.exec_cmd("hyprctl dispatch resizeactive 15 0"))
hl.bind(mainMod .. " + CTRL + SHIFT + h",     hl.dsp.exec_cmd("hyprctl dispatch resizeactive -15 0"))
hl.bind(mainMod .. " + CTRL + SHIFT + k",     hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 -15"))
hl.bind(mainMod .. " + CTRL + SHIFT + j",     hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 15"))

-- ======= Workspaces =======

for i = 1, 9 do
  hl.bind(mainMod .. " + " .. i,            hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + CTRL + " .. i,     hl.dsp.window.move({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. i,    hl.dsp.window.move({ workspace = i }), { silent = true })
end
hl.bind(mainMod .. " + 0",            hl.dsp.focus({ workspace = 10 }))
hl.bind(mainMod .. " + CTRL + 0",     hl.dsp.window.move({ workspace = 10 }))
hl.bind(mainMod .. " + SHIFT + 0",    hl.dsp.window.move({ workspace = 10 }), { silent = true })

hl.bind(mainMod .. " + PERIOD",       hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + COMMA",        hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse_down",   hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",     hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.move({ workspace = "-1" }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.move({ workspace = "+1" }))

hl.bind(mainMod .. " + F1",                  hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind(mainMod .. " + ALT + SHIFT + F1",    hl.dsp.window.move({ workspace = "special:scratchpad" }), { silent = true })

-- ======= Multimedia =======
hl.bind("Print",               hl.dsp.exec_cmd(_G.shell_screenshot_full), { locked = true })
hl.bind("SUPER + SHIFT + S",   hl.dsp.exec_cmd("hyprctl dispatch global caelestia:screenshotFreeze"))

hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd(_G.shell_volume_up),    { locked = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd(_G.shell_volume_down),  { locked = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd(_G.shell_volume_mute),  { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd(_G.shell_mic_mute),     { locked = true })

hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(_G.shell_brightness_up),   { locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(_G.shell_brightness_down), { locked = true })

hl.bind(mainMod .. " + B",            hl.dsp.exec_cmd(_G.shell_wallpaper_next), { locked = true })

hl.bind(mainMod .. " + Y",            hl.dsp.exec_cmd("~/.config/hypr/shaders/cycle_shaders.sh"))
hl.bind(mainMod .. " + SHIFT + N",    hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle_nightlight.sh"))
