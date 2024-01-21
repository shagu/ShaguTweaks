local _G = ShaguTweaks.GetGlobalEnv()
local T = ShaguTweaks.T

local module = ShaguTweaks:register({
  title = T["Movable Unit Frames"],
  description = T["Player and Target unit frames can be moved while <Shift> and <Ctrl> are pressed together."],
  expansions = { ["vanilla"] = true, ["tbc"] = true },
  category = T["Unit Frames"],
  enabled = nil,
})

local movables = { "PlayerFrame", "TargetFrame" }

module.enable = function(self)
  local unlocker = CreateFrame("Frame", nil, UIParent)
  unlocker:SetAllPoints(UIParent)

  unlocker.movable = nil
  unlocker:SetScript("OnUpdate", function()
    if IsShiftKeyDown() and IsControlKeyDown() then
      if not unlocker.movable then
        for _, frame in pairs(movables) do
         _G[frame]:SetUserPlaced(true)
         _G[frame]:SetMovable(true)
         _G[frame]:EnableMouse(true)
         _G[frame]:RegisterForDrag("LeftButton")
         _G[frame]:SetScript("OnDragStart", function() this:StartMoving() end)
         _G[frame]:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
        end

        unlocker.movable = true
        unlocker.grid:Show()
      end
    elseif unlocker.movable then
      for _, frame in pairs(movables) do
       _G[frame]:SetScript("OnDragStart", function() end)
       _G[frame]:SetScript("OnDragStop", function() end)
       _G[frame]:StopMovingOrSizing()
      end

      unlocker.movable = nil
      unlocker.grid:Hide()
    end
  end)

  unlocker.grid = CreateFrame("Frame", nil, WorldFrame)
  unlocker.grid:SetAllPoints(WorldFrame)
  unlocker.grid:Hide()

  local size = 1
  local line = {}

  local width = GetScreenWidth()
  local height = GetScreenHeight()

  local ratio = width / GetScreenHeight()
  local rheight = GetScreenHeight() * ratio

  local wStep = width / 64
  local hStep = rheight / 64

  -- vertical lines
  for i = 0, 64 do
    if i == 64 / 2 then
      line = unlocker.grid:CreateTexture(nil, 'BORDER')
      line:SetTexture(.8, .6, 0)
    else
      line = unlocker.grid:CreateTexture(nil, 'BACKGROUND')
      line:SetTexture(0, 0, 0, .2)
    end
    line:SetPoint("TOPLEFT", unlocker.grid, "TOPLEFT", i*wStep - (size/2), 0)
    line:SetPoint('BOTTOMRIGHT', unlocker.grid, 'BOTTOMLEFT', i*wStep + (size/2), 0)
  end

  -- horizontal lines
  for i = 1, floor(height/hStep) do
    if i == floor(height/hStep / 2) then
      line = unlocker.grid:CreateTexture(nil, 'BORDER')
      line:SetTexture(.8, .6, 0)
    else
      line = unlocker.grid:CreateTexture(nil, 'BACKGROUND')
      line:SetTexture(0, 0, 0, .2)
    end

    line:SetPoint("TOPLEFT", unlocker.grid, "TOPLEFT", 0, -(i*hStep) + (size/2))
    line:SetPoint('BOTTOMRIGHT', unlocker.grid, 'TOPRIGHT', 0, -(i*hStep + size/2))
  end
end
