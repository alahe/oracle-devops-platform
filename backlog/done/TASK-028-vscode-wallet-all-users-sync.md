# [TASK-028]: VS Code SQL Developer Ühenduste Täielik Sünkroniseerimine Walletiga ja Automaattest

**Staatus:** `DONE`  
**Prioriteet:** `HIGH`  
**Valdkond:** `Tooling` | `Security` | `Architecture`  
**Seotud Blueprintid / Profiilid:** Kõik blueprintid (1–13) ja andmebaasiprofiilid (`config/profiles/databases/*.yaml`)  
**Dokumentatsioon:** [connections/README.md](../../connections/README.md), [scripts/README.md](../../scripts/README.md)  

---

## 1. Probleemi Kirjeldus ja Kontekst
Varasemalt ei registreerinud [`scripts/register-connections.sh`](../../scripts/register-connections.sh) kõiki Oracle SEPS Walletis ja YAML profiilides defineeritud andmebaasikasutajaid VS Code laiendusse (*Oracle SQL Developer for VS Code*):
1. **Puuduvad rollid:** Registreerimata jäid rollid nagu `DBA_ADMIN`, `VIEWER`, spetsiifilised skeemikontod (`LIS_SCHEMA`, `PUBLISHER_READER`) või personaalsed arendajakontod.
2. **Puudus automaatne terviklikkuse kontroll:** Puudus automaattest, mis kontrolliks, kas 100% andmebaasi kontodest on VS Code failides (`~/.sqldev/connections.json`, `~/.dbtools/connections/`) esindatud.

---

## 2. Eesmärk ja Realiseeritud Tulemus
1. **Kõigi kasutajate automaatne registreerimine:**
   - Iga aktiivse andmebaasi kohta luuakse oma kaust (`/db-proxy`, `/db-lis`, `/db-publisher` jne) ja registreeritakse kõik rollid:
     - `1. Sys (${c_name})` (`SYSDBA` roll)
     - `2. DBA_ADMIN (${c_name})`
     - `3. SCHEMA (${c_name})` (nt `APEX_PROXY_SCHEMA`, `LIS_SCHEMA`)
     - `4. DEV (${c_name})` (nt `TEST_DEV`)
     - `5. VIEWER (${c_name})` (nt `TEST_VIEWER`)
     - Personaalsed arendajad (`EXTRA_DEV_USER`, `DEVELOPER_USER`) ja eraldi rollid (`PUBLISHER_READER`).
2. **Korduvate veebikontode välistamine:**
   - APEX veebikontosid (`TEST_WEB_USER` jms) ei lisata andmebaasi SQL ühendusteks (`ORA-01017` vältimine).
3. **Automaatne Terviklikkuse Test:**
   - Loodud [`tests/unit/test-vscode-wallet-connections.sh`](../../tests/unit/test-vscode-wallet-connections.sh), mis valideerib 100% andmebaasikasutajate olemasolu.
4. **`DBTU-03001` Vea Ennetamine:**
   - Puhastab `folders.json` orvudest GUID viidetest vastavalt skill `vscode_sql_developer` reeglitele.

---

## 3. Verifitseerimine ja Testid
- **Ühiktest:** [`tests/unit/test-vscode-wallet-connections.sh`](../../tests/unit/test-vscode-wallet-connections.sh) (PASS).
- **Kõik 58 ühiktesti:** Läbitud edukalt (`tests/unit/*.sh`).
