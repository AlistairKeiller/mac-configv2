local colors = require("colors")
local settings = require("settings")

sbar.add("event", "aerospace_workspace_change")

local spaces = {}
local brackets = {}

for i = 1, 9 do
  local sid = tostring(i)

  local space = sbar.add("item", "space." .. sid, {
    icon = {
      font = { family = settings.font.numbers },
      string = sid,
      padding_left = 15,
      padding_right = 15,
      color = colors.white,
      highlight_color = colors.blue,
    },
    label = { drawing = false },
    padding_right = 1,
    padding_left = 1,
    background = {
      color = colors.bg1,
      border_width = 1,
      height = 26,
      border_color = colors.black,
    },
  })

  spaces[sid] = space

  local bracket = sbar.add("bracket", "space.bracket." .. sid, { space.name }, {
    background = {
      color = colors.transparent,
      border_color = colors.bg2,
      height = 28,
      border_width = 2,
    }
  })

  brackets[sid] = bracket

  sbar.add("item", "space.padding." .. sid, {
    script = "",
    width = settings.group_paddings,
  })

  space:subscribe("aerospace_workspace_change", function(env)
    local selected = env.FOCUSED_WORKSPACE == sid
    space:set({
      icon = { highlight = selected },
      background = { border_color = selected and colors.black or colors.bg2 },
    })
    bracket:set({
      background = { border_color = selected and colors.grey or colors.bg2 }
    })
  end)

  space:subscribe("mouse.clicked", function(env)
    sbar.exec("aerospace workspace " .. sid)
  end)
end
