local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

sbar.add("event", "aerospace_workspace_change")

local spaces = {}
local brackets = {}

local handle = io.popen("aerospace list-workspaces --all 2>/dev/null")
local workspace_ids = {}
for sid in handle:read("*a"):gmatch("[^\r\n]+") do
  table.insert(workspace_ids, sid)
end
handle:close()

if #workspace_ids == 0 then
  for i = 1, 9 do workspace_ids[i] = tostring(i) end
end

for _, sid in ipairs(workspace_ids) do
  local space = sbar.add("item", "space." .. sid, {
    icon = {
      font = { family = settings.font.numbers },
      string = sid,
      padding_left = 15,
      padding_right = 8,
      color = colors.white,
      highlight_color = colors.red,
    },
    label = {
      padding_right = 20,
      color = colors.grey,
      highlight_color = colors.white,
      font = "sketchybar-app-font:Regular:16.0",
      y_offset = -1,
    },
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

  local space_bracket = sbar.add("bracket", "space.bracket." .. sid, { space.name }, {
    background = {
      color = colors.transparent,
      border_color = colors.bg2,
      height = 28,
      border_width = 2,
    }
  })

  brackets[sid] = space_bracket

  sbar.add("item", "space.padding." .. sid, {
    script = "",
    width = settings.group_paddings,
  })

  space:subscribe("aerospace_workspace_change", function(env)
    local selected = env.FOCUSED_WORKSPACE == sid
    space:set({
      icon = { highlight = selected },
      label = { highlight = selected },
      background = { border_color = selected and colors.black or colors.bg2 },
    })
    space_bracket:set({
      background = { border_color = selected and colors.grey or colors.bg2 }
    })
  end)

  space:subscribe("mouse.clicked", function(env)
    sbar.exec("aerospace workspace " .. sid)
  end)
end

-- Set initial highlight based on the currently focused workspace
local focused_handle = io.popen("aerospace list-workspaces --focused 2>/dev/null")
local focused_ws = focused_handle:read("*a"):match("^%s*(.-)%s*$")
focused_handle:close()

if focused_ws ~= "" and spaces[focused_ws] then
  spaces[focused_ws]:set({
    icon = { highlight = true },
    label = { highlight = true },
    background = { border_color = colors.black },
  })
  brackets[focused_ws]:set({
    background = { border_color = colors.grey }
  })
end

local spaces_indicator = sbar.add("item", {
  padding_left = -3,
  padding_right = 0,
  icon = {
    padding_left = 8,
    padding_right = 9,
    color = colors.grey,
    string = icons.switch.on,
  },
  label = {
    width = 0,
    padding_left = 0,
    padding_right = 8,
    string = "Spaces",
    color = colors.bg1,
  },
  background = {
    color = colors.with_alpha(colors.grey, 0.0),
    border_color = colors.with_alpha(colors.bg1, 0.0),
  }
})

spaces_indicator:subscribe("swap_menus_and_spaces", function(env)
  local currently_on = spaces_indicator:query().icon.value == icons.switch.on
  spaces_indicator:set({
    icon = currently_on and icons.switch.off or icons.switch.on
  })
end)

spaces_indicator:subscribe("mouse.entered", function(env)
  sbar.animate("tanh", 30, function()
    spaces_indicator:set({
      background = {
        color = { alpha = 1.0 },
        border_color = { alpha = 1.0 },
      },
      icon = { color = colors.bg1 },
      label = { width = "dynamic" }
    })
  end)
end)

spaces_indicator:subscribe("mouse.exited", function(env)
  sbar.animate("tanh", 30, function()
    spaces_indicator:set({
      background = {
        color = { alpha = 0.0 },
        border_color = { alpha = 0.0 },
      },
      icon = { color = colors.grey },
      label = { width = 0 }
    })
  end)
end)

spaces_indicator:subscribe("mouse.clicked", function(env)
  sbar.trigger("swap_menus_and_spaces")
end)
