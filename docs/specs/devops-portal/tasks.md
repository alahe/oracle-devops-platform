# DevOps Portal — Traceability Matrix & Tasks

- **Domain (SCS):** `devops-portal`
- **Referenced Requirements:** `docs/specs/devops-portal/requirements.md`
- **Referenced Design:** `docs/specs/devops-portal/design.md`
- **Methodology:** Thomas Dohmke (Agentic Assembly Line) & Julian Wood (Tasks Traceability)

---

## 1. Traceability Matrix

| Task ID | Requirement | Component / File | Verification Command | Status |
| :--- | :--- | :--- | :--- | :--- |
| **TSK-DP-01** | `[REQ-01]` | `layout.html` (Card Separation) | `./tests/unit/test-devhub-testing-tab.sh` | ✅ Completed |
| **TSK-DP-02** | `[REQ-02]` | `app.js` (Docked Console & Ring-Buffer) | `node --check scripts/internal/dev_hub/assets/app.js` | ✅ Completed |
| **TSK-DP-03** | `[REQ-03]` | `app.js` (Setup & Reset Command Studios) | `./tests/unit/test-dev-hub-generation.sh` | ✅ Completed |
| **TSK-DP-04** | `[REQ-04]` | `layout.html` / `style.css` (Safety Gates) | Visual inspection & unit tests | ✅ Completed |
| **TSK-DP-05** | `[REQ-05]` | `app.js` (1-Click AI Troubleshooting) | Tested via Copilot/Antigravity integration | ✅ Completed |
| **TSK-DP-06** | NFR-1 | `dev-hub-bridge.py` (Regex & Mutex) | `./scripts/check-pre-commit.sh` | ✅ Completed |
| **TSK-DP-07** | NFR-i18n | `i18n.js` (6 Languages EN/ET/FI/SV/LV/LT) | `./tests/test-multilingual-support.sh` | ✅ Completed |
| **TSK-DP-08** | `[REQ-06]` | `bump-iteration.sh`, `release.sh` | `./tests/unit/test-semantic-versioning.sh` | ✅ Completed |
| **TSK-DP-09** | `[REQ-07]` | `layout.html`, `app.js`, `i18n.js` | `./tests/unit/test-devhub-landing-tab.sh` | ✅ Completed |
| **TSK-DP-10** | `[REQ-08]` | `dev-hub-bridge.py`, `layout.html`, `app.js`, `i18n.js` | `./tests/unit/test-devhub-podman-runner.sh` | ✅ Completed |

---

## 2. Implementation History & Atomic Tasks

- [x] **TSK-DP-01:** Purged test cards from `⚡ DevOps` and migrated them to `🧪 Testing`.
- [x] **TSK-DP-02:** Implemented bottom slide-out console `#devops-docked-terminal` with live timer, ANSI parser, and 1500-line DOM ring buffer.
- [x] **TSK-DP-03:** Created `Setup Studio` and `Reset Studio` with mutually exclusive radio pills and real-time CLI preview.
- [x] **TSK-DP-04:** Added semantic safety indicators (`safe`, `action`, `destructive`) and 2-stage destructive confirmation.
- [x] **TSK-DP-05:** Integrated `askAiAboutCurrentTerminalError()` and `explainStudioCmdWithAi()` with Copilot/Antigravity split-pane.
- [x] **TSK-DP-06:** Added Mutex lock (HTTP 409) and username regex sanitizer (`^[a-zA-Z0-9_]{3,30}$`) to `dev-hub-bridge.py`.
- [x] **TSK-DP-07:** Integrated 26 new translation keys across 6 languages (100% test pass).
- [x] **TSK-DP-08:** Implemented 4-part iteration counter (`bump-iteration.sh`), Conventional Commits semantic release, and pre-push hook.
- [x] **TSK-DP-09:** Implemented home tab pinning (📌), smart adaptive landing, and 6-language synchronization.
- [x] **TSK-DP-10:** Implemented Podman VM and container startup capability in Dev Hub (`dev-hub-bridge.py`, `layout.html`, `app.js`, `i18n.js`, `test-devhub-podman-runner.sh`).

---

## 3. Autonomous Verification Cycle (Ralph Loop Invariant)

Per Rule 19, validation of all atomic tasks follows an autonomous Ralph Loop cycle:
1. **Execute:** Run target test suite or local CI.
2. **Evaluate:** If test fails, analyze failure output in context.
3. **Remediate:** Apply code patch autonomously without requiring human intervention.
4. **Verify:** Repeat cycle until 100% of test suites pass (exit code 0).
5. **Quality Gates:** Pass all 5 Quality Gates (Security, Functionality, Multilingual, Portability, Performance).
