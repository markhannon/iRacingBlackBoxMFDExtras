function TiresBlackBox()
    ui.beginScale()

    DrawArrows()
    DrawWindow("Tires", vec2(33, 22), vec2(479, 323))

    local titles = { "LF:", "RF:", "LR:", "RR:" }
    local optimalPressures = {}
    local hasAllOptimal = true
    local lineY = 65
    local lineX

    local function GetWheelOptimalPressure(wheel)
        if wheel == nil then return nil end

        local candidates = {
            wheel.tyreReferencePressure,
            wheel.tyreReference,
            wheel.tyreOptimalPressure,
            wheel.tyrePressureIdeal,
            wheel.tyreTargetPressure
        }

        for _, candidate in ipairs(candidates) do
            if type(candidate) == "number" and candidate > 0 then
                return candidate
            end
        end

        return nil
    end

    for i = 0, 3 do
        optimalPressures[i] = GetWheelOptimalPressure(CAR.wheels[i])
        if optimalPressures[i] == nil then
            hasAllOptimal = false
        end
    end

    for i = 0, 3 do
        if i == 2 then lineY = 147 end
        if i % 2 == 0 then lineX = 90 else lineX = 295 end

        local actualPressure = CAR.wheels[i].tyrePressure
        local displayValue = string.format("%.1fpsi", actualPressure)

        if hasAllOptimal then
            local pressureDelta = actualPressure - optimalPressures[i]
            displayValue = string.format("%.1fpsi %+.1f", actualPressure, pressureDelta)
        end

        DrawLabel(titles[i + 1], 0, lineY, lineX + 24 + 9)
        DrawValue(displayValue, 0, lineY, lineX + 125 + 24 + 9, nil, ui.Alignment.End)
    end

    if hasAllOptimal then
        local frontOptimal = (optimalPressures[0] + optimalPressures[1]) / 2
        local rearOptimal = (optimalPressures[2] + optimalPressures[3]) / 2

        DrawDisplayedValue("Front Optimal:", string.format("%.0fpsi", frontOptimal), 0, 245 + 24 + 9, 188)
        DrawDisplayedValue("Rear Optimal:", string.format("%.0fpsi", rearOptimal), 0, 245 + 24 + 9, 218)
        DrawDisplayedValue("Compound:", CAR:tyresName(), 0, 245 + 24 + 9, 248)
    else
        DrawDisplayedValue("Compound:", CAR:tyresName(), 0, 245 + 24 + 9, 188)
    end
end
