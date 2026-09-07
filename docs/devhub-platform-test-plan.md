# 🧪 Dev Hub & Platform Modernization Test Plan

[ 🇬🇧 English ](devhub-platform-test-plan.md) | [ 🇪🇪 Eesti ](et/devhub-platform-test-plan.md) | [ 🇫🇮 Suomi ](fi/devhub-platform-test-plan.md) | [ 🇸🇪 Svenska ](sv/devhub-platform-test-plan.md) | [ 🇱🇻 Latviešu ](lv/devhub-platform-test-plan.md) | [ 🇱🇹 Lietuvių ](lt/devhub-platform-test-plan.md)

---

## 1. Overview & Objectives

This test plan establishes the verification strategy and standardized test cases for the Developer Hub (`docs/dev-hub.html`) and platform orchestration modernization.

### Primary Testing Objectives:
1. **Accurate & Autonomous Status Detection:** Ensure Dev Hub accurately identifies active blueprints (including multi-blueprint concurrent operations) and never misreports stopped stacks (e.g. BP #3 and BP #4) as active.
2. **Resource Monitor Reliability:** Verify that the top-bar RAM gauge (`X GB / 16 GB`) sums only memory limits from genuinely running containers.
3. **3-Tab Modal Dialog Functionality:** Verify seamless navigation between tabs (`Architecture`, `Users & Security`, `Executions & Operations`), interactive Mermaid topology diagrams, SEPS Wallet credentials, and live execution timer.
4. **Database Actions & APEX Launchpad:** Validate 5-endpoint launch buttons, JVM/ORDS warmup toast notification, and automatic password copying to clipboard.
5. **Zero-Trust Security & SEPS Wallet:** Confirm passwords are read strictly in-memory from encrypted stores and never exposed in plaintext DOM or disk caches.
6. **Managers & Filters:** Validate profile and blueprint managers, viewing, cloning, editing, and instant client-side filtering (`Active`, `Remote`, etc.).
7. **Multi-Language Synchronization (i18n):** Ensure 100% parity across all 6 supported languages (🇬🇧 EN, 🇪🇪 ET, 🇫🇮 FI, 🇸🇪 SV, 🇱🇻 LV, 🇱🇹 LT).

---

## 2. Testing Pyramid & Coverage Matrix

| Level | Area | Tools | Duration | Frequency |
| :--- | :--- | :--- | :--- | :--- |
| **Level 1** | Code & Compilation | Python 3, `test-dev-hub-generation.sh` | ~5–10s | Every code change |
| **Level 2** | Integration & Wallet | `check-urls.sh`, `check-wallet.sh` | ~10–20s | Post container start |
| **Level 3** | UI / Functional | Web Browser, DevTools, Clipboard API | ~3–5 min | Pre-release |
| **Level 4** | Lifecycle & Recovery | `setup-all.sh`, `restore-golden-snapshots.sh` | ~15–45s | Blueprint switching |

---

## 3. Detailed Test Cases

### Group A: Status Detection & Resource Monitoring

- **TC-STATUS-01: Single Blueprint Detection (BP #0)**
  - *Precondition:* Ran `./scripts/setup-all.sh --blueprint 0`.
  - *Expected:* BP #0 is green `Active`. BP #1, #2, #3, #4, #5 are grey `Stopped`. Header shows `(1 active)` and RAM reflects BP 0 limit (~3.0 GB).
- **TC-STATUS-02: BP #3 & BP #4 Isolation**
  - *Precondition:* BP #1 is running (`db-alise` and `app-ords` are up).
  - *Expected:* BP #1 is `Active` (`db-alise`). BP #3 (`db-gvenzl`) and BP #4 (`db-adb`) are `Stopped`. BP 3/4 memory is not added to RAM counter.
- **TC-STATUS-03: Multi-Blueprint Concurrent Execution**
  - *Precondition:* BP #0 is running, and BP #8 is also launched.
  - *Expected:* Both BP #0 and BP #8 show green `Active`. Header shows `(2 active)` and RAM is calculated as the sum of both active stacks. Active cards sort to the top.

### Group B: 3-Tab Modal Dialog & Operations Controller

- **TC-MODAL-01: Tab Navigation**
  - *Steps:* Click `📐 Architecture ↗` or `⚡ Operations ↗`. Switch between `📐 Architecture`, `🔑 Users`, `⚡ Executions & Operations`.
  - *Expected:* Instant tab switching without page reload; header dropdown enables quick-switching between blueprints.
- **TC-MODAL-02: Mermaid Topology & Architecture**
  - *Expected:* Interactive Mermaid SVG renders correctly, port and container metadata table shows accurate details.
- **TC-MODAL-03: Executions & Operations (Unified Action Cards & Live Console)**
  - *Steps:* On Tab 3, inspect the unified action cards grid (Deploy & Switch, Rapid Restore, Restart & Refresh, Deep Reset, Stop Services, Custom Snapshot). Click any action button (e.g. `⚡ Activate` or `⚡ Restore Golden Snapshot`).
  - *Expected:* Each card displays an icon, description, copyable shell command box, and execution button. The live progress console opens directly below the cards grid and smooth-scrolls into view with live timer (`⏱️ 00:01`...), while redundant bottom deployment command boxes are eliminated.

### Group C: Service Cards & Database Actions Launchpad

- **TC-LAUNCH-01: 5-Endpoint Action Buttons**
  - *Expected:* Database cards feature 5 action buttons: `🛠️ APEX Workspace (DEV)`, `⚙️ APEX Admin (ADMIN)`, `📊 DB Actions (DEV)`, `📊 DB Actions (DBA_ADMIN)`, `🌐 ORDS (<pool>)`.
- **TC-LAUNCH-02: DB Actions Warmup Toast & Clipboard**
  - *Steps:* Click `📊 DB Actions (DEV)`.
  - *Expected:* Toast displays explaining ~10–15s initial JVM warmup, developer password is copied to clipboard, proper URL opens in new tab.
- **TC-LAUNCH-03: APEX Workspace Password Copy**
  - *Steps:* Click `🛠️ APEX Workspace (DEV)`.
  - *Expected:* Password copies to clipboard with toast confirmation, APEX login page opens.

### Group D: Oracle SEPS Wallet Credential Matrix

- **TC-WALLET-01: Dynamic Account Aggregation**
  - *Expected:* Matrix includes all accounts from YAML profiles, distinguished by DB instance and listener port.
- **TC-WALLET-02: Multi-Action Buttons in Matrix**
  - *Expected:* Action buttons `[ 🔑 Password ]`, `[ 📋 Alias ]`, `[ 💻 SQLcl ]`, `[ 📊 DB Actions ]` execute smoothly and trigger toast feedback.
- **TC-WALLET-03: Zero-Trust Security Audit**
  - *Expected:* Passwords are never hardcoded into HTML source; decrypted strictly in-memory from wallet.

### Group E: Managers & Filters

- **TC-MGR-01: Profile Manager**
  - *Expected:* Left pane lists YAML profiles, right pane shows syntax-highlighted content, clone button works.
- **TC-MGR-02: Blueprint Manager**
  - *Expected:* Left pane lists blueprints, right pane shows configuration, new blueprint form validates positive profile references.
- **TC-MGR-03: Grid & Filter Bar**
  - *Expected:* Filters (`Active`, `Remote`, etc.) filter cards instantly, 3-column responsive layout applies on wide screens.

### Group F: Multi-Language Parity (i18n)

- **TC-I18N-01: 6-Language Dynamic Switcher**
  - *Expected:* Header flags instantly translate all cards, buttons, badges, and modals across EN, ET, FI, SV, LV, LT.

---

## 4. Automated Execution Commands

```bash
# 1. Dev Hub compilation & 6-language unit test suite
bash tests/unit/test-dev-hub-generation.sh

# 2. SEPS Wallet & connection diagnostics
./scripts/check-wallet.sh

# 3. Web endpoints & URL healthcheck
./scripts/check-urls.sh

# 4. Blueprint CLI parameters & profile integrity
bash tests/unit/test-cli-blueprint-params.sh

# 5. Golden Snapshot rapid restore regression test
bash tests/unit/test-script-restore-golden-snapshots.sh
```
