local firstIndex

function StandingsBlackBox()
    ui.beginScale()

    DrawArrows()

    -- background
    ui.drawRectFilled(vec2(33, 87), vec2(479, 323), rgbm.from0255(0, 0, 0, .75), 6)

    ui.endPivotScale(Scale, vec2(0, 22))

    ui.pushDWriteFont("fonts/eurostarblackextended.ttf")

    -- title
    ui.setCursor(vec2(41 * Scale, 22 + (68 * Scale)))
    ui.dwriteText("Standings", 27 * Scale, rgbm.from0255(221, 182, 35))

    ui.popDWriteFont()

    ui.pushDWriteFont("Arial;Weight=Bold")

    local startPos = DriverData[CAR.index].position - 3
    local endPos = startPos + 6

    if SIM.carsCount < 7 then
        startPos = 1
        endPos = SIM.carsCount
    elseif startPos < 1 then
        startPos = 1
        endPos = 7
    elseif endPos > SIM.carsCount then
        startPos = SIM.carsCount - 6
        endPos = SIM.carsCount
    end

    if SelectOffsetY == "-" then SelectOffsetY = 0 end

    if SIM.carsCount < 7 then
        SelectOffsetY = 0
    elseif SelectOffsetY < 1 - startPos then
        SelectOffsetY = 1 - startPos
    elseif SelectOffsetY > SIM.carsCount - 6 - startPos then
        SelectOffsetY = SIM.carsCount - 6 - startPos
    end

    startPos = startPos + SelectOffsetY
    endPos = endPos + SelectOffsetY

    local lineY = 45 + 65 - 7
    if SIM.carsCount == 1 then
        lineY = lineY + 23 * 3
    end

    for i=0, SIM.carsCount-1 do
        if DriverData[i].position == 1 then
            firstIndex = i
        end
    end

    for currPos = startPos, endPos do
        local color = rgbm.from0255(244, 244, 244)
        if currPos == DriverData[CAR.index].position then color = rgbm.from0255(221, 182, 35) end

        local driverIndex
        for i = 0, SIM.carsCount - 1 do
            if DriverData[i].position == currPos then
                driverIndex = i
            end
        end

        ui.setCursor(vec2(0, lineY * Scale + 22))
        ui.dwriteTextAligned(DriverData[driverIndex].position, 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(32 + 24 + 9, 30):scale(Scale), false, color)

        ui.setCursor(vec2(0, lineY * Scale + 22))
        ui.dwriteTextAligned("#", 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(32 + 24 + 9 + 32, 30):scale(Scale), false, color)

        ui.setCursor(vec2(0, lineY * Scale + 22))
        ui.dwriteTextAligned(DriverData[driverIndex].driverNumber, 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(32 + 24 + 9 + 32 + 26, 30):scale(Scale), false, color)

        ui.setCursor(vec2((109 + 24 + 9) * Scale, lineY * Scale + 22))
        ui.dwriteTextAligned(DriverData[driverIndex].driverName, 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(300, 30):scale(Scale), false, color)

        ui.setCursor(vec2(0, lineY * Scale + 22))
        local timeText
        if SESSION.type == ac.SessionType.Race then
            if DriverData[driverIndex].position == 1 then
                timeText = "---"
            else
                local ownTime = DriverSpline[driverIndex][ac.getCar(driverIndex).lapCount + 1][DriverSpline[driverIndex][ac.getCar(driverIndex).lapCount + 1].currentSpline - 1]
                local firstTime = DriverSpline[firstIndex][ac.getCar(driverIndex).lapCount + 1][DriverSpline[driverIndex][ac.getCar(driverIndex).lapCount + 1].currentSpline - 1]
                if ownTime == nil or firstTime == nil then
                    timeText = "---"
                else
                    local seconds = math.round(firstTime - ownTime, 1)
                    timeText = string.format("%.1f", seconds)
                end
            end
        else
            if DriverData[driverIndex].bestLap == 0 then
                timeText = "---"
            else
                local minutes = DriverData[driverIndex].bestLap / 60E3
                local seconds = (minutes % 1) * 60
                local milliseconds = math.round((seconds % 1) * 1000)
                timeText = string.format("%d:%02d.%03d", minutes, seconds, milliseconds)
            end
        end
        ui.dwriteTextAligned(timeText, 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(437 + 24 + 9, 30):scale(Scale), false, color)

        lineY = lineY + 23
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
end
