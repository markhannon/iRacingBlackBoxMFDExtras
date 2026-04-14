-- Draws the clickable left and right arrows used to cycle between black boxes.
function DrawArrows()
    local InactiveColor = rgbm.from0255(0, 0, 0, .3)
    local ActiveColor = rgbm.from0255(221, 182, 35)
    local PressedColor = rgbm.colors.white
    local LeftBounds = { x1 = 0, x2 = 24, y1 = 160, y2 = 314 }
    local RightBounds = { x1 = 489, x2 = 513, y1 = 160, y2 = 314 }

    local mousePos = ui.mouseLocalPos()

    local leftArrColor = InactiveColor
    if mousePos.x >= LeftBounds.x1 and mousePos.x <= LeftBounds.x2 * Scale and mousePos.y >= LeftBounds.y1 * Scale and mousePos.y <= LeftBounds.y2 * Scale then
        leftArrColor = ActiveColor

        if ui.mouseDown(ui.MouseButton.Left) then
            leftArrColor = PressedColor
        end
        if ui.mouseReleased(ui.MouseButton.Left) then
            currentBlackBox = currentBlackBox - 1
            if currentBlackBox == 6 then currentBlackBox = 14 end
        end
    end

    local rightArrColor = InactiveColor
    if mousePos.x >= RightBounds.x1 * Scale and mousePos.x <= RightBounds.x2 * Scale and mousePos.y >= RightBounds.y1 * Scale and mousePos.y <= RightBounds.y2 * Scale then
        rightArrColor = ActiveColor

        if ui.mouseDown(ui.MouseButton.Left) then
            rightArrColor = PressedColor
        end
        if ui.mouseReleased(ui.MouseButton.Left) then
            currentBlackBox = currentBlackBox + 1
            if currentBlackBox == 15 then currentBlackBox = 7 end
        end
    end

    ui.drawTriangleFilled(vec2(0, 237), vec2(24, 160), vec2(24, 314), leftArrColor)
    ui.drawTriangleFilled(vec2(513, 237), vec2(489, 160), vec2(489, 314), rightArrColor)
end

-- Draws a single formatted row of UI text for either a label or a value.
function DrawItem(Text, x, y, IsValue, Width, Color, Alignment, RowHeight, FontSize)
    local ItemFont = "Arial;Weight=Bold"
    local LabelColor = rgbm.from0255(221, 182, 35)
    local ValueColor = rgbm.from0255(244, 244, 244)
    local WindowOffsetY = 22
    local DefaultRowHeight = 30
    local DefaultFontSize = 17
    local DefaultLabelWidth = 214 + 24 + 9
    local DefaultValueWidth = 100

    local EffectiveAlignment = Alignment or (IsValue and ui.Alignment.Start or ui.Alignment.End)
    local EffectiveColor = Color or (IsValue and ValueColor or LabelColor)
    local EffectiveWidth = Width or (IsValue and DefaultValueWidth or DefaultLabelWidth)
    local EffectiveRowHeight = RowHeight or DefaultRowHeight
    local EffectiveFontSize = FontSize or DefaultFontSize

    ui.pushDWriteFont(ItemFont)
    ui.setCursor(vec2(x * Scale, y * Scale + WindowOffsetY))
    ui.dwriteTextAligned(tostring(Text), EffectiveFontSize * Scale, EffectiveAlignment, ui.Alignment.Start, vec2(EffectiveWidth, EffectiveRowHeight):scale(Scale), false, EffectiveColor)
    ui.popDWriteFont()
end

-- Draws a label using the shared left-hand text styling.
function DrawLabel(Text, x, y, Width, Color, Alignment, RowHeight, FontSize)
    DrawItem(Text, x, y, false, Width, Color, Alignment, RowHeight, FontSize)
end

-- Draws a value using the shared right-hand text styling.
function DrawValue(Text, x, y, Width, Color, Alignment, RowHeight, FontSize)
    DrawItem(Text, x, y, true, Width, Color, Alignment, RowHeight, FontSize)
end

-- Draws a display-only label/value row with shared styling and optional layout overrides.
function DrawDisplayedValue(label, value, xLabel, xValue, y, valueWidth, valueAlignment, labelWidth, labelColor, valueColor)
    local effectiveValueWidth = valueWidth or 100
    local effectiveValueAlignment = valueAlignment or ui.Alignment.Start

    DrawLabel(label, xLabel, y, labelWidth, labelColor)
    DrawValue(value, xValue, y, effectiveValueWidth, valueColor, effectiveValueAlignment)
end

-- Draws an editable label/value row with explicit positions, optional highlight, and selection arrows.
function DrawEditableValue(label, value, xLabel, xValue, y, selected, valueWidth, valueAlignment)
    local highlightColor = rgbm.from0255(43, 53, 78)
    local effectiveValueWidth = valueWidth or 100
    local effectiveValueAlignment = valueAlignment or ui.Alignment.Start

    if selected then
        local line = y * Scale + 22
        ui.drawRectFilled(vec2((20 + 24 + 9) * Scale, line), vec2((422 + 24 + 9) * Scale, line + 22.6 * Scale), highlightColor)

        if DrawLeftSelectionArrow ~= nil then DrawLeftSelectionArrow(line) end
        if DrawRightSelectionArrow ~= nil then DrawRightSelectionArrow(line) end
    end

    DrawLabel(label, xLabel, y)
    DrawValue(value, xValue, y, effectiveValueWidth, nil, effectiveValueAlignment)
end

-- Draws the common black-box background panel and optional title text.
function DrawWindow(Title, topLeft, bottomRight)
    local TitleFont = "fonts/eurostarblackextended.ttf"
    local TitleColor = rgbm.from0255(221, 182, 35)
    local BackgroundColor = rgbm.from0255(0, 0, 0, .75)
    local PivotPoint = vec2(0, 22)
    local TitleOffsetX = 8
    local TitleOffsetY = 3
    local TitleSize = 27
    local CornerRadius = 6

    ui.drawRectFilled(topLeft, bottomRight, BackgroundColor, CornerRadius)
    ui.endPivotScale(Scale, PivotPoint)

    if Title ~= nil and Title ~= "" then
        ui.pushDWriteFont(TitleFont)
        ui.setCursor(vec2((topLeft.x + TitleOffsetX) * Scale, topLeft.y + (TitleOffsetY * Scale)))
        ui.dwriteText(Title, TitleSize * Scale, TitleColor)
        ui.popDWriteFont()
    end
end
