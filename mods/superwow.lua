-- SuperWoW compatibility
--
-- https://github.com/balakethelock/SuperWoW
--
-- This module adds GUID based cast and channel data to the
-- libcast library that is used to query enemy casting infos.

-- Skip module initialization if SuperWoW is not running.
if not GetPlayerBuffID or not CombatLogAdd or not SpellInfo then return end

local T = ShaguTweaks.T

local module = ShaguTweaks:register({
  title = T["Super WoW Compatibility"],
  description = T["Adds compatibility for the SuperWoW client mod."],
  expansions = { ["vanilla"] = true, ["tbc"] = false },
  category = T["General"],
  enabled = true,
})

module.enable = function(self)
  local libcast = ShaguTweaks.libcast

  local unitcast = CreateFrame("Frame")
  unitcast:RegisterEvent("UNIT_CASTEVENT")
  unitcast:SetScript("OnEvent", function()
    if arg3 == "START" or arg3 == "CAST" or arg3 == "CHANNEL" then
      -- human readable argument list
      local guid = arg1
      local target = arg2
      local event_type = arg3
      local spell_id = arg4
      local timer = arg5
      local start = GetTime()

      -- get spell info from spell id
      local spell, icon, _
      if SpellInfo and SpellInfo(spell_id) then
        spell, _, icon = SpellInfo(spell_id)
      end

      -- set fallback values
      spell = spell or UNKNOWN
      icon = icon or "Interface\\Icons\\INV_Misc_QuestionMark"

      -- add cast action to the database
      if not libcast.db[guid] then libcast.db[guid] = {} end
      libcast.db[guid].cast = spell
      libcast.db[guid].rank = nil
      libcast.db[guid].start = GetTime()
      libcast.db[guid].casttime = timer
      libcast.db[guid].icon = icon
      libcast.db[guid].channel = event_type == "CHANNEL" or false

      -- write state variable
      ShaguTweaks.superwow_active = true
    elseif arg3 == "FAIL" then
      local guid = arg1

      -- delete all cast entries of guid
      if libcast.db[guid] then
        libcast.db[guid].cast = nil
        libcast.db[guid].rank = nil
        libcast.db[guid].start = nil
        libcast.db[guid].casttime = nil
        libcast.db[guid].icon = nil
        libcast.db[guid].channel = nil
      end
    end
  end)
end