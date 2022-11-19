local gfind = string.gmatch or string.gfind

ShaguTweaks.GetExpansion = function()
  local _, _, _, client = GetBuildInfo()
  client = client or 11200

  -- detect client expansion
  if client >= 20000 and client <= 20400 then
    return "tbc"
  elseif client >= 30000 and client <= 30300 then
    return "wotlk"
  else
    return "vanilla"
  end
end

ShaguTweaks.GetGlobalEnv = function()
  if ShaguTweaks.GetExpansion() == 'vanilla' then
    return getfenv(0)
  else
    return _G or getfenv(0)
  end
end

local _G = ShaguTweaks.GetGlobalEnv()

local gradientcolors = {}
ShaguTweaks.GetColorGradient = function(perc)
  perc = perc > 1 and 1 or perc
  perc = perc < 0 and 0 or perc
  perc = floor(perc*100)/100

  local index = perc
  if not gradientcolors[index] then
    local r1, g1, b1, r2, g2, b2

    if perc <= 0.5 then
      perc = perc * 2
      r1, g1, b1 = 1, 0, 0
      r2, g2, b2 = 1, 1, 0
    else
      perc = perc * 2 - 1
      r1, g1, b1 = 1, 1, 0
      r2, g2, b2 = 0, 1, 0
    end

    local r = ShaguTweaks.round(r1 + (r2 - r1) * perc, 4)
    local g = ShaguTweaks.round(g1 + (g2 - g1) * perc, 4)
    local b = ShaguTweaks.round(b1 + (b2 - b1) * perc, 4)
    local h = ShaguTweaks.rgbhex(r,g,b)

    gradientcolors[index] = {}
    gradientcolors[index].r = r
    gradientcolors[index].g = g
    gradientcolors[index].b = b
    gradientcolors[index].h = h
  end

  return gradientcolors[index].r,
    gradientcolors[index].g,
    gradientcolors[index].b,
    gradientcolors[index].h
end

ShaguTweaks.GetExpansion = function()
  local _, _, _, client = GetBuildInfo()
  client = client or 11200

  -- detect client expansion
  if client >= 20000 and client <= 20400 then
    return "tbc"
  elseif client >= 30000 and client <= 30300 then
    return "wotlk"
  else
    return "vanilla"
  end
end

ShaguTweaks.HookScript = function(f, script, func)
  local prev = f:GetScript(script)
  f:SetScript(script, function(a1,a2,a3,a4,a5,a6,a7,a8,a9)
    if prev then prev(a1,a2,a3,a4,a5,a6,a7,a8,a9) end
    func(a1,a2,a3,a4,a5,a6,a7,a8,a9)
  end)
end

ShaguTweaks.HookAddonOrVariable = function(addon, func)
  local lurker = CreateFrame("Frame", nil)
  lurker.func = func
  lurker:RegisterEvent("ADDON_LOADED")
  lurker:RegisterEvent("VARIABLES_LOADED")
  lurker:RegisterEvent("PLAYER_ENTERING_WORLD")
  lurker:SetScript("OnEvent",function()
    if IsAddOnLoaded(addon) or _G[addon] then
      this:func()
      this:UnregisterAllEvents()
    end
  end)
end

