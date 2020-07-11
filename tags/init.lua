local awful = require 'awful'

local icons = require 'icons'
local themes = require 'themes'
local layouts = require 'tags/layouts'
local utils = require 'utils'
local naughty = require 'naughty'



local function check_tag(name)

  local cache_name = name

  if type(cache_name) ~= 'string' then
    cache_name = get_count()
  end
  -- check if existance, then use a new number for identification
  if awful.tag.find_by_name(awful.screen.focused(), name) ~= nil then
    name = cache_name .. get_count()
  end

  -- now check if more rules have been set

  local config = icons.backend.get_config()

  for k, v in utils.namepairs(config.matches) do
    local a, b
    if config.case_insensitive then
      a, b = k:lower(), cache_name:lower()
    else
      a, b = k, cache_name
    end

    if b:match(a) then
      local append = utils.check_string(v.append)
      if #append > 0 then append = ' ' .. append end

      local prepend = utils.check_string(v.prepend)
      if #prepend > 0 then prepend = prepend .. ' ' end

      name = name .. utils.check_string(append)
      name = utils.check_string(prepend) .. name

      if v.uppercase == true then
        name = name:upper()
      elseif v.lowercase == true then
        name = name:lower()
      else
        name = name:sub(1, 1):upper() .. name:sub(2):lower()
      end

    end
  end




  return name

end




-- -- {{ Building a tag
--

local static_tags = { }
local count = 1 -- for no name
local function get_count()
  count = count + 1
  return tostring(count - 1)
end


local function current_tag()
  return awful.screen.focused().selected_tag
end


local function rename_tag(name)
  if type(name) ~= 'string' or #name == 0 then return end
  local t = current_tag()
  if not t then return end
  t.name = check_tag(name)
  t.icon = icons.get_icon(name) -- update icon as well
end


local function search_tag(name, fixed)
  local tags = awful.screen.focused().tags
  if type(fixed) ~= 'boolean' then fixed = false end
  local matcher = name
  if fixed then matcher = name .. '%s*$' end
  for _, tags in pairs({ awful.screen.focused().tags, static_tags }) do
    for _, tag in pairs(tags) do
      local match = tag.name:lower():match(name:lower())
      -- local matcher = string.format('^%s%%s*$', check_tag(name))
      local match_literal = tag.name:match(matcher)
      if match then
        return tag, match, match_literal
      end
    end
  end
  return nil
end

local function move_to_tag()
  awful.prompt.run {
    prompt = 'Move to tag: ',
    textbox = awful.screen.focused().mypromptbox.widget,

    exe_callback = function(name)
      local c = client.focus
      if not c then return end
      local t = search_tag(name)
      if not t then return end
      c:tags({t})
      -- t:view_only()
    end
  }
end


local function static(name)
  if not name or #name == 0 then return end
  local t = search_tag(name)
  if t == nil or t.name ~= name then
    t = awful.tag.add (
      check_tag(name) .. ' ',
      { 
        layout        = layouts.check(layout),
        screen        = awful.screen.focused(),
        icon          = icons.get_icon(name),
        volatile      = false, -- delete when last client goes out
      }
      )

    static_tags[#static_tags + 1] = t
    t:view_only()

  end
end

local function pre_tags(list) -- - { name1, name2, name3 }
  if type(list) ~= 'table' or #list == 0 then return end
  for _, name in pairs(list) do
    static(name)
  end
end

local function new_tag(name, goto_)
  -- name will only be modified on tag name, but
  -- icon (i hope) will still be matched through input
  -- tag name
  if not name or #name == 0 then
    naughty.notify {
      title = '😠 Cmon! ',
      text = 'Did you really think you can pass me no name?\nThats innapropiate! No pancakes for you!',
      preset = naughty.config.presets.critical -- TODO: add warning preset?
    }
    return 
  end

  local tag, _, match = search_tag(name, true)
  local f = io.open('/home/cyber/testtag', 'w')
  f:write(tostring(match) .. '\n')
  f:write(tostring(name) .. '\n')
  f:close()
  if tag == nil or not match:match(name .. '%s*$')  then


    tag = awful.tag.add (
      check_tag(name) .. ' ',
      {
        layout        = layouts.check(layout),
        screen        = awful.screen.focused(),
        icon          = icons.get_icon(name),
        volatile      = true, -- delete when last client goes out
      }
      )
  else
    -- raise warning TODO warning here
    naughty.notify {
      title = '🚫 Try other name',
      text = 'A tag named "' .. name .. '" already exists.\nMaybe you meant switching to it.',
      preset = naughty.config.presets.low
    }
  end
  if goto_ == nil or goto_ == true then
    tag:view_only()
  end
  return tag
end
-- }}


-- - {{ EXPORTS


local function delete_current()
  local t  = awful.screen.focused().selected_tag
  if not t then return end
  -- check if tag is in initial tags, if so, dont delete it
  for _, tag in pairs(awful.screen.focused().tags) do
    for _, name in pairs(static_tags) do
      if name == tag.name then return end
    end
  end
  t:delete()
end


local function add()
  awful.prompt.run {
    prompt        = "❔ New tag: ",
    textbox       = awful.screen.focused().mypromptbox.widget,
    exe_callback  = new_tag,
  }
end

local function rename()
  awful.prompt.run {
    prompt        = '❔ New tag name: ',
    textbox       = awful.screen.focused().mypromptbox.widget,
    exe_callback  = rename_tag
  }
end

local function clone()
  local t = current_tag()
  if not t then return end
  local clients = t:clients()
  local t2 = awful.tag.add(t.name, awful.tag.getdata(t))
  t2:clients(clients) -- copy clients?
  t2:view_only() -- select that tag
end

local function move_to_new_tag()
  awful.prompt.run {
    prompt = '❔ Move to NEW tag: ',
    textbox       = awful.screen.focused().mypromptbox.widget,
    exe_callback = function(name)
      local c = client.focus
      if not c then
        naughty.notify {
          title = "⚠ Please select a client❗",
          text = "Seriously! Please select a client in order to \nbe able to move it 🥞",
          preset = naughty.config.presets.critical -- TODO: warning preset to say its user's fault
        }
        return 
      end -- no client focused
      local t = new_tag(name, false)
      if not t then return end -- tag not created, but notification was already sent
      c:tags({t})

    end
  }
end

local function go_tag(name)
  local t = search_tag(name)
  -- if not found, raise a notification
  if not t then 
    naughty.notify {
      title = "❗Cant find tag :❗💩",
      text = string.format("🐷 Sorry, a tag named like \"%s\"could not\nbe found 🥞 ", name),
      preset = naughty.config.presets.critical
    }
    t = current_tag()
  end

  t:view_only()


end

local function goTo()
  awful.prompt.run {
    prompt = "Go to tag: ",
    textbox = awful.screen.focused().mypromptbox.widget,
    exe_callback =  go_tag
  }
end


return { 

  clone = clone,
  add = add,
  rename = rename,
  delete_current = delete_current,
  statics  = pre_tags,
  move_to_tag = move_to_tag,
  move_to_new_tag = move_to_new_tag,
  go_to_tag = goTo,
  matches = icons.matches
  -- backend is a table with features that will not act from the frontend
  -- but should be accessible
}
