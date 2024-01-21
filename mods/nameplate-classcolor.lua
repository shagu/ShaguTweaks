local _G = ShaguTweaks.GetGlobalEnv()
local T = ShaguTweaks.T
local GetUnitData = ShaguTweaks.GetUnitData

local module = ShaguTweaks:register({
  title = T["Nameplate Class Colors"],
  description = T["Changes the nameplate health bar color to the class color."],
  expansions = { ["vanilla"] = true, ["tbc"] = true },
  enabled = nil,
})

module.enable = function(self)
  if ShaguPlates then return end

  table.insert(ShaguTweaks.libnameplate.OnUpdate, function()
    local name = this.name:GetText()
    local class, _, elite, player = GetUnitData(name, true)
    if class and player then
      local color = RAID_CLASS_COLORS[class] or { r = .5, g = .5, b = .5, a = 1 }
      this.healthbar:SetStatusBarColor(color.r, color.g, color.b, 1)
    end
  end)
end
