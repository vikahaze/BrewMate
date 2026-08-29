# 190626_fix_localization_and_version

## Objective

Support the additional localizations (Russian, Ukrainian, and Hindi) in the frontend language selection ComboBox, and fix a race condition where the application version info was requested from the main process before the IPC listener was registered in the renderer.

## Outcome

- ✅ Tests: 45 passing
- ✅ Build: Successful
- ✅ Review: Approved

## Files Modified

- [index.html](file:///Users/r/dev/github/BrewMate/src/renderer/index.html) - Added language selector option elements for Russian, Ukrainian, and Hindi.
- [renderer.ts](file:///Users/r/dev/github/BrewMate/src/renderer/renderer.ts) - Refactored IPC listener setup into a helper function `setupIpcListeners` and invoked it early in `init()` to avoid race conditions.

## Patterns Applied

- Centralized IPC listeners registration early in application initialization sequence.

## Integration Points

- `renderer.ts:318` via `setupIpcListeners()` call in `init()`.

## Architectural Decisions

- Centralized all IPC event handlers in renderer to avoid race conditions when asynchronous events are delivered immediately upon startup.

## Artifacts

- Pull Request: [#342](https://github.com/romankurnovskii/BrewMate/pull/342)
