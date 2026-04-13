local function DrawWindow(Title, topLeft, bottomRight)
    local TitleFont = "fonts/eurostarblackextended.ttf"
    local TitleColor = rgbm.from0255(221, 182, 35)
    local BackgroundColor = rgbm.from0255(0, 0, 0, .75)
    local TitleOffsetX = 8
    local TitleOffsetY = 3
    local TitleSize = 27
    local CornerRadius = 6

    ui.drawRectFilled(topLeft, bottomRight, BackgroundColor, CornerRadius)
    ui.endPivotScale(Scale, vec2(0, topLeft.y))

    ui.pushDWriteFont(TitleFont)
    ui.setCursor(vec2((topLeft.x + TitleOffsetX) * Scale, topLeft.y + (TitleOffsetY * Scale)))
    ui.dwriteText(Title, TitleSize * Scale, TitleColor)
    ui.popDWriteFont()
end

local function DrawItem(Text, x, y, IsValue)
    local ItemFont = "Arial;Weight=Bold"
    local LabelColor = rgbm.from0255(221, 182, 35)
    local ValueColor = rgbm.from0255(244, 244, 244)
    local FontSize = 17
    local WindowOffsetY = 22
    local RowHeight = 30
    local LabelWidth = 214 + 24 + 9
    local ValueWidth = 100

    local Alignment = IsValue and ui.Alignment.Start or ui.Alignment.End
    local Color = IsValue and ValueColor or LabelColor
    local Width = IsValue and ValueWidth or LabelWidth

    ui.pushDWriteFont(ItemFont)
    ui.setCursor(vec2(x * Scale, y * Scale + WindowOffsetY))
    ui.dwriteTextAligned(tostring(Text), FontSize * Scale, Alignment, ui.Alignment.Start, vec2(Width, RowHeight):scale(Scale), false, Color)
    ui.popDWriteFont()
end

local function DrawLabel(Text, x, y)
    DrawItem(Text, x, y, false)
end

local function DrawValue(Text, x, y)
    DrawItem(Text, x, y, true)
end

function FuelBlackBox()
    ui.beginScale()

    DrawArrows()
    DrawWindow("Fuel", vec2(33, 22), vec2(479, 323))

    
    local estimatedLaps = "-"
    if CAR.fuelPerLap ~= 0 then
        estimatedLaps = tostring(math.round(CAR.fuel / CAR.fuelPerLap, 1))
    end
    
    DrawLabel("Fuel / Lap:", 0, 100)
    DrawValue(CAR.fuelPerLap, 260, 100)
    DrawLabel("Est. Laps:", 0, 130)
    DrawValue(estimatedLaps, 260, 130)
    DrawLabel("Remaining:", 0, 174)
    DrawValue(string.format("%.1f", math.round(CAR.fuel, 1)) .. " L", 260, 174)
end
