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
  TargetFrameHealthBar.TextStringPercent:SetPoint("TOP", TargetFrameHealthBar, "BOTTOM", -20, 23)
  TargetFrameHealthBar.TextStringPercent:SetJustifyH("LEFT")

  TargetFrameHealthBar.TextStringNumber = TargetFrame.StatusTexts:CreateFontString("TargetFrameHealthBarText", "OVERLAY")
  TargetFrameHealthBar.TextStringNumber:SetPoint("TOP", TargetFrameHealthBar, "BOTTOM", 20, 23)
  TargetFrameHealthBar.TextStringNumber:SetJustifyH("RIGHT")

  --TargetFrameManaBar.TextString = TargetFrame.StatusTexts:CreateFontString("TargetFrameManaBarText", "OVERLAY")
  --TargetFrameManaBar.TextString:SetPoint("TOP", TargetFrameManaBar, "BOTTOM", -2, 22)

  --PetFrameHealthBar.TextString:SetPoint("CENTER", PetFrameHealthBar, "CENTER", -2, 0)
  --PetFrameManaBar.TextString:SetPoint("CENTER", PetFrameManaBar, "CENTER", -2, -2)

  for _, frame in pairs( { TargetFrameHealthBar--[[, TargetFrameManaBar, PlayerFrameHealthBar, PlayerFrameManaBar]] }) do
    frame.TextStringPercent:SetFontObject("GameFontWhite")
    frame.TextStringPercent:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
    frame.TextStringPercent:SetHeight(32)

    frame.TextStringNumber:SetFontObject("GameFontWhite")
    frame.TextStringNumber:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
    frame.TextStringNumber:SetHeight(32)
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
    local percent = sb.TextStringPercent
    local number = sb.TextStringNumber

    if percent and number and sb.unit then
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

      percent:SetText(percent .. "%")
      number:SetText(Abbreviate(cur))

      local hide = max == 0 or (sb.unit == "target" and UnitIsDead("target")) or sb.unit == "target" and UnitIsGhost("target")

      if hide then
        percent:Hide()
        percent:SetText("")
        number:Hide()
        number:SetText("")
      else
        percent:Show()
        number:Show()
      end
    end
  end
end
