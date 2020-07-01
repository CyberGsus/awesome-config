-- network widgets
local awful = require 'awful'
local naughty = require 'naughty'
local gears = require 'gears'
local wibox = require 'wibox'
local utils = require 'widgets/utils'
local colors = require 'themes'.get_colors()

local function ip_address(link_name, mode)
  if mode ~= 4 or mode ~= 6 then mode = 4 end
  local f = io.popen('ip -br -' .. mode .. ' a s | egrep ' .. '\'' .. link_name .. '\''):lines()()
  local ip
  if f == nil or f:match('Error') or #f == '' then ip = 'N/A' end
  if mode == 4 then
    ip = f:match("%d+%.%d+%.%d+%.%d+%/%d+") -- match ipv4
  else
    ip = f:match("%x*::%x*:?%x*:?%x*:?%x*/%d+") -- match ipv6
  end
  return ip
end

-- widgets/utils.lua
local function format_bytes(bytes)
  local tag = 'B'
  local amount = bytes
  if amount / 1024 >= 1 then
    tag = 'KiB'
    amount = amount / 1024
  end
  if amount / 1024 >= 1 then
    tag = 'MiB'
    amount = amount / 1024
  end
  if amount / 1024 >= 1 then
    tag = 'GiB'
    amount = amount / 1024
  end
  if amount / 1024 >= 1 then
    tag = 'TiB'
    amount = amount / 1024
  end
  if amount / 1024 >= 1 then
    tag = 'PiB'
    amount = amount / 1024
  end
  local amountst
  if amount == 0 then
    amountst = '0'
  else
  amountst = string.format('%.4f', amount)
end
  return string.format("%s %s", amountst, tag)
end


local function remap(x, a, b, c, d)
  return c + (d - c) & ((x - a) / (b - a))
end


