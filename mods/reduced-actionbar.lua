local _G = ShaguTweaks.GetGlobalEnv()
local T = ShaguTweaks.T

local module = ShaguTweaks:register({
  title = T["Reduced Actionbar Size"],
  description = T["Reduces the actionbar size by removing several items such as the bag panel and microbar"],
  expansions = { ["vanilla"] = true, ["tbc"] = nil },
  categpry = nil,
  enabled = nil,
})

local function ReplaceBag()
  local id = this:GetID()
  if id ~= 0 then
    id = ContainerIDToInventoryID(id)
    if CursorHasItem() then
      PutItemInBag(id)
    else
      PickupBagFromSlot(id)
    end
  end
end

module.enable = function(self)
  -- general function to hide textures and frames
  local function hide(frame, texture)
    if not frame then return end

    if texture and texture == 1 and frame.SetTexture then
      frame:SetTexture("")
    elseif texture and texture == 2 and frame.SetNormalTexture then
      frame:SetNormalTexture("")
    else
      frame:ClearAllPoints()
      frame.Show = function() return end
      frame:Hide()
    end
  end

  -- frames that shall be hidden
  local frames = {
    -- actionbar paging
    MainMenuBarPageNumber, ActionBarUpButton, ActionBarDownButton,
    -- xp and reputation bar
    MainMenuXPBarTexture2, MainMenuXPBarTexture3,
    ReputationWatchBarTexture2, ReputationWatchBarTexture3,
    -- actionbar backgrounds
    MainMenuBarTexture2, MainMenuBarTexture3,
    MainMenuMaxLevelBar2, MainMenuMaxLevelBar3,
    -- micro button panel
    CharacterMicroButton, SpellbookMicroButton, TalentMicroButton,
    QuestLogMicroButton, MainMenuMicroButton, SocialsMicroButton,
    WorldMapMicroButton, MainMenuBarPerformanceBarFrame, HelpMicroButton,
    -- bag panel
    CharacterBag3Slot, CharacterBag2Slot, CharacterBag1Slot,
    CharacterBag0Slot, MainMenuBarBackpackButton, KeyRingButton,
    -- shapeshift backgrounds
    ShapeshiftBarLeft, ShapeshiftBarMiddle, ShapeshiftBarRight,
  }

  -- textures that shall be set empty
  local textures = {
    ReputationWatchBarTexture2, ReputationWatchBarTexture3,
    ReputationXPBarTexture2, ReputationXPBarTexture3,
    SlidingActionBarTexture0, SlidingActionBarTexture1,
  }

  -- button textures that shall be set empty
  local normtextures = {
    ShapeshiftButton1, ShapeshiftButton2,
    ShapeshiftButton3, ShapeshiftButton4,
    ShapeshiftButton5, ShapeshiftButton6,
  }

  -- elements that shall be resized to 511px
  local resizes = {
    MainMenuBar, MainMenuExpBar, MainMenuBarMaxLevelBar,
    ReputationWatchBar, ReputationWatchStatusBar,
  }

  -- hide frames
  for id, frame in pairs(frames) do hide(frame) end

  -- clear textures
  for id, frame in pairs(textures) do hide(frame, 1) end
  for id, frame in pairs(normtextures) do hide(frame, 2) end

  -- resize actionbar
  for id, frame in pairs(resizes) do frame:SetWidth(511) end

  -- experience bar
  MainMenuXPBarTexture0:SetPoint("LEFT", MainMenuExpBar, "LEFT")
  MainMenuXPBarTexture1:SetPoint("RIGHT", MainMenuExpBar, "RIGHT")

  -- reputation bar
  ReputationWatchBar:SetPoint("BOTTOM", MainMenuExpBar, "TOP", 0, 0)
  ReputationWatchBarTexture0:SetPoint("LEFT", ReputationWatchBar, "LEFT")
  ReputationWatchBarTexture1:SetPoint("RIGHT", ReputationWatchBar, "RIGHT")

  -- move menubar texture background
  MainMenuMaxLevelBar0:SetPoint("LEFT", MainMenuBarArtFrame, "LEFT")
  MainMenuBarTexture0:SetPoint("LEFT", MainMenuBarArtFrame, "LEFT")
  MainMenuBarTexture1:SetPoint("RIGHT", MainMenuBarArtFrame, "RIGHT")

  -- move gryphon textures
  MainMenuBarLeftEndCap:SetPoint("RIGHT", MainMenuBarArtFrame, "LEFT", 30, 0)
  MainMenuBarRightEndCap:SetPoint("LEFT", MainMenuBarArtFrame, "RIGHT", -30, 0)

  -- move MultiBarBottomRight ontop of MultiBarBottomLeft
  MultiBarBottomRight:ClearAllPoints()
  MultiBarBottomRight:SetPoint("BOTTOM", MultiBarBottomLeft, "TOP", 0, 5)

  -- reload custom frame positions after original frame manage runs
  local hookUIParent_ManageFramePositions = UIParent_ManageFramePositions
  UIParent_ManageFramePositions = function(a1, a2, a3)
    -- run original function
    hookUIParent_ManageFramePositions(a1, a2, a3)

    -- move top actionbar if xp or reputation is tracked
    MultiBarBottomLeft:ClearAllPoints()
    if MainMenuExpBar:IsVisible() or ReputationWatchBar:IsVisible() then
      local anchor = GetWatchedFactionInfo() and ReputationWatchBar or MainMenuExpBar
      MultiBarBottomLeft:SetPoint("BOTTOM", anchor, "TOP", 0, 3)
    else
      MultiBarBottomLeft:SetPoint("BOTTOM", MainMenuBar, "TOP", 0, -3)
    end

    -- move pet actionbar above other actionbars
    PetActionBarFrame:ClearAllPoints()
    local anchor = MainMenuBarArtFrame
    anchor = MultiBarBottomLeft:IsVisible() and MultiBarBottomLeft or anchor
    anchor = MultiBarBottomRight:IsVisible() and MultiBarBottomRight or anchor
    PetActionBarFrame:SetPoint("BOTTOM", anchor, "TOP", 0, 3)

    -- ShapeshiftBarFrame
    ShapeshiftBarFrame:ClearAllPoints()
    local offset = 0
    local anchor = ActionButton1
    anchor = MultiBarBottomLeft:IsVisible() and MultiBarBottomLeft or anchor
    anchor = MultiBarBottomRight:IsVisible() and MultiBarBottomRight or anchor

    offset = anchor == ActionButton1 and ( MainMenuExpBar:IsVisible() or ReputationWatchBar:IsVisible() ) and 6 or 0
    offset = anchor == ActionButton1 and offset + 6 or offset
    ShapeshiftBarFrame:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 8, 2 + offset)

    -- move castbar ontop of other bars
    local anchor = MainMenuBarArtFrame
    anchor = MultiBarBottomLeft:IsVisible() and MultiBarBottomLeft or anchor
    anchor = MultiBarBottomRight:IsVisible() and MultiBarBottomRight or anchor
    local pet_offset = PetActionBarFrame:IsVisible() and 40 or 0
    CastingBarFrame:SetPoint("BOTTOM", anchor, "TOP", 0, 10 + pet_offset)
  end

  -- enable picking up/replacing bags by clicking on the container frame portrait
  for i = 1, 5 do
    _G["ContainerFrame" .. i .. "PortraitButton"]:SetScript("OnClick", ReplaceBag)
  end
end
