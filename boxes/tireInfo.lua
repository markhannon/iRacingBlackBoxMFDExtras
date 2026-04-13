function TireInfoBlackBox()
    ui.beginScale()

    DrawArrows()
    DrawWindow("Tire Info", vec2(33, 22), vec2(479, 323))

    local titles = { "LF", "RF", "LR", "RR" }
    local lineY = 37
    local lineX

    for i = 0, 3 do
        if i == 2 then lineY = 133 end
        if i % 2 == 0 then lineX = 68 else lineX = 284 end

        DrawLabel(titles[i + 1], lineX + 60, lineY, 100, nil, ui.Alignment.Start)
        DrawValue(tostring(math.round(CAR.wheels[i].tyreInsideTemperature)) .. "C", lineX, lineY + 28, 100, nil, ui.Alignment.Start)
        DrawValue(tostring(math.round(CAR.wheels[i].tyreMiddleTemperature)) .. "C", lineX + 60, lineY + 28, 100, nil, ui.Alignment.Start)
        DrawValue(tostring(math.round(CAR.wheels[i].tyreOutsideTemperature)) .. "C", lineX + 120, lineY + 28, 100, nil, ui.Alignment.Start)
        DrawValue(tostring(math.round((1 - CAR.wheels[i].tyreWear) * 100)) .. "%", lineX + 60, lineY + 56, 100, nil, ui.Alignment.Start)
    end

end
