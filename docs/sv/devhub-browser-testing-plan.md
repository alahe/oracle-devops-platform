<!-- [ 🇬🇧 English ](../devhub-browser-testing-plan.md) | [ 🇪🇪 Eesti ](../et/devhub-browser-testing-plan.md) | [ 🇸🇪 Svenska ](devhub-browser-testing-plan.md) -->

# 🧪 Dev-Hub webbläsarbaserad blueprints E2E-testning och livscykelguide

Denna guide beskriver den fullständiga testprocessen för att starta, hantera och validera arkitekturmodeller direkt via **Developer Hubs gränssnitt** (`https://localhost:8448/dev-hub` eller `http://localhost:8088/dev-hub`) och dess Bridge API.

---

## 🎯 Arkitektur och mål

1. **Webbläsarstyrd blueprintshantering:**
   - Hantera alla 12 arkitekturmodeller (#0 till #11) via Dev Hub Web UI eller Dev Hub Bridge REST API (`http://localhost:8089/api/toggle`).
2. **Verifiering av tjänste-URL:er:**
   - Verifierar anslutning (HTTP 200/301/302) till alla aktiva tjänste-slutpunkter: APEX Workspace, APEX Admin, Database Actions, Analytics Publisher, Forms 14c och Web IDE.
3. **Minnesbaserad lösenordshämtning och inloggningssimulering:**
   - Följer strikt **Regel 5 (Zero-Trust SEPS Wallet)**.
   - Lösenord hämtas direkt till minnet och matas in i webbformulär utan disksparning.
4. **RAM Watchdog och avaktivering av äldre behållare:**
   - Övervakar tillgängligt RAM-minne (tröskel: 2500 MB).
   - **Kärnbasens skydd:** Blueprint #0 (`db-proxy` port 1532 och `app-ords` port 8088/8448) **STOPPAS ALDRIG**.

---

## 🚀 Köra testpaketet

### 1. Körning via terminalen (CLI)

```bash
# Testa alla 12 blueprints i följd:
./tests/test-devhub-browser-blueprints.sh --all

# Testa fullständig 3-stegs livscykel (Start -> Stop -> Snabbstart) via Dev-Hub:
./tests/test-devhub-browser-blueprints.sh --all --lifecycle --dry-run
./tests/test-devhub-browser-blueprints.sh -b 1 --lifecycle

# Dedikerad testsvit för Dev-Hub full livscykel (blueprints 0-9):
./tests/test-devhub-lifecycle-full.sh --all --dry-run
./tests/test-devhub-lifecycle-full.sh -b 1
./tests/test-devhub-lifecycle-full.sh -b 0,1,8 --dry-run

# Testa en enskild blueprint:
./tests/test-devhub-browser-blueprints.sh -b 0
./tests/test-devhub-browser-blueprints.sh -b 9

# Dry-run simulering:
./tests/test-devhub-browser-blueprints.sh --dry-run
```

### 2. 1-klickskörning via Developer Hub Web UI

1. Öppna Dev Hub: **`https://localhost:8448/dev-hub`**
2. Navigera till fliken **"DevOps Console"** eller **"Testing Hub"** (Flik 5.5).
3. Klicka på **"Test DevHub Blueprints"** eller **"Dev-Hub blueprints 0-9 livscykeltest"**.
4. Följ realtidsutskriften direkt i webbläsaren!

---

## 📊 Rapporter och resultat

- **Webbläsarblueprints rapport:** `tests/reports/devhub_browser_blueprints_test_report.md`
- **Webbläsarblueprints mätvärden (JSON):** `metrics/devhub_browser_blueprints_benchmarks.json`
- **Full livscykelrapport (blueprints 0-9):** `tests/reports/devhub_lifecycle_full_report.md`
- **Full livscykel mätvärden (JSON):** `metrics/devhub_lifecycle_full_benchmarks.json`
- **Fullständig loggfil:** `install_logs/devhub_lifecycle_full_YYYYMMDD_HHMMSS.log`
