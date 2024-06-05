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

  function TextStatusBar_SetupFrames(parentFrame, childHealthFrame, childManaFrame, unit)
    parentFrame.StatusTexts = CreateFrame("Frame", nil, parentFrame)
    parentFrame.StatusTexts:SetAllPoints(parentFrame)

    local playerOffset = 0
    local targetOffset = 0

    if unit == "Player" then
      playerOffset = 4
    end

    if unit == "Target" then
      targetOffset = -4
    end

    childHealthFrame.TextStringPercent = parentFrame.StatusTexts:CreateFontString(unit .. "FrameHealthBarText", "OVERLAY")
    childHealthFrame.TextStringPercent:SetPoint("TOP", childHealthFrame, "BOTTOM", -40+targetOffset, 23)
    childHealthFrame.TextStringNumber = parentFrame.StatusTexts:CreateFontString(unit .. "FrameHealthBarText", "OVERLAY")
    childHealthFrame.TextStringNumber:SetPoint("TOP", childHealthFrame, "BOTTOM", 40+playerOffset, 23)
    childHealthFrame.TextString = nil

    childManaFrame.TextStringPercent = parentFrame.StatusTexts:CreateFontString(unit .. "FrameManaBarText", "OVERLAY")
    childManaFrame.TextStringPercent:SetPoint("TOP", childManaFrame, "BOTTOM", -40+targetOffset, 22)
    childManaFrame.TextStringNumber = parentFrame.StatusTexts:CreateFontString(unit .. "FrameManaBarText", "OVERLAY")
    childManaFrame.TextStringNumber:SetPoint("TOP", childManaFrame, "BOTTOM", 40+playerOffset, 22)
    childManaFrame.TextString = nil
  end

  TextStatusBar_SetupFrames(TargetFrame, TargetFrameHealthBar, TargetFrameManaBar, "Target")
  TextStatusBar_SetupFrames(PlayerFrame, PlayerFrameHealthBar, PlayerFrameManaBar, "Player")

  --PetFrameHealthBar.TextString:SetPoint("CENTER", PetFrameHealthBar, "CENTER", -2, 0)
  --PetFrameManaBar.TextString:SetPoint("CENTER", PetFrameManaBar, "CENTER", -2, -2)

  for _, frame in pairs( { TargetFrameHealthBar, TargetFrameManaBar, PlayerFrameHealthBar, PlayerFrameManaBar }) do
    frame.TextStringPercent:SetFontObject("GameFontWhite")
    frame.TextStringPercent:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
    frame.TextStringPercent:SetHeight(32)
    frame.TextStringPercent:SetWidth(30)
    frame.TextStringPercent:SetJustifyH("RIGHT")

    frame.TextStringNumber:SetFontObject("GameFontWhite")
    frame.TextStringNumber:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
    frame.TextStringNumber:SetHeight(32)
    frame.TextStringNumber:SetWidth(30)
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
        stringNumber:Hide()
        stringNumber:SetText("")
        stringPercent:Hide()
        stringPercent:SetText("")
      else
        stringNumber:Show()
        stringPercent:Show()
      end
    end
  end
end
