local _G = ShaguTweaks.GetGlobalEnv()
local L = ShaguTweaks.L

ShaguTweaks_locale["ruRU"]["MiniMapTweaks"] = {
  ["MiniMap Tweaks"] = "Улучшения мини-карты",
  ["Hides unnecessary mini map buttons and allows to zoom using the mouse wheel."] = "Скрывает ненужные кнопки мини-карты и позволяет масштабировать ее с помощью колеса мыши.",
  ["World & MiniMap"] = "Карта мира и мини-карта",
}

local module = ShaguTweaks:register({
  title = L["MiniMapTweaks"]["MiniMap Tweaks"],
  description = L["MiniMapTweaks"]["Hides unnecessary mini map buttons and allows to zoom using the mouse wheel."],
  expansions = { ["vanilla"] = true, ["tbc"] = true },
  category = L["MiniMapTweaks"]["World & MiniMap"],
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
