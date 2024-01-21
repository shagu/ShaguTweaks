local _G = ShaguTweaks.GetGlobalEnv()
local T = ShaguTweaks.T
local Abbreviate = ShaguTweaks.Abbreviate
local GetColorGradient = ShaguTweaks.GetColorGradient
local vanilla = ShaguTweaks.GetExpansion() == "vanilla" or nil

local module = ShaguTweaks:register({
  title = T["Unit Frame Health Colors"],
  description = T["Change health text color based on its value."],
  expansions = { ["vanilla"] = true, ["tbc"] = true },
  category = T["Unit Frames"],
  enabled = nil,
})

module.enable = function(self)
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
      local min, max = sb:GetMinMaxValues()
      local cur = sb:GetValue()
      local percent = max > 0 and floor(cur/max*100) or 0

      if strfind(sb:GetName(), "Health") then
        local r, g, b = GetColorGradient(percent/100)
        string:SetTextColor((r + 1) / 2, (g + 1) / 2, (b + 1) / 2, .75)
      end
    end
  end
end
