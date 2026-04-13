function LapTimingBlackBox()
    ui.beginScale()

    DrawArrows()

    -- background
    ui.drawRectFilled(vec2(33, 22 + 50), vec2(479, 323), rgbm.from0255(0, 0, 0, .75), 6)

    ui.endPivotScale(Scale, vec2(0, 22))

    ui.pushDWriteFont("fonts/eurostarblackextended.ttf")

    local minutes
    local seconds
    local milliseconds
    local timeText

    -- title
    ui.setCursor(vec2(41 * Scale, 22 + ((3 + 50) * Scale)))
    ui.dwriteText("Lap Timing", 27 * Scale, rgbm.from0255(221, 182, 35))

    ui.popDWriteFont()

    -- day + time
    ui.pushDWriteFont("Arial;Weight=Bold")
    ui.setCursor(vec2(357 * Scale, (60 * Scale) + 22))

    -- clock
    ui.dwriteText(
        string.format("%s %02d:%02d:%02d", os.date("%a", SIM.timestamp), SIM.timeHours, SIM.timeMinutes, SIM.timeSeconds),
        17 * Scale, rgbm.from0255(221, 182, 35))



    -- Remaining
    if SIM.isTimedRace or SIM.raceSessionType ~= ac.SessionType.Race then
        ui.setCursor(vec2(0 * Scale, (88 * Scale) + 22))
        local timeLeft = SIM.sessionTimeLeft
        if timeLeft < 0 then
            ui.dwriteTextAligned("Elapsed:", 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(361, 30):scale(Scale), false, rgbm.from0255(221, 182, 35))

            ui.setCursor(vec2(0, (88 * Scale) + 22))
            minutes = SIM.currentSessionTime / 60E3
            seconds = (minutes % 1) * 60
            timeText = string.format("%02d:%02d", minutes, seconds)
        else
            ui.dwriteTextAligned("Remaining:", 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(361, 30):scale(Scale), false, rgbm.from0255(221, 182, 35))

            ui.setCursor(vec2(0, (88 * Scale) + 22))
            minutes = SIM.sessionTimeLeft / 60E3
            seconds = (minutes % 1) * 60
            timeText = string.format("%02d:%02d", minutes, seconds)
        end

        ui.dwriteTextAligned(timeText, 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(466, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))
    end



    -- Lap
    ui.setCursor(vec2(43 * Scale, (114 * Scale) + 22))
    ui.dwriteTextAligned("Lap:", 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(60, 30):scale(Scale), false, rgbm.from0255(221, 182, 35))

    ui.setCursor(vec2(121 * Scale, (114 * Scale) + 22))
    ui.dwriteTextAligned(CAR.lapCount + 1, 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(60, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))

    -- Curr
    ui.setCursor(vec2(0 * Scale, (114 * Scale) + 22))
    ui.dwriteTextAligned("Curr:", 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(361, 30):scale(Scale), false, rgbm.from0255(221, 182, 35))

    ui.setCursor(vec2(0, (114 * Scale) + 22))
    minutes = CAR.lapTimeMs / 60E3
    seconds = (minutes % 1) * 60
    milliseconds = ((seconds % 1) * 1000) / 100
    if minutes < 1 then
        timeText = string.format("%d.%1d", seconds, milliseconds)
    else
        timeText = string.format("%d:%02d.%1d", minutes, seconds, milliseconds)
    end
    if not CAR.isLapValid then timeText = "*" .. timeText end
    ui.dwriteTextAligned(timeText, 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(466, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))



    -- To Go
    if SESSION.type == ac.SessionType.Race and not SESSION.isTimedRace then
        ui.setCursor(vec2(43 * Scale, (140 * Scale) + 22))
        ui.dwriteTextAligned("To Go:", 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(60, 30):scale(Scale), false, rgbm.from0255(221, 182, 35))

        ui.setCursor(vec2(121 * Scale, (140 * Scale) + 22))
        ui.dwriteTextAligned(SESSION.laps - (CAR.lapCount), 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(60, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))
    end

    -- Last
    ui.setCursor(vec2(0 * Scale, (140 * Scale) + 22))
    ui.dwriteTextAligned("Last:", 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(361, 30):scale(Scale), false, rgbm.from0255(221, 182, 35))

    ui.setCursor(vec2(0, (140 * Scale) + 22))
    if CAR.previousLapTimeMs == 0 then
        timeText = "---"
    else
        minutes = CAR.previousLapTimeMs / 60E3
        seconds = (minutes % 1) * 60
        milliseconds = math.round((seconds % 1) * 1000)
        if minutes < 1 then
            timeText = string.format("%d.%03d", seconds, milliseconds)
        else
            timeText = string.format("%d:%02d.%03d", minutes, seconds, milliseconds)
        end
        if not CAR.isLastLapValid then timeText = "*" .. timeText end
    end
    ui.dwriteTextAligned(timeText, 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(466, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))



    -- Pos
    ui.setCursor(vec2(43 * Scale, (166 * Scale) + 22))
    ui.dwriteTextAligned("Pos:", 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(60, 30):scale(Scale), false, rgbm.from0255(221, 182, 35))

    ui.setCursor(vec2(121 * Scale, (166 * Scale) + 22))
    ui.dwriteTextAligned(DriverData[CAR.index].position, 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(60, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))

    -- Best
    ui.setCursor(vec2(271 * Scale, (166 * Scale) + 22))
    ui.dwriteTextAligned("Best:", 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(60, 30):scale(Scale), false, rgbm.from0255(221, 182, 35))

    ui.setCursor(vec2(0 * Scale, (166 * Scale) + 22))
    if DriverData[CAR.index].bestLapLap == 0 then
        timeText = "-"
    else
        timeText = DriverData[CAR.index].bestLapLap
    end
    ui.dwriteTextAligned(timeText, 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(361, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))

    ui.setCursor(vec2(0 * Scale, (166 * Scale) + 22))
    if DriverData[CAR.index].bestLap == 0 then
        timeText = "---"
    else
        minutes = DriverData[CAR.index].bestLap / 60E3
        seconds = (minutes % 1) * 60
        milliseconds = math.round((seconds % 1) * 1000)
        if minutes < 1 then
            timeText = string.format("%d.%03d", seconds, milliseconds)
        else
            timeText = string.format("%d:%02d.%03d", minutes, seconds, milliseconds)
        end
    end
    ui.dwriteTextAligned(timeText, 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(466, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))

    -- ahead calculations
    local driverIndex
    if DriverData[CAR.index].position == 1 then driverIndex = -1 end
    for i = 0, SIM.carsCount - 1 do
        if DriverData[i].position == DriverData[CAR.index].position - 1 then
            driverIndex = i
        end
    end

    -- Ahead Text
    ui.setCursor(vec2(43 * Scale, (217 * Scale) + 22))
    ui.dwriteTextAligned("Ahead:", 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(60, 30):scale(Scale), false, rgbm.from0255(221, 182, 35))

    -- Ahead #
    ui.setCursor(vec2(121 * Scale, (217 * Scale) + 22))
    ui.dwriteTextAligned("#", 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(200, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))

    -- Ahead Number
    ui.setCursor(vec2(0, (217 * Scale) + 22))
    ui.dwriteTextAligned(DriverData[driverIndex].driverNumber, 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(160, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))

    -- Ahead name
    ui.setCursor(vec2(168 * Scale, (217 * Scale) + 22))
    ui.dwriteTextAligned(DriverData[driverIndex].driverName, 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(300, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))

    -- Ahead interval
    ui.setCursor(vec2(0, (217 * Scale) + 22))

    if SESSION.type == ac.SessionType.Race then
        if DriverData[CAR.index].position == 1 then
            timeText = "---"
        else
            local myTime = DriverSpline[CAR.index][CAR.lapCount + 1][DriverSpline[CAR.index][CAR.lapCount + 1].currentSpline - 1]
            local aheadTime = DriverSpline[driverIndex][CAR.lapCount + 1][DriverSpline[CAR.index][CAR.lapCount + 1].currentSpline - 1]
            if myTime == nil or aheadTime == nil then
                timeText = "---"
            else
                seconds = math.round(myTime - aheadTime, 1)
                timeText = string.format("%.1f", seconds)
            end
        end
    else
        if DriverData[CAR.index].position == 1 or DriverData[driverIndex].bestLap == 0 or DriverData[CAR.index].bestLap == 0 then
            timeText = "---"
        else
            local tmp = DriverData[CAR.index].bestLap / 1000 - DriverData[driverIndex].bestLap / 1000
            timeText = string.format("+%.3f", tmp)
        end
    end
    ui.dwriteTextAligned(timeText, 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(466, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))



    -- behind calculations
    if DriverData[CAR.index].position == SIM.carsCount then driverIndex = -1 end
    for i = 0, SIM.carsCount - 1 do
        if DriverData[i].position == DriverData[CAR.index].position + 1 then
            driverIndex = i
        end
    end

    -- Behind Text
    ui.setCursor(vec2(43 * Scale, (243 * Scale) + 22))
    ui.dwriteTextAligned("Behind:", 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(60, 30):scale(Scale), false, rgbm.from0255(221, 182, 35))

    -- Behind #
    ui.setCursor(vec2(121 * Scale, (243 * Scale) + 22))
    ui.dwriteTextAligned("#", 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(200, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))

    -- Behind Number
    ui.setCursor(vec2(0, (243 * Scale) + 22))
    ui.dwriteTextAligned(DriverData[driverIndex].driverNumber, 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(160, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))

    -- Behind name
    ui.setCursor(vec2(168 * Scale, (243 * Scale) + 22))
    ui.dwriteTextAligned(DriverData[driverIndex].driverName, 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(300, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))

    -- Behind interval
    ui.setCursor(vec2(0, (243 * Scale) + 22))
    if SESSION.type == ac.SessionType.Race then
        if DriverData[CAR.index].position == SIM.carsCount then
            timeText = "---"
        else
            local myTime = DriverSpline[CAR.index][ac.getCar(driverIndex).lapCount + 1][DriverSpline[driverIndex][ac.getCar(driverIndex).lapCount + 1].currentSpline - 1]
            local aheadTime = DriverSpline[driverIndex][ac.getCar(driverIndex).lapCount + 1][DriverSpline[driverIndex][ac.getCar(driverIndex).lapCount + 1].currentSpline - 1]
            if myTime == nil or aheadTime == nil then
                timeText = "---"
            else
                seconds = math.round(myTime - aheadTime, 1)
                timeText = string.format("%.1f", seconds)
            end
        end
    else
        if DriverData[CAR.index].position == SIM.carsCount or DriverData[driverIndex].bestLap == 0 or DriverData[CAR.index].bestLap == 0 then
            timeText = "---"
        else
            local tmp = DriverData[CAR.index].bestLap / 1000 - DriverData[driverIndex].bestLap / 1000
            timeText = string.format("%.3f", tmp)
        end
    end
    ui.dwriteTextAligned(timeText, 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(466, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))


    -- Incident count
    ui.setCursor(vec2(43 * Scale, (269 * Scale) + 22))
    ui.dwriteTextAligned("Incident count:", 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(200, 30):scale(Scale), false, rgbm.from0255(221, 182, 35))

    ui.setCursor(vec2((43 + 139) * Scale, (269 * Scale) + 22))
    ui.dwriteTextAligned(DriverData[CAR.index].incidentCount .. "x", 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(200, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))

    ui.popDWriteFont()
end
