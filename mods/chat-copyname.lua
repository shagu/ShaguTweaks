local _G = ShaguTweaks.GetGlobalEnv()
local hooksecurefunc = ShaguTweaks.hooksecurefunc
local strsplit = ShaguTweaks.strsplit

local module = ShaguTweaks:register({
  title = "Copy Name",
  description = "Copy person name by pressing shift & left clicking persons name in chat.",
  expansions = { ["vanilla"] = true, ["tbc"] = true },
  category = "Social & Chat",
  enabled = true,
})

module.enable = function(self)

  hooksecurefunc("UnitPopup_OnClick", function(self)
    DEFAULT_CHAT_FRAME:AddMessage("You have clicked on!")

  end)

  local tempSetItemRef = SetItemRef
  _G.SetItemRef = function (link,text,button)
    if(button == "LeftButton") then
      if ( strsub(link, 1, 6) == "player" ) then
        local name = strsub(link, 8)
        if ( name and (strlen(name) > 0) ) then
          local name, _ = strsplit(":", name)
          name = gsub(name, "([^%s]*)%s+([^%s]*)%s+([^%s]*)", "%3")
          name = gsub(name, "([^%s]*)%s+([^%s]*)", "%2")
          if IsShiftKeyDown() then
            if not ChatFrameEditBox:IsVisible() then 
              ChatFrame_OpenChat("|cffffffff|Hplayer:"..name.."|h"..name.."|h|r")
            else
              ChatFrameEditBox:Insert("|cffffffff|Hplayer:"..name.."|h"..name.."|h|r")
            end
            return
          end
        end

      end
    end
    tempSetItemRef(link, text, button)
  end
end

