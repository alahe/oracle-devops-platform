[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🛠️ CLI-Komentosarjat ja Kehittäjätyökalujen Käsikirja

Tämä opas tarjoaa kattavan dokumentaation kaikille projektin elinkaari-, diagnostiikka-, hallinta- ja kehittäjäskripteille.

Kaikki komentosarjat noudattavat tiukkaa **3-tasoista modulaarista hakemistorakennetta** (Rule 3), jossa päivittäiset kehittäjän CLI-työkalut sijaitsevat hakemiston `scripts/` juuressa ja erikoistuneet osaprosessit sekä sisäiset moottorit on eroteltu omiin alihakemistoihinsa.

---

## 📁 3-Tasoinen Komentosarjojen Hakemistorakenne

```text
scripts/
├── 🚀 YMPÄRISTÖN ELINKAAREN KOMENNOT:
│   ├── setup-all.sh                 # Koko ympäristön asennus (Suunnitelmat 0-11 & CLI)
│   ├── reset-all.sh                 # Ympäristön, volyymien ja verkkojen nollaus
│   ├── start-containers.sh          # Pysäytettyjen säilöjen käynnistys / jatkaminen
│   ├── deploy-remote.sh             # Etäkäyttöönotto pilveen ja kohdekoneisiin
│   └── test-local-ci.sh             # Paikallinen GitHub Actions CI/CD -simulaattori
│
├── 🔑 KEHITTÄJÄN JA YLLÄPITÄJÄN CLI-TYÖKALUT:
│   ├── get-password.sh              # Salasanojen ja käyttäjätunnusten luku Walletista
│   ├── check-urls.sh                # Verkkopalveluiden, altaiden ja URL-osoitteiden HTTP-tarkistus
│   ├── check-wallet.sh              # SEPS Walletin salasanattomien TNS-yhteyksien diagnostiikka
│   ├── sqlcl.sh                     # Älykäs SQLcl CLI -kääre (SEPS Wallet /@ALIAS -tuki)
│   ├── create-developer.sh          # Kehittäjätunnusten luonti ja salasanojen palautus
│   ├── register-connections.sh      # VS Code Oracle SQL Developer -yhteyksien synkronointi
│   ├── publish-image-to-artifactory.sh # Kuvien julkaisu Artifactoryyn & .env-määritys
│   └── clean-logs.sh                # Asennuslokien ja väliaikaistiedostojen siivous
│
├── 📁 snapshots/                    # 📸 Tilannevedosten (Golden Snapshots) hallinta (~15s toipuminen)
│   ├── create-golden-snapshots.sh   # Luo pakatun .tar.gz-arkiston tietokantavolyymeistä
│   ├── restore-golden-snapshots.sh  # Palauttaa tietokannan viimeisimpään tunnettuun tilaan
│   └── clean-golden-snapshots.sh    # Siivoaa vanhat arkistot säilyttäen uusimman
│
├── 📁 certs/                        # 🛡️ Paikallisten SSL/TLS-sertifikaattien luottamus (Zero-Admin / Non-Root)
│   ├── trust-local-cert-mac.sh      # macOS Avainnipun luottamusasennus (0-Root)
│   ├── trust-local-cert.cmd / .ps1  # Windows Sertifikaattisäilön luottamusskriptit (0-Admin)
│   └── untrust-local-cert-mac.sh    # Sertifikaattien poistotyökalut
│
├── 📁 publisher/                    # 📑 Analytics Publisherin hallinta ja toiminnot
│   ├── status-publisher.sh          # Publisher-palvelun ja WebLogic-palvelimen tila
│   ├── restart-publisher.sh         # Publisher-säilön siisti uudelleenkäynnistys
│   ├── backup-publisher-catalog.sh  # Raporttiluettelon vienti ja varmuuskopiointi
│   └── deploy-publisher-reports.sh  # Raporttien tuonti ja Git-synkronointi
│
├── 📁 forms/                        # 📐 Oracle Forms 14c hallinta ja toiminnot
│   ├── status-forms.sh              # Forms Runtime ja WebLogic -diagnostiikka
│   ├── restart-forms.sh             # Forms-säilön siisti uudelleenkäynnistys
│   └── deploy-forms-apps.sh         # .fmx-sovellusten toimitus kansioon /u01/oracle/forms_apps
│
└── 📁 internal/                     # ⚙️ Ei-interaktiiviset sisäiset automaatiomoottorit
    ├── common.sh, load-profile.sh, generate-compose-override.sh, create-wallet.sh ...
```

---

## 1. Ympäristön Automaattinen Asennus (`setup-all.sh`)

Komentosarja `./scripts/setup-all.sh` suorittaa koko ympäristön täydellisen asennuksen: lataa ohjelmistopaketit, orkestroi säilöt, odottaa tietokantojen ja ORDS:n valmiutta, suorittaa skeeman migraatiot (Liquibase), asentaa APEX:n päivityksineen ja mittaa kunkin vaiheen keston (Rule 1).

> 🏛️ **Modulaarinen ja Profiilipohjainen Arkkitehtuuri:**
> Komentosarja `setup-all.sh` toimii **pääorkestroijana**, joka hallinnoi CLI-käyttöliittymää, reaaliaikaisia ajastimia (Rule 7), suorituskykymittauksia (`metrics/`) ja lokitusta (`install_logs/`), delegoiden erikoistehtävät hakemiston `scripts/internal/` moottoreille:
> - 📦 **Yhteinen ysinkirjasto:** `common.sh` (värit, kesto, edistyminen, siivous, pakkaus)
> - 📄 **Compose Override:** `generate-compose-override.sh` (dynaamiset ohitukset & salaisuudet)
> - 📦 **Profiilit & Topologia:** `load-profile.sh` & `resolve-topology.sh`
> - ⌛ **Terveystarkistus:** `wait-db-healthy.sh` (2-vaiheinen mukautuva tarkistus ja itseparannus)
> - 🔌 **Ilmentymän Alustus:** `init-db-instance.sh`
> - 👤 **Käyttäjät & Roolit:** `apply-profile-users.sh`
> - 🔒 **Sertifikaattien Luottamus:** `generate-local-certs.sh`
> - 💻 **VS Code -yhteydet:** `register-connections.sh`
> - 📊 **Raportit & Mittarit:** `generate-setup-report.sh`

> 📊 **Yksityiskohtaiset työnkulut ja arkkitehtuurivaatimukset on dokumentoitu tiedostossa: [docs/setup-all-workflow.md](../docs/setup-all-workflow.md)**

> [!IMPORTANT]
> **SQLcl-Säilön Varajärjestelmä (Rule 4):** Ennen asennusta komentosarja tarkistaa, onko paikallinen **SQLcl** asennettu. Jos sitä ei löydy, se siirtyy automaattisesti käyttämään **SQLcl-säilökuvaa** (`SQLCL_CONTAINER_IMAGE`). Tämä takaa asennuksen onnistumisen myös ilman paikallista Javaa.

**Syntaksi:**
```bash
./scripts/setup-all.sh [-b <0-11>] [-tb <0-11|LIST|all>] [-lb] [-sb <0-11>] [--search <QUERY>] [--dry-run] [-ltr] [-i] [--force | -y] [--no-publisher] [--no-ords] [--no-monitor-app]
```

**Valitsimet ja Parametrit:**
*   **`-b <N>` / `--blueprint <N>`:** Tuotanto- ja kehitystila. Aktivoi tarkalleen **yhden** valitun blueprintin (0–11) säilyttäen tietokannan tiedot (Idempotentti / Ei nollausta).
*   **`-tb <LIST|all>` / `--test-blueprints`:** Automaattinen CI/CD-testaustila. Suorittaa `reset-all.sh -y` ennen jokaista testiä varmistaen puhtaan lähtötilan.
*   **`-lb` / `-l` / `--list-blueprints`:** Näyttää kaikkien 12 tuetun blueprintin dynaamisen taulukon käynnistämättä säilöjä.
*   **`-sb <N>` / `--show-blueprint <N>`:** Näyttää valitun blueprintin `<N>` yksityiskohtaiset tiedot (säilöt, portit, RAM-budjetti, TLS).
*   **`--search <QUERY>` / `--search-blueprints`:** Etsii blueprintejä avainsanan perusteella (esim. `publisher`, `ords`, `web-ide`).
*   **`--dry-run`:** Simuloi suorituksen ilman todellisia muutoksia.
*   **`-ltr` / `--list-test-reports`:** Näyttää blueprint-testiraporttien tilan kansiossa `tests/reports/blueprints/`.
*   **`-i` / `--select`:** Avaa interaktiivisen valikon 30s ajastimella.
*   **`--force` / `-y`:** Ohittaa vahvistuskysymykset ja levytarkistukset (sopii CI/CD-putkiin).
*   **`--no-publisher`:** Jättää Publisher-tietokannan (`db-publisher`) käynnistämättä muistin säästämiseksi.
*   **`--from-snapshot`:** Palauttaa tietokantavolyymit tallennetusta tilannevedoksesta ennen käynnistystä (**pika-aloitus ~30s**).
*   **`--build-image`:** Tallentaa tietokannan esikonfiguroiduksi säilökuvaksi asennuksen jälkeen.
*   **`--parallel`:** Sallii multi-DB- ja Publisher-alustuksen rinnakkain (vaatii vapaata RAM $\ge$ 8 GB).
*   **`--sequential`:** Pakottaa tiukan peräkkäisen asennuksen (turvallinen oletustila).

**Esimerkkikomennot:**
```bash
# 1. TUOTANTO JA TAVALLINEN KEHITYS:
./scripts/setup-all.sh -b 3             # Aktivoi suositeltu 2-tasoinen blueprint
./scripts/setup-all.sh --blueprint 7    # Aktivoi Full Enterprise 4-tasoinen pino
./scripts/setup-all.sh -lb              # Näytä blueprint-taulukko
./scripts/setup-all.sh -sb 3            # Näytä blueprint 3:n säilöpuu
./scripts/setup-all.sh --search pub     # Etsi Publisheriin liittyvät mallit
./scripts/setup-all.sh -b 3 --dry-run   # Simuloi suoritus

# 2. AUTOMAATTITESTAUS JA CI/CD:
./scripts/setup-all.sh -tb 3            # Testaa yksittäinen blueprint puhtaalta pöydältä
./scripts/setup-all.sh -tb 1,5,8        # Testaa valitut blueprintit
./scripts/setup-all.sh -tb all          # Testaa KAIKKI 12 blueprinttiä peräkkäin
./scripts/setup-all.sh -ltr             # Tarkista testiraporttien tila

# 3. Interaktiivinen asennus:
./scripts/setup-all.sh
```

---

## 2. Säilöjen Käynnistäminen (`start-containers.sh`)

Käynnistää olemassa olevat paikalliset tietokanta- ja ORDS-säilöt ja odottaa, että tietokannat saavuttavat `healthy`-tilan.

```bash
./scripts/start-containers.sh [--no-ords] [--no-publisher]
```

---

## 3. Ympäristön ja Komponenttien Nollaus (`reset-all.sh`)

Modulaarinen profiilitietoinen siivousmoottori, joka pysäyttää ja poistaa säilöt, profiilit (`config/profiles/*.yaml`), volyymit ja verkot.

**Syntaksi:**
```bash
./scripts/reset-all.sh [komponentti] [--profile <profiili>] [--logs | -l] [--force | -y] [--system]
```

**Esimerkkikomennot:**
```bash
./scripts/reset-all.sh all              # Täydellinen ympäristön nollaus
./scripts/reset-all.sh all --logs --force # Nollaus mukaan lukien lokit ilman vahvistusta
```

---

## 4. Tilannevedosten Hallinta (`scripts/snapshots/`)

Tarjoaa tietokantavolyymien nopean kylmävarmuuskopioinnin ja palauttamisen (~15s):

```bash
./scripts/snapshots/create-golden-snapshots.sh
./scripts/snapshots/restore-golden-snapshots.sh --force
./scripts/snapshots/clean-golden-snapshots.sh
```

---

## 4.5. Lokien Siivous ja Turvallisuus (`clean-logs.sh` & `sanitize-logs.sh`)

```bash
./scripts/clean-logs.sh [-y | --force]
```
Kaikki lokit suodatetaan automaattisesti salaisuuksien peittämiseksi. Hätätilannevirheenkorjauksessa peitto voidaan ohittaa:
```bash
DEBUG_LOG_UNSANITIZED=true ./scripts/setup-all.sh
```

---

## 5. Kehittäjän ja Ylläpitäjän CLI-Työkalut

### 5.1. Salasanojen Luku Walletista (`get-password.sh`)
```bash
./scripts/get-password.sh <ALIAS>
./scripts/get-password.sh DB_PROXY_DEV
./scripts/get-password.sh DB_PROXY_APEX_ADMIN
```

### 5.2. Verkkopalveluiden HTTP-Tarkistus (`check-urls.sh`)
```bash
./scripts/check-urls.sh
```

### 5.3. SEPS-Yhteyksien Diagnostiikka (`check-wallet.sh`)
```bash
./scripts/check-wallet.sh
```

### 5.4. Älykäs SQLcl CLI -Kääre (`sqlcl.sh`)
```bash
./scripts/sqlcl.sh /@DB_PROXY_DEV
./scripts/sqlcl.sh /@DB_PROXY_SYS as sysdba
```

### 5.5. Kehittäjätunnuksen Luonti (`create-developer.sh`)
```bash
./scripts/create-developer.sh
```

### 5.6. VS Code -Yhteyksien Synkronointi (`register-connections.sh`)
```bash
./scripts/register-connections.sh
```

---

## 6. Paikallisten Sertifikaattien Luottamus (`scripts/certs/`)

* 🍎 **macOS:** `./scripts/certs/trust-local-cert-mac.sh`
* 🪟 **Windows & WSL:** `scripts\certs\trust-local-cert.cmd` / `trust-local-cert.ps1`

---

## 7. Analytics Publisherin Toiminnot (`scripts/publisher/`)

* `./scripts/publisher/status-publisher.sh`
* `./scripts/publisher/restart-publisher.sh`
* `./scripts/publisher/backup-publisher-catalog.sh`
* `./scripts/publisher/deploy-publisher-reports.sh`

---

## 8. Etäkäyttöönotto ja Monipilvitestaus (`deploy-remote.sh`)

```bash
./scripts/deploy-remote.sh --host 20.123.45.67 --user azureuser --key ~/.ssh/id_rsa --blueprint 10
./tests/test-remote-multicloud.sh --dry-run
./tests/test-devhub-browser-blueprints.sh --all
```

---

## 9. Manuaalinen Päivitysten Asennus (`scripts/internal/`)

* `./scripts/internal/apply-apex-patch.sh`
* `./scripts/internal/apply-publisher-patch.sh`

---

## 10. Sisäiset Automaatiomoottorit (`scripts/internal/`)

Katso tarkemmat tiedot hakemistosta:
* 📁 **[`scripts/internal/README.fi.md`](internal/README.fi.md)**

---

## 11. Vianmääritys: Podman Machine Palautusohje

Jos Podman-liitännässä ilmenee virheitä tai säilöjen aikakatkaisuja:

```bash
podman machine stop
podman machine start
./scripts/reset-all.sh --force
./scripts/setup-all.sh --force
```
