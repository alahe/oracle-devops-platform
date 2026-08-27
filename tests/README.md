# 🧪 Keskkonna Automaattestimise ja Blueprintide Juhend (Testing Suite)

Antud kaust koondab projekti kogu automaattestimise taristu: testiraportid, automaatsed mõõdikud ja ressursside auditid.

Kõik 13 ametlikku arhitektuurset kavandit (Blueprints) asuvad keskse tõeallikana kaustas **[`config/blueprints/`](../config/blueprints/)**.

---

## 📁 Kataloogi Struktuur

- **`config/blueprints/`** ➔ 13 ametlikku arhitektuurset blueprinti (`.env.1-*` kuni `.env.13-*`).
- **`tests/reports/`** ➔ Blueprintide koondmaatriks ([`scenario_benchmark_matrix.md`](reports/scenario_benchmark_matrix.md)).
- **`tests/reports/scenarios/`** ➔ Automaatselt genereeritud ja Git-is jälgitavad testiaruanded (`scenario_1_report.md` kuni `scenario_13_report.md`).

---

## 🚀 Käivitamine Käsuliinilt (Terminal)

Testide käivitamiseks puhtalt lehelt (automaatse `reset-all -y` ja verifitseerimisega):

```bash
# Automaatne ühe käsuga testimine (Üksik blueprint):
./scripts/setup-all.sh -tb 3

# Konkreetse nimekirja testimine (Koma eraldajaga):
./scripts/setup-all.sh -tb 1,5,8,10

# KÕIGI 13 blueprinti automaatne laus-testimine järjestikku:
./scripts/setup-all.sh -tb all
```

---

## 📊 Kõigi 13 Stsenaariumi Ülevaade

| Stsenaarium | Nimi | Käivitatavad Konteinerid | Peamine Eesmärk |
| :--- | :--- | :--- | :--- |
| **1** | `.env.1-only-db-lis` | `db-lis` | Ainult LIS Andmebaas ilma veebiteenusteta. |
| **2** | `.env.2-db-lis-with-apex-ords` | `db-lis`, `app-ords` | LIS Baas + APEX 26.2 + ORDS üheskoos. |
| **3** | `.env.3-db-lis-apex-ords-with-proxy` | `db-proxy`, `db-lis`, `app-ords` | 2-Kihiline andmebaasi arhitektuur (Proxy + LIS). |
| **4** | `.env.4-only-app-publisher` | `db-publisher` | Eraldiseisev Analytics Publisheri andmebaas. |
| **5** | `.env.5-only-ords` | `app-ords` | Lokaalne ORDS Gateway kaug-andmebaasiga. |
| **6** | `.env.6-ords-with-apex` | `db-proxy`, `app-ords` | Proxy andmebaas + APEX + ORDS gateway. |
| **7** | `.env.7-all-services-together` | `db-publisher`, `db-proxy`, `db-lis`, `app-ords`, `app-publisher` | Täielik 4-Kihiline Ettevõtte Tootmiskeskkond. |
| **8** | `.env.8-gvenzl-dev-light` | `db-lis-gvenzl` | Kergekaaluline Gerald Venzl DB CI/CD testideks. |
| **9** | `.env.9-dev-workstation-with-web-ide` | `db-lis`, `app-ords`, `web-ide-dev` | **Zero-Install Arendaja Töōkoht** (VS Code Brauseris). |
| **10** | `.env.10-hybrid-multi-vendor-db` | `db-proxy-oracle`, `db-lis-gvenzl`, `app-ords` | Mitme eri andmebaasi pildi (Oracle + Gvenzl) klaster. |
| **11** | `.env.11-cloud-adb-with-web-ide` | `db-proxy-adb`, `app-ords`, `web-ide-dev` | Pilve Autonomous DB emuleerimine + Web IDE. |
| **12** | `.env.12-publisher-gvenzl-with-web-ide` | `db-publisher-gvenzl`, `app-publisher`, `web-ide-dev` | Pixel-Perfect aruandlus kergel Gvenzl DB-l. |
| **13** | `.env.13-full-enterprise-sandbox-web-ide` | 3 DB-d, `app-ords`, `app-publisher`, `web-ide-dev` | **Täielik ettevõtte pilvelabor (5 konteinerit).** |

---

## 🔍 Kuidas Automaatne Testimine Töötama Peab?

Iga katse käivitamisel loetakse mälumaht, CPU kasutus, võrgupordid ning sooritatakse kaks kohustuslikku kontrolli:

1. **🌐 Veebiteenuste HTTP Health Audit (`scripts/check-urls.sh`):**
   Kontrollib reaalsete HTTP/HTTPS võrgupäringutega iga veebiteenuse vastust (HTTP 200/302).
2. **🔑 SEPS Paroolivaba Oracle Walleti Audit (`scripts/check-wallet.sh`):**
   Kontrollib paroolivabalt kõiki registreeritud TNS aliaseid (`/@ALIAS`) ilma ühegi paroolita.
3. **🔒 TLS ja Sertifikaatide Poliitika Testikomplekt (`tests/test-tls-scenarios.sh`):**
   Testib 5-astmelist TLS hierarhiat (`CUSTOM_CERT`, `PUBLIC_DNS`, `CORP_PKI`, `USER_LOCAL_CA`, `SELF_SIGNED`) ja Blueprinti rangusastmete kontrolli.
4. **🌐 Brauseri ja UI Automaatne E2E Sisselogimise Test (`tests/test-browser-login.sh`):**
   Teostab reaalse veebipõhise sisselogimise ja valideerib sessiooni andmebaasis (`apex_workspace_activity_log`).

---

## 🧪 Eraldiseisvad Testikäsud

```bash
# Käivita TLS ja poliitikate automaatne test:
./tests/test-tls-scenarios.sh

# Käivita brauseri ja UI E2E sisselogimise test:
./tests/test-browser-login.sh

# Käivita kõik 55 ühiktesti:
for t in tests/unit/test-*.sh; do bash "$t"; done
```
