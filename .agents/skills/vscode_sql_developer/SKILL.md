---
name: vscode_sql_developer_registration
description: Juhis VS Code Oracle SQL Developer laienduse ühenduste, krüpteeritud paroolide ja kaustade automaatseks registreerimiseks ning saniteerimiseks SQLcl connmgr utiliidi kaudu.
---

# VS Code Oracle SQL Developer: Ühenduste ja Kaustade Registreerimine

See skill juhendab, kuidas automaatselt konfigureerida ja registreerida Oracle andmebaasi ühendusi, salvestatud krüpteeritud paroole ja kaustade struktuuri **VS Code Extension: Oracle SQL Developer** laienduse jaoks.

---

## 1. Arhitektuur ja Toimimise Mehhanism

Modernne VS Code Oracle SQL Developer laiendus (versioonid 23.4+) ei kasuta turvalisuse ja Keychain integratsiooni tõttu lihtsat staatilist `connections.json` faili, vaid toetub **sisemisele SQLcl utiliidile** ja `.dbtools` struktuurile:

*   **Asukoht kettal:** `~/.dbtools/connections/<GUID>/dbtools.properties`
*   **Kaustade struktuur:** `~/.dbtools/connection_folders/folders.json`
*   **Sisemine SQLcl:** `$HOME/.vscode/extensions/oracle.sql-developer-*/dbtools/sqlcl/bin/sql`

❌ **Keelatud muster:** Käsitsi `.properties` või `folders.json` failide kirjutamine tekitab vigaseid `string-ID` viiteid ja murrab paroolide krüpteeringu.
✅ **Õige muster:** Registreerimine tuleb teostada **VS Code laiendusega kaasas oleva SQLcl utiliidi** käskudega `connect -save` ja `connmgr`.

---

## 2. Natiivne Registreerimise Töövoog (SQLcl Commands)

Ühenduste ja kausta loomine toimub järgmise käsundiseeria abil SQLcl käsureal:

```sql
-- 1. Puhasta ja loo sihtkaust
connmgr delete -folder /<folder_name> -force
connmgr add -folder /<folder_name>

-- 2. Ühendu, krüpteeri ja salvesta parool OS Keychaini (-savepwd -replace)
connect -save "1. Sys" -savepwd -replace sys/SinuParool@localhost:1532/FREEPDB1 as sysdba
connmgr move -conn "1. Sys" /<folder_name>

connect -save "2. APEX_PROXY_SCHEMA" -savepwd -replace APEX_PROXY_SCHEMA/SinuParool@localhost:1532/FREEPDB1
connmgr move -conn "2. APEX_PROXY_SCHEMA" /<folder_name>

-- 3. Kontrolli tulemust
connmgr list -folder /<folder_name>
```

---

## 3. `DBTU-03001` Vea Ennetamine ja `folders.json` Saniteerimine

### Vea Põhjus (`DBTU-03001`):
Kui `~/.dbtools/connection_folders/folders.json` failis on alles vana projekti või kustutatud ühenduse ID (nt `"2ZuMX6avghyexCrZQ89W_Q"`), kuid sellele vastavat kausta `~/.dbtools/connections/2ZuMX6avghyexCrZQ89W_Q/` kettal enam ei ole, viskab VS Code käivitumisel vea `DBTU-03001` ja peidab kõik kaustad.

### Automaatne Saniteerimise Muster (`jq` / Bash):
Skriptis tuleb alati pärast registreerimist puhastada `folders.json` orvudest:

```bash
FOLDERS_FILE="$HOME/.dbtools/connection_folders/folders.json"
DBTOOLS_CONNS_DIR="$HOME/.dbtools/connections"

if [ -f "$FOLDERS_FILE" ] && command -v jq &>/dev/null; then
  # Tuvasta kettal tegelikult olemasolevad GUID kaustad
  valid_ids=($(find "$DBTOOLS_CONNS_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null || true))
  VALID_IDS_JSON=$(printf '%s\n' "${valid_ids[@]}" | jq -R . | jq -s .)

  # Eemalda folders.json failist kõik orvud ID-d
  jq --argjson valid "$VALID_IDS_JSON" '
    .folders = [
      .folders[]? |
      .connections = [ .connections[]? | select(. as $c | $valid | index($c)) ]
    ] |
    .folders = [ .folders[]? | select((.connections | length) > 0) ]
  ' "$FOLDERS_FILE" > "${FOLDERS_FILE}.tmp" 2>/dev/null && mv "${FOLDERS_FILE}.tmp" "$FOLDERS_FILE" 2>/dev/null || true
fi
```

---

## 4. Dünaamiline Sünkroniseerimine (`dbtools.properties` + `connections.json`)

Toetmaks nii modernseid (`~/.dbtools`) kui ka teisi VS Code laienduse versioone (`~/.sqldev/connections.json` / `~/.dbtools/connections.json`), tagab skript `register-connections.sh` automaatse dubleeritud sünkroniseerimise:
1. Natiivsed krüpteeritud Keychain paroolid ja kaustad: SQLcl `connect -save` ja `connmgr move`.
2. HEX Värvikoodid: `$HOME/.dbtools/connections/*/dbtools.properties` (`color=#HEX`).
3. Laienduse otsene JSON konfiguratsioon: `$HOME/.sqldev/connections.json` ja `$HOME/.dbtools/connections.json` uuendatakse täieliku kaustastruktuuri, paroolide ja värvidega.

---

