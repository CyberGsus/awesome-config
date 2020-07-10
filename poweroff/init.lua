local icons = require 'icons'
local colors = (require 'themes').get_colors()

local svg = nil

local function build(name)
  if type(name) ~= 'string' then
    name = 'poweroff.svg'
  end

  local svgf = io.open(icons.get_icon_dir() .. 'poweroff.svgf', 'r')
  local svg_mod = io.open(icons.get_icon_dir() .. 'poweroff-mod.svgf', 'w')
  for line in svgf:lines() do
    local fstart, fend = line:find('"#(%x+)"')
    if fstart ~= nil and fend ~= nil then
      local before = line:sub(1, fstart)
      local after = line:sub(fend, #line)
      svg_mod:write(string.format("%s%s%s", before, '#ff00ff', after) .. '\n')
    else 
      svg_mod:write(line .. '\n')
    end
  end

  svgf:close()
  svg_mod:close()

  svg = icons.get_icon_dir() .. 'poweroff-mod.svg'
  
end

return {
  icon = function() -- using factory method so i only write files once
    if not svg then build() end
    return svg
  end,
}
