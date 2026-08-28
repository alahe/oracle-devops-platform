# 🛠️ CLI Skriptide ja Tööriistade Kasutusjuhend (Command Line Reference)

Käesolev fail sisaldab üksikasjalikku juhendit kõigi projekti haldus-, diagnostika- ja arendusskriptide kohta.

Kõik skriptid järgivad ranget **3-kihilist modulaarset arhitektuuri**, kus igapäevased arendaja CLI tööriistad asuvad `scripts/` juurkaustas ning spetsiifilised operatsioonid ja sisemised mootorid on jaotatud loogilistesse alamkataloogidesse.

---

## 📁 3-Kihiline Skriptide Kataloogi Struktuur

```text
scripts/
├── 🚀 KESKKONNA ELUTSÜKLI KÄSUD:
│   ├── setup-all.sh                 # Kogu keskkonna paigaldus (Blueprints 1-13 & CLI)
│   ├── reset-all.sh                 # Keskkonna, voluumide ja andmete täielik/osaline puhastus
│   ├── start-containers.sh          # Seisatud konteinerite käivitamine / jätkamine
│   ├── deploy-remote.sh             # Kaugpaigaldus pilve ja sihtkeskkondadesse
│   └── test-local-ci.sh             # GitHub Actions kohalik CI/CD simulaator
│
├── 🔑 ARENDAJA JA ADMINISTRAATORI CLI TÖÖRIISTAD:
│   ├── get-password.sh              # Paroolide ja kasutajatunnuste lugemine Walletist
│   ├── check-urls.sh                # Veebiteenuste, basseinide ja URL-ide HTTP tervisekontroll
│   ├── check-wallet.sh              # SEPS Walleti paroolivabade TNS ühenduste diagnostika
│   ├── sqlcl.sh                     # Nutikas SQLcl CLI wrapper (SEPS Wallet /@ALIAS toega)
│   ├── create-developer.sh          # Arendajakontode loomine ja paroolide taastamine
│   ├── register-connections.sh      # VS Code Oracle SQL Developer ühenduste sünkroniseerimine
│   ├── publish-image-to-artifactory.sh # Piltide avaldamine ettevõtte Artifactorysse & .env seadistus
│   └── clean-logs.sh                # Paigalduslogide ja ajutiste failide puhastus
│
├── 📁 snapshots/                    # 📸 Andmebaasi hetktõmmiste (Golden Snapshots) haldus
│   ├── create-golden-snapshots.sh   # Loob andmebaasi mahutist tihendatud .tar.gz arhiivi
│   ├── restore-golden-snapshots.sh  # Taastab andmebaasi kiiresti viimasesse tuntud seisu
│   └── clean-golden-snapshots.sh    # Puhastab vanad arhiivid, jättes alles viimase koopia
│
├── 📁 certs/                        # 🛡️ Kohalike SSL/TLS sertifikaatide usaldamine
│   ├── trust-local-cert-mac.sh      # macOS Keychain usaldusskript (0-Root)
│   ├── trust-local-cert.cmd / .ps1  # Windows Certificate Store usaldusskriptid (0-Admin)
│   └── untrust-local-cert-mac.sh    # Sertifikaatide eemaldamine
│
├── 📁 publisher/                    # 📑 Analytics Publisheri haldus ja operatsioonid
│   ├── status-publisher.sh          # Publisheri ja WebLogic serveri staatus
│   ├── restart-publisher.sh         # Publisheri teenuse taaskäivitamine
│   ├── backup-publisher-catalog.sh  # Aruannete kataloogi eksport ja varundus
│   └── deploy-publisher-reports.sh  # Aruannete import ja Git sünkroniseerimine
│
├── 📁 forms/                        # 📐 Oracle Forms 14c haldus ja operatsioonid
│   ├── status-forms.sh              # Forms Runtime ja WebLogic serveri diagnostika
│   ├── restart-forms.sh             # Forms konteineri taaskäivitamine
│   └── deploy-forms-apps.sh         # .fmx rakenduste tarne kausta /u01/oracle/forms_apps
│
├── 📁 patches/                      # 🩹 Patchide käsitsi rakendamise mootorid
│   ├── apply-apex-patch.sh          # Oracle APEX PSE / Bundle patchi paigaldaja
│   └── apply-publisher-patch.sh     # Analytics Publisheri OPatch paigaldaja
│
└── 📁 internal/                     # ⚙️ Mitte-interaktiivsed sisemised automaatikamootorid
    ├── common.sh, load-profile.sh, generate-compose-override.sh, create-wallet.sh ...
```

