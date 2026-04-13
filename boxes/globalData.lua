SIM = ac.getSim()
CAR = ac.getCar(SIM.focusedCar)
SESSION = ac.getSession(SIM.currentSessionIndex)

DriverData = {}
PrevDriverData = {}
DriverSpline = {}

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
end

function GlobalUpdates()
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
            local driverIndex = SESSION.leaderboard[i].car.index

            DriverData[driverIndex].position = i + 1
            DriverData[driverIndex].driverName = SESSION.leaderboard[i].car:driverName()
            DriverData[driverIndex].driverNumber = SESSION.leaderboard[i].car:driverNumber()

            CheckValidLap(driverIndex)
            CheckIncidents(driverIndex)
            UpdateSplineInfo(driverIndex)
        end
    end
end

function CheckValidLap(driverIndex)
    if ac.getCar(driverIndex).isLastLapValid and (DriverData[driverIndex].bestLap == 0 or DriverData[driverIndex].bestLap > ac.getCar(DriverData[driverIndex].index).bestLapTimeMs) then
        DriverData[driverIndex].bestLap = ac.getCar(driverIndex).bestLapTimeMs
        DriverData[driverIndex].bestLapLap = ac.getCar(driverIndex).lapCount
    end
end

function CheckIncidents(driverIndex)
    if ac.getCar(driverIndex).lapCutsCount == 0 then
        DriverData[driverIndex].incidentCheck = 0
    elseif DriverData[driverIndex].incidentCheck ~= ac.getCar(driverIndex).lapCutsCount then
        DriverData[driverIndex].incidentCount = DriverData[driverIndex].incidentCount + 1
        DriverData[driverIndex].incidentCheck = ac.getCar(driverIndex).lapCutsCount
    end
end

function UpdateSplineInfo(driverIndex)
    local lap = ac.getCar(driverIndex).lapCount + 1

    if DriverSpline[driverIndex][lap] == nil then
        DriverSpline[driverIndex][lap] = {}
        DriverSpline[driverIndex][lap].currentSpline = 0
    end

    if ac.getCar(driverIndex).splinePosition > (DriverSpline[driverIndex][lap].currentSpline / 1000) then
        DriverSpline[driverIndex][lap][DriverSpline[driverIndex][lap].currentSpline] = TIME
        DriverSpline[driverIndex][lap].currentSpline = math.ceil(ac.getCar(driverIndex).splinePosition * 1000)
    end
end
