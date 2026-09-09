---
name: devhub_architecture
description: Guidelines for Developer Hub (dev-hub.html / dev-blue.html) modular SPA architecture, Single Source of Truth, Zero-Trust SEPS Wallet, 6-language i18n, and compiler boundaries.
---

# Developer Hub SPA Architecture & Invariants

This skill defines the architectural rules, module boundaries, and coding standards for the **Developer Hub** (`docs/dev-hub.html` and `docs/dev-blue.html`), its compilation engine (`scripts/internal/generate_dev_hub.py` and `scripts/internal/dev_hub/`), and associated bridge daemon (`scripts/internal/dev-hub-bridge.py`).

---

## 1. When to Use & Negative Routing

### Positive Triggers (Activate this skill when:)
- Developing, modifying, or debugging Developer Hub SPA pages (`docs/dev-hub.html`, `docs/dev-blue.html`).
- Editing compilation scripts under `scripts/internal/dev_hub/` (`catalog.py`, `topology.py`, `compiler.py`, `diagnostics.py`, etc.).
- Modifying client-side assets (`scripts/internal/dev_hub/assets/style.css`, `app.js`, `i18n.js`, templates).
- Working on the Dev Hub background bridge daemon (`scripts/internal/dev-hub-bridge.py`).
- Handling Dev Hub task execution, live log streaming, or service toggle actions (`toggleModuleBridge`).
- Adding new tabs, modals, translations, or statistics to the Dev Hub interface.

