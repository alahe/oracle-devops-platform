# 🧪 Master Blueprint Live Testing Summary Report

- **Date:** 2026-09-14 04:09:00
- **Total Tested:** 12
- **Passed:** 11 (✅)
- **Failed:** 0 (❌)
- **Skipped:** 1 (⏭️)
- **Total Duration:** 4700s (~1h 18m)
- **Fast Mode:** Yes (Golden Snapshots where available)
- **Dry Run:** No (Full Live Deployments & Health Assertions)

---

## 📊 Comprehensive Blueprint Live Lifecycle Results Table

| BP # | Blueprint Name | Expected Containers | Duration | Status | Details / Verification Results |
| :---: | :--- | :--- | :---: | :---: | :--- |
| **0** | `0-default-proxy-ords` | `db-proxy app-ords` | 280s | ✅ PASS | Core Base baseline healthy, 7 SEPS aliases connected, 9 endpoints OK |
| **1** | `1-standalone-alise-db` | `db-alise app-ords` | 727s | ✅ PASS | Port 1533 listener healthy, SEPS wallet connected, SQLcl PDB query OK |
| **2** | `2-standalone-proxy-db` | `db-proxy-standalone app-ords` | 707s | ✅ PASS | Port 1537 listener healthy, ORDS pool verified, SEPS wallet connected |
| **3** | `3-standalone-gvenzl-db` | `db-gvenzl app-ords` | 591s | ✅ PASS | Port 1535 FastStart container healthy, SEPS wallet connected |
| **4** | `4-standalone-autonomous-db` | `db-adb app-ords` | 211s | ✅ PASS | Port 1536 ATP cloud emulation healthy, mTLS wallet verified |
| **5** | `5-standalone-publisher` | `db-publisher app-publisher` | 759s | ✅ PASS | Port 1531 + 9502 healthy, OAS RCU credentials synchronized |
| **6** | `6-standalone-forms` | `db-forms app-forms` | 256s | ✅ PASS | Port 1534 + 9001 + 6082 healthy, Forms Runtime & noVNC verified |
| **7** | `7-consolidated-forms-publisher` | `db-forms-publisher app-forms app-publisher` | 799s | ✅ PASS | Port 1538 + 9005 + 9505 healthy, unified WebLogic domain operational |
| **8** | `8-standalone-web-ide` | `web-ide-dev` | 213s | ✅ PASS | Port 8090 verified (HTTP 200), 0-DB invariant preserved |
| **9** | `9-standalone-publisher-designer` | `app-publisher-designer` | 79s | ✅ PASS | Port 6083 verified (HTTP 200), 0-DB invariant preserved |
| **10** | `10-remote-ords` | `app-ords-remote` | 78s | ✅ PASS | Ports 8088/8448 verified, edge ORDS gateway operational, 0-DB invariant |
| **11** | `11-remote-publisher` | `app-publisher-remote` | 0s | ⏭️ SKIP | External remote database required (excluded per docs/incremental-blueprints-test-plan.md) |
