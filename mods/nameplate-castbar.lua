local _G = ShaguTweaks.GetGlobalEnv()
local UnitCastingInfo = ShaguTweaks.UnitCastingInfo
local UnitChannelInfo = ShaguTweaks.UnitChannelInfo

local module = ShaguTweaks:register({
  title = "Nameplate Castbar",
  description = "Adds a castbar to the nameplate based on combat log estimations.",
  expansions = { ["vanilla"] = true, ["tbc"] = false },
  enabled = nil,
})

module.enable = function(self)
  if ShaguPlates then return end

  local backdrop = {
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 8, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
  }

  local function create_castbar(plate)
    -- create the castbar
    plate.castbar = CreateFrame("StatusBar", nil, plate)
    plate.castbar:SetPoint("BOTTOM", plate, "BOTTOM", 8, -11)
    plate.castbar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    plate.castbar:SetStatusBarColor(1, .8, 0, 1)
    plate.castbar:SetWidth(plate:GetWidth() - 22)
    plate.castbar:SetHeight(10)

    -- create the spell icon
    plate.castbar.texture = CreateFrame("Frame", nil, plate.castbar)
    plate.castbar.texture:SetPoint("RIGHT", plate.castbar, "LEFT", 0, 0)
    plate.castbar.texture:SetHeight(18)
    plate.castbar.texture:SetWidth(18)
    plate.castbar.texture.icon = plate.castbar.texture:CreateTexture(nil, "BACKGROUND")
    plate.castbar.texture.icon:SetPoint("CENTER", 0, 0)
    plate.castbar.texture.icon:SetWidth(12)
    plate.castbar.texture.icon:SetHeight(12)
    plate.castbar.texture:SetBackdrop(backdrop)
    plate.castbar.texture:SetBackdropBorderColor(1,.8,0)

    -- castbar background
    plate.castbar.bg = plate.castbar:CreateTexture(nil, "BACKGROUND")
    plate.castbar.bg:SetTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    plate.castbar.bg:SetVertexColor(.1, .1, 0, .8)
    plate.castbar.bg:SetAllPoints(true)

    -- castbar spark
    plate.castbar.spark = plate.castbar:CreateTexture(nil, "OVERLAY")
    plate.castbar.spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
    plate.castbar.spark:SetWidth(20)
    plate.castbar.spark:SetHeight(20)
    plate.castbar.spark:SetBlendMode("ADD")

    -- castbar border
    plate.castbar.backdrop = CreateFrame("Frame", nil, plate.castbar)
    plate.castbar.backdrop:SetPoint("TOPLEFT", plate.castbar, "TOPLEFT", -3, 3)
    plate.castbar.backdrop:SetPoint("BOTTOMRIGHT", plate.castbar, "BOTTOMRIGHT", 3, -3)
    plate.castbar.backdrop:SetBackdrop(backdrop)
    plate.castbar.backdrop:SetBackdropBorderColor(1,.8,0)

    -- castbar spellname
    plate.castbar.text = plate.castbar:CreateFontString(nil, "HIGH", "GameFontWhite")
    plate.castbar.text:SetPoint("CENTER", plate.castbar, "CENTER", 0, 0)
    local font, size, opts = plate.castbar.text:GetFont()
    plate.castbar.text:SetFont(font, size - 3, "THINOUTLINE")

    -- hide castbar by default
    plate.castbar:Hide()
  end

  -- scan for casts and show castbar
  table.insert(ShaguTweaks.libnameplate.OnUpdate, function()
    -- create castbar if not existing
    if not this.castbar then create_castbar(this) end

    local name = this.name:GetText()
    local cast, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(name)

    if cast then
      local duration = endTime - startTime
      local max = duration / 1000
      local cur = GetTime() - startTime / 1000

      cur = cur > max and max or cur
      cur = cur < 0 and 0 or cur

      this.castbar:Show()
      this.castbar:SetMinMaxValues(0, duration / 1000)
      this.castbar:SetValue(cur)

      local percent = cur / max
      local x = this.castbar:GetWidth()*percent
      this.castbar.spark:SetPoint("CENTER", this.castbar, "LEFT", x, 0)

      this.castbar.text:SetText(cast)

      if texture then
        this.castbar.texture.icon:SetTexture(texture)
        this.castbar.texture.icon:Show()
      else
        this.castbar.texture.icon:Hide()
      end

      this.castbar:SetAlpha(this:GetAlpha())
    else
      this.castbar:Hide()
    end
  end)
end
