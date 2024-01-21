local _G = ShaguTweaks.GetGlobalEnv()
local T = ShaguTweaks.T
local Abbreviate = ShaguTweaks.Abbreviate
local GetColorGradient = ShaguTweaks.GetColorGradient
local vanilla = ShaguTweaks.GetExpansion() == "vanilla" or nil

local module = ShaguTweaks:register({
  title = T["Real Health Numbers"],
  description = T["Estimates health numbers, and shows numbers on player, pet and target unit frames."],
  expansions = { ["vanilla"] = true, ["tbc"] = true },
  category = T["Unit Frames"],
  enabled = true,
})

module.enable = function(self)
  TargetFrame.StatusTexts = CreateFrame("Frame", nil, TargetFrame)
  TargetFrame.StatusTexts:SetAllPoints(TargetFrame)

  TargetFrameHealthBar.TextString = TargetFrame.StatusTexts:CreateFontString("TargetFrameHealthBarText", "OVERLAY")
  TargetFrameHealthBar.TextString:SetPoint("TOP", TargetFrameHealthBar, "BOTTOM", -2, 23)

  TargetFrameManaBar.TextString = TargetFrame.StatusTexts:CreateFontString("TargetFrameManaBarText", "OVERLAY")
  TargetFrameManaBar.TextString:SetPoint("TOP", TargetFrameManaBar, "BOTTOM", -2, 22)

  PetFrameHealthBar.TextString:SetPoint("CENTER", PetFrameHealthBar, "CENTER", -2, 0)
  PetFrameManaBar.TextString:SetPoint("CENTER", PetFrameManaBar, "CENTER", -2, -2)

  for _, frame in pairs( { TargetFrameHealthBar, TargetFrameManaBar, PlayerFrameHealthBar, PlayerFrameManaBar }) do
    frame.TextString:SetFontObject("GameFontWhite")
    frame.TextString:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
    frame.TextString:SetHeight(32)
  end

  for _, frame in pairs( { PetFrameHealthBar, PetFrameManaBar }) do
    frame.TextString:SetFontObject("GameFontWhite")
    frame.TextString:SetFont(STANDARD_TEXT_FONT, 9, "OUTLINE")
    frame.TextString:SetHeight(32)
    frame.TextString:SetJustifyH("LEFT")
  end

  local HookTextStatusBar_UpdateTextString = TextStatusBar_UpdateTextString
  function TextStatusBar_UpdateTextString(sb)
    if not sb then sb = this end

    HookTextStatusBar_UpdateTextString(sb)
    local string = sb.TextString

    if string and sb.unit then
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

      if cur == percent and strfind(sb:GetName(), "Health") then
        string:SetText(percent .. "%")
      elseif sb:GetName() == "TargetFrameHealthBar" and cur < max then
        string:SetText(Abbreviate(cur) .. " - " .. percent .. "%")
      else
        string:SetText(Abbreviate(cur))
      end

      if max == 0 then
        string:Hide()
        string:SetText("")
      elseif sb.unit == "target" and UnitIsDead("target") then
        string:Hide()
        string:SetText("")
      elseif sb.unit == "target" and UnitIsGhost("target") then
        string:Hide()
        string:SetText("")
      else
        string:Show()
      end
    end
  end
end
