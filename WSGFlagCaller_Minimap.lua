WFC.Minimap = {}

local mmButton = CreateFrame("Button", "TurtlePvPMinimapButton", Minimap)
mmButton:SetWidth(31)
mmButton:SetHeight(31)
mmButton:SetFrameStrata("LOW")
mmButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

local icon = mmButton:CreateTexture(nil, "BACKGROUND")
icon:SetTexture("Interface\\Icons\\Ability_DualWield")
icon:SetWidth(20)
icon:SetHeight(20)
icon:SetPoint("TOPLEFT", mmButton, "TOPLEFT", 6, -5)

local bg = mmButton:CreateTexture(nil, "ARTWORK")
bg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
bg:SetVertexColor(0.8, 0.1, 0.1, 1) -- Red background
bg:SetWidth(20)
bg:SetHeight(20)
bg:SetPoint("TOPLEFT", mmButton, "TOPLEFT", 6, -5)
icon:SetDrawLayer("OVERLAY")

local border = mmButton:CreateTexture(nil, "OVERLAY")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetWidth(53)
border:SetHeight(53)
border:SetPoint("TOPLEFT", mmButton, "TOPLEFT", 0, 0)

mmButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
mmButton:SetScript("OnClick", function()
    if arg1 == "LeftButton" then
        WFC.Minimap:TogglePanel()
    else
        WFC:Print("TurtlePvP v3. Minimap button.")
    end
end)

local function UpdateMinimapPos()
    local angle = math.rad(WSGFCConfig.minimapPos or 45)
    local x = math.cos(angle) * 80
    local y = math.sin(angle) * 80
    mmButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

mmButton:SetScript("OnUpdate", function()
    if arg1 then this.elapsed = (this.elapsed or 0) + arg1 else return end
    if this.elapsed > 0.1 then
        this.elapsed = 0
        UpdateMinimapPos()
    end
end)

mmButton:RegisterForDrag("LeftButton")
mmButton:SetScript("OnDragStart", function()
    this.dragging = true
end)

mmButton:SetScript("OnDragStop", function()
    this.dragging = false
end)

local dragFrame = CreateFrame("Frame")
dragFrame:SetScript("OnUpdate", function()
    if mmButton.dragging then
        local mx, my = Minimap:GetCenter()
        local px, py = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        px = px / scale
        py = py / scale
        local angle = math.atan2(py - my, px - mx)
        WSGFCConfig.minimapPos = math.deg(angle)
        UpdateMinimapPos()
    end
end)

-- Configuration Panel
local panel = CreateFrame("Frame", "TurtlePvPConfigPanel", UIParent)
panel:SetWidth(300)
panel:SetHeight(200)
panel:SetPoint("CENTER", 0, 0)
panel:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
panel:EnableMouse(true)
panel:SetMovable(true)
panel:RegisterForDrag("LeftButton")
panel:SetScript("OnDragStart", function() this:StartMoving() end)
panel:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
panel:Hide()

local title = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
title:SetPoint("TOP", 0, -15)
title:SetText("TurtlePvP Settings")

local closeBtn = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -5, -5)

local tabWSG = CreateFrame("Button", "TurtlePvPTab1", panel, "CharacterFrameTabButtonTemplate")
tabWSG:SetPoint("BOTTOMLEFT", panel, "TOPLEFT", 10, -5)
tabWSG:SetText("WSG Caller")

local tabArena = CreateFrame("Button", "TurtlePvPTab2", panel, "CharacterFrameTabButtonTemplate")
tabArena:SetPoint("LEFT", tabWSG, "RIGHT", -15, 0)
tabArena:SetText("Arena HUD")

-- WSG Tab Content
local wsgFrame = CreateFrame("Frame", nil, panel)
wsgFrame:SetWidth(280)
wsgFrame:SetHeight(150)
wsgFrame:SetPoint("TOPLEFT", 10, -35)

local chkWSGEnable = CreateFrame("CheckButton", "TurtlePvPChkWSGEnable", wsgFrame, "UICheckButtonTemplate")
chkWSGEnable:SetPoint("TOPLEFT", 10, -10)
_G[chkWSGEnable:GetName().."Text"]:SetText("Enable WSG Flag Caller")
chkWSGEnable:SetScript("OnClick", function()
    WSGFCConfig.wsgEnabled = this:GetChecked()
    WFC:CheckZone(true)
end)