## 6. Dünaamiline Käsurea Wrapper ja Kesta Integratsioon (`scripts/sqlcl.sh`)

Süsteem toetab otseühendusi kasutaja käsurealt (nt `sql /@DB_APEX_PROXY_SYS as sysdba` ja `sql /@DB_TEST_DEV`):

### 6.1 Wrapperi Loogika (`scripts/sqlcl.sh`):
1. **Puhas `JAVA_TOOL_OPTIONS`:** Seab AINULT `export JAVA_TOOL_OPTIONS="-Doracle.net.tns_admin=$TNS_DIR"`. Eemaldab varasemad dubleeritud lipud, et ennetada Java System Property parseri viga `Syntax error at column 14: '`.
2. **`JAVA_HOME` Puhastamine:** Teeb `unset JAVA_HOME` enne SQLcl käivitamist, vältimaks vanade Java versioonide (nt SQL Developer Java 11) sekkumist VS Code SQLcl 26.2 (Java 21+) käivitusprotsessi.
3. **Parooli fallback võimendus (`view-wallet-credential.sh`):** Kui `mkstore -viewEntry` tagastab krüpteeritud binaarbaidid (`.'???...` või `[[ "$PWD_VAL" == *"?"* ]]`), päritakse parool automaatselt Podman secret store'ist (`apex_db_sys_password`, `apex_db_dev_password` jne).
4. **Süsteemne binary wrapper (`/Users/allanlahe/Applications/sqlcl/bin/sql` & `/opt/homebrew/Caskroom/sqlcl/.../bin/sql`):** Asendab või täiendab süsteemseid SQLcl binaare projekti wrapperiga, tagades et otsene käsk `sql` töötab sõltumata sellest, kas kasutaja kest laadis `alias sql` või mitte.

---

## 7. Stabiilsusleping ja Regressiooni Vältimise Reeglid (Stability Contracts)

Et vältida olukordi, kus ühe vea parandamisel tekib teine või vana viga tuleb tagasi, peavad kõik skriptid ja AI assistendid järgima **5 kohustuslikku stabiilsusreeglit**:

### 1. Kanooniline SQLcl Versiooni Tuvastus (Binary Resolution Order):
Skript peab alati valima VS Code laienduse **uusima SQLcl versiooni**:
```bash
VSCODE_SQLCL=$(find "$HOME/.vscode/extensions" -name "sql" -path "*/oracle.sql-developer-*/dbtools/sqlcl/bin/sql" 2>/dev/null | sort -rV | head -n 1)
```
Keelatud on loota pelgalt süsteemse `$PATH` muutuja peale ilma keskkonda saniteerimata.

### 2. Keskkonnamuutujate Saniteerimise Reegel (Environment Isolation):
Enne SQLcl väljakutsumist tuleb **alati teostada `unset JAVA_HOME`**, et vältida vanade seadistuste (nt SQL Developer Java 11) sekkumist VS Code SQLcl 26.2 (Java 21+) töösse. `JAVA_TOOL_OPTIONS` peab sisaldama AINULT:
```bash
export JAVA_TOOL_OPTIONS="-Doracle.net.tns_admin=$TNS_DIR"
```
Keelatud on korduvate `-Doracle.net.wallet_location=(SOURCE=...)` sulgudega lippude aheldamine (hoiab ära vea `Syntax error at column 14: '`).

### 3. Binaarparooli Tuvastuse ja Secret Fallback Reegel:
`mkstore -viewEntry` väljundit ei tohi kunagi otse SQLcl-ile edastada ilma kontrollita. Kui parool sisaldab binaarmärke või küsimärke (`[[ "$PWD_VAL" == *"?"* ]]`), tuleb parool lugeda automaatselt Podman secret store'ist (`apex_db_sys_password`, `apex_db_dev_password` jne).

### 4. POSIX Kesta Ühilduvuse Reegel (Shell Portability):
Keelatud on kasutada Bashi-spetsiifilisi sisefunktsioone (nagu `${ALIAS,,}`), mis murduvad `sh` / `zsh` all sisselugemisel. Kasutada tuleb porditavaid `tr '[:upper:]' '[:lower:]'` ja `awk` käske.

### 5. Multi-Shell Registreerimise Reegel:
Kesta integratsioonil tuleb lisada `TNS_ADMIN` ja `alias sql` **kõikidesse kesta profiilidesse** (`~/.zshrc`, `~/.zshenv`, `~/.bashrc`, `~/.bash_profile`) ning tagada käivitatav wrapper kaustas `~/Applications/sqlcl/bin/sql`.

---

## 8. Projekti Reeglid ja Piirangud

1. **Kausta nimi `.env` failist:** Kausta nimi pärineb dünaamiliselt `.env` / `repository.env` muutujatest (`VSCODE_FOLDER_NAME` -> `DB_CONN_NAME` -> `CONTAINER_NAME`).
2. **Paroolid Oracle Walletist (SEPS):** Paroolid päritakse ALATI `./scripts/internal/view-wallet-credential.sh <alias>` kaudu.
3. **Konfiguratsioon YAML profiilist:** Kasutajad ja pordid loetakse `config/profiles/*.yaml` failist. Koodis ei ole ühtegi kõvakodeeritud kasutajat ega parooli.
4. **Veebikasutajate välistamine:** APEX veebikontosid (nt `TEST_WEB_USER`) ei lisata andmebaasi SQL ühendusteks, kuna nende autentimine toimub läbi ORDS HTTP liidese (`ORA-01017` vältimine).
