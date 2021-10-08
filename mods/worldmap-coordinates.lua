local _G = _G or getfenv(0)
local GetExpansion = ShaguTweaks.GetExpansion

local module = ShaguTweaks:register({
  title = "WorldMap Coordinates",
  description = "Adds coordinates to the bottom of the World Map.",
  enabled = nil,
})

module.enable = function(self)
  local delay = CreateFrame("Frame")
  delay:RegisterEvent("PLAYER_ENTERING_WORLD")
  delay:SetScript("OnEvent", function()
    -- do not load if other map addon is loaded
    if Cartographer then return end
    if METAMAP_TITLE then return end

    -- coordinates
    if not WorldMapButton.coords then
      WorldMapButton.coords = CreateFrame("Frame", "pfWorldMapButtonCoords", WorldMapButton)
      WorldMapButton.coords.text = WorldMapButton.coords:CreateFontString(nil, "OVERLAY")
      WorldMapButton.coords.text:SetPoint("BOTTOMLEFT", WorldMapButton, "BOTTOMLEFT", 3, -21)

      -- move coordinates in case of other addons already taking the space
      if Gatherer_WorldMapDisplay then
        WorldMapButton.coords.text:SetPoint("LEFT", Gatherer_WorldMapDisplay, "RIGHT", 3, -21)
      end

      WorldMapButton.coords.text:SetFontObject(GameFontWhite)
      WorldMapButton.coords.text:SetTextColor(1, 1, 1)
      WorldMapButton.coords.text:SetJustifyH("RIGHT")

      WorldMapButton.coords:SetScript("OnUpdate", function()
        local width  = WorldMapButton:GetWidth()
        local height = WorldMapButton:GetHeight()
        local mx, my = WorldMapButton:GetCenter()
        local scale  = WorldMapButton:GetEffectiveScale()
        local x, y   = GetCursorPosition()

        mx = (( x / scale ) - ( mx - width / 2)) / width * 100
        my = (( my + height / 2 ) - ( y / scale )) / height * 100

        if MouseIsOver(WorldMapButton) then
          WorldMapButton.coords.text:SetText(string.format('|cffffcc00Coordinates: |r%.1f / %.1f', mx, my))
        else
          WorldMapButton.coords.text:SetText("")
        end
      end)
    end
  end)
end
