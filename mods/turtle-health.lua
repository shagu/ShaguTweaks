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

-- Turtle WoW specific libdebuff patches
local libdebuff = ShaguTweaks.libdebuff
local libdebuff_twow = CreateFrame("Frame")
libdebuff_twow:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
libdebuff_twow:SetScript("OnEvent", function()
  -- Break early on invalid data
  if not arg1 or not arg2 then return end

  -- Holy Strike is a spell, but can refresh paladin judgements
  -- Credits to @geojak
  if string.find(arg1, "Holy Strike") then
    for seal in ShaguTweaks.L["judgements"] do
      local name = UnitName("target")
      local level = UnitLevel("target")
      if name and libdebuff.objects[name] then
        if level and libdebuff.objects[name][level] and libdebuff.objects[name][level][seal] then
          libdebuff:AddEffect(name, level, seal)
        elseif libdebuff.objects[name][0] and libdebuff.objects[name][0][seal] then
          libdebuff:AddEffect(name, 0, seal)
        end
      end
    end
  end
end)
