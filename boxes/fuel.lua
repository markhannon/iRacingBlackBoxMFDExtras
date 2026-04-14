local function Clamp(value, minValue, maxValue)
    return math.max(minValue, math.min(maxValue, value))
end

local function GetAverageFuelPerLap()
    if FuelAverageUsagePerLap ~= nil and FuelAverageUsagePerLap > 0 then
        return FuelAverageUsagePerLap
    end

    if CAR.fuelPerLap ~= nil and CAR.fuelPerLap > 0 then
        return CAR.fuelPerLap
    end

    return 0
end

local function GetReferenceLapTimeMs()
    if CAR.previousLapTimeMs ~= nil and CAR.previousLapTimeMs > 0 then
        return CAR.previousLapTimeMs
    end

    if DriverData[CAR.index] ~= nil and DriverData[CAR.index].bestLap ~= nil and DriverData[CAR.index].bestLap > 0 then
        return DriverData[CAR.index].bestLap
    end

    if CAR.lapTimeMs ~= nil and CAR.lapTimeMs > 0 then
        return CAR.lapTimeMs
    end

    return 0
end

local function GetEstimatedLapsRemaining(averageFuelPerLap)
    if averageFuelPerLap <= 0 then
        return nil, "-"
    end

    local estimatedLaps = math.round(CAR.fuel / averageFuelPerLap, 1)
    return estimatedLaps, string.format("%.1f", estimatedLaps)
end

local function GetEstimatedTimeText(estimatedLaps)
    if estimatedLaps == nil then
        return "-"
    end

    local referenceLapTimeMs = GetReferenceLapTimeMs()
    if referenceLapTimeMs <= 0 then
        return "-"
    end

    local estimatedTimeMs = estimatedLaps * referenceLapTimeMs
    local minutes = math.floor(estimatedTimeMs / 60000)
    local seconds = math.floor((estimatedTimeMs % 60000) / 1000)
    return string.format("%d:%02d", minutes, seconds)
end

local function GetFuelToEnd(averageFuelPerLap)
    if averageFuelPerLap <= 0 then
        return nil, nil
    end

    local remainingLaps = nil
    local marginFuel = 0
    local isTimedSession = SESSION.isTimedRace or SIM.isTimedRace or SESSION.type ~= ac.SessionType.Race

    if not isTimedSession and SESSION.laps ~= nil and SESSION.laps > 0 then
        remainingLaps = math.max(0, SESSION.laps - CAR.lapCount) + FuelLapBuffer
    else
        local referenceLapTimeMs = GetReferenceLapTimeMs()
        if referenceLapTimeMs > 0 and SIM.sessionTimeLeft > 0 then
            remainingLaps = math.ceil(SIM.sessionTimeLeft / referenceLapTimeMs)
            marginFuel = averageFuelPerLap * FuelLapBuffer
        end
    end

    if remainingLaps == nil then
        return nil, nil
    end

    local fuelToEnd = math.max(0, remainingLaps * averageFuelPerLap + marginFuel - CAR.fuel)

    return remainingLaps, fuelToEnd
end

local function GetFillNextPit(fuelToEnd)
    if fuelToEnd == nil then
        return "N/A"
    end

    if CAR.maxFuel ~= nil and CAR.maxFuel > 0 then
        local headroom = math.max(0, CAR.maxFuel - CAR.fuel)
        return string.format("%.1f L", math.round(math.min(fuelToEnd, headroom), 1))
    end

    return "N/A"
end

