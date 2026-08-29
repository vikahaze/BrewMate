# 130726_brew-browser-research

## Objective

Research [brew-browser](https://github.com/msitarzewski/brew-browser) — a Homebrew GUI by msitarzewski — to identify features, UX patterns, and architectural decisions that can inform BrewMate improvements.

## Research Sources

- brew-browser README and repo structure (Tauri 2 + SvelteKit + Rust, dual-build: Tauri cross-platform + Swift/SwiftUI native for macOS 26)
- 24 open issues (20 bugs, 2 feature requests, 2 open PRs)
- brew-browser Linux build CI workflow
- BrewMate codebase analysis (Electron + vanilla TypeScript)
- brew-browser API: github.com/msitarzewski/brew-browser

## Key Findings

### brew-browser vs BrewMate — Feature Comparison

| Feature | brew-browser | BrewMate | Notes |
|---|---|---|---|
| Dashboard | Rich: installed count, updates, version, formula/cask split, donut, **storage usage** (Cellar/Caskroom/var/log/cache), **vuln exposure card** | Basic: installed count, formula/cask split, donut, cache size, update count | brew-browser has 2x the cards, storage drilldown, combined vuln card |
| Library (Installed) | Dense filterable list, **sortable columns**, **outdated badges**, **category chip filters**, **vulnerable filter pill**, **severity dots**, slide-over detail panel | Basic table, updates view separate, no per-row severity indicators | brew-browser has inline severity + category chips in Library |
| Discover (Catalog) | **19-category tile grid**, **subcategory drilldown**, **multi-select chip filter**, bundled 16k+ catalog, refreshable | Search + filter by type/category, basic card grid | brew-browser has a proper catalog browser with subcategories |
| Trending | **30/90/365-day windows**, **velocity index** (recent vs prior 11-month), **sparklines** (opt-in), sortable columns | Single trending list from analytics API | brew-browser's velocity + sparklines are unique |
| Snapshots | **Save/restore Brewfiles** via brew bundle, one-click new Mac setup | Not available | **Killer feature** — easy machine migration |
| Services | List/start/stop/restart | List/start/stop/restart | Comparable |
| Security/Vulns | **Opt-in brew vulns**, severity dots, per-package Security card, **GHSA enrichment**, **Upgrade-to-fix wired**, cask gap stated honestly | brew vulns integration | brew-browser has richer presentation + GHSA enrichment |
| Activity | **Persistent drawer** (last 200 jobs), live stdout/stderr, **resizable** | Terminal panel (toggle, no persistence) | brew-browser's history persistence + resizing is better UX |
| Pin/Unpin | **brew pin/unpin in GUI**, pin filter, pinned excluded from upgrade-all counts | Not available | brew-browser just implemented this — high-demand feature |
| GitHub Integration | **Star/Watch/File-issue** from package detail, OAuth Device Flow, keychain-stored | Not available | Differentiator for OSS developers |
| Command Palette | **Global Cmd+K** | Not available | Power-user UX |
| Offline Mode | **One-click toggle** blocks all outbound | Not available | Privacy + reliability feature |
| In-app Updater | Title-bar pill, **minisign verification**, skip-version tracking | Not available | brew-browser verifies downloads cryptographically |
| AI Enrichment | **Bundled AI categories + friendly names**, live refresh (opt-in) | Manual category mapping | brew-browser uses AI to generate friendly metadata |
| Magic Search | **Name + AI name + summary + description + categories**, sub-20ms | Basic search (name + description) | brew-browser indexes richer data |
| Brew Doctor | UI integration for brew doctor output | Not directly surfaced | brew-browser shows brew doctor in Activity |
| i18n | **Russian localization** contributed, i18n foundation in both builds | **5 languages** (EN/ES/RU/UK/HI) | BrewMate actually has more languages! |
| Linux Support | **Shipping .deb/.rpm/.AppImage** via CI | macOS-only | brew-browser has broader platform reach |
| Curated Upgrade | **Choose which packages to upgrade** in modal | Upgrade All button only | BrewMate needs selective upgrade |
| Storage Breakdown | Cellar/Caskroom/var/log/cache with **Reveal in Finder** | Total cache size only | brew-browser's per-directory breakdown is more useful |
| Donut Chart | **Hover interaction** (slice fattens, center shows count/label) | Hover shows label | BrewMate donut is less interactive |

### Issues Users Are Raising (brew-browser)

Based on 24 open issues and feature requests:

| Theme | Count | Examples |
|---|---|---|
| **Pin/ignore updates** | 2 requests | #90, #134 — "no desire to upgrade Chrome every time" |
| **brew update failures** | 5 | Proxy issues, untrusted taps, network flakes |
| **brew upgrade failures** | 6 | Conflicting formulae, download errors, tap trust |
| **brew services failures** | 3 | Postgres, launchd errors |
| **Brew Doctor inconsistencies** | 1 | Different output vs terminal due to PATH not loading .zshrc |
| **Catalog refresh issues** | 1 | Mixed error+success state |
| **Vuln scan edge cases** | 1 | Tap formula name parsing |

### What Users Want Most

1. **Pin/ignore specific package updates** (most requested) — already implemented in brew-browser v0.6.0
2. **Better error handling for brew failures** — especially tap trust, network proxies, conflicting formulae
3. **Resizable Activity drawer** — PR #136 submitted
4. **i18n** — Russian localization PR #133 submitted
5. **Reverse-dependency info** — planned for next release
6. **Deprecated/disabled indicators** — planned
7. **Manual vs Dependency filters** — planned
8. **Per-package disk size** — planned

## What BrewMate Should Implement

### Priority 1 (High Impact, Medium Effort)

1. **Pin/Unpin packages in GUI** — brew `pin`/`unpin` already exist. Add a pin button to each package row + a Pinned filter. Uses `brew pin <formula>` / `brew unpin <formula>`. Prevents specific packages from showing in upgrade-all. BrewMate's SoftwareManager + brew.ts already track outdated packages — adding pin detection is straightforward.

2. **Curated Upgrade modal** — Instead of just "Upgrade All", show a modal checklist of outdated packages with checkbox selection. Single batched `brew upgrade <pkg1> <pkg2> ...`. Pin-disabled packages shown greyed out.

3. **Storage usage breakdown** — Replace the single cache size card with per-directory breakdown:
   - Cellar (`brew --cellar`)
   - Caskroom (`brew --caskroom`)
   - Homebrew var/log (`brew --prefix`/var/log)
   - Cache (`brew --cache`)
   - Each with "Reveal in Finder" button
   - BrewMate already calculates directory sizes (`getDirSize` in renderer.ts)

4. **Resizable terminal/Activity drawer** — Persist the terminal panel height between sessions. Store size in settings. Minimum height with drag handle. brew-browser uses 252px min / 60% window-height max.

5. **Snapshots (Brewfile save/restore)** — Expose `brew bundle dump` in the GUI. Let users name/date-stamp snapshots. One-click restore = `brew bundle --file=<path>`. This is a **killer feature** for machine migration.

### Priority 2 (Medium Impact, Medium Effort)

6. **Library view improvements** — Add to the installed apps view:
   - Sortable columns (name, version, type, outdated status)
   - Outdated badges per row (BrewMate shows outdated in a separate view)
   - Category chip filters
   - Vulnerable filter pill (already have vulns scan — surface it per-row)
   - Inline severity dots for vulnerable packages

7. **Discover (Catalog Browser) improvements** — Enhance the Explore view:
   - Multi-select category filter chips (currently single-select)
   - Subcategory browsing for large categories
   - Bundled catalog for offline use (BrewMate already caches — just make caching more robust)

8. **Trending with velocity** — Show 30/90/365-day windows with a velocity indicator. Compute: `recent_month_installs / avg(prior_11_months)`. Label: 🔥 hot, ❄️ cooling, — stable.

9. **Per-package detail panel expansion** — Add to the slide-over sidebar:
   - GitHub stats card (stars, forks, last release)
   - Security card with CVE count + severity
   - Install history (if we add tracking)
   - Dependencies / reverse-dependencies
   - Homepage + source URL
   - **Pin/Unpin button**

### Priority 3 (Lower Effort, Nice to Have)

10. **Cmd+K command palette** — Simple overlay with common actions: navigate to sections, install "pkg", search, toggle terminal, toggle dark mode. Can be implemented as a hidden search input that opens on Cmd+K.

11. **Offline Mode** — A settings toggle that blocks all outbound network calls. For BrewMate this means: skip catalog refresh, skip trending fetch, skip vuln scan. Use cached data only.

12. **Brew Doctor integration** — Run `brew doctor` from the Dashboard, show warnings/errors in the terminal panel with severity classification.

13. **Activity history persistence** — Store last N brew command outputs to disk (JSONL). Show history in the terminal panel. Allow scrolling through past sessions.

14. **GitHub integration** — OAuth Device Flow for GitHub. Show star count on package detail. Allow starring/watching from the app. Optional, opt-in.

### Architecture Observations

**brew-browser does better:**
- **150+ typed Tauri commands** vs BrewMate's ~30 IPC handlers — finer-grained IPC means the frontend can request exactly what it needs
- **No `tauri-plugin-shell`** — every command built from typed Rust enums (security posture)
- **Two parallel builds** — Tauri for cross-platform + SwiftUI for native macOS
- **Bundled catalog** (~6 MiB gzipped) means offline-first by default
- **Data contracts** — `categories.json`, `enrichment.json`, shared across both builds
- **Security audit** — documented in `memory-bank/security.md`, 16 findings all fixed
- **Deterministic fuzzing** — brew-output parsers fuzzed in Rust + Swift

**BrewMate does better:**
- **More languages** — 5 vs brew-browser's 2 (English + Russian in PR)
- **Mac App Store distribution** — full MAS pipeline
- **Virtual scrolling** — handles ~100k items efficiently
- **Simpler tech stack** — Electron + vanilla TS means lower maintenance burden than dual-build Tauri + SwiftUI

## Linux Support Assessment

Created issue #384 on BrewMate: [Feature: Linux support — feasibility research and implementation plan](https://github.com/romankurnovskii/BrewMate/issues/384)

**Verdict**: Feasible with moderate effort (estimated 2-4 weeks for a solid implementation).
- Electron already has first-class Linux support
- Main work: replace macOS-specific paths, add Linuxbrew detection, update CI
- brew-browser proves the concept works and has solved similar problems
- BrewMate's current architecture (Electron + vanilla TS) is more cross-platform-friendly than brew-browser's dual-build approach

## Outcome

- ✅ Linux support issue opened: [BrewMate #385](https://github.com/romankurnovskii/BrewMate/issues/385)
- ✅ Package Pinning feature request: [BrewMate #386](https://github.com/romankurnovskii/BrewMate/issues/386)
- ✅ Brewfile Snapshots feature request: [BrewMate #387](https://github.com/romankurnovskii/BrewMate/issues/387)
- ✅ Selective Upgrade Panel feature request: [BrewMate #388](https://github.com/romankurnovskii/BrewMate/issues/388)
- ✅ Storage Analyzer feature request: [BrewMate #389](https://github.com/romankurnovskii/BrewMate/issues/389)
- ✅ Comprehensive feature comparison completed
- ✅ Priority-ranked implementation recommendations

## Files Referenced

- `src/renderer/renderer.ts` — Main UI logic (1898 lines)
- `src/utils/brew.ts` — Brew CLI wrappers
- `src/utils/path.ts` — Path detection
- `src/managers/SoftwareManager.ts` — Data management
- `src/constants.ts` — Configuration constants