---

## 1. Keskkonna automaatne paigaldus (`setup-all.sh`)

Skript `./scripts/setup-all.sh` teostab kogu keskkonna täieliku paigalduse: laeb alla vajaliku tarkvara, orkestreerib konteinerid, ootab andmebaaside ja ORDS-i valmisolekut, käivitab andmebaasi skeemi migratsioonid (Liquibase), paigaldab APEX-i koos bundle patchiga ning mõõdab iga sammu kestust.

> 🏛️ **Modulaarne & Profiilipõhine Arhitektuur:**
> Skript `setup-all.sh` on ehitatud **peamise orkestreerijana**, mis koondab interaktiivse CLI liidese, sammude mõõtmise (Reegel 1) ja logimise (`install_logs/`), delegeerides kõik spetsiifilised alamprotsessid modulaarsetele abiskriptidele kaustas `scripts/internal/`:
> - 📦 **Ühine abiteek:** `common.sh` (värvid, mõõdikud, progress, trap-cleanup, pakkimine)
> - 📄 **Compose Override:** `generate-compose-override.sh` (dünaamiline override ja saladuste haldus)
> - 📦 **Profiilid & Topoloogia:** `load-profile.sh` (single-pass YAML parsimine & vahemälustamine) & `resolve-topology.sh`
> - ⌛ **Tervisekontroll:** `wait-db-healthy.sh` (2-etapiline adaptiivne healthcheck ja iseparanemine)
> - 🔌 **Instantsi algseadistus:** `init-db-instance.sh`
> - 👤 **Kasutajad & Rollid:** `apply-profile-users.sh`
> - 🔒 **Sertifikaatide usaldamine:** `generate-local-certs.sh`
> - 💻 **VS Code ühendused:** `register-connections.sh`
> - 📊 **Raportid & Mõõdikud:** `generate-setup-report.sh` (JSON benchmarkid ja stsenaariumite raportid)

> 📊 **Paigaldusprotsessi detailne voodiagramm ja arhitektuursed sammud (idempotentsus, SQLcl fallback, Microsoft Defenderi optimeerimine) on kirjeldatud eraldi dokumendis: [docs/setup-all-workflow.md](../docs/setup-all-workflow.md)**

> [!IMPORTANT]
> **Tarkvara nõue (SQLcl container fallback):** Enne paigalduse algust kontrollib skript automaatselt, kas süsteemis on paigaldatud **SQLcl** lokaalne klient (või VS Code laienduse sees olev versioon). Kui utiliiti ei leita, lülitub paigaldus automaatselt ümber **SQLcl konteineri** kasutamisele (`SQLCL_CONTAINER_IMAGE`). See võimaldab andmebaasi migratsioonide ja APEX rakenduste paigaldust ka täiesti puhtas masinas ilma kohaliku Javal/SQLcl-ita.



**Süntaks:**
```bash
./scripts/setup-all.sh [-b <1-13>] [-tb <1-13|LIST|all>] [-lb] [-sb <1-13>] [--search <QUERY>] [--dry-run] [-ltr] [-i] [--force | -y] [--no-publisher] [--no-ords] [--no-monitor-app]
```

