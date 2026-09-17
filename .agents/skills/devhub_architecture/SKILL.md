---
name: devhub_architecture
description: Guidelines for Developer Hub (dev-hub.html / dev-blue.html) modular SPA architecture, Single Source of Truth, Zero-Trust SEPS Wallet, 6-language i18n, dark/light dual-theme support (dark default), and compiler boundaries.
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

### 4.9 Zero-Trust Web Authentication Relay Engine (Rule 5)
For complex enterprise portals (such as Oracle Analytics Publisher / WebLogic) where query-string authentication is prohibited or unsupported:
- **Relay Endpoint (`/api/publisher/open?user=<role>`):** The client opens the bridge relay endpoint in a new tab. The bridge extracts credentials strictly in-memory from the SEPS Wallet (`get-password.sh <ALIAS>`) and renders an auto-submitting POST form targeting `http://localhost:9502/xmlpserver/login.jsp`.
- **Session Stickiness Resolution:** To prevent WebLogic from reusing a previously active session (e.g. `bip_admin`) when switching to `bip_developer` or `bip_user`, the Bridge sends immediate session-expiration headers:
  `Set-Cookie: JSESSIONID=deleted; Path=/xmlpserver; Max-Age=0; Expires=Thu, 01 Jan 1970 00:00:00 GMT; HttpOnly; SameSite=Lax`.
- **Card-Level Sign-Out Control:** Cards for stateful middleware provide a direct `🚪 Sign Out (Puhasta sessioon)` link to the vendor logout servlet (`/xmlpserver/signout.jsp`).

### 4.10 Mandatory Platform Version Bumping & Header/Footer Visibility Contract (Rule 16)
- **Single Source of Truth (`VERSION`):** The repository root `VERSION` file is the sole authoritative definition of the platform version.
- **Mandatory Bump on Code Changes:** Whenever code changes, bug fixes, UI improvements, or scripts are committed, the version in `VERSION` MUST be bumped (semver).
- **Dual Visual Visibility:** The version MUST be visibly rendered in both:
  1. Sticky Navigation Header (`#platform-global-version`): `🚀 Oracle DevOps Platform • v<VERSION>`
  2. Platform Footer (`#footer-platform-version`): `© 2026 Oracle DevOps Platform • v<VERSION>`
- **Live Bridge Lockstep:** `dev-hub-bridge.py` dynamically reads `VERSION` on `/api/version` and `/api/health`, preventing any version drift between the backend bridge and client UI.
- **Eliminating Stale Cache Testing:** If a developer or user opens Dev Hub and observes an outdated version in either the header or footer, it immediately flags that the browser or ORDS/Jetty is serving a cached build, prompting a hard refresh (Ctrl+F5 / Cmd+Shift+R).

### 4.11 DevOps Management Tab & Docked Terminal Contract (ADR 0017)
- **Separation of Concerns:** `⚡ DevOps` tab is strictly for platform lifecycle, configuration, and tools. All CI test suites belong exclusively to `🧪 Testimine`.
- **Log Streaming:** Execution logs stream into the Docked Terminal Drawer (`#devops-docked-terminal`) with DOM ring-buffer (1500 lines) and `⏱️` timer. Cards show only a compact status strip.
- **Safety & Mutex:** Destructive commands (`reset-all --system`) require 2-step confirmation. Concurrent long-running operations are rejected with HTTP 409.
- **AI Remediation:** Failed commands link to Copilot/Antigravity via `askAiAboutTerminalError()`.
- **Full Architecture & Business Rationale:** [`docs/adr/0017-devops-tab-ux-and-docked-terminal.md`](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/adr/0017-devops-tab-ux-and-docked-terminal.md) and [`docs/specs/devops-management-portal-spec.md`](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/specs/devops-management-portal-spec.md).

