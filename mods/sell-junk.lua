local _G = ShaguTweaks.GetGlobalEnv()
local T = ShaguTweaks.T

local module = ShaguTweaks:register({
  title = T["Sell Junk"],
  description = T["Adds a “Sell Junk” button to every merchant window, that sells all grey items."],
  expansions = { ["vanilla"] = true, ["tbc"] = true },
  category = T["Tooltip & Items"],
  enabled = true,
})

local processed = {}

local function CreateGoldString(money)
  if type(money) ~= "number" then return "-" end

  local gold = floor(money/ 100 / 100)
  local silver = floor(mod((money/100),100))
  local copper = floor(mod(money,100))

  local string = ""
  if gold > 0 then string = string .. "|cffffffff" .. gold .. "|cffffd700g" end
  if silver > 0 or gold > 0 then string = string .. "|cffffffff " .. silver .. "|cffc7c7cfs" end
  string = string .. "|cffffffff " .. copper .. "|cffeda55fc"

  return string
end

local function HasGreyItems()
  for bag = 0, 4, 1 do
    for slot = 1, GetContainerNumSlots(bag), 1 do
      local name = GetContainerItemLink(bag,slot)
      if name and string.find(name,"ff9d9d9d") then return true end
    end
  end
  return nil
end

local function GetNextGreyItem()
  for bag = 0, 4, 1 do
    for slot = 1, GetContainerNumSlots(bag), 1 do
      local name = GetContainerItemLink(bag,slot)
      if name and string.find(name,"ff9d9d9d") and not processed[bag.."x"..slot] then
        processed[bag.."x"..slot] = true
        return bag, slot
      end
    end
  end

  return nil, nil
end

module.enable = function(self)
  local autovendor = CreateFrame("Frame", nil, nil)
  autovendor:Hide()

  autovendor:SetScript("OnShow", function()
    processed = {}
    this.price = 0
    this.count = 0
  end)

  autovendor:SetScript("OnHide", function()
    if this.count > 0 then
      DEFAULT_CHAT_FRAME:AddMessage(T["Your vendor trash has been sold and you earned"] .. " " .. CreateGoldString(this.price))
    end
  end)

  autovendor:SetScript("OnUpdate", function()
    -- throttle to to one item per .1 second
    if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + .1 end

    -- scan for the next grey item
    local bag, slot = GetNextGreyItem()
    if not bag or not slot then
      this:Hide()
      return
    end

    -- double check to only sell grey
    local name = GetContainerItemLink(bag,slot)
    if not name or not string.find(name,"ff9d9d9d") then
      return
    end

    -- get value
    local _, icount = GetContainerItemInfo(bag, slot)
    local _, _, id = string.find(GetContainerItemLink(bag, slot), "item:(%d+):%d+:%d+:%d+")
    local price = ShaguTweaks.SellValueDB[tonumber(id)] or 0
    if this.price then
      this.price = this.price + ( price * ( icount or 1 ) )
      this.count = this.count + 1
    end

    -- abort if the merchant window disappeared
    if not this.merchant then return end

    -- clear cursor and sell the item
    ClearCursor()
    UseContainerItem(bag, slot)
  end)

  autovendor:RegisterEvent("MERCHANT_SHOW")
  autovendor:RegisterEvent("MERCHANT_CLOSED")
  autovendor:RegisterEvent("MERCHANT_UPDATE")
  autovendor:SetScript("OnEvent", function()
    autovendor.button:Update()

    if event == "MERCHANT_CLOSED" then
      autovendor.merchant = nil
      autovendor:Hide()
    elseif event == "MERCHANT_SHOW" then
      autovendor.merchant = true
      autovendor.button:Show()
    end

    MerchantRepairText:SetText("")
    if MerchantRepairItemButton:IsShown() then
      autovendor.button:ClearAllPoints()
      autovendor.button:SetPoint("RIGHT", MerchantRepairItemButton, "LEFT", -4, 0)
    else
      autovendor.button:ClearAllPoints()
      autovendor.button:SetPoint("RIGHT", MerchantBuyBackItemItemButton, "LEFT", -14, 0)
    end
  end)

  -- Setup Autosell button
  autovendor.button = CreateFrame("Button", nil, MerchantFrame)
  autovendor.button:SetWidth(36)
  autovendor.button:SetHeight(36)
  autovendor.button:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
  autovendor.button:SetNormalTexture("Interface\\Icons\\Spell_Shadow_SacrificialShield")
  autovendor.button:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
    GameTooltip:SetText(T["Sell Grey Items"])
    GameTooltip:Show()
  end)

  autovendor.button:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)

  autovendor.button:SetScript("OnClick", function()
    autovendor:Show()
  end)

  autovendor.button.Update = function()
    if not autovendor:IsVisible() then
      if HasGreyItems() then
        autovendor.button:Enable()
        autovendor.button:GetNormalTexture():SetDesaturated(false)
      else
        autovendor.button:Disable()
        autovendor.button:GetNormalTexture():SetDesaturated(true)
      end
    else
      autovendor.button:Disable()
      autovendor.button:GetNormalTexture():SetDesaturated(true)
    end
  end

  -- Hook MerchantFrame_Update
  if not HookMerchantFrame_Update then
    local HookMerchantFrame_Update = MerchantFrame_Update
    function _G.MerchantFrame_Update()
      if MerchantFrame.selectedTab == 1 then
        autovendor.button:Show()
      else
        autovendor.button:Hide()
      end
      HookMerchantFrame_Update()
    end
  end
end
