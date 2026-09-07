[ 🇬🇧 English ](../testing-framework-and-devhub.md) | [ 🇪🇪 Eesti ](../et/testing-framework-and-devhub.md) | [ 🇫🇮 Suomi ](../fi/testing-framework-and-devhub.md) | [ 🇸🇪 Svenska ](../sv/testing-framework-and-devhub.md) | [ 🇱🇻 Latviešu ](../lv/testing-framework-and-devhub.md) | [ 🇱🇹 Lietuvių ](testing-framework-and-devhub.md)

# 🧪 Testavimo sistema ir developer Hub integracija

Šiame techniniame vadove aprašoma platformos kelių lygių automatizuoto testavimo architektūra, interaktyvus **Testavimo Centras** (`tab-testing`) sistemoje Developer Hub (`docs/dev-hub.html`), asinchroninis testų vykdymas per `dev-hub-bridge.py` ir kodo aprėpties stebėjimas.

---

## 🏛️ 1. Techninė architektūra ir komponentų srautas

Testavimo ekosistema sujungia kūrėjo vartotojo sąsajos veiksmus su testų vykdytojais, realaus laiko registravimu ir Git sekamais rodikliais:

```mermaid
flowchart TD
    subgraph UI ["🖥️ Dev Hub Testavimo Centras (tab-testing)"]
        SR["🚀 Testų Rinkinių Vykdytojas<br/>(Unit, Integ, Live, i18n, Perkeliamumas)"]
        TR["📑 Testų Ataskaitų Archyvas<br/>(Markdown Dviejų Skilčių Skaitytuvas)"]
        CE["📊 Kodo Aprėpties Naršyklė<br/>(scripts/*.sh Analizė)"]
        TH["📜 Testų Vykdymo Istorija<br/>(Laiko Žymos, Trukmė, Žurnalai)"]
        SC["🏆 CI Parengties Suvestinė<br/>(Unit, i18n, Perkeliamumas, CI Vartai)"]
    end

    subgraph BridgeAPI ["⚡ Dev Hub Bridge (dev-hub-bridge.py :8089)"]
        R_RUN["POST /api/tests/run<br/>(suite, script)"]
        R_STATUS["GET /api/task/status?task=test_runner<br/>(PID, stdout, exit_code)"]
        R_STOP["POST /api/tests/stop<br/>(SIGTERM procesų grupė)"]
        R_REP["GET /api/tests/reports<br/>GET /api/tests/report-content"]
        R_COV["GET /api/tests/coverage<br/>(Apdoroja report-coverage.md)"]
        R_HIST["GET /api/tests/history<br/>(test_execution_history.json)"]
    end

    subgraph Runners ["⚙️ Testavimo Sistemos Vykdytojai"]
        T_UNIT["tests/test-all-components.sh<br/>(30+ greitų vienetų testų)"]
        T_INTEG["tests/integration/*.sh<br/>(Topologija, Compose, Vaidmenys)"]
        T_LIVE["tests/test-live-platform.sh<br/>(Konteineriai, Klausytojai, Paslaugos)"]
        T_I18N["tests/test-multilingual-support.sh<br/>(Taisyklė 9 Paritetas 6 Kalbomis)"]
        T_PORT["tests/unit/test-filename-portability.sh<br/>(Taisyklė 13 Perkeliamumas)"]
        T_COV["tests/generate-test-coverage-report.sh<br/>(Tikrina scripts/ ir internal/)"]
    end

    subgraph Storage ["💾 Nuolatiniai Rodikliai ir Žurnalai (Taisyklė 1)"]
        LOGS["install_logs/test_*.log<br/>(Vietinis tee stdout/stderr)"]
        HIST_JSON["metrics/test_execution_history.json<br/>(Git sekami vykdymo žurnalai)"]
        COV_MD["tests/reports/test-coverage-report.md<br/>(Skriptų aprėpties lentelė)"]
        REPORTS_DIR["tests/reports/*.md<br/>(Regresijos ir našumo ataskaitos)"]
    end

    UI -->|Asinchroninis HTTP / Fetch| BridgeAPI
    BridgeAPI -->|subprocess.Popen & tee| Runners
    Runners -->|Rašo Realaus Laiko Žurnalą| LOGS
    Runners -->|Generuoja Ataskaitas| REPORTS_DIR
    Runners -->|Atnaujina Aprėpties Lentelę| COV_MD
    BridgeAPI -->|Prideda Rezultatą Baigus| HIST_JSON
    Storage -.->|Skaito ir Apdoroja| BridgeAPI
```

---

## 🚀 2. Testų rinkinių apžvalga

Platforma kokybės užtikrinimą suskirsto į specializuotus testų rinkinius:

