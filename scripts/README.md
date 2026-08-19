# CLI Skriptide Kasutusjuhend (Command Line Reference)

See fail sisaldab üksikasjalikku juhendit ja parameetrite kirjeldusi kõigi projekti juures asuvate skriptide kohta, mis asuvad kaustas `scripts/`.

---

## 1. Keskkonna automaatne paigaldus (`setup-all.sh`)

Skript `./scripts/setup-all.sh` teostab kogu keskkonna täieliku paigalduse: laeb alla vajaliku tarkvara, orkestreerib konteinerid, ootab andmebaaside ja ORDS-i valmisolekut, käivitab andmebaasi skeemi migratsioonid (Liquibase), paigaldab APEX-i koos bundle patchiga ning mõõdab iga sammu kestust.

> 🏛️ **Modulaarne & Profiilipõhine Arhitektuur:**
> Skript `setup-all.sh` on ehitatud **peamise orkestreerijana**, mis koondab interaktiivse CLI liidese, sammude mõõtmise (Reegel 1) ja logimise (`install_logs/`), delegeerides kõik spetsiifilised alamprotsessid modulaarsetele abiskriptidele kaustas `scripts/internal/`:
> - 📦 **Profiilid & Topoloogia:** `load-profile.sh` & `resolve-topology.sh`
> - 🔌 **Instantsi algseadistus:** `init-db-instance.sh`
> - 👤 **Kasutajad & Rollid:** `apply-profile-users.sh`
> - 🔒 **Sertifikaatide usaldamine:** `generate-local-certs.sh`
> - 💻 **VS Code ühendused:** `register-connections-sqlcl.sh`

> 📊 **Paigaldusprotsessi detailne voodiagramm ja arhitektuursed sammud (idempotentsus, SQLcl fallback, Microsoft Defenderi optimeerimine) on kirjeldatud eraldi dokumendis: [docs/setup-all-workflow.md](../docs/setup-all-workflow.md)**

> [!IMPORTANT]
> **Tarkvara nõue (SQLcl container fallback):** Enne paigalduse algust kontrollib skript automaatselt, kas süsteemis on paigaldatud **SQLcl** lokaalne klient (või VS Code laienduse sees olev versioon). Kui utiliiti ei leita, lülitub paigaldus automaatselt ümber **SQLcl konteineri** kasutamisele (`SQLCL_CONTAINER_IMAGE`). See võimaldab andmebaasi migratsioonide ja APEX rakenduste paigaldust ka täiesti puhtas masinas ilma kohaliku Javal/SQLcl-ita.



**Süntaks:**
```bash
./scripts/setup-all.sh [--force | -y] [--no-publisher] [--no-ords] [--no-monitor-app]
```

**Parameetrite valikud:**
- `--force` / `-y`: Jätab vahele paigalduseelse kinnituse ja kettaruumi kontrolli küsimused (sobib automaattestideks ja CI/CD tööriistadele).
- `--no-publisher`: Jätab lokaalse Publisher andmebaasi (`db-publisher`) käivitamata ja seadistamata (säästab mälu).
- `--no-ords`: Jätab lokaalse ORDS teenuse käivitamata ja konfigureerimata (paigaldab ainult APEX-i andmebaasi poolele).
- `--no-monitor-app`: Jätab kaustas `binaries/apex_apps/` asuvate APEX rakenduste automaatse paigaldamise vahele.

**Näidiskäsud:**
```bash
# Tavaline interaktiivne täispaigaldus:
./scripts/setup-all.sh

# Täispaigaldus ilma kinnituste küsimiseta (automaatne käivitus):
./scripts/setup-all.sh --force

# Paigaldus ilma Publisher andmebaasita:
./scripts/setup-all.sh --no-publisher

# Ainult APEX andmebaasi paigaldus ilma lokaalse ORDS-ita:
./scripts/setup-all.sh --no-ords

# Paigaldus ilma valmispakitud APEX rakenduste importimiseta:
./scripts/setup-all.sh --no-monitor-app
```

