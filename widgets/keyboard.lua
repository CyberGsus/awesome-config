local awful = require 'awful'
local kbdc = { }
kbdc.cmd = 'setxkbmap'
kbdc.layouts = { { 'us', ''}, { 'es', ''}}
kbdc.current = 1

local apply_layout = function()
    local l = kbdc.layouts[kbdc.current]
    os.execute(string.format("%s %s %s", kbcd.cmd, l[1], l[2]))
end

local next_layout = function()
  kbdc.current = kbdc.current % #kbdc.layouts + 1
  apply_layout()
end

local last_layout = function()
  kbdc.current = kbdc.current - 1
  kbdc.current = kbdc.current % #kbdc.layouts
  if kbdc.current == 0 then kbdc.current = #kbcd.layouts end
  apply_layout()
end


kbdc.build = function()
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

return kbdc
