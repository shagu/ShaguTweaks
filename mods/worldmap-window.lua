local _G = ShaguTweaks.GetGlobalEnv()
local L = ShaguTweaks.L
local HookScript = ShaguTweaks.HookScript

ShaguTweaks_locale["ruRU"]["WorldMapWindow"] = {
  ["WorldMap Window"] = "Окно карты мира",
  ["Turns the world map into a movable window. The map can be scaled with <Ctrl> + Mousewheel."] = "Превращает карту мира в подвижное окно. Карту можно масштабировать с помощью <Ctrl> + Колесо мыши.",
}


local module = ShaguTweaks:register({
  title = L["WorldMapWindow"]["WorldMap Window"],
  description = L["WorldMapWindow"]["Turns the world map into a movable window. The map can be scaled with <Ctrl> + Mousewheel."],
  expansions = { ["vanilla"] = true, ["tbc"] = true },
  category = L["categories"]["World & MiniMap"],
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

    -- make sure the hooks get only applied once
    if not this.hooked then
      this.hooked = true

      HookScript(WorldMapFrame, "OnShow", function()
        -- customize
        this:EnableKeyboard(false)
        this:EnableMouseWheel(1)

        -- set back to default scale
        WorldMapFrame:SetScale(.85)
      end)

      HookScript(WorldMapFrame, "OnMouseWheel", function()
        if IsShiftKeyDown() then
          WorldMapFrame:SetAlpha(WorldMapFrame:GetAlpha() + arg1/10)
        elseif IsControlKeyDown() then
          WorldMapFrame:SetScale(WorldMapFrame:GetScale() + arg1/10)
        end
      end)

      HookScript(WorldMapFrame, "OnMouseDown",function()
        WorldMapFrame:StartMoving()
      end)

      HookScript(WorldMapFrame, "OnMouseUp",function()
        WorldMapFrame:StopMovingOrSizing()
      end)
    end

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
