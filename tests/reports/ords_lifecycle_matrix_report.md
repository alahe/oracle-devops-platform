# 📊 ORDS Lifecycle & Decoupled Architecture Test Matrix Report

**Date:** 2026-09-04 06:28:06 UTC  
**Host OS:** Darwin (arm64)  
**Podman:** podman version 6.0.2  
**Result Summary:** 8 Passed / 0 Failed  

---

## 🧪 Execution Results Matrix

| Scenario | Step | Duration | Status | Details |
| :--- | :--- | :---: | :---: | :--- |
| **Scenario A** | Clean Slate Reset | `14s` | **✅ PASSED** | Workspace and containers cleaned |
| **Scenario A** | BP 0 Deploy (db-proxy + central ords) | `4m 46s` | **✅ PASSED** | Containers active, Root HTTP 302, SQL Developer HTTP 200 |
| **Scenario A** | BP 1 Add (db-alise + pool auto-register) | `4m 26s` | **✅ PASSED** | db-alise active, central ORDS pool: /etc/ords/config/databases/default/pool.xml |
| **Scenario A** | ADB Profile Checks (install_in_db: false) | `0s` | **✅ PASSED** | Cloud ORDS preserved, version match enabled |
| **Scenario B** | Clean Slate Reset | `16s` | **✅ PASSED** | Workspace and containers cleaned |
| **Scenario B** | BP 1 Deploy without ORDS | `3m 56s` | **✅ PASSED** | db-alise active, app-ords container absent (0 MB web RAM) |
| **Scenario B** | check-urls.sh Guidance UX | `1s` | **✅ PASSED** | Clear status and actionable hint displayed |
| **Scenario B** | check-urls.sh Estonian i18n | `1s` | **✅ PASSED** | Estonian guidance and actionable hint verified |

---

## 🔍 Architecture Invariants Verified

1. **Decoupled ORDS Lifecycle:** `ords.enabled: true` in database YAML sets up internal schemas without spawning `app-ords`. The web container is only spun up when `ORDS_PROFILE` is declared.
2. **Permanent Central ORDS Gateway (`env0`):** Newly launched database instances automatically register their pool in the central gateway without rebuilding containers.
3. **Cloud Autonomous Database (ADB):** `install_in_db: false` protects cloud ORDS schemas from being overwritten, and `verify_version_match: true` guarantees version compatibility.
4. **Guidance UX When No ORDS Server:** When ORDS is omitted, CLI diagnostics output standardized guidance with `./scripts/setup-all.sh --b 0` instructions in all supported languages.
