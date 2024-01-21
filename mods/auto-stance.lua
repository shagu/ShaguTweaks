local _G = ShaguTweaks.GetGlobalEnv()
local T = ShaguTweaks.T
local strsplit = ShaguTweaks.strsplit

local module = ShaguTweaks:register({
  title = T["Auto Stance"],
  description = T["Automatically switch to the required warrior or druid stance on spell cast."],
  expansions = { ["vanilla"] = true, ["tbc"] = nil },
  enabled = nil,
})

module.enable = function(self)
  local stancedance = CreateFrame("Frame")
  stancedance:RegisterEvent("UI_ERROR_MESSAGE")
  stancedance:SetScript("OnEvent", function() stancedance.lastError = arg1 end)

  stancedance.lastError = ""
  stancedance.scanString = string.gsub(SPELL_FAILED_ONLY_SHAPESHIFT, "%%s", "(.+)")
  stancedance.CastSpell = CastSpell
  stancedance.CastSpellByName = CastSpellByName
  stancedance.UseAction = UseAction

  stancedance.SwitchStance = function()
    for stance in string.gfind(stancedance.lastError, stancedance.scanString) do
      for _, stance in pairs({ strsplit(",", stance)}) do
        stancedance.CastSpellByName(string.gsub(stance,"^%s*(.-)%s*$", "%1"))
      end
    end
    stancedance.lastError = ""
  end

  function CastSpell(spellId, spellbookTabNum)
    stancedance:SwitchStance()
    stancedance.CastSpell(spellId, spellbookTabNum)
  end

  function CastSpellByName(spellName, onSelf)
    stancedance:SwitchStance()
    stancedance.CastSpellByName(spellName, onSelf)
  end

  function UseAction(slot, checkCursor, onSelf)
    stancedance:SwitchStance()
    stancedance.UseAction(slot, checkCursor, onSelf)
  end
end