**Parameetrite valikud:**
*   **`-b <N>` / `--blueprint <N>`:** Toodangu ja tavaarenduse režiim. Aktiveerib täpselt **ühe** valitud blueprinti (1–13) ja jätkab olemasoleva baasi pealt (No-Reset / Säilitab andmed).
*   **`-tb <LIST|all>` / `--test-blueprints`:** Automaattestimise ja CI/CD režiim. Teeb enne iga testi `reset-all.sh -y` puhta algseisu tagamiseks ja testib valitud blueprinti, komaga eraldatud nimekirja (`-tb 1,5,8`) või kõiki (`-tb all`).
*   **`-lb` / `-l` / `--list-blueprints`:** Kuvab kõigi 13 toetatud blueprinti dünaamilise ASCII ülevaatetabeli ilma midagi käivitamata.
*   **`-sb <N>` / `--show-blueprint <N>`:** Kuvab valitud blueprinti `<N>` detailse ülevaate (plaanitavad konteinerid, pordid, APEX/ORDS seaded, RAM eelarve ja TLS nõuded).
*   **`--search <QUERY>` / `--search-blueprints`:** Otsib ja filtreerib blueprinte märksõna järgi (nt `publisher`, `gvenzl`, `adb`, `web-ide`).
*   **`--dry-run`:** Simuleerib käivitust ja kontrollib konfiguratsioone ilma tegelikku paigaldust tegemata (töötab nii `-b <N> --dry-run` kui ka `-tb 1,3,7 --dry-run` režiimis).
*   **`-ltr` / `--list-test-reports`:** Kuvab kõigi 13 blueprinti testiaruannete (scenario reports) olekut kaustas `tests/reports/scenarios/`.
*   **`-i` / `--select`:** Avab terminalis interaktiivse valikumenüü koos 30s taimeriga.
*   `--force` / `-y`: Jätab vahele paigalduseelse kinnituse ja kettaruumi kontrolli küsimused (sobib automaattestideks ja CI/CD tööriistadele).
*   `--no-publisher`: Jätab lokaalse Publisher andmebaasi (`db-publisher`) käivitamata ja seadistamata (säästab mälu).
*   **`--from-snapshot` (TASK-018):** Taastab andmebaasi andmemahud enne käivitust eelnevalt salvestatud Golden Snapshotist (**kiirkäivitus ~30s**).
*   **`--build-image`:** Salvestab andmebaasi pärast edukat paigaldust automaatselt kanooniliseks eelkonfigureeritud konteineripildiks (`localhost/oracle-free-apex:<TAG>`). Kui pilt on juba olemas, jäetakse loomine vahele.
*   **`--parallel` (TASK-019):** Lubab multi-DB ja Publisheri paralleelse initsialiseerimise (eeldab vaba RAM $\ge$ 8 GB).
*   **`--sequential` (TASK-019):** Sunnib range järjestikuse samm-sammulise paigalduse (vaikimisi turvaline režiim).

**Näidiskäsud:**
```bash
# 1. TOODANG JA TAVAARENDUS (Idempotentne / Säilitab Andmed):
./scripts/setup-all.sh -b 3             # Aktiveeri soovitatud 2-kihiline tootmisblueprint
./scripts/setup-all.sh --blueprint 7    # Aktiveeri Full Enterprise 4-kihiline stack
./scripts/setup-all.sh -lb              # Vaata kõigi 13 blueprinti tabelit
./scripts/setup-all.sh -sb 3            # Vaata blueprinti 3 detailset puud ja konteinereid
./scripts/setup-all.sh --search pub     # Otsi Publisheriga seotud kavandeid
./scripts/setup-all.sh -b 3 --dry-run   # Simuleeri käivitust ilma paigalduseta

# 2. AUTOMAATTESTIMINE JA CI/CD (Puhas Algseis koos reset-all.sh -y):
./scripts/setup-all.sh -tb 3            # Testi üksikut blueprinti puhtalt lehelt
./scripts/setup-all.sh -tb 1,5,8,10     # Testi valitud blueprintide jada
./scripts/setup-all.sh -tb all          # Testi KÕIKI 13 blueprinti järjest
./scripts/setup-all.sh -tb 1,3,7 --dry-run # Simuleeri ja valideeri teste paari sekundiga
./scripts/setup-all.sh -ltr             # Vaata kõigi testiraportite olekut

# 3. Interaktiivne täispaigaldus:
./scripts/setup-all.sh
```

