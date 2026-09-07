# 🧪 Testēšanas Plāns: Oracle APEX DevHub Lietotne un CI/CD Konveijers

[ 🇬🇧 English ](../apex-devhub-test-plan.md) | [ 🇪🇪 Eesti ](../et/apex-devhub-test-plan.md) | [ 🇫🇮 Suomi ](../fi/apex-devhub-test-plan.md) | [ 🇸🇪 Svenska ](../sv/apex-devhub-test-plan.md) | [ 🇱🇻 Latviešu ](apex-devhub-test-plan.md) | [ 🇱🇹 Lietuvių ](../lt/apex-devhub-test-plan.md)

---

## 1. Kopsavilkums un Mērķi

Šī testēšanas plāna mērķis ir noteikt daudzlīmeņu verifikācijas stratēģiju **Oracle APEX DevHub lietotnei (Lietotne 101)**, tās pamatā esošajam PL/SQL dzinējam (`DEVHUB.DEV_HUB_PKG`), vietējam REST dokumentācijas tiltam un automatizētajam SQLcl APEXlang CI/CD konveijeram.

### Galvenie Mērķi:
1. **Funkcionālā Atbilstība:** Nodrošināt 100% funkcionalitātes paritāti starp statisko Dev Hub (`docs/dev-hub.html`) un APEX lietotni visās 6 lapās.
2. **Deterministiska Stāvokļa Izolācija:** Garantēt izolāciju, izmantojot ~15–30s Golden Snapshot atjaunošanu (`bp_3_latest.tar.gz`) pirms regresijas testiem.
3. **Daudzlīmeņu Pārklājums:** Apvienot datubāzes līmeņa utPLSQL testus, REST integrācijas pārbaudes, hibrīdās pārlūka E2E darba plūsmas (Playwright + curl sesiju simulators) un APEX Advisor koda kvalitātes auditu.
4. **Zero-Trust Drošība:** Nodrošināt, ka akreditācijas dati nekad nenoplūst uz HTML DOM, URL parametriem vai sīkfailiem atbilstoši SEPS Wallet prasībām.
5. **Nepārtrauktā Integrācija:** Nodrošināt bezsaistes lokālo emulāciju (`./scripts/test-local-ci.sh`) un GitHub Actions automatizāciju (`.github/workflows/deploy-devhub-apexlang.yml`).

---

## 2. Testēšanas Piramīda un Matrica

| Līmenis | Testējamais Komponents | Rīki | Izpildes Biežums | Paredzamais Ilgums |
| :--- | :--- | :--- | :--- | :--- |
| **1. līmenis** | `DEVHUB.DEV_HUB_PKG`, Tabulas, Dati | **utPLSQL v3** / SQLcl | Katrs commits, CI/CD | ~2–5 s |
| **2. līmenis** | REST tilts (8089), `UTL_HTTP`, ORDS | **curl**, Python, SQLcl | CI/CD, Pēc izvietošanas | ~3–8 s |
| **3. līmenis** | Lietotāja plūsmas, Lapas 1–6, Mermaid | **Playwright** + Bash/curl | Nakts testi, PR pārbaude | ~15–30 s |
| **4. līmenis** | APEX kvalitāte, SSP, SQL injekcijas | **APEX Advisor CLI** | PR pārbaude, CI/CD | ~5–10 s |

---

## 3. Testēšanas Līmeņi un Gadījumi

### 3.1. 1. līmenis: Datubāzes Vienību Testēšana (utPLSQL)
Mērķis: `DEVHUB` shēmas objekti `FREEPDB1` konteinerā.
- **TC-DB-01:** Shēmas un ierobežojumu validācija.
- **TC-DB-02:** `DEV_HUB_PKG.check_single_service` un statusa atjaunināšana (ONLINE/OFFLINE).
- **TC-DB-03:** `DEV_HUB_PKG.refresh_all_service_statuses` pakešizpilde bez bloķēšanām.
- **TC-DB-04:** `DEV_HUB_PKG.get_doc_markdown_rest` noturība, kad tilts nav sasniedzams.
- **TC-DB-05:** `DEV_HUB_PKG.sync_benchmarks_from_json` JSON apstrāde un apvienošana.
- **TC-DB-06:** `DEV_HUB_PKG.authenticate_local_dev` drošības robeža (atļauts tikai localhost).

### 3.2. 2. līmenis: Integrācijas un REST Dokumentācijas Tilts
Mērķis: Hosta un konteinera REST tilts (`scripts/internal/dev-hub-bridge.py`) portā `8089`.
- **TC-INT-01:** Tilta veselības pārbaude (`/api/health`) un kataloga vaicājums (`/api/catalog`).
- **TC-INT-02:** Markdown ielāde visās 6 atbalstītajās valodās.
- **TC-INT-03:** Konteinera iekšējā maršrutēšana uz `http://host.containers.internal:8089`.
- **TC-INT-04:** HTML konvertēšana datubāzē ar `APEX_MARKDOWN.TO_HTML`.

### 3.3. 3. līmenis: Pārlūka E2E Testēšana (Hibrīds: Playwright + Curl)
Mērķis: Oracle APEX Lietotne 101 (`https://localhost:8448/ords/r/proxy_workspace/devhub/`).
- **TC-E2E-01:** Neautentificēta pieprasījuma novirzīšana uz pieteikšanās lapu.
- **TC-E2E-02:** 1-klikšķa izstrādātāja autentifikācija un sesijas sīkfaila izveide.
- **TC-E2E-03:** Lapu 1–6 pieejamības pārbaude (HTTP 200).
- **TC-E2E-04:** 1. lapa (Pakalpojumu tabula un dinamiskā atjaunošana).
- **TC-E2E-05:** 2. lapa (Arhitektūras koks un Mermaid diagramma).
- **TC-E2E-06:** 3. lapa (Plānu pārlūks un starpliktuves kopēšana).
- **TC-E2E-07:** 4. lapa (Dinamisks daudzvalodu dokumentācijas lasītājs).
- **TC-E2E-08:** 5. lapa (DevOps komandu centrs).
- **TC-E2E-09:** 6. lapa (Veiktspējas mērījumu panelis).

### 3.4. 4. līmenis: Kvalitāte, APEX Advisor un Drošība
- **TC-SEC-01:** APEX Advisor palaišana caur CLI (0 kritisku kļūdu).
- **TC-SEC-02:** Session State Protection (SSP) un kontrolsummu audits.
- **TC-SEC-03:** Zero-Trust pārbaude pret paroļu noplūdēm.

---

## 4. Testēšanas Vide un Golden Snapshot Izolācija

Pirms plašiem testiem tiek atjaunots tīrs stāvoklis:
```bash
./scripts/snapshots/restore-golden-snapshots.sh --auto --yes -b 3 --no-rotate
```
Atjaunošana aizņem tikai ~15–30 sekundes un nodrošina identisku sākuma stāvokli.

---

## 5. Automatizācija un Ziņošana

```bash
# Palaist pilnu testu komplektu:
./scripts/test-apex-suite.sh

# Tikai konkrētu līmeni:
./scripts/test-apex-suite.sh --tier db
./scripts/test-apex-suite.sh --tier rest
./scripts/test-apex-suite.sh --tier e2e
./scripts/test-apex-suite.sh --tier advisor
```

Ziņojumu artefakti:
- JUnit XML: `metrics/junit-apex-devhub.xml`
- Markdown kopsavilkums: `tests/reports/apex_devhub_test_report.md`
- Veiktspējas rādītāji: `metrics/setup_benchmarks.json` (1. noteikums).
