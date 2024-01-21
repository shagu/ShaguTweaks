local _G = ShaguTweaks.GetGlobalEnv()
local T = ShaguTweaks.T
local scrollspeed = 1

local module = ShaguTweaks:register({
  title = T["Chat Tweaks"],
  description = T["Allows to scroll using the mouse wheel, enables sticky chat channels and repeats message on arrow up."],
  expansions = { ["vanilla"] = true, ["tbc"] = true },
  category = T["Social & Chat"],
  enabled = true,
})

local function ChatOnMouseWheel()
  if arg1 > 0 then
    if IsShiftKeyDown() then
      this:ScrollToTop()
    else
      for i=1, scrollspeed do
        this:ScrollUp()
      end
    end
  elseif arg1 < 0 then
    if IsShiftKeyDown() then
      this:ScrollToBottom()
    else
      for i=1, scrollspeed do
        this:ScrollDown()
      end
    end
  end
end

module.enable = function(self)
  -- enable sticky chat types
  ChatTypeInfo.WHISPER.sticky = 1
  ChatTypeInfo.OFFICER.sticky = 1
  ChatTypeInfo.RAID_WARNING.sticky = 1
  ChatTypeInfo.CHANNEL.sticky = 1

  -- repeat message without pressing <alt>
  ChatFrameEditBox:SetAltArrowKeyMode(false)

  for i=1, NUM_CHAT_WINDOWS do
    -- enable mouse wheel scrolling
    _G["ChatFrame" .. i]:EnableMouseWheel(true)
    _G["ChatFrame" .. i]:SetScript("OnMouseWheel", ChatOnMouseWheel)

    -- hide buttons
    --_G["ChatFrame" .. i .. "UpButton"]:Hide()
    --_G["ChatFrame" .. i .. "UpButton"].Show = function() return end
    --_G["ChatFrame" .. i .. "DownButton"]:Hide()
    --_G["ChatFrame" .. i .. "DownButton"].Show = function() return end
    --_G["ChatFrame" .. i .. "BottomButton"]:Hide()
    --_G["ChatFrame" .. i .. "BottomButton"].Show = function() return end
    --_G["ChatFrameMenuButton"]:Hide()
    --_G["ChatFrameMenuButton"].Show = function() return end
  end
end
