SIM = ac.getSim()
CAR = ac.getCar(SIM.focusedCar)
SESSION = ac.getSession(SIM.currentSessionIndex)

DriverData = {}
PrevDriverData = {}
DriverSpline = {}

FuelLastLapUsage = 0
FuelAverageUsagePerLap = 0
FuelUsageSamples = 0
FuelPreviousLapCount = 0
FuelLapStartFuel = 0
FuelLastKnownFuel = 0

local ResetFuelTracking
local UpdateFuelTracking

-- Records a new incident whenever the sim lap-cut counter increments for a driver.
function CheckIncidents(driverIndex)
    local car = ac.getCar(driverIndex)
    if car == nil then return end

    if car.lapCutsCount == 0 then
        DriverData[driverIndex].incidentCheck = 0
    elseif DriverData[driverIndex].incidentCheck ~= car.lapCutsCount then
        DriverData[driverIndex].incidentCount = DriverData[driverIndex].incidentCount + 1
        DriverData[driverIndex].incidentCheck = car.lapCutsCount
    end
end

-- Stores the best valid lap time seen so far for the specified driver.
function CheckValidLap(driverIndex)
    local car = ac.getCar(driverIndex)
    if car == nil then return end

    if car.isLastLapValid and (DriverData[driverIndex].bestLap == 0 or DriverData[driverIndex].bestLap > car.bestLapTimeMs) then
        DriverData[driverIndex].bestLap = car.bestLapTimeMs
        DriverData[driverIndex].bestLapLap = car.lapCount
    end
end

-- Reinitializes all shared driver, spline, and fuel-tracking state when a session changes.
function FirstInit()
    SIM = ac.getSim()
    CAR = ac.getCar(SIM.focusedCar)
    SESSION = ac.getSession(SIM.currentSessionIndex)

    for i = -1, SIM.carsCount do
        PrevDriverData[i] = {}

        DriverData[i] = {}
        DriverData[i].position = -1
        DriverData[i].driverName = "---"
        DriverData[i].driverNumber = "-"
        DriverData[i].bestLap = 0
        DriverData[i].bestLapLap = 0
        DriverData[i].incidentCount = 0
        DriverData[i].incidentCheck = 0

        DriverSpline[i] = {}
        DriverSpline[i][1] = {}
        DriverSpline[i][1].currentSpline = 0
    end

    ResetFuelTracking()
end

-- Returns the best available estimate for current fuel burn per lap.
function GetAverageFuelPerLap()
    if FuelAverageUsagePerLap ~= nil and FuelAverageUsagePerLap > 0 then
        return FuelAverageUsagePerLap
    end

    if CAR.fuelPerLap ~= nil and CAR.fuelPerLap > 0 then
        return CAR.fuelPerLap
    end

    return 0
end

-- Counts how many drivers currently have a valid connected leaderboard position.
function GetConnectedDriverCount()
    local count = 0
    for i = 0, SIM.carsCount - 1 do
        if IsDriverConnected(i) then
            count = count + 1
        end
    end
    return count
end

-- Estimates how many laps the current fuel load should cover.
function GetEstimatedLapsRemaining(averageFuelPerLap)
    if averageFuelPerLap <= 0 then
        return nil, "-"
    end

    local estimatedLaps = math.round(CAR.fuel / averageFuelPerLap, 1)
    return estimatedLaps, string.format("%.1f", estimatedLaps)
end

-- Converts the estimated laps remaining into a readable time string.
function GetEstimatedTimeText(estimatedLaps)
    if estimatedLaps == nil then
        return "-"
    end

    local referenceLapTimeMs = GetReferenceLapTimeMs()
    if referenceLapTimeMs <= 0 then
        return "-"
    end

    local estimatedTimeMs = estimatedLaps * referenceLapTimeMs
    local minutes = math.floor(estimatedTimeMs / 60000)
    local seconds = math.floor((estimatedTimeMs % 60000) / 1000)
    return string.format("%d:%02d", minutes, seconds)
