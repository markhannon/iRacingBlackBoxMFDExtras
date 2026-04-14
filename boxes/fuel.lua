local function Clamp(value, minValue, maxValue)
    return math.max(minValue, math.min(maxValue, value))
end


local function ApplyFuelAdjustments()
    FuelLapBuffer = tonumber(FuelLapBuffer) or 1

    if SelectOffsetY == "-" then
        SelectOffsetY = 1
    end

    SelectOffsetY = Clamp(SelectOffsetY, 1, 1)

    if SelectOffsetX == 0 then
        return
    end

    if SelectOffsetY == 1 then
        FuelLapBuffer = Clamp(math.round(FuelLapBuffer + 0.1 * SelectOffsetX, 1), 0, 10)
        FUEL_LAP_BUFFER_STORAGE:set(FuelLapBuffer)
    end

    SelectOffsetX = 0
end

function FuelBlackBox()
    ui.beginScale()

    DrawArrows()
    DrawWindow("Fuel", vec2(33, 22), vec2(479, 323))

    ApplyFuelAdjustments()

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

    DrawEditableValue("Margin (Laps):", string.format("%.1f", FuelLapBuffer), 0, 250 + 24 + 9, 86, SelectOffsetY == 1)

    DrawDisplayedValue("Estimated Next Pit:", fillNextPitText, 0, 260, 112)

    DrawDisplayedValue("Estimated to Finish:", fuelToEndText, 0, 260, 138)

    DrawDisplayedValue("Remaining:", remainingFuelText, 0, 260, 164)

    DrawDisplayedValue("Est. Laps:", estimatedLapsText, 0, 260, 190)

    DrawDisplayedValue("Est. Time:", estimatedTimeText, 0, 260, 216)

    DrawDisplayedValue("Avg / Lap:", averageFuelText, 0, 260, 242)

    DrawDisplayedValue("Last / Lap:", lastLapFuelText, 0, 260, 268)
end
