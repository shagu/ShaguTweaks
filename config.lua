local _G = ShaguTweaks.GetGlobalEnv()
local T = ShaguTweaks.T
local GetExpansion = ShaguTweaks.GetExpansion
local mod = math.mod or mod

local current_config = {}
local max_width = 500
local max_height = 680

local settings = CreateFrame("Frame", "AdvancedSettingsGUI", UIParent)
settings:Hide()

table.insert(UISpecialFrames, "AdvancedSettingsGUI")
settings:SetScript("OnHide", function()
  ShowUIPanel(GameMenuFrame)
  UpdateMicroButtons()
end)

settings:SetPoint("CENTER", UIParent, "CENTER", 0, 32)
settings:SetWidth(max_width)
settings:SetMovable(true)
settings:EnableMouse(true)
settings:RegisterForDrag("LeftButton")
settings:SetScript("OnDragStart", function() this:StartMoving() end)
settings:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
settings:SetFrameStrata("DIALOG")

settings:SetBackdrop({
  bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
  tile = true, tileSize = 32, edgeSize = 32,
  insets = { left = 11, right = 12, top = 12, bottom = 11 }
})

settings.scrollframe = CreateFrame('ScrollFrame', 'AdvancedSettingsGUIScrollframe', settings, 'UIPanelScrollFrameTemplate')
settings.scrollframe:SetWidth(max_width - 50)
settings.scrollframe:SetPoint('CENTER', settings, -16, 15)
settings.scrollframe:Hide()

settings.container = CreateFrame("Frame", "AdvancedSettingsGUIContainer", settings)

settings.title = CreateFrame("Frame", "AdvancedSettingsGUITtitle", settings)
settings.title:SetPoint("TOP", settings, "TOP", 0, 12)
settings.title:SetWidth(256)
settings.title:SetHeight(64)

settings.title.tex = settings.title:CreateTexture(nil, "MEDIUM")
settings.title.tex:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
settings.title.tex:SetAllPoints()

