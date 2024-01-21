local _G = ShaguTweaks.GetGlobalEnv()
local T = ShaguTweaks.T

local module = ShaguTweaks:register({
  title = T["Hide Errors"],
  description = T["Hides and ignores all Lua errors produced by broken addons."],
  expansions = { ["vanilla"] = true, ["tbc"] = true },
  enabled = nil,
})

module.enable = function(self)
  error = function() return end
  seterrorhandler(error)
end
