local beautiful = require 'beautiful'
local colors = require 'commons/colors'


-- {{ EDITABLE STUFF

local theme_name = 'cyber'


-- }}

local color_theme = nil


-- basic getters
local function get_colors()
  if color_theme == nil then
    color_theme = colors.load_colors(theme_name)
  end
  return color_theme
end



local theme_loaded = false


-- basic getter, prevents mistakes
local function init_script()
  return os.getenv('HOME') .. '/.config/awesome/themes/' .. theme_name .. '/theme.lua'
end

local function name()
  return theme_name
end


return {
  get_colors = get_colors,
  init_script = init_script,
  name = name,
}
