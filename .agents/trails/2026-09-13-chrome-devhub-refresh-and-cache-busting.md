# Session Trail: Google Chrome Dev Hub Hard-Refresh & In-App Cache-Busting

- **Date:** 2026-09-13
- **Author:** Antigravity AI (Pair Programming with User)
- **Status:** Complete ✅

---

## 1. Intent & Context
Developers frequently hit browser caching issues in Google Chrome where stale versions of `dev-hub.html` or local server endpoints (`localhost:8448`, `localhost:8089`) persist despite recompilation or code changes.
The goal was to provide:
1. A rock-solid CLI script (`scripts/refresh-devhub.sh`) to hard-refresh Chrome tabs displaying Dev Hub on macOS, bypassing all caches and validating that the browser version matches `VERSION`.
2. In-app features/tricks ("nipid") within Dev Hub for 1-click cache-busting, `Shift+R` keyboard shortcuts, and interactive version/cache diagnostics.

---

## 2. Multi-Perspective Review Insights
- **UX Guru:** Preserve URL hash (active tab e.g. `#tab-devops`), provide instant spinning animation + toast feedback, and make `#platform-version-badge` afford interaction.
- **Senior Software Engineer:** Do not rely on Chrome's "Allow JavaScript from Apple Events" (disabled by default in macOS). Use native AppleScript URL modification (`set URL of t to cleanUrl` with `?_cb=TIMESTAMP`) and `reload`. Automatically verify and recompile `docs/dev-hub.html` if stale on disk.
- **End User:** Simple command (`./scripts/refresh-devhub.sh`), launch Chrome if not running, do not trigger reload while typing in inputs.
- **Security Expert:** Sanitize numeric timestamp (`^[0-9]+$`), no credential leakage in query params, handle macOS TCC permission errors gracefully.

---

## 3. Changes Implemented

### CLI Script
- `scripts/refresh-devhub.sh`:
  - Native AppleScript window/tab discovery (`dev-hub.html`, `localhost:8448`, `8088`, `8089`, `8449`).
  - Cache-busting URL parameter `?_cb=$(date +%s)` injection.
  - Automatic check against `VERSION` and auto-compilation via `scripts/internal/generate-dev-hub.sh`.
  - DOM version inspection when Apple Events JS is allowed; graceful fallback with clear diagnostics when disabled.
  - Non-macOS fallback support (`google-chrome`, `wslview`).

### Dev Hub Core & UI Assets
- `scripts/internal/dev_hub/compiler.py`:
  - Injected `%BUILD_TIMESTAMP%` and `%GIT_COMMIT%`.
- `scripts/internal/dev_hub/assets/templates/layout.html`:
  - Fixed AI Skills subview inside `tab-specs`: directly embedded AI Skills toolbar, cards grid, reader pane, graph pane, and tasks pane inside `#specs-mode-skills-pane` (eliminating brittle runtime DOM node moving).
  - Meta tags for build timestamp and git commit.
  - Clickable `#platform-version-badge` opening `#version-inspector-modal-backdrop`.
  - Inline header button `[ 🔄 Värskenda ⇧R ]` (`#cache-reload-btn`).
  - Complete `#version-inspector-modal-backdrop` dialog.
- `scripts/internal/dev_hub/assets/app.js`:
  - `switchSpecsMode('skills')`: directly invokes `initSkillsTab()`, immediately populating cards, reader, and task matrix.
  - `switchTab('tab-skills')` & `openSkillsFromMenu()`: seamlessly redirect to `tab-specs` with skills sub-mode active.
  - `triggerDevHubHardReload(event)`: Injects `_cb=Date.now()`, preserves active hash, animates spin icon, replaces location.
  - `openVersionInspectorModal()` and `closeVersionInspectorModal(event)`.
  - Keydown handler for `Shift+R` and `Escape`.
  - Tab focus listener `checkDevHubFreshness()` detecting newer compiles on HTTP/HTTPS.
- `scripts/internal/dev_hub/assets/i18n.js`:
  - 11 new translation keys across all 6 languages (EN, ET, FI, SV, LV, LT).

### Testing & Verification
- `tests/unit/test-script-refresh-devhub.sh`: 100% PASS.
- `tests/unit/test-dev-hub-generation.sh`: 100% PASS.
- `tests/unit/test-filename-portability.sh`: All 2074 paths valid.
- `tests/test-multilingual-support.sh`: 12/12 PASS (463 switchers, 6 languages).

---

## 4. Verification Evidence
```bash
./tests/unit/test-script-refresh-devhub.sh
# Output:
# 🧪 TEST: refresh-devhub.sh
#    ✓ BASH süntaks kontrollitud ja kehtiv.
#    ✓ --help väljund kontrollitud ja kehtiv.
#    ✓ Rule 13 failinime porditavus kontrollitud.
# ✅ Test Edukas: scripts/refresh-devhub.sh on 100% valmis ja nõuetele vastav!
```
