[ 🇬🇧 English ](../testing-framework-and-devhub.md) | [ 🇪🇪 Eesti ](testing-framework-and-devhub.md) | [ 🇫🇮 Suomi ](../fi/testing-framework-and-devhub.md) | [ 🇸🇪 Svenska ](../sv/testing-framework-and-devhub.md) | [ 🇱🇻 Latviešu ](../lv/testing-framework-and-devhub.md) | [ 🇱🇹 Lietuvių ](../lt/testing-framework-and-devhub.md)

# 🧪 Testraamistik ja Dev hubi integratsioon

Käesolev tehniline juhend kirjeldab platvormi mitmetasemelise automaattestimise arhitektuuri, Developer Hubi (`docs/dev-hub.html`) interaktiivset **Testimiskeskust** (`tab-testing`), asünkroonset testide orkestreerimist `dev-hub-bridge.py` kaudu ning testkatvuse analüüsi.

---

## 🏛️ 1. Tehniline arhitektuur ja komponentide voog

Testimise ökosüsteem ühendab arendaja UI toimingud testikäivitajate, reaalajas logimise ja Git-jälgitavate mõõdikutega:

```mermaid
flowchart TD
    subgraph UI ["🖥️ Dev Hubi Testimiskeskus (tab-testing)"]
        SR["🚀 Testikomplektide Käivitaja<br/>(Unit, Integ, Live, i18n, Portatiivsus)"]
        TR["📑 Testiaruannete Arhiiv<br/>(Markdown kahe paaniga lugeja)"]
        CE["📊 Koodikaetuse Sirvija<br/>(scripts/*.sh analüüs)"]
        TH["📜 Testide Käivituste Ajalugu<br/>(Ajatemplid, Kestus, Logid)"]
        SC["🏆 CI Valmisoleku Tulemuskaart<br/>(Unit, i18n, Portatiivsus, CI Värav)"]
    end

    subgraph BridgeAPI ["⚡ Dev Hub Bridge (dev-hub-bridge.py :8089)"]
        R_RUN["POST /api/tests/run<br/>(suite, script)"]
        R_STATUS["GET /api/task/status?task=test_runner<br/>(PID, stdout, exit_code)"]
        R_STOP["POST /api/tests/stop<br/>(SIGTERM protsessigrupp)"]
        R_REP["GET /api/tests/reports<br/>GET /api/tests/report-content"]
        R_COV["GET /api/tests/coverage<br/>(Parsib report-coverage.md)"]
        R_HIST["GET /api/tests/history<br/>(test_execution_history.json)"]
    end

    subgraph Runners ["⚙️ Testraamistiku Käivitajad"]
        T_UNIT["tests/test-all-components.sh<br/>(30+ kiiret ühiktesti)"]
        T_INTEG["tests/integration/*.sh<br/>(Topoloogia, Compose, Rollid)"]
        T_LIVE["tests/test-live-platform.sh<br/>(Konteinerid, Kuulajad, Teenused)"]
        T_I18N["tests/test-multilingual-support.sh<br/>(Reegel 9 Pariteet 6 keeles)"]
        T_PORT["tests/unit/test-filename-portability.sh<br/>(Reegel 13 Portatiivsus)"]
        T_COV["tests/generate-test-coverage-report.sh<br/>(Skannib scripts/ ja internal/)"]
    end

    subgraph Storage ["💾 Püsivad Mõõdikud ja Logid (Reegel 1)"]
        LOGS["install_logs/test_*.log<br/>(Lokaalne tee stdout/stderr)"]
        HIST_JSON["metrics/test_execution_history.json<br/>(Git-jälgitavad käivituslogid)"]
        COV_MD["tests/reports/test-coverage-report.md<br/>(Skriptide kaetuse tabel)"]
        REPORTS_DIR["tests/reports/*.md<br/>(Regressiooni ja mõõdikute raportid)"]
    end

    UI -->|Asünkroonne HTTP / Fetch| BridgeAPI
    BridgeAPI -->|subprocess.Popen & tee| Runners
    Runners -->|Kirjutab Reaalajas Logi| LOGS
    Runners -->|Genereerib Aruanded| REPORTS_DIR
    Runners -->|Uuendab Kaetuse Tabelit| COV_MD
    BridgeAPI -->|Lisab Tulemuse Lõpetamisel| HIST_JSON
    Storage -.->|Loeb ja Parsib| BridgeAPI
```

---

## 🚀 2. Testikomplektide ülevaade

Platvorm jaotab kvaliteedi kontrolli spetsialiseeritud testikomplektideks:

