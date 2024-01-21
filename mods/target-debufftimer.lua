local _G = ShaguTweaks.GetGlobalEnv()
local T = ShaguTweaks.T

local module = ShaguTweaks:register({
  title = T["Debuff Timer"],
  description = T["Show debuff durations on the target unit frame."],
  expansions = { ["vanilla"] = true, ["tbc"] = nil },
  category = T["Unit Frames"],
  enabled = true,
})

local libdebuff = ShaguTweaks.libdebuff
local UnitDebuff = libdebuff and libdebuff.UnitDebuff
local TimeConvert = ShaguTweaks.TimeConvert

local function CreateTextCooldown(cooldown)
  if cooldown.readable then return end

  cooldown.readable = CreateFrame("Frame", "pfCooldownFrame", cooldown:GetParent())
  cooldown.readable:SetAllPoints(cooldown)
  cooldown.readable:SetFrameLevel(cooldown:GetParent():GetFrameLevel() + 1)
  cooldown.readable.text = cooldown.readable:CreateFontString("pfCooldownFrameText", "OVERLAY")

  cooldown.readable.text:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
  cooldown.readable.text:SetPoint("CENTER", cooldown.readable, "CENTER", 0, 0)
  cooldown.readable:SetScript("OnUpdate", function()
    parent = this:GetParent()
    if not parent then this:Hide() end

    if not this.next then this.next = GetTime() + .1 end
    if this.next > GetTime() then return end
    this.next = GetTime() + .1

    -- fix own alpha value (should be inherited, but somehow isn't always)
    this:SetAlpha(parent:GetAlpha())

    local remaining = this.duration - (GetTime() - this.start)
    if remaining >= 0 then
      this.text:SetText(TimeConvert(remaining))
    else
      this:Hide()
    end
  end)
end

module.enable = function(self)
  local HookTargetDebuffButton_Update = TargetDebuffButton_Update
  TargetDebuffButton_Update = function()
    HookTargetDebuffButton_Update()

    for i=1, MAX_TARGET_DEBUFFS do
      local effect, rank, texture, stacks, dtype, duration, timeleft = libdebuff:UnitDebuff("target", i)
      local button = _G["TargetFrameDebuff"..i]

      if button and not button.cd then
        button.cd = CreateFrame("Model", "TargetFrameDebuff"..i.."Cooldown", button, "CooldownFrameTemplate")
        button.cd.noCooldownCount = true
        button.cd:SetAllPoints()
        button.cd:SetScale(.6)
        button.cd:SetAlpha(.8)
      end

      local dCount = _G["TargetFrameDebuff" .. i .. "Count"]
      if button and dCount then
        if not dCount.fixup then
          dCount.fixup = true
          dCount:SetPoint("BOTTOMRIGHT", "TargetFrameDebuff" .. i, "BOTTOMRIGHT", 6, -3)
        end
        if stacks and stacks > 1 then
          dCount:SetText("|c0000ff3b" .. stacks)
          dCount:Show()
        else
          dCount:Hide()
        end
      end

      local dBorder = _G["TargetFrameDebuff" .. i .. "Border"]
      if button and dBorder then
        local color = dtype and DebuffTypeColor[dtype] or DebuffTypeColor["none"]
        dBorder:SetVertexColor(color.r, color.g, color.b)
      end

      if button and effect and duration and timeleft then
        local start = GetTime() + timeleft - duration
        CreateTextCooldown(button.cd)
        CooldownFrame_SetTimer(button.cd, start, duration, 1)
        button.cd.readable.start = start
        button.cd.readable.duration = duration
        button.cd.readable:Show()
        button.cd:Show()
      elseif button then
        CooldownFrame_SetTimer(button.cd,0,0,0)
      end
    end
  end
end
