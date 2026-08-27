# [TASK-027]: Multi-DB SEPS Walleti ja TNS Aliaste Täielik Sünkroniseerimine ning Ülevaatus

**Staatus:** `DONE`  
**Prioriteet:** `HIGH`  
**Valdkond:** `Security` | `Architecture` | `Tooling`  
**Seotud Blueprintid / Profiilid:** Kõik mitme andmebaasiga profiilid (nt Blueprint 3 / `db-proxy` + `db-lis`, `publisher`, `full enterprise` jne)  
**Dokumentatsioon:** [docs/turvalisus.md](../turvalisus.md), [connections/README.md](../../connections/README.md), [scripts/README.md](../../scripts/README.md)  

---

## 1. Probleemi Kirjeldus ja Kontekst
Mitme andmebaasiga keskkondade (`db-proxy`, `db-lis`, `db-publisher`) käivitamisel ilmnesid autentimistõrked (`ORA-01017: invalid credential or not authorized; logon denied` ja `ORA-12154: Could not find alias in tnsnames.ora`), kui ühenduti paroolivabalt läbi Oracle SEPS Walleti (nt `sql /@DB_DB_LIS_SYS as sysdba`):

1. **Multi-DB Saladuste pärimine:** `create-wallet.sh` funktsioon `get_container_secret` langes vaikimisi `apex_db_sys_password` saladusele tagasi, jättes arvestamata konteineripõhised saladused (`lis_db_sys_password`). Seetõttu kirjutas Wallet `db-lis` SYS parooliks teise andmebaasi parooli.
2. **Aliaste nimekujude lahknevus:** Walletisse loodi lühike alias `DB_LIS_SYS`, samas kui `tnsnames.ora` faili tekkis täisnimega alias `DB_DB_LIS_SYS`.
3. **Oracle Thin JDBC Wallet Location:** Oracle JDBC Thin draiver (mida SQLcl kasutab) vajas süsteemset JVM omadust `-Doracle.net.wallet_location=$TNS_DIR` lisaks olemasolevale `-Doracle.net.tns_admin=$TNS_DIR`.

---

## 2. Eesmärk ja Oodatav Tulemus
1. Tagada, et paroolivabad SEPS Walleti ühendused töötavad 100% stabiilselt ja veavabalt kõigi andmebaasi instantside ja kasutajarollide puhul (`SYS as sysdba`, `DEV`, `VIEWER`, `DBA_ADMIN`, `SCHEMA`).
2. Toetada automaatselt nii lühikesi kui pikki TNS aliaseid (nt `DB_LIS_SYS` JA `DB_DB_LIS_SYS`), vältides arendaja või CI/CD eksimusi aliaste valikul.
3. Säilitada turvalisus: mitte ükski parool ei tohi lekkida käsurea argumentidesse ega protsessitabelisse (`ps aux`).

---

## 3. Tehniline Teostus ja Seotud Failid

### 3.1 [`scripts/internal/create-wallet.sh`](../../scripts/internal/create-wallet.sh)
- Funktsioon `get_container_secret` otsib dünaamiliselt konteinerispetsiifilisi saladusi (`${c_short}_db_sys_password`, `${c_short}_dev_password` jne).
- Genereerib Walletisse ja `tnsnames.ora` failidesse automaatselt mõlemad aliase nimekujud:
  - `DB_${SHORT_NAME}_*` (nt `DB_LIS_SYS`, `DB_LIS_DEV`, `DB_LIS_DBA_ADMIN`, `DB_LIS_VIEWER`)
  - `DB_${FULL_NAME}_*` (nt `DB_DB_LIS_SYS`, `DB_DB_LIS_DEV`, `DB_DB_LIS_DBA_ADMIN`, `DB_DB_LIS_VIEWER`)

### 3.2 [`scripts/sqlcl.sh`](../../scripts/sqlcl.sh)
- Keskkonnamuutuja `JAVA_TOOL_OPTIONS` sisaldab:
  ```bash
  export JAVA_TOOL_OPTIONS="-Doracle.net.tns_admin=$TNS_DIR -Doracle.net.wallet_location=$TNS_DIR -XX:+TieredCompilation -XX:TieredStopAtLevel=1"
  ```
- Rakendatud `unset JAVA_HOME` vastavalt Workspace Rule 6 reeglile.

### 3.3 [`scripts/get-password.sh`](../../scripts/get-password.sh)
- Aliase normaliseerimine: eraldab konteineri prefiksi (`target_c_prefix`) ja otsib vastavat Podman saladust, kui Walletist ei leita otsevastet või kui Wallet tagastab binaarmärke.

### 3.4 [`scripts/check-wallet.sh`](../../scripts/check-wallet.sh)
- Kontrollib paroolivabalt kõiki aktiivseid TNS aliaseid ning kuvab selge maatriksi aktiivsete ja mitteaktiivsete basseinide kohta.

---

## 4. Verifitseerimine ja Testid
- **Ühiktest:** [`tests/unit/test-multi-db-seps-wallet.sh`](../../tests/unit/test-multi-db-seps-wallet.sh) (PASS).
- **Kõik 57 ühiktesti:** Läbitud edukalt (`tests/unit/*.sh`).