### 💡 Automaatne APEX ja ORDS tarkvarapakettide puhverdamine (`binaries/`)
Skript `setup-all.sh` järgib tarkvarapakettide hankimisel nutikat lokaalse puhverdamise strateegiat:
1. **ORDS pakett (`binaries/ords/`):** Kontrollitakse esmalt, kas kaustas `binaries/ords/` on olemas zip-fail (nt `ords-latest.zip`). Kui fail on olemas, kasutatakse seda otse. Kui fail puudub, laetakse vajalik versioon alla aktiivse YAML profiili parameetrist `PROFILE_ORDS_DOWNLOAD_URL` ja salvestatakse kausta `binaries/ords/`.
2. **APEX pakett (`binaries/` ja `binaries/apex/`):** Tuvastatakse andmebaasi profiili nõutud APEX versioon. Kui sobilik zip-fail on lokaalselt olemas, kasutatakse seda; vastasel juhul laetakse see profiili URL-ilt alla.
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
./scripts/reset-all.sh [komponent] [--profile <profiil>] [--force | -y] [--system]
```

**Komponentide valikud:**
- `all` (Vaikimisi): Peatab ja kustutab kõik komponendid (APEX Proxy, Publisher, ORDS) koos volumite ja võrkudega.
- `db-apex-proxy`: Kustutab ainult APEX Proxy andmebaasi konteineri ja selle persistentse volume.
- `db-publisher`: Kustutab ainult Publisher andmebaasi konteineri ja selle persistentse volume.
- `ords`: Kustutab ainult lokaalse ORDS teenuse konteineri.

**Lisalipud (Flags):**
- `--profile <nimi>`: Määra täpne profiili nimi puhastamiseks (vaikimisi võetakse `.env` muutujast `MAIN_DB_PROFILE`, nt `proxy-adb-oracle` või `bizapp-standard-oracle`).
- `--force` / `-y`: Jätab turvaküsimuse vahele ja teostab operatsiooni otse (kasulik CI/CD runneri või automaatsete testide jaoks).
- `--system`: Teostab kogu kohaliku Podman süsteemi täieliku süvapuhastuse (prune). Kustutab kõik konteinerid, pildid ja volumid, et vabastada kettaruumi (küsib täiendava kinnitussõna 'JAH').

**Näidiskäsud:**
```bash
# Kogu lokaalse arenduskeskkonna täielik kustutamine:
./scripts/reset-all.sh all

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

## 4.5. Logifailide puhastamine (`clean-logs.sh`)

Selleks, et lokaalne kettaruum ei täituks paigalduste ja taastamiste ajal tekkivate mahukate logifailidega, saab kasutada logide puhastamise skripti. Skript küsib kasutajalt interaktiivselt päevade arvu, millest vanemad failid kustutada.

**Süntaks:**
```bash
./scripts/clean-logs.sh
```

**Toimimine:**
*   Arendajalt küsitakse päevade arvu (nt `2` tähendab, et kustutatakse kõik üle 48 tunni vanused logid).
*   **Vaikimisi väärtus:** Kui vajutad lihtsalt Enter, valitakse **1** (kustutab kõik failid, mis on vanemad kui 24 tundi).
*   **Kogu puhastus:** Sisestades **0**, kustutatakse `install_logs/` kaustast kõik failid (välja arvatud versioonihalduse abifailid `.gitignore` ja `.gitkeep`).

---

## 4.6. Hetktõmmiste puhastamine (`clean-golden-snapshots.sh`)

Selleks, et lokaalne kettaruum ei täituks ajutiste ja vanade andmebaasi hetktõmmistega, saab kasutada hetktõmmiste puhastamise skripti. Skript küsib kasutajalt interaktiivselt päevade arvu, millest vanemad failid kustutada.

**Süntaks:**
```bash
./scripts/clean-golden-snapshots.sh
```

**Toimimine:**
*   Arendajalt küsitakse päevade arvu (nt `3` tähendab, et kustutatakse kõik üle 72 tunni vanused hetktõmmised).
*   **Vaikimisi väärtus:** Kui vajutad lihtsalt Enter, valitakse **0** (kustutab kõik vanad arhiivid, jättes alles vaid `_latest.tar.gz`).
*   **Turvalisus (Latest kaitse):** Skript **ei kustuta kunagi** viimast/värskeimat faili, mis lõpeb nimega `_latest.tar.gz` (nt `apex_proxy_oradata_latest.tar.gz`). See tagab, et sul on alati olemas vähemalt üks kehtiv taastepunkt.

