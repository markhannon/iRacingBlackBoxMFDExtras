function RelativeBlackBox()
    ui.beginScale()

    DrawArrows()

    -- background
    ui.drawRectFilled(vec2(33, 93), vec2(479, 323), rgbm.from0255(0, 0, 0, .75), 6)

    ui.endPivotScale(Scale, vec2(0, 22))

    ui.pushDWriteFont("fonts/eurostarblackextended.ttf")

    -- title
    ui.setCursor(vec2(41 * Scale, 22 + (74 * Scale)))
    ui.dwriteText("Relative", 27 * Scale, rgbm.from0255(221, 182, 35))

    ui.popDWriteFont()

    ui.pushDWriteFont("Arial;Weight=Bold")

    -- get index sorted
    local positions = {}
    for i = 1, SIM.carsCount do
        positions[i] = {}
        positions[i].index = i - 1
        positions[i].pos = ac.getCar(i - 1).splinePosition
    end
    table.sort(positions, function(lhs, rhs) return lhs.pos > rhs.pos end)

    -- get position / index in table positions
    local myPos
    for i = 1, SIM.carsCount do
        if positions[i].index == CAR.index then
            myPos = i
        end
    end

    -- get the driver index around me
    local counter = 1
    local realIndex = {}
    if SIM.carsCount < 7 then
        realIndex[1] = 0
    else
        for i = myPos - 3, myPos + 3 do
            local j = i
            if j < 1 then
                j = SIM.carsCount + j
            elseif j > SIM.carsCount then
                j = j - SIM.carsCount
            end
            realIndex[counter] = positions[j].index
            counter = counter + 1
        end
    end

    -- draw names
    local lineY = 38 + 71
    for i = 1, #realIndex do
        local color = rgbm.from0255(244, 244, 244)

        if SESSION.type ~= ac.SessionType.Race then
            if realIndex[i] == CAR.index then color = rgbm.from0255(221, 182, 35) end
        else
            if realIndex[i] == CAR.index then
                color = rgbm.from0255(221, 182, 35)
            elseif ac.getCar(realIndex[i]).lapCount > CAR.lapCount then
                color = rgbm.colors.red
            elseif ac.getCar(realIndex[i]).lapCount < CAR.lapCount then
                color = rgbm.colors.blue
            end
        end

        ui.setCursor(vec2(0, lineY * Scale + 22))
        ui.dwriteTextAligned(DriverData[realIndex[i]].position, 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(32 + 24 + 9, 30):scale(Scale), false, color)

        ui.setCursor(vec2(0, lineY * Scale + 22))
        ui.dwriteTextAligned("#", 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(32 + 24 + 9 + 32, 30):scale(Scale), false, color)

        ui.setCursor(vec2(0, lineY * Scale + 22))
        ui.dwriteTextAligned(DriverData[realIndex[i]].driverNumber, 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(32 + 24 + 9 + 32 + 26, 30):scale(Scale), false, color)

        ui.setCursor(vec2((109 + 24 + 9) * Scale, lineY * Scale + 22))
        ui.dwriteTextAligned(DriverData[realIndex[i]].driverName, 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(300, 30):scale(Scale), false, color)

        ui.setCursor(vec2(0, lineY * Scale + 22))
        local timeText
        local myTime = nil
        local driverTime = nil

        local driverLap
        if i < 4 then
            if ac.getCar(realIndex[i]).lapCount == CAR.lapCount or ac.getCar(realIndex[i]).lapCount > CAR.lapCount then
                driverLap = CAR.lapCount + 1
            else
                driverLap = ac.getCar(realIndex[i]).lapCount + 1
            end
        elseif i > 4 then
            driverLap = ac.getCar(realIndex[i]).lapCount + 1
        end

        if i == 4 then
            myTime = nil
        elseif i < 4 then
            myTime = DriverSpline[CAR.index][CAR.lapCount + 1][DriverSpline[CAR.index][CAR.lapCount + 1].currentSpline - 1]
            driverTime = DriverSpline[realIndex[i]][driverLap][DriverSpline[CAR.index][CAR.lapCount + 1].currentSpline - 1]
        else
            myTime = DriverSpline[CAR.index][CAR.lapCount + 1][DriverSpline[realIndex[i]][driverLap].currentSpline - 1]
            driverTime = DriverSpline[realIndex[i]][driverLap][DriverSpline[realIndex[i]][driverLap].currentSpline - 1]
        end

        if myTime == nil or driverTime == nil then
            timeText = "0.0"
        else
            local seconds = math.round(myTime - driverTime, 1)
            timeText = string.format("%.1f", seconds)
        end
        ui.dwriteTextAligned(timeText, 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(437 + 24 + 9, 30):scale(Scale), false, color)

        lineY = lineY + 22
    end


    -- Lap
    ui.setCursor(vec2((24 + 9 + 9) * Scale, (209 + 65 - 5) * Scale + 22))
    ui.dwriteTextAligned("Lap:", 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(50, 30):scale(Scale), false, rgbm.from0255(221, 182, 35))

    ui.setCursor(vec2((55 + 24 + 9) * Scale, (209 + 65 - 5) * Scale + 22))
    local text = CAR.lapCount + 1
    if SESSION.type == ac.SessionType.Race then
        text = tostring(CAR.lapCount + 1) .. " / " .. SESSION.laps
    end
    ui.dwriteTextAligned(text, 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(32 + 24 + 9 + 32, 30):scale(Scale), false, color)

    -- Last
    ui.setCursor(vec2((290 + 24 + 9) * Scale, (209 + 65 - 5) * Scale + 22))
    ui.dwriteTextAligned("Last:", 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(50, 30):scale(Scale), false, rgbm.from0255(221, 182, 35))

    ui.setCursor(vec2(0 * Scale, (209 + 65 - 5) * Scale + 22))
    if CAR.previousLapTimeMs == 0 then
        text = "---"
    else
        local minutes = CAR.previousLapTimeMs / 60E3
        local seconds = (minutes % 1) * 60
        local milliseconds = math.round((seconds % 1) * 1000)
        text = string.format("%d:%02d.%03d", minutes, seconds, milliseconds)
        if not CAR.isLastLapValid then text = "*" .. text end
    end
    ui.dwriteTextAligned(text, 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(437 + 24 + 9, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))

    ui.popDWriteFont()


    -- ? quali mode
    -- ? race mode
end
