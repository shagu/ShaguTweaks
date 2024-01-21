local _G = ShaguTweaks.GetGlobalEnv()
local T = ShaguTweaks.T
local round = ShaguTweaks.round
local rgbhex = ShaguTweaks.rgbhex
local Abbreviate = ShaguTweaks.Abbreviate

local module = ShaguTweaks:register({
  title = T["Tooltip Details"],
  description = T["Display health, class color, guild name, guild rank and current target on unit tooltips."],
  expansions = { ["vanilla"] = true, ["tbc"] = true },
  category = T["Tooltip & Items"],
  enabled = nil,
})

local backdrop = {
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true, tileSize = 8, edgeSize = 12,
  insets = { left = 3, right = 3, top = 3, bottom = 3 }
}

local units = { "mouseover", "player", "pet", "target", "party", "partypet", "raid", "raidpet" }
local current_unit = "none"
local function GetUnit()
  current_unit = "none"

  for i, unit in pairs(units) do
    if unit == "party" or unit == "partypet" then
      for i=1,4 do
        if UnitExists(unit .. i) and ( UnitName(unit .. i) == GameTooltipTextLeft1:GetText() or UnitPVPName(unit .. i) == GameTooltipTextLeft1:GetText() ) then
          current_unit = unit .. i
          return current_unit
        end
      end
    elseif unit == "raid" or unit == "raidpet" then
      for i=1,40 do
        if UnitExists(unit .. i) and ( UnitName(unit .. i) == GameTooltipTextLeft1:GetText() or UnitPVPName(unit .. i) == GameTooltipTextLeft1:GetText() ) then
          current_unit = unit .. i
          return current_unit
        end
      end
    else
      if UnitExists(unit) and ( UnitName(unit) == GameTooltipTextLeft1:GetText() or UnitPVPName(unit) == GameTooltipTextLeft1:GetText() ) then
        current_unit = unit
        return current_unit
      end
    end
  end

  return current_unit
end

local function UpdateTooltip()
  local unit = GetUnit()
  if unit == "none" then return end

  local pvpname = UnitPVPName(unit)
  local name = UnitName(unit)
  local target = UnitName(unit .. "target")
  local _, targetClass = UnitClass(unit .. "target")
  local targetReaction = UnitReaction("player",unit .. "target")
  local _, class = UnitClass(unit)
  local guild, rankstr, rankid = GetGuildInfo(unit)
  local reaction = UnitReaction(unit, "player")
  local pvptitle = gsub(pvpname or name, " "..name, "", 1)

  if name then
    if UnitIsPlayer(unit) and class then
      local color = RAID_CLASS_COLORS[class]
      GameTooltipStatusBar:SetStatusBarColor_orig(color.r, color.g, color.b)
      if color and color.r then
        GameTooltipTextLeft1:SetText(rgbhex(color.r, color.g, color.b, color.a) .. name)
      else
        GameTooltipTextLeft1:SetText("|cff999999" .. name)
      end
    elseif reaction then
      local color = UnitReactionColor[reaction]
      GameTooltipStatusBar:SetStatusBarColor_orig(color.r, color.g, color.b)
    end
    if pvptitle ~= name then
      GameTooltip:AppendText(" |cff666666["..pvptitle.."]|r")
    end
  end

  if guild then
    local rank, lead = "", ""
    if rankstr then rank = " |cffaaaaaa(" .. rankstr .. ")"  end
    if rankid and rankid == 0 then lead = "|cffffcc00*|r" end
    GameTooltip:AddLine("<" .. guild .. ">" .. lead .. rank, 0.3, 1, 0.5)
  end

  if target then
    if UnitIsPlayer(unit .. "target") and targetClass then
      local color = RAID_CLASS_COLORS[targetClass]
      GameTooltip:AddLine(target, color.r, color.g, color.b)
    elseif targetReaction then
      local color = UnitReactionColor[targetReaction]
      if color then
        GameTooltip:AddLine(target, color.r, color.g, color.b)
      else
        GameTooltip:AddLine(target, .5, .5, .5)
      end
    end
  end

  GameTooltip:Show()
end

module.enable = function(self)
  GameTooltipStatusBar:SetHeight(10)
  GameTooltipStatusBar:ClearAllPoints()
  GameTooltipStatusBar:SetPoint("BOTTOMLEFT", GameTooltip, "TOPLEFT", 4, 2)
  GameTooltipStatusBar:SetPoint("BOTTOMRIGHT", GameTooltip, "TOPRIGHT", -4, 2)

  GameTooltipStatusBar.bg = GameTooltipStatusBar:CreateTexture(nil, "BACKGROUND")
  GameTooltipStatusBar.bg:SetTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
  GameTooltipStatusBar.bg:SetVertexColor(.1, .1, 0, .8)
  GameTooltipStatusBar.bg:SetAllPoints(true)

  GameTooltipStatusBar.backdrop = CreateFrame("Frame", "GameTooltipStatusBarBackdrop", GameTooltipStatusBar)
  GameTooltipStatusBar.backdrop:SetPoint("TOPLEFT", GameTooltipStatusBar, "TOPLEFT", -3, 3)
  GameTooltipStatusBar.backdrop:SetPoint("BOTTOMRIGHT", GameTooltipStatusBar, "BOTTOMRIGHT", 3, -3)
  GameTooltipStatusBar.backdrop:SetBackdrop(backdrop)
  GameTooltipStatusBar.backdrop:SetBackdropBorderColor(.8,.8,.8,1)

  GameTooltipStatusBar.backdrop.health = GameTooltipStatusBar.backdrop:CreateFontString("Status", "DIALOG", "GameFontWhite")
  GameTooltipStatusBar.backdrop.health:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
  GameTooltipStatusBar.backdrop.health:SetPoint("TOP", 0, 4)
  GameTooltipStatusBar.backdrop.health:SetNonSpaceWrap(false)

  GameTooltipStatusBar.SetStatusBarColor_orig = GameTooltipStatusBar.SetStatusBarColor
  GameTooltipStatusBar.SetStatusBarColor = function() return end

  -- update tooltip whenever it gets shown
  local details = CreateFrame("Frame", nil, GameTooltip)
  details:SetScript("OnShow", UpdateTooltip)

  -- refresh current name and level
  local statusbar = CreateFrame('Frame', nil, GameTooltipStatusBar)
  statusbar:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
  statusbar:SetScript("OnEvent", function()
    this.name = UnitName("mouseover")
    this.level = UnitLevel("mouseover")
  end)

  -- update texts
  statusbar:SetScript("OnUpdate", function()
    local hp = GameTooltipStatusBar:GetValue()
    local _, hpmax = GameTooltipStatusBar:GetMinMaxValues()
    local rhp, rhpmax, estimated

    if hpmax > 100 or (round(hpmax/100*hp) ~= hp) then
      rhp, rhpmax = hp, hpmax
    else
      rhp, rhpmax, estimated = ShaguTweaks.libhealth:GetUnitHealthByName(this.name, this.level, tonumber(hp), tonumber(hpmax))
    end

    if ( estimated or hpmax > 100 or round(hpmax/100*hp) ~= hp ) then
      GameTooltipStatusBar.backdrop.health:SetText(string.format("%s / %s", Abbreviate(rhp, true), Abbreviate(rhpmax, true)))
    elseif hpmax > 0 then
      GameTooltipStatusBar.backdrop.health:SetText(string.format("%s%%", ceil(hp/hpmax*100)))
    else
      GameTooltipStatusBar.backdrop.health:SetText("")
    end
  end)
end
