local _G = ShaguTweaks.GetGlobalEnv()
local T = ShaguTweaks.T

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

local CLASS_ICON_TCOORDS = {
  ["WARRIOR"] = { 0, 0.25, 0, 0.25 },
  ["MAGE"] = { 0.25, 0.49609375, 0, 0.25 },
  ["ROGUE"] = { 0.49609375, 0.7421875, 0, 0.25 },
  ["DRUID"] = { 0.7421875, 0.98828125, 0, 0.25 },
  ["HUNTER"] = { 0, 0.25, 0.25, 0.5 },
  ["SHAMAN"] = { 0.25, 0.49609375, 0.25, 0.5 },
  ["PRIEST"] = { 0.49609375, 0.7421875, 0.25, 0.5 },
  ["WARLOCK"] = { 0.7421875, 0.98828125, 0.25, 0.5 },
  ["PALADIN"] = { 0, 0.25, 0.5, 0.75 },
  ["DEATHKNIGHT"] = { 0.25, .5, 0.5, .75 },
}

local module = ShaguTweaks:register({
  title = T["Unit Frame Class Portraits"],
  description = T["Replace unitframe portraits with class icons."],
  expansions = { ["vanilla"] = true, ["tbc"] = true },
  category = T["Unit Frames"],
  enabled = nil,
})

local function UpdatePortraits(frame)
  -- detect unit class or remove for non-player units
  local _, class = UnitClass(frame.unit)
  class = UnitIsPlayer(frame.unit) and class or nil

  -- update class icon if possible
  if class and frame.portrait then
    local iconCoords = CLASS_ICON_TCOORDS[class]
    frame.portrait:SetTexture(addonpath .. "\\img\\UI-Classes-Circles")
    frame.portrait:SetTexCoord(unpack(iconCoords))
  elseif not class and frame.portrait then
    frame.portrait:SetTexCoord(0, 1, 0, 1)
  end
end

module.enable = function(self)
  -- overwrite portraits set by the game
  local original = UnitFrame_Update
  UnitFrame_Update = function(arg1, arg2, arg3)
    original(arg1, arg2, arg3)
    UpdatePortraits(this)
  end

  -- handle portrait update events
  local events = CreateFrame("Frame")
  events:RegisterEvent("PLAYER_ENTERING_WORLD")
  events:RegisterEvent("UNIT_PORTRAIT_UPDATE")
  events:SetScript("OnEvent", function()
    -- reload player portrait
    UpdatePortraits(PlayerFrame)
    UpdatePortraits(TargetFrame)

    -- reload party portraits
    UpdatePortraits(PartyMemberFrame1)
    UpdatePortraits(PartyMemberFrame2)
    UpdatePortraits(PartyMemberFrame3)
    UpdatePortraits(PartyMemberFrame4)
  end)

  -- update target of target
  local tot = CreateFrame("Frame", nil, TargetFrame)
  tot:SetScript("OnUpdate", function()
    UpdatePortraits(TargetofTargetFrame)
  end)
end
