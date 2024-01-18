local _G = ShaguTweaks.GetGlobalEnv()
local L = ShaguTweaks.L

ShaguTweaks_locale["ruRU"]["HideErrors"] = {
  ["Hide Errors"] = "Скрыть ошибки",
  ["Hides and ignores all Lua errors produced by broken addons."] = "Скрывает и игнорирует все ошибки Lua, вызванные неработающими аддонами.",
}

local module = ShaguTweaks:register({
  title = L["HideErrors"]["Hide Errors"],
  description = L["HideErrors"]["Hides and ignores all Lua errors produced by broken addons."],
  expansions = { ["vanilla"] = true, ["tbc"] = true },
  enabled = nil,
})

module.enable = function(self)
  error = function() return end
  seterrorhandler(error)
end
