---------------------------
-- Default awesome theme --
---------------------------

local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local gfs = require("gears.filesystem")


-- package.path = package.path .. themes_path .. '/?'
local color_utils = require ('commons/color_utils')
-- theme name : cyber
local colors      = require ('commons/colors').load_colors('cyber')
local icons       = require ('commons/icons')

local themes_path = icons.themes_path()
local getfont = function (font_name, size, ...)
    if size == nil then size = 10 end
    if font_name == nil then return '' end
    local ft_attrs = ''
    local attrs = { ...}
    if #attrs > 0 then ft_attrs = ',' end
    for i = 1, #attrs do
        ft_attrs = ft_attrs .. string.format(' %s', attrs[i])
    end
    return string.format('%s%s %d', font_name, ft_attrs, size)
end


local theme = {}

local FONT_NORMAL   = 'IBM Plex Mono'
local FONT_MONO     = 'Jetbrains Mono'

theme.font          = getfont(FONT_NORMAL, dpi(9), 'Bold', 'Italic')

theme.bg_normal     = colors.dark[1]
theme.bg_focus      = colors.dark[1] -- color_utils.apply_direct_alpha(colors.light[1], 0.075)
theme.bg_urgent     = colors.dark[1]
theme.bg_minimize   = colors.dark[1] -- color_utils.apply_direct_alpha(colors.primary[1], 0.5)
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = color_utils.apply_direct_alpha(colors.light[1], 0.5) --color_utils.apply_alpha(colors.secondary[1], '#aaaaaa', 0.1)
local f = io.open('/home/cyber/test2.txt', 'w')
f:write(theme.fg_normal)
f:close()
theme.fg_focus      = colors.primary[1]
theme.fg_urgent     = color_utils.apply_direct_alpha('#ff0000', 0.75)
theme.fg_minimize   = color_utils.apply_direct_alpha(colors.secondary[1], 0.5)
theme.fg_systray    = colors.secondary[1]

theme.useless_gap   = dpi(0)
theme.border_width  = dpi(1)
theme.border_normal = colors.dark[1]
theme.border_focus  = colors.primary[1]
theme.border_marked = colors.secondary[1]

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- prompt_[fg|bg|fg_cursor|bg_cursor|font]
-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Taglist
theme.taglist_bg_focus          = color_utils.apply_alpha(theme.bg_normal, '#aaaaaa', 0.1)
theme.taglist_fg_occupied       = colors.grey[1]
theme.taglist_fg_normal         = colors.grey[1]
theme.taglist_fg_empty          = theme.bg_normal

-- Window titles
theme.titlebar_bg_normal        = colors.dark[1]
theme.titlebar_bg_focus         = colors.dark[1]
theme.titlebar_fg_focus         = colors.secondary[1]

-- Tasklist/taskbar
theme.tasklist_fg_focus         = colors.secondary[1]

-- Hotkeys colors (help window)
theme.hotkeys_bg                = colors.dark[1]                -- foreground
theme.hotkeys_fg                = colors.light[1]               -- background
theme.hotkeys_modifiers_fg      = color_utils.apply_alpha(theme.hotkeys_bg, '#ffffff', 0.2) -- Shift+Super+
theme.hotkeys_border_color      = colors.primary[1]
theme.hotkeys_group_margin      = dpi(20)
theme.hotkeys_description_font  = getfont(FONT_MONO, 10)
theme.hotkeys_font              = getfont('Hack', 10)
theme.hotkeys_border_width      = dpi(3)

-- Tooltips
theme.tooltip_fg_color          = color_utils.apply_alpha(theme.bg_normal, '#aaaaaa', 0.1)
theme.tooltip_font              = getfont(FONT_MONO, 10)
theme.tooltip_border_width      = dpi(0.5)
theme.tooltip_border_color      = colors.secondary[1]



-- Prompt
theme.prompt_font               = getfont(FONT_MONO, 8)
theme.prompt_fg                 = colors.secondary[1]
theme.prompt_fg_cursor          = colors.secondary[1]
theme.prompt_bg_cursor          = colors.secondary[1]




-- Generate taglist squares:
-- local taglist_square_size = dpi(4)
-- theme.taglist_squares_sel = theme_assets.taglist_squares_sel(
-- taglist_square_size, theme.fg_normal
-- )
-- theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(
-- taglist_square_size, theme.fg_normal
-- )

-- Variables set for theming notifications:
-- notification_font
-- notification_[bg|fg]
-- notification_[width|height|margin]
-- notification_[border_color|border_width|shape|opacity]

