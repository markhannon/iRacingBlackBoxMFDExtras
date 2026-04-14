local carsUtils = nil
local carsUtilsLoadAttempted = false

local function GetCarsUtils()
    if not carsUtilsLoadAttempted then
        carsUtilsLoadAttempted = true
        local ok, moduleValue = pcall(require, "shared/sim/cars")
        if ok then
            carsUtils = moduleValue
        end
    end

    return carsUtils
end

function TiresBlackBox()
    ui.beginScale()

    DrawArrows()
    DrawWindow("Tires", vec2(33, 22), vec2(479, 323))

    local titles = { "LF:", "RF:", "LR:", "RR:" }
    local optimalPressures = {}
    local hasAllOptimal = true
    local lineY = 65
    local lineX

    local function ResolveCompoundName()
        local ok, value = pcall(function()
            return CAR:tyresName()
        end)
        if ok and type(value) == "string" and value ~= "" then
            return value
        end
        return "N/A"
    end

    local compoundName = ResolveCompoundName()

    local function GetFirstPositiveNumber(...)
        for index = 1, select("#", ...) do
            local candidate = select(index, ...)
            if type(candidate) == "number" and candidate > 0 then
                return candidate
            end
        end

        return nil
    end

    local function GetWheelNumberField(wheel, fieldName)
        if wheel == nil then return nil end

        local ok, value = pcall(function()
            return wheel[fieldName]
        end)

        if ok and type(value) == "number" then
            return value
        end

        return nil
    end

    local function GetWheelOptimalPressure(wheel)
        if wheel == nil then return nil end

        return GetFirstPositiveNumber(
            GetWheelNumberField(wheel, "tyreReferencePressure"),
            GetWheelNumberField(wheel, "tyreReference"),
            GetWheelNumberField(wheel, "tyreOptimalPressure"),
            GetWheelNumberField(wheel, "tyrePressureIdeal"),
            GetWheelNumberField(wheel, "tyreTargetPressure")
        )
    end

    local function GetIdealPressureFromTyreConfig(isFront)
        local utils = GetCarsUtils()
        if utils == nil or CAR == nil or type(CAR.compoundIndex) ~= "number" then
            return nil
        end

        local ok, value = pcall(function()
            return utils.getTyreConfigValue(CAR.compoundIndex, isFront, "PRESSURE_IDEAL", 0)
        end)

        if ok and type(value) == "number" and value > 0 then
            return value
        end

        return nil
    end

    local frontIdealPressure = GetIdealPressureFromTyreConfig(true)
    local rearIdealPressure = GetIdealPressureFromTyreConfig(false)

    if frontIdealPressure ~= nil and rearIdealPressure ~= nil then
        optimalPressures[0] = frontIdealPressure
        optimalPressures[1] = frontIdealPressure
        optimalPressures[2] = rearIdealPressure
        optimalPressures[3] = rearIdealPressure
        hasAllOptimal = true
    else
        hasAllOptimal = true
        for i = 0, 3 do
            local wheel = CAR.wheels[i]
            optimalPressures[i] = GetWheelOptimalPressure(wheel)
            if optimalPressures[i] == nil then
                hasAllOptimal = false
            end
        end
    end

    for i = 0, 3 do
        if i == 2 then lineY = 147 end
        if i % 2 == 0 then lineX = 90 else lineX = 295 end

        local actualPressure = CAR.wheels[i].tyrePressure
        local displayValue = string.format("%.1fpsi", actualPressure)

        if hasAllOptimal then
            local pressureDelta = actualPressure - optimalPressures[i]
            displayValue = string.format("%.1fpsi %+.1f", actualPressure, pressureDelta)
        end

        DrawLabel(titles[i + 1], 0, lineY, lineX + 24 + 9)
        DrawValue(displayValue, 0, lineY, lineX + 125 + 24 + 9, nil, ui.Alignment.End)
    end

    if hasAllOptimal then
        local frontOptimal = (optimalPressures[0] + optimalPressures[1]) / 2
        local rearOptimal = (optimalPressures[2] + optimalPressures[3]) / 2

        DrawDisplayedValue("Front Optimal:", string.format("%.0fpsi", frontOptimal), 0, 245 + 24 + 9, 188)
        DrawDisplayedValue("Rear Optimal:", string.format("%.0fpsi", rearOptimal), 0, 245 + 24 + 9, 218)
        DrawDisplayedValue("Compound:", compoundName, 0, 245 + 24 + 9, 248)
    else
        DrawDisplayedValue("Compound:", compoundName, 0, 245 + 24 + 9, 188)
    end
end