local chkHPCallouts = CreateFrame("CheckButton", "TurtlePvPChkHPCallouts", wsgFrame, "UICheckButtonTemplate")
chkHPCallouts:SetPoint("TOPLEFT", 30, -40)
_G[chkHPCallouts:GetName().."Text"]:SetText("Enemy HP Callouts (/bg)")
chkHPCallouts:SetScript("OnClick", function() WSGFCConfig.hpCallouts = this:GetChecked() end)

local chkWSGFrame = CreateFrame("CheckButton", "TurtlePvPChkWSGFrame", wsgFrame, "UICheckButtonTemplate")
chkWSGFrame:SetPoint("TOPLEFT", 30, -70)
_G[chkWSGFrame:GetName().."Text"]:SetText("Show Flag HUD")
chkWSGFrame:SetScript("OnClick", function() 
    WSGFCConfig.showFrame = this:GetChecked()
    if WFC.Frame.UpdateVisibility then WFC.Frame:UpdateVisibility() end
end)

-- Arena Tab Content
local arenaFrame = CreateFrame("Frame", nil, panel)
arenaFrame:SetWidth(280)
arenaFrame:SetHeight(150)
arenaFrame:SetPoint("TOPLEFT", 10, -35)
arenaFrame:Hide()

local chkArenaEnable = CreateFrame("CheckButton", "TurtlePvPChkArenaEnable", arenaFrame, "UICheckButtonTemplate")
chkArenaEnable:SetPoint("TOPLEFT", 10, -10)
_G[chkArenaEnable:GetName().."Text"]:SetText("Enable Arena Enemy HUD")
chkArenaEnable:SetScript("OnClick", function() 
    WSGFCConfig.arenaEnabled = this:GetChecked() 
    WFC:CheckZone(true)
end)

local chkArenaDist = CreateFrame("CheckButton", "TurtlePvPChkArenaDist", arenaFrame, "UICheckButtonTemplate")
chkArenaDist:SetPoint("TOPLEFT", 30, -40)
_G[chkArenaDist:GetName().."Text"]:SetText("Show Distance (req UnitXP)")
chkArenaDist:SetScript("OnClick", function() 
    WSGFCConfig.arenaDistance = this:GetChecked() 
    if WFC.Arena.UpdateHUD then WFC.Arena:UpdateHUD() end
end)

local chkArenaTrinkets = CreateFrame("CheckButton", "TurtlePvPChkArenaTrinkets", arenaFrame, "UICheckButtonTemplate")
chkArenaTrinkets:SetPoint("TOPLEFT", 30, -70)
_G[chkArenaTrinkets:GetName().."Text"]:SetText("Track Trinkets/Racials (req Nampower)")
chkArenaTrinkets:SetScript("OnClick", function() WSGFCConfig.arenaTrinkets = this:GetChecked() end)

-- Tab Switching Logic
tabWSG:SetScript("OnClick", function()
    PanelTemplates_SelectTab(tabWSG)
    PanelTemplates_DeselectTab(tabArena)
    wsgFrame:Show()
    arenaFrame:Hide()
end)

tabArena:SetScript("OnClick", function()
    PanelTemplates_SelectTab(tabArena)
    PanelTemplates_DeselectTab(tabWSG)
    arenaFrame:Show()
    wsgFrame:Hide()
end)

-- Init values
panel:SetScript("OnShow", function()
    chkWSGEnable:SetChecked(WSGFCConfig.wsgEnabled)
    chkHPCallouts:SetChecked(WSGFCConfig.hpCallouts)
    chkWSGFrame:SetChecked(WSGFCConfig.showFrame)
    
    chkArenaEnable:SetChecked(WSGFCConfig.arenaEnabled)
    chkArenaDist:SetChecked(WSGFCConfig.arenaDistance)
    chkArenaTrinkets:SetChecked(WSGFCConfig.arenaTrinkets)
    
    PanelTemplates_TabResize(10, tabWSG)
    PanelTemplates_TabResize(10, tabArena)
    PanelTemplates_SetNumTabs(panel, 2)
    
    tabWSG:Click()
end)

function WFC.Minimap:TogglePanel()
    if panel:IsVisible() then
        panel:Hide()
    else
        panel:Show()
    end
end
