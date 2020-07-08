local layout_suit = require 'awful.layout.suit'


local function default()
  return layout_suit.max
end

local function check(name)
  if type(layout) == 'string' then
    local l = layout_suit[name]
    if l ~= nil then
      return l
    end
  elseif type(layout) == 'table' then
    for name, l in pairs(layout_suit) do
      if l == layout then
        return layout
      end
    end
  end
  return default()
end


return {
  check = check,
}
