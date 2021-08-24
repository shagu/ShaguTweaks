local _G = _G or getfenv(0)
local GetExpansion = ShaguTweaks.GetExpansion
local current_config = {}
local settings = CreateFrame("Frame", "AdvancedSettingsGUI", UIParent)
settings:Hide()

table.insert(UISpecialFrames, "AdvancedSettingsGUI")
settings:SetScript("OnHide", function()
  ShowUIPanel(GameMenuFrame)
  UpdateMicroButtons()
end)

settings:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
settings:SetWidth(434)
settings:SetHeight(400)
settings:SetBackdrop({
  bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
  tile = true, tileSize = 32, edgeSize = 32,
  insets = { left = 11, right = 12, top = 12, bottom = 11 }
})

settings.title = CreateFrame("Frame", "AdvancedSettingsGUITtitle", settings)
settings.title:SetPoint("TOP", settings, "TOP", 0, 12)
settings.title:SetWidth(256)
settings.title:SetHeight(64)

settings.title.tex = settings.title:CreateTexture(nil, "MEDIUM")
settings.title.tex:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
settings.title.tex:SetAllPoints()

settings.title.text = settings.title:CreateFontString(nil, "HIGH", "GameFontNormal")
settings.title.text:SetText("Advanced Options")
settings.title.text:SetPoint("TOP", 0, -14)

settings.cancel = CreateFrame("Button", "AdvancedSettingsGUICancel", settings, "GameMenuButtonTemplate")
settings.cancel:SetWidth(90)
settings.cancel:SetPoint("BOTTOMRIGHT", settings, "BOTTOMRIGHT", -17, 17)
settings.cancel:SetText(CANCEL)
settings.cancel:SetScript("OnClick", function()
  current_config = {}
  settings:Hide()
end)

settings.okay = CreateFrame("Button", "AdvancedSettingsGUIOkay", settings, "GameMenuButtonTemplate")
settings.okay:SetWidth(90)
settings.okay:SetPoint("RIGHT", settings.cancel, "LEFT", 0, 0)
settings.okay:SetText(OKAY)
settings.okay:SetScript("OnClick", function()
  local reload

  -- save temporary config to real config
  for k, v in pairs(current_config) do
    -- check if reload is required
    if current_config[k] ~= ShaguTweaks_config[k] then
      reload = true
    end

    -- set new config
    ShaguTweaks_config[k] = v
  end

  -- reload the UI if required
  if reload then ReloadUI() end

  settings:Hide()
end)

settings.defaults = CreateFrame("Button", "AdvancedSettingsGUICancel", settings, "GameMenuButtonTemplate")
settings.defaults:SetWidth(90)
settings.defaults:SetPoint("BOTTOMLEFT", settings, "BOTTOMLEFT", 17, 17)
settings.defaults:SetText(DEFAULTS)
settings.defaults:SetScript("OnClick", function()
  settings:defaults()
end)

settings.load = function(self)
  settings.entries = settings.entries or {}
  local entry = 1

  for title, mod in pairs(ShaguTweaks.mods) do
    if not settings.entries[entry] then
      settings.entries[entry] = CreateFrame("CheckButton", "AdvancedSettingsGUI" .. entry, settings, "OptionsCheckButtonTemplate")
    end

    local button = _G["AdvancedSettingsGUI" .. entry]
    local text = _G["AdvancedSettingsGUI" .. entry .. "Text"]

    button.title = title
    button:SetChecked(current_config[title] == 1 and true or nil)

    button:SetPoint("TOPLEFT", settings, "TOPLEFT", math.mod(entry, 2) == 1 and 17 or 17+200, math.ceil(entry/2)*-30)

    local description = mod.description
    button:SetScript("OnEnter", function()
      GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
      GameTooltip:SetText(description, nil, nil, nil, nil, 1)
      GameTooltip:Show()
    end)

    button:SetScript("OnHide", function()
      GameTooltip:Hide()
    end)

    button:SetScript("OnClick", function()
      if this:GetChecked() then
        current_config[this.title] = 1
      else
        current_config[this.title] = 0
      end
    end)
    text:SetText(title)

    entry = entry + 1
  end

  settings:SetHeight(80 + math.floor(entry/2)*30)
end

settings.defaults = function()
  -- read default settings from modules
  for title, mod in pairs(ShaguTweaks.mods) do
    current_config[title] = mod.enabled and 1 or 0
  end
  settings:load()
end

settings:SetScript("OnShow", function()
  -- read current config to temporary config
  for k, v in pairs(ShaguTweaks_config) do
    current_config[k] = v
  end

  settings:load()
end)

-- Add "Advanced Settings" Button to the Game Menu
GameMenuFrame:SetWidth(GameMenuFrame:GetWidth() - 30)
if GetExpansion() == 'tbc' then
  GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + 10)
elseif GetExpansion() == 'vanilla' then
  GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + 6)
end

local advanced = CreateFrame("Button", "GameMenuButtonAdvancedOptions", GameMenuFrame, "GameMenuButtonTemplate")
advanced:SetPoint("TOP", GameMenuButtonUIOptions, "BOTTOM", 0, -1)
advanced:SetText("Advanced Options|cffffff00*")
advanced:SetScript("OnClick", function()
  HideUIPanel(GameMenuFrame)
  settings:Show()
end)

GameMenuButtonKeybindings:ClearAllPoints()
GameMenuButtonKeybindings:SetPoint("TOP", advanced, "BOTTOM", 0, -1)
