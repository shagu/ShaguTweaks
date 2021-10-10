-- This is a sample module skeleton.
-- It does not serve any purpose, other than showing how to write a module.
-- Don't forget to add your module to the *.toc file once you're done.

local _G = _G or getfenv(0)
local GetExpansion = ShaguTweaks.GetExpansion

-- Remove this line, if you want the code for both expansions
if GetExpansion() == "tbc" then return end

-- This table holds the meta-data of the module:
local module = ShaguTweaks:register({
  title = "Custom Options",
  description = "A template module, showcasing custom changes",
  enabled = nil, 
})

module.enable = function(self)
  -- this code is running, if the mod gets enabled in the settings
end
