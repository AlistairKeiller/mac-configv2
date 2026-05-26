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

volume_slider:subscribe("volume_change", function(env)
  local volume = tonumber(env.INFO)
  local icon = icons.volume._0
  if volume > 60 then
    icon = icons.volume._100
  elseif volume > 30 then
    icon = icons.volume._66
  elseif volume > 10 then
    icon = icons.volume._33
  elseif volume > 0 then
    icon = icons.volume._10
  end

  last_set = volume
  volume_icon:set({ icon = icon })
  volume_slider:set({ slider = { percentage = volume } })
end)

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
