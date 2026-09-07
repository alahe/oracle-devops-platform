[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🛠️ CLI-Skript och Utvecklarverktyg Referensguide

Denna guide tillhandahåller fullständig dokumentation för alla miljö-, diagnostik-, administrations- och utvecklarscript i projektet.

Alla skript följer en strikt **3-nivåers modulär kataloglayout** (Rule 3), där dagliga CLI-verktyg för utvecklare finns i rotkatalogen `scripts/`, och specialiserade delprocesser och interna motorer är logiskt uppdelade i dedikerade underkataloger.

---

## 📁 3-Nivåers Katalogstruktur för Skript

```text
scripts/
├── 🚀 KOMMANDON FÖR MILJÖNS LIVSCYKEL:
│   ├── setup-all.sh                 # Komplett miljöinstallation (Arkitekturritningar 0-11 & CLI)
│   ├── reset-all.sh                 # Återställning av miljö, volymer och nätverk
│   ├── start-containers.sh          # Starta eller återuppta stoppade containrar
│   ├── deploy-remote.sh             # Fjärrdriftsättning till moln och målservrar
│   └── test-local-ci.sh             # Lokal körning av GitHub Actions CI/CD-simulering
│
├── 🔑 CLI-VERKTYG FÖR UTVECKLARE OCH ADMINISTRATÖRER:
│   ├── get-password.sh              # Hämta lösenord och användarnamn från SEPS Wallet
│   ├── check-urls.sh                # HTTP-hälsokontroll för webbtjänster, pooler och URL:er
│   ├── check-wallet.sh              # Diagnostik för lösenordsfria TNS-anslutningar med SEPS
│   ├── sqlcl.sh                     # Smart SQLcl CLI-omslag (stöd för SEPS Wallet /@ALIAS)
│   ├── create-developer.sh          # Skapa utvecklarkonton och återställa lösenord
│   ├── register-connections.sh      # Synkronisering av VS Code Oracle SQL Developer-anslutningar
│   ├── publish-image-to-artifactory.sh # Publicera avbildningar till Artifactory & .env-konfiguration
│   └── clean-logs.sh                # Rensa installationsloggar och temporära filer
│
├── 📁 snapshots/                    # 📸 Hantering av ögonblicksbilder (Golden Snapshots, ~15s återställning)
│   ├── create-golden-snapshots.sh   # Skapar komprimerat .tar.gz-arkiv av databasvolymer
│   ├── restore-golden-snapshots.sh  # Återställer databasen till senaste kända läge
│   └── clean-golden-snapshots.sh    # Rensar gamla arkiv medan senaste behålls
│
├── 📁 certs/                        # 🛡️ Förtroendehantering för lokala SSL/TLS-certifikat (Zero-Admin / Non-Root)
│   ├── trust-local-cert-mac.sh      # macOS Nyckelringsinstallatör (0-Root)
│   ├── trust-local-cert.cmd / .ps1  # Windows Certifikatarkiv skript (0-Admin)
│   └── untrust-local-cert-mac.sh    # Verktyg för att ta bort certifikat
│
├── 📁 publisher/                    # 📑 Hantering och drift av Analytics Publisher
│   ├── status-publisher.sh          # Status för Publisher och WebLogic-server
│   ├── restart-publisher.sh         # Kontrollerad omstart av Publisher-container
│   ├── backup-publisher-catalog.sh  # Säkerhetskopiering och export av rapportkatalog
│   └── deploy-publisher-reports.sh  # Rapportimport och Git-katalogsynkronisering
│
├── 📁 forms/                        # 📐 Hantering och drift av Oracle Forms 14c
│   ├── status-forms.sh              # Diagnostik för Forms Runtime och WebLogic
│   ├── restart-forms.sh             # Kontrollerad omstart av Forms-container
│   └── deploy-forms-apps.sh         # Leverans av .fmx-applikationer till /u01/oracle/forms_apps
│
└── 📁 internal/                     # ⚙️ Icke-interaktiva interna automationsmotorer
    ├── common.sh, load-profile.sh, generate-compose-override.sh, create-wallet.sh ...
```

---

## 1. Automatiserad Miljöinstallation (`setup-all.sh`)

Skriptet `./scripts/setup-all.sh` utför en komplett miljöinstallation: laddar ner nödvändiga programvarupaket, orkestrerar containrar via Podman, väntar på databas- och ORDS-beredskap, kör databasmigreringar (Liquibase), installerar APEX med korrigeringsfiler och mäter stegen (Rule 1).

> 🏛️ **Modulär och Profildriven Arkitektur:**
> Skriptet `setup-all.sh` fungerar som **huvudorkestrerare** med CLI-gränssnitt, realtidsräknare (Rule 7), prestandamätningar (`metrics/`) och loggning (`install_logs/`), och delegerar domänspecifika uppgifter till modulära skript i `scripts/internal/`:
> - 📦 **Delat kärnbibliotek:** `common.sh` (färger, tidsformatering, framsteg, avbrottshantering, komprimering)
> - 📄 **Compose Override:** `generate-compose-override.sh` (dynamiska inställningar & hemligheter)
> - 📦 **Profiler & Topologi:** `load-profile.sh` & `resolve-topology.sh`
> - ⌛ **Hälsokontroll:** `wait-db-healthy.sh` (2-fas adaptiv kontroll och självläkning)
> - 🔌 **Instansinitiering:** `init-db-instance.sh`
> - 👤 **Användare & Roller:** `apply-profile-users.sh`
> - 🔒 **Certifikatförtroende:** `generate-local-certs.sh`
> - 💻 **VS Code-anslutningar:** `register-connections.sh`
> - 📊 **Rapporter & Mätvärden:** `generate-setup-report.sh`

> 📊 **Detaljerade arbetsflöden och arkitektoniska regler dokumenteras i: [docs/setup-all-workflow.md](../docs/setup-all-workflow.md)**

> [!IMPORTANT]
> **Reservmönster för SQLcl-container (Rule 4):** Före start kontrollerar skriptet automatiskt om **SQLcl** är installerat lokalt. Om det saknas växlar det automatiskt till att använda **SQLcl-containern** (`SQLCL_CONTAINER_IMAGE`). Detta gör att migreringar och APEX-installationer fungerar på rena maskiner utan lokal Java.

**Syntax:**
```bash
./scripts/setup-all.sh [-b <0-11>] [-tb <0-11|LIST|all>] [-lb] [-sb <0-11>] [--search <QUERY>] [--dry-run] [-ltr] [-i] [--force | -y] [--no-publisher] [--no-ords] [--no-monitor-app]
```

**Flaggor och Parametrar:**
*   **`-b <N>` / `--blueprint <N>`:** Produktions- och utvecklingsläge. Aktiverar exakt **en** vald arkitekturritning (0–11) och behåller befintlig databasdata (Idempotent / Ingen återställning).
*   **`-tb <LIST|all>` / `--test-blueprints`:** Automatiserat CI/CD-testläge. Kör automatiskt `reset-all.sh -y` före varje test för att säkerställa ren baslinje.
*   **`-lb` / `-l` / `--list-blueprints`:** Visar en dynamisk ASCII-översiktstabell över alla 12 ritningar utan att starta containrar.
*   **`-sb <N>` / `--show-blueprint <N>`:** Visar detaljerade specifikationer för ritning `<N>` (containrar, portar, RAM, TLS).
*   **`--search <QUERY>` / `--search-blueprints`:** Söker och filtrerar ritningar baserat på nyckelord.
*   **`--dry-run`:** Simulerar körningen utan att göra faktiska ändringar.
*   **`-ltr` / `--list-test-reports`:** Visar status för testrapporter i `tests/reports/blueprints/`.
*   **`-i` / `--select`:** Öppnar interaktiv meny med 30s nedräkningstimer.
*   **`--force` / `-y`:** Hoppar över bekräftelsefrågor (användbart för CI/CD).
*   **`--no-publisher`:** Startar inte Publisher-databasen (`db-publisher`) för att spara minne.
*   **`--from-snapshot`:** Återställer databasvolymer från en sparad ögonblicksbild före start (**snabbstart ~30s**).
*   **`--build-image`:** Sparar databasen som en förkonfigurerad containeravbildning efter installationen.
*   **`--parallel`:** Aktiverar parallell initiering av multi-DB och Publisher (kräver ledigt RAM $\ge$ 8 GB).
*   **`--sequential`:** Tvingar strikt sekventiell steg-för-steg installation (säkert standardläge).

**Exempelkommandon:**
```bash
# 1. PRODUKTION OCH VANLIG UTVECKLING:
./scripts/setup-all.sh -b 3             # Aktivera rekommenderad 2-nivåers produktionsritning
./scripts/setup-all.sh --blueprint 7    # Aktivera Full Enterprise 4-nivåers stack
./scripts/setup-all.sh -lb              # Visa tabell över alla 12 ritningar
./scripts/setup-all.sh -sb 3            # Visa detaljerad containerstruktur för ritning 3
./scripts/setup-all.sh -b 3 --dry-run   # Simulera start utan installation

# 2. AUTOMATISERAD TESTNING OCH CI/CD:
./scripts/setup-all.sh -tb 3            # Testa enskild ritning från grunden
./scripts/setup-all.sh -tb 1,5,8        # Testa sekvens av valda ritningar
./scripts/setup-all.sh -tb all          # Testa ALLA 12 ritningar i följd
./scripts/setup-all.sh -ltr             # Kontrollera testrapporternas status

# 3. Interaktiv installation:
./scripts/setup-all.sh
```

---

## 2. Starta Containrar (`start-containers.sh`)

Startar befintliga lokala databas- och ORDS-containrar och väntar tills databaserna uppnår status `healthy`.

```bash
./scripts/start-containers.sh [--no-ords] [--no-publisher]
```

---

## 3. Återställning av Miljö och Komponenter (`reset-all.sh`)

Modulär profilmedveten saneringsmotor som stoppar och tar bort containrar, profiler (`config/profiles/*.yaml`), volymer och nätverk.

**Syntax:**
```bash
./scripts/reset-all.sh [komponent] [--profile <profil>] [--logs | -l] [--force | -y] [--system]
```

**Exempel:**
```bash
./scripts/reset-all.sh all              # Fullständig återställning av miljö
./scripts/reset-all.sh all --logs --force # Återställning inklusive loggar utan bekräftelse
```

---

## 4. Hantering av Ögonblicksbilder (`scripts/snapshots/`)

```bash
./scripts/snapshots/create-golden-snapshots.sh
./scripts/snapshots/restore-golden-snapshots.sh --force
./scripts/snapshots/clean-golden-snapshots.sh
```

---

## 4.5. Loggsanering och Säkerhet (`clean-logs.sh` & `sanitize-logs.sh`)

```bash
./scripts/clean-logs.sh [-y | --force]
```
Alla skriptloggar filtreras automatiskt för att maskera hemligheter. För nödfelsökning:
```bash
DEBUG_LOG_UNSANITIZED=true ./scripts/setup-all.sh
```

---

## 5. CLI-Verktyg för Utvecklare och Administratörer

### 5.1. Läsa Lösenord från Wallet (`get-password.sh`)
```bash
./scripts/get-password.sh <ALIAS>
./scripts/get-password.sh DB_PROXY_DEV
./scripts/get-password.sh DB_PROXY_APEX_ADMIN
```

### 5.2. HTTP-Hälsokontroll för Webbtjänster (`check-urls.sh`)
```bash
./scripts/check-urls.sh
```

### 5.3. Diagnostik av SEPS-Anslutningar (`check-wallet.sh`)
```bash
./scripts/check-wallet.sh
```

### 5.4. Smart SQLcl CLI-Omslag (`sqlcl.sh`)
```bash
./scripts/sqlcl.sh /@DB_PROXY_DEV
./scripts/sqlcl.sh /@DB_PROXY_SYS as sysdba
```

### 5.5. Skapa Utvecklarkonto (`create-developer.sh`)
```bash
./scripts/create-developer.sh
```

### 5.6. Synkronisera VS Code-Anslutningar (`register-connections.sh`)
```bash
./scripts/register-connections.sh
```

---

## 6. Förtroende för Lokala Certifikat (`scripts/certs/`)

* 🍎 **macOS:** `./scripts/certs/trust-local-cert-mac.sh`
* 🪟 **Windows & WSL:** `scripts\certs\trust-local-cert.cmd` / `trust-local-cert.ps1`

---

## 7. Analytics Publisher Åtgärder (`scripts/publisher/`)

* `./scripts/publisher/status-publisher.sh`
* `./scripts/publisher/restart-publisher.sh`
* `./scripts/publisher/backup-publisher-catalog.sh`
* `./scripts/publisher/deploy-publisher-reports.sh`

---

## 8. Fjärrdriftsättning & Multi-Molntestning (`deploy-remote.sh`)

```bash
./scripts/deploy-remote.sh --host 20.123.45.67 --user azureuser --key ~/.ssh/id_rsa --blueprint 10
./tests/test-remote-multicloud.sh --dry-run
./tests/test-devhub-browser-blueprints.sh --all
```

---

## 9. Manuell Installation av Patchar (`scripts/internal/`)

* `./scripts/internal/apply-apex-patch.sh`
* `./scripts/internal/apply-publisher-patch.sh`

---

## 10. Interna Automationsmotorer (`scripts/internal/`)

Se detaljerad information i katalogen:
* 📁 **[`scripts/internal/README.sv.md`](internal/README.sv.md)**

---

## 11. Felsökning: Återställningsrutin för Podman Machine

Vid socket-fel eller timeout i containrar:

```bash
podman machine stop
podman machine start
./scripts/reset-all.sh --force
./scripts/setup-all.sh --force
```
