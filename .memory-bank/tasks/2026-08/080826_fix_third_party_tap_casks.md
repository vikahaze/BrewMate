# 080826_fix_third_party_tap_casks

## Objective

Fix Explore page missing apps installed from third-party Homebrew taps (e.g. `brewmate`, `etemaro` from `romankurnovskii/awesome-brew`) even though `brew list` showed them installed.

## Root Cause

- `getAllTapCaskNames()` in `src/utils/brew.ts` called `brew search --casks` with **no query argument**.
- On modern Homebrew (confirmed on 6.0.15) this fails: `Error: Invalid usage: This command requires at least 1 text or regex argument`.
- The `catch` returned `[]`, so the supplement block in `src/main/ipcHandlers.ts` (`if (allTapCaskNames.length > 0)`) was skipped entirely.
- Third-party tap casks never entered `allApps`, so the Explore grid (both "All" and "Installed" categories) silently dropped them via the `allAppsMap.get()` lookup miss in `src/renderer/renderer.ts`.
- The "Installed" chip count and dashboard donut undercounted them too.
- Unit tests missed it because they mocked `brew search --casks` as if it returned names with no argument — the tests encoded the bug as expected behavior.

## Fix

- Rewrote `getAllTapCaskNames()` in `src/utils/brew.ts` to:
  1. Enumerate installed taps via `brew tap`.
  2. Query each tap individually with `brew search --casks <tap>` (verified working on Homebrew 6.0.15; `brew search --casks ''` is NOT viable — it dies on untrusted taps).
  3. Skip formula-only/untrusted taps that exit non-zero (per-tap try/catch).
  4. Dedupe results.
- Updated unit tests in `src/utils/__tests__/brew.test.ts` to mock the real per-tap call sequence and added coverage for formula-only tap skips, dedup, and zero taps.

## Verification

- Unit: `npx jest` — 85/85 tests passing (7 suites); brew tests 24/24.
- Typecheck: `tsc --noEmit` — 0 errors.
- Runtime smoke test on this machine: 12 taps → 87 unique cask names, `brewmate` and `etemaro` both discovered (~2.6s).
- Live app check: main-process log showed `[IPC] Found 73 casks from third-party taps` (this line never appeared before) and `[IPC] Fetched apps: 16,289`.
- User confirmed: apps now visible in Explore → Installed.

## Outcome

- ✅ Fix committed: `762045c` — `fix: include third-party tap casks in Explore catalog`
- ✅ Released as **v1.0.39** (tag `v1.0.39`, commit `a442571`)
- ✅ GitHub Actions Release workflow: SUCCESS (5m45s) — macOS universal + Linux assets uploaded
- ✅ In-repo cask auto-updated: `Casks/brewmate.rb` version `1.0.39`, sha256 `88e62e9f7ab508b5bcd47e87923eccf2e5b8d3d2a3e95546fe14ea625dabcb16` (commit `63eccce`)

## Files Modified

- `src/utils/brew.ts` — `getAllTapCaskNames()` rewritten to per-tap enumeration (+48/-23)
- `src/utils/__tests__/brew.test.ts` — `getAllTapCaskNames` test suite updated (+73/-0)

## Integration Points

- `src/main/ipcHandlers.ts` — `get-all-apps` handler consumes `getAllTapCaskNames()` output; unchanged.
- `src/renderer/renderer.ts` — no changes needed; once tap casks are in `allApps`, existing `allAppsMap`/`installedApps` name matching works because both `brew list --casks` and `brew info --json` use the short cask token.

## Known Gaps (Out of Scope)

- Third-party **formulae** from taps are still missing from Explore (same class of gap, separate change).
