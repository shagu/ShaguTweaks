local _G = ShaguTweaks.GetGlobalEnv()
local hooksecurefunc = hooksecurefunc or ShaguTweaks.hooksecurefunc
local GetExpansion = ShaguTweaks.GetExpansion

local module = ShaguTweaks:register({
  title = "Shiftclick Action",
  description = "Allows shift-clicking on a locked actionbar to use the button instead of picking it up.",
  expansions = { ["vanilla"] = true, ["tbc"] = nil },
  category = "General",
  enabled = true,
})

module.enable = function(self)
  local HookPickupAction = PickupAction
  function PickupAction(ActionButtonID)
    if ( LOCK_ACTIONBAR == "1" ) then
      if ( IsShiftKeyDown() ) then
        UseAction(ActionButtonID, 1);
      end
      return
	end
    HookPickupAction(ActionButtonID)
  end
end
