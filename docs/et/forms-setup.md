[ 🇬🇧 English ](../forms-setup.md) | [ 🇪🇪 Eesti ](forms-setup.md) | [ 🇸🇪 Svenska ](../sv/README.md) | [ 🇱🇻 Latviešu ](../lv/README.md) | [ 🇱🇹 Lietuvių ](../lt/README.md)

# Oracle Forms 14c (14.1.2) Paigaldus-, Arendus- ja Kasutusjuhend

See juhend kirjeldab **Oracle Forms 14c (Fusion Middleware 14.1.2 / Forms Services)** paigaldamist, arhitektuuri, arendaja töövooge, failide edastamist konteinerisse, piltide ja hetktõmmiste haldust ning Forms rakenduste käitamist ja APEX-isse migreerimist.

---

## 1. Arhitektuur ja Portide Jaotus

| Komponent | Port | Kirjeldus |
| :--- | :--- | :--- |
| 📐 **Forms Runtime** | `9001` / `9002` | Forms Services servlet (`/forms/frmservlet`) ja reaalajas käivitatavad veebivormid (`/forms/frmservlet?form=test.fmx`). |
| 🌐 **Forms Developer Hub** | `6082` | Arendaja veebikeskus ja diagnostikaliides (`http://localhost:6082/vnc.html`). |
| ⚙️ **WebLogic Console** | `7001` | WebLogic AdminServer haldusliides (`/console`). |
| 🗄️ **Forms DB (`db-forms`)** | `1534` | Oracle 23ai Free andmebaas RCU skeemidega (`FORMS_STB`, `FORMS_OPSS`, `FORMS_IAU`, `FORMS_WLS`). |
| 🗄️ **Custom DB (`db-custom` / `db-alise`)** | `1531` | Custom ärirakenduse andmebaas (andmed, tabelid, paketid). |
| 🚀 **ORDS & APEX** | `8181` / `8088` | Oracle REST Data Services ja APEX App Builder. |

---

## 2. Arhitektuurne Selgitus: Forms Builder (GUI) vs Konteineri Headless Runtime

### Miks Forms Builderit (GUI) ei saa Macis/Linuxis otse avada?
1. **Pärand-Motif graafikaraamistik:** Linuxi Forms Builder (`frmbld`) põhineb 1990ndate aegsel **Motif / OpenMotif** graafikaraamistikul, mis vajab spetsiifilisi pärand-X11 laiendusi (8-bit PseudoColor Visuals, vanad fondiserverid). Kaasaegne macOS XQuartz ega kaasaegsed Linuxi aknahaldurid (Wayland/Xorg) ei toeta enam neid 30 aasta taguseid graafikastandardeid, visates vea `FRM-91111: internal error: window system startup failure`.
2. **Oracle ametlik tootedokumentatsioon:** Oracle Forms 12c ja 14c dokumentatsioonis on sätestatud:
   > *Form Builder (GUI visuaalne toimetaja) on ametlikult toetatud AINULT Microsoft Windows operatsioonisüsteemis (`frmbld.exe`). Linuxi jaotuspaketid sisaldavad Forms Compileri (`frmcmp_batch`), Forms Services Runtime serverit (`frmweb` / WebLogic `WLS_FORMS`) ja migratsioonitööriistu (`Forms2XML`).*

### Konteineri Tegelik Otstarve ja Roll
Konteinerit kasutatakse **Headless DevOps, Kompileerimise ja Käituskeskkonnana**:
- **Rakenduste Käitamine:** Kompileeritud vorme (`.fmx`) jooksutatakse reaalajas veebiserveri kaudu (`http://localhost:9001/forms/frmservlet?form=<minuvorm.fmx>`).
- **Partii-Kompileerimine (CLI):** `.fmb` vormide kompileerimine `.fmx`-iks toimub käsurealt sekundiga läbi käsu `./scripts/forms/compile-form.sh`.
- **APEX Migratsioon:** Vormide XML-iks teisendamine ja APEX Migration Workshop ZIP paki eksport.

---

## 3. Juhend: Kuidas Edastada Forms `.fmb` ja `.fmx` Faile Konteinerisse

Forms failide konteinerisse toimetamiseks on **4 paindlikku meetodit**:

