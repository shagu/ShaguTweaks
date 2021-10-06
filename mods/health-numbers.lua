local _G = _G or getfenv(0)
local Abbreviate = ShaguTweaks.Abbreviate
local GetColorGradient = ShaguTweaks.GetColorGradient
local vanilla = ShaguTweaks.GetExpansion() == "vanilla" or nil

local module = ShaguTweaks:register({
  title = "Real Health Numbers",
  description = "Estimates health numbers, and shows numbers on player, pet and target unit frames.",
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
    frame.TextString:SetFontObject("GameFontNormal")
    frame.TextString:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
    frame.TextString:SetHeight(32)
  end

  for _, frame in pairs( { PetFrameHealthBar, PetFrameManaBar }) do
    frame.TextString:SetFontObject("GameFontNormal")
    frame.TextString:SetFont(STANDARD_TEXT_FONT, 9, "OUTLINE")
    frame.TextString:SetHeight(32)
    frame.TextString:SetJustifyH("LEFT")
  end

  local HookUnitFrame_UpdateManaType = UnitFrame_UpdateManaType
  function UnitFrame_UpdateManaType(uf)
    HookUnitFrame_UpdateManaType(uf)
    if not uf then uf = this end
    local string = uf.manabar and uf.manabar.TextString
    if not string then return end

    if not strfind(uf.manabar:GetName(), "Health") then
      local r, g, b = uf.manabar:GetStatusBarColor()
      string:SetTextColor((r + 2) / 3, (g + 2) / 3, (b + 2) / 3, 1)
    end
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

      if strfind(sb:GetName(), "Health") then
        local r, g, b = GetColorGradient(percent/100)
        string:SetTextColor((r + 1) / 2, (g + 1) / 2, (b + 1) / 2, .75)
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
