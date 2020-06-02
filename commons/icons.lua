local theme_icons =  '/home/cyber/.themes/Sweet-Dark/assets/'

local icons = { }


local name = function(asset_type, name)
  if name == nil then
    name = ''
  end
  if asset_type == 'normal' then
    name = name .. ''

  elseif asset_type == 'focus' then
    name = name .. '_prelight'
  elseif asset_type == 'inactive' then
    name = name .. '_unfocused'
  elseif asset_type == 'active' then
    name = name .. '_pressed'
  end
  return name
end

icons.themes_path = function()
  return string.format('%s/.config/awesome/themes/', os.getenv('HOME'))
end

icons.aw_icon = function(size, fg, bg, theme_name, themes_dir)
  os.execute(string.format("sh ~/.config/awesome/commons/update-icon.sh \"%s\" \"%s\" \"%s\" \"%s\"",
    theme_name, size, fg, bg
  ))
  return  themes_dir  .. theme_name .. '/' .. 'awesome-icon.png'
end

icons.asset = function(asset_fmt, asset_name, asset_type)
  if asset_type == nil then
    asset_type = 'normal'
  end
  asset_name = name(asset_type, asset_name)
  if asset_fmt == 'png' then
    asset_name = asset_name .. '@2'
  end
  
  return theme_icons .. asset_name .. '.' .. asset_fmt
end




return icons