### Meetod A (Kõige Lihtsam & Soovitatav): Lokaalne Monteeritud Kaust (`forms_apps/`)
- Projekti juurkataloogis asuv kaust **`forms_apps/`** on automaatselt monteeritud konteineri kausta `/u01/oracle/forms_apps` reaalajas (`rw` režiimis).
- **Kuidas kasutada:**
  1. Kopeeri või lohista oma olemasolevad `.fmb` või `.fmx` failid Finderis/Exploreris otse kausta `forms_apps/` (või käsurealt `cp /minu/kaust/*.fmb forms_apps/`).
  2. Failid on **koheselt ja reaalajas konteineris nähtavad** ilma konteinerit taaskäivitamata.
  3. Kompileeri käsurealt: `./scripts/forms/compile-form.sh forms_apps/minuvorm.fmb`
  4. Ava veebis: `http://localhost:9001/forms/frmservlet?form=minuvorm.fmx`

### Meetod B: Ametlik Tarne Skript (`deploy-forms-apps.sh`)
Kui soovid faile tarnida teisest kataloogist või automatiseeritud skriptist:
```bash
# Tarnib üksiku vormi:
./scripts/forms/deploy-forms-apps.sh /minu/projekt/tellimused.fmb

# Tarnib terve kaustapuu koos menüüde (.mmb) ja teekidega (.pll):
./scripts/forms/deploy-forms-apps.sh /minu/vanad_vormid/
```

### Meetod C: Podman / Docker Kopeerimiskäsk (`podman cp`)
Otsene kopeerimine käimasolevasse konteinerisse:
```bash
podman cp /minu/kohalik/vorm.fmb app-forms:/u01/oracle/forms_apps/
podman cp /minu/kohalik/vorm.fmx app-forms:/u01/oracle/forms_apps/
```

### Meetod D: Windows Forms Builderist (`frmbld.exe`) Otse Salvestamine
Kui arendaja kujundab vorme Windowsi masinas (või Maci virtuaalmasinas nagu Parallels / VMware):
1. Jaga Maci kaust `forms_apps/` Windowsi virtuaalmasinaga võrgukettana (nt `Z:\forms_apps`).
2. Windows Forms Builderis vali **File $\rightarrow$ Save As** ja salvesta otse kettale `Z:\forms_apps\minuvorm.fmb`.
3. Maci konteineris käivita kompileerimine ja testi koheselt veebis!

---

## 4. Konteineripiltide (Images) ja Kuldsete Hetktõmmiste (Snapshots) Haldus

Forms 14c keskkonna korduvkasutatavuse tagamiseks pakub repositoorium **4 võimekat mehhanismi**:

### 1. Eelkonfigureeritud Pildiehitaja (`docker/forms/build-forms-prebuilt-image.sh`)
Skript ehitab ja sildistab valmis paigaldatud Forms 14c domeeniga OCI pildi:
```bash
# Ehita lokaalne pilt:
./docker/forms/build-forms-prebuilt-image.sh

# Või määra sihtregistri täisnimi:
./docker/forms/build-forms-prebuilt-image.sh -t artifactory.corp.bank/oracle-forms:14.1.2
```
*Tulemus:* Uues arendusmasinas või CI/CD-s käivitub Forms **5 sekundiga** ilma nullist 15-minutilise paigalduseta.

### 2. Kuldsete Hetktõmmiste Süsteem (`scripts/snapshots/`)
Loob andmebaasi ja rakenduste püsimälumahtudest (Volumes) tihendatud `.tar.gz` arhiivid kausta `golden-snapshots/`:
```bash
# Loo hetktõmmis:
./scripts/snapshots/create-golden-snapshots.sh

# Taasta hetktõmmis sekundiga:
./scripts/snapshots/restore-golden-snapshots.sh
```

### 3. OCI Pildi Lokaalne Eksport & Import (`podman save` / `podman load`)
Võimaldab pilti jagada ja arhiveerida ilma internetiühenduseta (air-gapped keskkonnad):
```bash
# Eksport faili:
podman save -o binaries/forms/oracle-forms-14.1.2.tar localhost/oracle-forms:14.1.2

# Import teises masinas:
podman load -i binaries/forms/oracle-forms-14.1.2.tar
```

