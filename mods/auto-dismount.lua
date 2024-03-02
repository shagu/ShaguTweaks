local _G = ShaguTweaks.GetGlobalEnv()
local T = ShaguTweaks.T

local module = ShaguTweaks:register({
  title = T["Auto Dismount"],
  description = T["Automatically dismounts whenever a spell is casted."],
  expansions = { ["vanilla"] = true, ["tbc"] = nil },
  enabled = nil,
})

module.enable = function(self)
  local dismount = CreateFrame("Frame")
  ShaguTweaks.dismount = dismount

  -- mount tooltip texts
  dismount.strings = {
    -- deDE
    "^Erhöht Tempo um (.+)%%",
    -- enUS
    "^Increases speed by (.+)%%",
    -- esES
    "^Aumenta la velocidad en un (.+)%%",
    -- frFR
    "^Augmente la vitesse de (.+)%%",
    -- ruRU
    "^Скорость увеличена на (.+)%%",
    -- koKR
    "^이동 속도 (.+)%%만큼 증가",
    -- zhCN
    "^速度提高(.+)%%",

    -- turtle-wow
    "speed based on",
    "Slow and steady...",
    "Riding",
    "根据骑术技能提高速度。",
    "又慢又稳......",
  }

  -- shapeshift buff icons
  dismount.shapeshifts = {
    "ability_racial_bearform", "ability_druid_catform", "ability_druid_travelform",
    "spell_nature_forceofnature", "ability_druid_aquaticform", "spell_nature_spiritwolf"
  }

  -- errors that indicate mount/shapeshift
  dismount.errors = { SPELL_FAILED_NOT_MOUNTED, ERR_ATTACK_MOUNTED, ERR_TAXIPLAYERALREADYMOUNTED,
    SPELL_FAILED_NOT_SHAPESHIFT, SPELL_FAILED_NO_ITEMS_WHILE_SHAPESHIFTED, SPELL_NOT_SHAPESHIFTED,
    SPELL_NOT_SHAPESHIFTED_NOSPACE, ERR_CANT_INTERACT_SHAPESHIFTED, ERR_NOT_WHILE_SHAPESHIFTED,
    ERR_NO_ITEMS_WHILE_SHAPESHIFTED, ERR_TAXIPLAYERSHAPESHIFTED,ERR_MOUNT_SHAPESHIFTED }

  dismount.scanner = ShaguTweaks.libtipscan:GetScanner("dismount")

  dismount:RegisterEvent("UI_ERROR_MESSAGE")
  dismount:SetScript("OnEvent", function()
    -- stand up
    if arg1 == SPELL_FAILED_NOT_STANDING then
      SitOrStand()
      return
    end

    -- scan through buffs and cancel shapeshift/mount
    for id, errorstring in pairs(dismount.errors) do
      if arg1 == errorstring then
        for i=0, 31 do
          -- detect mounts based on tooltip text
          dismount.scanner:SetPlayerBuff(i)
          for _, str in pairs(dismount.strings) do
            if dismount.scanner:Find(str) then
              CancelPlayerBuff(i)
              return
            end
          end

          -- detect shapeshift based on texture
          local buff = GetPlayerBuffTexture(i)
          if buff then
            for id, bufftype in pairs(dismount.shapeshifts) do
              if string.find(string.lower(buff), bufftype) then
                CancelPlayerBuff(i)
                return
              end
            end
          end
        end
      end
    end
  end)
end
