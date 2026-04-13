require("boxes.globalData")
require("settings.iRacingBlackBoxMFDSettings")
require("boxes.lapTiming")
require("boxes.standings")
require("boxes.relative")
require("boxes.fuel")
require("boxes.tires")
require("boxes.tireInfo")
require("boxes.inCarAdjustments")
require("boxes.blank")

PrevBlackBox = 0
PrevSessionIndex = -1
SelectOffsetY = 0
SelectOffsetX = 0

FirstSetup = false
TIME = 0

local currentBlackBox = 7

if ac.onSessionStart then
    ac.onSessionStart(function()
        FirstInit()
    end)
end

function script.windowMain(dt)
    SIM = ac.getSim()
    CAR = ac.getCar(SIM.focusedCar)
    SESSION = ac.getSession(SIM.currentSessionIndex)
    TIME = TIME + dt

    if not FirstSetup or PrevSessionIndex ~= SIM.currentSessionIndex or SIM.currentSessionTime <= 1000 then
        FirstInit()
        FirstSetup = true
        PrevSessionIndex = SIM.currentSessionIndex
    end

    if CAR == nil then
        ac.debug("focused driver error")
    else
        GlobalUpdates()
        CheckButtonInput()

        if PrevBlackBox ~= currentBlackBox then
            SelectOffsetY = "-"
            SelectOffsetX = 0
            PrevBlackBox = currentBlackBox
        end


        if currentBlackBox == 7 then
            LapTimingBlackBox()
        elseif currentBlackBox == 8 then
            StandingsBlackBox()
        elseif currentBlackBox == 9 then
            RelativeBlackBox()
        elseif currentBlackBox == 10 then
            FuelBlackBox()
        elseif currentBlackBox == 11 then
            TiresBlackBox()
        elseif currentBlackBox == 12 then
            TireInfoBlackBox()
        elseif currentBlackBox == 13 then
            InCarAdjBlackBox()
        else
            BlankBlackBox()
        end
    end
end

local pressed = false
function CheckButtonInput()
    if not pressed and NextBlackBox:pressed() then
        currentBlackBox = currentBlackBox + 1
        if currentBlackBox == 15 then currentBlackBox = 7 end
        pressed = true
    elseif NextBlackBox:released() then
        pressed = false
    elseif not pressed and PreviousBlackBox:pressed() then
        currentBlackBox = currentBlackBox - 1
        if currentBlackBox == 6 then currentBlackBox = 14 end
        pressed = true
    elseif PreviousBlackBox:released() then
        pressed = false
    elseif not pressed and SelectNextControl:pressed() then
        if SelectOffsetY ~= "-" then SelectOffsetY = SelectOffsetY + 1 end
        pressed = true
    elseif SelectNextControl:released() then
        pressed = false
    elseif not pressed and SelectPreviousControl:pressed() then
        if SelectOffsetY ~= "-" then SelectOffsetY = SelectOffsetY - 1 end
        pressed = true
    elseif SelectPreviousControl:released() then
        pressed = false
    elseif not pressed and IncrementSelectControl:pressed() then
        SelectOffsetX = SelectOffsetX + 1
        pressed = true
    elseif IncrementSelectControl:released() then
        pressed = false
    elseif not pressed and DecrementSelectControl:pressed() then
        SelectOffsetX = SelectOffsetX - 1
        pressed = true
    elseif DecrementSelectControl:released() then
        pressed = false
    elseif not pressed and LapTimingShortcut:pressed() then
        if currentBlackBox == 7 then
            currentBlackBox = 14
        else
            currentBlackBox = 7
        end
        pressed = true
    elseif LapTimingShortcut:released() then
        pressed = false
    elseif not pressed and StandingsShortcut:pressed() then
        if currentBlackBox == 8 then
            currentBlackBox = 14
        else
            currentBlackBox = 8
        end
        pressed = true
    elseif StandingsShortcut:released() then
        pressed = false
    elseif not pressed and RelativeShortcut:pressed() then
        if currentBlackBox == 9 then
            currentBlackBox = 14
        else
            currentBlackBox = 9
        end
        pressed = true
    elseif RelativeShortcut:released() then
        pressed = false
    elseif not pressed and FuelShortcut:pressed() then
        if currentBlackBox == 10 then
            currentBlackBox = 14
        else
            currentBlackBox = 10
        end
        pressed = true
    elseif FuelShortcut:released() then
        pressed = false
    elseif not pressed and TiresShortcut:pressed() then
        if currentBlackBox == 11 then
            currentBlackBox = 14
        else
            currentBlackBox = 11
        end
        pressed = true
    elseif TiresShortcut:released() then
        pressed = false
    elseif not pressed and TireInfoShortcut:pressed() then
        if currentBlackBox == 12 then
            currentBlackBox = 14
        else
            currentBlackBox = 12
        end
        pressed = true
    elseif TireInfoShortcut:released() then
        pressed = false
    elseif not pressed and InCarAdjShortcut:pressed() then
        if currentBlackBox == 13 then
            currentBlackBox = 14
        else
            currentBlackBox = 13
        end
        pressed = true
    elseif InCarAdjShortcut:released() then
        pressed = false
    end
end

function DrawArrows()
    local mousePos = ui.mouseLocalPos()

    local leftArrColor = rgbm.from0255(0, 0, 0, .3)
    if mousePos.x >= 0 and mousePos.x <= 24 * Scale and mousePos.y >= 160 * Scale and mousePos.y <= 314 * Scale then
        leftArrColor = rgbm.from0255(221, 182, 35)

        if ui.mouseDown(ui.MouseButton.Left) then
            leftArrColor = rgbm.colors.white
        end
        if ui.mouseReleased(ui.MouseButton.Left) then
            currentBlackBox = currentBlackBox - 1
            if currentBlackBox == 6 then currentBlackBox = 14 end
        end
    end

    local rightArrColor = rgbm.from0255(0, 0, 0, .3)
    if mousePos.x >= 489 * Scale and mousePos.x <= 513 * Scale and mousePos.y >= 160 * Scale and mousePos.y <= 314 * Scale then
        rightArrColor = rgbm.from0255(221, 182, 35)

        if ui.mouseDown(ui.MouseButton.Left) then
            rightArrColor = rgbm.colors.white
        end
        if ui.mouseReleased(ui.MouseButton.Left) then
            currentBlackBox = currentBlackBox + 1
            if currentBlackBox == 15 then currentBlackBox = 7 end
        end
    end

    -- left arrow
    ui.drawTriangleFilled(vec2(0, 237), vec2(24, 160), vec2(24, 314), leftArrColor)
    -- right arrow
    ui.drawTriangleFilled(vec2(513, 237), vec2(489, 160), vec2(489, 314), rightArrColor)
end