### 4. Ettevõtte Sise-Artifactory ja Pilveregistri Tugi
Seadista `.env` failis muutuja `FORMS_CONTAINER_IMAGE=artifactory.corp/oracle-forms:14.1.2` ning laadi pilt registrisse:
```bash
podman tag localhost/oracle-forms:14.1.2 artifactory.corp/oracle-forms:14.1.2
podman push artifactory.corp/oracle-forms:14.1.2
```

---

## 5. Forms Kompileerimine ja Custom Andmebaasi Ühendus

Forms vormide (`.fmb`) kompileerimisel kontrollib `frmcmp_batch` andmebaasi skeemi (tabelid, vaated, paketid).

Kompileerimisel saab määrata sihtandmebaasi aliase (mis loetakse turvaliselt SEPS Walletist):
```bash
# Kompileeri vaikimisi Forms DB vastu:
./scripts/forms/compile-form.sh forms_apps/minuvorm.fmb

# Kompileeri Custom rakenduse andmebaasi vastu:
./scripts/forms/compile-form.sh -a DB_CUSTOM_DEV forms_apps/tellimused.fmb

# Kompileeri kõik vormid korraga:
./scripts/forms/compile-form.sh --all -a DB_CUSTOM_DEV
```

---

## 6. Blueprintide Ülevaade

| Blueprint | Nimi | Kirjeldus |
| :--- | :--- | :--- |
| **Blueprint 14** | `14-forms-with-dedicated-db` | Oracle Forms 14c koos pühendatud metaandmete andmebaasiga (`db-forms`). |
| **Blueprint 15** | `15-forms-full-enterprise` | Täisarhitektuur: Forms (`app-forms`) + Forms DB (`db-forms`) + Custom DB (`db-custom`) + APEX Proxy DB (`db-proxy`) + ORDS. |
| **Blueprint 16** | `16-forms-minimal-hybrid` | Minimaalne hübriid: Forms (`app-forms`) + Forms/APEX Proxy DB (`db-forms-proxy`) + Custom DB (`db-custom`) + ORDS. |
| **Blueprint 17** | `17-forms-with-embedded-ords` | Forms + Sisseehitatud ORDS Jetty: Kõik-ühes rakendusserver (`app-forms`: Forms 9001 + ORDS Jetty 8088) + `db-proxy`. |
| **Blueprint 18** | `18-ultimate-all-in-one-enterprise` | 🌟 Ultimate Enterprise All-in-One: Forms 14c + Analytics Publisher + APEX 26.1 + ORDS ühendatud andmebaasil (`db-proxy`). |

---

## 7. Forms-to-APEX Moderniseerimise Töövoog (Tulevik)

```
┌─────────────────────────┐      1. export-forms-for-apex.sh      ┌─────────────────────────────┐
│  Olemasolevad Oracle    │ ────────────────────────────────────► │  apex_migration_bundle.zip  │
│  Forms failid (.fmb)    │                                       └──────────────┬──────────────┘
└─────────────────────────┘                                                      │
             │                                                                   │ 2. Import APEXisse
             │ 3. extract-forms-plsql.sh                                         ▼
             ▼                                                    ┌─────────────────────────────┐
┌─────────────────────────┐                                       │  Oracle APEX App Builder    │
│  Andmebaasi Paketid     │ ────────────────────────────────────► │  Application Migration      │
│  PKG_*_FORMS_LOGIC.sql  │        4. Rakenda loogika DBs         │  Workshop                   │
└─────────────────────────┘                                       └─────────────────────────────┘
```

1. **Samm 1:** Paiguta olemasolevad `.fmb` moodulid kausta `forms_apps/`.
2. **Samm 2:** Käivita `./scripts/forms/export-forms-for-apex.sh`. See genereerib faili `forms_apps/apex_migration_bundle.zip`.
3. **Samm 3:** Ava Oracle APEX App Builder, vali **App Builder &rarr; Application Migration Workshop** ning laadi üles loodud ZIP arhiiv.
4. **Samm 4:** Eralda äriloogika käsuga `./scripts/forms/extract-forms-plsql.sh forms_apps/<vorm>_fmb.xml` ning rakenda genereeritud pakett andmebaasis.