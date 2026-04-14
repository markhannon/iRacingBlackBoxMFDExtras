# Repository facts and working conventions

## Project identity
- The app identity is iRacingBlackBoxMFDExtras.
- Keep the main entrypoint, settings module name, and manifest values aligned with that app name.
- The settings loader uses a hardcoded manifest path under apps/lua/<app-folder>/manifest.ini, so renames must stay consistent.

## UI helpers
- Shared drawing helpers live in helpers.lua at the repo root.
- Black box modules should reuse the shared DrawWindow, DrawItem, DrawLabel, DrawValue, and DrawArrows helpers instead of duplicating them.

## Fuel black box
- The Fuel black box includes strategy estimates such as average fuel per lap, last-lap usage, fuel to finish, and lap/time projections.
- FuelPitAddLitres is planner-only app state. No verified CSP Lua API is currently wired in to update Assetto Corsa pit refuel strategy directly.
- The Add Next Pit row is intentionally hidden in the Fuel UI, but the supporting code and setting remain for future use.

## Driver data and multiplayer filtering
- DriverData uses position >= 1 for active connected drivers. Disconnected or uninitialized entries remain at -1.
- Relative, Lap Timing, and Standings should only show connected drivers.
- Use the shared connected-driver helpers in boxes/globalData.lua instead of relying on raw SIM.carsCount alone.
- Driver positions are reset each update to avoid stale offline entries showing in black boxes.

## Diagnostics
- Some CSP Lua editor diagnostics around ui drawing calls are known type-stub noise and are not automatically runtime issues.
