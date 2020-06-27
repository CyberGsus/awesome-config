pcall(require, "luarocks.loader") -- for lfs
local lfs = require 'lfs'
local awful = require 'awful'
local themes = require 'themes'

-- some helpers
local layouts = require 'icons/layouts'
-- {{ configuring stuff

local icon_dir = os.getenv('HOME') .. '/.config/awesome/themes/' .. themes.name() .. '/icons/'

local config = {
  case_insensitive = true,
}



local function get_icon_dir()
  return icon_dir
end

local function get_icon(tag_name)
  -- checks if I have an icon which matches the tag name, case insensitive
  if type(tag_name) ~= 'string' or #tag_name == 0 then return end
  if config.case_insensitive then tag_name = tag_name:lower() end
  -- local pattern = string.format('^%s\\.(.+)$', tag_name)
  for file in io.popen('find "' .. icon_dir .. '" -type f | cut -d/ -f9'):lines() do
    if config.case_insensitive then file = file:lower() end
    if file:match(tag_name) then
      return icon_dir .. '/' .. file
    end
  end
  return nil -- explicit is better than implicit
end


local function set_icon_dir(newdir)
  if type(newdir) ~= 'string' then return false end -- we dont want weirdos, thanks
  -- check if valid: exists and is directory
  local stat = lfs.attributes(newdir)
  if stat == nil then return false end -- not exists
  if stat.mode ~= 'directory' then return false end -- not a directory
  if not stat.mode:match('r.x......') then return false end -- read, execute (ls and enter the directory)
  -- checks passed
  icon_dir = newdir
  return true
end


-- }}


-- {{ Building a tag
--

local static_tags = { }
local count = 1 -- for no name
local function get_count()
  count = count + 1
  return tostring(count - 1)
end

local function check_tag(name)

  if type(name) ~= 'string' then
    name = get_count()
  end
  -- check if existance, then use a new number for identification
  if awful.tag.find_by_name(awful.screen.focused(), name) ~= nil then
    name = name .. get_count()
  end
  return name
end

local function current_tag()
  return awful.screen.focused().selected_tag
end


local function rename_tag(name)
  if type(name) ~= 'string' or #name == 0 then return end
  local t = current_tag()
  if not t then return end
  t.name = check_tag(name)
  t.icon = get_icon(name) -- update icon as well
end



local function static(name)
  if not name or #name == 0 then return end
  static_tags[#static_tags + 1] = name
  awful.tag.add (
  check_tag(name) .. ' ',
  {
    layout        = layouts.check(layout),
    screen        = awful.screen.focused(),
    icon          = get_icon(name),
    volatile      = false, -- delete when last client goes out
  }
  ):view_only()
end

local function pre_tags(list) -- { name1, name2, name3 }
  if type(list) ~= 'table' or #list == 0 then return end
  for _, name in pairs(list) do
    static(name)
  end
end


local function new_tag(name, layout)
  -- name will only be modified on tag name, but
  -- icon (i hope) will still be matched through input
  -- tag name
  if not name or #name == 0 then return end

  awful.tag.add (
  check_tag(name) .. ' ',
  {
    layout        = layouts.check(layout),
    screen        = awful.screen.focused(),
    icon          = get_icon(name),
    volatile      = true, -- delete when last client goes out
  }
  ):view_only()
end
-- }}


--- {{ EXPORTS


local function delete_current()
  local t  = awful.screen.focused().selected_tag
  if not t then return end
  -- check if tag is in initial tags, if so, dont delete it
  for _, tag in pairs(awful.screen.focused().tags) do
    for _, name in pairs(static_tags) do
      if name == tag then return end
    end
  end
  t:delete()
end


local function add()
  awful.prompt.run {
    prompt        = "New tag: ",
    textbox       = awful.screen.focused().mypromptbox.widget,
    exe_callback  = new_tag,
  }
end

local function rename()
  awful.prompt.run {
    prompt        = 'New tag name: ',
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

--}}

return {
  clone = clone,
  add = add,
  rename = rename,
  delete_current = delete_current,
  statics  = pre_tags,
  icon_dir = icon_dir, -- now my local one should be safe
  -- backend is a table with features that will not act from the frontend
  -- but should be accessible
}
