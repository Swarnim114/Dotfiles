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

-- ============================================================================
-- Zoom Module (SOLID Principles)
-- ============================================================================

_G.ZOOM_CONFIG = {
  min = 1.0,
  max = 5.0,
  toggle_factor = 3.0,
  duration = 0.4,       -- seconds
  steps = 30,           -- interpolation steps
  easing = function(t)  -- easeOutCubic
    local t2 = t - 1
    return t2 * t2 * t2 + 1
  end
}

-- Track zoom state ourselves — hl.get_config() returns the STATIC initial value,
-- not the runtime value set by hl.config(), so we can't rely on it for toggle logic.
local _current_zoom = _G.ZOOM_CONFIG.min
local active_timer  = nil

_G.animate_zoom = function(target_zoom)
  -- Cancel any running animation
  if active_timer then
    active_timer:set_enabled(false)
    active_timer = nil
  end

  if math.abs(_current_zoom - target_zoom) < 0.001 then
    return
  end

  local start_zoom      = _current_zoom
  local step            = 0
  local step_delay_ms   = math.floor((_G.ZOOM_CONFIG.duration / _G.ZOOM_CONFIG.steps) * 1000)
  local this_timer

  this_timer = hl.timer(function()
    step = step + 1
    local t = step / _G.ZOOM_CONFIG.steps

    if t >= 1 then
      _current_zoom = target_zoom
      hl.config({ cursor = { zoom_factor = _current_zoom } })
      this_timer:set_enabled(false)
      if active_timer == this_timer then
        active_timer = nil
      end
      return
    end

    local eased = _G.ZOOM_CONFIG.easing(t)
    _current_zoom = start_zoom + (target_zoom - start_zoom) * eased
    hl.config({ cursor = { zoom_factor = _current_zoom } })
  end, { timeout = step_delay_ms, type = "repeat" })

  active_timer = this_timer
end

_G.zoom = function(offset)
  local target

  if offset ~= nil then
    target = _current_zoom + offset
  elseif math.abs(_current_zoom - _G.ZOOM_CONFIG.min) > 0.05 then
    -- Currently zoomed in → zoom out
    target = _G.ZOOM_CONFIG.min
  else
    -- Currently at min → zoom in
    target = _G.ZOOM_CONFIG.toggle_factor
  end

  target = math.max(_G.ZOOM_CONFIG.min, math.min(_G.ZOOM_CONFIG.max, target))
  _G.animate_zoom(target)
end


