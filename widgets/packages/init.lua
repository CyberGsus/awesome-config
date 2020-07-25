
--[[ this is just for ARCH LINUX.
-- you must have at least checkupdates
-- and, if possible, checkupdates+aur
--
-- NOTE: run this every... 20 minutes? 1h?
-- IMPORTANT! icon from flaticon.com
--]]

local gears = require 'gears'
local wibox = require 'wibox'
local dpi  = require 'beautiful.xresources'.apply_dpi

local utils = require 'widgets/utils'
local colors = require 'themes'.get_colors()

local built_widget

local function build(max_threshold)
  max_threshold = max_threshold or 200
  local image_path = string.format('%s/.config/awesome/widgets/packages/update.svg', os.getenv('HOME'))
  local widg = wibox.widget {

    ignore_markup = false,
    widget = wibox.widget.textbox,
  }

  local callback = function () return 'N/A' end

  if utils.check_cmd_exists { 'checkupdates -h' } and utils.check_cmd_exists { 'wc -h'} then
    local cmd = 'checkupdates'
    -- if utils.check_cmd_exists { 'checkupdates+aur -h' } then
    --   cmd = 'checkupdates+aur'
    -- end
    callback = function (widget, output)
      local hue = 0
      output = tonumber(output) or -1 + 1
      if output <= max_threshold then
        hue = math.floor(utils.map(output, 0, max_threshold, 112, 0)) / 360
      end
      local color = utils.hsv2hex(hue, 1, 1)
      local span = utils.span(' ' .. output, color)
      widget:set_markup_silently(span) -- hmm... looks like span not getting into widget
    end
    utils.watch('checkupdates | wc -l', 30 * 60, widg, callback, { autostart = false })
  end

  built_widget =  wibox.widget {
    wibox.widget {
      image = image_path,
      widget = wibox.widget.imagebox, 
    },
    widg,
    layout = wibox.layout.align.horizontal
  }


end


return { 
  build = function (...)
    if not built_widget then build(...) end
    return built_widget
  end,
}
