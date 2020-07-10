pcall(require, "luarocks.loader") -- for lfs
local lfs = require 'lfs'
local gears = require 'gears'
local awful = require 'awful'
local themes = require 'themes'
local utils = require 'utils'

-- some helpers

-- -- {{ configuring stuff

local icon_dir = os.getenv('HOME') .. '/.config/awesome/themes/' .. themes.name() .. '/icons/'


local config = {
  case_insensitive = true,
  full_string = false,
  matches = { --[[
  Structure:
    { 
      prepend: string,
      append: string,
    }
  --  ]]
  }
}

-- }}




local function get_icon_dir()
  return icon_dir
end

-- https://stackoverflow.com/questions/1426954/split-string-in-lua
local function split(inp, sep)
  assert(type(inp) == 'string', 'input must be a string')
  if type(sep) ~= 'string' then sep = '%s' end
  local t = {  }
  for str in inp:gmatch("([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return pairs(t)
end


local function get_icon(tag_name)
  -- checks if I have an icon which matches the tag name, case insensitive
  if type(tag_name) ~= 'string' or #tag_name == 0 then return end
  if config.case_insensitive then tag_name = tag_name:lower() end
  -- now check if it has a match in config overrides
  local ret_val
  for _, name in split(tag_name) do
    local count = 0
    for _, t in utils.filter(config.matches, function(keys,tbl) 
      if type(keys) == 'string' then
        return name:find(keys) ~= nil
      elseif type(keys) == 'table' then
        for k, v in ipairs(keys) do
          if name:find(k) ~= nil then return true end
        end
      else return false
      end
    end) do
      count = count + 1
      if t == nil then goto continue end
      if type(t.icon) == 'string' then
        -- absolute path
        if t.icon:sub(1, 1) == '/' then
          ret_val = t.icon
          break
          -- HOME path
        elseif t.icon:sub(1, 1) == '~' then
          ret_val =  os.getenv('HOME') .. t.icon:sub(2, #t.icon)
          break
          -- relative to icon_dir
        else
          ret_val = icon_dir .. '/' .. t.icon
          break
        end
      end
      ::continue::
    end
  end


  if ret_val then return ret_val end

  -- local pattern = string.format('^%s\\.(.+)$', tag_name)
  for file in io.popen('find "' .. icon_dir .. '" -type f | cut -d/ -f9'):lines() do
    if config.case_insensitive then file = file:lower() end
    for _, name in split(tag_name) do
      if file:match(name) then
        return icon_dir .. '/' .. file
      end
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

local function get_config()
  return config
end


return {
  get_icon = get_icon,
  matches = function(names, new_tbl)
    if type(names) == 'string' then
      names = { names }
    end
    for _, name in ipairs(names) do
      if type(config.matches[name]) ~= 'table' then
        config.matches[name] = {}
      end
      for k, v in utils.namepairs(new_tbl) do
        config.matches[name][k] = v
      end
    end
  end,

  backend = {
    get_config = function()
      return config
    end,
    get_icon_dir = get_icon_dir
  },
}
