<!-- [ 🇬🇧 English ](../devhub-browser-testing-plan.md) | [ 🇪🇪 Eesti ](../et/devhub-browser-testing-plan.md) | [ 🇱🇻 Latviešu ](devhub-browser-testing-plan.md) -->

# 🧪 Dev-Hub pārlūkprogrammas plānu E2E testēšanas un dzīvescikla rokasgrāmata

Šī rokasgrāmata apraksta pilnu gala-līdz-galam testēšanas darbplūsmu arhitektūras plānu palaišanai, pārvaldībai un validācijai tieši caur **Developer Hub pārlūkprogrammas saskarni** (`https://localhost:8448/dev-hub` vai `http://localhost:8088/dev-hub`) un tā Bridge API.

---

## 🎯 Arhitektūra un mērķi

1. **Pārlūkprogrammas vadīta plānu pārvaldība:**
   - Pārvaldiet visus 12 arhitektūras plānus (#0 līdz #11) caur Dev Hub Web UI vai Dev Hub Bridge REST API (`http://localhost:8089/api/toggle`).
2. **Pakalpojumu URL pārbaude:**
   - Pārbauda tīkla savienojamību (HTTP 200/301/302) visiem aktīvajiem pakalpojumiem: APEX Workspace, APEX Admin, Database Actions, Analytics Publisher, Forms 14c un Web IDE.
3. **Akreditācijas datu nolasīšana atmiņā un pieteikšanās simulācija:**
   - Stingri ievēro **5. noteikumu (Zero-Trust SEPS Wallet)**.
   - Paroles tiek nolasītas tieši atmiņā un ievadītas tīmekļa formās bez glabāšanas diskā.
4. **RAM uzraudzība un vecāku konteineru apturēšana:**
   - Uzrauga pieejamo operatīvo atmiņu (slieksnis: 2500 MB).
   - **Bāzes kodola aizsardzība:** Plāns #0 (`db-proxy` ports 1532 un `app-ords` ports 8088/8448) **NEKAD NETIEK APTURĒTS**.

---

## 🚀 Testa pakotnes izpilde

### 1. Izpilde no termināļa (CLI)

```bash
# Testēt visus 12 plānus secīgi:
./tests/test-devhub-browser-blueprints.sh --all

# Testēt pilnu 3 soļu dzīvesciklu (Start -> Stop -> Fast-Start) caur Dev-Hub:
./tests/test-devhub-browser-blueprints.sh --all --lifecycle --dry-run
./tests/test-devhub-browser-blueprints.sh -b 1 --lifecycle

# Dedicēts Dev-Hub pilna dzīvescikla (plāni 0-9) testa modulis:
./tests/test-devhub-lifecycle-full.sh --all --dry-run
./tests/test-devhub-lifecycle-full.sh -b 1
./tests/test-devhub-lifecycle-full.sh -b 0,1,8 --dry-run

# Testēt vienu plānu:
./tests/test-devhub-browser-blueprints.sh -b 0
./tests/test-devhub-browser-blueprints.sh -b 9

# Dry-run simulācija:
./tests/test-devhub-browser-blueprints.sh --dry-run
```

### 2. 1 klikšķa palaišana no Dev Hub saskarnes

1. Atveriet Dev Hub: **`https://localhost:8448/dev-hub`**
2. Pārejiet uz cilni **"DevOps Console"** vai **"Testing Hub"** (Cilne 5.5).
3. Noklikšķiniet uz **"Test DevHub Blueprints"** vai **"Dev-Hub plānu 0-9 dzīvescikla tests"**.
4. Sekojiet līdzi reāllaika termināļa izvadei pārlūkprogrammā!

---

## 📊 Atskaites un rezultāti

- **Pārlūkprogrammas plānu ziņojums:** `tests/reports/devhub_browser_blueprints_test_report.md`
- **Pārlūkprogrammas plānu metrika (JSON):** `metrics/devhub_browser_blueprints_benchmarks.json`
- **Pilna dzīvescikla ziņojums (plāni 0-9):** `tests/reports/devhub_lifecycle_full_report.md`
- **Pilna dzīvescikla metrika (JSON):** `metrics/devhub_lifecycle_full_benchmarks.json`
- **Pilns žurnālformats:** `install_logs/devhub_lifecycle_full_YYYYMMDD_HHMMSS.log`