settings.title.text = settings.title:CreateFontString(nil, "HIGH", "GameFontNormal")
settings.title.text:SetText(T["Advanced Options"])
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
  if reload then
    Minimap:SetMaskTexture("Textures\\MinimapMask")
    ReloadUI()
  end

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
  -- never use more than 3/4 of the screen size
  max_height = math.min(UIParent:GetHeight()/UIParent:GetScale()*0.75, 680)

  -- update window sizing according to screen
  settings:SetHeight(max_height)
  settings.scrollframe:SetHeight(max_height - 80)
  settings.container:SetHeight(max_height - 30)

  settings.entries = settings.entries or {}
  local expansion = ShaguTweaks:GetExpansion()

  -- sort all configs into categories
  local gui = {}
  for title, module in pairs(ShaguTweaks.mods) do
    if module.expansions[expansion] then
      local category = module.category or T["General"]
      gui[category] = gui[category] or {}
      gui[category][title] = module
    end
  end

  local topspace = 10
  local required_height = topspace
  local entrysize = 22
  local previous = nil

  local sortGeneralFirst = function(a, b)
    if a == T["General"] then return true end
    if b == T["General"] then return false end
    return a < b
  end

  for category, entries in ShaguTweaks.spairs(gui, sortGeneralFirst) do
    local entry, spacing = 1, 22
    local height = 0

    -- add category background
    settings.category = settings.category or {}
    settings.category[category] = settings.category[category] or CreateFrame("Frame", nil, settings.container)

    if not previous then
      settings.category[category]:SetPoint("TOPLEFT", settings.container, "TOPLEFT", spacing, -spacing - topspace)
      settings.category[category]:SetPoint("TOPRIGHT", settings.container, "TOPRIGHT", -spacing, -spacing - topspace)
    else
      settings.category[category]:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -spacing)
      settings.category[category]:SetPoint("TOPRIGHT", previous, "BOTTOMRIGHT", 0, -spacing)
    end

    previous = settings.category[category]

    -- create category title collapse button
    local collapse = function(frame, expand)
      local parent = frame or this.parent

      if expand then
        local height = parent.collapse or parent:GetHeight()
        parent.collapse = height
      end

      if not parent.collapse then
        local height = parent:GetHeight()
        parent.collapse = height
        parent:SetHeight(1)

        for button in pairs(parent.buttons) do button:Hide() end
        parent.button:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
        parent.button:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
        parent.button:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
        parent.button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
        parent:SetAlpha(0)
      else
        local height = parent.collapse
        parent.collapse = nil
        parent:SetHeight(height)

        for button in pairs(parent.buttons) do button:Show() end
        parent.button:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
        parent.button:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
        parent.button:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled")
        parent.button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
        parent:SetAlpha(1)
      end
    end

    settings.category[category].button = settings.category[category].button or CreateFrame("Button", nil, settings.container)
    settings.category[category].button:SetPoint("TOPLEFT", settings.category[category], "TOPLEFT", 0, entrysize-4)
    settings.category[category].button:SetWidth(22)
    settings.category[category].button:SetHeight(22)
    settings.category[category].button.parent = settings.category[category]
    settings.category[category].button:SetScript("OnClick", collapse)

    settings.category[category].title = settings.category[category].title or CreateFrame("Button", nil, settings.container)
    settings.category[category].title:SetPoint("TOPLEFT", settings.category[category], "TOPLEFT", 22, entrysize-4)
    settings.category[category].title:SetWidth(200)
    settings.category[category].title:SetHeight(entrysize)
    settings.category[category].title.parent = settings.category[category]
    settings.category[category].title:SetScript("OnClick", collapse)

    settings.category[category]:SetBackdrop({
      bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
      edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      tile = true, tileSize = 8, edgeSize = 16,
      insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })

    if ShaguTweaks.DarkMode then
      settings.category[category]:SetBackdropColor(.1,.1,.1,1)
      settings.category[category]:SetBackdropBorderColor(.2,.2,.2,1)
    else
      settings.category[category]:SetBackdropColor(.2,.2,.2,1)
      settings.category[category]:SetBackdropBorderColor(.5,.5,.5,1)
    end

    -- add category title
    settings.category[category].text = settings.category[category].text or settings.category[category].title:CreateFontString(nil, "HIGH", "GameFontHighlightSmall")
    settings.category[category].text:SetJustifyH("LEFT")
    settings.category[category].text:SetAllPoints()
    settings.category[category].text:SetText(category)

    for title, module in ShaguTweaks.spairs(entries) do
      if not settings.entries[title] then
        settings.entries[title] = CreateFrame("CheckButton", "AdvancedSettingsGUI" .. title, settings.category[category], "OptionsCheckButtonTemplate")
        settings.entries[title]:SetHeight(24)
        settings.entries[title]:SetWidth(24)
      end

      local button = _G["AdvancedSettingsGUI" .. title]
      local text = _G["AdvancedSettingsGUI" .. title .. "Text"]

      settings.category[category].buttons = settings.category[category].buttons or {}
      settings.category[category].buttons[button] = true

      button.title = title
      button:SetChecked(current_config[title] == 1 and true or nil)
      button:SetPoint("TOPLEFT", settings.category[category], "TOPLEFT", mod(entry, 2) == 1 and 17 or 17+200, math.ceil(entry/2-1)*-entrysize-spacing/2)

      -- add another row to height
      if mod(entry, 2) == 1 then height = height + entrysize end

      local title = module.title
      local description = module.description
      button:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
        GameTooltip:SetText(title, nil, nil, nil, nil, 1)
        GameTooltip:AddLine(description, 1, 1, 1, 1, 1)
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

    collapse(settings.category[category], true)

    height = height + spacing
    settings.category[category]:SetHeight(height)

    required_height = required_height + height + spacing
  end

  -- set container size to required height
  settings.container:SetHeight(required_height)

  if required_height < max_height then
    -- reduce base frame if possible
    settings:SetHeight(required_height + 60)
    settings.container:SetParent(settings)
    settings.container:ClearAllPoints()
    settings.container:SetPoint("CENTER", settings, 0, 20)
    settings.container:SetWidth(max_width - 20)

    settings.scrollframe:Hide()
  elseif required_height > max_height then
    -- set up scrollframe when needed
    settings.container:SetParent(settings.scrollframe)
    settings.container:SetHeight(settings.scrollframe:GetHeight())
    settings.container:SetWidth(settings.scrollframe:GetWidth() + 20)

    settings.scrollframe:SetScrollChild(settings.container)
    settings.scrollframe:Show()
  end
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
GameMenuFrame:SetWidth(GameMenuFrame:GetWidth() - 10)
GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + 10)
local advanced = CreateFrame("Button", "GameMenuButtonAdvancedOptions", GameMenuFrame, "GameMenuButtonTemplate")
advanced:SetPoint("TOP", GameMenuButtonUIOptions, "BOTTOM", 0, -1)
advanced:SetText(T["Advanced Options"] .. "|cffffff00*")
advanced:SetScript("OnClick", function()
  HideUIPanel(GameMenuFrame)
  settings:Show()
end)

GameMenuButtonKeybindings:ClearAllPoints()
GameMenuButtonKeybindings:SetPoint("TOP", advanced, "BOTTOM", 0, -1)