---

## 4.7. Arendaja kasutajakonto loomine (`create-developer.sh`)

Selleks, et lokaalses arenduses (DEV) ei jagataks ühist ja piiramatute õigustega `ADMIN` kasutajat, saab iga arendaja luua endale isikliku arendajakonto (developer rolliga) otse oma PC kasutajanime alusel. 

*Märkus: See skript käivitatakse ka automaatselt valikuna peamise keskkonna paigaldusskripti (`setup-all.sh`) lõpus lokaalses režiimis.*

**Süntaks:**
```bash
./scripts/internal/create-developer.sh
```

**Toimimine:**
*   Skript tuvastab automaatselt jooksva operatsioonisüsteemi (macOS/Linux) kasutaja nime keskkonnamuutujast `$USER` (või `$DEVELOPER_USER`) ja pakub seda vaikimisi kasutajanimena (muutes selle suurtähtedeks, nt `ALLANLAHE`).
*   Skript genereerib automaatselt taustal uue tugeva ja juhusliku parooli kujul `Dev_[juhuslik_väärtus]_2026!` ning salvestab selle turvaliselt Oracle Walletisse (SEPS) ilma parooli ekraanile kuvamata või küsimata (lugemine: `./scripts/internal/view-wallet-credential.sh <KASUTAJANIMI>`).
*   **Andmebaasi kasutaja (DB User):** Skript loob andmebaasi (`FREEPDB1`) samanimelise kasutaja, annab talle sisselogimisõiguse (`CREATE SESSION`) ja määrab ametliku Oracle 23c/23ai arendaja rolli **`DB_DEVELOPER_ROLE`**, mis tagab kõik vajalikud õigused DDL/DML tegevusteks ilma liigsete administraatori õigusteta.
*   **APEX arendajakonto:** Skript loob APEX-i keskkonda (`PROXY_WORKSPACE`) sama nime ja parooliga arendaja kasutaja, võimaldades sisselogimist APEX Builderisse.
*   **VS Code SQL Developer ühendus:** Pärast kasutajate loomist registreeritakse uus ühendus automaatselt kasutaja VS Code SQL Developer laienduse alla skriptiga `./scripts/register-connections.sh`.

---

## 4.8. Lokaalne Offline CI/CD Simulaator (`test-local-ci.sh`)

Selleks, et testida GitHub Actions workflow failide (`.github/workflows/deploy-apex.yml`) ja SQLcl Projects tarne toimimist oma arvutis **täielikult offline režiimis ilma koodi pushimata**, saab käivitada:

**Süntaks:**
```bash
./scripts/test-local-ci.sh [--dry-run] [--workflow deploy-apex.yml] [--ui]
```

**Toimimine:**
*   Skript genereerib kohalikust SEPS Walletist automaatselt ajutise `.env.secrets` faili.
*   Kontrollib ja käivitab Nektos `act` CLI utiliidi või ajutise SQLcl konteineri (ephemeral SQLcl fallback) lokaalseks CI/CD pariteettestiks.
*   Kuivkäivitus (`--dry-run`): Kontrollib workflow süntaksit ja sammusid ilma andmebaasi muutmata.

*   Säilitab teised kasutaja olemasolevad kaustad failis `folders.json` ning eemaldab vanad orvud ühenduse ID-d, et ennetada `DBTU-03001` vigu.

---

## 4.8. Süsteemsete paroolide genereerimine (`generate-passwords.sh`)

Selleks, et kõigil paigaldatavatel andmebaasi instantsidel ja APEX administraatoritel oleksid tugevad ja kordumatud paroolid, saab kasutada paroolide automaatse genereerimise skripti.

**Süntaks:**
```bash
./scripts/internal/generate-passwords.sh [--force | -y]
```

