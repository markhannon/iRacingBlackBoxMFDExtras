SelectedSetting = 0

function InCarAdjBlackBox()
    ui.beginScale()

    DrawArrows()

    -- background
    ui.drawRectFilled(vec2(33, 22), vec2(479, 323), rgbm.from0255(0, 0, 0, .75), 6)

    ui.endPivotScale(Scale, vec2(0, 22))

    ui.pushDWriteFont("fonts/eurostarblackextended.ttf")

    -- title
    ui.setCursor(vec2(41 * Scale, 22 + (3 * Scale)))
    ui.dwriteText("In-car Adjustments", 27 * Scale, rgbm.from0255(221, 182, 35))

    ui.popDWriteFont()

    ui.pushDWriteFont("Arial;Weight=Bold")

    local names = {
        "ERS battery charge",
        "MGU-K delivery mode",
        "MGU-K recovery mode",
        "MGU-H mode",
        "Brake bias coarse",
        "Brake bias fine",
        "Traction Control mode",
        "ABS mode",
        "Engine brake setting",
        "Wiper mode",
        "Light mode"
    }

    local showLine = {}

    if CAR.hasCockpitERSDelivery then showLine["ERS battery charge"] = tostring(math.round(CAR.kersCharge * 100)) .. "%" end
    if CAR.mgukDeliveryCount > 0 then showLine["MGU-K delivery mode"] = string.format("%d / %d", CAR.mgukDelivery, CAR.mgukDeliveryCount - 1) end
    if CAR.hasCockpitERSRecovery then showLine["MGU-K recovery mode"] = string.format("%d / 100", CAR.mgukRecovery * 10) end
    if CAR.hasCockpitMGUHMode then if CAR.mguhChargingBatteries then showLine["MGU-H mode"] = "Battery" else showLine["MGU-H mode"] = "Motor" end end
    if CAR.brakesCockpitBias then
        showLine["Brake bias coarse"] = string.format("%.1f%%", math.round(CAR.brakeBias * 100, 1))
        showLine["Brake bias fine"] = string.format("%.1f%%", math.round(CAR.brakeBias * 100, 1))
    end
    if CAR.tractionControlModes > 0 then showLine["Traction Control mode"] = CAR.tractionControlMode end
    if CAR.absModes > 0 then showLine["ABS mode"] = CAR.absMode end
    if CAR.engineBrakeSettingsCount > 0 then showLine["Engine brake setting"] = string.format("%d / %d", CAR.currentEngineBrakeSetting + 1, CAR.engineBrakeSettingsCount) end
    if CAR.wiperModes > 1 then showLine["Wiper mode"] = CAR.wiperMode end
    if CAR.headlightsAreHeadlights then showLine["Light mode"] = CAR.headlightsActive end

    local count = 0
    for i in pairs(showLine) do count = count + 1 end

    local lastLineY = (275 - 6) * Scale + 22
    local ceilY = (49 - 6) * Scale + 22

    local selectMin = 0
    if showLine["ERS battery charge"] ~= nil then selectMin = 1 end
    if SelectOffsetY == "-" then SelectOffsetY = selectMin end
    if SelectOffsetY < selectMin then SelectOffsetY = count - 1 elseif SelectOffsetY > count - 1 then SelectOffsetY = selectMin end

    local lineDistance = (lastLineY - ceilY) / (count - 1)
    local line = ceilY

    for i = 1, #names do
        if showLine[names[i]] ~= nil then
            if math.round(line) == math.round(ceilY + SelectOffsetY * lineDistance) then
                ui.drawRectFilled(vec2((20 + 24 + 9) * Scale, line), vec2((422 + 24 + 9) * Scale, line + 22.6 * Scale), rgbm.from0255(43, 53, 78))
                SelectedSetting = names[i]
            end

            ui.setCursor(vec2(0, line))
            ui.dwriteTextAligned(names[i] .. ":", 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(213 + 24 + 9, 100):scale(Scale), false, rgbm.from0255(221, 182, 35))

            if names[i] == "ERS battery charge" then
                ui.setCursor(vec2(250 + 24 + 9, line))
                ui.dwriteTextAligned(showLine[names[i]], 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(100, 100):scale(Scale), false, rgbm.from0255(244, 244, 244))
            else
                DrawLeftSelectionArrow(line)
                ui.setCursor(vec2((250 + 24 + 9) * Scale, line))
                ui.dwriteTextAligned(showLine[names[i]], 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(100, 100):scale(Scale), false, rgbm.from0255(244, 244, 244))
                DrawRightSelectionArrow(line)

                if SelectOffsetX ~= 0 then
                    ChangeSetting()
                    SelectOffsetX = 0
                end
            end

            line = line + lineDistance
        end
    end

    ui.popDWriteFont()
