[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🛠️ CLI Skriptu un Izstrādātāja Rīku Rokasgrāmata

Šī rokasgrāmata sniedz visaptverošu dokumentāciju visiem vides dzīves cikla, diagnostikas, administratīvajiem un izstrādātāju skriptiem projektā.

Visi skripti ievēro stingru **3 līmeņu modulāru direktoriju struktūru** (Rule 3), kur ikdienas izstrādātāja CLI rīki atrodas saknes mapē `scripts/`, bet specializēti apakšprocesi un iekšējie dzinēji ir loģiski nodalīti atsevišķās apakšmapēs.

---

## 📁 3 Līmeņu Skriptu direktoriju Struktūra

```text
scripts/
├── 🚀 VIDES DZĪVES CIKLA KOMANDAS:
│   ├── setup-all.sh                 # Pilna vides uzstādīšana (Projektējumi 0-11 & CLI)
│   ├── reset-all.sh                 # Vides, sējumu un tīklu atiestatīšana
│   ├── start-containers.sh          # Apturētu konteineru palaišana / atsākšana
│   ├── deploy-remote.sh             # Attālināta ieviešana mākonī un mērķa serveros
│   └── test-local-ci.sh             # Vietējais GitHub Actions CI/CD simulācijas izpildītājs
│
├── 🔑 IZSTRĀDĀTĀJA UN ADMINISTRATORA CLI RĪKI:
│   ├── get-password.sh              # Paroļu un lietotājvārdu nolasīšana no SEPS Wallet
│   ├── check-urls.sh                # HTTP veselības pārbaude tīmekļa pakalpojumiem un URL
│   ├── check-wallet.sh              # Bezparoles TNS savienojumu diagnostika ar SEPS
│   ├── sqlcl.sh                     # Viedais SQLcl CLI ietvars (SEPS Wallet /@ALIAS atbalsts)
│   ├── create-developer.sh          # Izstrādātāju kontu izveide un paroļu atkopšana
│   ├── register-connections.sh      # VS Code Oracle SQL Developer savienojumu sinhronizācija
│   ├── publish-image-to-artifactory.sh # Attēlu publicēšana Artifactory & .env konfigurācija
│   └── clean-logs.sh                # Instalācijas žurnālu un pagaidu failu tīrīšana
│
├── 📁 snapshots/                    # 📸 Momentuzņēmumu (Golden Snapshots) pārvaldība (~15s atkopšana)
│   ├── create-golden-snapshots.sh   # Izveido saspiestu .tar.gz arhīvu no datubāzes sējumiem
│   ├── restore-golden-snapshots.sh  # Atjauno datubāzi uz pēdējo zināmo stāvokli
│   └── clean-golden-snapshots.sh    # Notīra vecos arhīvus, saglabājot jaunāko
│
├── 📁 certs/                        # 🛡️ Lokālo SSL/TLS sertifikātu uzticamība (Zero-Admin / Non-Root)
│   ├── trust-local-cert-mac.sh      # macOS Atslēgu glabātuves uzticamība (0-Root)
│   ├── trust-local-cert.cmd / .ps1  # Windows Sertifikātu glabātuves skripti (0-Admin)
│   └── untrust-local-cert-mac.sh    # Sertifikātu noņemšanas rīki
│
├── 📁 publisher/                    # 📑 Analytics Publisher pārvaldība un darbības
│   ├── status-publisher.sh          # Publisher pakalpojuma un WebLogic servera statuss
│   ├── restart-publisher.sh         # Korekta Publisher konteinera pārstartēšana
│   ├── backup-publisher-catalog.sh  # Atskaišu kataloga eksports un dublēšana
│   └── deploy-publisher-reports.sh  # Atskaišu imports un Git sinhronizācija
│
├── 📁 forms/                        # 📐 Oracle Forms 14c pārvaldība un darbības
│   ├── status-forms.sh              # Forms Runtime un WebLogic diagnostika
│   ├── restart-forms.sh             # Korekta Forms konteinera pārstartēšana
│   └── deploy-forms-apps.sh         # .fmx lietotņu piegāde uz /u01/oracle/forms_apps
│
└── 📁 internal/                     # ⚙️ Neinteraktīvie iekšējie automatizācijas dzinēji
    ├── common.sh, load-profile.sh, generate-compose-override.sh, create-wallet.sh ...
```

---

## 1. Automatizēta Vides Uzstādīšana (`setup-all.sh`)

Skripts `./scripts/setup-all.sh` veic pilnu vides instalāciju: lejupielādē programmatūras paketes, orķestrē konteinerus, gaida datubāžu un ORDS gatavību, palaiž shēmas migrācijas (Liquibase), instalē APEX ar ielāpiem un mēra ilgumu (Rule 1).

> 🏛️ **Modulāra un uz Profiliem Balstīta Arhitektūra:**
> Skripts `setup-all.sh` kalpo kā **galvenais orķestrētājs**, kas nodrošina CLI saskarni, reāllaika taimerus (Rule 7), rādītāju vākšanu (`metrics/`) un žurnālus (`install_logs/`), deleģējot uzdevumus dzinējiem mapē `scripts/internal/`:
> - 📦 **Kopīgā kodola bibliotēka:** `common.sh` (krāsas, ilgums, progress, tīrīšana, saspiešana)
> - 📄 **Compose Override:** `generate-compose-override.sh` (dinamiskie iestatījumi & noslēpumi)
> - 📦 **Profili & Topoloģija:** `load-profile.sh` & `resolve-topology.sh`
> - ⌛ **Veselības Pārbaude:** `wait-db-healthy.sh` (2 fāžu adaptīvā pārbaude un pašdziedināšanās)
> - 🔌 **Instances Inicializācija:** `init-db-instance.sh`
> - 👤 **Lietotāji & Loma:** `apply-profile-users.sh`
> - 🔒 **Sertifikātu Uzticamība:** `generate-local-certs.sh`
> - 💻 **VS Code Savienojumi:** `register-connections.sh`
> - 📊 **Pārskati & Rādītāji:** `generate-setup-report.sh`

> 📊 **Detalizētas darbplūsmas un arhitektūras prasības ir aprakstītas dokumentā: [docs/setup-all-workflow.md](../docs/setup-all-workflow.md)**

> [!IMPORTANT]
> **SQLcl Konteinera Rezerves Modelis (Rule 4):** Pirms palaišanas skripts pārbauda, vai ir instalēts lokālais **SQLcl**. Ja tas netiek atrasts, tas automātiski pārslēdzas uz **SQLcl konteinera attēlu** (`SQLCL_CONTAINER_IMAGE`). Tas garantē migrāciju un APEX importu veiksmīgu izpildi uz tīrām mašīnām bez lokālās Java.

**Sintakse:**
```bash
./scripts/setup-all.sh [-b <0-11>] [-tb <0-11|LIST|all>] [-lb] [-sb <0-11>] [--search <QUERY>] [--dry-run] [-ltr] [-i] [--force | -y] [--no-publisher] [--no-ords] [--no-monitor-app]
```

**Opcijas un Parametri:**
*   **`-b <N>` / `--blueprint <N>`:** Produkcijas un izstrādes režīms. Aktivizē tieši **vienu** izvēlēto projektējumu (0–11) un saglabā esošos datus (Idempotents / Bez atiestatīšanas).
*   **`-tb <LIST|all>` / `--test-blueprints`:** Automatizēts CI/CD testēšanas režīms. Pirms katra testa palaiž `reset-all.sh -y`, nodrošinot tīru bāzes stāvokli.
*   **`-lb` / `-l` / `--list-blueprints`:** Parāda visu 12 projektējumu dinamisko tabulu, nepalaižot konteinerus.
*   **`-sb <N>` / `--show-blueprint <N>`:** Parāda projektējuma `<N>` specifikācijas (konteineri, porti, RAM, TLS).
*   **`--search <QUERY>` / `--search-blueprints`:** Meklē projektējumus pēc atslēgvārda.
*   **`--dry-run`:** Simulē izpildi bez faktiskām izmaiņām.
*   **`-ltr` / `--list-test-reports`:** Parāda testu pārskatu statusu mapē `tests/reports/blueprints/`.
*   **`-i` / `--select`:** Atver interaktīvu izvēlni ar 30s taimeri.
*   **`--force` / `-y`:** Izlaiž apstiprinājuma vaicājumus (piemērots CI/CD).
*   **`--no-publisher`:** Nepalaid Publisher datubāzi (`db-publisher`), lai ietaupītu atmiņu.
*   **`--from-snapshot`:** Atjauno datubāzes sējumus no momentuzņēmuma pirms palaišanas (**ātrais starts ~30s**).
*   **`--build-image`:** Saglabā datubāzi kā iepriekš konfigurētu konteinera attēlu pēc instalācijas.
*   **`--parallel`:** Atļauj paralēlu inicializāciju (nepieciešama brīva RAM $\ge$ 8 GB).
*   **`--sequential`:** Pieprasa stingru secīgu instalāciju (drošais noklusējuma režīms).

**Piemēri:**
```bash
# 1. PRODUKCIJA UN IKDIENAS IZSTRĀDE:
./scripts/setup-all.sh -b 3             # Aktivizēt ieteikto 2 līmeņu produkcijas modeli
./scripts/setup-all.sh --blueprint 7    # Aktivizēt Full Enterprise 4 līmeņu steku
./scripts/setup-all.sh -lb              # Skatīt visu 12 projektējumu tabulu
./scripts/setup-all.sh -sb 3            # Skatīt projektējuma 3 konteineru koku
./scripts/setup-all.sh -b 3 --dry-run   # Simulēt palaišanu

# 2. AUTOMATIZĒTĀ TESTĒŠANA UN CI/CD:
./scripts/setup-all.sh -tb 3            # Testēt konkrētu modeli no jauna
./scripts/setup-all.sh -tb 1,5,8        # Testēt izvēlētos modeļus
./scripts/setup-all.sh -tb all          # Testēt VISUS 12 modeļus pēc kārtas
./scripts/setup-all.sh -ltr             # Pārbaudīt testu pārskatus

# 3. Interaktīvā uzstādīšana:
./scripts/setup-all.sh
```

---

## 2. Konteineru Palaišana (`start-containers.sh`)

Palaiž esošos lokālos datubāzes un ORDS konteinerus un gaida, līdz datubāzes sasniedz `healthy` statusu.

```bash
./scripts/start-containers.sh [--no-ords] [--no-publisher]
```

---

## 3. Vides un komponentu Atiestatīšana (`reset-all.sh`)

Modulārs profila vadīts tīrīšanas dzinējs, kas aptur un noņem konteinerus, profilus (`config/profiles/*.yaml`), sējumus un tīklus.

```bash
./scripts/reset-all.sh all
./scripts/reset-all.sh all --logs --force
```

---

## 4. Momentuzņēmumu Pārvaldība (`scripts/snapshots/`)

```bash
./scripts/snapshots/create-golden-snapshots.sh
./scripts/snapshots/restore-golden-snapshots.sh --force
./scripts/snapshots/clean-golden-snapshots.sh
```

---

## 4.5. Žurnālu Tīrīšana Un Drošība (`clean-logs.sh` & `sanitize-logs.sh`)

```bash
./scripts/clean-logs.sh [-y | --force]
```
Visi žurnāli tiek automātiski filtrēti, lai maskētu noslēpumus. Ārkārtas atkļūdošanai:
```bash
DEBUG_LOG_UNSANITIZED=true ./scripts/setup-all.sh
```

---

## 5. Izstrādātāja Un administratora CLI Rīki

### 5.1. Paroļu Nolasīšana No Wallet (`get-password.sh`)
```bash
./scripts/get-password.sh <ALIAS>
./scripts/get-password.sh DB_PROXY_DEV
./scripts/get-password.sh DB_PROXY_APEX_ADMIN
```

### 5.2. Tīmekļa Pakalpojumu HTTP Pārbaude (`check-urls.sh`)
```bash
./scripts/check-urls.sh
```

### 5.3. SEPS savienojumu diagnostika (`check-wallet.sh`)
```bash
./scripts/check-wallet.sh
```

### 5.4. Viedais SQLcl CLI ietvars (`sqlcl.sh`)
```bash
./scripts/sqlcl.sh /@DB_PROXY_DEV
./scripts/sqlcl.sh /@DB_PROXY_SYS as sysdba
```

### 5.5. Izstrādātāja Konta izveide (`create-developer.sh`)
```bash
./scripts/create-developer.sh
```

### 5.6. VS code savienojumu Sinhronizācija (`register-connections.sh`)
```bash
./scripts/register-connections.sh
```

---

## 6. Lokālo Sertifikātu Uzticamība (`scripts/certs/`)

* 🍎 **macOS:** `./scripts/certs/trust-local-cert-mac.sh`
* 🪟 **Windows & WSL:** `scripts\certs\trust-local-cert.cmd` / `trust-local-cert.ps1`

---

## 7. Analytics Publisher Darbības (`scripts/publisher/`)

* `./scripts/publisher/status-publisher.sh`
* `./scripts/publisher/restart-publisher.sh`
* `./scripts/publisher/backup-publisher-catalog.sh`
* `./scripts/publisher/deploy-publisher-reports.sh`

---

## 8. Attālinātā Ieviešana & Multi-Mākoņu Testēšana (`deploy-remote.sh`)

```bash
./scripts/deploy-remote.sh --host 20.123.45.67 --user azureuser --key ~/.ssh/id_rsa --blueprint 10
./tests/test-remote-multicloud.sh --dry-run
./tests/test-devhub-browser-blueprints.sh --all
```

---

## 9. Manuāla Ielāpu Uzstādīšana (`scripts/internal/`)

* `./scripts/internal/apply-apex-patch.sh`
* `./scripts/internal/apply-publisher-patch.sh`

---

## 10. Iekšējie Automatizācijas Dzinēji (`scripts/internal/`)

Sīkāku informāciju skatiet mapē:
* 📁 **[`scripts/internal/README.lv.md`](internal/README.lv.md)**

---

## 11. Problēmu Novēršana: Podman machine Atkopšanas Plāns

Ja rodas ligzdas kļūdas vai konteineru taimauti:

```bash
podman machine stop
podman machine start
./scripts/reset-all.sh --force
./scripts/setup-all.sh --force
```
