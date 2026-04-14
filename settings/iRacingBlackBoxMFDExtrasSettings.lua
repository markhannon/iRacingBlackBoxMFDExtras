SCALE = ac.storage("Scale", 1)
Scale = tonumber(SCALE:get()) or 1

local function normalizeBool(value, fallback)
  if type(value) == "boolean" then return value end
  if type(value) == "number" then return value ~= 0 end
  if type(value) == "string" then return value == "true" or value == "1" end
  if value == nil then return fallback == true end
  return not not value
end

local function readStoredBool(storage)
  return normalizeBool(storage:get(), false)
end

local LastSeparateWindowStates = {
  lapTiming = nil,
  standings = nil,
  relative = nil,
}

local function drawStoredCheckbox(label, currentValue, storage)
  if ui.checkbox(label, currentValue) then
    currentValue = not currentValue
    storage:set(currentValue)
  end

  return currentValue
end

function syncSeparateWindows(force)
  if ac.setWindowOpen == nil then
    return
  end

  local desiredStates = {
    lapTiming = ShowSeparateLapTiming == true,
    standings = ShowSeparateStandings == true,
    relative = ShowSeparateRelative == true,
  }

  if (desiredStates.lapTiming or desiredStates.standings or desiredStates.relative) and ac.setAppOpen ~= nil then
    ac.setAppOpen("iRacingBlackBoxMFDExtras")
  end

  for windowId, desiredState in pairs(desiredStates) do
    if force or LastSeparateWindowStates[windowId] ~= desiredState then
      ac.setWindowOpen(windowId, desiredState)
      LastSeparateWindowStates[windowId] = desiredState
    end
  end
end

FUEL_LAP_BUFFER_STORAGE = ac.storage("FuelLapBuffer", 1)
FuelLapBuffer = tonumber(FUEL_LAP_BUFFER_STORAGE:get()) or 1

FUEL_PIT_ADD_STORAGE = ac.storage("FuelPitAddLitres", 0)
FuelPitAddLitres = tonumber(FUEL_PIT_ADD_STORAGE:get()) or 0

SHOW_DRIVER_NUMBER_STORAGE = ac.storage("ShowDriverNumber", false)
ShowDriverNumber = readStoredBool(SHOW_DRIVER_NUMBER_STORAGE)

SHOW_SEPARATE_LAP_TIMING_STORAGE = ac.storage("ShowSeparateLapTiming", false)
ShowSeparateLapTiming = readStoredBool(SHOW_SEPARATE_LAP_TIMING_STORAGE)

SHOW_SEPARATE_STANDINGS_STORAGE = ac.storage("ShowSeparateStandings", false)
ShowSeparateStandings = readStoredBool(SHOW_SEPARATE_STANDINGS_STORAGE)

SHOW_SEPARATE_RELATIVE_STORAGE = ac.storage("ShowSeparateRelative", false)
ShowSeparateRelative = readStoredBool(SHOW_SEPARATE_RELATIVE_STORAGE)

IniFile = ac.INIConfig.load(ac.getFolder(ac.FolderID.ACApps) .. "\\lua\\iRacingBlackBoxMFDExtras\\manifest.ini")

BaseWindowWidth = 447 + 2 * (24 + 9)
BaseWindowHeight = 301 + 22

OldWindowWidth = BaseWindowWidth
OldWindowHeight = BaseWindowHeight
NewWindowWidth = OldWindowWidth
NewWindowHeight = OldWindowHeight

NextBlackBox = ac.ControlButton("BlackBox_NextBlackBox")
PreviousBlackBox = ac.ControlButton("BlackBox_PreviousBlackBox")
SelectNextControl = ac.ControlButton("BlackBox_SelectNextControl")
SelectPreviousControl = ac.ControlButton("BlackBox_SelectPreviousControl")
IncrementSelectControl = ac.ControlButton("BlackBox_IncrementSelectControl")
DecrementSelectControl = ac.ControlButton("BlackBox_DecrementSelectControl")

