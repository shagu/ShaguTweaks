local _G = ShaguTweaks.GetGlobalEnv()
local T = ShaguTweaks.T
local gfind = string.gmatch or string.gfind
local GetUnitData = ShaguTweaks.GetUnitData
local hooksecurefunc = ShaguTweaks.hooksecurefunc
local GetExpansion = ShaguTweaks.GetExpansion
local cmatch = ShaguTweaks.cmatch
local rgbhex = ShaguTweaks.rgbhex
local strsplit = ShaguTweaks.strsplit

local module = ShaguTweaks:register({
  title = T["Chat Hyperlinks"],
  description = T["Copy website URLs from the chat, transforms CLINKs into real items and handles quest and player links."],
  expansions = { ["vanilla"] = true, ["tbc"] = true },
  category = T["Social & Chat"],
  enabled = true,
})

local URLPattern = {
  WWW = {
    ["rx"]=" (www%d-)%.([_A-Za-z0-9-]+)%.(%S+)%s?",
    ["fm"]="%s.%s.%s"},
  PROTOCOL = {
    ["rx"]=" (%a+)://(%S+)%s?",
    ["fm"]="%s://%s"},
  EMAIL = {
    ["rx"]=" ([_A-Za-z0-9-%.:]+)@([_A-Za-z0-9-]+)(%.)([_A-Za-z0-9-]+%.?[_A-Za-z0-9-]*)%s?",
    ["fm"]="%s@%s%s%s"},
  PORTIP = {
    ["rx"]=" (%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?):(%d%d?%d?%d?%d?)%s?",
    ["fm"]="%s.%s.%s.%s:%s"},
  IP = {
    ["rx"]=" (%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%s?",
    ["fm"]="%s.%s.%s.%s"},
  SHORTURL = {
    ["rx"]=" (%a+)%.(%a+)/(%S+)%s?",
    ["fm"]="%s.%s/%s"},
  URLIP = {
    ["rx"]=" ([_A-Za-z0-9-]+)%.([_A-Za-z0-9-]+)%.(%S+)%:([_0-9-]+)%s?",
    ["fm"]="%s.%s.%s:%s"},
  URL = {
    ["rx"]=" ([_A-Za-z0-9-]+)%.([_A-Za-z0-9-]+)%.(%S+)%s?",
    ["fm"]="%s.%s.%s"},
}

local function FormatLink(formatter,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10)
  if not (formatter and a1) then return end
  local newtext = string.format(formatter,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10)

  -- check the last capture index for consecutive trailing dots (invalid top level domain)
  local invalidtld
  for _, arg in pairs({a10,a9,a8,a7,a6,a5,a4,a3,a2,a1}) do
    if arg then
      invalidtld = string.find(arg, "(%.%.)$")
      break
    end
  end

  if (invalidtld) then return newtext end
  if formatter == URLPattern.EMAIL.fm then -- email parser
    local colon = string.find(a1,":")
    if (colon) and string.len(a1) > colon then
      if not (string.sub(a1,1,6) == "mailto") then
        local prefix,address = string.sub(newtext,1,colon),string.sub(newtext,colon+1)
        return string.format(" %s|cffccccff|Hurl:%s|h[%s]|h|r ",prefix,address,address)
      end
    end
  end
  return " |cffccccff|Hurl:" .. newtext .. "|h[" .. newtext .. "]|h|r "
end

local URLFuncs = {
  ["WWW"] = function(a1,a2,a3) return FormatLink(URLPattern.WWW.fm,a1,a2,a3) end,
  ["PROTOCOL"] = function(a1,a2) return FormatLink(URLPattern.PROTOCOL.fm,a1,a2) end,
  ["EMAIL"] = function(a1,a2,a3,a4) return FormatLink(URLPattern.EMAIL.fm,a1,a2,a3,a4) end,
  ["PORTIP"] = function(a1,a2,a3,a4,a5) return FormatLink(URLPattern.PORTIP.fm,a1,a2,a3,a4,a5) end,
  ["IP"] = function(a1,a2,a3,a4) return FormatLink(URLPattern.IP.fm,a1,a2,a3,a4) end,
  ["SHORTURL"] = function(a1,a2,a3) return FormatLink(URLPattern.SHORTURL.fm,a1,a2,a3) end,
  ["URLIP"] = function(a1,a2,a3,a4) return FormatLink(URLPattern.URLIP.fm,a1,a2,a3,a4) end,
  ["URL"] = function(a1,a2,a3) return FormatLink(URLPattern.URL.fm,a1,a2,a3) end,
}

local function HandleLink(text)
  local URLPattern = URLPattern
  text = string.gsub (text, URLPattern.WWW.rx, URLFuncs.WWW)
  text = string.gsub (text, URLPattern.PROTOCOL.rx, URLFuncs.PROTOCOL)
  text = string.gsub (text, URLPattern.EMAIL.rx, URLFuncs.EMAIL)
  text = string.gsub (text, URLPattern.PORTIP.rx, URLFuncs.PORTIP)
  text = string.gsub (text, URLPattern.IP.rx, URLFuncs.IP)
  text = string.gsub (text, URLPattern.SHORTURL.rx, URLFuncs.SHORTURL)
  text = string.gsub (text, URLPattern.URLIP.rx, URLFuncs.URLIP)
  text = string.gsub (text, URLPattern.URL.rx, URLFuncs.URL)
  return text
end

local CopyLinkDialog = CreateFrame("Frame", "ShaguTweaksURLCopy", UIParent)
CopyLinkDialog:Hide()

