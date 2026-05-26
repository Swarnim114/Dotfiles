_G.filemanager = "nautilus"
_G.editor = "zed"
_G.music = "spotify"
_G.notetaking = "obsidian"
_G.browser = "helium-browser"
_G.applauncher = "rofi -show drun"
_G.terminal = "kitty"
_G.idlehandler = "hypridle"
_G.capturing = "grim -g \"$(slurp)\" - | swappy -f -"
_G.wallpaper = "~/.config/themes/current/background"

-- Focus mode variables
_G.normal_gaps_in = 6
_G.normal_gaps_out = 8
_G.normal_border_size = 3
_G.normal_rounding = 0
_G.normal_shadow = true

_G.focus_gaps_in = 0
_G.focus_gaps_out = 0
_G.focus_border_size = 1
_G.focus_shadow = false

require("config.shells.noctalia-v5")
