local _G = ShaguTweaks.GetGlobalEnv()
local T = ShaguTweaks.T
local L = ShaguTweaks.L

local module = ShaguTweaks:register({
    title = T["Equip Compare"],
    description = T["Shows currently equipped items on tooltips while the shift key is pressed."],
    expansions = { ["vanilla"] = true, ["tbc"] = nil },
    category = T["Tooltip & Items"],
    enabled = true,
})

module.enable = function(self)
    -- set globals for all inventory types
    for key, value in pairs(L["itemtypes"]) do setglobal(key, value) end
    INVTYPE_WEAPON_OTHER = INVTYPE_WEAPON.."_other";
    INVTYPE_FINGER_OTHER = INVTYPE_FINGER.."_other";
    INVTYPE_TRINKET_OTHER = INVTYPE_TRINKET.."_other";

    local slots = {
        [INVTYPE_2HWEAPON] = "MainHandSlot",
        [INVTYPE_BODY] = "ShirtSlot",
        [INVTYPE_CHEST] = "ChestSlot",
        [INVTYPE_CLOAK] = "BackSlot",
        [INVTYPE_FEET] = "FeetSlot",
        [INVTYPE_FINGER] = "Finger0Slot",
        [INVTYPE_FINGER_OTHER] = "Finger1Slot",
        [INVTYPE_HAND] = "HandsSlot",
        [INVTYPE_HEAD] = "HeadSlot",
        [INVTYPE_HOLDABLE] = "SecondaryHandSlot",
        [INVTYPE_LEGS] = "LegsSlot",
        [INVTYPE_NECK] = "NeckSlot",
        [INVTYPE_RANGED] = "RangedSlot",
        [INVTYPE_RELIC] = "RangedSlot",
        [INVTYPE_ROBE] = "ChestSlot",
        [INVTYPE_SHIELD] = "SecondaryHandSlot",
        [INVTYPE_SHOULDER] = "ShoulderSlot",
        [INVTYPE_TABARD] = "TabardSlot",
        [INVTYPE_TRINKET] = "Trinket0Slot",
        [INVTYPE_TRINKET_OTHER] = "Trinket1Slot",
        [INVTYPE_WAIST] = "WaistSlot",
        [INVTYPE_WEAPON] = "MainHandSlot",
        [INVTYPE_WEAPON_OTHER] = "SecondaryHandSlot",
        [INVTYPE_WEAPONMAINHAND] = "MainHandSlot",
        [INVTYPE_WEAPONOFFHAND] = "SecondaryHandSlot",
        [INVTYPE_WRIST] = "WristSlot",
        [INVTYPE_WAND] = "RangedSlot",
        [INVTYPE_GUN] = "RangedSlot",
        [INVTYPE_PROJECTILE] = "AmmoSlot",
        [INVTYPE_CROSSBOW] = "RangedSlot",
        [INVTYPE_THROWN] = "RangedSlot",
    }
    ShoppingTooltip1:SetClampedToScreen(true)
    ShoppingTooltip2:SetClampedToScreen(true)

    local function startsWith(str, start)
        return string.sub(str, 1, string.len(start)) == start
    end


    local function ExtractAttributes(tooltip)
        local name = tooltip:GetName()

        -- get the name/header of the last set comparison tooltip
        local comparetooltip = ShaguTweaks.eqcompare.tooltip:GetName()
        local iname = _G[comparetooltip .. "TextLeft1"] and _G[comparetooltip .. "TextLeft1"]:GetText()

        -- only run once per item
        if tooltip.pfCompLastName == iname then return end

        tooltip.pfCompData = {}
        tooltip.pfCompLastName = iname

        for i=1,30 do
            local widget = _G[name.."TextLeft"..i]
            if widget and widget:GetObjectType() == "FontString" then
                local text = widget:GetText()
                if text and not string.find(text, "-", 1, true) then
                    local start = 1
                    if startsWith(text, "\+") or startsWith(text, "\(") then start = 2 end

                    local space = string.find(text, " ", 1, true)
                    if space then
                        local value = tonumber(string.sub(text, start, space-1))
                        if value and text then
                            -- we've found an attr
                            local attr = string.sub(text, space, string.len(text))
                            tooltip.pfCompData[attr] = { value = tonumber(value), widget = widget }
                        end
                    end
                end
            end
        end
    end


    local function CompareAttributes(data, targetData)
        if not data then return end
      
        for attr,v in pairs(data) do
            if targetData then
                local target = targetData[attr]
                if target then
                    if v.value ~= target.value and v.widget:GetText() then
                        if v.value > target.value then
                            if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
                                v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. ShaguTweaks.round(v.value - target.value, 1) .. ")")
                            end
                        elseif not v.widget.compSet then
                            if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
                                v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. ShaguTweaks.round(target.value - v.value, 1) .. ")")
                            end
                        end
                        target.processed = true
                    else
                        target.processed = true
                    end
                else
                    -- this attribute doesnt exist in target
                    if v.widget and v.widget:GetText() then
                        if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
                            v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. v.value .. ")")
                        end
                    end
                end
            end
        end
      
        for _,target in pairs(targetData) do
            if target and not target.processed then
                -- we are an extra value
                local text = target.widget:GetText()
                if text and not strfind(text, "|cff88ff88") and not strfind(text, "|cffff8888") then
                    target.widget:SetText(text .. "|cff88ff88 (+" .. target.value .. ")")
                end
            end
        end
    end


    ShaguTweaks.eqcompare = {}
    ShaguTweaks.eqcompare.GameTooltipShow = function()
      ShaguTweaks.eqcompare.tooltip = this
        if not IsShiftKeyDown() then return end

        for i=1,this:NumLines() do
            local tmpText = _G[this:GetName() .. "TextLeft"..i]

            for slotType, slotName in pairs(slots) do
                if tmpText:GetText() == slotType then
                    local slotID = GetInventorySlotInfo(slotName)

                    -- determine screen part
                    local x = GetCursorPosition() / UIParent:GetEffectiveScale()
                    local anchor = x < GetScreenWidth() / 2 and "BOTTOMLEFT" or "BOTTOMRIGHT"
                    local relative = x < GetScreenWidth() / 2 and "BOTTOMRIGHT" or "BOTTOMLEFT"

                    -- overwrite position for tooltips without owner
                    local pos, parent = this:GetPoint()
                    if parent and parent == UIParent and pos == "BOTTOMRIGHT" then
                        anchor = "BOTTOMRIGHT"
                        relative = "BOTTOMLEFT"
                    end

                    -- first tooltip
                    ShoppingTooltip1:SetOwner(this, "ANCHOR_NONE");
                    ShoppingTooltip1:ClearAllPoints();
                    ShoppingTooltip1:SetPoint(anchor, this, relative, 0, 0);
                    ShoppingTooltip1:SetInventoryItem("player", slotID)
                    ShoppingTooltip1:Show()

                    -- second tooltip
                    if slots[slotType .. "_other"] then
                        local slotID_other = GetInventorySlotInfo(slots[slotType .. "_other"])
                        ShoppingTooltip2:SetOwner(this, "ANCHOR_NONE");
                        ShoppingTooltip2:ClearAllPoints();
                        ShoppingTooltip2:SetPoint(anchor, ShoppingTooltip1, relative, 0, 0);
                        ShoppingTooltip2:SetInventoryItem("player", slotID_other)
                        ShoppingTooltip2:Show();
                    end
                end
            end
        end
    end

    GameTooltip.HookScript = GameTooltip.HookScript or ShaguTweaks.HookScript
    ShoppingTooltip1.HookScript = ShoppingTooltip1.HookScript or ShaguTweaks.HookScript
    ShoppingTooltip2.HookScript = ShoppingTooltip2.HookScript or ShaguTweaks.HookScript

    ShaguTweaks.eqcompare.ShoppingTooltipShow = function()
        if not ShaguTweaks.eqcompare.tooltip then return end
        ExtractAttributes(this)
        ExtractAttributes(ShaguTweaks.eqcompare.tooltip)
        CompareAttributes(ShaguTweaks.eqcompare.tooltip.pfCompData, this.pfCompData)
    end

    GameTooltip:HookScript("OnShow", ShaguTweaks.eqcompare.GameTooltipShow)
    ShoppingTooltip1:HookScript("OnShow", ShaguTweaks.eqcompare.ShoppingTooltipShow)
    ShoppingTooltip2:HookScript("OnShow", ShaguTweaks.eqcompare.ShoppingTooltipShow)

    if AtlasLootTooltip then
        AtlasLootTooltip.HookScript = AtlasLootTooltip.HookScript or ShaguTweaks.HookScript
        AtlasLootTooltip2.HookScript = AtlasLootTooltip2.HookScript or ShaguTweaks.HookScript
        AtlasLootTooltip:HookScript("OnShow", ShaguTweaks.eqcompare.GameTooltipShow)
        AtlasLootTooltip2:HookScript("OnShow", ShaguTweaks.eqcompare.GameTooltipShow)
    end

end
