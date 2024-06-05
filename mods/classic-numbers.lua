local _G = ShaguTweaks.GetGlobalEnv()
local T = ShaguTweaks.T
local Abbreviate = ShaguTweaks.Abbreviate
local GetColorGradient = ShaguTweaks.GetColorGradient
local vanilla = ShaguTweaks.GetExpansion() == "vanilla" or nil

local module = ShaguTweaks:register({
  title = T["Classic Health Numbers"],
  description = T["Shows both numbers and percentage for health and mana"],
  expansions = { ["vanilla"] = true, ["tbc"] = true },
  category = T["Unit Frames"],
  enabled = true,
})

module.enable = function(self)
  TargetFrame.StatusTexts = CreateFrame("Frame", nil, TargetFrame)
  TargetFrame.StatusTexts:SetAllPoints(TargetFrame)

  TargetFrameHealthBar.TextStringPercent = TargetFrame.StatusTexts:CreateFontString("TargetFrameHealthBarText", "OVERLAY")
  TargetFrameHealthBar.TextStringPercent:SetPoint("TOP", TargetFrameHealthBar, "BOTTOM", -45, 23)

  TargetFrameHealthBar.TextStringNumber = TargetFrame.StatusTexts:CreateFontString("TargetFrameHealthBarText", "OVERLAY")
  TargetFrameHealthBar.TextStringNumber:SetPoint("TOP", TargetFrameHealthBar, "BOTTOM", 42, 23)

  TargetFrameManaBar.TextStringPercent = TargetFrame.StatusTexts:CreateFontString("TargetFrameManaBarText", "OVERLAY")
  TargetFrameManaBar.TextStringPercent:SetPoint("TOP", TargetFrameManaBar, "BOTTOM", -45, 22)

  TargetFrameManaBar.TextStringNumber = TargetFrame.StatusTexts:CreateFontString("TargetFrameManaBarText", "OVERLAY")
  TargetFrameManaBar.TextStringNumber:SetPoint("TOP", TargetFrameManaBar, "BOTTOM", 42, 22)

  PlayerFrameHealthBar.TextStringPercent = PlayerFrame.StatusTexts:CreateFontString("PlayerFrameHealthBarText", "OVERLAY")
  PlayerFrameHealthBar.TextStringPercent:SetPoint("TOP", PlayerFrameHealthBar, "BOTTOM", -45, 23)

  PlayerFrameHealthBar.TextStringNumber = PlayerFrame.StatusTexts:CreateFontString("PlayerFrameHealthBarText", "OVERLAY")
  PlayerFrameHealthBar.TextStringNumber:SetPoint("TOP", PlayerFrameHealthBar, "BOTTOM", 42, 23)

  PlayerFrameManaBar.TextStringPercent = PlayerFrame.StatusTexts:CreateFontString("PlayerFrameManaBarText", "OVERLAY")
  PlayerFrameManaBar.TextStringPercent:SetPoint("TOP", PlayerFrameManaBar, "BOTTOM", -45, 22)

  PlayerFrameManaBar.TextStringNumber = PlayerFrame.StatusTexts:CreateFontString("PlayerFrameManaBarText", "OVERLAY")
  PlayerFrameManaBar.TextStringNumber:SetPoint("TOP", PlayerFrameManaBar, "BOTTOM", 42, 22)

  --PetFrameHealthBar.TextString:SetPoint("CENTER", PetFrameHealthBar, "CENTER", -2, 0)
  --PetFrameManaBar.TextString:SetPoint("CENTER", PetFrameManaBar, "CENTER", -2, -2)

  for _, frame in pairs( { TargetFrameHealthBar, TargetFrameManaBar, PlayerFrameHealthBar, PlayerFrameManaBar }) do
    frame.TextStringPercent:SetFontObject("GameFontWhite")
    frame.TextStringPercent:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
    frame.TextStringPercent:SetHeight(32)
    frame.TextStringPercent:SetJustifyH("RIGHT")

    frame.TextStringNumber:SetFontObject("GameFontWhite")
    frame.TextStringNumber:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
    frame.TextStringNumber:SetHeight(32)
    frame.TextStringNumber:SetJustifyH("RIGHT")
  end

  --for _, frame in pairs( { PetFrameHealthBar, PetFrameManaBar }) do
  --  frame.TextString:SetFontObject("GameFontWhite")
  --  frame.TextString:SetFont(STANDARD_TEXT_FONT, 9, "OUTLINE")
  --  frame.TextString:SetHeight(32)
  --  frame.TextString:SetJustifyH("LEFT")
  --end

  local HookTextStatusBar_UpdateTextString = TextStatusBar_UpdateTextString
  function TextStatusBar_UpdateTextString(sb)
    if not sb then sb = this end

    HookTextStatusBar_UpdateTextString(sb)
    local stringPercent = sb.TextStringPercent
    local stringNumber = sb.TextStringNumber

    if stringPercent and stringNumber and sb.unit then
      -- hide tbc text string element
      if not vanilla then
        TargetFrameHealthBarText:Hide()
      end

      sb.lockShow = 42
      sb:Show()

      local min, max = sb:GetMinMaxValues()
      local cur = sb:GetValue()
      local percent = max > 0 and floor(cur/max*100) or 0

      if sb:GetName() == "TargetFrameHealthBar" then
        cur, max = ShaguTweaks.libhealth:GetUnitHealth(sb.unit)
      end

      stringPercent:SetText(percent .. "%")
      stringNumber:SetText(Abbreviate(cur))

      local hide = max == 0 or (sb.unit == "target" and UnitIsDead("target")) or sb.unit == "target" and UnitIsGhost("target")

      if hide then
        stringPercent:Hide()
        stringPercent:SetText("")
        stringNumber:Hide()
        stringNumber:SetText("")
      else
        stringPercent:Show()
        stringNumber:Show()
      end
    end
  end
end
