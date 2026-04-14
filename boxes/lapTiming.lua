function LapTimingBlackBox(showArrows, showClock)
    ui.beginScale()

    if showArrows ~= false then DrawArrows() end
    DrawWindow("Lap Timing", vec2(33, 22), vec2(479, 323), showClock)

    local minutes
    local seconds
    local milliseconds
    local timeText
    local showDriverNumber = ShowDriverNumber == true
    local rowY = {
        summary = 88,
        current = 114,
        last = 140,
        best = 166,
        ahead = 217,
        behind = 243,
        incidents = 269
    }

    ui.pushDWriteFont("Arial;Weight=Bold")
    -- Lap summary (includes laps to go for lap-limited races)
    ui.setCursor(vec2(43 * Scale, (rowY.summary * Scale) + 22))
    ui.dwriteTextAligned("Lap:", 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(60, 30):scale(Scale), false, rgbm.from0255(221, 182, 35))

    local lapSummary = tostring(CAR.lapCount + 1)
    if SESSION.type == ac.SessionType.Race and not SESSION.isTimedRace and SESSION.laps > 0 then
        local lapsToGo = math.max(SESSION.laps - CAR.lapCount, 0)
        lapSummary = string.format("%d (%d to go)", CAR.lapCount + 1, lapsToGo)
    end

    ui.setCursor(vec2(121 * Scale, (rowY.summary * Scale) + 22))
    ui.dwriteTextAligned(lapSummary, 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(180, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))

    -- Remaining / Elapsed
    if SIM.isTimedRace or SIM.raceSessionType ~= ac.SessionType.Race then
        ui.setCursor(vec2(0 * Scale, (rowY.summary * Scale) + 22))
        local timeLeft = SIM.sessionTimeLeft
        if timeLeft < 0 then
            ui.dwriteTextAligned("Elapsed:", 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(361, 30):scale(Scale), false, rgbm.from0255(221, 182, 35))

            ui.setCursor(vec2(0, (rowY.summary * Scale) + 22))
            timeText = FormatSessionDuration(SIM.currentSessionTime)
        else
            ui.dwriteTextAligned("Remaining:", 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(361, 30):scale(Scale), false, rgbm.from0255(221, 182, 35))

            ui.setCursor(vec2(0, (rowY.summary * Scale) + 22))
            timeText = FormatSessionDuration(SIM.sessionTimeLeft)
        end

        ui.dwriteTextAligned(timeText, 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(466, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))
    end


    -- Pos (hybrid extra)
    ui.setCursor(vec2(43 * Scale, (rowY.current * Scale) + 22))
    ui.dwriteTextAligned("Pos:", 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(60, 30):scale(Scale), false, rgbm.from0255(221, 182, 35))

    ui.setCursor(vec2(121 * Scale, (rowY.current * Scale) + 22))
    ui.dwriteTextAligned(DriverData[CAR.index].position, 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(60, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))

    -- Curr
    ui.setCursor(vec2(0 * Scale, (rowY.current * Scale) + 22))
    ui.dwriteTextAligned("Curr:", 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(361, 30):scale(Scale), false, rgbm.from0255(221, 182, 35))

    ui.setCursor(vec2(0, (rowY.current * Scale) + 22))
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


    -- Last
    ui.setCursor(vec2(0 * Scale, (rowY.last * Scale) + 22))
    ui.dwriteTextAligned("Last:", 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(361, 30):scale(Scale), false, rgbm.from0255(221, 182, 35))

    ui.setCursor(vec2(0, (rowY.last * Scale) + 22))
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


    -- Delta to driver's own best in this session
    ui.setCursor(vec2(43 * Scale, (rowY.best * Scale) + 22))
    ui.dwriteTextAligned("Delta:", 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(80, 30):scale(Scale), false, rgbm.from0255(221, 182, 35))

    ui.setCursor(vec2(121 * Scale, (rowY.best * Scale) + 22))
    local deltaColor = rgbm.from0255(244, 244, 244)
    local delta = CAR.performanceMeter
    if type(delta) ~= "number" then
        timeText = "---"
    else
        if math.abs(delta) > 1000 then
            timeText = "inf"
        elseif math.abs(delta) > 100 then
            timeText = string.format("%.0f", delta)
        elseif math.abs(delta) > 10 then
            timeText = string.format("%.1f", delta)
        else
            timeText = string.format("%.2f", delta)
        end

        if delta > 0 then
            timeText = "+" .. timeText
            deltaColor = rgbm.from0255(226, 9, 38)
        elseif delta < 0 then
            deltaColor = rgbm.from0255(102, 213, 79)
        end
    end
    ui.dwriteTextAligned(timeText, 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(95, 30):scale(Scale), false, deltaColor)

    -- Best
    ui.setCursor(vec2(0 * Scale, (rowY.best * Scale) + 22))
    ui.dwriteTextAligned("Best:", 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(361, 30):scale(Scale), false, rgbm.from0255(221, 182, 35))

    ui.setCursor(vec2(0 * Scale, (rowY.best * Scale) + 22))
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
    local connectedCount = GetConnectedDriverCount()
    local driverIndex = GetDriverIndexForPosition(DriverData[CAR.index].position - 1)

    -- Ahead Text
    ui.setCursor(vec2(43 * Scale, (rowY.ahead * Scale) + 22))
    ui.dwriteTextAligned("Ahead:", 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(60, 30):scale(Scale), false, rgbm.from0255(221, 182, 35))

    local aheadDriverNumber = driverIndex ~= -1 and DriverData[driverIndex].driverNumber or "-"
    local aheadDriverName = driverIndex ~= -1 and DriverData[driverIndex].driverName or "---"

    if showDriverNumber then
        -- Ahead #
        ui.setCursor(vec2(121 * Scale, (rowY.ahead * Scale) + 22))
        ui.dwriteTextAligned("#", 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(200, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))

        -- Ahead Number
        ui.setCursor(vec2(0, (rowY.ahead * Scale) + 22))
        ui.dwriteTextAligned(aheadDriverNumber, 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(160, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))
    end

    -- Ahead name
    ui.setCursor(vec2((showDriverNumber and 168 or 121) * Scale, (rowY.ahead * Scale) + 22))
    ui.dwriteTextAligned(aheadDriverName, 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(300, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))

    -- Ahead interval
    ui.setCursor(vec2(0, (rowY.ahead * Scale) + 22))

    if SESSION.type == ac.SessionType.Race then
        if DriverData[CAR.index].position == 1 or driverIndex == -1 then
            timeText = "---"
        else
            local mySplineLap = DriverSpline[CAR.index][CAR.lapCount + 1]
            local aheadSplineLap = DriverSpline[driverIndex][CAR.lapCount + 1]
            local splineIndex = mySplineLap and mySplineLap.currentSpline - 1 or nil
            local myTime = mySplineLap and splineIndex and mySplineLap[splineIndex] or nil
            local aheadTime = aheadSplineLap and splineIndex and aheadSplineLap[splineIndex] or nil
            if myTime == nil or aheadTime == nil then
                timeText = "---"
            else
                seconds = math.round(myTime - aheadTime, 1)
                timeText = string.format("%.1f", seconds)
            end
        end
    else
        if DriverData[CAR.index].position == 1 or driverIndex == -1 or DriverData[driverIndex].bestLap == 0 or DriverData[CAR.index].bestLap == 0 then
            timeText = "---"
        else
            local tmp = DriverData[CAR.index].bestLap / 1000 - DriverData[driverIndex].bestLap / 1000
            timeText = string.format("+%.3f", tmp)
        end
    end
    ui.dwriteTextAligned(timeText, 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(466, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))



    -- behind calculations
    driverIndex = GetDriverIndexForPosition(DriverData[CAR.index].position + 1)

    -- Behind Text
    ui.setCursor(vec2(43 * Scale, (rowY.behind * Scale) + 22))
    ui.dwriteTextAligned("Behind:", 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(60, 30):scale(Scale), false, rgbm.from0255(221, 182, 35))

    local behindDriverNumber = driverIndex ~= -1 and DriverData[driverIndex].driverNumber or "-"
    local behindDriverName = driverIndex ~= -1 and DriverData[driverIndex].driverName or "---"

    if showDriverNumber then
        -- Behind #
        ui.setCursor(vec2(121 * Scale, (rowY.behind * Scale) + 22))
        ui.dwriteTextAligned("#", 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(200, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))

        -- Behind Number
        ui.setCursor(vec2(0, (rowY.behind * Scale) + 22))
        ui.dwriteTextAligned(behindDriverNumber, 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(160, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))
    end

    -- Behind name
    ui.setCursor(vec2((showDriverNumber and 168 or 121) * Scale, (rowY.behind * Scale) + 22))
    ui.dwriteTextAligned(behindDriverName, 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(300, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))

    -- Behind interval
    ui.setCursor(vec2(0, (rowY.behind * Scale) + 22))
    if SESSION.type == ac.SessionType.Race then
        if DriverData[CAR.index].position == connectedCount or driverIndex == -1 then
            timeText = "---"
        else
            local driverLap = ac.getCar(driverIndex).lapCount + 1
            local mySplineLap = DriverSpline[CAR.index][driverLap]
            local behindSplineLap = DriverSpline[driverIndex][driverLap]
            local splineIndex = behindSplineLap and behindSplineLap.currentSpline - 1 or nil
            local myTime = mySplineLap and splineIndex and mySplineLap[splineIndex] or nil
            local aheadTime = behindSplineLap and splineIndex and behindSplineLap[splineIndex] or nil
            if myTime == nil or aheadTime == nil then
                timeText = "---"
            else
                seconds = math.round(myTime - aheadTime, 1)
                timeText = string.format("%.1f", seconds)
            end
        end
    else
        if DriverData[CAR.index].position == connectedCount or driverIndex == -1 or DriverData[driverIndex].bestLap == 0 or DriverData[CAR.index].bestLap == 0 then
            timeText = "---"
        else
            local tmp = DriverData[CAR.index].bestLap / 1000 - DriverData[driverIndex].bestLap / 1000
            timeText = string.format("%.3f", tmp)
        end
    end
    ui.dwriteTextAligned(timeText, 17 * Scale, ui.Alignment.End, ui.Alignment.Start, vec2(466, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))


    -- Incident count
    ui.setCursor(vec2(43 * Scale, (rowY.incidents * Scale) + 22))
    ui.dwriteTextAligned("Incident count:", 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(200, 30):scale(Scale), false, rgbm.from0255(221, 182, 35))

    ui.setCursor(vec2((43 + 139) * Scale, (rowY.incidents * Scale) + 22))
    ui.dwriteTextAligned(DriverData[CAR.index].incidentCount .. "x", 17 * Scale, ui.Alignment.Start, ui.Alignment.Start, vec2(200, 30):scale(Scale), false, rgbm.from0255(244, 244, 244))

    ui.popDWriteFont()
end
