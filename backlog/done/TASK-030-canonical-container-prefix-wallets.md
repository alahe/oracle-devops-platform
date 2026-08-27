# [TASK-030]: SEPS Walleti, Terminali Aruande ja VS Code Ühenduste Kanooniline Ühtlustamine

**Staatus:** `DONE`  
**Prioriteet:** `HIGH`  
**Valdkond:** `Architecture` | `Security` | `Tooling`  
**Seotud Blueprintid / Profiilid:** Kõik blueprintid (1–13) ja andmebaasiprofiilid (`config/profiles/databases/*.yaml`)  
**Dokumentatsioon:** [connections/README.md](../../connections/README.md), [scripts/README.md](../../scripts/README.md), [docs/turvalisus.md](../../docs/turvalisus.md)  

---

## 1. Probleemi Kirjeldus ja Kontekst
Varasemalt esines kolme erineva vaate vahel (Oracle SEPS Wallet, terminali paigalduse lõpparuanne ja VS Code SQL Developer laienduse puu) ebakõlasid:
1. **Topelt `DB_DB_...` aliased:** Stringide liitmise tõttu genereeriti eksitavaid topelt-aliaseid (nt `DB_DB_PROXY_DEV`).
2. **Pärand-aliased ja `SYS@FREE`:** Walletis leidusid vanad üldised aliased (`DB_DBA_ADMIN`, `DB_TEST_DEV`), mis ühendusid ekslikult juurbaasi `SYS@FREE`.
3. **VS Code numbrilõhed:** `db-lis` kaustas puudus number 3 (`1, 2, 4, 5`), kuna numbrid olid määratud staatiliste kasutajanimede järgi.
4. **Terminali aruande lahknevus:** Terminali hierarhia kuvas toor-aliaseid ilma kasutajasõbralike numbrite ja SQLcl kiirkäskudeta.

---

## 2. Eesmärk ja Realiseeritud Tulemus

### 2.1 Puhas Kanooniline Eesliide (`DB_<KONTEINER>_<ROLL>`)
- Konteineri nimi normaliseeritakse puhtalt:
  - `db-proxy` ➔ `DB_PROXY_SYS`, `DB_PROXY_DBA_ADMIN`, `DB_PROXY_SCHEMA`, `DB_PROXY_DEV`, `DB_PROXY_VIEWER`
  - `db-lis` ➔ `DB_LIS_SYS`, `DB_LIS_DBA_ADMIN`, `DB_LIS_DEV`, `DB_LIS_VIEWER`
  - `db-publisher` ➔ `DB_PUBLISHER_SYS`, `DB_PUBLISHER_READER`
  - `db-forms` ➔ `DB_FORMS_SYS`, `DB_FORMS_DEV`
- **0 dubleerimist:** Eemaldatud vigased `DB_DB_...` aliased ja pärand-aliased.
- Kõik ühendused lähevad alati õigesse PDB-sse (`FREEPDB1`).

### 2.2 VS Code Numbrite Dünaamiline Järjestus (1..N)
- [`scripts/register-connections.sh`](../../scripts/register-connections.sh) sorteerib kasutajad deterministlikult (`SYS` ➔ `DBA_ADMIN` ➔ `SCHEMA` ➔ `DEV` ➔ `VIEWER`) ja arvutab numbrid dünaamiliselt:
  - `1. Sys (${c_name})`
  - `2. DBA_ADMIN (${c_name})`
  - `3. TEST_DEV (${c_name})` (kui eraldi skeem puudub)
  - `4. TEST_VIEWER (${c_name})`
  - Kaotatud numbrilõhed (100% järjestikune numeratsioon igas kaustas).

### 2.3 Terminali Lõpparuande Täielik Ühtlustamine
- [`scripts/setup-all.sh`](../../scripts/setup-all.sh) kuvab terminalis täpselt sama struktuuri ja SQLcl käske:
  ```text
  📁 db-proxy (localhost:1532/FREEPDB1)
  │  ├── 🔴 1. Sys (db-proxy)               (SYSDBA -> sql /@DB_PROXY_SYS as sysdba)
  │  ├── 🔵 2. DBA_ADMIN (db-proxy)         (DBA     -> sql /@DB_PROXY_DBA_ADMIN)
  │  ├── 🟣 3. APEX_PROXY_SCHEMA (db-proxy) (Skeem   -> sql /@DB_PROXY_SCHEMA)
  │  ├── 🟢 4. TEST_DEV (db-proxy)          (Arendaja-> sql /@DB_PROXY_DEV)
  │  └── 🟡 5. TEST_VIEWER (db-proxy)       (Vaataja -> sql /@DB_PROXY_VIEWER)
  ```

---

## 3. Verifitseerimine ja Testid
- **Ühiktestid:** [`tests/unit/test-multi-db-seps-wallet.sh`](../../tests/unit/test-multi-db-seps-wallet.sh) ja [`tests/unit/test-vscode-wallet-connections.sh`](../../tests/unit/test-vscode-wallet-connections.sh) (PASS).
- **Kogu testikomplekt:** Kõik 58 ühiktesti läbitud edukalt (`All 58 unit tests OK`).
