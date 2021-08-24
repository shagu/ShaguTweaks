local _G = _G or getfenv(0)
local GetUnitData = ShaguTweaks.GetUnitData

local module = ShaguTweaks:register({
  title = "Use Class Colors On Nameplates",
  description = "Change the nameplate healthbar color to class colors",
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