### 💡 Automaatne APEX ja ORDS tarkvarapakettide puhverdamine (`binaries/`)
Skript `setup-all.sh` järgib tarkvarapakettide hankimisel nutikat lokaalse puhverdamise strateegiat:
1. **ORDS pakett (`binaries/ords/`):** Kontrollitakse esmalt, kas kaustas `binaries/ords/` on olemas zip-fail (nt `ords-latest.zip`). Kui fail on olemas, kasutatakse seda otse. Kui fail puudub, laetakse vajalik versioon alla aktiivse YAML profiili parameetrist `PROFILE_ORDS_DOWNLOAD_URL` ja salvestatakse kausta `binaries/ords/`.
2. **APEX pakett (`binaries/apex/`):** Tuvastatakse andmebaasi profiili nõutud APEX versioon. Kontrollitakse esmalt kausta `binaries/apex/` (nt `apex-latest.zip`, `apex_26.1_en.zip`, `apex_24.2.zip`). Kui sobilik zip-fail on lokaalselt olemas, kasutatakse seda; vastasel juhul laetakse see profiili URL-ilt alla kausta `binaries/apex/`.
3. Markerfaili `apex/.unzipped_source` abil jälgitakse, et vajadusel pakitaks lahti just uue versiooni failid.

### 🚀 Kiire paigaldus ja viirusetõrje (Microsoft Defender) optimeerimine
Ettevõtte keskkondades, kus host-masinas töötab range viirusetõrjetarkvara (nt Microsoft Defender), võib tuhandete väikeste APEX-i paigaldusfailide lahtipakkimine ja lugemine host-süsteemi kettalt võtta väga kaua aega.
* **Automaatne tuvastus:** Kui andmebaas töötab kohalikus konteineris (`oracle-db-apex-proxy`), ei pakita APEX-i mootorit ega patchide `.zip` faile enam host-masinas lahti.
* **Konteineri-sisene teostus:** Skript kopeerib ühe zip-failina andmed otse andmebaasi konteinerisse, pakib failid lahti konteineri isoleeritud failisüsteemis (`/tmp/`) ning teostab paigalduse sealt. Viirusetõrje ei pääse konteineri siseseid faile skaneerima ja paigaldus on kordades kiirem!
* **Staatilised failid (Volume-põhine lahendus):** Pärast andmebaasi paigaldust kopeeritakse staatilised veebiressursid konteineri sees otse nimetatud volume-isse (`apex_images` ➡️ `/opt/oracle/apex_images/images/`), mida lokaalne ORDS-i konteiner kasutab. Kuna failid ei puuduta kordagi hosti ketast, on paigaldus ülikiire ja hosti viirusetõrje ei kontrolli neid.

---

### 🔌 Intelligentne kohalike konteinerite käivitamine
Skriptid `./scripts/setup-all.sh` ja `./scripts/start-containers.sh` loevad konfiguratsiooni ja käituvad dünaamiliselt:
* **Publisher DB:** Kui `PUBLISHER_DB_HOST` on seadistustest välja kommenteeritud või tühi, loetakse see automaatselt väljalülitatuks (`--no-publisher`). Kui hostinimi on suunatud välisele serverile (pole `localhost` ega `127.0.0.1`), siis kohalikku `oracle-db-publisher` konteinerit käima ei tõmmata, kuid skript saab ühenduda välise baasiga.
* **ORDS:** Kui `ORDS_URL` või `ORDS_HTTP_PORT` on välja kommenteeritud, lülitub ORDS-i käivitamine ja ootamine automaatselt välja (`--no-ords`).

---

## 2. Konteinerite käivitamine (`start-containers.sh`)

Skript `./scripts/start-containers.sh` käivitab lokaalsed andmebaasi ja ORDS-i konteinerid ning ootab, kuni andmebaasid saavutavad `healthy` oleku.

**Süntaks:**
```bash
./scripts/start-containers.sh [--no-ords] [--no-publisher]
```

**Parameetrid:**
- `--no-ords`: Jätab ORDS-i konteineri käivitamata (käivitab ainult andmebaasid).
- `--no-publisher`: Jätab Publisher andmebaasi käivitamata (käivitab ainult APEX Proxy ja ORDS-i).

**Näidiskäsud:**
```bash
# Kõikide lokaalsete konteinerite käivitamine:
./scripts/start-containers.sh

# Ainult andmebaaside käivitamine (ilma ORDS-ita):
./scripts/start-containers.sh --no-ords

# APEX Proxy ja ORDS käivitamine ilma Publisher andmebaasita:
./scripts/start-containers.sh --no-publisher
```

