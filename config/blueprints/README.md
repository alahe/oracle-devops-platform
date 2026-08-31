[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](../../docs/sv/README.md) | [ 🇱🇻 Latviešu ](../../docs/lv/README.md) | [ 🇱🇹 Lietuvių ](../../docs/lt/README.md)

# 🏗️ Architecture Blueprints (Environment Models)

This directory serves as the **central and canonical single source of truth for all 23 supported architecture blueprints**.

Each blueprint (`.env.<N>-*`) defines a complete infrastructure configuration ranging from a single development database to an 8-container isolated enterprise cloud lab.

---

## 🚀 Quickstart CLI Commands

### 1. Production & Day-to-Day Development (Safe / Idempotent / Data-Preserving):
Activate exactly one official blueprint:
```bash
# Activate Blueprint 3 (DEFAULT 2-layer production stack):
./scripts/setup-all.sh -b 3

# Or with long parameter:
./scripts/setup-all.sh --blueprint 30

# List all available blueprints in formatted ASCII table:
./scripts/setup-all.sh -lb

# Inspect detailed configuration of a specific blueprint:
./scripts/setup-all.sh -sb 30

# Search blueprints by keyword:
./scripts/setup-all.sh --search publisher

# Simulate execution without running (Dry-Run):
./scripts/setup-all.sh -b 34 --dry-run
```

### 2. Automated Testing & CI/CD Benchmarking (Clean Slate with reset-all -y):
Run automated tests and capture performance telemetry:
```bash
# Test a single blueprint from scratch:
./scripts/setup-all.sh -tb 30

# Test a custom sequence of blueprints:
./scripts/setup-all.sh -tb 30,34,41

# Test ALL blueprints sequentially:
./scripts/setup-all.sh -tb all

# List all generated test benchmark reports:
./scripts/setup-all.sh -ltr
```

### 3. Comprehensive Deep Regression & Real Matrix Testing (Cold + Warm + E2E Login):
Execute 2-pass matrix verification (Pass 1: Cold scratch setup + Pass 2: Warm restart recovery & E2E authentication):
```bash
# Run 2-pass deep testing for specific blueprints:
./scripts/internal/run_blueprint_matrix_test.sh 7 10 11 31

# Run 2-pass deep testing across the entire platform (Blueprints 3–43):
./scripts/internal/run_blueprint_matrix_test.sh

# Results saved to: metrics/matrix_test_report_<TIMESTAMP>.json
```

---

## 📊 Canonical Decade Architecture Matrix

### 🔹 Series 1–9: Core APEX & Database Architectures
| No | File Name | Active Containers | Ports | Purpose & Description |
| :--- | :--- | :--- | :--- | :--- |
| **1** | `.env.1-only-db-alise` | `db-alise` | `1533` | **ALISE DB Only:** Minimal local development database without ORDS or web portals. |
| **2** | `.env.2-db-alise-with-apex-ords` | `db-alise`, `app-ords` | `1533`, `8088`, `8448` | **All-in-One Monolith:** ALISE database with co-located APEX 26.1 and ORDS web gateway. |
| **3** | `.env.3-db-alise-apex-ords-with-proxy` | `db-proxy`, `db-alise`, `app-ords` | `1532`, `1533`, `8088`, `8448` | **🌟 DEFAULT PRODUCTION STACK:** 2-layer secure network topology (isolated Proxy DB and ALISE DB). |
| **4** | `.env.4-only-ords` | `app-ords` | `8088`, `8448` | **Standalone ORDS Gateway:** Centralized web gateway serving remote or cloud databases. |
| **5** | `.env.5-ords-with-apex` | `db-proxy`, `app-ords` | `1532`, `8088`, `8448` | **Proxy Web Server:** Proxy database co-located with APEX and ORDS. |
| **6** | `.env.6-gvenzl-dev-light` | `db-alise` | `1533` | **Gerald Venzl Dev Light:** Lightweight Gerald Venzl image for fast CI/CD testing. |
| **7** | `.env.7-hybrid-multi-vendor-db` | `db-proxy`, `db-alise`, `app-ords` | `1532`, `1533`, `8088`, `8448` | **Hybrid Cluster:** Official Oracle 23ai image (Proxy) and Gerald Venzl image (ALISE) co-existing. |

---

### 🔹 Series 10–19: Analytics Publisher Architectures (Pixel-Perfect Reporting)
| No | File Name | Active Containers | Ports | Purpose & Description |
| :--- | :--- | :--- | :--- | :--- |
| **10** | `.env.10-publisher-dedicated-db` | `db-publisher`, `app-publisher` | `1531`, `9502` | **Dedicated Publisher DB:** Analytics Publisher with dedicated RCU metadata database. |
| **11** | `.env.11-publisher-full-enterprise` | `db-publisher`, `db-alise`, `db-proxy`, `app-ords`, `app-publisher` | `1531-1533`, `8088`, `9502` | **Fully Isolated Publisher Stack:** All 3 databases, ORDS, and Publisher co-located. |
| **12** | `.env.12-publisher-minimal-hybrid` | `db-proxy`, `db-alise`, `app-ords`, `app-publisher` | `1531`, `1532`, `8088`, `9502` | **Minimal Publisher Hybrid:** Combined Publisher/Proxy DB + ALISE DB + ORDS + Publisher. |
| **13** | `.env.13-publisher-all-in-one-db` | `db-proxy`, `app-ords`, `app-publisher` | `1532`, `8088`, `9502` | **All-in-One Publisher DB:** All RCU and business schemas inside one Free DB (`db-proxy`). |

