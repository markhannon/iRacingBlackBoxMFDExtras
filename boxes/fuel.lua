function FuelBlackBox()
    ui.beginScale()

    DrawArrows()
    DrawWindow("Fuel", vec2(33, 22), vec2(479, 323))

    
    local estimatedLaps = "-"
    if CAR.fuelPerLap ~= 0 then
        estimatedLaps = tostring(math.round(CAR.fuel / CAR.fuelPerLap, 1))
    end
    
    DrawLabel("Fuel / Lap:", 0, 100)
    DrawValue(CAR.fuelPerLap, 260, 100)
    DrawLabel("Est. Laps:", 0, 130)
    DrawValue(estimatedLaps, 260, 130)
    DrawLabel("Remaining:", 0, 174)
    DrawValue(string.format("%.1f", math.round(CAR.fuel, 1)) .. " L", 260, 174)
end
