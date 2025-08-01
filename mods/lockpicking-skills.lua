local _G = ShaguTweaks.GetGlobalEnv()
local L, T = ShaguTweaks.L, ShaguTweaks.T
local GetExpansion = ShaguTweaks.GetExpansion
local hooksecurefunc = ShaguTweaks.hooksecurefunc
local GetItemIDFromLink = ShaguTweaks.GetItemIDFromLink
local GetItemLinkByName = ShaguTweaks.GetItemLinkByName

local module = ShaguTweaks:register({
    title = T["Lockbox and Key skills"],
    description = T["Adds the Lockpicking skill required to unlock a lockbox on the tooltip. Blacksmithing keys show what level they can unlock."],
    expansions = { ["vanilla"] = true, ["tbc"] = true },
    category = T["Tooltip & Items"],
    enabled = true,
})

local requirePickPocketSkill = {
    -- Drops
    [4632]  = 1,   -- Ornate Bronze Lockbox
    [4633]  = 25,  -- Heavy Bronze Lockbox
    [4634]  = 70,  -- Iron Lockbox
    [4636]  = 125, -- Strong Iron Lockbox
    [4637]  = 175, -- Steel Lockbox
    [4638]  = 225, -- Reinforced Steel Lockbox
    [5758]  = 225, -- Mithril Lockbox
    [5759]  = 225, -- Thorium Lockbox
    [5760]  = 225, -- Eternium Lockbox
    [31952] = 325, -- Khorium Lockbox - TBC
    -- Fishing
    [6354]  = 1,   -- Small Locked Chest
    [6355]  = 70,  -- Sturdy Locked Chest
    [13875] = 175, -- Ironbound Locked Chest
    [13918] = 250, -- Reinforced Locked Chest
    -- Engineering
    [6712]  = 1    -- Practice Lock
}

local canOpenPickPocketSkill = {
    -- Blacksmithing
    [15869] = 25,  -- Silver Skeleton Key
    [15870] = 125, -- Gold Skeleton Key
    [15871] = 200, -- Truesilver Skeleton Key
    [15872] = 300, -- Arcanite Skeleton Key
}

-- In TBC Seaforium charge can open chests in addition to doors.
local tbcSeaforiumCharge = {
    [4367]  = 150, -- Small Seaforium Charge
    [4398]  = 250, -- Large Seaforium Charge
    [18594] = 300, -- Powerful Seaforium Charge
    [23819] = 350, -- Elemental Seaforium Charge
}

if GetExpansion() == "tbc" then
    for k,v in pairs(tbcSeaforiumCharge) do
        canOpenPickPocketSkill[k] = v
    end
end

local function AddLockPickingSkill(frame, itemLink)
    if not frame then return end

    local itemID = GetItemIDFromLink(itemLink)
    if not itemID then return end

    if not requirePickPocketSkill[itemID] and not canOpenPickPocketSkill[itemID] then
        return
    end

    local lineString
    if requirePickPocketSkill[itemID] then
        lineString = string.format("Requires Lockpicking (%d)", requirePickPocketSkill[itemID])
    end

    if canOpenPickPocketSkill[itemID] then
        lineString = string.format("Opens lock up to (%d) lockpicking skill", canOpenPickPocketSkill[itemID])
    end

    local moneyFrame = _G[frame:GetName().."MoneyFrame"]
    local isMoneyShownOnTooltip = MerchantFrame:IsVisible()
            or moneyFrame and moneyFrame.staticMoney > 0 and moneyFrame.staticMoney ~= GetMoney()

    -- Ensure line is added above the money line
    if isMoneyShownOnTooltip then
        moneyFrame:Hide()
        for i = frame:NumLines(), 1, -1 do
            local line = _G[frame:GetName().."TextLeft"..i]
            if line:GetText() == " " then -- the money line
                line:SetText(lineString) -- use money line to hold text
                break
            end
        end
        SetTooltipMoney(frame, moneyFrame.staticMoney) -- add the money one line down
    else
        frame:AddLine(lineString, 1.0, 1.0, 1.0)
    end

    frame:Show()
end

module.enable = function(self)
    -- Hook item links tooltip
    hooksecurefunc("ChatFrame_OnHyperlinkShow", function(link, text, button)
        AddLockPickingSkill(ItemRefTooltip, link)
    end)

    -- Hook loot tooltip
    hooksecurefunc(GameTooltip, "SetLootItem", function(tip, lootIndex)
        AddLockPickingSkill(GameTooltip, GetLootSlotLink(lootIndex))
    end)

    -- Hook group loot roll tooltip
    hooksecurefunc(GameTooltip, "SetLootRollItem", function(tip, id)
        AddLockPickingSkill(GameTooltip, GetLootRollItemLink(id))
    end)

    -- Hook bag tooltip
    hooksecurefunc(GameTooltip, "SetBagItem", function(tip, bag, slot)
        AddLockPickingSkill(GameTooltip, GetContainerItemLink(bag, slot))
    end)

    -- Hook bank tooltip
    hooksecurefunc(GameTooltip, "SetInventoryItem", function(tip, unit, slot)
        AddLockPickingSkill(GameTooltip, GetInventoryItemLink(unit, slot))
    end)

    -- Hook hyper links, used for BankItems and Bagnon_Forever addons
    hooksecurefunc(GameTooltip, "SetHyperlink", function(tip, link, count)
        AddLockPickingSkill(GameTooltip, link)
    end)

    -- Hook quest reward tooltip
    hooksecurefunc(GameTooltip, "SetQuestItem", function(tip, qtype, slot)
        AddLockPickingSkill(GameTooltip, GetQuestItemLink(qtype, slot))
    end)

    -- Hook questlog reward tooltip
    hooksecurefunc(GameTooltip, "SetQuestLogItem", function(tip, qtype, slot)
        AddLockPickingSkill(GameTooltip, GetQuestLogItemLink(qtype, slot))
    end)

    -- Hook trade skill tooltip
    hooksecurefunc(GameTooltip, "SetTradeSkillItem", function(tip, tradeItemIndex, reagentIndex)
        if reagentIndex then
            return AddLockPickingSkill(GameTooltip, GetTradeSkillReagentItemLink(tradeItemIndex, reagentIndex))
        end

        AddLockPickingSkill(GameTooltip, GetTradeSkillItemLink(tradeItemIndex))
    end)

    -- Hook player trade tooltip
    hooksecurefunc(GameTooltip, "SetTradePlayerItem", function(self, index)
        AddLockPickingSkill(GameTooltip, GetTradePlayerItemLink(index))
    end)

    -- Hook target trade tooltip
    hooksecurefunc(GameTooltip, "SetTradeTargetItem", function(self, index)
        AddLockPickingSkill(GameTooltip, GetTradeTargetItemLink(index))
    end)

    -- Hook inbox items
    hooksecurefunc(GameTooltip, "SetInboxItem", function(self, mailIndex, attachmentIndex)
        if GetInboxItemLink then
            return AddLockPickingSkill(GameTooltip, GetInboxItemLink(mailIndex, attachmentIndex))
        end

        local itemName = GetInboxItem(mailIndex, attachmentIndex)
        AddLockPickingSkill(GameTooltip, GetItemLinkByName(itemName))
    end)

    -- Hook send mail items
    hooksecurefunc(GameTooltip, "SetSendMailItem", function(self, attachmentIndex)
        if GetSendMailItemLink then
            return AddLockPickingSkill(GameTooltip, GetSendMailItemLink(attachmentIndex))
        end

        local itemName = GetSendMailItem(attachmentIndex)
        AddLockPickingSkill(GameTooltip, GetItemLinkByName(itemName))
    end)
end
