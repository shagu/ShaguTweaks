local _G = _G or getfenv(0)
local GetExpansion = ShaguTweaks.GetExpansion

local module = ShaguTweaks:register({
  title = "Use Squared Minimap",
  description = "Draw the minimap in a squared shape",
  enabled = nil,
})

Minimap:SetMaskTexture("Textures\\MinimapMask")

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
