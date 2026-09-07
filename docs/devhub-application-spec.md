# Application Specification: Oracle APEX Dev Hub

## 1. Application Identity
- **App ID:** 101
- **App Name:** Oracle DevOps Platform Developer Hub
- **Alias:** DEVHUB
- **Theme:** Universal Theme (Theme 42 - Vita Dark / Redwood Dark)
- **Parsing Schema:** DEVHUB
- **Workspace:** PROXY_WORKSPACE
- **Target DB:** db-proxy (Port 1532, FREEPDB1)
- **Session Management:** Max Idle = 86400s (24h), Max Length = 604800s (7d), Deep Linking = Enabled

## 2. Architecture & Components
- **Backend Package:** `DEVHUB.DEV_HUB_PKG`
- **Zero-Trust Security:** SEPS Wallet (`cwallet.sso`), 0 plaintext passwords in DB or UI.
- **REST Markdown Engine:** Markdown fetched dynamically in real-time from `http://host.containers.internal:8089/api/doc` and converted server-side via `APEX_MARKDOWN.TO_HTML`.
- **Hybrid Visualization:** Native APEX Tree Region (`CONNECT BY PRIOR`) + Interactive Mermaid.js diagram.

## 3. Page Inventory
1. **Page 1 (Services & Status):** Cards Region from `DEVHUB_SERVICES` cache, 0 ms page-load latency, on-demand refresh.
2. **Page 2 (Architecture & Topology):** Sakk 1: Native APEX Tree & Detail Cards; Sakk 2: Mermaid.js visual flowchart.
3. **Page 3 (Blueprints Explorer):** Faceted Search with categories, profile tags, dynamic runtime status (`🟢 RUNNING`, `🟡 PARTIAL`, `⚪ STOPPED`), live container chips with profile-defined ports, and drawer with YAML compose. Deep linking `P3_BLUEPRINT_ID` Unrestricted.
4. **Page 4 (Documentation Reader):** Tree TOC, language selector (EN, ET, FI, SV, LV, LT), server-side REST Markdown Dynamic Content. Deep linking `P4_DOC_ID`, `P4_LANG` Unrestricted.
5. **Page 5 (DevOps Commands):** Cards with CLI commands, visual 1.5s copy feedback ("✓ Kopeeritud!"), and SEPS Wallet `./scripts/get-password.sh <ALIAS>` helpers.
6. **Page 6 (Logs & Benchmarks):** Interactive Report of `DEVHUB_BENCHMARKS` with sync button.
7. **Page 9999 (Login):** Standard APEX Accounts login + conditional 1-click Dev Quick Login (active only in DEV environment).

## 4. Blueprint Runtime Lifecycle & Controller
- **Dynamic Modules Controller Bar:** Real-time on-demand toggling of dynamic building blocks (Web IDE :8090, Analytics Publisher :9502, Forms 14c :9001/:6082, Publisher Designer :6083) with sub-second status reflection via `/api/status`.
- **Core Base Protection:** Blueprint 0 (`db-proxy` + `app-ords`) serves as the immutable platform core hosting Dev Hub and central routing. Stopping is strictly prohibited in the UI (badge `🛡️ KAITSTUD TUUM` / `PROTECTED CORE`) and rejected by the Bridge API with `403 Forbidden`.
- **Runtime Status Classification:**
  - `🟢 RUNNING`: All containers declared in the blueprint are actively running in Podman.
  - `🟡 PARTIAL`: 1..N-1 containers are active (e.g. database instance is up, but web/middleware container is stopped).
  - `⚪ STOPPED`: 0 containers are running (0 MB RAM consumption).
  - `🌟 CURRENT ACTIVE`: Marks the blueprint currently recorded in `.active_blueprint`.
- **100% Dynamic Port Resolution (Rule 11):** All container host ports displayed in blueprint cards and modals are resolved dynamically from positive YAML profile definitions (`config/profiles/**/*.yaml`) without hardcoded port literals.

## 5. YAML Profile Manager & Custom Blueprint Builder
- **Profile Manager Modal (`#profile-modal`):** Direct in-browser viewing, inspection, and modification of all YAML profiles (`databases/`, `ords/`, `web-ide/`, `publisher/`, `forms/`, `forms-publisher/`). Includes instant conflict checking against busy ports and active containers. Edits persist directly to disk and trigger background Dev Hub synchronization.
- **Custom Blueprint Creator (`#create-bp-modal`):** Declarative creator for custom blueprints (`config/blueprints/.env.<num>-<slug>`) following positive profile reference semantics.

