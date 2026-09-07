# 🧪 Testavimo planas: Oracle APEX DevHub programa ir CI/CD konvejeris

[ 🇬🇧 English ](../apex-devhub-test-plan.md) | [ 🇪🇪 Eesti ](../et/apex-devhub-test-plan.md) | [ 🇫🇮 Suomi ](../fi/apex-devhub-test-plan.md) | [ 🇸🇪 Svenska ](../sv/apex-devhub-test-plan.md) | [ 🇱🇻 Latviešu ](../lv/apex-devhub-test-plan.md) | [ 🇱🇹 Lietuvių ](apex-devhub-test-plan.md)

---

## 1. Santrauka ir tikslai

Šio testavimo plano tikslas – nustatyti griežtą kelių lygių tikrinimo strategiją **Oracle APEX DevHub programai (Programa 101)**, jos pagrindiniam PL/SQL varikliui (`DEVHUB.DEV_HUB_PKG`), vietiniam REST dokumentacijos tiltui ir automatizuotam SQLcl APEXlang CI/CD konvejeriui.

### Pagrindiniai tikslai:
1. **Funkcinis Atitikimas:** Užtikrinti 100 % funkcionalumo atitiktį tarp statinio Dev Hub (`docs/dev-hub.html`) ir APEX programos visuose 6 puslapiuose.
2. **Deterministinė Būsenos Izoliacija:** Užkirsti kelią testų užterštumui, naudojant ~15–30 s Golden Snapshot atkūrimą (`bp_3_latest.tar.gz`) prieš regresijos testus.
3. **Kelių Lygių Aprėptis:** Sujungti duomenų bazės utPLSQL testus, REST integracijos patikrinimus, hibridinius naršyklės E2E srautus (Playwright + curl seansų simuliatorius) ir APEX Advisor kodo kokybės auditą.
4. **Zero-Trust Sauga:** Garantuoti, kad prisijungimo duomenys niekada nenutekėtų į HTML DOM, URL parametrus ar slapukus pagal SEPS Wallet principus.
5. **Nuolatinė Integracija:** Užtikrinti sklandų vietinį autonominį modeliavimą (`./scripts/test-local-ci.sh`) ir GitHub Actions automatizavimą (`.github/workflows/deploy-devhub-apexlang.yml`).

---

## 2. Testavimo piramidė ir matrica

| Lygis | Testuojamas Komponentas | Įrankiai | Vykdymo Dažnis | Numatoma Trukmė |
| :--- | :--- | :--- | :--- | :--- |
| **1 lygis** | `DEVHUB.DEV_HUB_PKG`, Lentelės, Duomenys | **utPLSQL v3** / SQLcl | Kiekvienas commit, CI/CD | ~2–5 s |
| **2 lygis** | REST tiltas (8089), `UTL_HTTP`, ORDS | **curl**, Python, SQLcl | CI/CD, Po diegimo | ~3–8 s |
| **3 lygis** | Vartotojų srautai, Puslapiai 1–6, Mermaid | **Playwright** + Bash/curl | Naktiniai, PR peržiūra | ~15–30 s |
| **4 lygis** | APEX kokybė, SSP, SQL injekcijos | **APEX Advisor CLI** | PR peržiūra, CI/CD | ~5–10 s |

---

## 3. Testavimo lygiai ir testavimo atvejai

### 3.1. 1 Lygis: Duomenų bazės vienetų testavimas (utplsql)
Taikinys: `DEVHUB` schemos objektai `FREEPDB1` konteineryje.
- **TC-DB-01:** Schemos ir apribojimų patikra (`DEVHUB_SERVICES`, `DEVHUB_TOPOLOGY` ir kt.).
- **TC-DB-02:** `DEV_HUB_PKG.check_single_service` ir būsenų atnaujinimas (ONLINE/OFFLINE).
- **TC-DB-03:** `DEV_HUB_PKG.refresh_all_service_statuses` masinis vykdymas be blokavimų.
- **TC-DB-04:** `DEV_HUB_PKG.get_doc_markdown_rest` atsparumas, kai tiltas nepasiekiamas.
- **TC-DB-05:** `DEV_HUB_PKG.sync_benchmarks_from_json` JSON apdorojimas ir suliejimas.
- **TC-DB-06:** `DEV_HUB_PKG.authenticate_local_dev` saugumo riba (leidžiama tik localhost).

### 3.2. 2 Lygis: Integracija ir REST dokumentacijos tiltas
Taikinys: Prieglobos ir konteinerio REST tiltas (`scripts/internal/dev-hub-bridge.py`) 8089 prievade.
- **TC-INT-01:** Tilto būsenos patikra (`/api/health`) ir katalogo užklausa (`/api/catalog`).
- **TC-INT-02:** Markdown gavimas visomis 6 palaikomomis kalbomis.
- **TC-INT-03:** Konteinerio vidinis nukreipimas į `http://host.containers.internal:8089`.
- **TC-INT-04:** HTML konvertavimas duomenų bazėje su `APEX_MARKDOWN.TO_HTML`.

### 3.3. 3 Lygis: Naršyklės E2E testavimas (hibridas: Playwright + curl)
Taikinys: Oracle APEX Programa 101 (`https://localhost:8448/ords/r/proxy_workspace/devhub/`).
- **TC-E2E-01:** Neautentifikuotos užklausos nukreipimas į prisijungimo puslapį.
- **TC-E2E-02:** 1 paspaudimo kūrėjo prisijungimas ir seanso slapuko sukūrimas.
- **TC-E2E-03:** 1–6 puslapių pasiekiamumo patikra (HTTP 200).
- **TC-E2E-04:** 1 puslapis (Paslaugų lentelė ir dinaminis atnaujinimas).
- **TC-E2E-05:** 2 puslapis (Architektūros medis ir Mermaid diagrama).
- **TC-E2E-06:** 3 puslapis (Planų naršyklė ir kopijavimas į iškarpinę).
- **TC-E2E-07:** 4 puslapis (Dinaminė daugiakalbė dokumentacijos skaityklė).
- **TC-E2E-08:** 5 puslapis (DevOps komandų centras).
- **TC-E2E-09:** 6 puslapis (Našumo rodiklių suvestinė).

### 3.4. 4 Lygis: Kokybė, APEX advisor ir sauga
- **TC-SEC-01:** APEX Advisor vykdymas per CLI (0 kritinių klaidų).
- **TC-SEC-02:** Session State Protection (SSP) ir kontrolinių sumų auditas.
- **TC-SEC-03:** Zero-Trust patikra prieš slaptažodžių ar raktų nutekėjimą.

---

## 4. Testavimo aplinka ir golden snapshot izoliacija

Prieš didelius testus atkuriama švari būsena:
```bash
./scripts/snapshots/restore-golden-snapshots.sh --auto --yes -b 3 --no-rotate
```
Atkūrimas trunka tik ~15–30 sekundžių ir užtikrina identišką pradinę būseną.

---

## 5. Automatizavimas ir ataskaitos

```bash
# Vykdyti visą testų paketą:
./scripts/test-apex-suite.sh

# Tik konkretų lygį:
./scripts/test-apex-suite.sh --tier db
./scripts/test-apex-suite.sh --tier rest
./scripts/test-apex-suite.sh --tier e2e
./scripts/test-apex-suite.sh --tier advisor
```

Ataskaitų failai:
- JUnit XML: `metrics/junit-apex-devhub.xml`
- Markdown santrauka: `tests/reports/apex_devhub_test_report.md`
- Našumo rodikliai: `metrics/setup_benchmarks.json` (1 taisyklė).
