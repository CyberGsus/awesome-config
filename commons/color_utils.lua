local config_colors = {}

config_colors.padleft = function (str, t, len)
  if type (str) ~= 'string' then return '' end
  if type (t) ~= 'string' then t = '0' end
  if type (len) ~= 'number' or len < #str then len = #str end
  return string.rep(t, len - #str) .. str
end

config_colors.parse_hex = function (str)
  local result = 0
  for i = 1, #str do
    local char = string.byte(string.sub(str, i, i))
    local num = 0
    -- char >= '0' and char <= '9'
    if char >= 48 and char <= 57 then
      num = char - 48
    end
    --- char >= 'a' and char <= 'f'
    if char >= 97 and char <= 102 then
      num = char - 87
    end


    local pow = 16 ^ (#str - i)
    result = result + (num * pow)
  end

  return math.floor(result)
end


config_colors.to_hex = function (hex)
  local result = ''
  repeat
    local next_value = hex & 0xf
    local next_char
    if next_value >= 10 then
      next_char = next_value + 87
    else
      next_char = next_value + 48
    end

    result = string.char(next_char) .. result

    hex = hex >> 4
  until hex <= 0
  return result
end

config_colors.rgbs_to_table = function (rgbs)
  if type (rgbs) ~=  'string' then return { } end
  local result = { }
  local rgbss = string.sub(rgbs, 2, #rgbs)
  for i = 1, #rgbs, 2 do
    if i == #rgbs then break end
    result[#result+1] = config_colors.parse_hex(string.sub(rgbss, i, i + 1))
  end
  return result
end


config_colors.table_to_str = function (tbl)
  if type (tbl) ~= 'table' then return '' end
  local result = ''
  for i = 1, #tbl do
    local next_str = config_colors.to_hex(tbl[i])
    if tbl[i] < 10 then
      next_str = '0' .. next_str
    end
    result = result .. next_str
  end
  return '#' .. result
end


config_colors.apply_alpha = function (col1, col2, alpha)
  local color1
  if type (col1) == 'string' then
    color1 = config_colors.rgbs_to_table(col1)
  else
    if type (col1) == 'table' then
      color1 = col1
    else
      color1 = { 0, 0, 0}
    end
  end
  local color2
  if type (col2) == 'string' then
    color2 = config_colors.rgbs_to_table(col2)
  else
    if type (col2) == 'table' then
      color2 = col2
    else
      color2 = { 0, 0, 0}
    end
  end

  local color3 = { }

  if alpha == nil then alpha = 0 end

  for i = 1, 3 do
    color3[i] = math.floor(alpha * color2[i] + (1 - alpha) * color1[i])
  end

  return config_colors.table_to_str(color3)

end

-- Puts alpha into #rrggbbaa format
config_colors.apply_direct_alpha = function (col1, alpha)
  if type (col1) == 'table' then col1 = config_colors.table_to_str(col1) end
  if type (col1) ~= 'string' then return '#000000' end
  return col1 .. config_colors.padleft(config_colors.to_hex(math.floor(alpha * 255), '0', 2))
end


return config_colors
