# Testiaruanne (Test Report)

See dokument võtab kokku projekti testimise kava (**[testing.md](testing.md)**) tulemused pärast muudatuste (Oracle Wallet paroolihaldus, HTTPS suunamised ja Windows/WSL kohandused) paigaldamist.

Testid teostati lokaalses keskkonnas kuupäeval **2026-08-09**.

---

## 📊 Kokkuvõte (Summary)

| Testi tase | Kirjeldus | Olek | Märkused |
| :--- | :--- | :--- | :--- |
| **Tase 1** | Süntaks & Staatiline Analüüs | **ROHELINE / PASSED** | Kõik Bash skriptid ja JSON seadistused valideeriti edukalt. |
| **Tase 2** | Komponentide Funktsionaalsus | **ROHELINE / PASSED** | Testkasutajad luuakse korrektselt; DB Scheduler Jobid on aktiivsed ja töötavad. |
| **Tase 3** | E2E & Teenuste Integratsioon | **ROHELINE / PASSED** | Teenuste HTTPS pordid, suunamised, paroolide lugemine Walletist ning Golden Snapshot varukoopia/taastamine toimivad 100%. |

---

## 🛠 Tase 1: Süntaks ja JSON valideerimine
*   **Bash skriptide kontroll (`bash -n`):** Läbitud. Ühtegi süntaksiviga ei leitud skriptides `scripts/*.sh` ja `scripts/internal/*.sh`.
*   **JSON seadistusfailide valideerimine:** Läbitud. Kõik `connections/*.json` failid on korrektses JSON formaadis.
*   **Käivitatud käsk:**
    ```bash
    bash -n ./scripts/*.sh ./scripts/internal/*.sh && for f in ./connections/*.json; do python3 -m json.tool "$f" >/dev/null || exit 1; done
    ```

---

## ⚙️ Tase 2: Komponentide testid
*   **Arendaja kasutaja ja rollide loomine:** Läbitud. Kasutaja `TEST_DEV` luuakse korrektselt andmebaasi ja talle antakse `DB_DEVELOPER_ROLE`.
*   **Monitooringu Scheduler Job (`AUTO_ALERT_JOB`):** Läbitud. Job käivitati andmebaasis käsitsi ja selle olekuks logiti `SUCCEEDED`.
    *   *Käivitatud SQL:*
        ```sql
        EXEC DBMS_SCHEDULER.run_job('APEX_PROXY_SCHEMA.AUTO_ALERT_JOB');
        SELECT status FROM dba_scheduler_job_run_details WHERE job_name = 'AUTO_ALERT_JOB';
        ```
    *   *Tulemus:* `SUCCEEDED`

---

## 🚀 Tase 3: E2E Integratsioon ja Kasutusjuhtumid
*   **HTTP -> HTTPS ümbersuunamine (Port 8088 -> 8448):** Läbitud. Päring pordile `8088` tagastab ümbersuunamise staatuse `303` ja suunab korrektselt pordile `8448`.
*   **HTTPS APEX liides (Port 8448):** Läbitud. Päring pordile `8448` tagastab staatuse `200 OK` (leht on kättesaadav).
*   **Oracle Walletist paroolide lugemine:** Läbitud. Abiskript dekrüpteerib ja kuvab korrektselt nii `DB_APEX_PROXY_SYS` kui ka `DB_TEST_DEV` kasutajanimed ja paroolid ilma neid vahepeal failidesse kirjutamata.
    *   *Käivitatud käsk:*
        ```bash
        ./scripts/internal/view-wallet-credential.sh DB_TEST_DEV
        ```
*   **Hetktõmmise loomine (Golden Snapshot Backup):** Läbitud. Hetktõmmise utiliit `create-golden-snapshots.sh` peatab teenused, loob tihendatud arhiivi ja käivitab teenused uuesti (kestus: **2m 2s**).
*   **Hetktõmmisest taastamine (Golden Snapshot Restore):** Läbitud. Restore skript `restore-golden-snapshots.sh` taastab andmed arhiivist, teostab kohandatud iseparaneva konteinerite puhastuse ja käivitab uuesti kõik teenused koos ORDS `dev-ords` profiiliga (kestus: **1m 2s**).

---

## ☁️ Autonomous Database (ADB) režiimi E2E testimine ja sisselogimise verifitseerimine

Eraldi E2E testiseeria teostati Autonomous Database (`adb-free`) režiimis, kasutades käsku `./scripts/setup-all.sh --force --no-publisher`. 

### 1. APEX Tööruumi ja Kasutajate Provisioning
*   Loodi automaatselt APEX tööruum **`PROXY_WORKSPACE`**.
*   Tööruumi sisestati ja verifitseeriti järgmised kasutajad:
    *   `ADMIN` (Tööruumi administraator) – parool loetud Podmani saladustest (`apex_admin_password`).
    *   `TEST_DEV` (Arendaja) – parool loetud Podmani saladustest (`test_dev_password`).
    *   `TEST_WEB_USER` (Veebikasutaja) – parool `WebTestPass2026!`.

### 2. Veebiliidese sisselogimiste testimine (Browser Subagent)
*   **APEX Builder sisselogimine (`PROXY_WORKSPACE`):** Testitud ja läbitud kõigi kolme kasutajaga (`ADMIN`, `TEST_DEV`, `TEST_WEB_USER`). Brauser avab APEX-i tööruumi avalehe ja App Builderi korrektselt.
*   **Database Actions (SQL Developer Web) sisselogimine (`ADMIN`):** Testitud ja läbitud. Süsteem logib andmebaasi administraatorina sisse ja laeb töölauda.
*   **SQL Worksheet päringute käivitamine:** Läbitud. SQL Worksheetis käivitati edukalt kontrollpäring `select owner, table_name from all_tables where owner = 'ADMIN';`, mis tagastas tulemused ~0.4 sekundiga.

### 3. ORDS ja andmebaasi versioonide erinevuse hoiatus (Version Mismatch Warning)
*   *Tähelepanek:* Database Actions liideses võib kuvada hoiatuse, et ORDS tarkvara versioon (26.2.1) ei vasta andmebaasi sees olevale ORDS-i metaandmete skeemi versioonile.
*   *Lahendus/Selgitus:* See on `adb-free` konteineri režiimis ootuspärane käitumine, kuna Autonomous Database PDB sisaldab eelpaigaldatud ORDS-i metaandmeid, mis erinevad väljaspool PDB-d jooksva ORDS-i protsessi omast. Hoiatus on puhtalt informatiivne ning **ei takista** ühegi funktsionaalsuse toimimist (SQL päringud ja APEX Builder töötavad täielikult).

---

## 📝 Kokkuvõte
Kõik projektis kirjeldatud kasutusjuhtumid, ühenduste seadistused ja kasutajate sisselogimised toimivad nii kohalikus standardrežiimis kui ka Autonomous Database (ADB) režiimis korrektselt. Testimise plaan loetakse **edukalt sooritatuks**.
