WFC.Frame = {}
local hud = nil

function WFC.Frame:Initialize()
    hud = CreateFrame("Frame", "WSGFCHud", UIParent)
    hud:SetWidth(200)
    hud:SetHeight(60)
    hud:SetPoint(WSGFCConfig.framePoint, UIParent, WSGFCConfig.framePoint, WSGFCConfig.frameX, WSGFCConfig.frameY)
    hud:SetMovable(true)
    hud:EnableMouse(true)
    hud:RegisterForDrag("LeftButton")
    hud:SetScript("OnDragStart", function() this:StartMoving() end)
    hud:SetScript("OnDragStop", function() 
        this:StopMovingOrSizing() 
        local p, _, rp, x, y = this:GetPoint()
        WSGFCConfig.framePoint = p
        WSGFCConfig.frameX = x
        WSGFCConfig.frameY = y
    end)
    
    hud.allyRow = WFC.Frame:CreateRow(hud, 0, "Alliance Flag")
    hud.hordeRow = WFC.Frame:CreateRow(hud, -30, "Horde Flag")
    
    hud:Hide()
end

function WFC.Frame:CreateRow(parent, yOffset, label)
    local row = CreateFrame("Button", nil, parent)
    row:SetWidth(200)
    row:SetHeight(25)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)
    
    local tex = row:CreateTexture(nil, "BACKGROUND")
    tex:SetAllPoints()
    tex:SetTexture(0, 0, 0, 0.5)
    row.bg = tex
    
    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetWidth(20)
    icon:SetHeight(20)
    icon:SetPoint("LEFT", row, "LEFT", 2, 0)
    if string.find(label, "Alliance") then
        icon:SetTexture("Interface\\Icons\\INV_Banner_02") 
    else
        icon:SetTexture("Interface\\Icons\\INV_Banner_03")
    end
    
    local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    nameText:SetPoint("LEFT", icon, "RIGHT", 5, 0)
    nameText:SetText("Carrier")
    row.nameText = nameText
    
    local hpBar = CreateFrame("StatusBar", nil, row)
    hpBar:SetWidth(100)
    hpBar:SetHeight(15)
    hpBar:SetPoint("RIGHT", row, "RIGHT", -5, 0)
    hpBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    hpBar:SetStatusBarColor(0, 1, 0)
    hpBar:SetMinMaxValues(0, 100)
    hpBar:SetValue(100)
    row.hpBar = hpBar
    
    row:SetScript("OnClick", function()
        local cName = row.carrierName
        if cName then
            TargetByName(cName, true)
            if FocusUnit then
                FocusUnit("target")
            end
        end
    end)
    
    return row
end

function WFC.Frame:Disable()
    if hud then hud:Hide() end
    WFC.Frame:StopTicker()
end

function WFC.Frame:UpdateVisibility()
    if not WSGFCConfig.showFrame or not WFC.inWSG then
        WFC.Frame:Disable()
        return
    end
    
    local showAny = false
    
    if WFC.allyCarrier then
        hud.allyRow.carrierName = WFC.allyCarrier
        hud.allyRow.nameText:SetText(WFC.allyCarrier)
        hud.allyRow:Show()
        showAny = true
    else
        hud.allyRow:Hide()
    end
    
    if WFC.hordeCarrier then
        hud.hordeRow.carrierName = WFC.hordeCarrier
        hud.hordeRow.nameText:SetText(WFC.hordeCarrier)
        hud.hordeRow:Show()
        showAny = true
    else
        hud.hordeRow:Hide()
    end
    
    if showAny then
        hud:Show()
        WFC.Frame:StartTicker()
    else
        hud:Hide()
        WFC.Frame:StopTicker()
    end
end

function WFC.Frame:StartTicker()
    if not hud.ticker then
        hud.ticker = CreateFrame("Frame", nil, hud)
        hud.ticker.elapsed = 0
        hud.ticker:SetScript("OnUpdate", function()
            this.elapsed = this.elapsed + arg1
            if this.elapsed > 0.5 then
                this.elapsed = 0
                WFC.Frame:OnTick()
            end
        end)
    end
end

function WFC.Frame:StopTicker()
    if hud and hud.ticker then
        hud.ticker:SetScript("OnUpdate", nil)
        hud.ticker = nil
    end
end

function WFC.Frame:OnTick()
    WFC.Frame:UpdateRowHP(hud.allyRow, WFC.allyCarrier)
    WFC.Frame:UpdateRowHP(hud.hordeRow, WFC.hordeCarrier)
end

function WFC.Frame:UpdateRowHP(row, carrierName)
    if not carrierName then return end
    
    local hp = 0
    local hpMax = 100
    local found = false
    local classColor = nil
    local targetId = nil

    if UnitName("target") == carrierName then
        targetId = "target"
    end
    if not targetId then
        for i=1, GetNumGroupMembers and GetNumGroupMembers() or GetNumRaidMembers() do
            if UnitName("raid"..i) == carrierName then
                targetId = "raid"..i
                break
            end
        end
    end
    if not targetId then
        for i=1, GetNumPartyMembers() do
            if UnitName("party"..i) == carrierName then
                targetId = "party"..i
                break
            end
        end
    end
    if not targetId and WFC.superwow and UnitExists(carrierName) then
        targetId = carrierName
    end

    if targetId then
        hp = UnitHealth(targetId)
        hpMax = UnitHealthMax(targetId)
        found = true
        if UnitClass then
            local _, eClass = UnitClass(targetId)
            if eClass then
                classColor = WFC:GetClassColor(eClass)
            end
        end
    end
    
    -- SuperWoW Minimap Tracking 
    if WSGFCConfig.minimap and WFC.superwow and TrackUnit then
        local myFaction = UnitFactionGroup("player")
        local isAllyFC = (myFaction == "Alliance" and carrierName == WFC.allyCarrier) or (myFaction == "Horde" and carrierName == WFC.hordeCarrier)
        if isAllyFC and targetId then
            TrackUnit(targetId)
        end
    end

    if classColor then
        row.nameText:SetText("|cff"..classColor..carrierName.."|r")
    end
    
    if found and hpMax and hpMax > 0 then
        row.hpBar:SetMinMaxValues(0, hpMax)
        row.hpBar:SetValue(hp)
        local pct = hp / hpMax
        if pct > 0.5 then
            row.hpBar:SetStatusBarColor(0, 1, 0)
        elseif pct > 0.25 then
            row.hpBar:SetStatusBarColor(1, 1, 0)
        else
            row.hpBar:SetStatusBarColor(1, 0, 0)
        end
    end
end
