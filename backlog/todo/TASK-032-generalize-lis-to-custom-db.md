# [TASK-032]: LIS Nime ja Viidete Asendamine Üldise 'db-custom' / 'custom' Mudeliga

**Staatus:** `TODO`  
**Prioriteet:** `HIGH`  
**Valdkond:** `Architecture`  
**Seotud Blueprintid / Profiilid:** Kõik Custom/LIS andmebaasiga blueprintid (`.env.1-*`, `.env.2-*`, `.env.3-*`, `.env.7-*`, `.env.11-*`, `.env.12-*`, `.env.21-*`, `.env.22-*`, `.env.30-*`, `.env.33-*`)

---

## 1. Probleemi Kirjeldus ja Kontekst
Praeguses koodibaasis viitavad mitmed andmebaasid, profiilid, ORDS basseinid ja blueprintid spetsiifilisele laborirakendusele (**LIS** ehk *Laboratory Information System*). 

Et muuta platvorm **täielikult universaalseks, domeenivabaks ja paindlikuks** mis tahes eritellimusel loodud äri- või klientrakenduse jaoks (APEX, Forms, PL/SQL, REST API), tuleb spetsiifiline tähis `LIS` / `db-alise` asendada universaalse standardiga (`db-custom` / `custom`).

---

## 2. Eesmärk ja Oodatav Tulemus
1. **Konteineri Nimi:** `db-alise` $\rightarrow$ `db-custom` (Port 1533).
2. **Keskkonnamuutuja:** `DB_ALISE` $\rightarrow$ `DB_CUSTOM` (koos automaatse `DB_CUSTOM="${DB_CUSTOM:-$DB_ALISE}"` tagasiühilduvusega).
3. **ORDS Bassein ja Marsruut:** `/ords/lis/` $\rightarrow$ `/ords/custom/` (`config/ords/databases/custom/pool.xml`).
4. **SEPS Walleti Aliased:** `DB_CUSTOM_SYS`, `DB_CUSTOM_DBA_ADMIN`, `DB_CUSTOM_DEV`, `DB_CUSTOM_APP`, `DB_CUSTOM_VIEWER` (koos `DB_ALISE_*` fallback aliase toega).
5. **Andmebaasi Profiilid:** `db-custom-oracle.yaml`, `db-custom-gvenzl.yaml`, `db-custom-adb.yaml`.
6. **Blueprintide Nimekiri:** `.env.1-only-db-custom`, `.env.2-db-custom-with-apex-ords`, `.env.3-db-custom-apex-ords-with-proxy` jne.

---

## 3. Tehniline Teostus ja Arhitektuur
- **Profiilid:** Luua `config/profiles/databases/db-custom-oracle.yaml`, `db-custom-gvenzl.yaml`, `db-custom-adb.yaml`.
- **ORDS:** Luua `config/ords/databases/custom/pool.xml`.
- **Blueprintid:** Uuendada `config/blueprints/` failid ja `README.md`.
- **Skriptid:** Uuendada `resolve-topology.sh`, `generate-compose-override.sh`, `generate-passwords.sh`, `create-wallet.sh`, `get-password.sh`, `register-connections.sh`, `setup-all.sh`.
- **Dokumentatsioon:** Uuendada `README.md`, `connections/README.md`, `docs/turvalisus.md`.

---

## 4. Verifitseerimine ja Automaattestid
- Käivitada ja läbida kõik 67 ühikutesti (`tests/unit/*.sh`).
- Kontrollida Blueprintide dry-run simulatsioone (`./scripts/setup-all.sh -b 3 --dry-run`).
- Kontrollida ORDS basseini ja SEPS Walleti ühenduste genereerimist.
