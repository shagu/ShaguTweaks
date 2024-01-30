local _G = ShaguTweaks.GetGlobalEnv()
local T = ShaguTweaks.T

local module = ShaguTweaks:register({
  title = T["Unit Frame Big Health"],
  description = T["Increases the healthbar of the player and target unitframe."],
  expansions = { ["vanilla"] = true, ["tbc"] = true },
  category = T["Unit Frames"],
  enabled = nil,
})


local addonpath
local tocs = { "", "-master", "-tbc", "-wotlk" }
for _, name in pairs(tocs) do
  local current = string.format("ShaguTweaks%s", name)
  local _, title = GetAddOnInfo(current)
  if title then
    addonpath = "Interface\\AddOns\\" .. current
    break
  end
end

module.enable = function(self)
  PlayerFrameTexture:SetTexture(addonpath .. "\\img\\UI-TargetingFrame")
  PlayerFrameHealthBar:SetPoint("TOPLEFT", 106, -22)
  PlayerFrameHealthBar:SetHeight(30)

  PlayerStatusTexture:SetTexture(addonpath .. "\\img\\UI-Player-Status")

  TargetFrameTexture:SetTexture(addonpath .. "\\img\\UI-TargetingFrame")
  TargetFrameHealthBar:SetPoint("TOPRIGHT", -106, -22)
  TargetFrameHealthBar:SetHeight(30)


  local original = TargetFrame_CheckClassification
  function TargetFrame_CheckClassification()
    local classification = UnitClassification("target")
    if ( classification == "worldboss" ) then
      TargetFrameTexture:SetTexture(addonpath .. "\\img\\UI-TargetingFrame-Elite")
    elseif ( classification == "rareelite"  ) then
      TargetFrameTexture:SetTexture(addonpath .. "\\img\\UI-TargetingFrame-Elite")
    elseif ( classification == "elite"  ) then
      TargetFrameTexture:SetTexture(addonpath .. "\\img\\UI-TargetingFrame-Elite")
    elseif ( classification == "rare"  ) then
      TargetFrameTexture:SetTexture(addonpath .. "\\img\\UI-TargetingFrame-Rare")
    else
      TargetFrameTexture:SetTexture(addonpath .. "\\img\\UI-TargetingFrame")
    end
  end


  local wait = CreateFrame("Frame")
  wait:RegisterEvent("PLAYER_ENTERING_WORLD")
  wait:SetScript("OnEvent", function()
    if ShaguTweaks.DarkMode then
      PlayerFrameTexture:SetVertexColor(.3,.3,.3,.9)
      TargetFrameTexture:SetVertexColor(.3,.3,.3,.9)
    end

    -- adjust healthbar colors to frame colors
    local original = TargetFrame_CheckFaction
    function TargetFrame_CheckFaction(self)
      original(self)

      if TargetFrameHealthBar._SetStatusBarColor then
        local r, g, b, a = TargetFrameNameBackground:GetVertexColor()
        TargetFrameHealthBar:_SetStatusBarColor(r, g, b, a)
      end
    end
  end)

  -- delay to first draw
  wait:SetScript("OnUpdate", function()
    -- move text strings a bit higher
    if PlayerFrameHealthBar.TextString then
      PlayerFrameHealthBar.TextString:SetPoint("TOP", PlayerFrameHealthBar, "BOTTOM", 0, 23)
    end

    if TargetFrameHealthBar.TextString then
      TargetFrameHealthBar.TextString:SetPoint("TOP", TargetFrameHealthBar, "BOTTOM", -2, 23)
    end

    -- use class color for player (if enabled)
    if PlayerFrameNameBackground then
      -- disable vanilla ui color restore functions
      PlayerFrameHealthBar._SetStatusBarColor = PlayerFrameHealthBar.SetStatusBarColor
      PlayerFrameHealthBar.SetStatusBarColor = function() return end

      -- set player healthbar to class color
      local r, g, b, a = PlayerFrameNameBackground:GetVertexColor()
      PlayerFrameHealthBar:_SetStatusBarColor(r, g, b, a)

      -- hide status textures
      PlayerFrameNameBackground:Hide()
      PlayerFrameNameBackground.Show = function() return end
    end

    -- use frame color for target frame
    if TargetFrameNameBackground then
      -- disable vanilla ui color restore functions
      TargetFrameHealthBar._SetStatusBarColor = TargetFrameHealthBar.SetStatusBarColor
      TargetFrameHealthBar.SetStatusBarColor = function() return end

      -- hide status textures
      TargetFrameNameBackground.Show = function() return end
      TargetFrameNameBackground:Hide()
    end

    TargetFrame_CheckFaction(PlayerFrame)
    wait:UnregisterAllEvents()
    wait:Hide()
  end)
end