### 4.12 Dual-Theme Support (Dark & Light) & Dark-First Default Invariant
- **Mandatory Dual-Theme Architecture:** Developer Hub (`docs/dev-hub.html` and `docs/dev-blue.html`) MUST provide first-class, seamless support for both **Dark Theme (`[data-theme="dark"]`)** and **Light Theme (`[data-theme="light"]`)**.
- **Dark-First Default Invariant (Mandatory Initial Choice):**
  - The default, out-of-the-box theme for all users and fresh browser sessions MUST ALWAYS be **Dark Theme** (`data-theme="dark"`).
  - If no explicit user preference is stored in `localStorage.getItem('dev_hub_theme')`, the application automatically defaults to Dark Theme.
  - Flash-of-Unstyled-Theme (FOUT) is prevented via an immediate synchronous script in `<head>`.
- **Theme Switching & Shortcuts:**
  - Fast 1-click theme toggle button (`#theme-toggle-btn`) in the sticky navigation header toggles between Dark (`🌙`) and Light (`☀️`) modes with smooth transitions.
  - Global keyboard shortcut **`Alt+T`** instantly toggles the active theme.
  - State is persisted across browser reloads via `localStorage.setItem('dev_hub_theme', theme)`.
- **Zero Dark Regression Guarantee:**
  - Dark mode styles must remain 100% pristine, high-contrast, and unaltered when introducing or refining light theme styles.
- **Dark Console Invariant (Mandatory Terminal Protection):**
  - Terminal output containers, execution logs, and CLI consoles (`#terminal-output`, `.devops-docked-terminal`, `.embedded-terminal-container`, `#report-console-pre`, `#bp-config-editor-textarea`) MUST remain strictly dark (`#030712` background, `#f8fafc` text) across ALL themes, preserving developer terminal ergonomics.
- **Light Theme Contrast & Zero Black Boxes Contract (WCAG AAA):**
  - In light theme (`[data-theme="light"]`), all non-terminal components (cards, modals, tabs, tables, toolbars) must render on clean, polished surfaces (`--surface: #ffffff`, `--bg: #f8fafc`) with WCAG AAA compliant text contrast (`#0f172a` headings/bold, `#334155` body text, `#475569` labels).
  - Hardcoded dark slate or black boxes (`rgba(15, 23, 42, ...)` or `#0f172a`) are strictly prohibited in light mode UI elements (such as modal tabs, filter toolbars, and card backgrounds).
  - Text selection (`::selection`) must provide high-contrast styling (Sky Blue `#0284c7` background with pure white `#ffffff` text).

### 4.13 Mandatory Dual-Mode (Dark & Light) Invariant for New Pages & Components
Whenever any new page, tab, sub-tab, modal, card, or UI component is created or modified in Developer Hub:
- **Simultaneous Dual-Mode Delivery (Mandatory):** Both Dark Mode and Light Mode styles MUST be authored, tested, and validated simultaneously within the exact same workflow cycle. Delivering a feature only in Dark Mode or only in Light Mode is strictly prohibited.
- **Strict Text Contrast Standards (WCAG 2.1 AA $\ge 4.5:1$):**
  - In Light Mode, text on white/light surfaces MUST use dark, high-contrast colors (`#0f172a`, `#1e293b`, or `#334155`). Low-contrast light-gray text (e.g. `#cbd5e1`, `#94a3b8`) on white surfaces is strictly prohibited.
  - In Dark Mode, text on dark surfaces MUST use crisp light colors (`#f8fafc`, `#e2e8f0`, or `#cbd5e1`).
- **Button & Visual Hierarchy Discipline:**
  - Solid saturated primary color (`var(--primary)` / `#0284c7`) is strictly reserved for the single primary focal action on a screen/modal (e.g., "Save Profile", "Deploy").
  - Repeated card buttons in grids (such as skill cards, blueprint cards, DevOps cards) MUST use neutral secondary or outline styles (`background: #ffffff; border: 1px solid #cbd5e1; color: #334155;`) with gentle hover accents, preventing an overwhelming sea of solid blue boxes.
- **Active State Selection Discipline:**
  - Active selection in lists (log files, YAML profiles, blueprint trees) MUST use modern subtle accents (e.g. `border-left: 3.5px solid var(--primary); background: #f0f9ff; color: #0369a1;`) instead of thick, opaque 4-sided blue boxes.
