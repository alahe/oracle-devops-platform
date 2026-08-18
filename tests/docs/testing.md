# Testimisjuhend ja Testikava (Testing Plan)

See dokument kirjeldab testimismetoodikat, testjuhtumeid ja samme, mille abil verifitseerida mitme APEX/ORDS versiooni paralleelset tööd, Autonomous Database (ADB) režiimi ning lokaalset Transparent Data Encryption (TDE) andmete krüpteerimist.

---

### Testjuhtum F0: Dünaamiliste profiilide ja topoloogia testimine (`test-db-profiles-and-topology.sh`)
*   **Eesmärk:** Kinnitada profiilide YAML laadimist, 3-tasemelist prioriteeti (Artifactory sise-register) ja topoloogia portide konflikti lahendajat.
*   **Sammud:**
    1. Käivita automaatne testskript:
       ```bash
       ./tests/test-db-profiles-and-topology.sh
       ```
    *   *Detailne juhend:* Vaata [profiles-and-topology-testing.md](profiles-and-topology-testing.md).

### Testjuhtum F1: Mitme paralleelse APEX/ORDS versiooni käivitamine (Dev)
*   **Eesmärk:** Kinnitada, et peabaas (APEX 24.1) ja lisabaas (APEX 23.2) töötavad paralleelselt ilma konfliktideta ja vahendavad õigeid staatilisi faile.
*   **Sammud:**
    1. Seadista `.env` failis muutujad järgmiselt:
       ```env
       ADDITIONAL_DATABASES="custom3"
       APEX_DB_APEX_VERSION=24.1
       APEX_DB_ORDS_VERSION=24.1
       ORDS_PORT=8088

       DB_custom3_APEX_VERSION=23.2
       DB_custom3_ORDS_VERSION=23.2
       DB_custom3_ORDS_PORT=8089
       ```
    2. Käivita täispaigaldus:
       ```bash
       ./scripts/setup-all.sh --force
       ```
    3. Kontrolli konteinerite olekut käsurealt:
       ```bash
       podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
       ```
       *Oodatav tulemus:* Konteinerid `oracle-db-apex-proxy`, `oracle-db-custom3`, `oracle-ords-dev` ja `oracle-ords-custom3` on olekus `Up (healthy)`.
    4. Ava brauseris mõlema APEX-i liidesed:
       *   Peabaas: `http://localhost:8088/ords/apex` (APEX 24.1)
       *   Lisabaas: `http://localhost:8089/ords/apex` (APEX 23.2)
       *Oodatav tulemus:* Mõlemad veebilehed avanevad edukalt ja sisselogimise lehe allnurgas kuvatakse vastavalt õige versiooninumber (24.1 ja 23.2).

### Testjuhtum F2: Autonomous Database (ADB) tugi ja mTLS Wallet
*   **Eesmärk:** Kinnitada, et andmebaasi tüübiks `ADB` määramisel kasutatakse eelinstalleeritud APEX-it ja ORDS-i ning mTLS wallet kopeeritakse korrektselt hosti.
*   **Sammud:**
    1. Puhasta eelmine keskkond:
       ```bash
       ./scripts/reset-all.sh all --force
       ```
    2. Seadista `.env` failis muutujad:
       ```env
       APEX_DB_TYPE=ADB
       APEX_DB_IMAGE=container-registry.oracle.com/database/adb-free:latest
       ```
    3. Käivita paigaldus:
       ```bash
       ./scripts/setup-all.sh --force
       ```
    4. Kontrolli, et:
       *   Kohalikku ORDS-i konteinerit ei käivitatud (kuna ADB-l on ORDS sees).
       *   Hosti kaustas `config/tns_admin/` on olemas mTLS wallet failid (`cwallet.sso`, `ewallet.p12`) ja andmebaasi poolt genereeritud `tnsnames.ora`.
    5. Testi ühendust läbi hosti SQLcl:
       ```bash
       sql /@free_low
       ```
       *Oodatav tulemus:* Ühendus luuakse edukalt ilma paroolita, kasutades SEPS walletit.

---

## 2. Mittefunktsionaalsed Testid (Non-Functional Tests)

### Testjuhtum NF1: Transparent Data Encryption (TDE) kontroll kettal
*   **Eesmärk:** Veenduda, et andmefailid lokaalsel kettal on krüpteeritud ja Keystore (wallet) on avatud.
*   **Sammud:**
    1. Ühendu andmebaasi (peabaas või lisabaas) seest `sysdba` õigustes:
       ```bash
       podman exec -it oracle-db-apex-proxy sqlplus / as sysdba
       ```
    2. Kontrolli TDE Keystore (wallet) staatust:
       ```sql
       SELECT status, wallet_type FROM v$encryption_wallet;
       ```
       *Oodatav tulemus:* `status` peab olema `OPEN` ja `wallet_type` peab olema `AUTOLOGIN` (arenduses).
    3. Kontrolli, kas tabeliruumid on krüpteeritud:
       ```sql
       SELECT tablespace_name, encrypted FROM dba_tablespaces;
       ```
       *Oodatav tulemus:* Kasutajate tabeliruumid (nt `APEX_PROXY_TS` või `PUBLISHER_TS`) peavad näitama `YES`.

### Testjuhtum NF2: Ajutiste (ephemeral) konteinerite puhtus (DevOps reegel)
*   **Eesmärk:** Veenduda, et CLI ja Liquibase operatsioonid ei jäta taustale rippuma orvuks jäänud või poolikuid konteinereid.
*   **Sammud:**
    1. Jälgi aktiivseid ja peatatud konteinereid pärast paigaldusskripti valmimist:
       ```bash
       podman ps -a
       ```
       *Oodatav tulemus:* Nimekirjas ei tohi olla ühtegi ajutist SQLcl või Liquibase ühekordset konteinerit (tuvastatav juhuslike nimede järgi). Kõik ühekordsed sammud peavad käivituma `--rm` võtmega.

### Testjuhtum NF3: Täielik puhastus (Reset Cleanliness)
*   **Eesmärk:** Veenduda, et `./scripts/reset-all.sh all` kustutab kõik ajutised failid, saladused ja paroolid.
*   **Sammud:**
    1. Käivita puhastus:
       ```bash
       ./scripts/reset-all.sh all --force
       ```
    2. Kontrolli failisüsteemi ja Podmani olekut:
       *   `ls -la .env` -> Fail ei tohi eksisteerida.
       *   `ls -la podman-compose.override.yml` -> Fail ei tohi eksisteerida.
       *   `ls -la db-install/` -> Kataloog ei tohi eksisteerida (lahtipakitud kood puhastatud).
       *   `podman secret ls` -> Ühtegi hoidlaga seotud parooli/saladust ei tohi olla nimekirjas.
       *   `podman volume ls` -> Ühtegi projekti andmevolume'i ei tohi olla alles.
