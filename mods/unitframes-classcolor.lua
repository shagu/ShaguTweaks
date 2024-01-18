local _G = ShaguTweaks.GetGlobalEnv()
local L = ShaguTweaks.L

ShaguTweaks_locale["ruRU"]["UnitFrameClassColors"] = {
  ["Unit Frame Class Colors"] = "Цветные классы окон юнитов",
  ["Adds class colors to the player, target and party unit frames."] = "Добавить цвета классов к окнам игрока, цели и отряда группы.",
  ["Unit Frames"] = "Окна юнита",
}

local module = ShaguTweaks:register({
  title = L["UnitFrameClassColors"]["Unit Frame Class Colors"],
  description = L["UnitFrameClassColors"]["Adds class colors to the player, target and party unit frames."],
  expansions = { ["vanilla"] = true, ["tbc"] = true },
  category = L["UnitFrameClassColors"]["Unit Frames"],
  enabled = nil,
})

local partycolors = function()
  for id = 1, MAX_PARTY_MEMBERS do
    local name = _G['PartyMemberFrame'..id..'Name']
    local _, class = UnitClass("party" .. id)
    local class = RAID_CLASS_COLORS[class] or { r = .5, g = .5, b = .5, a = 1 }
    if name then name:SetTextColor(class.r, class.g, class.b, 1) end
  end
end

module.enable = function(self)
  -- enable class color backgrounds
  local original = TargetFrame_CheckFaction
  function TargetFrame_CheckFaction(self)
    original(self)

    local reaction = UnitReaction("target", "player")

	  if UnitIsPlayer("target") then
	    local _, class = UnitClass("target")
	    local class = RAID_CLASS_COLORS[class] or { r = .5, g = .5, b = .5, a = 1 }
	    TargetFrameNameBackground:SetVertexColor(class.r, class.g, class.b, 1)
	    TargetFrameNameBackground:Show()
	  elseif reaction and reaction > 4 then
	    TargetFrameNameBackground:Hide()
    else
	    TargetFrameNameBackground:Show()
    end
  end

  local _, class = UnitClass("player")
  local class = RAID_CLASS_COLORS[class] or { r = .5, g = .5, b = .5, a = 1 }

  -- add name background to player frame
  PlayerFrameNameBackground = PlayerFrame:CreateTexture(nil, "BACKGROUND")
  PlayerFrameNameBackground:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-LevelBackground")
  PlayerFrameNameBackground:SetWidth(119)
  PlayerFrameNameBackground:SetHeight(19)
  PlayerFrameNameBackground:SetPoint("TOPLEFT", 106, -22)
  PlayerFrameNameBackground:SetVertexColor(class.r, class.g, class.b, 1)

  local wait = CreateFrame("Frame")
  wait:RegisterEvent("PLAYER_ENTERING_WORLD")
  wait:SetScript("OnEvent", function()
    local _, class = UnitClass("player")
    local class = RAID_CLASS_COLORS[class] or { r = .5, g = .5, b = .5, a = 1 }
    PlayerFrameNameBackground:SetVertexColor(class.r, class.g, class.b, 1)
    this:UnregisterAllEvents()

    -- make sure to keep name background above frame shadow
    PlayerFrameNameBackground:SetDrawLayer("BORDER")
    TargetFrameNameBackground:SetDrawLayer("BORDER")
  end)

  -- add font outline
  local font, size = PlayerFrame.name:GetFont()
  PlayerFrame.name:SetFont(font, size, "NONE")
  TargetFrame.name:SetFont(font, size, "NONE")

  -- add party frame class colors
  local HookPartyMemberFrame_UpdateMember = PartyMemberFrame_UpdateMember
  PartyMemberFrame_UpdateMember = function(self)
    HookPartyMemberFrame_UpdateMember(self)
    partycolors()
  end

  partycolors()
end
