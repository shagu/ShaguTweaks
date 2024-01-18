local _G = ShaguTweaks.GetGlobalEnv()
local L = ShaguTweaks.L

ShaguTweaks_locale["ruRU"]["MiniMapSquare"] = {
  ["MiniMap Square"] = "Квадратная мини-карта",
  ["Draw the mini map in a squared shape instead of a round one."] = "Мини-карта квадратной формы вместо круглой.",
}

local module = ShaguTweaks:register({
  title = L["MiniMapSquare"]["MiniMap Square"],
  description = L["MiniMapSquare"]["Draw the mini map in a squared shape instead of a round one."],
  expansions = { ["vanilla"] = true, ["tbc"] = true },
  category = L["categories"]["World & MiniMap"],
  enabled = nil,
})

module.enable = function(self)
  MinimapBorder:SetTexture(nil)
  Minimap:SetPoint("CENTER", MinimapCluster, "TOP", 9, -98)
  Minimap:SetMaskTexture("Interface\\BUTTONS\\WHITE8X8")

  Minimap.border = CreateFrame("Frame", nil, Minimap)
  Minimap.border:SetFrameStrata("BACKGROUND")
  Minimap.border:SetFrameLevel(1)
  Minimap.border:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -3, 3)
  Minimap.border:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 3, -3)
  Minimap.border:SetBackdrop({
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 8, edgeSize = 16,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }})

  Minimap.border:SetBackdropBorderColor(.9,.8,.5,1)
  Minimap.border:SetBackdropColor(.4,.4,.4,1)
end
