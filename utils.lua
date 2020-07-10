return {
  namepairs = function (tbl)
    local final  = {  }
    for k, v in pairs(tbl) do
      if k == 1 then break end
      final[k] = v
    end

    return pairs(final)
  end,

  split =  function (inp, sep)
    assert(type(inp) == 'string', 'input must be a string')
    if type(sep) ~= 'string' then sep = '%s' end
    local t = {  }
    for str in inp:gmatch("([^" .. sep .. "]+)") do
      table.insert(t, str)
    end
    return pairs(t)
  end,


  filter = function (tbl, fun)
    if type(fun) ~= 'function' then
      fun = function(k, v) return true end
    end
    local target = tbl

    local keys = {  }
    for k, _ in pairs(tbl) do
      keys[#keys + 1] = k
    end

    local c_index = 1

    return function()
      for i = c_index, #keys do
        local k = keys[i]
        local v = target[k]
        if fun(k, v) then
          c_index = i + 1 -- save position to later continue
          return k, v
        end
      end
    end
  end,

  filter_pairs = function (fun, ...)
    if type(fun) ~= 'function' then
      fun = function(k, v) return 1 == 1 end
    end

    local it, tbl = ...

    local k, v

    return function()
      while true do
        k, v = it(tbl, k)
        if k == nil then return nil end -- generator exhausted
        if fun(k, v) then
          return k, v
        end
      end
    end
  end,

  check_string = function (obj)
    if type(obj) == 'string' and #obj > 0 then
      return obj
    else
      return ''
    end
  end,

}
