local _G = ShaguTweaks.GetGlobalEnv()
local T = ShaguTweaks.T

local module = ShaguTweaks:register({
  title = T["Equip Compare"],
  description = T["Shows currently equipped items on tooltips while the shift key is pressed."],
  expansions = { ["vanilla"] = true, ["tbc"] = nil },
  category = T["Tooltip & Items"],
  enabled = true,
})

module.enable = function(self)
  local itemtypes = {
    ["deDE"] = {
      ["INVTYPE_WAND"] = "Zauberstab",
      ["INVTYPE_THROWN"] = "Wurfwaffe",
      ["INVTYPE_GUN"] = "Schusswaffe",
      ["INVTYPE_CROSSBOW"] = "Armbrust",
      ["INVTYPE_PROJECTILE"] = "Projektil",
    },
    ["enUS"] = {
      ["INVTYPE_WAND"] = "Wand",
      ["INVTYPE_THROWN"] = "Thrown",
      ["INVTYPE_GUN"] = "Gun",
      ["INVTYPE_CROSSBOW"] = "Crossbow",
      ["INVTYPE_PROJECTILE"] = "Projectile",
    },
    ["esES"] = {
      ["INVTYPE_WAND"] = "Varita",
      ["INVTYPE_THROWN"] = "Arma arrojadiza",
      ["INVTYPE_GUN"] = "Arma de fuego",
      ["INVTYPE_CROSSBOW"] = "Ballesta",
      ["INVTYPE_PROJECTILE"] = "Proyectil",
    },
    ["frFR"] = {
      ["INVTYPE_WAND"] = "Baguette",
      ["INVTYPE_THROWN"] = "Armes de jet",
      ["INVTYPE_GUN"] = "Arme à feu",
      ["INVTYPE_CROSSBOW"] = "Arbalète",
      ["INVTYPE_PROJECTILE"] = "Projectile",
    },
    ["koKR"] = {
      ["INVTYPE_WAND"] = "마법봉",
      ["INVTYPE_THROWN"] = "투척 무기",
      ["INVTYPE_GUN"] = "총",
      ["INVTYPE_CROSSBOW"] = "석궁",
      ["INVTYPE_PROJECTILE"] = "투사체",
    },
    ["ruRU"] = {
      ["INVTYPE_WAND"] = "Жезл",
      ["INVTYPE_THROWN"] = "Метательное",
      ["INVTYPE_GUN"] = "Огнестрельное",
      ["INVTYPE_CROSSBOW"] = "Арбалет",
      ["INVTYPE_PROJECTILE"] = "Боеприпасы",
    },
    ["zhCN"] = {
      ["INVTYPE_WAND"] = "魔杖",
      ["INVTYPE_THROWN"] = "投掷武器",
      ["INVTYPE_GUN"] = "枪械",
      ["INVTYPE_CROSSBOW"] = "弩",
      ["INVTYPE_PROJECTILE"] = "弹药",
    }
   }

  -- set globals for all inventory types
  for key, value in pairs(itemtypes[GetLocale()]) do setglobal(key, value) end
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

  local function ShowCompare(tooltip)
    -- abort if shift is not pressed
    if not IsShiftKeyDown() then
      ShoppingTooltip1:Hide()
      ShoppingTooltip2:Hide()
      return
    end

    for i=1,tooltip:NumLines() do
      local tmpText = _G[tooltip:GetName() .. "TextLeft"..i]

      for slotType, slotName in pairs(slots) do
        if tmpText:GetText() == slotType then
          local slotID = GetInventorySlotInfo(slotName)

          -- determine screen part
          local x = GetCursorPosition() / UIParent:GetEffectiveScale()
          local anchor = x < GetScreenWidth() / 2 and "BOTTOMLEFT" or "BOTTOMRIGHT"
          local relative = x < GetScreenWidth() / 2 and "BOTTOMRIGHT" or "BOTTOMLEFT"

          -- overwrite position for tooltips without owner
          local pos, parent = tooltip:GetPoint()
          if parent and parent == UIParent and pos == "BOTTOMRIGHT" then
            anchor = "BOTTOMRIGHT"
            relative = "BOTTOMLEFT"
          end

          -- first tooltip
          ShoppingTooltip1:SetOwner(tooltip, "ANCHOR_NONE");
          ShoppingTooltip1:ClearAllPoints();
          ShoppingTooltip1:SetPoint(anchor, tooltip, relative, 0, 0);
          ShoppingTooltip1:SetInventoryItem("player", slotID)
          ShoppingTooltip1:Show()

          -- second tooltip
          if slots[slotType .. "_other"] then
            local slotID_other = GetInventorySlotInfo(slots[slotType .. "_other"])
            ShoppingTooltip2:SetOwner(tooltip, "ANCHOR_NONE");
            ShoppingTooltip2:ClearAllPoints();
            ShoppingTooltip2:SetPoint(anchor, ShoppingTooltip1, relative, 0, 0);
            ShoppingTooltip2:SetInventoryItem("player", slotID_other)
            ShoppingTooltip2:Show();
          end
        end
      end
    end
  end

  -- show item compare on default tooltips
  local default = CreateFrame("Frame", nil, GameTooltip)
  default:SetScript("OnUpdate", function()
    ShowCompare(GameTooltip)
  end)

  -- show compare on atlas tooltips
  ShaguTweaks.HookAddonOrVariable("AtlasLoot", function()
    local atlas = CreateFrame("Frame", nil, AtlasLootTooltip)
    atlas:SetScript("OnUpdate", function()
      ShowCompare(AtlasLootTooltip)
    end)
  end)
end
