function TireInfoBlackBox()
    ui.beginScale()

    DrawArrows()
    DrawWindow("Tire Info", vec2(33, 22), vec2(479, 323))

    local valueWhite = rgbm.from0255(244, 244, 244)
    local wearYellow = rgbm.from0255(255, 255, 0)

    local titles = { "LF", "RF", "LR", "RR" }
    local lineY = 45
    local lineX

    local function ResolveCompoundName()
        local ok, value = pcall(function()
            return CAR:tyresName()
        end)
        if ok and type(value) == "string" and value ~= "" then
            return value
        end
        return "N/A"
    end

    local compoundName = ResolveCompoundName()

    local function GetFirstPositiveNumber(...)
        for index = 1, select("#", ...) do
            local candidate = select(index, ...)
            if type(candidate) == "number" and candidate > 0 then
                return candidate
            end
        end

        return nil
    end

    local function GetWheelNumberField(wheel, fieldName)
        if wheel == nil then return nil end

        local ok, value = pcall(function()
            return wheel[fieldName]
        end)

        if ok and type(value) == "number" then
            return value
        end

        return nil
    end

    local function GetMaximumOptimalTemperature(compound, minTemp)
        if type(compound) ~= "string" or type(minTemp) ~= "number" then
            return nil
        end

        if string.find(compound, "Street") then
            return minTemp + 10
        elseif string.find(compound, "Intermediate") then
            return minTemp + 10
        elseif string.find(compound, "Wet") then
            return minTemp + 10
        elseif string.find(compound, "Super") then
            return minTemp + 15
        elseif string.find(compound, "Soft") then
            return minTemp + 20
        elseif string.find(compound, "Medium") then
            return minTemp + 20
        elseif string.find(compound, "Hard") then
            return minTemp + 25
        else
            return minTemp + 30
        end
    end

    local function GetWheelTemperatureRange(wheel, compound)
        if wheel == nil then return nil, nil end

        local minTemp = GetFirstPositiveNumber(
            GetWheelNumberField(wheel, "tyreOptimumTemperature"),
            GetWheelNumberField(wheel, "tyreTemperatureMin"),
            GetWheelNumberField(wheel, "tyreMinTemperature"),
            GetWheelNumberField(wheel, "tyreTemperatureIdealMinimum"),
            GetWheelNumberField(wheel, "tyreWorkingTemperatureMin"),
            GetWheelNumberField(wheel, "tyreOptimalTemperatureMin")
        )
        local maxTemp = GetMaximumOptimalTemperature(compound, minTemp)

        if minTemp ~= nil and maxTemp ~= nil and maxTemp > minTemp then
            return minTemp, maxTemp
        end

        return nil, nil
    end

    local globalMinTemp = nil
    local globalMaxTemp = nil
    for i = 0, 3 do
        local wheelMinTemp, wheelMaxTemp = GetWheelTemperatureRange(CAR.wheels[i], compoundName)
        if wheelMinTemp ~= nil and wheelMaxTemp ~= nil then
            globalMinTemp = globalMinTemp ~= nil and math.min(globalMinTemp, wheelMinTemp) or wheelMinTemp
            globalMaxTemp = globalMaxTemp ~= nil and math.max(globalMaxTemp, wheelMaxTemp) or wheelMaxTemp
        end
    end

    local function GetTemperatureColor(temperature)
        if type(temperature) ~= "number" or globalMinTemp == nil or globalMaxTemp == nil then
            return valueWhite
        end

        if temperature < globalMinTemp then
            return rgbm.colors.blue
        end

        if temperature > globalMaxTemp then
            return rgbm.colors.red
        end

        return valueWhite
    end

    for i = 0, 3 do
        if i == 2 then lineY = 141 end
        if i % 2 == 0 then lineX = 68 else lineX = 284 end

        local wheel = CAR.wheels[i]
        local insideTemp = wheel.tyreInsideTemperature
        local middleTemp = wheel.tyreMiddleTemperature
        local outsideTemp = wheel.tyreOutsideTemperature
        local wearPercent = (1 - wheel.tyreWear) * 100

        local wearColor = valueWhite
        if wearPercent < 25 then
            wearColor = rgbm.colors.red
        elseif wearPercent < 50 then
            wearColor = wearYellow
        end

        DrawLabel(titles[i + 1], lineX + 60, lineY, 100, nil, ui.Alignment.Start)
        DrawValue(tostring(math.round(insideTemp)) .. "C", lineX, lineY + 28, 100, GetTemperatureColor(insideTemp), ui.Alignment.Start)
        DrawValue(tostring(math.round(middleTemp)) .. "C", lineX + 60, lineY + 28, 100, GetTemperatureColor(middleTemp), ui.Alignment.Start)
        DrawValue(tostring(math.round(outsideTemp)) .. "C", lineX + 120, lineY + 28, 100, GetTemperatureColor(outsideTemp), ui.Alignment.Start)
        DrawValue(tostring(math.round(wearPercent)) .. "%", lineX + 60, lineY + 56, 100, wearColor, ui.Alignment.Start)
    end

    local tempRangeText = "N/A"
    if globalMinTemp ~= nil and globalMaxTemp ~= nil then
        tempRangeText = string.format("%d-%dC", math.round(globalMinTemp), math.round(globalMaxTemp))
    end

    local summaryY = 248
    DrawLabel("Tyre:", 0, summaryY, 123)
    DrawValue(compoundName, 128, summaryY, 120, nil, ui.Alignment.End)
    DrawDisplayedValue("Range:", tempRangeText, 221, 349, summaryY, 120, ui.Alignment.Start, 123)

end
