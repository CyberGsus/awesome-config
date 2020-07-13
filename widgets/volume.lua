-- volume widget
local utils   = require 'widgets/utils'
local wibox   = require 'wibox'
local naughty = require 'naughty'
local colors  = (require 'commons/colors').load_colors('cyber')

local function build()
  local widg = wibox.widget {
    widget = wibox.widget.textbox
  }


  local timer = utils.watch(
    'amixer sget Master',
    1,
    widg,
    function (widget, output)
      -- <http://web.archive.org/web/20130928001745/http://awesome.naquadah.org/wiki/Volume_control_and_display>
      local volume = tonumber(
        string.match(output, "(%d?%d?%d)%%"))

      local status = string.match(output, "%[(o[^%]]*)%]")

      local color ='#333333'
      local icon
      local text
      local hue = utils.map(volume, 0, 100, 194, 125)
      if string.find(status,'on', 1, true) then
        color = utils.hsv2hex(math.floor(utils.map(volume, 0, 100, 194, 125)) / 360, 1, 1)
        icon = '🔊'
      else
        icon = '🔇'
      end

      --     f = io.open('/home/cyber/testvolume', 'w')
      --     f:write(tostring(volume))
      --     f:write("\n")
      --     f:write(color)
      --     f:write("\n")
      --     f:write(status)
      --     f:write("\n")
      --     f:write(hue)
      --     f:close()

      widget:set_markup_silently(
        string.format("%s %s%%",
          icon,
          utils.span(tostring(volume), color))
        )


      end)


      widg:connect_signal(
        'button::press',
        function (_, __, ___, button)
          if button == 1 then
            naughty.notify {
              preset = naughty.config.presets.normal,
              title = 'Audio module',
              text = 'Shows the audio level in percentage\n🔇:\tMuted\n🔊:\tNon-muted'
            }
          end
        end)

        return widg
      end


      return {
        build = build
      }