| Komplekti Võti | Nimi | Kirjeldus | Käsk |
| :--- | :--- | :--- | :--- |
| `unit` | **Ühiktestide Komplekt** | 29+ kiiret isolatsioonitesti: konfigratsioonid, SEPS wallet, süntaks ja loogika ilma live-baasita. | `./tests/test-all-components.sh` |
| `integration` | **Integratsioonitestid** | Mitme andmebaasi topoloogia, compose override genereerimine, profiili rollid ja ühenduskontroll. | `tests/integration/*.sh` |
| `live` | **Live Platvormi E2E** | Täielik regressioon töötavate konteinerite, andmebaasi kuulajate ja veebiteenuste vastu. | `./tests/test-live-platform.sh` |
| `i18n` | **Mitmekeelsuse Pariteet** | Reegli 9 range audit, mis kontrollib sõnastiku sümmeetriat kõigis 6 keeles (EN, ET, FI, SV, LV, LT). | `./tests/test-multilingual-support.sh --all` |
| `portability` | **Failinimede Portatiivsus** | Reegli 13 audit: Windows NTFS/FAT keelatud märgid, seadmenimed ja ASCII teekonventsioonid. | `./tests/unit/test-filename-portability.sh` |
| `browser` | **Brauseri & SSO E2E** | Simuleerib brauseritoiminguid, APEXi sisselogimist, Dev Hubi otseteed ja SSO autentimist. | `./scripts/test-browser-login.sh` |
| `ci_sim` | **Lokaalne GitHub CI** | Käivitab või eelvaatleb GitHub Actions CI/CD töövooge võrguühenduseta konteinerites. | `./scripts/test-local-ci.sh --dry-run` |
| `precommit` | **Pre-Commit Turvakontroll** | Välkkiire 6-faasiline audit enne commit'i/push'i: Zero-Trust saladused, GDPR/isikuandmed, Zero-Knowledge ettevõtte info, Reegel 13 porditavus, süntaks ja reavahetused. | `./scripts/check-pre-commit.sh --full` |
| `coverage` | **Kaetuse Genereerija** | Analüüsib kaetust kataloogides `scripts/` ja `scripts/internal/` ning uuendab markdown raportit. | `./tests/generate-test-coverage-report.sh` |

---

## 🖥️ 3. Dev hubi testimiskeskus (`tab-testing`)

Developer Hubi testimise vahekaart pakub nelja alamvahekaarti:

### 3.1 🚀 Testikomplektide käivitaja (`test-subtab-runner`)
- **Komplektikaardid**: Võimaldab ühe klõpsuga käivitada tervet komplekti või rippmenüüst valitud üksikut testi.
- **Sisseehitatud Reaalajas Terminal**: Terminaliboks (`#0b0f19`), mis kuvab stdout/stderr reaalajas voogu, pakub automaatse kerimise lülitit, stopperit, logi allalaadimist ja sundkatkestamist (`POST /api/tests/stop`).

### 3.2 📑 Testiaruannete arhiiv (`test-subtab-reports`)
- **Kahepaaniline vaatur**: Vasakul loetletakse raportid (`tests/reports/*.md`) staatusemärkidega (`PASS`, `FAIL`, `INFO`) ja ajatemplitega.
- **Renderdatud Markdown**: Paremal kuvatakse vormindatud HTML koos aktiivsete Mermaid diagrammidega ning lülitiga toor-markdowni vaatamiseks.

### 3.3 📊 Koodikaetuse sirvija (`test-subtab-coverage`)
- **KPI Kokkuvõte**: Visuaalne edenemisriba, mis näitab kaetud skriptide protsenti, koguarvu, kaetud ja katmata skripte.
- **Interaktiivne Tabel**: Kuvab kõik `scripts/*.sh` ja `scripts/internal/*.sh` skriptid ning nendega seotud testifailid.
- **Filtreerimine ja Otsing**: Kiire otsing ja filtrid ("Kõik", "Kaetud", "Katmata").
- **Analüüsi Värskendamine**: Käivitab skripti `generate-test-coverage-report.sh` otse kasutajaliidesest.

### 3.4 📜 Käivituste ajalugu (`test-subtab-history`)
- Kuvab faili `metrics/test_execution_history.json` salvestatud ajalugu.
- Näitab ajatemplit, komplekti, skripti nime, kestust sekundites, tulemust, otselinki failile `install_logs/test_*.log` ja 1-klõpsuga **Re-run** nuppu.

---

## 🔒 4. Zero-trust turvalisus ja reeglite vastavus

1. **Reegel 1 (Ajastus ja Logimine)**: Iga testi käivitus teeb automaatselt `tee` väljundi faili `install_logs/test_<suite>_<timestamp>.log` ja fikseerib kestuse failis `metrics/test_execution_history.json`.
2. **Reegel 9 (i18n Pariteet)**: Kogu testimise vahekaart on täielikult tõlgitud kõigisse kuude keelde (EN, ET, FI, SV, LV, LT).
3. **Reegel 12 (Asünkroonne Ülesanne)**: Testid käivitatakse asünkroonselt `subprocess.Popen` abil ilma veebiliidese hangumise või HTTP ajalõputa.
4. **Reegel 13 (Portatiivsus)**: Kõik raportid ja logid kasutavad ASCII kebab-case nimesid ilma Windowsi keelatud märkideta.