local function ApplyFuelAdjustments()
    FuelPitAddLitres = tonumber(FuelPitAddLitres) or 0
    FuelLapBuffer = tonumber(FuelLapBuffer) or 1

    if SelectOffsetY == "-" then
        SelectOffsetY = 1
    end

    SelectOffsetY = Clamp(SelectOffsetY, 1, 1)

    if SelectOffsetX == 0 then
        return
    end

    if SelectOffsetY == 0 then
        FuelPitAddLitres = math.max(0, math.round(FuelPitAddLitres + 0.5 * SelectOffsetX, 1))
        FUEL_PIT_ADD_STORAGE:set(FuelPitAddLitres)
    elseif SelectOffsetY == 1 then
        FuelLapBuffer = Clamp(math.round(FuelLapBuffer + 0.1 * SelectOffsetX, 1), 0, 10)
        FUEL_LAP_BUFFER_STORAGE:set(FuelLapBuffer)
    end

    SelectOffsetX = 0
end

local function DrawEditableFuelRow(label, value, y, selected)
    local highlightColor = rgbm.from0255(43, 53, 78)

    if selected then
        local line = y * Scale + 22
        ui.drawRectFilled(vec2((20 + 24 + 9) * Scale, line), vec2((422 + 24 + 9) * Scale, line + 22.6 * Scale), highlightColor)

        if DrawLeftSelectionArrow ~= nil then DrawLeftSelectionArrow(line) end
        if DrawRightSelectionArrow ~= nil then DrawRightSelectionArrow(line) end
    end

    DrawLabel(label, 0, y)
    DrawValue(value, 250 + 24 + 9, y, 100, nil, ui.Alignment.Start)
end

function FuelBlackBox()
    ui.beginScale()

    DrawArrows()
    DrawWindow("Fuel", vec2(33, 22), vec2(479, 323))

    ApplyFuelAdjustments()

    FuelPitAddLitres = tonumber(FuelPitAddLitres) or 0
    FuelLapBuffer = tonumber(FuelLapBuffer) or 1

    local averageFuelPerLap = GetAverageFuelPerLap()
    local averageFuelText = averageFuelPerLap > 0 and string.format("%.2f L", math.round(averageFuelPerLap, 2)) or "-"
    local lastLapFuelText = FuelLastLapUsage ~= nil and FuelLastLapUsage > 0 and string.format("%.2f L", math.round(FuelLastLapUsage, 2)) or "-"
    local estimatedLaps, estimatedLapsText = GetEstimatedLapsRemaining(averageFuelPerLap)
    local estimatedTimeText = GetEstimatedTimeText(estimatedLaps)
    local _, fuelToEnd = GetFuelToEnd(averageFuelPerLap)
    local fuelToEndText = fuelToEnd ~= nil and string.format("%.1f L", math.round(fuelToEnd, 1)) or "-"
    local fillNextPitText = GetFillNextPit(fuelToEnd)

    local remainingFuelText = string.format("%.1f L", math.round(CAR.fuel, 1))
    if CAR.maxFuel ~= nil and CAR.maxFuel > 0 then
        remainingFuelText = string.format("%.1f / %.1f L", math.round(CAR.fuel, 1), math.round(CAR.maxFuel, 1))
    end

    -- DrawEditableFuelRow("Add Next Pit:", string.format("%.1f L", FuelPitAddLitres), 60, SelectOffsetY == 0)
    DrawEditableFuelRow("Margin (Laps):", string.format("%.1f", FuelLapBuffer), 86, SelectOffsetY == 1)

    DrawLabel("Estimated Next Pit:", 0, 112)
    DrawValue(fillNextPitText, 260, 112)

    DrawLabel("Estimated to Finish:", 0, 138)
    DrawValue(fuelToEndText, 260, 138)

    DrawLabel("Remaining:", 0, 164)
    DrawValue(remainingFuelText, 260, 164)

    DrawLabel("Est. Laps:", 0, 190)
    DrawValue(estimatedLapsText, 260, 190)

    DrawLabel("Est. Time:", 0, 216)
    DrawValue(estimatedTimeText, 260, 216)

    DrawLabel("Avg / Lap:", 0, 242)
    DrawValue(averageFuelText, 260, 242)

    DrawLabel("Last / Lap:", 0, 268)
    DrawValue(lastLapFuelText, 260, 268)
end
