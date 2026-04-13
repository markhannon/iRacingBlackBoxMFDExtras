function TiresBlackBox()
    ui.beginScale()

    DrawArrows()

    -- background
    ui.drawRectFilled(vec2(33, 22), vec2(479, 323), rgbm.from0255(0, 0, 0, .75), 6)

    ui.endPivotScale(Scale, vec2(0, 22))

    ui.pushDWriteFont("fonts/eurostarblackextended.ttf")

    -- title
    ui.setCursor(vec2(41 * Scale, 22 + (3 * Scale)))
    ui.dwriteText("Tires", 27 * Scale, rgbm.from0255(221, 182, 35))

    ui.popDWriteFont()

    ui.pushDWriteFont("Arial;Weight=Bold")

    local titles = { "LF:", "RF:", "LR:", "RR:" }
    local lineY = 65
    local lineX

    for i = 0, 3 do
        if i == 2 then lineY = 147 end
        if i % 2 == 0 then lineX = 90 else lineX = 295 end

        ui.setCursor(vec2(0, lineY * Scale + 22))
        ui.dwriteTextAligned(titles[i + 1], 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(lineX + 24 + 9, 30):scale(Scale), false, rgbm.from0255(221, 182, 35))

        ui.setCursor(vec2(0, lineY * Scale + 22))
        ui.dwriteTextAligned(tostring(math.round(CAR.wheels[i].tyrePressure)) .. "psi", 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(lineX + 100 + 24 + 9, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))
    end

    -- Compound
    ui.setCursor(vec2(0, 188 * Scale + 22))
    ui.dwriteTextAligned("Compound:", 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(214 + 24 + 9, 30):scale(Scale), false, rgbm.from0255(221, 182, 35))

    ui.setCursor(vec2((245 + 24 + 9) * Scale, 188 * Scale + 22))
    ui.dwriteTextAligned(CAR:tyresName(), 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(100, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))

    ui.popDWriteFont()
end
