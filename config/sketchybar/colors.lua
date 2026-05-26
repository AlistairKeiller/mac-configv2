return {
  black = 0xff11111b,   -- crust
  white = 0xffcdd6f4,   -- text
  red = 0xfff38ba8,     -- red
  green = 0xffa6e3a1,   -- green
  blue = 0xff89b4fa,    -- blue
  yellow = 0xfff9e2af,  -- yellow
  orange = 0xfffab387,  -- peach
  magenta = 0xffcba6f7, -- mauve
  grey = 0xff7f849c,    -- overlay1
  transparent = 0x00000000,

  bar = {
    bg = 0xee181825,    -- mantle, slightly transparent
    border = 0xff181825,
  },
  popup = {
    bg = 0xcc313244,    -- surface0
    border = 0xff6c7086 -- overlay0
  },
  bg1 = 0xff313244,     -- surface0
  bg2 = 0xff45475a,     -- surface1

  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then return color end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}