**Toimimine:**
*   Kui `.env` faili veel ei eksisteeri, loob skript selle automaatselt faili `.env.example` kopeerimise teel.
*   Skript genereerib iga süsteemse rolli ja kasutaja jaoks (nt `SYS`, `APEX_PROXY_SCHEMA`, `TEST_DEV`, APEX Admin ja ORDS Listener) juhuslikud tugevad paroolid.
*   **Turvaline hoidmine:** Genereeritud paroolid registreeritakse otse **Podman Secrets** teenusesse (daemoni turvalisse mällu) – neid **ei kirjutata kunagi lahtise tekstina kettale ega `.env` faili**.
*   **Walleti parool:** Oracle Walleti parool salvestatakse eraldi faili `config/secrets/wallet_password.txt` (mida `.gitignore` ei lisa kunagi versioonihaldusse) ja mida skriptid vajavad kohaliku Walleti haldamiseks.
*   **Kaitse:** Kui saladused on juba registreeritud, küsib skript üle, kas soovid need uutega asendada. Valikuga `--force` (või `-y`) asendatakse need automaatselt ilma kinnitust küsimata.

---

## 4.9. Kohalike SSL sertifikaatide genereerimine (`generate-local-certs.sh`)

Selleks, et lokaalses arenduses (DEV_LOCAL) saaks testida HTTPS turvalist ühendust ilma brauseri hoiatusteta, saab luua kohaliku juursertifikaadi (Root CA) ning allkirjastada sellega domeeni `localhost` sertifikaadi.

**Süntaks:**
```bash
./scripts/internal/generate-local-certs.sh
```

**Toimimine:**
*   Skript loob kausta `config/certs/` kaks peamist sertifikaati: kohaliku Root CA (`localCA.pem`) ning localhosti võtme ja sertifikaadi (`localhost.crt`, `localhost.key`) ORDS-i HTTPS-i jaoks.
*   **Oracle Wallet automaatne loomine:** Skript konverteerib need samad sertifikaadid automaatselt Oracle Walleti formaati (loob failid `ewallet.p12` ja `cwallet.sso`) ning paigutab need kaustadesse `config/wallet-apex-proxy/` ja `config/wallet-publisher/` andmebaasi TCPS ühenduste tarbeks.
*   **macOS integratsioon:** Kui skript käivitatakse macOS-is, küsib see luba lisada loodud Root CA automaatselt macOS-i süsteemse Keychaini nimekirja ning märkida see usaldusväärseks (`trustRoot`). See nõuab sudo parooli, kuid tagab selle, et arendaja brauser usaldab kohalikke HTTPS aadresse (kuvatakse roheline lukk).

---

## 4.10. Andmebaasi paroolide lugemine Walletist (`view-wallet-credential.sh`)

Selleks, et mitte hoida ja printida andmebaasi SYS ja skeemide paroole avatud tekstina logifailidesse või konsooli, kasutatakse paroolivaba **Oracle Walletit**. Kui sul on siiski vaja tekstilist parooli käsitsi ühenduse võtmiseks, saad selle turvaliselt Walletist välja lugeda.

**Süntaks:**
```bash
./scripts/internal/view-wallet-credential.sh <alias>
```
*Soovituslikud aliased: `DB_APEX_PROXY_SYS`, `DB_TEST_DEV`, `DB_APEX_PROXY_SCHEMA`*

---

## 4.11. SQLcl Käsurea Wrapper (`scripts/sqlcl.sh`)

Utiliit `./scripts/sqlcl.sh` võimaldab luua sujuvaid käsurea SQLcl ühendusi ilma paroole sisestamata. `setup-all.sh` registreerib selle automaatselt kasutaja kesta konfiguratsiooni (`~/.zshrc` / `~/.bashrc`), misjärel saab otse kasutada käske:

```bash
# SYSDBA ühendus APEX Proxy andmebaasi:
sql /@DB_APEX_PROXY_SYS as sysdba

# Arendaja ühendus:
sql /@DB_TEST_DEV
```

**Omadused:**
*   **Dünaamiline aliase tuvastus:** Loeb ühenduse rekvisiidid otse aktiivse YAML profiili aliastest ja Oracle Walletist (SEPS).
*   **Automaatne fallback:** Kui kohalikku SQLcl utiliiti ega VS Code laiendust ei leita, käivitatakse päring läbi ühekordse (ephemeral) SQLcl konteineri.
*   **Automaattestid:** `setup-all.sh` teostab paigalduse lõpus ühenduste automaatse valideerimise ja kuvab tulemuse ekraanile.


