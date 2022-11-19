-- This module can be used to add your own custom code.
-- Make sure to read the comments carefully.

-- Remove the following line to activate the module:
if true then return end

-- This table holds the meta-data of the module:
local module = ShaguTweaks:register({
  title = "Custom Settings",
  description = "Custom code: Have a look at mods/custom.lua",
  expansions = { ["vanilla"] = true, ["tbc"] = true },
  category = nil,
  enabled = nil,
})

-- Global code:
--   This is where you can put your most basic variable assignments.
--   Code in this scope will *always* run, no matter if the module is enabled or not.
local _G = ShaguTweaks.GetGlobalEnv()

module.enable = function(self)
  -- Module code:
  --   This is where you should put your changes.
  --   Code in this scope will *only* if the module is enabled.

  -- Example:
  -- Hide actionbar textures:
  -- for i = 0, 4 do
  --   _G["MainMenuMaxLevelBar"..i]:Hide()
  --   _G["MainMenuBarTexture"..i]:Hide()
  -- end
end
