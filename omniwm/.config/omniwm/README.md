# OmniWM

OmniWM accepts exactly one complete, strict-schema `settings.toml`; it has no native include or import directive. The files in `modules/` are therefore the editable source of truth, and `build.sh` renders them into the live configuration file.

```sh
~/dotfiles/omniwm/.config/omniwm/build.sh
```

The numeric prefixes define render order. Do not edit `~/.config/omniwm/settings.toml` directly: a later render replaces it. Do not use the OmniWM Settings window for persistent edits either, because it writes the generated output rather than a module.

Modules correspond to the prior Hyprland layout: global appearance, Dwindle layout, focus/input, gaps, general behavior, gestures, interface surfaces, app rules, hotkeys, and workspaces.

After a render, OmniWM live-reloads the complete file. Verify it with:

```sh
omniwmctl query workspaces
```
