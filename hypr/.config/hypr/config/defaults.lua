_G.filemanager = "nautilus"
_G.editor = "zeditor"
_G.draw = "helium-browser --app=https://excalidraw.com/"
_G.music = "spotify"
_G.notetaking = "obsidian"
_G.browser = "helium-browser"
_G.applauncher = "rofi -show drun"
_G.terminal = "kitty"
_G.idlehandler = "hypridle"
_G.capturing = "grim -g \"$(slurp)\" - | swappy -f -"
_G.wallpaper = "~/.config/themes/current/background"

-- Focus mode variables
_G.normal_gaps_in = 4
_G.normal_gaps_out = 6
_G.normal_border_size = 2
_G.normal_rounding = 0
_G.normal_shadow = true

_G.focus_gaps_in = 0
_G.focus_gaps_out = 0
_G.focus_border_size = 1
_G.focus_shadow = false



require("config.shells.noctalia-v5")
require("config.utils")
require("config.matugen")
