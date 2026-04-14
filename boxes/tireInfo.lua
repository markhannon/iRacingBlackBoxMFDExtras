function TireInfoBlackBox()
    ui.beginScale()

    DrawArrows()
    DrawWindow("Tire Info", vec2(33, 22), vec2(479, 323))

    local valueWhite = rgbm.from0255(244, 244, 244)
    local wearYellow = rgbm.from0255(255, 255, 0)

    local titles = { "LF", "RF", "LR", "RR" }
    local lineY = 37
    local lineX

    local function GetWheelTemperatureRange(wheel)
        if wheel == nil then return nil, nil end

        local minCandidates = {
            wheel.tyreTemperatureMin,
            wheel.tyreMinTemperature,
            wheel.tyreTemperatureIdealMinimum,
            wheel.tyreWorkingTemperatureMin,
            wheel.tyreOptimalTemperatureMin
        }
        local maxCandidates = {
            wheel.tyreTemperatureMax,
            wheel.tyreMaxTemperature,
            wheel.tyreTemperatureIdealMaximum,
            wheel.tyreWorkingTemperatureMax,
            wheel.tyreOptimalTemperatureMax
        }

        local minTemp = nil
        local maxTemp = nil

        for _, candidate in ipairs(minCandidates) do
            if type(candidate) == "number" and candidate > 0 then
                minTemp = candidate
                break
            end
        end

        for _, candidate in ipairs(maxCandidates) do
            if type(candidate) == "number" and candidate > 0 then
                maxTemp = candidate
                break
            end
        end

        if minTemp ~= nil and maxTemp ~= nil and maxTemp > minTemp then
            return minTemp, maxTemp
        end

        return nil, nil
    end

    local globalMinTemp = nil
    local globalMaxTemp = nil
    for i = 0, 3 do
        local wheelMinTemp, wheelMaxTemp = GetWheelTemperatureRange(CAR.wheels[i])
        if wheelMinTemp ~= nil and wheelMaxTemp ~= nil then
            globalMinTemp = globalMinTemp ~= nil and math.min(globalMinTemp, wheelMinTemp) or wheelMinTemp
            globalMaxTemp = globalMaxTemp ~= nil and math.max(globalMaxTemp, wheelMaxTemp) or wheelMaxTemp
        end
    end

    local function GetTemperatureColor(temperature)
        if globalMinTemp == nil or globalMaxTemp == nil then
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
        if i == 2 then lineY = 133 end
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

    DrawDisplayedValue("Temp Range:", tempRangeText, 0, 245 + 24 + 9, 218)
    DrawDisplayedValue("Compound:", CAR:tyresName(), 0, 245 + 24 + 9, 248)

end
