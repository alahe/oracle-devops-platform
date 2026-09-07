<!-- [ 🇬🇧 English ](devhub-browser-testing-plan.md) | [ 🇪🇪 Eesti ](et/devhub-browser-testing-plan.md) -->

# 🧪 Dev-Hub Browser Blueprints E2E Testing & Lifecycle Guide

This guide details the complete end-to-end testing workflow for launching, managing, and validating architecture blueprints directly through the **Developer Hub browser interface** (`https://localhost:8448/dev-hub` or `http://localhost:8088/dev-hub`).

---

## 🎯 Architecture & Objectives

1. **Browser-Driven Blueprint Management:**
   - Control all 12 architecture blueprints (#0 through #11) through the Dev Hub Web UI or the Dev Hub Bridge REST API (`http://localhost:8089/api/toggle`).
2. **Service URL Verification:**
   - Probes and validates web connectivity (HTTP 200/301/302) across all active service endpoints:
     - APEX Workspace (`/ords/<pool>/r/apex/workspace-sign-in/oracle-apex-sign-in`)
     - APEX Instance Administration (`/ords/<pool>/apex_admin`)
     - Database Actions / SQL Developer Web (`/ords/<pool>/user_developer/sign-in?r=_sdw`)
     - Analytics Publisher (`http://localhost:9502/xmlpserver`)
     - Forms 14c Runtime (`http://localhost:9001/forms/frmservlet?form=test.fmx`)
     - Forms Web GUI (`http://localhost:6082/vnc.html`)
     - VS Code Web IDE (`http://localhost:8090/?folder=/workspace`)
     - Template Designer Studio (`http://localhost:6083/`)
3. **In-Memory Credential Fetch & Web Form Login Simulation:**
   - Adheres strictly to **Rule 5 (Zero-Trust SEPS Wallet)**.
   - Credentials are never written to disk or sent as plain URL parameters.
   - Credentials are read directly into memory (`./scripts/get-password.sh <ALIAS> -p`) and submitted directly into web form authentication fields, precisely simulating a developer using the Dev Hub 1-click clipboard button and pasting (`Cmd+V`) into the browser password field.
4. **RAM Watchdog & Older Container Deactivation:**
   - Monitors available RAM (Podman VM and host) with a configurable safety buffer (default: 2500 MB).
   - If free RAM drops below the threshold when switching between heavy database/WebLogic stacks:
     - **Core Base Invariant:** Blueprint #0 (`db-proxy` port 1532 and `app-ords` port 8088/8448) is **NEVER STOPPED**. The Developer Hub and ORDS gateway remain permanently accessible.
     - Automatically stops older dynamic containers (`db-alise`, `db-publisher`, `app-forms`, `web-ide-dev`, `app-publisher-designer`).
     - **Seamless Auto-Resume:** Immediately resumes testing the target blueprint where it left off without restarting from scratch.

---

## 🚀 Running the Test Suite

### 1. Interactive or Automated Execution via CLI

```bash
# Test all 12 blueprints sequentially:
./tests/test-devhub-browser-blueprints.sh --all

# Test a single blueprint (e.g. Blueprint #0 Core Base or Blueprint #9 Designer):
./tests/test-devhub-browser-blueprints.sh -b 0
./tests/test-devhub-browser-blueprints.sh -b 9

# Dry-run validation (checks blueprints, URL mappings, and SEPS Wallet aliases without starting containers):
./tests/test-devhub-browser-blueprints.sh --dry-run

# Custom RAM threshold (e.g. 3000 MB):
./tests/test-devhub-browser-blueprints.sh --all --min-ram 3000
```

### 2. 1-Click Execution via Developer Hub Web UI

1. Open Dev Hub: **`https://localhost:8448/dev-hub`**
2. Navigate to the **"DevOps Console"** tab.
3. Select or click **"Test DevHub Blueprints"** (`test-devhub-blueprints`).
4. View real-time terminal output directly in the web console!

---

## 📊 Artifacts & Reports

Execution results are automatically persisted to version-controlled directories:
- **Test Report (Markdown):** `tests/reports/devhub_browser_blueprints_test_report.md`
- **Benchmarks (JSON):** `metrics/devhub_browser_blueprints_benchmarks.json`
- **Complete Execution Logs:** `install_logs/devhub_browser_blueprints_YYYYMMDD_HHMMSS.log`
