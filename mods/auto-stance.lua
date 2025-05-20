local _G = ShaguTweaks.GetGlobalEnv()
local T = ShaguTweaks.T
local strsplit = ShaguTweaks.strsplit

local module = ShaguTweaks:register({
  title = T["Auto Stance"],
  description = T["Automatically switch to the required warrior or druid stance on spell cast."],
  expansions = { ["vanilla"] = true, ["tbc"] = nil },
  enabled = true,
})

module.enable = function(self)
  local stancedance = CreateFrame("Frame", "ShaguTweaksStancedance")
  stancedance.scanString = string.gsub(SPELL_FAILED_ONLY_SHAPESHIFT, "%%s", "(.+)")
  stancedance:RegisterEvent("UI_ERROR_MESSAGE")
  stancedance:SetScript("OnEvent", function()
    for stances in string.gfind(arg1, stancedance.scanString) do
      for _, stance in pairs({ strsplit(",", stances)}) do
        CastSpellByName(string.gsub(stance,"^%s*(.-)%s*$", "%1"))
      end
    end
  end)
end
