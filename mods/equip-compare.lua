local _G = ShaguTweaks.GetGlobalEnv()
local T = ShaguTweaks.T

local module = ShaguTweaks:register({
  title = T["Equip Compare"],
  description = T["Shows currently equipped items on tooltips while the shift key is pressed."],
  expansions = { ["vanilla"] = true, ["tbc"] = nil },
  category = T["Tooltip & Items"],
  enabled = true,
})

module.enable = function()
  local lastSearchName
  local lastSearchID

  local function GetItemIDByName(name)
    if not name then return nil end
    if name ~= lastSearchName then
      for itemID = 1, 99999 do
        local itemName = GetItemInfo(itemID)
        if (itemName and itemName == name) then
          lastSearchID = itemID
          break
        end
      end
      lastSearchName = name
    end
    return lastSearchID
  end

  local function HookTooltip(tooltip)
    local original_SetLootRollItem    = tooltip.SetLootRollItem
    local original_SetLootItem        = tooltip.SetLootItem
    local original_SetMerchantItem    = tooltip.SetMerchantItem
    local original_SetQuestLogItem    = tooltip.SetQuestLogItem
    local original_SetQuestItem       = tooltip.SetQuestItem
    local original_SetHyperlink       = tooltip.SetHyperlink
    local original_SetBagItem         = tooltip.SetBagItem
    local original_SetInboxItem       = tooltip.SetInboxItem
    local original_SetInventoryItem   = tooltip.SetInventoryItem
    local original_SetCraftItem       = tooltip.SetCraftItem
    local original_SetCraftSpell      = tooltip.SetCraftSpell
    local original_SetTradeSkillItem  = tooltip.SetTradeSkillItem
    local original_SetAuctionItem     = tooltip.SetAuctionItem
    local original_SetAuctionSellItem = tooltip.SetAuctionSellItem
    local original_SetTradePlayerItem = tooltip.SetTradePlayerItem
    local original_SetTradeTargetItem = tooltip.SetTradeTargetItem

    local original_OnHide = tooltip:GetScript("OnHide")

    tooltip:SetScript("OnHide", function()
      if original_OnHide then original_OnHide() end
      this.itemID = nil
    end)

    function tooltip.SetLootRollItem(self, rollID)
      original_SetLootRollItem(self, rollID)
      local _, _, id = strfind(GetLootRollItemLink(rollID) or "", "item:(%d+)")
      self.itemID = tonumber(id)
    end

    function tooltip.SetLootItem(self, slot)
      original_SetLootItem(self, slot)
      local _, _, id = strfind(GetLootSlotLink(slot) or "", "item:(%d+)")
      self.itemID = tonumber(id)
    end

    function tooltip.SetMerchantItem(self, merchantIndex)
      original_SetMerchantItem(self, merchantIndex)
      local _, _, id = strfind(GetMerchantItemLink(merchantIndex) or "", "item:(%d+)")
      self.itemID = tonumber(id)
    end

    function tooltip.SetQuestLogItem(self, itemType, index)
      original_SetQuestLogItem(self, itemType, index)
      local _, _, id = strfind(GetQuestLogItemLink(itemType, index) or "", "item:(%d+)")
      self.itemID = tonumber(id)
    end

    function tooltip.SetQuestItem(self, itemType, index)
      original_SetQuestItem(self, itemType, index)
      local _, _, id = strfind(GetQuestItemLink(itemType, index) or "", "item:(%d+)")
      self.itemID = tonumber(id)
    end

    function tooltip.SetHyperlink(self, arg1)
      original_SetHyperlink(self, arg1)
      local _, _, id = strfind(arg1 or "", "item:(%d+)")
      self.itemID = tonumber(id)
    end

    function tooltip.SetBagItem(self, container, slot)
      local hasCooldown, repairCost = original_SetBagItem(self, container, slot)
      local _, _, id = strfind(GetContainerItemLink(container, slot) or "", "item:(%d+)")
      self.itemID = tonumber(id)
      return hasCooldown, repairCost
    end

    function tooltip.SetInboxItem(self, mailID, attachmentIndex)
      original_SetInboxItem(self, mailID, attachmentIndex)
      local itemName = GetInboxItem(mailID)
      self.itemID = GetItemIDByName(itemName)
    end

    function tooltip.SetInventoryItem(self, unit, slot)
      local hasItem, hasCooldown, repairCost = original_SetInventoryItem(self, unit, slot)
      local _, _, id = strfind(GetInventoryItemLink(unit, slot) or "", "item:(%d+)")
      self.itemID = tonumber(id)
      return hasItem, hasCooldown, repairCost
    end

    function tooltip.SetCraftItem(self, skill, slot)
      original_SetCraftItem(self, skill, slot)
      local _, _, id = strfind(GetCraftReagentItemLink(skill, slot) or "", "item:(%d+)")
      self.itemID = tonumber(id)
    end

    function tooltip.SetCraftSpell(self, slot)
      original_SetCraftSpell(self, slot)
      local _, _, id = strfind(GetCraftItemLink(slot) or "", "item:(%d+)")
      self.itemID = tonumber(id)
    end

    function tooltip.SetTradeSkillItem(self, skillIndex, reagentIndex)
      original_SetTradeSkillItem(self, skillIndex, reagentIndex)
      if reagentIndex then
        local _, _, id = strfind(GetTradeSkillReagentItemLink(skillIndex, reagentIndex) or "", "item:(%d+)")
        self.itemID = tonumber(id)
      else
        local _, _, id = strfind(GetTradeSkillItemLink(skillIndex) or "", "item:(%d+)")
        self.itemID = tonumber(id)
      end
    end

    function tooltip.SetAuctionItem(self, atype, index)
      original_SetAuctionItem(self, atype, index)
      local itemName = GetAuctionItemInfo(atype, index)
      self.itemID = GetItemIDByName(itemName)
    end

    function tooltip.SetAuctionSellItem(self)
      original_SetAuctionSellItem(self)
      local itemName = GetAuctionSellItemInfo()
      self.itemID = GetItemIDByName(itemName)
    end

    function tooltip.SetTradePlayerItem(self, index)
      original_SetTradePlayerItem(self, index)
      local _, _, id = strfind(GetTradePlayerItemLink(index) or "", "item:(%d+)")
      self.itemID = tonumber(id)
    end

    function tooltip.SetTradeTargetItem(self, index)
      original_SetTradeTargetItem(self, index)
      local _, _, id = strfind(GetTradeTargetItemLink(index) or "", "item:(%d+)")
      self.itemID = tonumber(id)
    end
  end

  local lines = {}
  for i = 1, 30 do
    lines[i] = {}
  end
  local function AddHeader(tooltip)
    local name = tooltip:GetName()
    for i in pairs(lines) do
      for j in pairs(lines[i]) do
        lines[i][j] = nil
      end
    end
    for i = 1, tooltip:NumLines() do
      local leftText = _G[name.."TextLeft"..i]:GetText()
      local rightText = _G[name.."TextRight"..i]:IsShown() and _G[name.."TextRight"..i]:GetText()
      local rL, gL, bL = _G[name.."TextLeft"..i]:GetTextColor()
      local rR, gR, bR = _G[name.."TextRight"..i]:GetTextColor()
      lines[i][1], lines[i][2], lines[i][3], lines[i][4], lines[i][5], lines[i][6], lines[i][7], lines[i][8] = leftText, rightText, rL, gL, bL, rR, gR, bR
    end

    tooltip:SetText(CURRENTLY_EQUIPPED, .5, .5, .5, 1, true)
    for _, line in ipairs(lines) do
      if line[2] then
        tooltip:AddDoubleLine(line[1], line[2], line[3], line[4], line[5], line[6], line[7], line[8])
      else
        tooltip:AddLine(line[1], line[3], line[4], line[5], true)
      end
    end
    for i = 1, getn(lines) do
      if _G[name.."TextLeft"..i] then
        _G[name.."TextLeft"..i]:SetJustifyH("LEFT")
      end
      if _G[name.."TextRight"..i] then
        _G[name.."TextRight"..i]:SetJustifyH("LEFT")
      end
    end

    -- update tooltip sizes
    tooltip:Show()
  end

  local invtype_to_index = {
    INVTYPE_AMMO = {0},
    INVTYPE_HEAD = {1},
    INVTYPE_NECK = {2},
    INVTYPE_SHOULDER = {3},
    INVTYPE_BODY = {4},
    INVTYPE_CHEST = {5},
    INVTYPE_ROBE = {5},
    INVTYPE_WAIST = {6},
    INVTYPE_LEGS = {7},
    INVTYPE_FEET = {8},
    INVTYPE_WRIST = {9},
    INVTYPE_HAND = {10},
    INVTYPE_FINGER = {11, 12},
    INVTYPE_TRINKET = {13, 14},
    INVTYPE_CLOAK = {15},
    INVTYPE_2HWEAPON = {16, 17},
    INVTYPE_WEAPONMAINHAND = {16, 17},
    INVTYPE_WEAPON = {16, 17},
    INVTYPE_WEAPONOFFHAND = {16, 17},
    INVTYPE_HOLDABLE = {16, 17},
    INVTYPE_SHIELD = {16, 17},
    INVTYPE_RANGED = {18},
    INVTYPE_RANGEDRIGHT = {18},
    INVTYPE_TABARD = {19},
  }

  local function SlotIndex(invtype)
    if not invtype_to_index[invtype] then
      return
    end
    return unpack(invtype_to_index[invtype])
  end

  ShoppingTooltip1:SetClampedToScreen(true)
  ShoppingTooltip2:SetClampedToScreen(true)

  local function ShowCompare(tooltip)
    -- abort if shift is not pressed
    if not IsShiftKeyDown() then
      ShoppingTooltip1:Hide()
      ShoppingTooltip2:Hide()
      return
    end

    if not tooltip.itemID then return end

    local itemName, itemLink, itemQuality, itemLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemTexture = GetItemInfo(tooltip.itemID)
    local index1, index2 = SlotIndex(itemEquipLoc)

    if not index1 then return end

    -- determine screen part
    local x = GetCursorPosition() / UIParent:GetEffectiveScale()
    local anchor = x < GetScreenWidth() / 2 and "TOPLEFT" or "TOPRIGHT"
    local relative = x < GetScreenWidth() / 2 and "TOPRIGHT" or "TOPLEFT"

    -- overwrite position for tooltips without owner
    local pos, parent = tooltip:GetPoint()
    if parent and parent == UIParent and pos == "TOPRIGHT" then
      anchor = "TOPRIGHT"
      relative = "TOPLEFT"
    end

    -- first tooltip
    ShoppingTooltip1:SetOwner(tooltip, "ANCHOR_NONE")
    ShoppingTooltip1:ClearAllPoints()
    ShoppingTooltip1:SetPoint(anchor, tooltip, relative, 0, 0)
    ShoppingTooltip1:SetInventoryItem("player", index1)
    ShoppingTooltip1:Show()
    AddHeader(ShoppingTooltip1)

    -- second tooltip
    if index2 and GetInventoryItemLink("player", index2) then
      ShoppingTooltip2:SetOwner(tooltip, "ANCHOR_NONE")
      ShoppingTooltip2:ClearAllPoints()
      if ShoppingTooltip1:IsShown() then
        ShoppingTooltip2:SetPoint(anchor, ShoppingTooltip1, relative, 0, 0)
      else
        ShoppingTooltip2:SetPoint(anchor, tooltip, relative, 0, 0)
      end
      ShoppingTooltip2:SetInventoryItem("player", index2)
      ShoppingTooltip2:Show()
      AddHeader(ShoppingTooltip2)
    end
  end

  -- show item compare on default tooltips
  HookTooltip(GameTooltip)
  local default = CreateFrame("Frame", nil, GameTooltip)
  default:SetScript("OnUpdate", function()
    ShowCompare(GameTooltip)
  end)

  -- show compare on atlas tooltips
  ShaguTweaks.HookAddonOrVariable("AtlasLoot", function()
    HookTooltip(AtlasLootTooltip)
    HookTooltip(AtlasLootTooltip2)
    local atlas = CreateFrame("Frame", nil, AtlasLootTooltip)
    atlas:SetScript("OnUpdate", function()
      ShowCompare(AtlasLootTooltip)
      ShowCompare(AtlasLootTooltip2)
    end)
  end)
end
