local json  = require('commons/rxi/json')


local readall = function (filename)
  local str = ''
  local f = io.open(filename)
  if f == nil then return '' end
  str = f:read("*all")
  f:close()
  return str
end

local color_functions = {}

color_functions.load_json = function(filename)
  return json.decode(readall(filename))
end

color_functions.load_colors = function (theme)
  return color_functions.load_json(os.getenv("HOME") .. '/.config/awesome/themes/' ..theme.. '/colors.json')
end

return color_functions

