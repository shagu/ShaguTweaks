local _G = ShaguTweaks.GetGlobalEnv()
local strsplit = ShaguTweaks.strsplit

local module = ShaguTweaks:register({
  title = "Copy Name",
  description = "Copy person name by pressing shift & left clicking persons name in chat.",
  expansions = { ["vanilla"] = true, ["tbc"] = true },
  category = "Social & Chat",
  enabled = true,
})

module.enable = function(self)

  local tempSetItemRef = SetItemRef
  _G.SetItemRef = function (link,text,button)

    if(button == "LeftButton") and IsShiftKeyDown() then

      if ( strsub(link, 1, 6) == "player" ) then
        local name = strsub(link, 8)
        if ( name and (strlen(name) > 0) ) then
          local name, _ = strsplit(":", name)
          name = gsub(name, "([^%s]*)%s+([^%s]*)%s+([^%s]*)", "%3")
          name = gsub(name, "([^%s]*)%s+([^%s]*)", "%2")
            if not ChatFrameEditBox:IsVisible() then 
              ChatFrame_OpenChat(name)
            else
              ChatFrameEditBox:Insert(name)
            end
            return
        end

      end
    end
    tempSetItemRef(link, text, button)
  end
end

