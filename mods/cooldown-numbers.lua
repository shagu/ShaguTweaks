local _G = ShaguTweaks.GetGlobalEnv()
local T = ShaguTweaks.T
local hooksecurefunc = hooksecurefunc or ShaguTweaks.hooksecurefunc
local GetExpansion = ShaguTweaks.GetExpansion
local AddBorder = ShaguTweaks.AddBorder
local TimeConvert = ShaguTweaks.TimeConvert

local module = ShaguTweaks:register({
  title = T["Cooldown Numbers"],
  description = T["Display  the remaining duration as text on every cooldown."],
  expansions = { ["vanilla"] = true, ["tbc"] = true },
  enabled = nil,
  color = { r = .3, g = .3, b = .3, a = .9}
})

local function CooldownOnUpdate()
  -- hide frames without parent
  local parent = this:GetParent()
  if not parent then this:Hide() end

  if not this.tick then this.tick = GetTime() + .1 end
  if this.tick > GetTime() then return end
  this.tick = GetTime() + .1

  -- fix own alpha value (should be inherited, but somehow isn't always)
  this:SetAlpha(parent:GetAlpha())

  local remaining = this.duration - (GetTime() - this.start)
  if remaining > 0 then
    this.text:SetText(TimeConvert(remaining))
  else
    this:Hide()
  end
end

local function CreateCoolDown(cooldown, start, duration)
  local parent = cooldown:GetParent()
  if not parent then return end

  -- skip already set debuff timers
  if cooldown.readable then return end

  local parentname = parent and parent.GetName and parent:GetName()
  parentname = parentname or "UnknownCooldownFrame"

  cooldown.cooldowntext = CreateFrame("Frame", parentname .. "CooldownText", cooldown)
  cooldown.cooldowntext:SetAllPoints(cooldown)
  cooldown.cooldowntext:SetFrameLevel(parent:GetFrameLevel() + 1)
  cooldown.cooldowntext.text = cooldown.cooldowntext:CreateFontString(parentname .. "CooldownTextFont", "OVERLAY")

  -- detect dynamic font size
  local size = parent:GetHeight() or 0
  size = size > 0 and size * .64 or 12
  size = size > 14 and 14 or size

  -- set fonts
  cooldown.cooldowntext.text:SetFont(STANDARD_TEXT_FONT, size, "OUTLINE")
  cooldown.cooldowntext.text:SetPoint("CENTER", cooldown.cooldowntext, "CENTER", 0, 0)
  cooldown.cooldowntext:SetScript("OnUpdate", CooldownOnUpdate)
end

local function SetCooldown(this, start, duration, enable)
  -- add support for omnicc's disable flag
  if this.noCooldownCount then return end

  -- don't draw global cooldowns
  if not duration or duration < 2 then
    -- hide if already existing
    if this.cooldowntext then
      this.cooldowntext:Hide()
    end

    return
  end

  if not this.cooldowntext then
    CreateCoolDown(this, start, duration)
  end

  if this.cooldowntext then
    if start > 0 and duration > 0 and (not enable or enable > 0) then
      this.cooldowntext:Show()
    else
      this.cooldowntext:Hide()
    end

    this.cooldowntext.start = start
    this.cooldowntext.duration = duration
  end
end

module.enable = function(self)
  if GetExpansion() == "vanilla" then
    -- vanilla does not have a cooldown frame type, so we hook the
    -- regular SetTimer function that each one is calling.
    hooksecurefunc("CooldownFrame_SetTimer", SetCooldown)
  else
    -- tbc and later expansion have a cooldown frametype, so we can
    -- hook directly into the frame creation and add our function there.
    local methods = getmetatable(CreateFrame('Cooldown', nil, nil, 'CooldownFrameTemplate')).__index
    hooksecurefunc(methods, 'SetCooldown', SetCooldown)
  end
end
