local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local slider_width = 100

local volume_slider = sbar.add("slider", slider_width, {
  position = "right",
  padding_left = 4,
  padding_right = 8,
  label = { drawing = false },
  icon = { drawing = false },
  slider = {
    highlight_color = colors.blue,
    background = {
      height = 5,
      corner_radius = 3,
      color = colors.bg2,
    },
    knob = {
      string = "􀀁",
      drawing = true,
    },
  },
  click_script = 'osascript -e "set volume output volume $PERCENTAGE"',
})

local volume_icon = sbar.add("item", "widgets.volume.icon", {
  position = "right",
  padding_left = 8,
  padding_right = 0,
  icon = {
    string = icons.volume._100,
    color = colors.grey,
    font = {
      style = settings.font.style_map["Regular"],
      size = 14.0,
    },
  },
  label = { drawing = false },
  update_freq = 5,
})

sbar.add("bracket", "widgets.volume.bracket", {
  volume_icon.name,
  volume_slider.name,
}, {
  background = { color = colors.bg1 },
})

sbar.add("item", "widgets.volume.padding", {
  position = "right",
  width = settings.group_paddings,
})

local last_set = -1
local current_volume = 0
local is_headphones = false

local function pick_icon()
  if is_headphones then
    if current_volume == 0 then return icons.volume.headphones_off end
    return icons.volume.headphones
  end
  if current_volume > 60 then return icons.volume._100 end
  if current_volume > 30 then return icons.volume._66 end
  if current_volume > 10 then return icons.volume._33 end
  if current_volume > 0 then return icons.volume._10 end
  return icons.volume._0
end

local function refresh_device()
  sbar.exec([=[system_profiler SPAudioDataType 2>/dev/null | awk '
    /^        [^ ]/ { mode = "scan" }
    mode == "scan" && /Default Output Device: Yes/ { mode = "found" }
    mode == "found" && /Transport: / { sub(/^[[:space:]]+Transport:[[:space:]]+/, ""); print tolower($0); exit }
  ']=], function(result)
    local transport = (result or ""):gsub("%s+$", "")
    local hp = transport ~= "" and transport ~= "built-in"
    if hp ~= is_headphones then
      is_headphones = hp
      volume_icon:set({ icon = pick_icon() })
    end
  end)
end

volume_slider:subscribe("volume_change", function(env)
  current_volume = tonumber(env.INFO) or 0
  last_set = current_volume
  volume_icon:set({ icon = pick_icon() })
  volume_slider:set({ slider = { percentage = current_volume } })
  refresh_device()
end)

volume_icon:subscribe({ "routine", "system_woke", "forced" }, refresh_device)

volume_icon:subscribe("mouse.clicked", function()
  sbar.exec("open /System/Library/PreferencePanes/Sound.prefpane")
end)

-- Sketchybar slider intentionally only fires on drag release; poll while hovered to track the drag live.
local hovering = false
local polling_active = false
local pending = false

local function poll_slider()
  if not hovering then
    polling_active = false
    return
  end
  local q = volume_slider:query()
  if q and q.slider then
    local p = tonumber(q.slider.percentage)
    if p and p ~= last_set and not pending then
      last_set = p
      pending = true
      sbar.exec('osascript -e "set volume output volume ' .. p .. '"', function()
        pending = false
      end)
    end
  end
  sbar.delay(0.05, poll_slider)
end

volume_slider:subscribe("mouse.entered", function()
  hovering = true
  if not polling_active then
    polling_active = true
    poll_slider()
  end
end)

volume_slider:subscribe("mouse.exited", function()
  hovering = false
end)
