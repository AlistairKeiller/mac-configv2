local colors = require("colors")
local settings = require("settings")

local idle_icon = "􀊱"
local rec_icon = "●"
local frames = { "◐", "◓", "◑", "◒" }

sbar.exec("rm -f /tmp/dictate.flag")

local dictate = sbar.add("item", "widgets.dictate", {
  position = "right",
  icon = {
    string = idle_icon,
    align = "center",
    width = 28,
    padding_left = 10,
    padding_right = 10,
  },
  label = { drawing = false },
  background = { color = colors.bg1 },
})

sbar.add("item", "widgets.dictate.padding", {
  position = "right",
  width = settings.group_paddings,
})

local recording, transcribing, frame = false, false, 1
local function tick()
  if not transcribing then return end
  dictate:set({ icon = { string = frames[frame], color = colors.white } })
  frame = frame % #frames + 1
  sbar.delay(0.15, tick)
end

dictate:subscribe("mouse.clicked", function()
  if transcribing then return end
  if recording then
    recording = false
    transcribing = true
    frame = 1
    tick()
    sbar.exec("rm -f /tmp/dictate.flag")
  else
    recording = true
    dictate:set({ icon = { string = rec_icon, color = colors.red } })
    sbar.exec("touch /tmp/dictate.flag && uv run $CONFIG_DIR/helpers/dictate.py", function()
      recording = false
      transcribing = false
      dictate:set({ icon = { string = idle_icon, color = colors.white } })
    end)
  end
end)
