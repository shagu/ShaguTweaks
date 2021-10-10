local _G = _G or getfenv(0)

local module = ShaguTweaks:register({
  title = "WorldMap Window",
  description = "Turns the world map into a movable window. The map can be scaled with <Ctrl> + Mousewheel.",
  expansions = { ["vanilla"] = true, ["tbc"] = true },
  category = "World & MiniMap",
  enabled = true,
})

module.enable = function(self)
  table.insert(UISpecialFrames, "WorldMapFrame")

  function _G.ToggleWorldMap()
    if WorldMapFrame:IsShown() then
      WorldMapFrame:Hide()
    else
      WorldMapFrame:Show()
    end
  end

  local delay = CreateFrame("Frame")
  delay:RegisterEvent("PLAYER_ENTERING_WORLD")
  delay:SetScript("OnEvent", function()
    -- do not load if other map addon is loaded
    if Cartographer then return end
    if METAMAP_TITLE then return end

    UIPanelWindows["WorldMapFrame"] = { area = "center" }

    WorldMapFrame:SetScript("OnShow", function()
      -- default events
      UpdateMicroButtons()
      PlaySound("igQuestLogOpen")
      CloseDropDownMenus()
      SetMapToCurrentZone()
      WorldMapFrame_PingPlayerPosition()

      -- customize
      this:EnableKeyboard(false)
      this:EnableMouseWheel(1)
    end)

    WorldMapFrame:SetScript("OnMouseWheel", function()
      if IsShiftKeyDown() then
        WorldMapFrame:SetAlpha(WorldMapFrame:GetAlpha() + arg1/10)
      elseif IsControlKeyDown() then
        WorldMapFrame:SetScale(WorldMapFrame:GetScale() + arg1/10)
      end
    end)

    WorldMapFrame:SetScript("OnMouseDown",function()
      WorldMapFrame:StartMoving()
    end)

    WorldMapFrame:SetScript("OnMouseUp",function()
      WorldMapFrame:StopMovingOrSizing()
    end)

    WorldMapFrame:SetMovable(true)
    WorldMapFrame:EnableMouse(true)

    WorldMapFrame:SetScale(.85)
    WorldMapFrame:ClearAllPoints()
    WorldMapFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 30)
    WorldMapFrame:SetWidth(WorldMapButton:GetWidth() + 15)
    WorldMapFrame:SetHeight(WorldMapButton:GetHeight() + 55)
    BlackoutWorld:Hide()
  end)
end
