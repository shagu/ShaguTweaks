local _G = ShaguTweaks.GetGlobalEnv()
local L, T = ShaguTweaks.L, ShaguTweaks.T

local module = ShaguTweaks:register({
    title = T["Free Slots Count"],
    description = T["Adds a free slots count to the backpack button. The top right count shows free class bag slots, the bottom left count shows free reagent bag slots and the bottom right count shows the remaining free bag slots."],
    expansions = { ["vanilla"] = true, ["tbc"] = nil },
    category = T["Tooltip & Items"],
    enabled = nil,
})

module.enable = function(self)
    local button = MainMenuBarBackpackButton

    button.class = button:CreateFontString("Status", "LOW", "GameFontNormal")
    button.class:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
    button.class:SetPoint("TOPRIGHT", button, "TOPRIGHT", -2, -4)
    button.class:SetJustifyH("RIGHT")
    button.class:SetFontObject(GameFontWhite)

    local _, class = UnitClass("player")
    local class = RAID_CLASS_COLORS[class] or { r = .5, g = .5, b = .5, a = 1 }
    button.class:SetTextColor(class.r, class.g, class.b)

    button.reagent = button:CreateFontString("Status", "LOW", "GameFontNormal")
    button.reagent:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
    button.reagent:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 2, 4)
    button.reagent:SetJustifyH("LEFT")
    button.reagent:SetFontObject(GameFontWhite)
    button.reagent:SetTextColor(.25, .78, .92)

    button.count = button:CreateFontString("Status", "LOW", "GameFontNormal")
    button.count:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
    button.count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 4)
    button.count:SetJustifyH("RIGHT")
    button.count:SetFontObject(GameFontWhite)

    -- class
    local soul = { "Core Felcloth Bag", "D'Sak's Small bag", "Felcloth Bag", "Box of Souls", "Small Soul Pouch", "Soul Pouch" }
    local quiver = { "Ancient Sinew Wrapped Lamina", "Harpy Hide Quiver", "Heavy Quiver", "Quickdraw Quiver", "Quiver of the Night Watch", "Ribbly's Quiver", "Hunting Quiver", "Light Leather Quiver", "Light Quiver", "Medium Quiver", "Small Quiver" }
    local pouch = { "Gnoll Skin Bandolier", "Bandolier of the Night Watch", "Heavy Leather Ammo Pouch", "Ribbly's Bandolier", "Thick Leather Ammo Pouch", "Hunting Ammo Sack", "Medium Shot Pouch", "Small Ammo Pouch", "Small Leather Ammo Pouch", "Small Shot Pouch" }
    -- reagent
    local herb = { "Cenarion Herb Bag", "Herb Pouch", "Satchel of Cenarius" }
    local ench = { "Big Bag of Enchantment", "Enchanted Mageweave Pouch", "Enchanted Runecloth Bag" }

    local freeClass = 0
    local freeReagent = 0

    local function classSlots()
        local function findName(name, names)
            for _, bagName in ipairs(names) do
                if string.find(name, bagName) then
                    return true
                end
            end
            return false
        end

        local found
        local free = 0
        for i = 0, 4 do
            local name = GetBagName(i)
            if name and (findName(name, soul) or findName(name, quiver) or findName(name, pouch)) then
                found = true
                for slot = 1, GetContainerNumSlots(i) do
                    local link = GetContainerItemLink(i, slot)
                    if not (link) then
                        free = free + 1
                    end
                end
            end
        end

        freeClass = free

        if found then
            button.class:SetText(free)
        else
            button.class:SetText("")
        end
    end
    classSlots()

    local function reagentSlots()
        local function findName(name, names)
            for _, bagName in ipairs(names) do
                if string.find(name, bagName) then
                    return true
                end
            end
            return false
        end

        local found
        local free = 0
        for i = 0, 4 do
            local name = GetBagName(i)
            if name and (findName(name, herb) or findName(name, ench)) then
                found = true
                for slot = 1, GetContainerNumSlots(i) do
                    local link = GetContainerItemLink(i, slot)
                    if not (link) then
                        free = free + 1
                    end
                end
            end
        end

        freeReagent = free

        if found then
            button.reagent:SetText(free)
        else
            button.reagent:SetText("")
        end
    end
    reagentSlots()


    local function freeSlots()
        local free = 0
        for i = 0, 4 do
            for slot = 1, GetContainerNumSlots(i) do
                local link = GetContainerItemLink(i, slot)
				if not (link) then
					free = free + 1
				end
            end
        end
        button.count:SetText(free-freeClass-freeReagent)
    end
    freeSlots()

    local events = CreateFrame("Frame")
    events:RegisterEvent("BAG_UPDATE")

    events:SetScript("OnEvent", function()
        classSlots()
        reagentSlots()
        freeSlots()
    end)
end