LapTimingShortcut = ac.ControlButton("BlackBox_LapTimingShortcut")
StandingsShortcut = ac.ControlButton("BlackBox_StandingsShortcut")
RelativeShortcut = ac.ControlButton("BlackBox_RelativeShortcut")
FuelShortcut = ac.ControlButton("BlackBox_FuelShortcut")
TiresShortcut = ac.ControlButton("BlackBox_TiresShortcut")
TireInfoShortcut = ac.ControlButton("BlackBox_TireInfoShortcut")
InCarAdjShortcut = ac.ControlButton("BlackBox_InCarAdjShortcut")

Bindings = {
  NextBlackBox,
  PreviousBlackBox,
  SelectNextControl,
  SelectPreviousControl,
  IncrementSelectControl,
  DecrementSelectControl,

  LapTimingShortcut,
  StandingsShortcut,
  RelativeShortcut,
  FuelShortcut,
  TiresShortcut,
  TireInfoShortcut,
  InCarAdjShortcut
}

BindingNames = {
  "Next Black Box",
  "Previous Black Box",
  "Select Next Control",
  "Select Previous Control",
  "Increment Selected Control",
  "Decrement Selected Control",

  "Lap Timing Black Box",
  "Standings Black Box",
  "Relative Black Box",
  "Fuel Black Box",
  "Tires Black Box",
  "Tire Info Black Box",
  "In-car Adjustments Black Box"
}


function script.iRacingBlackBoxMFDExtras_Settings(dt)
  ui.tabBar('iRacingBlackBoxMFDExtrasSettings', ui.TabBarFlags.NoTooltip and ui.TabBarFlags.FittingPolicyResizeDown, function()
    ui.tabItem('General', function()
      ui.newLine(1)

      Scale = ui.slider("##Scale", Scale, 0.1, 2, "Scale: %.3f")
      SCALE:set(Scale)

      FuelLapBuffer = ui.slider("##FuelLapBuffer", FuelLapBuffer, 0, 10, "Fuel lap buffer: %.1f")
      FuelLapBuffer = math.max(0, math.round(tonumber(FuelLapBuffer) or 1, 1))
      FUEL_LAP_BUFFER_STORAGE:set(FuelLapBuffer)

      FuelPitAddLitres = ui.slider("##FuelPitAddLitres", FuelPitAddLitres, 0, 150, "Next pit add: %.1f L")
      FuelPitAddLitres = math.max(0, math.round(tonumber(FuelPitAddLitres) or 0, 1))
      FUEL_PIT_ADD_STORAGE:set(FuelPitAddLitres)

      ShowDriverNumber = drawStoredCheckbox("Show Driver Number##ShowDriverNumber", ShowDriverNumber, SHOW_DRIVER_NUMBER_STORAGE)

      ShowSeparateLapTiming = drawStoredCheckbox("Show Separate Lap Timing##ShowSeparateLapTiming", ShowSeparateLapTiming, SHOW_SEPARATE_LAP_TIMING_STORAGE)

      ShowSeparateStandings = drawStoredCheckbox("Show Separate Standings##ShowSeparateStandings", ShowSeparateStandings, SHOW_SEPARATE_STANDINGS_STORAGE)

      ShowSeparateRelative = drawStoredCheckbox("Show Separate Relative##ShowSeparateRelative", ShowSeparateRelative, SHOW_SEPARATE_RELATIVE_STORAGE)

      syncSeparateWindows()

      NewWindowHeight = (BaseWindowHeight - 22) * Scale + 22
      NewWindowWidth = BaseWindowWidth * Scale

      if NewWindowHeight ~= OldWindowHeight or NewWindowWidth ~= OldWindowWidth then
        local newSize = tostring(NewWindowWidth) .. ", " .. tostring(NewWindowHeight)
        IniFile:setAndSave("WINDOW_...", "SIZE", newSize)
        OldWindowHeight = NewWindowHeight
        OldWindowWidth = NewWindowWidth
      end
    end)

    ui.tabItem('key bindings', function()
      ui.pushDWriteFont("ARIAL;Weight=Bold")

      for i, key in pairs(BindingNames) do
        ui.dwriteTextAligned(key, 12, ui.Alignment.End, ui.Alignment.Center, vec2(182, 25))
        ui.sameLine(210)

        Bindings[i]:control(vec2(250, 0))
      end

      ui.popDWriteFont()
    end)
  end)
end
