local _G = _G or getfenv(0)

local module = ShaguTweaks:register({
  title = "Auto Dismount",
  description = "Automatically dismounts whenever a spell is casted.",
  expansions = { ["vanilla"] = true, ["tbc"] = nil },
  enabled = nil,
})

module.enable = function(self)
  local dismount = CreateFrame("Frame")
  dismount:RegisterEvent("UI_ERROR_MESSAGE")

  dismount.buffs = { "spell_nature_swiftness", "_mount_", "_qirajicrystal_",
    "ability_racial_bearform", "ability_druid_catform", "ability_druid_travelform",
    "spell_nature_forceofnature", "ability_druid_aquaticform", "spell_nature_spiritwolf",
    "ability_hunter_pet_turtle", "inv_misc_head_dragon_black", "ability_bullrush" }

  dismount.errors = { SPELL_FAILED_NOT_MOUNTED, ERR_ATTACK_MOUNTED, ERR_TAXIPLAYERALREADYMOUNTED,
    SPELL_FAILED_NOT_SHAPESHIFT, SPELL_FAILED_NO_ITEMS_WHILE_SHAPESHIFTED, SPELL_NOT_SHAPESHIFTED,
    SPELL_NOT_SHAPESHIFTED_NOSPACE, ERR_CANT_INTERACT_SHAPESHIFTED, ERR_NOT_WHILE_SHAPESHIFTED,
    ERR_NO_ITEMS_WHILE_SHAPESHIFTED, ERR_TAXIPLAYERSHAPESHIFTED,ERR_MOUNT_SHAPESHIFTED }

  dismount:SetScript("OnEvent", function()
    -- stand up
    if arg1 == SPELL_FAILED_NOT_STANDING then
      SitOrStand()
      return
    end

    -- cancel mount buff
    for id, errorstring in pairs(dismount.errors) do
      if arg1 == errorstring then
        for i=0,15,1 do
          local buff = GetPlayerBuffTexture(i)
          if buff then
            for id, bufftype in pairs(dismount.buffs) do
              if string.find(string.lower(buff), bufftype) then
                CancelPlayerBuff(i)
              end
            end
          end
        end
      end
    end
  end)
end