| Rinkinys | Pavadinimas | Aprašymas | Komanda |
| :--- | :--- | :--- | :--- |
| `unit` | **Vienetų Testų Rinkinys** | 29+ greiti izoliuoti testai be veikiančios DB: konfigūracijos, SEPS piniginė, sintaksė ir logika. | `./tests/test-all-components.sh` |
| `integration` | **Integraciniai Testai** | Kelių duomenų bazių topologija, compose override kūrimas, profilių vaidmenys ir ryšiai. | `tests/integration/*.sh` |
| `live` | **Veikiančios Platformos E2E** | Pilnas regresinis testavimas prieš veikiančius konteinerius, DB klausytojus ir paslaugas. | `./tests/test-live-platform.sh` |
| `i18n` | **Daugiakalbystės Paritetas** | Griežtas Taisyklės 9 auditas, tikrinantis žodyno simetriją visomis 6 kalbomis (EN, ET, FI, SV, LV, LT). | `./tests/test-multilingual-support.sh --all` |
| `portability` | **Failų Vardų Perkeliamumas** | Taisyklės 13 auditas: Windows NTFS/FAT draudžiami simboliai, įrenginių vardai ir ASCII keliai. | `./tests/unit/test-filename-portability.sh` |
| `browser` | **Naršyklė & SSO E2E** | Simuliuoja naršyklės veiksmus, APEX prisijungimą, Dev Hub sparčiuosius klavišus ir SSO autentifikavimą. | `./scripts/test-browser-login.sh` |
| `ci_sim` | **Vietinis GitHub CI** | Vykdo arba peržiūri GitHub Actions darbo eigas autonomiškai laikinuose konteineriuose. | `./scripts/test-local-ci.sh --dry-run` |
| `coverage` | **Aprėpties Generatorius** | Analizuoja aprėptį `scripts/` ir `scripts/internal/` kataloguose bei atnaujina markdown ataskaitą. | `./tests/generate-test-coverage-report.sh` |

---

## 🖥️ 3. Dev Hub testavimo centras (`tab-testing`)

Developer Hub testavimo skirtukas siūlo 4 specializuotus poskirtukus:

### 3.1 🚀 Testų rinkinių vykdytojas (`test-subtab-runner`)
- **Rinkinių Kortelės**: Leidžia vienu spustelėjimu vykdyti visą rinkinį arba išskleidžiamajame sąraše pasirinktą atskirą skriptą.
- **Integruotas Realaus Laiko Terminalas**: Terminalo langas (`#0b0f19`), rodantis stdout/stderr realiuoju laiku, su automatiniu slinkimu, laikmačiu, žurnalo atsisiuntimu ir stabdymu (`POST /api/tests/stop`).

### 3.2 📑 Testų ataskaitų archyvas (`test-subtab-reports`)
- **Dvigubos Skilties Rodinys**: Kairiajame skydelyje pateikiamos ataskaitos (`tests/reports/*.md`) su būsenos žymomis (`PASS`, `FAIL`, `INFO`) ir laiko žymomis.
- **Renderuotas Markdown**: Dešiniajame skydelyje rodomas suformatuotas HTML su veikiančiomis Mermaid diagramomis ir perjungikliu į neapdorotą tekstą.

### 3.3 📊 Kodo aprėpties naršyklė (`test-subtab-coverage`)
- **KPI Suvestinė**: Vaizdinė eigos juosta, rodanti padengtų skriptų procentą, bendrą skaičių, padengtus ir nepadengtus skriptus.
- **Interaktyvi Lentelė**: Išvardija visus skriptus `scripts/*.sh` ir `scripts/internal/*.sh` bei susijusius testų failus.
- **Filtravimas ir Paieška**: Greita teksto paieška ir būsenos filtrai ("Visi", "Padengti", "Nepadengti").
- **Analizės Atnaujinimas**: Vykdo `generate-test-coverage-report.sh` tiesiai iš sąsajos.

### 3.4 📜 Vykdymo istorija (`test-subtab-history`)
- Rodo faile `metrics/test_execution_history.json` užregistruotą istoriją.
- Pateikia laiko žymą, rinkinį, skripto pavadinimą, trukmę sekundėmis, rezultatą, tiesioginę nuorodą į `install_logs/test_*.log` ir mygtuką **Vykdyti iš naujo**.

---

## 🔒 4. Zero-trust saugumas ir taisyklių atitiktis

1. **Taisyklė 1 (Laiko Matavimas ir Žurnalas)**: Kiekvienas testas automatiškai nukreipia išvestį į `install_logs/test_<suite>_<timestamp>.log` ir išsaugo trukmę faile `metrics/test_execution_history.json`.
2. **Taisyklė 9 (Daugiakalbystė)**: Visa sąsaja yra visiškai išversta į visas šešias kalbas (EN, ET, FI, SV, LV, LT).
3. **Taisyklė 12 (Asinchroninė Užduotis)**: Testai vykdomi fone per `subprocess.Popen`, neužblokuojant naršyklės ir nesukeliant HTTP skirtųjų laikų.
4. **Taisyklė 13 (Perkeliamumas)**: Visi ataskaitų ir žurnalų failų vardai naudoja griežtą ASCII kebab-case standartą be Windows draudžiamų simbolių.

---

## 🌐 5. Žodyno nuorodų saugus auditas be atsisiuntimų (`test-glossary-links.sh` / `.cmd`)

Užtikrina, kad dokumentacijos ir Dev Hub žodyno nuorodos niekada negrąžintų `404 Not Found` klaidos, garantuojant apsaugą nuo failų atsisiuntimo:

1. **Atmintyje vykdomos HTTP HEAD užklausos**: Tikrinimo variklis (`scripts/internal/check-glossary-links.py`) naudoja tik HTTP `HEAD` užklausas ir nuskaito tik būsenos kodą (200, 301, 404). Atsako turinys niekada neįrašomas į diską.
2. **Tarpplatforminis nulinis įrenginys (Windows ir POSIX)**:
   - **POSIX (macOS / Linux / WSL2)**: Išvestis nukreipiama į `/dev/null`.
   - **Windows (NTFS / CMD / PowerShell)**: Išvestis nukreipiama į `NUL` per `tests/unit/test-glossary-links.cmd`.
   - **Python standartinė biblioteka**: `os.devnull` garantuoja nulinį disko naudojimą visose OS.
3. **Protokolo apsauga**: Leidžiamas tik `https://`.
4. **Dev Hub vykdymas**: Testas pasiekiamas Dev Hub **Unit Test Suite** skirtuke (`tab-testing`) su tiesioginiu konsolės transliavimu.
