-- TurtleWoW decided to change and add QoL features to their
-- default client, which they consider to be wanted by everyone.
-- This modules lets you disable the target-healthpoints again.
--
-- Depending on the amount of changes in future, this might move
-- from "Unit Frames" to a more general "Revert TWoW Changes" module.

-- Skip module initialization on every other client than TurtleWoW.
if not TargetHPText or not TargetHPPercText then return end

-- This table holds the meta-data of the module:
local module = ShaguTweaks:register({
  title = "Hide TWoW Target Health",
  description = "Hide Turtle-WoW Custom Health Points From Target Frame",
  expansions = { ["vanilla"] = true, ["tbc"] = false },
  category = "Unit Frames",
  enabled = true,
})

module.enable = function(self)
  TargetHPText:Hide()
  TargetHPText.Show = function() return end

  TargetHPPercText:Hide()
  TargetHPPercText.Show  = function() return end
end
