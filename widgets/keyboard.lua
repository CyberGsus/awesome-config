local awful = require 'awful'
local utils = require 'widgets/utils'
local kbdc = { }
kbdc.cmd = 'setxkbmap'
kbdc.layouts = { { 'us', ''}, { 'es', ''}}
kbdc.current = 1



local apply_layout = function()
    local l = kbdc.layouts[kbdc.current]
    os.execute(string.format("%s %s %s", kbdc.cmd, l[1], l[2]))
end

local next_layout = function()
  kbdc.current = kbdc.current % #kbdc.layouts + 1
  apply_layout()
end

local last_layout = function()
  kbdc.current = kbdc.current - 1
  kbdc.current = kbdc.current % #kbdc.layouts
  if kbdc.current == 0 then kbdc.current = #kbdc.layouts end
  apply_layout()
end


kbdc.build = function()
  local kbcol = utils.get_color()
  local widg = awful.widget.keyboardlayout()

  widg:connect_signal(
    'button::press',
    function(_, __, ___, button)
      if button == 1 then
        next_layout()
      elseif button == 3 then
        last_layout()
      end
    end)

  return widg
end

kbdc.next_layout = next_layout
kbdc.last_layout = last_layout

return kbdc
