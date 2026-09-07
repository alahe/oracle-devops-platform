---
name: devhub_architecture
description: Guidelines for Developer Hub (dev-hub.html / dev-blue.html) modular SPA architecture, Single Source of Truth, Zero-Trust SEPS Wallet, 6-language i18n, and compiler boundaries.
---

# Developer Hub SPA Architecture & Invariants

This skill defines the architectural rules, module boundaries, and coding standards for the **Developer Hub** (`docs/dev-hub.html` and `docs/dev-blue.html`), its compilation engine (`scripts/internal/generate_dev_hub.py` and `scripts/internal/dev_hub/`), and associated bridge daemon (`scripts/internal/dev-hub-bridge.py`).

---

## 1. Modular Directory Layout

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
    └── assets/                      # Pure web assets (clean syntax, no Python f-string escaping!)
        ├── style.css                # Pure CSS (custom properties, glassmorphism, responsive grid)
        ├── app.js                   # Pure JavaScript (toggleModuleBridge, healthchecks, wallet, modals)
        ├── i18n.json                # Symmetric 6-language dictionary (EN, ET, FI, SV, LV, LT)
        └── templates/
            ├── layout.html          # HTML shell (head, navbar, drawer, modals, footer)
            ├── tab_cockpit.html     # Tab 1: Cockpit & 12 Blueprint cards
            ├── tab_presentation.html# Tab 2: 16:9 Widescreen slide deck
            ├── tab_snapshots.html   # Tab 3: Snapshots & DR recovery
            ├── tab_forms_pub.html   # Tab 4: Forms & Publisher studio
            ├── tab_apexlang.html    # Tab 5: APEXlang studio
            ├── tab_onboarding.html  # Tab 6: Onboarding & Quickstart
            ├── tab_docs.html        # Tab 7: Documentation reader
            ├── tab_devops.html      # Tab 8: Interactive DevOps console
            ├── tab_benchmarks.html  # Tab 9: Benchmarks & Execution logs
            └── modals.html          # Blueprint Topology Modal, Snippet Modal, Profile Editor
