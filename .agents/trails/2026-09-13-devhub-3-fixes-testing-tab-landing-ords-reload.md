# Session Trail: Dev Hub 3 Bug Fixes (Testing Tab DOM, Home Tab Landing, ORDS Reload Redirect)

**Date:** 2026-09-13  
**Status:** ✅ Completed & Verified  
**Scope:** `layout.html` (DOM Tag Balance), `app.js` (`renderDocsNav`, Landing Resolution, `triggerDevHubHardReload`), `refresh-devhub.sh` (AppleScript Filter)  

---

## 1. Problem Statements & Root Causes
1. **Testing tab empty black screen:** `layout.html` line 1669 (`#repo-stats-widget`) was missing closing `</div>`. As a consequence, `tab-devops` was not closed before `tab-testing`, nesting `tab-testing` inside `tab-devops`. When switching to Testing tab, `tab-devops` was hidden (`display: none;`), hiding `tab-testing` as well.
2. **Pinned home tab ignored / Onboarding opened instead:** `setLanguage()` on startup called `renderDocsNav()`, which called `loadDocContent(0)` with `skipHistory = false`. This pushed `#tab-docs?doc=getting-started` to browser history/hash before landing resolution ran. Landing resolution found the freshly pushed hash and ignored user's `pinnedHome` (`dev_hub_home_tab`).
3. **Refresh button redirected to ORDS landing page (`localhost:8448/ords/_landing#tab-services`):** Appending `?_cb=TIMESTAMP` to `https://localhost:8448/dev-hub.html` caused ORDS standalone Jetty docroot to fail path matching, triggering an automatic 302 Found redirect to `/ords/_/landing`, carrying over the `#tab-services` fragment.

---

## 2. Solutions Implemented
- **`layout.html`:** Added missing closing `</div>` after line 1789. Verified 0 unclosed tags in template and compiled HTML.
- **`app.js`:**
  - In `renderDocsNav()`: passed `skipHistory = true` to `loadDocContent` to eliminate history pollution during background rendering.
  - In Landing Resolution: prioritized `pinnedHome` over restored URL hashes when opening cold.
  - In `triggerDevHubHardReload()`: bypassed `?_cb=` query string when on `http:`/`https:` (ORDS ports 8448/8088), using `fetch(..., { method: 'HEAD', cache: 'reload' })` + `window.location.reload()`.
- **`refresh-devhub.sh`:** Narrowed down AppleScript tab matching to `dev-hub.html`, `hub.html`, `:8089`, and avoided adding query string to HTTP/HTTPS tabs on reload.

---

## 3. Verification & Quality Gates
- Python Tag Validator: 0 unclosed tags in `layout.html`, `tab-devops` and `tab-testing` verified as top-level siblings.
- `./tests/unit/test-dev-hub-generation.sh`: ✅ PASS
- `./tests/unit/test-devhub-testing-tab.sh`: ✅ PASS
- `./tests/unit/test-script-refresh-devhub.sh`: ✅ PASS
- `./tests/unit/test-filename-portability.sh`: ✅ PASS (All 2088 paths compliant with Rule 13)
- `./tests/test-multilingual-support.sh`: ✅ PASS (12/12, 100% parity across 6 languages)
