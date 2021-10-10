local _G = _G or getfenv(0)

SLASH_RELOAD1 = '/rl'
function SlashCmdList.RELOAD(msg, editbox) ReloadUI() end

message = function(msg)
  DEFAULT_CHAT_FRAME:AddMessage("|cffffff00" .. ( msg or "nil" ))
end
print = message

error = function(msg)
  DEFAULT_CHAT_FRAME:AddMessage("|cffff0000".. (msg or "nil" ))
end
seterrorhandler(error)

ShaguTweaks = CreateFrame("Frame")
ShaguTweaks.mods = {}

-- load translation tables
ShaguTweaks.L = (ShaguTweaks_locale[GetLocale()] or ShaguTweaks_locale["enUS"])
ShaguTweaks:RegisterEvent("VARIABLES_LOADED")
ShaguTweaks:SetScript("OnEvent", function()
  -- load current expansion
  local expansion = ShaguTweaks:GetExpansion()

  -- initialize empty config
  if not ShaguTweaks_config then ShaguTweaks_config = {} end

  -- read all registered mods
  for title, mod in pairs(ShaguTweaks.mods) do
    -- write initial default config
    if not ShaguTweaks_config[title] then
      ShaguTweaks_config[title] = mod.enabled and 1 or 0
    end

    -- load enabled mods
    if mod.expansions[expansion] and ShaguTweaks_config[title] == 1 then
      mod:enable()
    end
  end
end)

ShaguTweaks.register = function(self, mod)
  ShaguTweaks.mods[mod.title] = mod
  return ShaguTweaks.mods[mod.title]
end
