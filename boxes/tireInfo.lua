function TireInfoBlackBox()
    ui.beginScale()

    DrawArrows()

    -- background
    ui.drawRectFilled(vec2(33, 22), vec2(479, 323), rgbm.from0255(0, 0, 0, .75), 6)

    ui.endPivotScale(Scale, vec2(0, 22))

    ui.pushDWriteFont("fonts/eurostarblackextended.ttf")

    -- title
    ui.setCursor(vec2(41 * Scale, 22 + (3 * Scale)))
    ui.dwriteText("Tire Info", 27 * Scale, rgbm.from0255(221, 182, 35))

    ui.popDWriteFont()

    ui.pushDWriteFont("Arial;Weight=Bold")

    local titles = { "LF", "RF", "LR", "RR" }
    local lineY = 37
    local lineX

    for i = 0, 3 do
        if i == 2 then lineY = 133 end
        if i % 2 == 0 then lineX = 68 else lineX = 284 end

        ui.setCursor(vec2((lineX + 60) * Scale, lineY * Scale + 22))
        ui.dwriteTextAligned(titles[i + 1], 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(100, 30):scale(Scale), false, rgbm.from0255(221, 182, 35))

        ui.setCursor(vec2(lineX * Scale, (lineY + 28) * Scale + 22))
        ui.dwriteTextAligned(tostring(math.round(CAR.wheels[i].tyreInsideTemperature)) .. "C", 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(100, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))

        ui.setCursor(vec2((lineX + 60) * Scale, (lineY + 28) * Scale + 22))
        ui.dwriteTextAligned(tostring(math.round(CAR.wheels[i].tyreMiddleTemperature)) .. "C", 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(100, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))

        ui.setCursor(vec2((lineX + 60 + 60) * Scale, (lineY + 28) * Scale + 22))
        ui.dwriteTextAligned(tostring(math.round(CAR.wheels[i].tyreOutsideTemperature)) .. "C", 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(100, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))

        ui.setCursor(vec2((lineX + 60) * Scale, (lineY + 28 + 28) * Scale + 22))
        ui.dwriteTextAligned(tostring(math.round((1 - CAR.wheels[i].tyreWear) * 100)) .. "%", 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(100, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))
    end

    ui.popDWriteFont()
end
