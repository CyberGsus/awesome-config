local json  = require('commons/rxi/json')


local readall = function (filename)
  io.write(string.format('Filename : %s\n', filename))
  local file = io.open(filename, 'r')
  io.input(file)
  local str = ''
  local lastread = nil
  while true do
    lastread = io.read()
    if lastread == nil then
      break
    end
    str = str .. lastread
  end
  io.close(file)
  return str
end

local color_functions = {}

color_functions.load_json = function(filename)
  return json.decode(readall(filename))
end

color_functions.load_colors = function (theme)
  return color_functions.load_json('/home/cyber/.config/awesome/themes/' ..theme.. '/colors.json')
end

return color_functions

