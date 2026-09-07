[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🛠️ CLI Scenarijų ir Kūrėjo Įrankių Žinynas

Šiame vadove pateikiama išsami visų projekto gyvavimo ciklo, diagnostikos, administravimo ir kūrėjo scenarijų dokumentacija.

Visi scenarijai atitinka griežtą **3 lygių modulinę katalogų struktūrą** (Rule 3), kur kasdieniai kūrėjo CLI įrankiai yra šakniniame kataloge `scripts/`, o specializuoti antriniai procesai ir vidiniai varikliai yra logiškai atskirti į tam skirtus pakatalogius.

---

## 📁 3 Lygių scenarijų katalogų Struktūra

```text
scripts/
├── 🚀 APLINKOS GYVAVIMO CIKLO KOMANDOS:
│   ├── setup-all.sh                 # Pilnas aplinkos diegimas (Projektai 0-11 & CLI)
│   ├── reset-all.sh                 # Aplinkos, tomų ir tinklų atstatymas
│   ├── start-containers.sh          # Sustabdytų konteinerių paleidimas / pratęsimas
│   ├── deploy-remote.sh             # Nuotolinis diegimas į debesį ir tikslinius serverius
│   └── test-local-ci.sh             # Vietinis GitHub Actions CI/CD modeliavimo vykdytojas
│
├── 🔑 KŪRĖJO IR ADMINISTRATORIAUS CLI ĮRANKIAI:
│   ├── get-password.sh              # Slaptažodžių ir vartotojų nuskaitymas iš SEPS Wallet
│   ├── check-urls.sh                # HTTP sveikatos patikra žiniatinklio paslaugoms ir URL
│   ├── check-wallet.sh              # TNS ryšių be slaptažodžio diagnostika su SEPS
│   ├── sqlcl.sh                     # Išmanusis SQLcl CLI apvalkalas (SEPS Wallet /@ALIAS palaikymas)
│   ├── create-developer.sh          # Kūrėjo paskyrų kūrimas ir slaptažodžių atkūrimas
│   ├── register-connections.sh      # VS Code Oracle SQL Developer ryšių sinchronizavimas
│   ├── publish-image-to-artifactory.sh # Atvaizdų publikavimas į Artifactory & .env konfigūracija
│   └── clean-logs.sh                # Diegimo žurnalų ir laikinųjų failų valymas
│
├── 📁 snapshots/                    # 📸 Momentinių kopijų (Golden Snapshots) valdymas (~15s atkūrimas)
│   ├── create-golden-snapshots.sh   # Sukuria suspaustą .tar.gz archyvą iš duomenų bazės tomų
│   ├── restore-golden-snapshots.sh  # Atkuria duomenų bazę į paskutinę žinomą būseną
│   └── clean-golden-snapshots.sh    # Išvalo senus archyvus, išlaikant naujausią
│
├── 📁 certs/                        # 🛡️ Vietinių SSL/TLS sertifikatų pasitikėjimas (Zero-Admin / Non-Root)
│   ├── trust-local-cert-mac.sh      # macOS Raktinės pasitikėjimo diegėjas (0-Root)
│   ├── trust-local-cert.cmd / .ps1  # Windows Sertifikatų saugyklos scenarijai (0-Admin)
│   └── untrust-local-cert-mac.sh    # Sertifikatų šalinimo įrankiai
│
├── 📁 publisher/                    # 📑 Analytics Publisher valdymas ir operacijos
│   ├── status-publisher.sh          # Publisher paslaugos ir WebLogic serverio būsena
│   ├── restart-publisher.sh         # Tvarkingas Publisher konteinerio perkrovimas
│   ├── backup-publisher-catalog.sh  # Ataskaitų katalogo eksportavimas ir atsarginė kopija
│   └── deploy-publisher-reports.sh  # Ataskaitų importavimas ir Git sinchronizavimas
│
├── 📁 forms/                        # 📐 Oracle Forms 14c valdymas ir operacijos
│   ├── status-forms.sh              # Forms Runtime ir WebLogic diagnostika
│   ├── restart-forms.sh             # Tvarkingas Forms konteinerio perkrovimas
│   └── deploy-forms-apps.sh         # .fmx programų pristatymas į /u01/oracle/forms_apps
│
└── 📁 internal/                     # ⚙️ Neinteraktyvūs vidiniai automatizavimo varikliai
    ├── common.sh, load-profile.sh, generate-compose-override.sh, create-wallet.sh ...
```

---

## 1. Automatizuotas aplinkos diegimas (`setup-all.sh`)

Scenarijus `./scripts/setup-all.sh` atlieka pilną aplinkos diegimą: atsisiunčia programinės įrangos paketus, orkestruoja konteinerius, laukia duomenų bazių ir ORDS parengties, vykdo schemos migracijas (Liquibase), įdiegia APEX su pataisomis ir matuoja trukmę (Rule 1).

> 🏛️ **Modulinė ir Profiliais Paremta Architektūra:**
> Scenarijus `setup-all.sh` veikia kaip **pagrindinis orkestratorius**, teikiantis CLI sąsają, tiesioginius laikmačius (Rule 7), rodiklių rinkimą (`metrics/`) ir žurnalus (`install_logs/`), deleguodamas užduotis varikliams kataloge `scripts/internal/`:
> - 📦 **Bendra branduolio biblioteka:** `common.sh` (spalvos, trukmė, eiga, valymas, suspaudimas)
> - 📄 **Compose Override:** `generate-compose-override.sh` (dinaminiai nustatymai & paslaptys)
> - 📦 **Profiliai & Topologija:** `load-profile.sh` & `resolve-topology.sh`
> - ⌛ **Sveikatos Patikra:** `wait-db-healthy.sh` (2 fazių adaptyvi patikra ir savęs gydymas)
> - 🔌 **Egzemplioriaus Inicijavimas:** `init-db-instance.sh`
> - 👤 **Vartotojai & Rolės:** `apply-profile-users.sh`
> - 🔒 **Sertifikatų Pasitikėjimas:** `generate-local-certs.sh`
> - 💻 **VS Code Ryšiai:** `register-connections.sh`
> - 📊 **Ataskaitos & Rodikliai:** `generate-setup-report.sh`

> 📊 **Išsamios darbo eigos ir architektūros reikalavimai dokumentuoti faile: [docs/setup-all-workflow.md](../docs/setup-all-workflow.md)**

> [!IMPORTANT]
> **SQLcl Konteinerio Atsarginis Modelis (Rule 4):** Prieš paleidimą scenarijus patikrina, ar įdiegtas vietinis **SQLcl**. Jei nerandama, jis automatiškai persijungia į **SQLcl konteinerio atvaizdą** (`SQLCL_CONTAINER_IMAGE`). Tai užtikrina sėkmingą migraciją ir APEX diegimą be vietinės Java.

**Sintaksė:**
```bash
./scripts/setup-all.sh [-b <0-11>] [-tb <0-11|LIST|all>] [-lb] [-sb <0-11>] [--search <QUERY>] [--dry-run] [-ltr] [-i] [--force | -y] [--no-publisher] [--no-ords] [--no-monitor-app]
```

**Parinktys ir Parametrai:**
*   **`-b <N>` / `--blueprint <N>`:** Gamybos ir kūrimo režimas. Aktyvuoja tiksliai **vieną** pasirinktą projektą (0–11) ir išsaugo esamus duomenis (Idempotentinis / Be atstatymo).
*   **`-tb <LIST|all>` / `--test-blueprints`:** Automatizuotas CI/CD testavimo režimas. Prieš kiekvieną testą paleidžia `reset-all.sh -y`, užtikrindamas švarią pradinę būseną.
*   **`-lb` / `-l` / `--list-blueprints`:** Rodo visų 12 palaikomų projektų dinaminę lentelę nepaleidžiant konteinerių.
*   **`-sb <N>` / `--show-blueprint <N>`:** Rodo projekto `<N>` specifikacijas (konteineriai, prievadai, RAM, TLS).
*   **`--search <QUERY>` / `--search-blueprints`:** Ieško projektų pagal raktinį žodį.
*   **`--dry-run`:** Modeliuoja vykdymą be faktinių pakeitimų.
*   **`-ltr` / `--list-test-reports`:** Rodo testų ataskaitų būseną kataloge `tests/reports/blueprints/`.
*   **`-i` / `--select`:** Atidaro interaktyvų meniu su 30s laikmačiu.
*   **`--force` / `-y`:** Praleidžia patvirtinimo klausimus (tinka CI/CD).
*   **`--no-publisher`:** Nepaleidžia Publisher duomenų bazės (`db-publisher`), taupant atmintį.
*   **`--from-snapshot`:** Atkuria duomenų bazės tomus iš momentinės kopijos prieš paleidimą (**greitas startas ~30s**).
*   **`--build-image`:** Išsaugo duomenų bazę kaip iš anksto sukonfigūruotą konteinerio atvaizdą.
*   **`--parallel`:** Leidžia lygiagretų inicijavimą (reikia laisvos RAM $\ge$ 8 GB).
*   **`--sequential`:** Reikalauja griežto nuoseklaus diegimo (saugus numatytasis režimas).

**Pavyzdžiai:**
```bash
# 1. GAMYBA IR KASDIENIS KŪRIMAS:
./scripts/setup-all.sh -b 3             # Aktyvuoti rekomenduojamą 2 lygių gamybos modelį
./scripts/setup-all.sh --blueprint 7    # Aktyvuoti Full Enterprise 4 lygių steką
./scripts/setup-all.sh -lb              # Peržiūrėti visų 12 projektų lentelę
./scripts/setup-all.sh -sb 3            # Peržiūrėti projekto 3 konteinerių medį
./scripts/setup-all.sh -b 3 --dry-run   # Simuliuoti paleidimą

# 2. AUTOMATIZUOTAS TESTAVIMAS IR CI/CD:
./scripts/setup-all.sh -tb 3            # Testuoti konkretų projektą nuo pradžių
./scripts/setup-all.sh -tb 1,5,8        # Testuoti pasirinktus projektus
./scripts/setup-all.sh -tb all          # Testuoti VISUS 12 projektų iš eilės
./scripts/setup-all.sh -ltr             # Tikrinti testų ataskaitas

# 3. Interaktyvus diegimas:
./scripts/setup-all.sh
```

---

## 2. Konteinerių paleidimas (`start-containers.sh`)

Paleidžia esamus vietinius duomenų bazės ir ORDS konteinerius ir laukia, kol duomenų bazės pasieks būseną `healthy`.

```bash
./scripts/start-containers.sh [--no-ords] [--no-publisher]
```

---

## 3. Aplinkos ir komponentų atstatymas (`reset-all.sh`)

Modulinis profiliu valdomas valymo variklis, kuris sustabdo ir pašalina konteinerius, profilius (`config/profiles/*.yaml`), tomus ir tinklus.

```bash
./scripts/reset-all.sh all
./scripts/reset-all.sh all --logs --force
```

---

## 4. Momentinių kopijų valdymas (`scripts/snapshots/`)

```bash
./scripts/snapshots/create-golden-snapshots.sh
./scripts/snapshots/restore-golden-snapshots.sh --force
./scripts/snapshots/clean-golden-snapshots.sh
```

---

## 4.5. ŽUrnalų valymas ir sauga (`clean-logs.sh` & `sanitize-logs.sh`)

```bash
./scripts/clean-logs.sh [-y | --force]
```
Visi žurnalai automatiškai filtruojami, kad būtų užmaskuotos paslaptys. Avariniam derinimui:
```bash
DEBUG_LOG_UNSANITIZED=true ./scripts/setup-all.sh
```

---

## 5. Kūrėjo Ir administratoriaus CLI Įrankiai

### 5.1. Slaptažodžių Skaitymas iš Wallet (`get-password.sh`)
```bash
./scripts/get-password.sh <ALIAS>
./scripts/get-password.sh DB_PROXY_DEV
./scripts/get-password.sh DB_PROXY_APEX_ADMIN
```

### 5.2. ŽIniatinklio paslaugų HTTP patikra (`check-urls.sh`)
```bash
./scripts/check-urls.sh
```

### 5.3. SEPS Ryšių diagnostika (`check-wallet.sh`)
```bash
./scripts/check-wallet.sh
```

### 5.4. Išmanusis SQLcl CLI apvalkalas (`sqlcl.sh`)
```bash
./scripts/sqlcl.sh /@DB_PROXY_DEV
./scripts/sqlcl.sh /@DB_PROXY_SYS as sysdba
```

### 5.5. Kūrėjo Paskyros Kūrimas (`create-developer.sh`)
```bash
./scripts/create-developer.sh
```

### 5.6. VS code Ryšių sinchronizavimas (`register-connections.sh`)
```bash
./scripts/register-connections.sh
```

---

## 6. Vietinių sertifikatų Pasitikėjimas (`scripts/certs/`)

* 🍎 **macOS:** `./scripts/certs/trust-local-cert-mac.sh`
* 🪟 **Windows & WSL:** `scripts\certs\trust-local-cert.cmd` / `trust-local-cert.ps1`

---

## 7. Analytics Publisher operacijos (`scripts/publisher/`)

* `./scripts/publisher/status-publisher.sh`
* `./scripts/publisher/restart-publisher.sh`
* `./scripts/publisher/backup-publisher-catalog.sh`
* `./scripts/publisher/deploy-publisher-reports.sh`

---

## 8. Nuotolinis diegimas & kelių debesų testavimas (`deploy-remote.sh`)

```bash
./scripts/deploy-remote.sh --host 20.123.45.67 --user azureuser --key ~/.ssh/id_rsa --blueprint 10
./tests/test-remote-multicloud.sh --dry-run
./tests/test-devhub-browser-blueprints.sh --all
```

---

## 9. Rankinis pataisų diegimas (`scripts/internal/`)

* `./scripts/internal/apply-apex-patch.sh`
* `./scripts/internal/apply-publisher-patch.sh`

---

## 10. Vidiniai automatizavimo varikliai (`scripts/internal/`)

Išsamesnę informaciją rasite kataloge:
* 📁 **[`scripts/internal/README.lt.md`](internal/README.lt.md)**

---

## 11. Trikčių ŠAlinimas: Podman machine Atkūrimo vadovas

Kilus lizdų klaidoms arba pasibaigus konteinerių laikui:

```bash
podman machine stop
podman machine start
./scripts/reset-all.sh --force
./scripts/setup-all.sh --force
```
