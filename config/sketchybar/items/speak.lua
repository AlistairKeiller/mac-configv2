local colors = require("colors")
local settings = require("settings")

sbar.add("item", "widgets.speak", {
  position = "right",
  icon = {
    string = "􀒎",
    padding_right = 8,
    padding_left = 8,
  },
  label = { drawing = false },
  background = { color = colors.bg1 },
  click_script = "nohup uv run $CONFIG_DIR/helpers/speak.py >/dev/null 2>&1 &",
})

sbar.add("item", "widgets.speak.padding", {
  position = "right",
  width = settings.group_paddings,
})