---

## 3. Keskkonna või komponentide kustutamine (`reset-all.sh`)

Skript `./scripts/reset-all.sh` on **modulaarne profiilipõhine puhastaja**, mis peatab ja kustutab valitud komponendid, profiilid (`config/profiles/*.yaml`), persistentse salvestusruumi (volumes) ja võrgud.

> 🏛️ **Profiilipõhine Puhastusmootor:**
> Skript `reset-all.sh` kaasab profiililaaduri `load-profile.sh` ning tagab, et profiili vahetamisel (nt 23c -> ADB 19c) puhastatakse automaatselt kõik selle profiiliga seotud andmemahud (`apex_proxy_oradata`, `apex_proxy_data`, `publisher_oradata`, `apex_images`), vältides andmete ristsaastumist ja `ORA-65156` konflikte.

**Süntaks:**
```bash
./scripts/reset-all.sh [komponent] [--profile <profiil>] [--logs | -l] [--force | -y] [--system]
```

**Komponentide valikud:**
- `all` (Vaikimisi): Peatab ja kustutab kõik komponendid (APEX Proxy, Publisher, ORDS) koos volumite ja võrkudega.
- `db-apex-proxy`: Kustutab ainult APEX Proxy andmebaasi konteineri ja selle persistentse volume.
- `db-publisher`: Kustutab ainult Publisher andmebaasi konteineri ja selle persistentse volume.
- `ords`: Kustutab ainult lokaalse ORDS teenuse konteineri.

**Lisalipud (Flags):**
- `--logs` / `-l`: Puhastab lisaks konteineritele ja andmetele ka paigalduslogid (`install_logs/*.log`), lahtipakitud kataloogid (`unzipped_log*`) ning diagnostika-arhiivid (`clean-logs.sh`). Interaktiivses režiimis (ilma `-y` liputa) küsitakse logide puhastamise kohta lisaküsimus.
- `--profile <nimi>`: Määra täpne profiili nimi puhastamiseks (vaikimisi võetakse `.env` muutujast `MAIN_DB_PROFILE`, nt `proxy-adb-oracle` või `bizapp-standard-oracle`).
- `--force` / `-y`: Jätab turvaküsimuse vahele ja teostab operatsiooni otse (kasulik CI/CD runneri või automaatsete testide jaoks).
- `--system`: Teostab kogu kohaliku Podman süsteemi täieliku süvapuhastuse (prune). Kustutab kõik konteinerid, pildid ja volumid, et vabastada kettaruumi (küsib täiendava kinnitussõna 'JAH').

**Näidiskäsud:**
```bash
# Kogu lokaalse arenduskeskkonna täielik kustutamine:
./scripts/reset-all.sh all

# Kogu keskkonna ja paigalduslogide puhastamine korraga:
./scripts/reset-all.sh all --logs --force

# Kustuta spetsiifilise profiili baas ja volumid ilma kinnituseta:
./scripts/reset-all.sh all --profile proxy-adb-oracle --force

# Ainult APEX Proxy DB ja selle volume kustutamine ilma kinnituseta:
./scripts/reset-all.sh db-apex-proxy --force

# Ainult Publisher DB kustutamine:
./scripts/reset-all.sh db-publisher

# Ainult ORDS teenuse peatamine ja kustutamine:
./scripts/reset-all.sh ords

# Podman VM-i taaskäivitamine ja süsteemi täielik tühjendamine (kettaruumi vabastamiseks):
./scripts/reset-all.sh --system
```

---

## 4. Hetktõmmise (Golden Snapshot) loomine ja taastamine (`create-golden-snapshots.sh` & `restore-golden-snapshots.sh`)

Kui keskkond on edukalt üles seatud ja soovime teha andmebaasi andmetest kiire koopia (näiteks enne testimist või ohtlikke muudatusi), saame kasutada volumite külma varundust (hetktõmmist), mis võtab aega alla minuti.