```

---

## 2. Developer Editing Guide: Where to Make Changes

Whenever updating Developer Hub features, follow this file routing contract:

| Task | Target File | Notes |
|---|---|---|
| **Styling, colors, layout, animations** | `scripts/internal/dev_hub/assets/style.css` | Use pure CSS with standard `{` and `}` braces. Never double braces. |
| **Client JS, buttons, filters, health** | `scripts/internal/dev_hub/assets/app.js` | Pure JS. Maintain `toggleModuleBridge` as the unified toggle engine. |
| **Translations across 6 languages** | `scripts/internal/dev_hub/assets/i18n.json` | Maintain 100% dictionary symmetry across `en`, `et`, `fi`, `sv`, `lv`, `lt`. |
| **Blueprint metadata, RAM, categories** | `scripts/internal/dev_hub/catalog.py` | Add/update blueprint titles, categories, and memory guidelines. |
| **Mermaid architecture diagrams** | `scripts/internal/dev_hub/topology.py` | Break decision diamonds into multiple lines (`<br/>`) per Rule 10. |
| **Wallet accounts, logs, benchmarks** | `scripts/internal/dev_hub/diagnostics.py` | Query SEPS wallet strictly in-memory per Rule 5. |
| **HTML structure, tabs, modals** | `scripts/internal/dev_hub/assets/templates/` | Standard HTML templates with `%TOKEN%` injection points. |

---

## 3. Strict Architectural Invariants

### 3.1 Standalone Single-File Distribution (Mandatory)
The compiled output `docs/dev-hub.html` MUST remain a 100% standalone, self-contained HTML file. All CSS, JavaScript, and translations must be bundled directly into the HTML by `compiler.py`. It MUST NOT require an external web server, Node.js, or local static asset hosting to render in any standard web browser.

### 3.2 Zero-Trust SEPS Wallet Invariant (Rule 5)
- Plaintext database passwords must NEVER be saved to the filesystem, cached in `.env`, or passed in URL query parameters.
- Dev Hub loads credentials directly in-memory from `cwallet.sso` / `mkstore` or Podman secrets at compilation time and embeds them into `LOCAL_PASSWORDS` for 1-click clipboard helpers (`copyUsername`, `handleCopyPassword`, `copyAndScrollToWallet`).

### 3.3 Multi-Language Symmetry (Rule 9)
All user-facing UI labels, buttons, tooltips, and descriptions must exist in all 6 Nordic-Baltic languages:
`🇬🇧 EN (English - Canonical)`, `🇪🇪 ET (Estonian)`, `🇫🇮 FI (Finnish)`, `🇸🇪 SV (Swedish)`, `🇱🇻 LV (Latvian)`, `🇱🇹 LT (Lithuanian)`.
Every key added to `i18n.json` must be present in all 6 language blocks.

### 3.4 Mermaid v10 DOM ID Isolation & Multi-Line Diamonds (Rule 10)
- In `app.js`, always render Mermaid diagrams using async `await mermaid.render(svgId, diagCode)` with a randomized unique ID (`bp-modal-svg-${bNum}-${Math.floor(Math.random()*100000)}`). Never use static DOM IDs which cause Mermaid v10 cache collisions.
- Mermaid decision diamonds (`{...}`) must always be broken into 2–4 concise lines using HTML `<br/>` tags.

### 3.5 Unified Toggle Engine (`toggleModuleBridge`)
Card action buttons (`▶️ Start Service`, `⏹️ Stop Service`) and stack switch buttons (`⚡ Lülitu sellele stäkile`) MUST route through `toggleModuleBridge(modKey, action)`:
- Enforces **Core Base Protection** (prohibits stopping `db-proxy` or `app-ords` via web).
- Calls Bridge API `POST /api/toggle?module=...&action=...` when online.
- Fallback: Automatically copies CLI command (e.g. `./scripts/start-containers.sh ...`) to the clipboard with toast feedback if the bridge is offline or browser blocks HTTP under HTTPS.
- Automatically triggers delayed `checkServiceHealth()` to refresh status pills.

### 3.6 Mandatory Asynchronous Long-Running Task Contract (Rule 12)
- Any setup, deployment, rebuild, or deep reset taking > 10s MUST be executed as an asynchronous background task (`ACTIVE_TASKS` in `dev-hub-bridge.py` via `subprocess.Popen`).
- Synchronous blocking `fetch` requests with short browser-side timeouts (e.g. 300s AbortController) on setup operations are **strictly prohibited**. Cold setup operations take 4–7 minutes; synchronous fetch calls will reliably abort with `signal is aborted without reason` even while the server process succeeds.
- Frontend MUST dispatch the task, receive immediate `{ status: "ok", task: ... }`, and poll `/api/task/status?task=...` while streaming live logs until `state: "completed"` or `state: "failed"`.

### 3.7 Delayed Active Blueprint & Verified State Contract (Rule 12)
- A blueprint MUST NOT be marked `🟢 Online / Aktiivne` or written to `.active_blueprint` when containers are merely starting or initializing.
- Cards must reflect real state: `⏳ Paigaldamisel...` (while setup is active), `🟡 Käivitumas...` (while container healthcheck is starting), and `🟢 Aktiivne` ONLY after database initialization, SEPS Wallet credentials, and URL endpoints are 100% verified.

---

## 4. Prohibited Anti-Patterns

- ❌ **No Python f-string Escaping:** Do not embed raw CSS or JavaScript inside Python f-strings where `{` and `}` have to be doubled (`{{` and `}}`).
- ❌ **No Hardcoded Ports or Passwords:** Never hardcode port numbers (`1521`, `8448`), usernames, or passwords. Dynamically resolve all ports from YAML profiles and `.env`.
- ❌ **No Dead Code Accumulation:** When removing UI sections, prune unused CSS classes and unused i18n dictionary keys across all 6 languages.
- ❌ **No Third-Party Python Dependencies:** Use only Python 3 standard library (`os`, `sys`, `json`, `re`, `pathlib`, `glob`, `datetime`, `subprocess`) plus `yaml` (PyYAML). Do not introduce Jinja2 or external build tools.
