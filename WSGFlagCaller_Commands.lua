SLASH_WSGFLAGCALLER1 = "/wsgflagcaller"
SLASH_WSGFLAGCALLER2 = "/wfc"

SlashCmdList["WSGFLAGCALLER"] = function(msg)
    local args = {}
    for word in string.gfind(msg, "[^%s]+") do
        table.insert(args, string.lower(word))
    end
    
    local cmd = args[1]
    
    if cmd == "info" or not cmd then
        WFC:Print("WSGFlagCaller Commands:")
        WFC:Print("  /wfc hp on/off - Toggle HP callouts")
        WFC:Print("  /wfc thresholds 75 50 25 - Set HP thresholds for callouts")
        WFC:Print("  /wfc frame on/off - Show or hide the flag carrier HUD")
        WFC:Print("  /wfc reset - Reset HUD position to default")
        WFC:Print("  /wfc status - Show current settings")
        WFC:Print("  /wfc debug on/off - Toggle debug messages")
        WFC:Print("  /wfc force - Force-enable WSG mode (for testing)")
    elseif cmd == "hp" then
        WSGFCConfig.hpCallouts = (args[2] == "on")
        WFC:Print("HP Callouts set to " .. tostring(args[2]))
    elseif cmd == "frame" then
        WSGFCConfig.showFrame = (args[2] == "on")
        WFC:Print("Frame visibility set to " .. tostring(args[2]))
        WFC.Frame:UpdateVisibility()
    elseif cmd == "debug" then
        if args[2] == "on" then
            WSGFCConfig.debug = true
            WFC:Print("Debug mode enabled.")
        else
            WSGFCConfig.debug = false
            WFC:Print("Debug mode disabled.")
        end
    elseif cmd == "force" then
        WFC:CheckZone(true)
        WFC:Print("Force-enabled WSG mode.")
    elseif cmd == "reset" then
        WSGFCConfig.framePoint = "TOP"
        WSGFCConfig.frameX = 0
        WSGFCConfig.frameY = -150
        if WSGFCHud then
            WSGFCHud:SetPoint(WSGFCConfig.framePoint, UIParent, WSGFCConfig.framePoint, WSGFCConfig.frameX, WSGFCConfig.frameY)
        end
        WFC:Print("Frame position reset.")
    elseif cmd == "thresholds" then
        WSGFCConfig.hpThresholds = {}
        for i=2, table.getn(args) do
            local num = tonumber(args[i])
            if num then
                table.insert(WSGFCConfig.hpThresholds, num)
            end
        end
        WFC:Print("HP Thresholds updated.")
    elseif cmd == "status" then
        local onOffStr = function(b) return b and "|cff00ff00[ON]|r" or "|cffff0000[OFF]|r" end
        WFC:Print("=== WSG Flag Caller Status ===")
        local npStr = GetNampowerVersion and "|cff00ff00Yes|r" or "|cffff0000No|r"
        local unitXPStr = UnitXP and "|cff00ff00Yes|r" or "|cffff0000No|r"
        WFC:Print("Nampower (Guids/HP): " .. npStr)
        WFC:Print("UnitXP (Distance): " .. unitXPStr)
        WFC:Print("HP Callouts: " .. onOffStr(WSGFCConfig.hpCallouts) .. " (Thresholds: " .. table.concat(WSGFCConfig.hpThresholds, ",") .. "%)")
        WFC:Print("Frame: " .. onOffStr(WSGFCConfig.showFrame))
        WFC:Print("Debug: " .. onOffStr(WSGFCConfig.debug))
    end
end