CopyLinkDialog:SetWidth(300)
CopyLinkDialog:SetHeight(90)
CopyLinkDialog:SetFrameStrata("FULLSCREEN")
CopyLinkDialog:SetPoint("CENTER", 0, 0)
CopyLinkDialog:SetBackdrop({
  bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
  tile = true, tileSize = 32, edgeSize = 32,
  insets = { left = 11, right = 12, top = 12, bottom = 11 }
})

CopyLinkDialog:SetScript("OnShow", function()
  this.text:HighlightText()
end)

CopyLinkDialog.text = CreateFrame("EditBox", "ShaguTweaksURLCopyEditBox", CopyLinkDialog)
CopyLinkDialog.text:SetTextColor(1,.8,0)
CopyLinkDialog.text:SetJustifyH("CENTER")
CopyLinkDialog.text:SetBackdrop({
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true, tileSize = 16, edgeSize = 16,
  insets = { left = 3, right = 3, top = 3, bottom = 3 }
})

CopyLinkDialog.text:SetBackdropColor(0,0,0,.8)
CopyLinkDialog.text:SetBackdropBorderColor(.8,.8,.8,1)

CopyLinkDialog.text:SetWidth(260)
CopyLinkDialog.text:SetHeight(25)

CopyLinkDialog.text:SetPoint("TOP", CopyLinkDialog, "TOP", 0, -20)
CopyLinkDialog.text:SetFontObject(GameFontNormal)

CopyLinkDialog.text:SetScript("OnEscapePressed", function(self)
  CopyLinkDialog:Hide()
end)

CopyLinkDialog.text:SetScript("OnEditFocusLost", function(self)
  CopyLinkDialog:Hide()
end)

CopyLinkDialog.close = CreateFrame("Button", "ShaguTweaksURLCopyClose", CopyLinkDialog, "UIPanelButtonTemplate")
CopyLinkDialog.close:SetPoint("BOTTOMRIGHT", CopyLinkDialog, "BOTTOMRIGHT", -20, 20)
CopyLinkDialog.close:SetWidth(70)
CopyLinkDialog.close:SetHeight(18)

CopyLinkDialog.close:SetText(CLOSE)
CopyLinkDialog.close:SetScript("OnClick", function()
  CopyLinkDialog:Hide()
end)

CopyLinkDialog.CopyText = function(text)
  CopyLinkDialog.text:SetText(text)
  CopyLinkDialog:Show()
end

module.enable = function(self)
  local HookSetItemRef = SetItemRef
  function _G.SetItemRef(link, text, button)
    local questlink, _, quest_id = string.find(link, "quest:(%d+):.*")
    local playerlink = strsub(link, 1, 6) == "player"

    -- don't overwrite other addons questlink hook
    if ShaguQuest or pfQuest or Questie then questlink = nil end

    if (strsub(link, 1, 3) == "url") then
      if string.len(link) > 4 and string.sub(link,1,4) == "url:" then
        CopyLinkDialog.CopyText(string.sub(link,5, string.len(link)))
      end
      return
    elseif questlink then
      local _, _, quest_title = string.find(text, ".*|h%[(.*)%]|h.*")
      if quest_title then
        HideUIPanel(ItemRefTooltip)
        ShowUIPanel(ItemRefTooltip)
        ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
        ItemRefTooltip:AddLine(quest_title, 1,1,0)
        ItemRefTooltip:AddDoubleLine("Quest ID", quest_id, .6, .6, .6, 1, 1, 1)
        ItemRefTooltip:Show()
      end
      return
    elseif playerlink then
      local name = strsub(link, 8)
      if ( name and (strlen(name) > 0) ) then
        local name, _ = strsplit(":", name)
        name = gsub(name, "([^%s]*)%s+([^%s]*)%s+([^%s]*)", "%3")
        name = gsub(name, "([^%s]*)%s+([^%s]*)", "%2")
        if IsShiftKeyDown() and ChatFrameEditBox:IsVisible() then
          ChatFrameEditBox:Insert("|cffffffff|Hplayer:"..name.."|h["..name.."]|h|r")
          return
        end
      end
    end
    HookSetItemRef(link, text, button)
  end

  do -- add class colors to chat
    for i=1,NUM_CHAT_WINDOWS do
      if _G["ChatFrame"..i] and not _G["ChatFrame"..i].HookAddMessage then
        _G["ChatFrame"..i].HookAddMessage = _G["ChatFrame"..i].AddMessage
        _G["ChatFrame"..i].AddMessage = function(frame, text, a1, a2, a3, a4, a5)
          if text then
            -- Remove prat CLINKs
            text = gsub(text, "{CLINK:(%x+):([%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-):([^}]-)}", "|c%1|Hitem:%2|h[%3]|h|r") -- tbc
            text = gsub(text, "{CLINK:(%x+):([%d-]-:[%d-]-:[%d-]-:[%d-]-):([^}]-)}", "|c%1|Hitem:%2|h[%3]|h|r") -- vanilla

            -- Remove chatter CLINKs
            text = gsub(text, "{CLINK:item:(%x+):([%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-):([^}]-)}", "|c%1|Hitem:%2|h[%3]|h|r")
            text = gsub(text, "{CLINK:enchant:(%x+):([%d-]-):([^}]-)}", "|c%1|Henchant:%2|h[%3]|h|r")
            text = gsub(text, "{CLINK:spell:(%x+):([%d-]-):([^}]-)}", "|c%1|Hspell:%2|h[%3]|h|r")
            text = gsub(text, "{CLINK:quest:(%x+):([%d-]-):([%d-]-):([^}]-)}", "|c%1|Hquest:%2:%3|h[%4]|h|r")

            -- Detect URLs
            text = HandleLink(text)
          end

          _G["ChatFrame"..i].HookAddMessage(frame, text, a1, a2, a3, a4, a5)
        end
      end
    end
  end
end