end

-- Formats session duration text as MM:SS, switching to HH:MM:SS for 1 hour or longer.
function FormatSessionDuration(timeMs)
    if timeMs == nil then
        return "---"
    end

    local totalSeconds = math.floor(timeMs / 1000)
    if totalSeconds < 0 then
        return "---"
    end

    local hours = math.floor(totalSeconds / 3600)
    local minutes = math.floor((totalSeconds % 3600) / 60)
    local seconds = totalSeconds % 60

    if hours > 0 then
        return string.format("%02d:%02d:%02d", hours, minutes, seconds)
    end

    return string.format("%02d:%02d", minutes, seconds)
end

-- Calculates how much fuel is required to safely reach the session finish.
function GetFuelToEnd(averageFuelPerLap)
    if averageFuelPerLap <= 0 then
        return nil, nil
    end

    local remainingLaps = nil
    local marginFuel = 0
    local isTimedSession = SESSION.isTimedRace or SIM.isTimedRace or SESSION.type ~= ac.SessionType.Race

    if not isTimedSession and SESSION.laps ~= nil and SESSION.laps > 0 then
        remainingLaps = math.max(0, SESSION.laps - CAR.lapCount) + FuelLapBuffer
    else
        local referenceLapTimeMs = GetReferenceLapTimeMs()
        if referenceLapTimeMs > 0 and SIM.sessionTimeLeft > 0 then
            remainingLaps = math.ceil(SIM.sessionTimeLeft / referenceLapTimeMs)
            marginFuel = averageFuelPerLap * FuelLapBuffer
        end
    end

    if remainingLaps == nil then
        return nil, nil
    end

    local fuelToEnd = math.max(0, remainingLaps * averageFuelPerLap + marginFuel - CAR.fuel)

    return remainingLaps, fuelToEnd
end

-- Resolves the car index currently occupying a given leaderboard position.
function GetDriverIndexForPosition(position)
    if position == nil or position < 1 then
        return -1
    end

    for i = 0, SIM.carsCount - 1 do
        if IsDriverConnected(i) and DriverData[i].position == position then
            return i
        end
    end

    return -1
end

-- Estimates the likely next pit-stop fill amount without exceeding tank capacity.
function GetFillNextPit(fuelToEnd)
    if fuelToEnd == nil then
        return "N/A"
    end

    if CAR.maxFuel ~= nil and CAR.maxFuel > 0 then
        local headroom = math.max(0, CAR.maxFuel - CAR.fuel)
        return string.format("%.1f L", math.round(math.min(fuelToEnd, headroom), 1))
    end

    return "N/A"
end

-- Refreshes all shared driver telemetry and leaderboard state once per frame.
function GlobalUpdates()
    for i = 0, SIM.carsCount - 1 do
        DriverData[i].position = -1
    end

    if SIM.carsCount == 1 then
        DriverData[CAR.index].position = 1
        DriverData[CAR.index].driverName = CAR:driverName()
        DriverData[CAR.index].driverNumber = CAR:driverNumber()

        CheckValidLap(CAR.index)
        CheckIncidents(CAR.index)
    elseif SESSION.type == ac.SessionType.Race then
        for i, car in ac.iterateCars.leaderboard() do
            DriverData[car.index].position = i
            DriverData[car.index].driverName = car:driverName()
            DriverData[car.index].driverNumber = car:driverNumber()

            CheckValidLap(car.index)
            CheckIncidents(car.index)
            UpdateSplineInfo(car.index)
        end
    else
        for i = 0, SIM.carsCount - 1 do
            local leaderboardEntry = SESSION.leaderboard[i]
            if leaderboardEntry ~= nil and leaderboardEntry.car ~= nil then
                local driverIndex = leaderboardEntry.car.index

                DriverData[driverIndex].position = i + 1
                DriverData[driverIndex].driverName = leaderboardEntry.car:driverName()
                DriverData[driverIndex].driverNumber = leaderboardEntry.car:driverNumber()

                CheckValidLap(driverIndex)
                CheckIncidents(driverIndex)
                UpdateSplineInfo(driverIndex)
            end
        end
    end

    UpdateFuelTracking()