### Hetktõmmise loomine (`create-golden-snapshots.sh`)
Peatab ajutiselt konteinerid, loob andmebaasi volumist tihendatud arhiivi `golden-snapshots/apex_proxy_oradata_${TIMESTAMP}.tar.gz` ja taaskäivitab konteinerid.

```bash
./scripts/create-golden-snapshots.sh
```

### Taastamine (`restore-golden-snapshots.sh`)
Peatab konteinerid, kustutab praeguse vigase volume, loob uue tühja volume, pakib valitud arhiivi sinna lahti ning käivitab konteinerid uuesti.

**Süntaks:**
```bash
./scripts/restore-golden-snapshots.sh [failinimi.tar.gz] [--force | -y]
```

**Parameetrid:**
- `[failinimi.tar.gz]` (Valikuline): Konkreetse arhiivi nimi, mida soovid taastada. Kui parameetrit ei edastata ja `--force` pole lisatud, kuvatakse interaktiivne menüü kõikide olemasolevate hetktõmmistega (kust saab valida numbriga).
- `--force` / `-y`: Taastab automaatselt kõige värskema hetktõmmise ilma interaktiivset valikumenüüd kuvamata ja kinnitust küsimata.

**Näidiskäsud:**
```bash
# Interaktiivne taastamine (kuvab nimekirja ja laseb valida):
./scripts/restore-golden-snapshots.sh

# Automaatne taastamine kõige viimasest (viimati loodud) hetktõmmisest:
./scripts/restore-golden-snapshots.sh --force

# Taastamine konkreetsest hetktõmmise failist:
./scripts/restore-golden-snapshots.sh apex_proxy_oradata_20260807_123456.tar.gz
```

---

## 4.5. Logifailide ja Diagnostika Puhastamine (`clean-logs.sh`)

Selleks, et lokaalne kettaruum ei täituks paigalduste ja taastamiste ajal tekkivate mahukate logifailide ega WebLogic/Publisheri diagnostika-arhiividega, saab kasutada logide puhastamise skripti.

**Süntaks:**
```bash
./scripts/clean-logs.sh [-y | --force]
```

**Toimimine ja kustutatavad failid:**
*   **Paigalduslogid:** Kustutab kõik ajatempliga logifailid kaustast `install_logs/*.log`.
*   **Lahtipakitud logikataloogid:** Eemaldab automaatselt kõik ajutised `unzipped_log*` kataloogid koos sisuga.
*   **BI Publisheri diagnostika-arhiivid:** Eemaldab WebLogic / Analytics Publisheri Configuration Assistant-i poolt loodud `bieeconfiglogs*.zip` diagnostikapakid.
*   **Automaatrežiim:** Käivituslipuga `-y` või `--force` teostatakse puhastus interaktiivseid küsimusi esitamata.

---

## 4.5.1. Logide Saniteerimine & Turvalisus (`sanitize-logs.sh`)

Selleks, et vältida tundlike paroolide, `ACCESS_TOKEN`, `token=...`, `Authorization: Bearer ...`, `ARTIFACTORY_TOKEN` ja `GITHUB_TOKEN` sattumist versioonihaldusesse või lokaalsetesse logidesse (`install_logs/*.log`), filteeritakse kõigi skriptide stdout/stderr logivoog automaatselt läbi abiskripti `scripts/internal/sanitize-logs.sh`.

> ⚠️ **Tõrkeotsing & Erandkorras unmasking:**
> Kui tõrkeotsinguks või silumiseks (debug) on **hädavajalik** näha logides avatud žetoone või Bearer päringupäiseid, saab maskingut erandkorras ajutiselt välja lülitada keskkonnamuutujaga:
> ```bash
> DEBUG_LOG_UNSANITIZED=true ./scripts/setup-all.sh
> ```
> *Märkus: Seda võimalust tohib kasutada AINULT erandkorras ja turvalises kohalikus keskkonnas.*
## 4. Arendaja ja Administraatori Igapäevased CLI Tööriistad

### 4.1. Paroolide ja Kasutajatunnuste Lugemine Walletist (`get-password.sh`)
Selleks, et mitte hoida paroole avatud tekstina konsoolis, failides või protsessitabelis (`ps aux`), kasutatakse paroolivaba **Oracle Walletit (SEPS)**. Arendaja saab mis tahes süsteemi või skeemi parooli turvaliselt kätte käsuga:

