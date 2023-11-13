local _G = ShaguTweaks.GetGlobalEnv()

local module = ShaguTweaks:register({
  title = "MiniMap Clock - 12h Server Time",
  description = "Adds a small 12h clock to the MiniMap showing Server Time.",
  expansions = { ["vanilla"] = true, ["tbc"] = nil },
  category = "World & MiniMap",
  enabled = nil,
})

MinimapClock = CreateFrame("Frame", "Clock", Minimap)
MinimapClock:Hide()
MinimapClock:SetFrameLevel(64)
MinimapClock:SetPoint("BOTTOM", MinimapCluster, "BOTTOM", 8, 18)
MinimapClock:SetWidth(70)
MinimapClock:SetHeight(23)
MinimapClock:SetBackdrop({
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true, tileSize = 8, edgeSize = 16,
  insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
MinimapClock:SetBackdropBorderColor(.9,.8,.5,1)
MinimapClock:SetBackdropColor(.4,.4,.4,1)

module.enable = function(self)
  MinimapClock:Show()
  MinimapClock:EnableMouse(true)

  MinimapClock.text = MinimapClock:CreateFontString("Status", "LOW", "GameFontNormal")
  MinimapClock.text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
  MinimapClock.text:SetAllPoints(MinimapClock)
  MinimapClock.text:SetFontObject(GameFontWhite)

  MinimapClock:SetScript("OnUpdate", function()
    -- Set MiniMap Clock to ServerTime
    local h, m = GetGameTime()
    local ampm = h >= 12 and " PM" or " AM"
    h = (math.mod(h, 12) == 0) and 12 or math.mod(h, 12)
    -- Convert the hour to a string without leading zeros
    local hStr = tostring(h)
    local servertime = hStr .. ":" .. string.format("%02d%s", m, ampm)
    this.text:SetText(servertime)
  end)

  MinimapClock:SetScript("OnEnter", function()
    local h, m = GetGameTime()
    local ampm = h >= 12 and " PM" or " AM"
    h = (math.mod(h,12) == 0) and 12 or math.mod(h,12)
    -- Convert the hour to a string without leading zeros
    local hStr = tostring(h)
    local servertime = hStr .. ":" .. string.format("%02d%s", m, ampm)

    -- Calculate local time without leading zeros
    local localH = tonumber(date("%I"))
    local localHStr = localH < 10 and " " .. tostring(localH) or tostring(localH)
    local localtime = localHStr .. ":" .. string.format("%02d%s", m, ampm)    

    GameTooltip:ClearLines()
    GameTooltip:SetOwner(this, ANCHOR_BOTTOMLEFT)

    GameTooltip:AddLine("Clock")
    GameTooltip:AddDoubleLine("Localtime", localtime, 1, 1, 1, 1, 1, 1)
    GameTooltip:AddDoubleLine("Servertime", servertime, 1, 1, 1, 1, 1, 1)
    GameTooltip:Show()
  end)


  MinimapClock:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)
end