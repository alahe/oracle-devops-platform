# 📊 3-Tiered Container Lifecycle Matrix Report

**Date:** 2026-09-03 06:06:39 UTC  
**Host OS:** Darwin (arm64)  
**Podman:** podman version 6.0.2  

---

## ⏱️ Timing & Functionality Comparison Matrix

| Blueprint | Tier 1: Külm (-tb) | Tier 2: Soe (-b) | Tier 3: Taastus (~15s) | Kiiruse Võit | HTTP GET | DB / Wallet | Web-IDE Laiendused | Snapshot |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **BP 4** | `2m 45s` | `11m 25s` | `7m 31s` | **0.4x** | ✅ PASS (HTTP 200/302) | ✅ PASS (SEPS Wallet) | ⚠️ Missing: anti py sqldev  | ✅ Created (bp_4_20260902_055807.tar.gz) |

---

### 🔍 Etappide Definitsioonid:
1. **Tier 1 (Külm Käivitus / Ehitusrežiim `-tb`):** Puhas nullist paigaldus. Genereerib ja kompileerib andmebaasi, APEX-i ja ORDS-i ning salvestab lõpus värske Golden Snapshoti.
2. **Tier 2 (Soe Käivitus / Vahemälu `-b`):** Taaskasutab olemasolevaid konteinereid ja mahte ilma uuesti kompileerimata (*Fastpath*).
3. **Tier 3 (Kiirtaastus `restore-golden-snapshots.sh`):** Taastab andmebaasi ja teenused tihendatud arhiivist koos automaatse SEPS paroolirotatsiooniga.

### 💻 Web-IDE Laienduste Nõuded:
- `google.google-antigravity` (Google Antigravity AI Assistant)
- `ms-python.python` (Microsoft Python Suite)
- `oracle.sql-developer` (Oracle SQL Developer for VS Code)
