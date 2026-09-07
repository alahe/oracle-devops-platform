# 🧪 Testaussuunnitelma: Oracle APEX DevHub -sovellus ja CI/CD -putki

[ 🇬🇧 English ](../apex-devhub-test-plan.md) | [ 🇪🇪 Eesti ](../et/apex-devhub-test-plan.md) | [ 🇫🇮 Suomi ](apex-devhub-test-plan.md) | [ 🇸🇪 Svenska ](../sv/apex-devhub-test-plan.md) | [ 🇱🇻 Latviešu ](../lv/apex-devhub-test-plan.md) | [ 🇱🇹 Lietuvių ](../lt/apex-devhub-test-plan.md)

---

## 1. Yhteenveto ja Tavoitteet

Tämän testaussuunnitelman tavoitteena on määritellä monitasoinen varmennusstrategia **Oracle APEX DevHub -sovellukselle (Sovellus 101)**, sen taustalla toimivalle PL/SQL-moottorille (`DEVHUB.DEV_HUB_PKG`), paikalliselle REST-dokumentaatiosillalle ja automatisoidulle SQLcl APEXlang CI/CD -putkelle.

### Keskeiset Tavoitteet:
1. **Toiminnallinen Yhdenmukaisuus:** Varmistaa 100 % ominaisuuksien vastaavuus staattisen Dev Hubin (`docs/dev-hub.html`) ja APEX-sovelluksen välillä kaikilla 6 sivulla.
2. **Deterministinen Tilan Eristäminen:** Taata testien riippumattomuus hyödyntämällä ~15–30 sekunnin Golden Snapshot -palautusta (`bp_3_latest.tar.gz`) ennen kattavia regressiotestejä.
3. **Monitasoinen Kattavuus:** Yhdistää tietokantatason utPLSQL-testit, REST-integraatiotarkistukset, hybridit selain-E2E-työnkulut (Playwright + curl-istuntosimulaattori) sekä APEX Advisor -laadunvarmistus.
4. **Zero-Trust -Tietoturva:** Varmistaa, että tunnistautumistietoja ei koskaan vuoda HTML DOM -rakenteeseen, URL-parametreihin tai evästeisiin SEPS Wallet -periaatteiden mukaisesti.
5. **Jatkuva Integraatio (CI/CD):** Mahdollistaa saumaton offline-simulointi (`./scripts/test-local-ci.sh`) ja GitHub Actions -automaatio (`.github/workflows/deploy-devhub-apexlang.yml`).

---

## 2. Testauspyramidi ja Kattavuusmatriisi

| Taso | Testattava Komponentti | Työkalut | Suoritustiheys | Odotettu Kesto |
| :--- | :--- | :--- | :--- | :--- |
| **Taso 1** | `DEVHUB.DEV_HUB_PKG`, Taulut, Siemenet | **utPLSQL v3** / SQLcl | Jokainen commit, CI/CD | ~2–5 s |
| **Taso 2** | REST-silta (8089), `UTL_HTTP`, ORDS | **curl**, Python, SQLcl | CI/CD, Asennuksen jälkeen | ~3–8 s |
| **Taso 3** | Käyttäjävirrat, Sivut 1–6, Mermaid | **Playwright** + Bash/curl | Öinen ajo, PR-tarkistus | ~15–30 s |
| **Taso 4** | APEX-laatu, SSP, SQL-injektiot | **APEX Advisor CLI** | PR-tarkistus, CI/CD | ~5–10 s |

---

## 3. Testaustasot ja Testitapaukset

