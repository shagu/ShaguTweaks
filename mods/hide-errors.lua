local _G = ShaguTweaks.GetGlobalEnv()

local module = ShaguTweaks:register({
  title = "Hide Errors",
  description = "Hides and ignores all Lua errors produced by broken addons.",
  expansions = { ["vanilla"] = true, ["tbc"] = true },
  enabled = nil,
})

module.enable = function(self)
  error = function() return end
  seterrorhandler(error)
end