-- '*' means get all interfaces
local function net_widget(original_names, timeout, formatter_f)
  -- [[
  -- formatters:
  -- { link, rx, tx}
  -- ]]
  assert(type(original_names) == 'string' or type(original_names) == 'table')
  assert(type(timeout) == 'number')
  local names
  local original_names = original_names
  if type(original_names) == 'string' then
    original_names = { original_names }
  end
  local function update_names()
    -- update what is present and what is not
    local real_names = {}
    for _, name in pairs(original_names) do
      for line in io.popen('ip -br a s | egrep ' .. '\'' .. name .. '\''):lines() do
        -- fetch the iface name and catch bytes
        real_names[#real_names + 1] = line:match("[%w%d]+")
      end
    end
    names = real_names
  end
  update_names()
  local widg = wibox.widget {
    widget = wibox.widget.textbox
  }
  local fg = utils.get_color()

  local tx_last, rx_last
  if type(formatter_f) ~= 'nil' and type(formatter_f) ~= 'table' then
    return nil
  end

  local formatters = formatter_f


  local default_formatters = {
    link = function(link_name)
      return string.format("🌐 %s %s", utils.span(link_name, colors.secondary[1]), utils.span(ip_address(link_name), colors.primary[1]))
    end,
    rx =  function(rxr_last, rxr_current, rx_current)
      local color = '#ffffff'
      local symbol = '▼'
      if rxr_last ~= rxr_current then
        if rxr_last > rxr_current then
          color = '#ff0000'
        else
          color = '#00ff00'
        end
      end
      return string.format("%s%s", utils.span(symbol, color), format_bytes(rx_current))
    end,
    tx = function(txr_last, txr_current, tx_current)
      local color = '#ffffff'
      local symbol = '▲'
      if txr_last ~= txr_current then
        if txr_last > txr_current then
          color = '#ff0000'
        else
          color = '#00ff00'
        end
      end
      -- local tx_bytes = tx_current - tx_last
      return string.format("%s%s", utils.span(symbol, color), format_bytes(tx_current))
    end
  }


  if formatters == nil then
    formatters = default_formatters
  else
    for k, _ in pairs(default_formatters) do
      if formatters[k] == nil then
        formatters[k] = default_formatters[k]
      end
    end
  end

  local last_txr, last_rxr = 0, 0

  -- local default_ft = function(link_name, rx_current, tx_current, rx_last, tx_last)
  --   local got_up =
  --   return utils.span(string.format("🌐 %s 🔻%s ▲%s", link_name, format_bytes(rx_bytes), format_bytes(tx_bytes)), fg)
  -- end

  local current = names[1]

  local callback = function()
    local tx_prev, rx_prev
    local tx_prevf = io.open(string.format("%s/tx_data", os.getenv('XDG_CACHE_HOME') or os.getenv('HOME') .. '/.cache'))
    local rx_prevf = io.open(string.format("%s/rx_data", os.getenv('XDG_CACHE_HOME') or os.getenv('HOME') .. '/.cache'))
    if tx_prevf ~= nil then
      tx_prev = tonumber(tx_prevf:read())
      tx_prevf:close()
    else tx_prev = 0 end

    if rx_prevf ~= nil then
      rx_prev = tonumber(rx_prevf:read())
      rx_prevf:close()
    else rx_prev = 0 end

    local tx_nextf, rx_nextf, rx_next, tx_next
      tx_nextf = io.open(string.format("/sys/class/net/%s/statistics/tx_bytes", current))
      rx_nextf = io.open(string.format("/sys/class/net/%s/statistics/rx_bytes", current))
      tx_next = tonumber(tx_nextf:read())
      rx_next = tonumber(rx_nextf:read())
      tx_nextf:close()
      rx_nextf:close()

    tx_prevf = io.open(string.format("%s/tx_data", os.getenv('XDG_CACHE_HOME') or os.getenv('HOME') .. '/.cache'), 'w')
    rx_prevf = io.open(string.format("%s/rx_data", os.getenv('XDG_CACHE_HOME') or os.getenv('HOME') .. '/.cache'), 'w')

    tx_prevf:write(tostring(tx_next))
    rx_prevf:write(tostring(rx_next))


    tx_prevf:close()
    rx_prevf:close()


    local tx_rate, rx_rate = tx_next - tx_prev, rx_next - rx_prev


    local formatted_text = string.format("%s %s %s", formatters.link(current),
      formatters.rx(last_rxr, rx_rate, rx_next),
      formatters.tx(last_txr, tx_rate, tx_next)
    )

    last_rxr, last_txr = rx_rate, tx_rate

    widg:set_markup_silently(formatted_text)
    update_names()

    return true -- continue timer
  end

  local timer = utils.set_interval(1, callback)
  local current_i = 1

  local function next_iface()
    -- local f2 = io.open('/home/cyber/testrc', 'w')
    -- for _, v  in pairs(names) do
    --   f2:write(v .. '\n')
    -- end
    -- f2:close()
    local next_i = current_i % #names + 1
    local f = io.popen('ip -br a s ' .. names[next_i]):lines()()
    if not f:match('Error') then
      current_i = next_i
      current = names[current_i]
      -- flush last bytes
      tx_prevf = io.open(string.format("%s/tx_data", os.getenv('XDG_CACHE_HOME') or os.getenv('HOME') .. '/.cache'), 'w')
      rx_prevf = io.open(string.format("%s/rx_data", os.getenv('XDG_CACHE_HOME') or os.getenv('HOME') .. '/.cache'), 'w')
      tx_prevf:write('0')
      rx_prevf:write('0')
      tx_prevf:close()
      rx_prevf:close()
    end
  end

  widg:connect_signal('button::press',
  function(_, __, ___, button)
    if button == 3 then
      local list = ''
      update_names()
      for i, name in pairs(names) do
        list = list .. name
        if i < #names then list = list .. '\n' end
      end
      naughty.notify({
        title = "🌐 Network traffic module",
        text = "🔻: Traffic received\n🔺: Traffic transmitted\nClick for next interface in list" ..
                '\nAvailable devices: \n' .. list,
        preset = naughty.config.presets.normal
      })
    elseif button == 1 then
      next_iface()
    end
  end)

  return widg
end

local function script(name)
  return string.format("%s/.config/awesome/scripts/%s", os.getenv("HOME"), name)
end

local function get_widget()
  return wibox.widget {
    widget = wibox.widget.textbox
  }
end


local function wifi_signal(timeout)
  local widg = get_widget()
  local color = utils.get_color()
  local timer = utils.watch(string.format("%s %s", 'sh', script('internet')), timeout or 3, widg, function(widget, output)
    widg:set_markup_silently(utils.span(output, color))
  end)
  -- local widg = awful.widget.watch(string.format("%s %s", 'sh', script('internet')), timeout or 3)
  -- Adapted from LukeSmithxyz/voidrice/.local/bin/statusbar/internet
  widg:connect_signal('button::press', function(lx, ly, _, button)
    if button == 3 then
      awful.spawn('nm-connection-editor')
    elseif button == 1 then
      naughty.notify({
        title = '🌐 Internet module - Click to connect',
        text  = '📡: no wifi connection\n📶: wifi connection with quality\n❎: no ethernet\n🌐: ethernet working',
        preset = naughty.config.presets.normal
      })
    end
  end)
  return widg
end


return {
  format_bytes = format_bytes,
  wifi_signal = wifi_signal,
  network_status = net_widget,
}