### 3.1. Taso 1: Tietokannan Yksikkötestaus (utPLSQL)
Kohde: `DEVHUB`-skeeman objektit `FREEPDB1`-tietokannassa.
- **TC-DB-01:** Skeeman ja rajoitteiden validointi (`DEVHUB_SERVICES`, `DEVHUB_TOPOLOGY`, jne.).
- **TC-DB-02:** `DEV_HUB_PKG.check_single_service` ja tilapäivitykset (ONLINE/OFFLINE, vasteajat).
- **TC-DB-03:** `DEV_HUB_PKG.refresh_all_service_statuses` massapäivitys ilman lukituksia.
- **TC-DB-04:** `DEV_HUB_PKG.get_doc_markdown_rest` vikasietoisuus sillan ollessa poissa käytöstä.
- **TC-DB-05:** `DEV_HUB_PKG.sync_benchmarks_from_json` JSON-käsittely ja tietojen yhdistäminen.
- **TC-DB-06:** `DEV_HUB_PKG.authenticate_local_dev` turvarajojen tarkistus (vain localhost sallittu).

### 3.2. Taso 2: Integraatio ja REST-dokumentaatiosilta
Kohde: Isäntäkoneen ja kontin välinen REST-silta (`scripts/internal/dev-hub-bridge.py`) portissa `8089`.
- **TC-INT-01:** Sillan terveystarkastus (`/api/health`) ja luettelohaku (`/api/catalog`).
- **TC-INT-02:** Markdown-sisällön haku kaikilla 6 tuetulla kielellä.
- **TC-INT-03:** Kontinsisäinen reititys osoitteeseen `http://host.containers.internal:8089`.
- **TC-INT-04:** HTML-muunnos tietokannassa `APEX_MARKDOWN.TO_HTML` -funktiolla.

### 3.3. Taso 3: Selaimen E2E-Testaus (Hybridi: Playwright + Curl)
Kohde: Oracle APEX Sovellus 101 (`https://localhost:8448/ords/r/proxy_workspace/devhub/`).
- **TC-E2E-01:** Kirjautumattoman pyynnön uudelleenohjaus kirjautumissivulle.
- **TC-E2E-02:** 1-klikkauksen kehittäjäkirjautuminen ja evästeen luonti.
- **TC-E2E-03:** Sivujen 1–6 saatavuustarkistus (HTTP 200).
- **TC-E2E-04:** Sivu 1 (Palvelutilat ja dynaaminen päivitys).
- **TC-E2E-05:** Sivu 2 (Arkkitehtuurin puu- ja Mermaid-kaaviot).
- **TC-E2E-06:** Sivu 3 (Blueprint-selain ja leikepöytäkopiointi).
- **TC-E2E-07:** Sivu 4 (Dynaaminen monikielinen dokumentaatiolukija).
- **TC-E2E-08:** Sivu 5 (DevOps-komentokeskus).
- **TC-E2E-09:** Sivu 6 (Suorituskykymittaristot).

### 3.4. Taso 4: Laatu, APEX Advisor ja Turvallisuus
- **TC-SEC-01:** APEX Advisor -tarkastus CLI-työkalulla (0 kriittistä virhettä).
- **TC-SEC-02:** Session State Protection (SSP) ja tarkistussummien validointi.
- **TC-SEC-03:** Zero-Trust -tarkastus salasanojen ja avainten vuotojen estämiseksi.

---

## 4. Testausympäristö ja Golden Snapshot -eristys

Jokainen laaja testiajo käynnistää puhtaan tilan:
```bash
./scripts/snapshots/restore-golden-snapshots.sh --auto --yes -b 3 --no-rotate
```
Palautus vie vain ~15–30 sekuntia ja takaa aina identtisen tietokantatilan.

---

## 5. Suoritus ja Raportointi

```bash
# Aja koko testauskokonaisuus:
./scripts/test-apex-suite.sh

# Vain tietty taso:
./scripts/test-apex-suite.sh --tier db
./scripts/test-apex-suite.sh --tier rest
./scripts/test-apex-suite.sh --tier e2e
./scripts/test-apex-suite.sh --tier advisor
```

Tuotetut raportit:
- JUnit XML: `metrics/junit-apex-devhub.xml`
- Markdown-koonti: `tests/reports/apex_devhub_test_report.md`
- Suorituskykymittarit: `metrics/setup_benchmarks.json` (Sääntö 1).
