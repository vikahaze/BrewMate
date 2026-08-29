# August 2026 Tasks

## Tasks Completed

### 2026-08-08: Fix Third-Party Tap Casks Missing from Explore

- Root cause: `brew search --casks` called without a query fails on modern Homebrew, so tap enumeration returned `[]` and third-party tap casks (e.g. `brewmate`, `etemaro`) never entered the Explore catalog.
- Fixed `getAllTapCaskNames()` in `src/utils/brew.ts` to enumerate taps via `brew tap` and query each with `brew search --casks <tap>`, skipping formula-only/untrusted taps and deduping.
- Updated `getAllTapCaskNames` unit tests to mock the real per-tap call sequence (+ coverage for formula-only taps, dedup, zero taps).
- Verified in app: Explore → Installed now shows tap-installed apps; log showed `Found 73 casks from third-party taps`.
- Released as **v1.0.39** (fix commit `762045c`, tag `v1.0.39`); release workflow succeeded and in-repo cask updated.
- See: [080826_fix_third_party_tap_casks.md](./080826_fix_third_party_tap_casks.md)
