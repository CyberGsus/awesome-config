-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
local themes = require "themes"
local icons = require "icons"
local tags = require 'tags'
local poweroff = require 'poweroff'

-- -{{ tag matching rules

icons.matches('c$', { icon = 'languages/c.svg' })
icons.matches('py', { icon = 'languages/python.png' })
icons.matches('settings', { icon = 'usb.png' })
icons.matches('term', { icon = 'cmdline-fluent.png', uppercase = true })
icons.matches('vms', { icon = '/usr/share/icons/hicolor/22x22/apps/vmware-player.png' })
icons.matches('vue', { icon = 'vue.svg' })
icons.matches({ 'cpp', 'c++' }, { icon = 'languages/cpp.svg' })
tags.matches('dev', { append = "⚙" })
tags.matches('web', { prepend = "🌐" })
tags.matches('learn', { append = "📖" })
tags.matches('class', { prepend = '😪' })
icons.matches('ctf', { icon = 'ctf.png', uppercase = true })
-- TODO: make reload first save tags


--- }}


-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

local last_tag

local widgets = require ("widgets")

-- - {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
  naughty.notify(
    {
      preset = naughty.config.presets.critical,
      title = "Oops, there were errors during startup!",
      text = awesome.startup_errors
    }
    )
end



-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal(
    "debug::error",
    function(err)
      -- Make sure we don't go into an endless error loop
      if in_error then
        return
      end
      in_error = true

      naughty.notify(
        {
          preset = naughty.config.presets.critical,
          title = "Oops, an error happened!",
          text = tostring(err)
        }
        )
      in_error = false
    end
    )
end


-- - {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(themes.init_script())

-- This is used later as the default terminal and editor to run.
terminal = "alacritty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
alt_key = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
  -- awful.layout.suit.floating,
  awful.layout.suit.tile,
  -- awful.layout.suit.tile.top,
  awful.layout.suit.fair,
  -- awful.layout.suit.fair.horizontal,
  awful.layout.suit.spiral,
  -- awful.layout.suit.spiral.dwindle,
  awful.layout.suit.max
  -- awful.layout.suit.max.fullscreen,
  -- awful.layout.suit.magnifier,
  -- awful.layout.suit.corner.nw,
  -- awful.layout.suit.corner.ne,
  -- awful.layout.suit.corner.sw,
  -- awful.layout.suit.corner.se,
}
-- }}}
-- - {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
  {"hotkeys", function()
      hotkeys_popup.show_help(nil, awful.screen.focused())
    end},
    {"manual", terminal .. " -e man awesome"},
    {"edit config", editor_cmd .. " " .. awesome.conffile},
    {"restart", awesome.restart},
    {"quit", function()
        awesome.quit()
      end},
      { "poweroff", function() os.execute('poweroff') end, poweroff.icon() }
    }

    mymainmenu =
    awful.menu(
      {
        items = {
          {"awesome", myawesomemenu, beautiful.awesome_icon},
          {"open terminal", terminal}
        }
      }
      )

    mylauncher =
    awful.widget.launcher(
      {
        image = beautiful.awesome_icon,
        menu = mymainmenu
      }
      )

    -- Menubar configuration
    menubar.utils.terminal = terminal -- Set the terminal for applications that require it
    -- }}}

    -- Keyboard map indicator and switcher
    mykeyboardlayout = widgets.keyboard.build()
    -- myvolumewidget = widgets.volume.build()



    function dir (s, n, f, c)
      if type(s) ~= 'table' then return end
      local name = n or ''
      local file = f or io.stdout
      for k, v in pairs(s) do
        f:write(string.format("%s.%s = (%s) %s\n", name, k, type (v), v))
      end
      if (f ~= io.stdout or f ~= io.stderr or f ~= io.stdin) and (c == nil or c == false) then f:close() end
    end


    function indexOf(tbl, t)
      for i = 1, #tbl do
        if t == tbl[i] then
          return i
        end
      end
      return -1
    end

    local colors = themes.get_colors()


    local color_n = true
    function get_color()
      local color
      if color_n then
        color = colors.primary[1]
      else
        color = colors.secondary[1]
      end
      color_n = not color_n
      return color
    end

    -- widgets/utils.lua
    local span = require ('widgets/utils').span

    -- local colors = require ('commons/colors').load_colors('cyber')


    -- {{{ Wibar
          -- Create a textclock widget
          mytextclock = wibox.widget.textclock(span('%a %b %d [ %T ]'), 1)

          local lfs = require 'lfs'


          netbar  = widgets.network.wifi_signal(1)
          wifibar = widgets.network.network_status({ "wlp2s0", "tun*"}, 1)


          -- Create a wibox for each screen and add it
          local taglist_buttons =
          gears.table.join(
            awful.button(
              {},
              1,
              function(t)
                t:view_only()
              end
              ),
            awful.button(
              {modkey},
              1,
              function(t)
                if client.focus then
                  client.focus:move_to_tag(t)
                end
              end
              ),
            awful.button({}, 3, awful.tag.viewtoggle),
            awful.button(
              {modkey},
              3,
              function(t)
                if client.focus then
                  client.focus:toggle_tag(t)
                end
              end
              ),
            awful.button(
              {},
              4,
              function(t)
                awful.tag.viewnext(t.screen)
              end
              ),
            awful.button(
              {},
              5,
              function(t)
                awful.tag.viewprev(t.screen)
              end
              )
            )

          local tasklist_buttons =
          gears.table.join(
            awful.button(
              {},
              1,
              function(c)
                if c == client.focus then
                  c.minimized = true
                else
                  c:emit_signal("request::activate", "tasklist", {raise = true})
                end
              end
              ),
            awful.button(
              {},
              3,
              function()
                awful.menu.client_list({theme = {width = 250}})
              end
              ),
            awful.button(
              {},
              4,
              function()
                awful.client.focus.byidx(1)
              end
              ),
            awful.button(
              {},
              5,
              function()
                awful.client.focus.byidx(-1)
              end
              )
            )


          tagnames = {"🏠 HOME " , "🔘 MEDIA ", "TERM "}
          local function set_wallpaper(s)
            -- Wallpaper
            if beautiful.wallpaper then
              local wallpaper = beautiful.wallpaper
              -- If wallpaper is a function, call it with the screen
              if type(wallpaper) == "function" then
                wallpaper = wallpaper(s)
              end
              gears.wallpaper.maximized(wallpaper, s, true)
            end
          end

          -- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
          screen.connect_signal("property::geometry", set_wallpaper)

          function separator(direction)
            if type(direction) ~= 'string' or not (direction ~= 'left' or direction ~= 'right') then
              direction = 'left'
            end
            local value
            if direction == 'left' then value = '' else value =  '' end
            return wibox.widget.textbox(string.format(" %s ", value))
          end
          awful.screen.connect_for_each_screen(
            function(s)
              -- Wallpaper
              set_wallpaper(s)

              -- Each screen has its own tag table.
              tags.statics(tagnames)
              -- awful.tag(tagnames, s, awful.layout.layouts[1])

              -- Create a promptbox for each screen
              s.mypromptbox = awful.widget.prompt()
              -- Create an imagebox widget which will contain an icon indicating which layout we're using.
              -- We need one layoutbox per screen.
              s.mylayoutbox = awful.widget.layoutbox(s)
              s.mylayoutbox:buttons(
                gears.table.join(
                  awful.button(
                    {},
                    1,
                    function()
                      awful.layout.inc(1)
                    end
                    ),
                  awful.button(
                    {},
                    3,
                    function()
                      awful.layout.inc(-1)
                    end
                    ),
                  awful.button(
                    {},
                    4,
                    function()
                      awful.layout.inc(1)
                    end
                    ),
                  awful.button(
                    {},
                    5,
                    function()
                      awful.layout.inc(-1)
                    end
                    )
                  )
                )
              -- Create a taglist widget
              s.mytaglist =
              awful.widget.taglist {
                screen = s,
                filter = awful.widget.taglist.filter.all,
                buttons = taglist_buttons
              }

              -- Create a tasklist widget
              s.mytasklist =
              awful.widget.tasklist {
                screen = s,
                filter = awful.widget.tasklist.filter.currenttags,
                buttons = tasklist_buttons
              }

              systray = wibox.widget.systray()
              systray.forced_height = 2.5

              -- Create the wibox
              s.mywibox = awful.wibar({position = "top", screen = s})

              -- Add widgets to the wibox
              s.mywibox:setup {
                layout = wibox.layout.align.horizontal,
                {
                  -- Left widgets
                  layout = wibox.layout.fixed.horizontal,
                  mylauncher,
                  separator('left'),
                  s.mytaglist,
                  separator('right'),
                  s.mypromptbox,
                  separator('right'),
                  widgets.packages.build(),
                  separator('right')
                },
                s.mytasklist, -- Middle widget
                {
                  -- Right widgets
                  layout = wibox.layout.fixed.horizontal,
                  -- separator(),
                  -- require ('widgets/htb'),
                  separator(),
                  mykeyboardlayout,
                  separator(),
                  systray,
                  separator(),
                  wifibar,
                  -- separator(),
                  -- myvolumewidget,
                  separator(),
                  netbar,
                  separator(),
                  widgets.battery.widget(),
                  separator(),
                  mytextclock,
                  separator(),
                  s.mylayoutbox
                }
              }
            end
            )

          -- }}}

          -- - {{{ Mouse bindings
          root.buttons(
            gears.table.join(
              awful.button(
                {},
                3,
                function()
                  mymainmenu:toggle()
                end
                ),
              awful.button({}, 4, awful.layout.inc(1)),
              awful.button({}, 5, awful.layout.inc(-1))
              )
            )
          -- }}}

          -- - {{{ Key bindings
          globalkeys =
          gears.table.join(
            -- next layout
            awful.key({modkey}, "s", hotkeys_popup.show_help, {description = "show help", group = "awesome"}),
            awful.key({modkey}, "Left", awful.tag.viewprev, {description = "view previous", group = "tag"}),
            awful.key({modkey}, "Right", awful.tag.viewnext, {description = "view next", group = "tag"}),
            awful.key({modkey}, "Escape", awful.tag.history.restore, {description = "go back", group = "tag"}),
            awful.key(
              {modkey},
              "j",
              function()
                awful.client.focus.byidx(1)
              end,
              {description = "focus next by index", group = "client"}
              ),
            awful.key(
              {modkey},
              "k",
              function()
                awful.client.focus.byidx(-1)
              end,
              {description = "focus previous by index", group = "client"}
              ),
            awful.key(
              {modkey, "Shift"},
              "w",
              function()
                mymainmenu:show()
              end,
              {description = "show main menu", group = "awesome"}
              ),
            -- Layout manipulation
            awful.key(
              {modkey, "Shift"},
              "j",
              function()
                awful.client.swap.byidx(1)
              end,
              {description = "swap with next client by index", group = "client"}
              ),
            awful.key(
              {modkey, "Shift"},
              "k",
              function()
                awful.client.swap.byidx(-1)
              end,
              {description = "swap with previous client by index", group = "client"}
              ),
            awful.key(
              {modkey, "Control"},
              "j",
              function()
                awful.screen.focus_relative(1)
              end,
              {description = "focus the next screen", group = "screen"}
              ),
            awful.key(
              {modkey, "Control"},
              "k",
              function()
                awful.screen.focus_relative(-1)
              end,
              {description = "focus the previous screen", group = "screen"}
              ),
            awful.key({modkey}, "u", awful.client.urgent.jumpto, {description = "jump to urgent client", group = "client"}),
            awful.key(
              {modkey, "Shift"},
              "Tab",
              function()
                awful.client.focus.history.previous()
                if client.focus then
                  client.focus:raise()
                end
              end,
              {description = "go back", group = "client"}
              ),
            awful.key(
              {modkey, "Control"},
              "j",
              function()
                awful.layout.inc(1)
              end,
              {description = "next layout", group = "client"}
              ),
            awful.key(
              {modkey, "Control"},
              "k",
              function()
                awful.layout.inc(-1)
              end,
              {description = "previous layout", group = "client"}
              ),
            -- Standard program
            awful.key(
              {modkey},
              "Return",
              function()
                awful.spawn(terminal)
              end,
              {description = "open a terminal", group = "launcher"}
              ),
            awful.key({modkey, "Control"}, "r", awesome.restart, {description = "reload awesome", group = "awesome"}),
            awful.key({modkey, "Shift"}, "q", awesome.quit, {description = "quit awesome", group = "awesome"}),
            awful.key(
              {modkey},
              "l",
              function()
                awful.tag.incmwfact(0.05)
              end,
              {description = "increase master width factor", group = "layout"}
              ),
            awful.key(
              {modkey},
              "h",
              function()
                awful.tag.incmwfact(-0.05)
              end,
              {description = "decrease master width factor", group = "layout"}
              ),
            awful.key(
              {modkey, "Shift"},
              "h",
              function()
                awful.tag.incnmaster(1, nil, true)
              end,
              {description = "increase the number of master clients", group = "layout"}
              ),
            awful.key(
              {modkey, "Shift"},
              "l",
              function()
                awful.tag.incnmaster(-1, nil, true)
              end,
              {description = "decrease the number of master clients", group = "layout"}
              ),
            awful.key(
              {modkey, "Control"},
              "h",
              function()
                awful.tag.incncol(1, nil, true)
              end,
              {description = "increase the number of columns", group = "layout"}
              ),
            awful.key(
              {modkey, "Control"},
              "l",
              function()
                awful.tag.incncol(-1, nil, true)
              end,
              {description = "decrease the number of columns", group = "layout"}
              ),
            awful.key(
              {modkey},
              "tab",
              function()
                awful.layout.inc(1)
              end,
              {description = "select next", group = "layout"}
              ),
            awful.key(
              { modkey, }, 'space', widgets.keyboard.next_layout, { description = 'select next keyboard layout', group = 'keyboard'}
              ),
            awful.key(
              {modkey, "Shift"},
              "space",
              function()
                awful.layout.inc(-1)
              end,
              {description = "select previous", group = "layout"}
              ),
            awful.key(
              {modkey, "Control"},
              "n",
              function()
                local c = awful.client.restore()
                -- Focus restored client
                if c then
                  c:emit_signal("request::activate", "key.unminimize", {raise = true})
                end
              end,
              {description = "restore minimized", group = "client"}
              ),
            -- Prompt
            awful.key(
              {modkey},
              "r",
              function()
                awful.screen.focused().mypromptbox:run()
              end,
              {description = "run prompt", group = "launcher"}
              ),
            awful.key(
              {modkey},
              "x",
              function()
                awful.prompt.run {
                  prompt = "Lua : ",
                  textbox = awful.screen.focused().mypromptbox.widget,
                  exe_callback = awful.util.eval,
                  history_path = awful.util.get_cache_dir() .. "/history_eval"
                }
              end,
              {description = "lua execute prompt", group = "awesome"}
              ),
            -- Menubar
            awful.key(
              {modkey},
              "p",
              function()
                menubar.show()
              end,
              {description = "show the menubar", group = "launcher"}
              )
            )

          clientkeys =
          gears.table.join(
            awful.key(
              {modkey},
              "f",
              function(c)
                c.fullscreen = not c.fullscreen
                c:raise()
              end,
              {description = "toggle fullscreen", group = "client"}
              ),
            awful.key(
              {modkey},
              "w",
              function(c)
                c:kill()
              end,
              {description = "close", group = "client"}
              ),
            awful.key(
              {modkey, "Control"},
              "space",
              awful.client.floating.toggle,
              {description = "toggle floating", group = "client"}
              ),
            awful.key(
              {modkey, "Control"},
              "Return",
              function(c)
                c:swap(awful.client.getmaster())
              end,
              {description = "move to master", group = "client"}
              ),
            awful.key(
              {modkey},
              "o",
              function(c)
                c:move_to_screen()
              end,
              {description = "move to screen", group = "client"}
              ),
            awful.key(
              {modkey},
              "t",
              function(c)
                c.ontop = not c.ontop
              end,
              {description = "toggle keep on top", group = "client"}
              ),
            awful.key(
              {modkey},
              "n",
              function(c)
                -- The client currently has the input focus, so it cannot be
                -- minimized, since minimized clients can't have the focus.
                c.minimized = true
              end,
              {description = "minimize", group = "client"}
              ),
            awful.key(
              {modkey},
              "m",
              function(c)
                c.maximized = not c.maximized
                c:raise()
              end,
              {description = "(un)maximize", group = "client"}
              ),
            awful.key(
              {modkey, "Control"},
              "m",
              function(c)
                c.maximized_vertical = not c.maximized_vertical
                c:raise()
              end,
              {description = "(un)maximize vertically", group = "client"}
              ),
            awful.key(
              {modkey, "Shift"},
              "m",
              function(c)
                c.maximized_horizontal = not c.maximized_horizontal
                c:raise()
              end,
              {description = "(un)maximize horizontally", group = "client"}
              ),
            awful.key({modkey, "Shift"}, "l", switchKeyboard, {description = "Shift keyboard layout", group = "awesome"})

            )

          local function capitalize(str)
            return string.format("%s%s", string.upper(string.sub(str, 1, 1)), string.lower(string.sub(str, 2, #str)))
          end

          local function launch(keygroup, lastkey, command, name)
            if name == nil then
              name = command
            end

            return awful.key(
              keygroup,
              lastkey,
              function()
                awful.spawn(command)
              end,
              {description = "Start " .. capitalize(name), group = "launcher"}
              )
          end

          -- Bind application launchers
          globalkeys =
          gears.table.join(
            globalkeys,
            -- Launch discord
            launch({modkey}, "d", "/opt/Discord/Discord", "discord"),
            launch({modkey}, "b", "firefox", "browser"), -- NOTE: may change this to a custom function that finds browsers and prompts
            launch({"Shift"}, "Print", terminal .. "mate-screenshot -i", "screenshot dialog")
            )


          -- Bind new tag stuff
          globalkeys = gears.table.join(
            globalkeys,
            -- Tests:
            --  icon -- no  matches
            --  equal name - passed
            --  just add the fucking tag -- passed
            awful.key(
              { modkey,       }, 'a', tags.add,
              { description = 'Add new tag', group = 'tag'}),

            -- Tests:
            --  just delete the fucking tag --passed
            awful.key(
              { modkey, 'Shift'}, 'd', tags.delete_current,
              { description = 'Delete current tag', group = 'tag'}),

            awful.key(
              { modkey, 'Shift' }, 'r', tags.rename,
              { description = 'Rename current tag', group = 'tag'}),

            awful.key(
              { modkey, 'Shift', }, 'g',  tags.move_to_tag, 
              { description = 'Move client to existing tag', group = 'tag'}),

            awful.key(
              { modkey,  alt_key }, 'g', tags.move_to_new_tag,
              { description = 'Create new tag and move selected client there', group = 'tag' }
              ),

            awful.key(
              { modkey, },'g', tags.go_to_tag,
              { description = 'Go to tag by search', group = 'tag' }
              )

            )


          -- Bind all key numbers to tags.
          -- Be careful: we use keycodes to make it work on any keyboard layout.
          -- This should map on the top row of your keyboard, usually 1 to 9.
          for i = 1, 9 do
            globalkeys =
            gears.table.join(
              globalkeys,
              -- View tag only.
              awful.key(
                {modkey},
                "#" .. i + 9,
                function()
                  local screen = awful.screen.focused()
                  local tag = screen.tags[i]
                  if tag then
                    tag:view_only()
                  end
                end,
                {description = "view tag #" .. i, group = "tag"}
                ),
              -- Toggle tag display.
              awful.key(
                {modkey, "Control"},
                "#" .. i + 9,
                function()
                  local screen = awful.screen.focused()
                  local tag = screen.tags[i]
                  if tag then
                    awful.tag.viewtoggle(tag)
                  end
                end,
                {description = "toggle tag #" .. i, group = "tag"}
                ),
              -- Move client to tag.
              awful.key(
                {modkey, "Shift"},
                "#" .. i + 9,
                function()
                  if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                      client.focus:move_to_tag(tag)
                    end
                  end
                end,
                {description = "move focused client to tag #" .. i, group = "tag"}
                ),
              -- Toggle tag on focused client.
              awful.key(
                {modkey, "Control", "Shift"},
                "#" .. i + 9,
                function()
                  if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                      client.focus:toggle_tag(tag)
                    end
                  end
                end,
                {description = "toggle focused client on tag #" .. i, group = "tag"}
                )
              )
          end

          clientbuttons =
          gears.table.join(
            awful.button(
              {},
              1,
              function(c)
                c:emit_signal("request::activate", "mouse_click", {raise = true})
              end
              ),
            awful.button(
              {modkey},
              1,
              function(c)
                c:emit_signal("request::activate", "mouse_click", {raise = true})
                awful.mouse.client.move(c)
              end
              ),
            awful.button(
              {modkey},
              3,
              function(c)
                c:emit_signal("request::activate", "mouse_click", {raise = true})
                awful.mouse.client.resize(c)
              end
              )
            )

          -- Set keys
          root.keys(globalkeys)
          -- }}}

          -- {{{ Rules
                -- Rules to apply to new clients (through the "manage" signal).
                awful.rules.rules = {
                  -- All clients will match this rule.
                  {
                    rule = {},
                    properties = {
                      border_width = beautiful.border_width,
                      border_color = beautiful.border_normal,
                      focus = awful.client.focus.filter,
                      raise = true,
                      keys = clientkeys,
                      buttons = clientbuttons,
                      screen = awful.screen.preferred,
                      placement = awful.placement.no_overlap + awful.placement.no_offscreen
                    }
                  },
                  -- Floating clients.
                  {
                    rule_any = {
                      instance = {
                        "DTA", -- Firefox addon DownThemAll.
                        "copyq", -- Includes session name in class.
                        "pinentry"
                      },
                      class = {
                        "Arandr",
                        "Blueman-manager",
                        "Gpick",
                        "Kruler",
                        "MessageWin", -- kalarm.
                        "Sxiv",
                        "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
                        "Wpa_gui",
                        "veromix",
                        "xtightvncviewer"
                      },
                      -- Note that the name property shown in xprop might be set slightly after creation of the client
                      -- and the name shown there might not match defined rules here.
                      name = {
                        "Event Tester" -- xev.
                      },
                      role = {
                        "AlarmWindow", -- Thunderbird's calendar.
                        "ConfigManager", -- Thunderbird's about:config.
                        "pop-up" -- e.g. Google Chrome's (detached) Developer Tools.
                      }
                    },
                    properties = {floating = true}
                  },
                  -- Add titlebars to normal clients and dialogs
                  {
                    rule_any = {
                      type = {"normal", "dialog"}
                    },
                    properties = {titlebars_enabled = false}
                  }

                  -- Set Firefox to always map on the tag named "2" on screen 1.
                  -- { rule = { class = "Firefox" },
                    --   properties = { screen = 1, tag = "2" } },
                  }
                  -- }}}

                  -- {{{ Signals
                        -- Signal function to execute when a new client appears.
                        client.connect_signal(
                          "manage",
                          function(c)
                            -- Set the windows at the slave,
                            -- i.e. put it at the end of others instead of setting it master.
                            -- if not awesome.startup then awful.client.setslave(c) end

                            if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
                              -- Prevent clients from being unreachable after screen count changes.
                              awful.placement.no_offscreen(c)
                            end
                          end
                          )

                        -- Add a titlebar if titlebars_enabled is set to true in the rules.
                        client.connect_signal(
                          "request::titlebars",
                          function(c)
                            -- buttons for the titlebar
                            local buttons =
                            gears.table.join(
                              awful.button(
                                {},
                                1,
                                function()
                                  c:emit_signal("request::activate", "titlebar", {raise = true})
                                  awful.mouse.client.move(c)
                                end
                                ),
                              awful.button(
                                {},
                                3,
                                function()
                                  c:emit_signal("request::activate", "titlebar", {raise = true})
                                  awful.mouse.client.resize(c)
                                end
                                )
                              )

                            awful.titlebar(c):setup {
                              {
                                -- Left
                                awful.titlebar.widget.iconwidget(c),
                                buttons = buttons,
                                layout = wibox.layout.fixed.horizontal
                              },
                              {
                                -- Middle
                                {
                                  -- Title
                                  align = "center",
                                  widget = awful.titlebar.widget.titlewidget(c)
                                },
                                buttons = buttons,
                                layout = wibox.layout.flex.horizontal
                              },
                              {
                                -- Right
                                awful.titlebar.widget.floatingbutton(c),
                                awful.titlebar.widget.maximizedbutton(c),
                                awful.titlebar.widget.stickybutton(c),
                                awful.titlebar.widget.ontopbutton(c),
                                awful.titlebar.widget.closebutton(c),
                                layout = wibox.layout.fixed.horizontal()
                              },
                              layout = wibox.layout.align.horizontal
                            }
                          end
                          )

                        -- Enable sloppy focus, so that focus follows mouse.
                        client.connect_signal(
                          "mouse::enter",
                          function(c)
                            c:emit_signal("request::activate", "mouse_enter", {raise = false})
                          end
                          )

                        client.connect_signal(
                          "focus",
                          function(c)
                            if type(c) == "table" then
                              c.border_color = beautiful.border_focus
                            end
                          end
                          )
                        client.connect_signal(
                          "unfocus",
                          function(c)
                            c.border_color = beautiful.border_normal
                          end
                          )
                        -- }}}
