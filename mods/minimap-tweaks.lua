local _G = ShaguTweaks.GetGlobalEnv()
local T = ShaguTweaks.T

local module = ShaguTweaks:register({
  title = T["MiniMap Tweaks"],
  description = T["Hides unnecessary mini map buttons and allows to zoom using the mouse wheel."],
  expansions = { ["vanilla"] = true, ["tbc"] = true },
  category = T["World & MiniMap"],
  enabled = nil,
})

module.enable = function(self)
  -- hide daytime circle
  GameTimeFrame:Hide()
  GameTimeFrame:SetScript("OnShow", function() this:Hide() end)

  -- hide minimap zone background
  MinimapBorderTop:Hide()
  MinimapToggleButton:Hide()
  MinimapZoneTextButton:SetPoint("CENTER", 7, 85)

  -- hide zoom buttons and enable mousewheel
  MinimapZoomIn:Hide()
  MinimapZoomOut:Hide()
  Minimap:EnableMouseWheel(true)
  Minimap:SetScript("OnMouseWheel", function()
    if(arg1 > 0) then Minimap_ZoomIn() else Minimap_ZoomOut() end
  end)
end
