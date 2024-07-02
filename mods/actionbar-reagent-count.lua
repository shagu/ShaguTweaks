local _G = ShaguTweaks.GetGlobalEnv()
local T = ShaguTweaks.T

local module = ShaguTweaks:register({
    title = T["Reagent Count"],
    description = T["Show the reagent count on action buttons."],
    expansions = { ["vanilla"] = true, ["tbc"] = nil },
    category = T["Action Bar"],
    enabled = nil,
})

module.enable = function(self)
    -- [ GetItemCount ]
    -- Returns information about how many of a given item the player has.
    -- 'itemName'   [string]         name of the item
    -- returns:     [int]            the number of the given item
    local function GetItemCount(itemName)
        local count = 0
        for bag = 4, 0, -1 do
        for slot = 1, GetContainerNumSlots(bag) do
            local _, itemCount = GetContainerItemInfo(bag, slot)
            if itemCount then
            local itemLink = GetContainerItemLink(bag,slot)
            local _, _, itemParse = strfind(itemLink, "(%d+):")
            local queryName = GetItemInfo(itemParse)
            if queryName and queryName ~= "" then
                if queryName == itemName then
                count = count + itemCount
                end
            end
            end
        end
        end

        return count
    end

    local reagent_slots = { }
    local reagent_counts = { }
    local reagent_textureslots = { }
    local reagent_capture = SPELL_REAGENTS.."(.+)"
    local scanner = ShaguTweaks.libtipscan:GetScanner("actionbar")
    local reagentcounter = CreateFrame("Frame", "stReagentCounter", UIParent)
    reagentcounter:RegisterEvent("PLAYER_ENTERING_WORLD")
    reagentcounter:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
    reagentcounter:RegisterEvent("BAG_UPDATE")
    reagentcounter:SetScript("OnEvent", function()
        if event == "BAG_UPDATE" then
            this.event = true
        else
            for slot = 1, 120 do
                local texture = GetActionTexture(slot)

                -- update buttons that previously had an reagent
                if reagent_slots[slot] and not texture then
                reagent_textureslots[slot] = nil
                reagent_slots[slot] = nil
                -- updatecache[slot] = true
                end

                -- search for reagents on buttons with different icon
                if reagent_textureslots[slot] ~= texture then
                    if HasAction(slot) then
                        reagent_textureslots[slot] = texture
                        scanner:SetAction(slot)
                        local _, reagents = scanner:Find(reagent_capture)
                        if reagents then
                        reagent_slots[slot] = reagents
                        reagent_counts[reagents] = reagent_counts[reagents] or 0
                        -- updatecache[slot] = true
                        end
                    end
                end
            end
        end
    end)

    -- limit bag events to one per second
    reagentcounter:SetScript("OnUpdate", function()
        if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + 1 end

        if this.event then
            for item in pairs(reagent_counts) do
                reagent_counts[item] = GetItemCount(item)
            end
            -- for slot in pairs(reagent_slots) do
            --     updatecache[slot] = true
            -- end

            this.event = nil
            reagentcounter:updateCount()
        end
    end)

    local function IsReagentAction(slot)
        return reagent_slots[slot] and true or nil
    end

    local function GetReagentCount(slot)
        return reagent_counts[reagent_slots[slot]]
    end

    local actionBars = {'Action', 'BonusAction', 'MultiBarBottomLeft', 'MultiBarBottomRight', 'MultiBarLeft', 'MultiBarRight'}
    function reagentcounter:updateCount()
        for k, v in pairs(actionBars) do
            for i = 1, NUM_ACTIONBAR_BUTTONS do
                local button = _G[v..'Button'..i]
                local text = _G[button:GetName().."Count"]
                if IsReagentAction(ActionButton_GetPagedID(button)) then
                    text:SetText(GetReagentCount(ActionButton_GetPagedID(button)))
                end
            end
        end
    end

    local HookActionButton_UpdateCount = ActionButton_UpdateCount
    function ActionButton_UpdateCount()
        HookActionButton_UpdateCount()
        local text = _G[this:GetName().."Count"]
        if IsReagentAction(ActionButton_GetPagedID(this)) then
            text:SetText(GetReagentCount(ActionButton_GetPagedID(this)))
        end
    end
end