### Negative Routing (What NOT to do here:)
| Request / Intent | Do NOT handle here | Route to Skill |
|---|---|---|
| Modifying blueprint YAML profiles or topology logic | `blueprints_and_topology` | Use [blueprints_and_topology](file:///.agents/skills/blueprints_and_topology/SKILL.md) |
| Authoring or formatting Mermaid diagrams | `mermaid_diagram_design` | Use [mermaid_diagram_design](file:///.agents/skills/mermaid_diagram_design/SKILL.md) |
| Running or debugging container health / Podman compose | `oracle_containers` | Use [oracle_containers](file:///.agents/skills/oracle_containers/SKILL.md) |
| Managing SEPS wallet credentials or password extraction | `wallet_security_rotation` | Use [wallet_security_rotation](file:///.agents/skills/wallet_security_rotation/SKILL.md) |
| Running or adding automated regression test suites | `testing_and_ci_framework` | Use [testing_and_ci_framework](file:///.agents/skills/testing_and_ci_framework/SKILL.md) |

---

## 2. Modular Directory Layout

The generator follows a strict separation of concerns, eliminating monolithic multi-thousand-line Python f-strings:

```
scripts/internal/
├── generate_dev_hub.py              # Slim CLI orchestrator (< 100 lines)
└── dev_hub/                         # Modular package
    ├── __init__.py
    ├── catalog.py                   # BP_CATALOG (0..11) & DOC_SPECS metadata and multilingual info
    ├── topology.py                  # Dynamic Mermaid architecture generator from YAML profiles
    ├── diagnostics.py               # SEPS Wallet passwords, benchmarks, install_logs, Podman live state
    ├── parser.py                    # .env.* blueprint parser (components, ports, users, diagrams)
    ├── compiler.py                  # Standalone HTML compiler assembling assets into dev-hub.html
    ├── glossary.py                  # 6-language architecture acronyms & glossary engine
    ├── testing.py                   # Test suites catalog & historical execution engine
    └── assets/                      # Pure web assets (clean syntax, no Python f-string escaping!)
        ├── style.css                # Pure CSS (custom properties, glassmorphism, responsive grid)
        ├── app.js                   # Pure JavaScript (toggleModuleBridge, healthchecks, wallet, modals, repo stats)
        ├── i18n.js                  # Symmetric 6-language dictionary (EN, ET, FI, SV, LV, LT)
        └── templates/
            ├── layout.html          # HTML shell (head, navbar, drawer, modals, footer)
            └── ...                  # Embedded section templates
```

---

## 3. Developer Editing Guide: Where to Make Changes

Whenever updating Developer Hub features, follow this file routing contract:

| Task | Target File | Notes |
|---|---|---|
| **Styling, colors, layout, animations** | `scripts/internal/dev_hub/assets/style.css` | Use pure CSS with standard `{` and `}` braces. Never double braces. |
| **Client JS, buttons, filters, health** | `scripts/internal/dev_hub/assets/app.js` | Pure JS. Maintain `toggleModuleBridge` and `loadRepoStatistics`. |
| **Translations across 6 languages** | `scripts/internal/dev_hub/assets/i18n.js` | Maintain 100% dictionary symmetry across `en`, `et`, `fi`, `sv`, `lv`, `lt`. |
| **Blueprint metadata, RAM, categories** | `scripts/internal/dev_hub/catalog.py` | Add/update blueprint titles, categories, and memory guidelines. |
| **Architecture Glossary & Acronyms** | `scripts/internal/dev_hub/glossary.py` | Terms and definitions across all 6 languages. |
| **Test Suites & Testing Tab** | `scripts/internal/dev_hub/testing.py` | Registered test suites and script associations. |
| **Codebase Health & Statistics Engine**| `scripts/internal/generate-repo-report.py` | SLOC, language breakdown, test density ratio. |
| **Mermaid architecture diagrams** | `scripts/internal/dev_hub/topology.py` | Break decision diamonds into multiple lines (`<br/>`) per Rule 10. |
| **Wallet accounts, logs, benchmarks** | `scripts/internal/dev_hub/diagnostics.py` | Query SEPS wallet strictly in-memory per Rule 5. |
| **HTML structure, tabs, modals** | `scripts/internal/dev_hub/assets/templates/` | Standard HTML templates with `%TOKEN%` injection points. |

---

## 4. Strict Architectural Invariants

### 4.1 Standalone Single-File Distribution (Mandatory)
The compiled output `docs/dev-hub.html` MUST remain a 100% standalone, self-contained HTML file. All CSS, JavaScript, and translations must be bundled directly into the HTML by `compiler.py`. It MUST NOT require an external web server, Node.js, or local static asset hosting to render in any standard web browser.

### 4.2 Zero-Trust SEPS Wallet Invariant (Rule 5)
- Plaintext database passwords must NEVER be saved to the filesystem, cached in `.env`, or passed in URL query parameters.
- Dev Hub loads credentials directly in-memory from `cwallet.sso` / `mkstore` or Podman secrets at compilation time and embeds them into `LOCAL_PASSWORDS` for 1-click clipboard helpers (`copyUsername`, `handleCopyPassword`, `copyAndScrollToWallet`).

### 4.3 Multi-Language Symmetry (Rule 9)
All user-facing UI labels, buttons, tooltips, and descriptions must exist in all 6 Nordic-Baltic languages:
`🇬🇧 EN (English - Canonical)`, `🇪🇪 ET (Estonian)`, `🇫🇮 FI (Finnish)`, `🇸🇪 SV (Swedish)`, `🇱🇻 LV (Latvian)`, `🇱🇹 LT (Lithuanian)`.
Every key added to `i18n.json` must be present in all 6 language blocks.

### 4.4 Mermaid v10 DOM ID Isolation & Multi-Line Diamonds (Rule 10 & mermaid_diagram_design Skill)
- In `app.js`, always render Mermaid diagrams using async `await mermaid.render(svgId, diagCode)` with a randomized unique ID (`bp-modal-svg-${bNum}-${Math.floor(Math.random()*100000)}`). Never use static DOM IDs which cause Mermaid v10 cache collisions.
- Mermaid decision diamonds (`{...}`) must always be broken into 2–4 concise lines using HTML `<br/>` tags (max 25–28 chars per line).
- Avoid overly wide horizontal layouts (`direction LR` with > 4 nodes); prefer `direction TB` or grouped subgraphs with box lines broken to max 30–35 chars so text remains easily readable on laptops.

### 4.5 Unified Toggle Engine (`toggleModuleBridge`)
Card action buttons (`▶️ Start Service`, `⏹️ Stop Service`) and stack switch buttons (`⚡ Lülitu sellele stäkile`) MUST route through `toggleModuleBridge(modKey, action)`:
- Enforces **Core Base Protection** (prohibits stopping `db-proxy` or `app-ords` via web).
- Calls Bridge API `POST /api/toggle?module=...&action=...` when online.
- Fallback: Automatically copies CLI command (e.g. `./scripts/start-containers.sh ...`) to the clipboard with toast feedback if the bridge is offline or browser blocks HTTP under HTTPS.
- Automatically triggers delayed `checkServiceHealth()` to refresh status pills.

### 4.6 Mandatory Asynchronous Long-Running Task Contract (Rule 12)
- Any setup, deployment, rebuild, or deep reset taking > 10s MUST be executed as an asynchronous background task (`ACTIVE_TASKS` in `dev-hub-bridge.py` via `subprocess.Popen`).
- Synchronous blocking `fetch` requests with short browser-side timeouts (e.g. 300s AbortController) on setup operations are **strictly prohibited**. Cold setup operations take 4–7 minutes; synchronous fetch calls will reliably abort with `signal is aborted without reason` even while the server process succeeds.
- Frontend MUST dispatch the task, receive immediate `{ status: "ok", task: ... }`, and poll `/api/task/status?task=...` while streaming live logs until `state: "completed"` or `state: "failed"`.

### 4.7 Delayed Active Blueprint & Verified State Contract (Rule 12)
- A blueprint MUST NOT be marked `🟢 Online / Aktiivne` or written to `.active_blueprint` when containers are merely starting or initializing.
- Cards must reflect real state: `⏳ Paigaldamisel...` (while setup is active), `🟡 Käivitumas...` (while container healthcheck is starting), and `🟢 Aktiivne` ONLY after database initialization, SEPS Wallet credentials, and URL endpoints are 100% verified.

### 4.8 Dual-Protocol Bridge & Zero-Dependency Embedded Profiles (Rule 4 & Rule 5)
- **Dual-Protocol Bridge (HTTP :8089 & HTTPS :8449):** `dev-hub-bridge.py` starts both standard HTTP on port `8089` and a background TLS/HTTPS listener on port `8449` using `config/certs/localhost.crt` and `localhost.key`. This completely eliminates browser Mixed Content blocking (`Failed to fetch`) when Dev Hub is accessed via ORDS TLS (`https://localhost:8448/dev-hub`).
- **Dynamic BRIDGE_URL Resolution:** Frontend dynamically resolves the bridge origin to match document protocol: `isHttps ? 'https://localhost:8449' : 'http://localhost:8089'`.
- **Offline Pre-Embedding (Instant UX):** All 22 YAML profiles (`window.PROFILES_DATA`) and 12 blueprints (`window.BLUEPRINTS_DATA`) are pre-compiled directly into `dev-hub.html` with full content and metadata. The profile manager and blueprint viewer render immediately from in-memory cache upon opening. Even if the bridge daemon is stopped, users can browse, inspect, and copy all configurations in read-only mode.
- **Strict Variable Scoping:** State variables (`CURRENT_PROFILE_PATH`, `CURRENT_BP_PATH`, `CACHED_PROFILES`, `CACHED_BLUEPRINTS`) must be cleanly declared with `let` to guarantee zero `ReferenceError` crashes across browsers.

---

## 5. Operational Playbooks & Step-by-Step Execution

### 5.1 Recompiling Dev Hub (`generate_dev_hub.py`)
Whenever editing templates, assets, catalog, or diagnostics, recompile the standalone portal:
```bash
python3 scripts/internal/generate_dev_hub.py
```
Outputs:
- `docs/dev-hub.html` (Primary dark-themed Dev Hub)
- `docs/dev-blue.html` (Alternative blueprint view)

### 5.2 Validating Dev Hub HTML Integrity
Verify token replacement, JS syntax, and standalone completeness:
```bash
./tests/unit/test-dev-hub-generation.sh
```

### 5.3 Starting the Dev Hub Bridge Daemon
For full interactive control (1-click stack switches, live log streaming, container toggles):
```bash
# Start dual HTTP (8089) and HTTPS (8449) bridge daemon:
python3 scripts/internal/dev-hub-bridge.py &

# Verify bridge health:
curl -s http://localhost:8089/api/health | jq .
```

---

## 6. Prohibited Anti-Patterns

- ❌ **No Python f-string Escaping:** Do not embed raw CSS or JavaScript inside Python f-strings where `{` and `}` have to be doubled (`{{` and `}}`).
- ❌ **No Hardcoded Ports or Passwords:** Never hardcode port numbers (`1521`, `8448`), usernames, or passwords. Dynamically resolve all ports from YAML profiles and `.env`.
- ❌ **No Dead Code Accumulation:** When removing UI sections, prune unused CSS classes and unused i18n dictionary keys across all 6 languages.
- ❌ **No Third-Party Python Dependencies:** Use only Python 3 standard library (`os`, `sys`, `json`, `re`, `pathlib`, `glob`, `datetime`, `subprocess`) plus `yaml` (PyYAML). Do not introduce Jinja2 or external build tools.
- ❌ **No Blocking Synchronous Calls on Long Tasks:** Never run cold setups or migrations synchronously in browser requests.

---

## 7. Diagnostic Signatures & 1-Line Remedies

| Symptom / Error | Root Cause | 1-Line Remediation |
|---|---|---|
| `Mixed Content: ... was loaded over HTTPS, but requested an insecure resource` | Browser blocked HTTP `:8089` call under HTTPS `:8448` | Ensure `dev-hub-bridge.py` is running its background HTTPS `:8449` thread with `localhost.crt`. |
| Unrendered `%TOKEN%` visible in generated HTML | Missing token replacement in `compiler.py` | Add token mapping in `scripts/internal/dev_hub/compiler.py` `compile_dev_hub()`. |
| `Cannot read properties of undefined (reading 'render')` | Mermaid.js not loaded or DOM element missing | Check script tag in `layout.html` and verify target SVG container ID exists. |
| `SyntaxError: Identifier 'CURRENT_PROFILE_PATH' has already been declared` | Variable re-declaration conflict in global scope | Scope modal helper variables using `let` and prevent duplicate asset bundling. |
| Card remains stuck in `Paigaldamisel...` | Long-running task failed or `.setup_in_progress` lock lingering | Check `/api/task/status?task=setup` or remove stale `.setup_in_progress` in workspace root. |
