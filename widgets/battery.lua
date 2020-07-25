pcall(require, "luarocks.loader")

local lfs = require 'lfs'
local wibox = require 'wibox'
local utils = require 'widgets/utils'
local naughty = require 'naughty'
local notify = naughty.notify


local set_interval = utils.set_interval

local function supply(name)
  return string.format('/sys/class/power_supply/%s', name)
end

local function exists(file)
  return (lfs.attributes(file or '') ~= nil)
end

local function readfile(fname)
  -- t = io.open('/home/cyber/testbat', 'w')
  local st = nil
  if exists(fname) then
    f = io.open(fname)
    if f ~= nil then
      st = f:read("*all")
    end
  end
  return st
end

-- Adapted from <https://github.com/LukeSmithxyz/voidrice/blob/master/.local/bin/statusbar/battery>
local function battery_info() -- returns { charging: boolean, status: string,  current: number, }
  -- is battery charging?
  for file in lfs.dir ('/sys/class/power_supply') do
    if file:match('BAT?') then
      local path = supply(file)
      local capacity = tonumber(readfile(path .. '/capacity')) or -1
      local status = readfile(path .. '/status') or 'unknown'
      return { status = status, current = capacity }
    end
  end
  return { status = 'unknown', current = -1}
end


local match_pairs = {
  { "[Dd]ischarging", '🔋'},
  { '[Nn]ot charging', '🛑' },
  { '[Cc]harging', '🔌' },
  { '[Ff]ull' , '⚡' },
  { '[Uu]nknown', '♻️ ' }
}






local exports = {
  widget = function()
    local color = utils.get_color()
    local widg = wibox.widget {
      widget = wibox.widget.textbox
    }

    local timer = utils.set_interval(1, function()
      local info = battery_info()
      local icon = ''
      for _, v in pairs(match_pairs) do
        if info.status:match(string.format("%s", v[1])) then icon = v[2] break end
      end
      -- log = io.open('/home/cyber/testbat', 'w')
      local fg = utils.tbl2hex(utils.hsv2rgb((info.current or 0) / 360, 1, 1))
      -- fg = color
      widg:set_markup_silently(string.format("%s %s%%", icon, utils.span(info.current, fg)))
    end, false)


    widg:connect_signal(
    'button::press', function(lx, ly, _, button)
      if button == 1 then
        notify {
          title = "🔋 Battery module",
          text = "🔋: discharging\n🛑: not charging\n♻: stagnant charge\n🔌: charging\n⚡: charged\n❗: battery very low!",
        }
      end
    end)
    return widg
  end
}

return exports
