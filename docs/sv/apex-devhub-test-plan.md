# 🧪 Testplan: Oracle APEX DevHub-applikation och CI/CD-pipeline

[ 🇬🇧 English ](../apex-devhub-test-plan.md) | [ 🇪🇪 Eesti ](../et/apex-devhub-test-plan.md) | [ 🇫🇮 Suomi ](../fi/apex-devhub-test-plan.md) | [ 🇸🇪 Svenska ](apex-devhub-test-plan.md) | [ 🇱🇻 Latviešu ](../lv/apex-devhub-test-plan.md) | [ 🇱🇹 Lietuvių ](../lt/apex-devhub-test-plan.md)

---

## 1. Sammanfattning och mål

Syftet med denna testplan är att fastställa en rigorös verifieringsstrategi i flera nivåer för **Oracle APEX DevHub-applikationen (App 101)**, dess underliggande PL/SQL-motor (`DEVHUB.DEV_HUB_PKG`), den lokala REST-dokumentationsbryggan och den automatiserade SQLcl APEXlang CI/CD-pipelinen.

### Huvudmål:
1. **Funktionell Paritet:** Säkerställa 100 % funktionslikhet mellan den statiska Dev Hub (`docs/dev-hub.html`) och APEX-applikationen över alla 6 sidor.
2. **Deterministisk Tillståndsisolering:** Garantera isolering genom ~15–30s återställning från Golden Snapshot (`bp_3_latest.tar.gz`) före regressionstester.
3. **Flernivåtäckning:** Kombinera utPLSQL-tester på databasnivå, REST-integrationskontroller, hybrida webbläsarflöden (Playwright + curl-sessionssimulator) och APEX Advisor-kodgranskning.
4. **Zero-Trust Säkerhet:** Säkerställa att autentiseringsuppgifter aldrig läcker till HTML DOM, URL-parametrar eller cookies.
5. **Kontinuerlig Integration:** Tillhandahålla smidig lokal offline-simulering (`./scripts/test-local-ci.sh`) och GitHub Actions-automatisering (`.github/workflows/deploy-devhub-apexlang.yml`).

---

## 2. Testpyramid och omfattningsmatris

| Nivå | Testad Komponent | Verktyg | Körningsfrekvens | Förväntad Tid |
| :--- | :--- | :--- | :--- | :--- |
| **Nivå 1** | `DEVHUB.DEV_HUB_PKG`, Tabeller, Frödata | **utPLSQL v3** / SQLcl | Varje commit, CI/CD | ~2–5 s |
| **Nivå 2** | REST-brygga (8089), `UTL_HTTP`, ORDS | **curl**, Python, SQLcl | CI/CD, Efter driftsättning | ~3–8 s |
| **Nivå 3** | Användarflöden, Sidor 1–6, Mermaid | **Playwright** + Bash/curl | Nattlig, PR-validering | ~15–30 s |
| **Nivå 4** | APEX-kvalitet, SSP, SQL-injektion | **APEX Advisor CLI** | PR-validering, CI/CD | ~5–10 s |

---

## 3. Testnivåer och testfall

### 3.1. Nivå 1: Enhetstestning i databasen (utplsql)
Mål: `DEVHUB`-schemaobjekt i `FREEPDB1`.
- **TC-DB-01:** Schemavalidering och integritetsbegränsningar.
- **TC-DB-02:** `DEV_HUB_PKG.check_single_service` och statusuppdateringar (ONLINE/OFFLINE).
- **TC-DB-03:** `DEV_HUB_PKG.refresh_all_service_statuses` batchkörning utan låsningar.
- **TC-DB-04:** `DEV_HUB_PKG.get_doc_markdown_rest` motståndskraft när bryggan är offline.
- **TC-DB-05:** `DEV_HUB_PKG.sync_benchmarks_from_json` JSON-tolkning och sammanfogning.
- **TC-DB-06:** `DEV_HUB_PKG.authenticate_local_dev` säkerhetsgräns (endast localhost tillåten).

### 3.2. Nivå 2: Integration och REST-dokumentationsbrygga
Mål: Värd-till-container REST-brygga (`scripts/internal/dev-hub-bridge.py`) på port `8089`.
- **TC-INT-01:** Hälsokontroll (`/api/health`) och kataloghämtning (`/api/catalog`).
- **TC-INT-02:** Hämtning av Markdown på alla 6 språk.
- **TC-INT-03:** Containerintern routing till `http://host.containers.internal:8089`.
- **TC-INT-04:** HTML-konvertering i databasen via `APEX_MARKDOWN.TO_HTML`.

### 3.3. Nivå 3: E2E-webbläsartestning (hybrid: Playwright + curl)
Mål: Oracle APEX Applikation 101 (`https://localhost:8448/ords/r/proxy_workspace/devhub/`).
- **TC-E2E-01:** Oautentiserad omdirigering till inloggningssidan.
- **TC-E2E-02:** 1-klicks utvecklarinloggning och sessionscookie.
- **TC-E2E-03:** Tillgänglighetskontroll för sidorna 1–6 (HTTP 200).
- **TC-E2E-04:** Sida 1 (Tjänstestatustabell och dynamisk uppdatering).
- **TC-E2E-05:** Sida 2 (Arkitekturträd och Mermaid-diagram).
- **TC-E2E-06:** Sida 3 (Blueprints-utforskare och urklippskopiering).
- **TC-E2E-07:** Sida 4 (Dynamisk flerspråkig dokumentationsläsare).
- **TC-E2E-08:** Sida 5 (DevOps-kommandocenter).
- **TC-E2E-09:** Sida 6 (Prestandamätvärden).

### 3.4. Nivå 4: Kvalitet, APEX advisor och säkerhet
- **TC-SEC-01:** Körning av APEX Advisor via CLI (0 kritiska fel).
- **TC-SEC-02:** Session State Protection (SSP) och kontrollsummor.
- **TC-SEC-03:** Zero-Trust säkerhetskontroll mot läckor av lösenord eller nycklar.

---

## 4. Testmiljö och golden snapshot-isolering

Före stora testsviter återställs ren miljö via:
```bash
./scripts/snapshots/restore-golden-snapshots.sh --auto --yes -b 3 --no-rotate
```
Återställningen tar endast ~15–30 sekunder och garanterar identiskt utgångsläge.

---

## 5. Automatisering och rapportering

```bash
# Kör hela testsviten:
./scripts/test-apex-suite.sh

# Specifik nivå:
./scripts/test-apex-suite.sh --tier db
./scripts/test-apex-suite.sh --tier rest
./scripts/test-apex-suite.sh --tier e2e
./scripts/test-apex-suite.sh --tier advisor
```

Rapporter:
- JUnit XML: `metrics/junit-apex-devhub.xml`
- Markdown-sammanfattning: `tests/reports/apex_devhub_test_report.md`
- Prestandamått: `metrics/setup_benchmarks.json` (Regel 1).