---

## 🌐 5. Sõnastiku veebilinkide null-allalaadimisega audit (`test-glossary-links.sh` / `.cmd`)

Tagamaks, et dokumentatsiooni ja Dev Hubi glossaari lingid ei tagasta kunagi `404 Not Found` vealehti ning välistades igasuguse pahavara või failide allalaadimise ohu:

1. **Mälupõhine HTTP HEAD päring**: Kontrollmootor (`scripts/internal/check-glossary-links.py`) teeb ainult HTTP `HEAD` päringuid, lugedes üksnes HTTP staatuskoodi (200, 301, 404). Vastuse keha ei loeta ega salvestata kettale.
2. **Ristplatvormiline virtuaalne tühiseade (Windows ja POSIX)**:
   - **POSIX (macOS / Linux / WSL2)**: Väljund suunatakse seadmele `/dev/null`.
   - **Windows (NTFS / CMD / PowerShell)**: Väljund suunatakse seadmele `NUL` skriptiga `tests/unit/test-glossary-links.cmd`.
   - **Pythoni standardteek**: Portatiivne `os.devnull` tagab null kettakirjutust kõigil operatsioonisüsteemidel.
3. **Protokollilukk**: Rangelt lubatud vaid `https://` protokoll.
4. **Dev Hubi reaalajas käivitamine**: Test on registreeritud Dev Hubi **Unit Test Suite** all (`tab-testing`) ning on käivitatav 1-klikiga koos reaalajas terminali logivooga.

---

## 🛡️ 6. Git Pre-Commit ja Pre-Push turvakontroll (`scripts/check-pre-commit.sh`)

Tagamaks, et vigane kood, krüpteerimata paroolid, GDPR rikkumised ja konfidentsiaalne ettevõtte info ei satuks kunagi Giti ajalukku:

### 6.1 6-Faasiline kontrolliarhitektuur
1. **Reegel 13 & 14 Portatiivsus**: Kontrollib Windows NTFS keelatud märke (`< > : " / \ | ? *`), DOS seadmenimesid (`CON`, `PRN`, `AUX`, `NUL`), lõpupunkte/tühikuid ning LF Unix reavahetusi.
2. **Reegel 5 Zero-Trust Saladuste Skaneerimine**: Blokeerib `.env.secrets`, privaatvõtmed (`*.pem`, `*.key`, `id_rsa`), AWS võtmed ja koodisisesed paroolid. Veateadetes maskeeritakse leitud väärtused (`***`), vältides infoleket logidesse.
3. **GDPR ja Isikuandmete (PII) Audit**: Tõkestab andmebaasi dumpide (`*.dmp`, `*.dump`, `*.bak`, `*.sql.gz`), isikukoodide ja pangakontode (IBAN) commitimise.
4. **Zero-Knowledge Konfidentsiaalse Info Tuvastus**: Võrdleb koodi märgendeid SHA-256 räside loendiga (`config/security/forbidden_hashes.json`) ja tuvastab universaalseid sisevõrgu domeene (`*.corp`, `*.intra`, `*.internal`). **Koodi ei salvestata ühtegi ettevõtte nime selges tekstis.**
5. **Staatiline Süntaksikontroll**: Teostab `bash -n` shell-skriptidele, `python3 -m py_compile` Pythonile ja JSON/YAML süntaksikontrolli enne commit'i.
6. **Dev-Hub ja Tõlgete Sünkroonsus**: Tagab Dev Hubi vigadeta genereerimise ja 6-keelse tõlkesümmeetria.

### 6.2 Arendaja CLI ja Git Hookide Kasutamine
```bash
# Kontrolli ainult lavastatud (staged) faile enne commitimist (~1s):
./scripts/check-pre-commit.sh --staged

# Kogu repositooriumi põhjalik audit enne pushimist (~5s):
./scripts/check-pre-commit.sh --full

# Paigalda automaatsed Git hookid (.githooks/pre-commit ja .githooks/pre-push):
./scripts/check-pre-commit.sh --install-hook

# Lisa konfidentsiaalne märksõna Zero-Knowledge SHA-256 räsina:
./scripts/check-pre-commit.sh --add-forbidden-hash "märksõna"

# Paranda reavahetused automaatselt LF standardile:
./scripts/check-pre-commit.sh --fix
```

### 6.3 Käivitamine Dev Hubi kaudu
- **DevOps juhtpult**: 1-klõpsuga kaart **"Git Pre-Commit & Pre-Push turvakontroll"** käivitab kohese auditi koos reaalajas väljundiga.
- **Testimiskeskus (`tab-testing`)**: Registreeritud kategoorias **Compliance** koos reaalajas käivitamise, logide ja dokumentatsiooni linkidega.

