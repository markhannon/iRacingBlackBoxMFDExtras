function FuelBlackBox()
    ui.beginScale()

    DrawArrows()

    -- background
    ui.drawRectFilled(vec2(33, 22), vec2(479, 323), rgbm.from0255(0, 0, 0, .75), 6)

    ui.endPivotScale(Scale, vec2(0, 22))

    ui.pushDWriteFont("fonts/eurostarblackextended.ttf")

    -- title
    ui.setCursor(vec2(41 * Scale, 22 + (3 * Scale)))
    ui.dwriteText("Fuel", 27 * Scale, rgbm.from0255(221, 182, 35))

    ui.popDWriteFont()

    ui.pushDWriteFont("Arial;Weight=Bold")




    -- Remaining
    ui.setCursor(vec2(0, 174 * Scale + 22))
    ui.dwriteTextAligned("Remaining:", 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(214 + 24 + 9, 30):scale(Scale), false, rgbm.from0255(221, 182, 35))

    ui.setCursor(vec2(260 * Scale, 174 * Scale + 22))
    ui.dwriteTextAligned(string.format("%.1f", math.round(CAR.fuel, 1)) .. " L", 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(100, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))



    -- Est Lap
    ui.setCursor(vec2(0, (174 + 27) * Scale + 22))
    ui.dwriteTextAligned("Est. Laps:", 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(214 + 24 + 9, 30):scale(Scale), false, rgbm.from0255(221, 182, 35))

    ui.setCursor(vec2(260 * Scale, (174 + 27) * Scale + 22))
    local text
    if CAR.fuelPerLap == 0 then
        text = "-"
    else
        text = math.round(CAR.fuel / CAR.fuelPerLap, 1)
    end
    ui.dwriteTextAligned(text, 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(100, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))

    ui.popDWriteFont()
end