theme.notification_font = getfont(FONT_NORMAL, 10, 'Bold')
theme.notification_fg   = colors.secondary[1]
theme.notification_border_width = dpi(1.5)
theme.notification_border_color = colors.secondary[1]



-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = themes_path.."default/submenu.png"
theme.menu_height = dpi(15)
theme.menu_width  = dpi(100)

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Define the image to load
-- theme.titlebar_close_button_normal = icons.asset('png', 'close', 'inactive')
-- theme.titlebar_close_button_focus  = icons.asset('png', 'close')

-- theme.titlebar_minimize_button_normal = icons.asset('png', 'min', 'inactive')
-- theme.titlebar_minimize_button_focus  = icons.asset('png', 'min')

-- theme.titlebar_ontop_button_normal_inactive = themes_path.."default/titlebar/ontop_normal_inactive.png"
-- theme.titlebar_ontop_button_focus_inactive  = themes_path.."default/titlebar/ontop_focus_inactive.png"
-- theme.titlebar_ontop_button_normal_active = themes_path.."default/titlebar/ontop_normal_active.png"
-- theme.titlebar_ontop_button_focus_active  = themes_path.."default/titlebar/ontop_focus_active.png"

-- theme.titlebar_sticky_button_normal_inactive = themes_path.."default/titlebar/sticky_normal_inactive.png"
-- theme.titlebar_sticky_button_focus_inactive  = themes_path.."default/titlebar/sticky_focus_inactive.png"
-- theme.titlebar_sticky_button_normal_active = themes_path.."default/titlebar/sticky_normal_active.png"
-- theme.titlebar_sticky_button_focus_active  = themes_path.."default/titlebar/sticky_focus_active.png"

-- theme.titlebar_floating_button_normal_inactive = themes_path.."default/titlebar/floating_normal_inactive.png"
-- theme.titlebar_floating_button_focus_inactive  = themes_path.."default/titlebar/floating_focus_inactive.png"
-- theme.titlebar_floating_button_normal_active = themes_path.."default/titlebar/floating_normal_active.png"
-- theme.titlebar_floating_button_focus_active  = themes_path.."default/titlebar/floating_focus_active.png"

-- theme.titlebar_maximized_button_normal_inactive = themes_path.."default/titlebar/maximized_normal_inactive.png"
-- theme.titlebar_maximized_button_focus_inactive  = themes_path.."default/titlebar/maximized_focus_inactive.png"
-- theme.titlebar_maximized_button_normal_active = themes_path.."default/titlebar/maximized_normal_active.png"
-- theme.titlebar_maximized_button_focus_active  = themes_path.."default/titlebar/maximized_focus_active.png"

theme.wallpaper = '/home/cyber/.local/share/wallpapers/links/blackarch-wallpaper.jpg'
--themes_path.."default/background.png"

-- You can use your own layout icons like this:
theme.layout_fairh = themes_path.."default/layouts/fairhw.png"
theme.layout_fairv = themes_path.."default/layouts/fairvw.png"
theme.layout_floating  = themes_path.."default/layouts/floatingw.png"
theme.layout_magnifier = themes_path.."default/layouts/magnifierw.png"
theme.layout_max = themes_path.."default/layouts/maxw.png"
theme.layout_fullscreen = themes_path.."default/layouts/fullscreenw.png"
theme.layout_tilebottom = themes_path.."default/layouts/tilebottomw.png"
theme.layout_tileleft   = themes_path.."default/layouts/tileleftw.png"
theme.layout_tile = themes_path.."default/layouts/tilew.png"
theme.layout_tiletop = themes_path.."default/layouts/tiletopw.png"
theme.layout_spiral  = themes_path.."default/layouts/spiralw.png"
theme.layout_dwindle = themes_path.."default/layouts/dwindlew.png"
theme.layout_cornernw = themes_path.."default/layouts/cornernww.png"
theme.layout_cornerne = themes_path.."default/layouts/cornernew.png"
theme.layout_cornersw = themes_path.."default/layouts/cornersww.png"
theme.layout_cornerse = themes_path.."default/layouts/cornersew.png"

-- Generate Awesome icon:
theme.awesome_icon =  icons.aw_icon(theme.menu_height * 10, theme.fg_focus, theme.bg_focus, 'cyber', themes_path, { reload = false })
--[[theme_assets.awesome_icon(
theme.menu_height, theme.bg_focus, theme.fg_focus
) --]]

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
