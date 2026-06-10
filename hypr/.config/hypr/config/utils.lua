local state_file = "/tmp/hypr_focus_mode"

local function file_exists(path)
  local f = io.open(path, "r")
  if f then
    f:close()
    return true
  end
  return false
end

_G.toggle_focus_mode = function()
  if file_exists(state_file) then
    -- Disable focus mode (restore layout)
    hl.config({
      general = {
        gaps_in = _G.normal_gaps_in,
        gaps_out = _G.normal_gaps_out,
        border_size = _G.normal_border_size
      },
      decoration = {
        rounding = _G.normal_rounding,
        shadow = {
          enabled = _G.normal_shadow
        }
      }
    })
    hl.workspace_rule({ workspace = "w[tv1]", border_size = _G.normal_border_size })
    hl.exec_cmd("noctalia msg bar-toggle")
    os.remove(state_file)
  else
    -- Enable focus mode
    hl.config({
      general = {
        gaps_in = _G.focus_gaps_in,
        gaps_out = _G.focus_gaps_out,
        border_size = _G.focus_border_size
      },
      decoration = {
        shadow = {
          enabled = _G.focus_shadow
        }
      }
    })
    hl.workspace_rule({ workspace = "w[tv1]", border_size = 0 })
    hl.exec_cmd("noctalia msg bar-toggle")
    local f = io.open(state_file, "w")
    if f then
      f:write("")
      f:close()
    end
  end
end

_G.take_screenshot = function(mode)
  local output_dir = os.getenv("HOME") .. "/Pictures/Screenshots"
  hl.exec_cmd("mkdir -p " .. output_dir)

  local timestamp = os.date("%Y-%m-%d_%H-%M-%S")

  if mode == "full" then
    local filename = output_dir .. "/screenshot-full-" .. timestamp .. ".png"
    hl.exec_cmd("grim - | tee " .. filename .. " | wl-copy --type image/png")
  else
    hl.exec_cmd("pkill slurp") -- Kill any active selection tool
    local filename = output_dir .. "/screenshot-" .. timestamp .. ".png"
    local m = mode or "region"
    hl.exec_cmd("hyprshot -m " .. m .. " --raw | tee " .. filename .. " | wl-copy --type image/png")
  end
end

_G.restart_trackpad = function()
    hl.exec_cmd("sudo modprobe -r i2c_hid_acpi && sudo modprobe i2c_hid_acpi")
end

