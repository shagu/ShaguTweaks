local T = ShaguTweaks.T

local module = ShaguTweaks:register({
  title = T["Unit Frame Energy & Mana Tick"],
  description = T["Adds an energy & mana tick to the player frame."],
  expansions = { ["vanilla"] = true, ["tbc"] = nil },
  category = T["Unit Frames"],
  enabled = nil,
})

module.enable = function(self)
  local energytick = CreateFrame("Frame", nil, PlayerFrameManaBar)
  energytick:SetAllPoints(PlayerFrameManaBar)
  energytick:RegisterEvent("PLAYER_ENTERING_WORLD")
  energytick:RegisterEvent("UNIT_DISPLAYPOWER")
  energytick:RegisterEvent("UNIT_ENERGY")
  energytick:RegisterEvent("UNIT_MANA")
  energytick:SetScript("OnEvent", function()
    if UnitPowerType("player") == 0 then
      this.mode = "MANA"
      -- hide if full mana and not in combat
      if (UnitMana("player") == UnitManaMax("player")) and (not UnitAffectingCombat("player")) then
        this:Hide()
      else
        this:Show()
      end
    elseif UnitPowerType("player") == 3 then
      this.mode = "ENERGY"
      this:Show()
    else
      this:Hide()
    end

    if event == "PLAYER_ENTERING_WORLD" then
      this.lastMana = UnitMana("player")
    end

    if (this.mode == "ENERGY") or ((event == "UNIT_MANA" or event == "UNIT_ENERGY") and arg1 == "player") then
      this.currentMana = UnitMana("player")
      local diff = 0
      if this.lastMana then
        diff = this.currentMana - this.lastMana
      end

      if this.mode == "MANA" and diff < 0 then
        this.target = 5
      elseif this.mode == "MANA" and diff > 0 then
        if this.max ~= 5 and diff > (this.badtick and this.badtick*1.2 or 5) then
          this.target = 2
        else
          this.badtick = diff
        end
      elseif this.mode == "ENERGY" and diff >= 0 then
        this.target = 2
      end
      this.lastMana = this.currentMana
    end
  end)

local pheight, pwidth = PlayerFrameManaBar:GetHeight(), PlayerFrameManaBar:GetWidth()
energytick:SetScript("OnUpdate", function()
  if this.target then
    this.start, this.max = GetTime(), this.target
    this.target = nil
  end

  if not this.start then return end

  this.current = GetTime() - this.start

  if this.current > this.max then
    this.start, this.max, this.current = GetTime(), 2, 0
  end

  local pos = (pwidth ~= "-1" and pwidth or width) * (this.current / this.max)
  if not pheight then return end
  this.spark:SetPoint("LEFT", pos-((pheight+5)/2), 0)
end)

  energytick.spark = energytick:CreateTexture(nil, 'OVERLAY')
  energytick.spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
  energytick.spark:SetHeight(pheight + 10)
  energytick.spark:SetWidth(pheight + 4)
  energytick.spark:SetBlendMode('ADD')
end