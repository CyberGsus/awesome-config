-- test.lua
local colors = require ('colors')

for k in pairs(colors) do
  print(string.format("colors[%s] = %s", k, colors[k]))
end