end

-- Returns the best lap time reference to use for fuel-time projections.
function GetReferenceLapTimeMs()
    if CAR.previousLapTimeMs ~= nil and CAR.previousLapTimeMs > 0 then
        return CAR.previousLapTimeMs
    end

    if DriverData[CAR.index] ~= nil and DriverData[CAR.index].bestLap ~= nil and DriverData[CAR.index].bestLap > 0 then
        return DriverData[CAR.index].bestLap
    end

    if CAR.lapTimeMs ~= nil and CAR.lapTimeMs > 0 then
        return CAR.lapTimeMs
    end

    return 0
end

-- Returns true when a driver slot belongs to an actively connected car with a valid position.
function IsDriverConnected(driverIndex)
    if driverIndex == nil or driverIndex < 0 or driverIndex >= SIM.carsCount then
        return false
    end

    local car = ac.getCar(driverIndex)
    return car ~= nil and car.isConnected and DriverData[driverIndex] ~= nil and (DriverData[driverIndex].position or -1) > 0
end

-- Clears the rolling fuel-usage state when a session reset, teleport, or refuel is detected.
ResetFuelTracking = function()
    if CAR == nil then return end

    FuelLastLapUsage = 0
    FuelAverageUsagePerLap = 0
    FuelUsageSamples = 0
    FuelPreviousLapCount = CAR.lapCount or 0
    FuelLapStartFuel = CAR.fuel or 0
    FuelLastKnownFuel = CAR.fuel or 0
end

-- Recomputes the last-lap and average fuel usage based on the current car telemetry.
UpdateFuelTracking = function()
    if CAR == nil then return end

    local currentLap = CAR.lapCount or 0
    local currentFuel = CAR.fuel or 0

    if currentLap < FuelPreviousLapCount or currentLap - FuelPreviousLapCount > 1 or currentFuel > FuelLastKnownFuel + 1 then
        ResetFuelTracking()
        FuelPreviousLapCount = currentLap
        FuelLapStartFuel = currentFuel
        FuelLastKnownFuel = currentFuel
        return
    end

    if currentLap > FuelPreviousLapCount then
        local lapUsage = FuelLapStartFuel - currentFuel
        if lapUsage > 0 and lapUsage < 50 then
            FuelLastLapUsage = lapUsage

            if FuelUsageSamples == 0 then
                FuelAverageUsagePerLap = lapUsage
            else
                FuelAverageUsagePerLap = ((FuelAverageUsagePerLap * FuelUsageSamples) + lapUsage) / (FuelUsageSamples + 1)
            end

            FuelUsageSamples = FuelUsageSamples + 1
        end

        FuelLapStartFuel = currentFuel
        FuelPreviousLapCount = currentLap
    end

    FuelLastKnownFuel = currentFuel
end

-- Captures spline timing checkpoints so the relative and standings views can estimate gaps.
function UpdateSplineInfo(driverIndex)
    local car = ac.getCar(driverIndex)
    if car == nil then return end

    local lap = car.lapCount + 1

    if DriverSpline[driverIndex][lap] == nil then
        DriverSpline[driverIndex][lap] = {}
        DriverSpline[driverIndex][lap].currentSpline = 0
    end

    if car.splinePosition > (DriverSpline[driverIndex][lap].currentSpline / 1000) then
        DriverSpline[driverIndex][lap][DriverSpline[driverIndex][lap].currentSpline] = TIME
        DriverSpline[driverIndex][lap].currentSpline = math.ceil(car.splinePosition * 1000)
    end
end
