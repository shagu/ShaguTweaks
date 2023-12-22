local _G = ShaguTweaks.GetGlobalEnv()
local hooksecurefunc = hooksecurefunc or ShaguTweaks.hooksecurefunc
local GetExpansion = ShaguTweaks.GetExpansion

local module = ShaguTweaks:register({
  title = "Sticky Markers",
  description = "Enforce keeping raid markers instead of clearing them when applying existing mark to a unit.",
  expansions = { ["vanilla"] = true, ["tbc"] = nil },
  category = "Unit Frames",
  enabled = true,
})

module.enable = function(self)
  hooksecurefunc("SetRaidTargetIcon", function(unit, index)
    SetRaidTarget(unit, index);
  end)
end
