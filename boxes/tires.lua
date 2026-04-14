function TiresBlackBox()
    ui.beginScale()

    DrawArrows()
    DrawWindow("Tires", vec2(33, 22), vec2(479, 323))

    local titles = { "LF:", "RF:", "LR:", "RR:" }
    local lineY = 65
    local lineX

    for i = 0, 3 do
        if i == 2 then lineY = 147 end
        if i % 2 == 0 then lineX = 90 else lineX = 295 end

        DrawLabel(titles[i + 1], 0, lineY, lineX + 24 + 9)
        DrawValue(tostring(math.round(CAR.wheels[i].tyrePressure)) .. "psi", 0, lineY, lineX + 100 + 24 + 9, nil, ui.Alignment.End)
    end

    -- Compound
    DrawDisplayedValue("Compound:", CAR:tyresName(), 0, 245 + 24 + 9, 188)
end
