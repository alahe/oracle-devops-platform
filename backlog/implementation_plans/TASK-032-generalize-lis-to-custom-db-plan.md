# Tegevuskava: TASK-032 — LIS Nime ja Viidete Asendamine Üldise 'db-custom' Mudeliga

## 1. Ülevaade ja Eesmärk
Praeguses koodibaasis viitavad mitmed andmebaasid, profiilid, ORDS basseinid ja blueprintid spetsiifilisele laborirakendusele (**LIS** ehk *Laboratory Information System*). 

Et muuta platvorm **täielikult universaalseks, domeenivabaks ja paindlikuks** mis tahes eritellimusel loodud äri- või klientrakenduse jaoks (APEX, Forms, PL/SQL, REST API), asendatakse spetsiifiline tähis `LIS` / `db-alise` universaalse standardiga:
- Konteineri nimi: **`db-custom`**
- Keskkonnamuutuja: **`DB_CUSTOM`** (koos automaatse `DB_ALISE` tagasiühilduvusega)
- ORDS bassein / REST marsruut: **`/ords/custom/`**
- SEPS Wallet aliased: **`DB_CUSTOM_SYS`**, **`DB_CUSTOM_DBA_ADMIN`**, **`DB_CUSTOM_DEV`**, **`DB_CUSTOM_APP`**, **`DB_CUSTOM_VIEWER`**
- Profiilifailid: **`db-custom-oracle.yaml`**, **`db-custom-gvenzl.yaml`**, **`db-custom-adb.yaml`**

---

## 2. Kavandatavad Muudatused Komponentide Kaupa

### A. Andmebaasi Profiilid (`config/profiles/databases/`)
- [NEW] `config/profiles/databases/db-custom-oracle.yaml` (asendab `db-alise-oracle.yaml`)
  - Container name: `db-custom`
  - Port: `1533`
  - Wallet aliased: `DB_CUSTOM_SYS`, `DB_CUSTOM_DBA_ADMIN`, `DB_CUSTOM_DEV`, `DB_CUSTOM_APP`, `DB_CUSTOM_VIEWER`
- [NEW] `config/profiles/databases/db-custom-gvenzl.yaml` (asendab `db-infra-gvenzl.yaml`)
- [NEW] `config/profiles/databases/db-custom-adb.yaml` (asendab `db-alise-adb.yaml`)
- [MODIFY] `config/profiles/databases/README.md`

### B. ORDS Konfiguratsioon ja Basseinid (`config/ords/`)
- [NEW] `config/ords/databases/custom/pool.xml` (asendab `config/ords/databases/lis/pool.xml`)
  - Ühendub `db-custom:1521/FREEPDB1`
  - URL mapping: `/ords/custom/`
- [MODIFY] `config/ords/README.md` ja ORDS mallid

### C. Blueprintid (`config/blueprints/`)
- [MODIFY] `.env.1-only-db-custom` (endine `.env.1-only-db-alise`, `DB_CUSTOM=db-custom-oracle`)
- [MODIFY] `.env.2-db-custom-with-apex-ords` (endine `.env.2-db-alise-with-apex-ords`)
- [MODIFY] `.env.3-db-custom-apex-ords-with-proxy` (endine `.env.3-db-alise-apex-ords-with-proxy`)
- [MODIFY] `.env.6-gvenzl-dev-light` (`DB_CUSTOM=db-custom-gvenzl`)
- [MODIFY] `.env.7-hybrid-multi-vendor-db` (`DB_PROXY=db-proxy-oracle`, `DB_CUSTOM=db-custom-gvenzl`)
- [MODIFY] `.env.11-publisher-full-enterprise`, `.env.12-publisher-minimal-hybrid` (`DB_CUSTOM=db-custom-oracle`)
- [MODIFY] `.env.21-forms-full-enterprise`, `.env.22-forms-minimal-hybrid` (`DB_CUSTOM=db-custom-oracle`)
- [MODIFY] `.env.30-dev-workstation-with-web-ide`, `.env.33-full-enterprise-sandbox-web-ide` (`DB_CUSTOM=db-custom-oracle`)
- [MODIFY] `config/blueprints/README.md`

### D. Orkestreerimise ja Abiskriptid (`scripts/` & `scripts/internal/`)
- [MODIFY] `scripts/internal/resolve-topology.sh`:
  - Asendada `DB_ALISE` $\rightarrow$ `DB_CUSTOM` (koos tagasiühilduvusega: `DB_CUSTOM="${DB_CUSTOM:-$DB_ALISE}"`).
  - Kaardistada konteiner `db-custom` (port 1533).
- [MODIFY] `scripts/internal/generate-compose-override.sh`:
  - Luua teenuse definitsioon `db-custom`.
- [MODIFY] `scripts/internal/generate-passwords.sh`:
  - Luua secret `custom_db_sys_password` (ja hoida fallbackina `lis_db_sys_password`).
- [MODIFY] `scripts/internal/create-wallet.sh`:
  - Registreerida `DB_CUSTOM_*` aliased (ja ühilduvuse `DB_ALISE_*`).
- [MODIFY] `scripts/get-password.sh`:
  - Toetada `CUSTOM` / `DB_CUSTOM_*` otsinguid.
- [MODIFY] `scripts/setup-all.sh`:
  - Uuendada lõpparuande ja ühenduste puudiagrammi viited (`db-custom`).
- [MODIFY] `scripts/register-connections.sh`:
  - Registreerida VS Code ühenduste kaust `db-custom`.

### E. Dokumentatsioon ja Testid
- [MODIFY] `README.md`, `connections/README.md`, `docs/turvalisus.md`.
- [MODIFY] Kõik ühikutestid (`tests/unit/*.sh`), mis kontrollivad topoloogiat ja profiile.

---

## 3. Verifitseerimise Plaan
1. Topoloogia ja profiilide laadimise test: `./tests/unit/test-forms-profile-and-topology.sh`, `./tests/unit/test-script-resolve-topology.sh`.
2. Käsuliini ja blueprintide inspektsioon: `./scripts/setup-all.sh --list-blueprints`, `./scripts/setup-all.sh -sb 3`.
3. Kõigi 67 ühikutesti kontroll: `for t in tests/unit/*.sh; do bash "$t"; done` (Tagada 100% PASS).
