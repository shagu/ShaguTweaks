local _G = _G or getfenv(0)

SLASH_RELOAD1 = '/rl'
function SlashCmdList.RELOAD(msg, editbox) ReloadUI() end

message = function(msg)
  DEFAULT_CHAT_FRAME:AddMessage("|cffffff00" .. ( msg or "nil" ))
end
print = print or message

error = function(msg)
  DEFAULT_CHAT_FRAME:AddMessage("|cffff0000".. (msg or "nil" ))
end
seterrorhandler(error)

ShaguTweaks = CreateFrame("Frame")
ShaguTweaks.mods = {}
ShaguTweaks.overwrites = {}

-- flag official modules
local official = true

-- load translation tables
ShaguTweaks.L = (ShaguTweaks_locale[GetLocale()] or ShaguTweaks_locale["enUS"])
ShaguTweaks.T = (ShaguTweaks_translation[GetLocale()] or ShaguTweaks_translation["enUS"])

-- use table index key as translation fallback
ShaguTweaks.T = setmetatable(ShaguTweaks.T, { __index = function(tab,key)
  local value = tostring(key)
  rawset(tab, key, value)
  return value
end})

ShaguTweaks:RegisterEvent("ADDON_LOADED")
ShaguTweaks:RegisterEvent("VARIABLES_LOADED")
ShaguTweaks:SetScript("OnEvent", function()
  -- flag all external modules as unofficial
  if event == "ADDON_LOADED" then
    ShaguTweaks.provider = nil
    official = false
    return
  end

  -- load current expansion
  local expansion = ShaguTweaks:GetExpansion()

  -- initialize empty config
  if not ShaguTweaks_config then ShaguTweaks_config = {} end

  -- initialize overwrites
  ShaguTweaks_config.overwrites = ShaguTweaks_config.overwrites or {}

  -- read all registered mods
  for title, mod in pairs(ShaguTweaks.mods) do
    -- write initial default config
    if not ShaguTweaks_config[title] then
      ShaguTweaks_config[title] = mod.enabled and 1 or 0
    end

    -- load possible overwrites
    if mod.config then
      for name, value in pairs(mod.config) do
        ShaguTweaks.overwrites[name] = value
      end
    end

    -- apply custom overwrites
    if mod.config and ShaguTweaks_config.overwrites then
      for name, value in pairs(ShaguTweaks_config.overwrites) do
        ShaguTweaks.overwrites[name] = value
        mod.config[name] = value
      end
    end

    -- load enabled mods
    if mod.expansions[expansion] and ShaguTweaks_config[title] == 1 then
      mod:enable()
    end
  end
end)

ShaguTweaks.register = function(self, mod)
  -- add fallback captions and providers to categories
  local provider = ShaguTweaks.provider or "|cffFF5555Mods:|r"
  local category = mod.category or ShaguTweaks.T["General"]
  mod.category = category or provider .. " " .. category

  -- register mod
  ShaguTweaks.mods[mod.title] = mod
  return ShaguTweaks.mods[mod.title]
end

local GetConfigValue = function(conf)
  if type(conf) == "table" and conf.r and conf.g and conf.b then
    return string.format("%s,%s,%s,%s", conf.r, conf.g, conf.b, (conf.a or 1))
  elseif type(conf) == "number" or type(conf) == "string" then
    return conf
  end

  return ""
end

-- print message without applied hooks
local originalAddMessage = DEFAULT_CHAT_FRAME.AddMessage
local stdout = function(msg)
  originalAddMessage(DEFAULT_CHAT_FRAME, msg)
end

-- add /st slash command for custom config overwrites
SLASH_STWEAKS1, SLASH_STWEAKS2, SLASH_STWEAKS3 = "/st", "/stweaks", "/shagutweaks"
SlashCmdList["STWEAKS"] = function(msg)
  local cmd = { ShaguTweaks.strsplit(" ", msg) }
  if cmd[1] == "reset" then
    ShaguTweaks_config.overwrites = {}
    ReloadUI()
  elseif cmd[1] then
    local index = cmd[1]
    local input = cmd[2] or ""

    -- detect best value format
    local value
    local rgba, _, r, g, b, a = string.find(input, "(.+),(.+),(.+),(.+)")

    value = rgba and { r = r, g = g, b = b, a = a }
    value = value or tonumber(input) and tonumber(input)
    value = value or input

    -- validate input and set config
    if not ShaguTweaks.overwrites[index] then
      local text = "|cffff5555Error:|r Overwrite |cffffcc00%s|r does not exists.|r"
      stdout(string.format(text, index), 1, 1, 1, 1)
    elseif type(ShaguTweaks.overwrites[index]) ~= type(value) then
      local text = "|cffff5555Error:|r Overwrite |cffffcc00%s|r requires to be type: |cffffcc00%s|r"
      stdout(string.format(text, index, type(ShaguTweaks.overwrites[index])), 1, 1, 1, 1)
    else
      ShaguTweaks_config.overwrites[index] = value
      local text = "Overwrite |cffffcc00%s|r is now set to: |cffffcc00%s|r"
      stdout(string.format(text, index, input), 1, 1, 1, 1)
    end
  else
    stdout("|cffffcc00Shagu|rTweaks overwrites:", 1, 1, 1, 1)
    stdout("|cffffcc00|r", 1, 1, 1, 1)
    stdout("|cffff5555Warning:|r This is for experienced users only. Do not change values unless you know what you're doing. Use '/st reset' before submitting any bug.", 1, .8, .8, 1)
    stdout("|cffffcc00|r", 1, 1, 1, 1)
    for name, value in ShaguTweaks.spairs(ShaguTweaks.overwrites) do
      stdout("  |cffaaaaaa/st|r " .. name .. " |cffffcc00" .. GetConfigValue(value), 1, 1, 1, 1)
    end
    stdout("  |cffaaaaaa/st|r reset", 1, 1, 1, 1)
  end
end
