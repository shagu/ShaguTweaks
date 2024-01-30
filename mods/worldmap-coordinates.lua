local _G = ShaguTweaks.GetGlobalEnv()
local T = ShaguTweaks.T

local module = ShaguTweaks:register({
  title = T["WorldMap Coordinates"],
  description = T["Adds coordinates to the bottom of the World Map."],
  expansions = { ["vanilla"] = true, ["tbc"] = true },
  category = T["World & MiniMap"],
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
      WorldMapButton.coords.text:SetFontObject(GameFontWhite)
      WorldMapButton.coords.text:SetTextColor(1, 1, 1)
      WorldMapButton.coords.text:SetJustifyH("RIGHT")

      -- move coordinates in case of other addons already taking the space
      if Gatherer_WorldMapDisplay then
        WorldMapButton.coords.text:SetPoint("LEFT", Gatherer_WorldMapDisplay, "RIGHT", 3, -21)
      end

      WorldMapButton.player = CreateFrame("Frame", "pfWorldMapButtonCoords", WorldMapButton)
      WorldMapButton.player.text = WorldMapButton.player:CreateFontString(nil, "OVERLAY")
      WorldMapButton.player.text:SetPoint("BOTTOMRIGHT", WorldMapButton, "BOTTOMRIGHT", -3, -21)
      WorldMapButton.player.text:SetFontObject(GameFontWhite)
      WorldMapButton.player.text:SetTextColor(1, 1, 1)
      WorldMapButton.player.text:SetJustifyH("RIGHT")

      WorldMapButton.coords:SetScript("OnUpdate", function()
        local width  = WorldMapButton:GetWidth()
        local height = WorldMapButton:GetHeight()
        local mx, my = WorldMapButton:GetCenter()
        local scale  = WorldMapButton:GetEffectiveScale()
        local x, y   = GetCursorPosition()

        mx = (( x / scale ) - ( mx - width / 2)) / width * 100
        my = (( my + height / 2 ) - ( y / scale )) / height * 100

        local px, py = GetPlayerMapPosition("player")
        if px > 0 and py > 0 then
          WorldMapButton.player.text:SetText(string.format("|cffffcc00" .. T["Player"] .. ": |r%.1f / %.1f", px*100, py*100))
        else
          WorldMapButton.player.text:SetText(string.format("|cffffcc00" .. T["Player"] .. ": |r" .. T["N/A"]))
        end

        if MouseIsOver(WorldMapButton) then
          WorldMapButton.coords.text:SetText(string.format("|cffffcc00" .. T["Cursor"] .. ": |r%.1f / %.1f", mx, my))
        else
          WorldMapButton.coords.text:SetText(string.format("|cffffcc00" .. T["Cursor"] .. ": |r" .. T["N/A"]))
        end
      end)
    end
  end)
end