```bash
# Üldine süntaks:
./scripts/get-password.sh <ALIAS>

# Näited:
./scripts/get-password.sh DB_PROXY_DEV          # Proxy DB arendaja parool
./scripts/get-password.sh DB_PROXY_APEX_ADMIN    # APEX INTERNAL admin parool
./scripts/get-password.sh DB_PROXY_SYS           # Proxy DB SYS administraatori parool
./scripts/get-password.sh DB_LIS_DEV             # LIS DB arendaja parool
./scripts/get-password.sh DB_PUBLISHER_DEV       # Analytics Publisheri administraatori parool
```

---

### 4.2. Veebiteenuste ja URL-ide HTTP Tervisekontroll (`check-urls.sh`)
Teostab reaalajas HTTP/HTTPS GET päringuid kõigile aktiivsetele ORDS basseinidele, APEX liidestele, Database Actions portaalile ja Web IDE-le, kontrollides vastuskoodide (HTTP 200/302) ja TLS sertifikaatide kehtivust:

```bash
# Kontrolli kõiki aktiivseid veebiteenuseid:
./scripts/check-urls.sh

# Kohandatud katsete arv ja ooteaeg (nt 10 katset 2s vahega):
./scripts/check-urls.sh 10 2
```

---

### 4.3. SEPS Walleti Paroolivabade Ühenduste Diagnostika (`check-wallet.sh`)
Kontrollib kõiki registreeritud TNS aliaseid (`/@ALIAS`), teostades SQLcl kaudu paroolivaba päringu `SELECT status FROM v$instance` ja tagades, et SEPS autologin toimib 100%:

```bash
./scripts/check-wallet.sh
```

---

### 4.4. Nutikas SQLcl Käsurea Wrapper (`sqlcl.sh`)
Võimaldab luua koheseid SQLcl konsooliühendusi otse terminalist ilma parooli sisestamata:

```bash
# Logi sisse arendajana:
./scripts/sqlcl.sh /@DB_PROXY_DEV

# Logi sisse SYSDBA administraatorina:
./scripts/sqlcl.sh /@DB_PROXY_SYS as sysdba

# Käivita SQL fail:
./scripts/sqlcl.sh /@DB_PROXY_DEV @minu_skript.sql
```

**Omadused:**
*   **Automaatne tuvastus:** Eelistab VS Code Oracle SQL Developer laienduse SQLcl-i ja Java 21 mootorit.
*   **Zero-Install Fallback:** Kui masinas puudub kohalik Java/SQLcl, käivitab ajutise Podman SQLcl konteineri (`podman run --rm`).

---

### 4.5. Arendaja Kasutajakonto Loomine (`create-developer.sh`)
Loob personaalse arendajakonto (nii andmebaasi kui APEX-i poolel) ning genereerib automaatselt tugeva parooli SEPS Walletisse:

```bash
./scripts/create-developer.sh
```

---

### 4.6. VS Code SQL Developer Ühenduste Sünkroniseerimine (`register-connections.sh`)
Loob ja sünkroniseerib VS Code Oracle SQL Developer laienduse ühenduste puu koos salvestatud paroolidega:

```bash
./scripts/register-connections.sh
```

---

### 4.7. Logide ja Ajutiste Failide Puhastus (`clean-logs.sh`)
Kustutab `install_logs/*.log` failid ja ajutised lahtipakkimiskaustad:

```bash
./scripts/clean-logs.sh [-y | --force]
```

---

## 5. Andmebaasi Hetktõmmiste (Golden Snapshots) Haldus (`scripts/snapshots/`)

Kõik andmebaasi mahutite varundamise ja taastamise käsud asuvad kaustas `scripts/snapshots/`:

### 5.1. Hetktõmmise loomine (`create-golden-snapshots.sh`)
Peatab konteinerid ja loob andmebaasi mahutist tihendatud `.tar.gz` arhiivi kausta `golden-snapshots/`:
```bash
./scripts/snapshots/create-golden-snapshots.sh
```