---

### 🔹 Series 20–29: Oracle Forms 14c Architectures (Forms Services & Modernization)
| No | File Name | Active Containers | Ports | Purpose & Description |
| :--- | :--- | :--- | :--- | :--- |
| **20** | `.env.20-forms-dedicated-db` | `db-forms`, `app-forms` | `1534`, `9001`, `7001`, `6082` | **Forms 14c & Dedicated DB:** Oracle Forms 14c runtime and WebLogic with dedicated RCU database. |
| **21** | `.env.21-forms-full-enterprise` | `db-forms`, `db-alise`, `db-proxy`, `app-forms`, `app-ords` | `1531-1534`, `8088`, `9001` | **Full Enterprise Forms Stack:** Forms + Forms RCU DB + Custom DB + APEX Proxy DB + ORDS. |
| **22** | `.env.22-forms-minimal-hybrid` | `db-proxy`, `db-alise`, `app-forms`, `app-ords` | `1531`, `1532`, `8088`, `9001` | **Minimal Forms Hybrid:** Combined Forms/Proxy DB + ALISE DB + ORDS + Forms Services. |
| **23** | `.env.23-forms-with-embedded-ords` | `db-proxy`, `app-forms` | `1532`, `8088`, `9001`, `7001`, `6082` | **Forms + Embedded ORDS Jetty:** All-in-one app server (Forms 9001 + ORDS 8088) + DB. |

---

### 🔹 Series 30–39: Zero-Install Developer Workstations & Cloud Labs (Web IDE)
| No | File Name | Active Containers | Ports | Purpose & Description |
| :--- | :--- | :--- | :--- | :--- |
| **30** | `.env.30-dev-workstation-with-web-ide` | `db-alise`, `app-ords`, `web-ide-dev` | `1533`, `8088`, `8090` | **Zero-Install Dev Workstation:** Browser-based VS Code Web IDE (Oracle SQL Dev + Antigravity AI + GitHub Actions) + ALISE DB + ORDS. |
| **31** | `.env.31-cloud-adb-with-web-ide` | `db-proxy`, `app-ords`, `web-ide-dev` | `1532`, `8088`, `8090` | **Cloud ADB Emulator + Web IDE:** Autonomous Database emulator with browser VS Code Web IDE & tools. |
| **32** | `.env.32-publisher-gvenzl-with-web-ide` | `db-publisher`, `app-publisher`, `web-ide-dev` | `1531`, `9502`, `8090` | **Publisher Dev Lab + Web IDE:** Pixel-Perfect reporting on lightweight DB with Web IDE. |
| **33** | `.env.33-full-enterprise-sandbox-web-ide` | 3 DBs, `app-ords`, `app-publisher`, `web-ide-dev` | All ports | **Full Enterprise Cloud Lab:** All databases and services with browser Web IDE & SEPS Wallet. |
| **34** | `.env.34-proxy-alise-apex-ords-with-web-ide` | `db-proxy`, `db-alise`, `app-ords`, `web-ide-dev` | `1532`, `1533`, `8088`, `8090` | **2-Layer Enterprise Stack + Web IDE:** Recommended 2-layer production stack (Proxy + ALISE) with browser VS Code Web IDE. |

---

### 🔹 Series 40–49: Ultimate Enterprise All-in-One (Forms + Publisher + APEX + ORDS)
| No | File Name | Active Containers | Ports | Purpose & Description |
| :--- | :--- | :--- | :--- | :--- |
| **40** | `.env.40-ultimate-all-in-one-enterprise` | `db-proxy`, `app-forms`, `app-publisher`, `app-ords` | `1532`, `8088`, `9502`, `9001` | **🌟 Ultimate Enterprise All-in-One:** Forms 14c + Analytics Publisher + APEX 26.1 + ORDS on single DB. |
| **41** | `.env.41-ultimate-all-in-one-enterprise-with-web-ide` | `db-proxy`, `app-forms`, `app-publisher`, `app-ords`, `web-ide-dev` | `1532`, `8088`, `9502`, `9001`, `8090` | **Ultimate Enterprise All-in-One + Web IDE:** Forms 14c + Publisher + APEX + ORDS + Web IDE on single DB (`db-proxy`). |
| **42** | `.env.42-ultimate-full-enterprise-isolated-with-web-ide` | `db-forms`, `db-publisher`, `db-proxy`, `db-alise`, `app-forms`, `app-publisher`, `app-ords`, `web-ide-dev` | All ports | **Fully Isolated Enterprise Cloud Lab + Web IDE:** Forms and Publisher in **isolated containers on dedicated databases** with Web IDE. |
| **43** | `.env.43-proxy-ords-apex-with-shared-forms-publisher-db-web-ide` | `db-proxy`, `db-publisher`, `app-forms`, `app-publisher`, `app-ords`, `web-ide-dev` | `1531`, `1532`, `8088`, `9502`, `9001`, `8090` | **2-Database Hybrid Enterprise + Web IDE:** APEX/ORDS Proxy DB (`db-proxy`) + Shared Middleware Infra DB (`db-publisher`) for Forms 14c & Publisher RCU schemas. |
