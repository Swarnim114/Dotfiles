hl.window_rule({
  name = "windowrule-1",
  float = true,
  match = { class = "^(org.pulseaudio.pavucontrol|blueman-manager|CachyOSHello|zenity|qalculate-gtk)$" }
})



hl.window_rule({
  name = "windowrule-2",
  float = true,
  match = { class = "^(xdg-desktop-portal-gtk|xdg-desktop-portal-kde|xdg-desktop-portal-hyprland).*" }
})

hl.window_rule({
  name = "windowrule-3",
  float = true,
  match = { class = "^(polkit-gnome-authentication-agent-1|hyprpolkitagent|org.kde.polkit-kde-authentication-agent-1).*" }
})

hl.window_rule({
  name = "windowrule-4",
  float = true,
  match = { title = "^(Picture in picture|Save File|Open File|Steam - Self Updater)$" }
})


hl.window_rule({
  name = "windowrule-6",
  border_size = 0,
  match = { title = "^.*wants.*" }
})



hl.window_rule({
  name = "windowrule-8",
  float = true,
  center = true,
  match = { title = "^(imv|mpv|danmufloat|termfloat|nemo|ncmpcpp|Calculator|Volume Control|WebApp Installer|Proton VPN|Installer|satty|org.gnome.Nautilus|Blanket|Nautilus)$" }
})

hl.window_rule({
  name = "windowrule-9",
  size = "800 600",
  match = { title = "^(imv|mpv|danmufloat|termfloat|nemo|ncmpcpp|Calculator|Volume Control|WebApp Installer|Installer|satty|org.gnome.Nautilus|Blanket|Nautilus)$" }
})


hl.window_rule({
  name = "windowrule-11",
  pin = true,
  match = { title = "^(danmufloat)$" }
})

hl.window_rule({
  name = "windowrule-12",
  rounding = 5,
  match = { title = "^(danmufloat|termfloat)$" }
})


for i = 1, 10 do
  hl.workspace_rule({
    workspace = i,
    persistent = true
  })
end
