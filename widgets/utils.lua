-- put primary and secondary in color thmee
local colors = require ('commons/colors').load_colors('cyber')
local alpha = require ('commons/color_utils').apply_direct_alpha
local gears = require 'gears'

local function hsv2rgb(h, s, v)
  local r, g, b
  local i = math.floor( h * 6)
  local f = h * 6 - i
  local p = v * (1 - s)
  local q = v * (1 - f * s)
  local t = v * (1 - (1 - f) * s)
  local rem  = i % 6

  if rem == 0 then r = v g = t b = p end
  if rem == 1 then r = q g = v b = p end
  if rem == 2 then r = p g = v b = t end
  if rem == 3 then r = p g = q b = v end
  if rem == 4 then r = t g = p b = v end
  if rem == 5 then r = v g = p b = q end


  local tbl =  { r, g, b }
  for i = 1, 3 do
    tbl[i] = math.floor(tbl[i] * 255)
  end
  return tbl
end

local tbl2hex = function(tbl)
  return string.format("#%02x%02x%02x", tbl[1], tbl[2], tbl[3])
end


local color_toggle = true
local function get_color(no_toggle)
  -- local color
  -- if color_toggle then
  --   color = colors.primary[1]
  -- else
  --   color = colors.secondary[1]
  -- end
  -- if no_toggle ~= true then
  --   color_toggle = not color_toggle
  -- end
  -- return alpha(color, 0.90)
  return alpha(colors.light[1], 0.5)
end

local function span(text, color)
  if color == nil then
    color = get_color()
  end
  return string.format("<span foreground='%s' >%s</span>", color,
  text)
end

local function set_interval(timeout, cb)
  local timer = gears.timer {
    timeout = timeout,
    call_now = true,
    autostart = true,
    callback = cb,
  }
  timer:start()
  return timer
end


local function watch(sc,timeout, widget, cb)
  if cb == nil then cb = function(widg, out) end end
  return set_interval(timeout, function()
    local fd = io.popen(sc)
    if fd == nil then return false end -- failed, don't repeat
    local out = fd:read("*all")
    fd:close()
    cb(widget, out)
    return true
  end)
end

return {
  span = span,
  get_color = get_color,
  set_interval = set_interval,
  watch = watch,
  hsv2rgb = hsv2rgb,
  tbl2hex = tbl2hex,
}