- **Automated Verification:**
  - Every component and theme change MUST be verified by `./tests/unit/test-devhub-theme-modes.sh`.

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

### 5.4 Automated UI & WCAG Contrast Testing Engine
To ensure zero regressions across themes, tabs, modals, and WCAG 2.1 AA contrast compliance:
```bash
# Full test suite in mock mode (~1-2s):
./tests/test-devhub-ui.sh --all

# Group-specific tests:
./tests/test-devhub-ui.sh --group themes
./tests/test-devhub-ui.sh --group core

# Specific blueprint modal test:
./tests/test-devhub-ui.sh -b 3
```

#### Semantic Selectors Contract for UI Elements
To ensure UI modifications never break automated tests:
- Main navigation tabs must declare `id="tab-<name>"` and `data-tab-id="tab-<name>"`.
- Blueprints must declare `data-bp="<id>"` on cards and `id="blueprint-modal"` on the detail modal.
- Controls must preserve semantic IDs: `#theme-toggle-btn`, `#btn-podman-primary-action`, `#podman-empty-hero`.
- Translatable elements must declare `data-i18n="<key>"`.

---

## 6. Prohibited Anti-Patterns

- ❌ **No Python f-string Escaping:** Do not embed raw CSS or JavaScript inside Python f-strings where `{` and `}` have to be doubled (`{{` and `}}`).
- ❌ **No Hardcoded Ports or Passwords:** Never hardcode port numbers (`1521`, `8448`), usernames, or passwords. Dynamically resolve all ports from YAML profiles and `.env`.
- ❌ **No Dead Code Accumulation:** When removing UI sections, prune unused CSS classes and unused i18n dictionary keys across all 6 languages.
- ❌ **No Third-Party Python Dependencies:** Use only Python 3 standard library (`os`, `sys`, `json`, `re`, `pathlib`, `glob`, `datetime`, `subprocess`) plus `yaml` (PyYAML). Do not introduce Jinja2 or external build tools.
- ❌ **No Blocking Synchronous Calls on Long Tasks:** Never run cold setups or migrations synchronously in browser requests.
- ❌ **No Single-Theme Features:** Never deliver new tabs, modals, or components that only support Dark Mode or only support Light Mode. Both themes must be fully authored and validated simultaneously with WCAG 2.1 AA compliant contrast.
- ❌ **No Indiscriminate Solid Primary Buttons:** Never apply solid primary button styling (`background: var(--primary) !important`) across all `.btn` elements or repeat solid buttons on every card in a large grid.
- ❌ **No Low-Contrast Inline Colors in JavaScript:** Never hardcode low-contrast text colors (e.g., `color: #cbd5e1` or `#38bdf8`) inline in DOM generators when rendered on white/light surfaces.

---

## 7. Diagnostic Signatures & 1-Line Remedies

| Symptom / Error | Root Cause | 1-Line Remediation |
|---|---|---|
| `Mixed Content: ... was loaded over HTTPS, but requested an insecure resource` | Browser blocked HTTP `:8089` call under HTTPS `:8448` | Ensure `dev-hub-bridge.py` is running its background HTTPS `:8449` thread with `localhost.crt`. |
| Unrendered `%TOKEN%` visible in generated HTML | Missing token replacement in `compiler.py` | Add token mapping in `scripts/internal/dev_hub/compiler.py` `compile_dev_hub()`. |
| `Cannot read properties of undefined (reading 'render')` | Mermaid.js not loaded or DOM element missing | Check script tag in `layout.html` and verify target SVG container ID exists. |
| `SyntaxError: Identifier 'CURRENT_PROFILE_PATH' has already been declared` | Variable re-declaration conflict in global scope | Scope modal helper variables using `let` and prevent duplicate asset bundling. |
| Card remains stuck in `Paigaldamisel...` | Long-running task failed or `.setup_in_progress` lock lingering | Check `/api/task/status?task=setup` or remove stale `.setup_in_progress` in workspace root. |
