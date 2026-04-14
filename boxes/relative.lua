function RelativeBlackBox()
    ui.beginScale()

    DrawArrows()
    DrawWindow("Relative", vec2(33, 93), vec2(479, 323))

    ui.pushDWriteFont("Arial;Weight=Bold")

    -- get connected drivers sorted by spline position
    local positions = {}
    for i = 0, SIM.carsCount - 1 do
        if IsDriverConnected(i) then
            table.insert(positions, {
                index = i,
                pos = ac.getCar(i).splinePosition
            })
        end
    end
    table.sort(positions, function(lhs, rhs) return lhs.pos > rhs.pos end)

    -- get position / index in table positions
    local myPos = 1
    for i = 1, #positions do
        if positions[i].index == CAR.index then
            myPos = i
            break
        end
    end

    -- get the driver index around me
    local realIndex = {}
    local myListIndex = 1
    if #positions <= 7 then
        local startIndex = math.max(1, myPos - 3)
        local endIndex = math.min(#positions, myPos + 3)
        for i = startIndex, endIndex do
            realIndex[#realIndex + 1] = positions[i].index
            if positions[i].index == CAR.index then
                myListIndex = #realIndex
            end
        end
    else
        local counter = 1
        for i = myPos - 3, myPos + 3 do
            local j = i
            if j < 1 then
                j = #positions + j
            elseif j > #positions then
                j = j - #positions
            end
            realIndex[counter] = positions[j].index
            if positions[j].index == CAR.index then
                myListIndex = counter
            end
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
        if i < myListIndex then
            if ac.getCar(realIndex[i]).lapCount >= CAR.lapCount then
                driverLap = CAR.lapCount + 1
            else
                driverLap = ac.getCar(realIndex[i]).lapCount + 1
            end
        elseif i > myListIndex then
            driverLap = ac.getCar(realIndex[i]).lapCount + 1
        end

        if i == myListIndex then
            myTime = nil
        elseif i < myListIndex then
            local mySplineLap = DriverSpline[CAR.index][CAR.lapCount + 1]
            local driverSplineLap = DriverSpline[realIndex[i]][driverLap]
            local splineIndex = mySplineLap and mySplineLap.currentSpline - 1 or nil
            myTime = mySplineLap and splineIndex and mySplineLap[splineIndex] or nil
            driverTime = driverSplineLap and splineIndex and driverSplineLap[splineIndex] or nil
        else
            local mySplineLap = DriverSpline[CAR.index][CAR.lapCount + 1]
            local driverSplineLap = DriverSpline[realIndex[i]][driverLap]
            local splineIndex = driverSplineLap and driverSplineLap.currentSpline - 1 or nil
            myTime = mySplineLap and splineIndex and mySplineLap[splineIndex] or nil
            driverTime = driverSplineLap and splineIndex and driverSplineLap[splineIndex] or nil
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
    local summaryColor = rgbm.from0255(244, 244, 244)
    DrawLabel("Lap:", 24 + 9 + 9, 209 + 65 - 5, 50, nil, ui.Alignment.Start)

    local text = tostring(CAR.lapCount + 1)
    if SESSION.type == ac.SessionType.Race then
        text = tostring(CAR.lapCount + 1) .. " / " .. SESSION.laps
    end
    DrawValue(text, 55 + 24 + 9, 209 + 65 - 5, 32 + 24 + 9 + 32, summaryColor, ui.Alignment.Start)

    -- Last
    DrawLabel("Last:", 290 + 24 + 9, 209 + 65 - 5, 50, nil, ui.Alignment.Start)

    if CAR.previousLapTimeMs == 0 then
        text = "---"
    else
        local minutes = CAR.previousLapTimeMs / 60E3
        local seconds = (minutes % 1) * 60
        local milliseconds = math.round((seconds % 1) * 1000)
        text = string.format("%d:%02d.%03d", minutes, seconds, milliseconds)
        if not CAR.isLastLapValid then text = "*" .. text end
    end
    DrawValue(text, 0, 209 + 65 - 5, 437 + 24 + 9, summaryColor, ui.Alignment.End)

    ui.popDWriteFont()


    -- ? quali mode
    -- ? race mode
end
