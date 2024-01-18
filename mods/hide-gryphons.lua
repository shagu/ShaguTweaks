local _G = ShaguTweaks.GetGlobalEnv()
local L = ShaguTweaks.L

ShaguTweaks_locale["ruRU"]["HideGryphons"] = {
  ["Hide Gryphons"] = "Спрятать грифонов",
  ["Hides the gryphons left and right of the action bar."] = "Скрывает грифонов слева и справа от панели действий.",
}

local module = ShaguTweaks:register({
  title = L["HideGryphons"]["Hide Gryphons"],
  description = L["HideGryphons"]["Hides the gryphons left and right of the action bar."],
  expansions = { ["vanilla"] = true, ["tbc"] = true },
  enabled = nil,
})

module.enable = function(self)
  MainMenuBarLeftEndCap:Hide()
  MainMenuBarRightEndCap:Hide()
end
