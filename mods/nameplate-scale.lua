local _G = ShaguTweaks.GetGlobalEnv()
local T = ShaguTweaks.T

local module = ShaguTweaks:register({
  title = T["Nameplate Scale"],
  description = T["Makes all nameplates honor the UI-Scale setting."],
  expansions = { ["vanilla"] = true, ["tbc"] = nil },
  enabled = true,
})

module.enable = function(self)
  if ShaguPlates then return end

  table.insert(ShaguTweaks.libnameplate.OnInit, function(plate)
    local owidth = plate:GetWidth()
    local oheight = plate:GetHeight()

    -- create new plate
    local new = CreateFrame("Frame", nil, plate)
    plate.new = new

    new:SetScale(UIParent:GetScale())
    new:SetAllPoints(plate)
    new.plate = plate

    plate.healthbar:SetParent(new)
    plate.healthbar:SetFrameLevel(1)

    plate:SetWidth(owidth*UIParent:GetScale())
    plate:SetHeight(oheight*UIParent:GetScale())

    for i, object in pairs({plate:GetRegions()}) do
      object:SetParent(new)

      -- adjust level icon position
      if ShaguTweaks:GetExpansion() == "vanilla" and i == 5 or i == 7 then
        object:SetPoint("BOTTOMRIGHT", -6, 3)
      end
    end

    new:SetScript("OnShow", function()
      -- adjust sizes
      this:SetScale(UIParent:GetScale())
      this.plate:SetWidth(owidth*UIParent:GetScale())
      this.plate:SetHeight(oheight*UIParent:GetScale())
    end)
  end)

  table.insert(ShaguTweaks.libnameplate.OnUpdate, function()
    this.new:SetAlpha(this:GetAlpha())
  end)
end