local hooks = {}
ShaguTweaks.hooksecurefunc = function(name, func, append)
  if not _G[name] then return end

  hooks[tostring(func)] = {}
  hooks[tostring(func)]["old"] = _G[name]
  hooks[tostring(func)]["new"] = func

  if append then
    hooks[tostring(func)]["function"] = function(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
      hooks[tostring(func)]["old"](a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
      hooks[tostring(func)]["new"](a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
    end
  else
    hooks[tostring(func)]["function"] = function(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
      hooks[tostring(func)]["new"](a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
      hooks[tostring(func)]["old"](a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
    end
  end

  _G[name] = hooks[tostring(func)]["function"]
end

local sanitize_cache = {}
ShaguTweaks.SanitizePattern = function(pattern)
  if not sanitize_cache[pattern] then
    local ret = pattern
    -- escape magic characters
    ret = gsub(ret, "([%+%-%*%(%)%?%[%]%^])", "%%%1")
    -- remove capture indexes
    ret = gsub(ret, "%d%$","")
    -- catch all characters
    ret = gsub(ret, "(%%%a)","%(%1+%)")
    -- convert all %s to .+
    ret = gsub(ret, "%%s%+",".+")
    -- set priority to numbers over strings
    ret = gsub(ret, "%(.%+%)%(%%d%+%)","%(.-%)%(%%d%+%)")
    -- cache it
    sanitize_cache[pattern] = ret
  end

  return sanitize_cache[pattern]
end

local capture_cache = {}
ShaguTweaks.GetCaptures = function(pat)
  local r = capture_cache
  if not r[pat] then
    for a, b, c, d, e in gfind(gsub(pat, "%((.+)%)", "%1"), gsub(pat, "%d%$", "%%(.-)$")) do
      r[pat] = { a, b, c, d, e}
    end
  end

  if not r[pat] then return nil, nil, nil, nil end
  return r[pat][1], r[pat][2], r[pat][3], r[pat][4], r[pat][5]
end

ShaguTweaks.cmatch = function(str, pat)
  -- read capture indexes
  local a,b,c,d,e = ShaguTweaks.GetCaptures(pat)
  local _, _, va, vb, vc, vd, ve = string.find(str, ShaguTweaks.SanitizePattern(pat))

  -- put entries into the proper return values
  local ra, rb, rc, rd, re
  ra = e == "1" and ve or d == "1" and vd or c == "1" and vc or b == "1" and vb or va
  rb = e == "2" and ve or d == "2" and vd or c == "2" and vc or a == "2" and va or vb
  rc = e == "3" and ve or d == "3" and vd or a == "3" and va or b == "3" and vb or vc
  rd = e == "4" and ve or a == "4" and va or c == "4" and vc or b == "4" and vb or vd
  re = a == "5" and va or d == "5" and vd or c == "5" and vc or b == "5" and vb or ve

  return ra, rb, rc, rd, re
end


local timer
ShaguTweaks.QueueFunction = function(a1,a2,a3,a4,a5,a6,a7,a8,a9)
  if not timer then
    timer = CreateFrame("Frame")
    timer.queue = {}
    timer.interval = TOOLTIP_UPDATE_TIME
    timer.DeQueue = function()
      local item = table.remove(timer.queue,1)
      if item then
        item[1](item[2],item[3],item[4],item[5],item[6],item[7],item[8],item[9])
      end
      if table.getn(timer.queue) == 0 then
        timer:Hide() -- no need to run the OnUpdate when the queue is empty
      end
    end
    timer:SetScript("OnUpdate",function()
      this.sinceLast = (this.sinceLast or 0) + arg1
      while (this.sinceLast > this.interval) do
        this.DeQueue()
        this.sinceLast = this.sinceLast - this.interval
      end
    end)
  end
  table.insert(timer.queue,{a1,a2,a3,a4,a5,a6,a7,a8,a9})
  timer:Show() -- start the OnUpdate
end

ShaguTweaks.strsplit = function(delimiter, subject)
  if not subject then return nil end
  local delimiter, fields = delimiter or ":", {}
  local pattern = string.format("([^%s]+)", delimiter)
  string.gsub(subject, pattern, function(c) fields[table.getn(fields)+1] = c end)
  return unpack(fields)
end

ShaguTweaks.rgbhex = function(r, g, b, a)
  if type(r) == "table" then
    if r.r then
      _r, _g, _b, _a = r.r, r.g, r.b, (r.a or 1)
    elseif table.getn(r) >= 3 then
      _r, _g, _b, _a = r[1], r[2], r[3], (r[4] or 1)
    end
  elseif tonumber(r) then
    _r, _g, _b, _a = r, g, b, (a or 1)
  end

  if _r and _g and _b and _a then
    -- limit values to 0-1
    _r = _r + 0 > 1 and 1 or _r + 0
    _g = _g + 0 > 1 and 1 or _g + 0
    _b = _b + 0 > 1 and 1 or _b + 0
    _a = _a + 0 > 1 and 1 or _a + 0
    return string.format("|c%02x%02x%02x%02x", _a*255, _r*255, _g*255, _b*255)
  end

  return ""
end

local border = {
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true, tileSize = 8, edgeSize = 16,
  insets = { left = 0, right = 0, top = 0, bottom = 0 }
}
ShaguTweaks.AddBorder = function(frame, inset, color)
  if not frame then return end
  if frame.ShaguTweaks_border then return frame.ShaguTweaks_border end

  local top, right, bottom, left

  if type(inset) == "table" then
    top, right, bottom, left = unpack((inset))
    left, bottom = -left, -bottom
  end

  if not frame.ShaguTweaks_border then
    frame.ShaguTweaks_border = CreateFrame("Frame", nil, frame)
    frame.ShaguTweaks_border:SetPoint("TOPLEFT", frame, "TOPLEFT", (left or -inset), (top or inset))
    frame.ShaguTweaks_border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", (right or inset), (bottom or -inset))
    frame.ShaguTweaks_border:SetBackdrop(border)

    if color then
      frame.ShaguTweaks_border:SetBackdropBorderColor(color.r, color.g, color.b, 1)
    end
  end

  return frame.ShaguTweaks_border
end

ShaguTweaks.round = function(input, places)
  if not places then places = 0 end
  if type(input) == "number" and type(places) == "number" then
    local pow = 1
    for i = 1, places do pow = pow * 10 end
    return floor(input * pow + 0.5) / pow
  end
end

ShaguTweaks.Abbreviate = function(number, eachk)
  local sign = number < 0 and -1 or 1
  number = math.abs(number)

  if number > 1000000 then
    return ShaguTweaks.round(number/1000000*sign,2) .. "m"
  elseif not eachk and number > 10000 then
    return ShaguTweaks.round(number/1000*sign,2) .. "k"
  elseif eachk and number > 1000 then
    return ShaguTweaks.round(number/1000*sign,2) .. "k"
  end

  return number
end

ShaguTweaks.TimeConvert = function(remaining)
  local color = "|cffffffff"

  if remaining < 5 then
    color = "|cffff5555"
  elseif remaining < 10 then
    color = "|cffffff55"
  end

  if remaining < 60 then
    return color..ceil(remaining)
  elseif remaining < 3600 then
    return color..ceil(remaining/60).."m"
  elseif remaining < 86400 then
    return color..ceil(remaining/3600).."h"
  else
    return color..ceil(remaining/86400).."d"
  end
end

-- http://lua-users.org/wiki/SortedIteration
local function __genOrderedIndex( t )
  local orderedIndex = {}
  for key in pairs(t) do
    table.insert( orderedIndex, key )
  end
  table.sort( orderedIndex )
  return orderedIndex
end

local function orderedNext(t, state)
  local key = nil
  if state == nil then
    t.__orderedIndex = __genOrderedIndex( t )
    key = t.__orderedIndex[1]
  else
    for i = 1,table.getn(t.__orderedIndex) do
      if t.__orderedIndex[i] == state then
        key = t.__orderedIndex[i+1]
      end
    end
  end

  if key then
    return key, t[key]
  end

  t.__orderedIndex = nil
  return
end

ShaguTweaks.spairs = function(t)
  return orderedNext, t, nil
end
