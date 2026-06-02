local colors = require("colors")
local settings = require("settings")

local idle_icon = "􀌮"
local frames = { "◐", "◓", "◑", "◒" }

local speak = sbar.add("item", "widgets.speak", {
  position = "right",
  icon = {
    string = idle_icon,
    align = "center",
    width = 28,
    padding_left = 8,
    padding_right = 12,
  },
  label = { drawing = false },
  background = { color = colors.bg1 },
})

sbar.add("item", "widgets.speak.padding", {
  position = "right",
  width = settings.group_paddings,
})

local busy, frame = false, 1
local function tick()
  if not busy then return end
  speak:set({ icon = { string = frames[frame], padding_left = 10, padding_right = 10 } })
  frame = frame % #frames + 1
  sbar.delay(0.15, tick)
end

speak:subscribe("mouse.clicked", function()
  if busy then return end
  busy, frame = true, 1
  tick()
  sbar.exec("uv run $CONFIG_DIR/helpers/speak.py", function()
    busy = false
    speak:set({ icon = { string = idle_icon, padding_left = 8, padding_right = 12 } })
  end)
end)