---

## 5. Parimad Praktikad: Millal millist skripti kasutada?

### Keskkonna automaatne paigaldus (`setup-all.sh`):
*   **Esmakordselt:** Kui kloonid projekti esimest korda oma masinasse ja sul pole veel andmebaase ega APEX-it püsti pandud.
*   **Versiooni uuendustel:** Kui soovid uuendada APEX mootorit, ORDS-i või peale kanda uusi andmebaasi patche.
*   **Põhikonfiguratsiooni muutmisel:** Kui muudad võrgukohti, porte või seadeid failis `.env` ja soovid, et keskkond luuakse uute reeglite järgi puhtalt uuesti.

### Käivita konteinerid (`start-containers.sh`):
*   **Igapäevaselt:** Kui tuled hommikul tööle või teed pausi ning andmebaasi/ORDS konteinerid on seisatud (näiteks pärast arvuti taaskäivitamist või `podman compose stop` tegemist). See äratab juba olemasolevad andmebaasid ja ORDS-i uuesti ellu koos sinu andmete ja tehtud muudatustega ilma midagi uuesti installeerimata.

### Loo hetktõmmis (`create-golden-snapshots.sh`):
*   **Enne** suuremaid arendustöid, andmemudeli migratsione või ohtlikke DDL-operatsioone.
*   **Pärast** keskkonna edukat täispaigaldust, testandmete sisselaadimist ja manuaalsete kasutajate / workspaces-ide konfigureerimist (et vältida nende uuesti loomist nullist).

### Taasta hetktõmmisest (`restore-golden-snapshots.sh`):
*   **Rikete korral:** Kui kohaliku andmebaasi failisüsteem läheb katki või konteiner ei käivitu (Listener / TNS vead).
*   **Nullimiseks:** Kui soovid kiiresti (alla 1 minutiga) viia arenduskeskkonna seisu tagasi viimasesse tuntud-töötavasse olekusse, selle asemel et oodata 10 minutit uut täispaigaldust.

### Kustuta ja nulli keskkond (`reset-all.sh`):
*   **Kogu keskkonna eemaldamiseks:** Kui soovid vabastada oma arvutist kettaruumi (säästab ~15GB+ ruumi) või alustada täiesti puhtalt lehelt.
*   **Üksikute komponentide puhastamiseks:** Kui soovid näiteks nullida ainult ühe andmebaasi (nt `db-publisher`), kuid soovid säilitada teise andmebaasi ja ORDS-i.
*   **Podman süsteemi parandamiseks (`--system` lüliti):** Kui Podman VM on kettaruumist tühi või läinud lukku ja vajab süvapuhastust (prune).

---

## 🚀 Google Antigravity Desktop GUI Sandbox (`run-antigravity-sandbox.sh`)

Skript `./scripts/run-antigravity-sandbox.sh` paigaldab ja käivitab **Google Antigravity IDE natiivse töölauarakenduse (GUI)** täielikult isoleeritud **Podman liivakastis** (`antigravity-sandbox`), suunates graafilise akna macOS ekraanile läbi XQuartz X11 protokolli.

**Kasutamine:**
```bash
# 1. Käivita töölauarakendus Podman konteineris:
./scripts/run-antigravity-sandbox.sh

# 2. Ehita konteineri pilt uuesti:
./scripts/run-antigravity-sandbox.sh --build

# 3. Peata ja kustuta liivakast:
./scripts/run-antigravity-sandbox.sh --stop
```

---

## 🛠️ Sisemised Abiskriptid (`scripts/internal/`)

Kõik sisemised paigaldus-, profiili-, SQL- ja abiskriptid asuvad alamkataloogis `scripts/internal/`. Nende detailse kirjeldustabeli leiad eraldi juhendist:
*   📁 **[scripts/internal/README.md](internal/README.md)** (Profiilimootor, SQLcl abiskriptid, SEPS Walletid, sertifikaadid ja paigaldajad).

---

## 🛑 Veaotsing: Millal teostada Podman Machine taaskäivitus? (`podman machine stop && podman machine start`)

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