end

function DrawLeftSelectionArrow(line)
    ui.drawRectFilled(vec2(258 * Scale, line + 2 * Scale), vec2(278 * Scale, line + 22 * Scale), rgbm.colors.gray)
    ui.drawRectFilled(vec2(261 * Scale, line + 5 * Scale), vec2(275 * Scale, line + 19 * Scale), rgbm.colors.white)
    ui.drawTriangleFilled(vec2((261 + 2) * Scale, line + 12 * Scale), vec2((275 - 2) * Scale, line + 6 * Scale), vec2((275 - 2) * Scale, line + 18 * Scale), rgbm.colors.red)
end

function DrawRightSelectionArrow(line)
    ui.drawRectFilled(vec2(424 * Scale, line + 2 * Scale), vec2(444 * Scale, line + 22 * Scale), rgbm.colors.gray)
    ui.drawRectFilled(vec2(427 * Scale, line + 5 * Scale), vec2(441 * Scale, line + 19 * Scale), rgbm.colors.white)
    ui.drawTriangleFilled(vec2((427 + 2) * Scale, line + 6), vec2((427 + 2) * Scale, line + 18 * Scale), vec2((441 - 2) * Scale, line + 12 * Scale), rgbm.colors.red)
end

function ChangeSetting()
    if SelectedSetting == "MGU-K delivery mode" then
        local value = CAR.mgukDelivery + SelectOffsetX
        if CAR.mgukDelivery == CAR.mgukDeliveryCount - 1 and SelectOffsetX > 0 then
            value = 0
        elseif CAR.mgukDelivery == 0 and SelectOffsetX < 0 then
            value = CAR.mgukDeliveryCount - 1
        end
        ac.setMGUKDelivery(value)
    elseif SelectedSetting == "MGU-K recovery mode" then
        local value = CAR.mgukRecovery + SelectOffsetX
        if CAR.mgukRecovery == 10 and SelectOffsetX > 0 then
            value = 0
        elseif CAR.mgukRecovery == 0 and SelectOffsetX < 0 then
            value = 10
        end
        ac.setMGUKRecovery(value)
    elseif SelectedSetting == "MGU-H mode" then
        ac.setMGUHCharging(not CAR.mguhChargingBatteries)
    elseif SelectedSetting == "Brake bias coarse" then
        ac.setBrakeBias(CAR.brakeBias + 0.01 * SelectOffsetX)
    elseif SelectedSetting == "Brake bias fine" then
        ac.setBrakeBias(CAR.brakeBias + CAR.brakesBiasStep * SelectOffsetX)
    elseif SelectedSetting == "Traction Control mode" then
        local value = CAR.tractionControlMode + SelectOffsetX
        if CAR.tractionControlMode == CAR.tractionControlModes and SelectOffsetX > 0 then
            value = 0
        elseif CAR.tractionControlMode == 0 and SelectOffsetX < 0 then
            value = CAR.tractionControlModes
        end
        ac.setTC(value)
    elseif SelectedSetting == "ABS mode" then
        local value = CAR.absMode + SelectOffsetX
        if CAR.absMode == CAR.absModes and SelectOffsetX > 0 then
            value = 0
        elseif CAR.absMode == 0 and SelectOffsetX < 0 then
            value = CAR.absModes
        end
        ac.setABS(value)
    elseif SelectedSetting == "Engine brake setting" then
        local value = CAR.currentEngineBrakeSetting + SelectOffsetX
        if CAR.currentEngineBrakeSetting == CAR.engineBrakeSettingsCount - 1 and SelectOffsetX > 0 then
            value = 0
        elseif CAR.currentEngineBrakeSetting == 0 and SelectOffsetX < 0 then
            value = CAR.engineBrakeSettingsCount - 1
        end
        ac.setEngineBrakeSetting(value)
    elseif SelectedSetting == "Wiper mode" then
        local value = CAR.wiperMode + SelectOffsetX
        if CAR.wiperMode == CAR.wiperModes - 1 and SelectOffsetX > 0 then
            value = 0
        elseif CAR.wiperMode == 0 and SelectOffsetX < 0 then
            value = CAR.wiperModes
        end
        ac.setWiperMode(value)
    elseif SelectedSetting == "Light mode" then
        ac.setHeadlights(not CAR.headlightsActive)
    end
end