### 5.2. Hetktõmmisest taastamine (`restore-golden-snapshots.sh`)
Taastab andmebaasi seisu alla 1 minutiga viimasesse tuntud-töötavasse olekusse:
```bash
# Taasta viimane hetktõmmis (latest):
./scripts/snapshots/restore-golden-snapshots.sh

# Taasta konkreetne arhiiv:
./scripts/snapshots/restore-golden-snapshots.sh apex_proxy_oradata_20260827_120000.tar.gz
```

### 5.3. Vanade hetktõmmiste puhastamine (`clean-golden-snapshots.sh`)
Kustutab vanad arhiivid, jättes alati alles viimase `_latest.tar.gz` koopia:
```bash
./scripts/snapshots/clean-golden-snapshots.sh
```

---

## 6. Kohalike Sertifikaatide Usaldamine (`scripts/certs/`)

Kohalikud SSL/TLS juursertifikaadid genereeritakse automaatselt paigalduse ajal. Vajadusel saab neid käsitsi usaldada või eemaldada:

*   🍎 **macOS (0-Root):**
    *   👉 `./scripts/certs/trust-local-cert-mac.sh` (Lisab sertifikaadi kasutaja `login.keychain-db` hoidlasse ilma `sudo`-ta)
    *   👉 `./scripts/certs/untrust-local-cert-mac.sh` (Eemaldab sertifikaadi)
*   🪟 **Windows & WSL (0-Admin):**
    *   👉 `scripts\certs\trust-local-cert.cmd` (Topeltklõpsatav CMD Batch fail)
    *   👉 `scripts\certs\trust-local-cert.ps1` (PowerShell skript)
    *   👉 `scripts\certs\untrust-local-cert.cmd` (Sertifikaadi eemaldamine)

---

## 7. Analytics Publisheri Haldus (`scripts/publisher/`)

Kõik Oracle Analytics Publisheri (Pixel Perfect) operatsioonid:

*   📊 **Staatuse kontroll:** `./scripts/publisher/status-publisher.sh`
*   🔄 **Teenuse taaskäivitamine:** `./scripts/publisher/restart-publisher.sh`
*   📦 **Aruannete varundus:** `./scripts/publisher/backup-publisher-catalog.sh`
*   🚀 **Aruannete tarne (Deploy):** `./scripts/publisher/deploy-publisher-reports.sh`

---

## 8. Patchide Käsitsi Rakendamine (`scripts/patches/`)

*   🩹 **APEX Patch Set Exception (PSE) paigaldus:** `./scripts/patches/apply-apex-patch.sh`
*   🩹 **Analytics Publisher OPatch paigaldus:** `./scripts/patches/apply-publisher-patch.sh`

---

## 9. Sisemised Abiskriptid (`scripts/internal/`)

Kõik sisemised paigaldus-, profiili-, SQL- ja abiskriptid asuvad alamkataloogis `scripts/internal/`:
*   📁 **[`scripts/internal/README.md`](internal/README.md)** (Profiilimootor, SEPS Walletid, sisemised SQL failid ja paigaldusmootorid).

---

## 10. Veaotsing: Millal teostada Podman Machine taaskäivitus? (`podman machine stop && podman machine start`)

Kui arenduskeskkonnas või terminalis tekivad järgmised sümptomid:
1. Käsk `./scripts/setup-all.sh` annab vea: `❌ Viga: Konteiner db-dev-full ei saavutanud 'healthy' olekut 450 sekundi jooksul!`.
2. Podman käsud hanguvad või tagastavad pesa vea: `Error: Get ".../containers/json": EOF`.
3. Konteiner hangub taaskäivitussilmuses veaga `ORA-01078 / LRM-00109: could not open parameter file`.

### Veaotsingu sammud (Recovery Runbook):

```bash
# 1. Peata ja käivita macOS / Linux Podman virtuaalmasina pesa uuesti:
podman machine stop
podman machine start

# 2. Puhasta poolelijäänud / katkised mahud ja konteinerid:
./scripts/reset-all.sh --force

# 3. Käivita keskkonna paigaldus puhtalt uuesti:
./scripts/setup-all.sh --force
```


