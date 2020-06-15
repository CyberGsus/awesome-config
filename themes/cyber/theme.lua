-- My own awesome theme


local theme_assets  = require 'beautiful.theme_assets'
local xresources    = require 'beautiful.xresources'
local dpi           = xresources.apply_dpi
--

local gfs           = require 'gears.filesytem'
local themes_path   = '/home/cyber/.config/awesome/themes'

local color_utils   = require 'color_utils'
local colors        = require 'colors'
local icons         = require 'icons'

local app_icons_path    = os.getenv("HOME") .. '/.local/share/icons/candy-icons/'
local theme_icons_path  = os.getenv("HOME") .. '/.themes/Sweet-Dark/assets/'

local theme = {}

-- Font
theme.font = 'sans 8'

-- Background
theme.bg_normal   =       colors.dark[1]            -- dark
theme.bg_focus    =       colors.primary[1]         -- primary
theme.bg_urgent   =       colors.secondary[1]     -- secondary
-- theme.bg_urgent   =       '#f29913'     -- orange-ish
theme.bg_minimize =       color_utils.apply_alpha(
colors.dark[1],
colors.primary[1],
0.75)             -- focus with 0.75 alpha
theme.bg_systray  =       theme.bg_normal

-- Foreground
theme.fg_normal   =       colors.grey[1]       -- grey
theme.fg_focus    =       colors.light[1]       -- light
theme.fg_urgent   =       color_utils.apply_alpha(
colors.secondary[1],
colors.light[1],
0.75)                 -- secondary over light
theme.fg_minimize =       colors.light[2]


theme.useless_gap     = dpi(0)
theme.border_width    = dpi(1.5)
theme.border_normal   = colors.dark[1]
theme.border_focus    = colors.primary[1]
theme.border_marked   = colors.secondary[1]


-- Generate taglist squares
local taglist_square_size = dpi(4)
theme.taglist_squares_sel = theme_assets.taglist_squares_sel(
taglist_square_size, theme.fg_focus
)
theme.taglist_square_unsel = theme_assets.taglist_squares_unsel(
taglist_square_size, theme.fg_normal
)


-- Notifications
theme.notification_font = 'Hack'
theme.notification_bg   = colors.dark[1]
theme.notification_fg   = color_utils.apply_alpha(
colors.light[1], colors.dark[1], 0.89
)

theme.notification_border_color   =   colors.secondary[1]
theme.notitication_opacity        =   0.7

-- Menu
theme.menu_height                 = dpi(15)
theme.menu_width                  = dpi(100)


-- Windows
theme.titlebar_close_button_normal    = icons.asset('png', 'close')
theme.titlebar_close_button_focus     = icons.asset('png', 'close', 'focus')

theme.titlebar_minimize_button_normal = icons.asset('png', 'minimize')
theme.titlebar_minimize_button_focus  = icons.asset('png', 'minimize', 'focus')

-- theme.titlebar_ontop_button_normal


-- Icons
theme.icon_theme    = os.getenv("HOME") .. '/.local/share/wallpapers/links/wallpaper.jpg'
--
return theme
