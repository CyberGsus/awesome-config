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
