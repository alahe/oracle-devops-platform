---
name: setup_orchestration_modularization
description: Juhised setup-all.sh ja reset-all.sh orkestreerimiskihi moduleerimiseks. Tagab, et peaskriptid ei sisalda kõvakodeeritud väärtusi ega äriloogikat — kõik parameetrid tulevad dünaamiliselt profiilidest ja abiskriptidest.
---

# Setup-All Orkestreerimiskiht: Moduleerimise Reeglid

See skill kirjeldab, kuidas `scripts/setup-all.sh` ja `scripts/reset-all.sh` peavad olema üles ehitatud ning milliseid reegleid tuleb järgida kogu keskkonna paigaldus- ja puhastusprotsesside arendamisel.

---

## 1. Peaskripti Eesmärk ja Vastutus

### `setup-all.sh` — Ainult Orkestreerija
`setup-all.sh` on **orkestreerimiskiht** (orchestration layer), mille ainsad kohustused on:

| Vastutus | Kirjeldus |
| :--- | :--- |
| **Käsurea parsimine** | `--force`, `--no-ords`, `--no-publisher` jms lippude vastuvõtmine ja edastamine. |
| **Kasutajalt kinnituse küsimine** | Enne tegevuste alustamist kuvatakse aktiivne profiil, topoloogia ja küsitakse luba jätkata. |
| **Etappide delegeerimine** | Iga tehniline samm kutsutakse välja `scripts/internal/*.sh` abiskriptist. |
| **Tagasiside andmine** | Progress bar, ajaloolised ooteajad (`metrics/`), sammude kestus ja logifailide teed. |
| **Mõõdikud ja logimine** | Ajamõõtmine ja tulemuste salvestamine `metrics/setup_benchmarks.json` ja `install_logs/` kaustadesse. |

### ❌ Skriptid ja Testid EI TOHI:
- Sisaldada äriloogikat peaskriptides
- Sisaldada kõvakodeeritud paroole, DB hostinimesid (nt `localhost:1521`), pordinumbreid, SID-e ega kõvakodeeritud konteinerite nimesid
- Otseselt teada, millist Oracle pilti või ORDS versiooni kasutatakse

---

## 2. Ainus Tõeallikas (Single Source of Truth)

Kogu süsteemi konfiguratsioon peab tulema **dünaamiliselt** järgmistest allikatest:

### A. YAML Profiilid (`config/profiles/*.yaml`)
Profiil määrab andmebaasi tüübi ja kõik selle parameetrid:

```yaml
database:
  container_image: container-registry.oracle.com/database/adb-free:latest
  workload_type: ATP
  db_sid: FREE           # ← ORACLE_SID väärtus
  db_pdb: MYATP          # ← ORACLE_PDB väärtus
  db_port: 1532          # ← Host-side port
  container_port: 1522   # ← Konteineri sisemine port
  admin_user: admin
  admin_role: NORMAL
  default_service: MYATP_low.adb.oraclecloud.com
  wallet_required: true
  configure_tde: true
  encrypt_tablespaces: ALL
```

### B. `.env` Fail (Kasutaja Seadistused)
`.env` fail määrab ainult aktiivse profiili nime ja hosti-poolsed parameetrid:

```bash
MAIN_DB_PROFILE=proxy-adb-oracle     # Viitab YAML profiilile
ORDS_URL=https://localhost:8443
ORDS_HTTP_PORT=8088
```

### C. `scripts/internal/load-db-profile.sh` (Profiilist Lugemine)
Funktsioon `load_db_profile` parsib YAML profiili ja ekspordib parameetrid muutujatesse:

```bash
load_db_profile "proxy-adb-oracle"
# → PROFILE_DB_SID="FREE"
# → PROFILE_DB_PDB="MYATP"
# → PROFILE_DB_PORT="1532"
# → PROFILE_CONTAINER_PORT="1522"
# → PROFILE_WORKLOAD_TYPE="ATP"
# → RESOLVED_DB_IMAGE="container-registry.oracle.com/database/adb-free:latest"
# → IS_ADB="true"
```

### D. Oracle Wallet (SEPS Credential Storage)
Kogu paroolide ja turvaliste rekvisiitide pärimine toimub eelistatult keskse utiliidi `scripts/internal/view-wallet-credential.sh <alias>` kaudu. **Kõik Walleti aliased loetakse dünaamiliselt aktiivsest YAML profiilist (`config/profiles/*.yaml`)**, tagades et kood ega skriptid ei sisalda kõvakodeeritud aliaste stringe (nagu `DB_APEX_PROXY_SYS`) ega paroolimuutujaid.

### E. Dünaamiline Konteineri Nime ja Hosti Lugemine (`get_active_db_instances`)

Konteinerite ega hostide nimesid ei tohi kunagi skriptidesse ega automaattestidesse kõvakodeerida (nt `db-apex-proxy` või `localhost:1521`). Kõik instantsid ja hostid tuleb lugeda dünaamiliselt `.env` failist ja aktiivsest profiilist:

```bash
# 1. Laeme profiili ja keskkonnamuutujad
if [ -f "$WORKSPACE_DIR/scripts/internal/load-db-profile.sh" ]; then
  source "$WORKSPACE_DIR/scripts/internal/load-db-profile.sh"
  load_db_profile >/dev/null 2>&1 || true
fi

# 2. Tuvastame dünaamiliselt aktiivse primaarse konteineri nime .env failist
PRIMARY_CONTAINER=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1)
PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-db-dev-full}"

# 3. Laeme baas-URLi ja hosti dünaamiliselt profiilist/env-ist ilma kõvakodeeringuteta
BASE_URL="${RESOLVED_ORDS_BASE_URL:-${ORDS_URL:-https://${RESOLVED_ORDS_HOST:-localhost}:${PROFILE_ORDS_HTTPS_PORT:-8448}}}"

# 4. Pärime paroolid dünaamiliselt SEPS Walletist
APEX_ADMIN_PWD=$("$WORKSPACE_DIR/scripts/internal/view-wallet-credential.sh" "APEX_ADMIN" 2>/dev/null | grep "Password:" | awk '{print $3}' | tr -d '\r\n')
```

---

## 3. Keelatud Mustrid (Anti-Patterns)

### ❌ 3.1 Kõvakodeeritud Paroolid
```bash
# KEELATUD – Varuparool koodis:
[ -z "$adb_admin_pwd" ] && adb_admin_pwd="OraclePass2026Admin"

# ÕIGE – Dünaamiline genereerimine:
if [ -z "$adb_admin_pwd" ]; then
  "$SCRIPT_DIR/internal/generate-passwords.sh" --force
  adb_admin_pwd=$(podman secret inspect --showsecret apex_db_sys_password ...)
fi
```

### ❌ 3.2 Kõvakodeeritud Konteinerite Nimed
```bash
# KEELATUD – Staatiline teenusenimi:
services:
  db-apex-proxy:
    image: ...

# ÕIGE – Dünaamiline nimi profiilist:
PROXY_SERVICE_KEY=$(get_active_db_instances | head -n 1 | cut -d'|' -f1)
cat <<EOF > "$OVERRIDE_FILE"
services:
  ${PROXY_SERVICE_KEY}:
    image: ${RESOLVED_DB_IMAGE}
EOF
```

### ❌ 3.3 Kõvakodeeritud Pordid, SID-d ja Teenuse Nimed
```bash
# KEELATUD:
- "$PORT:1521"
- ORACLE_SID=FREE
- DBPORT=1521

# ÕIGE:
- "${c_port}:${PROFILE_CONTAINER_PORT}"
- ORACLE_SID=${PROFILE_DB_SID}
- DBPORT=${PROFILE_CONTAINER_PORT}
```

### ❌ 3.4 Kõvakodeeritud Võrgu Nimi
```bash
# KEELATUD:
podman run --rm --network=oracle-free-db-in-prod_default ...

# ÕIGE:
podman run --rm --network="${PROJECT_NAME}_default" ...
```

### ❌ 3.5 Staatiline `ADDITIONAL_DATABASES` Muutuja
```bash
# KEELATUD – Eraldi nimekiri lisabaasidest:
ADDITIONAL_DATABASES="lis bizapp"

# ÕIGE – Kõik baasid loetakse dünaamiliselt .env failist:
for inst in $(get_active_db_instances); do
  IFS='|' read -r c_name prof key <<< "$inst"
  load_db_profile "$prof"
  ...
done
```

---

## 4. Dünaamilised Abifunktsioonid

### `get_active_db_instances()`
Loeb `.env` failist kõik aktiivsed andmebaasivõtmed ja tagastab need kujul:
```
db-proxy|proxy-adb-oracle|DB_PROXY
db-lis|bizapp-standard-oracle|DB_LIS
```

### `get_required_secret_names()`
Tagastab kõik vajalike Podman saladuste nimed dünaamiliselt:
```bash
get_required_secret_names
# → "apex_db_sys_password publisher_db_sys_password apex_schema_password test_dev_password ords_listener_password apex_admin_password db_lis_db_sys_password"
```

### `load_db_profile()`
Laeb YAML profiilist kõik parameetrid eksporditavatesse muutujatesse.

---

## 5. Podman Compose Override Genereerimine

`podman-compose.override.yml` genereeritakse **alati dünaamiliselt** funktsioonis `generate_override_and_secrets()`:

1. Esimene instants (peamine proxy-baas) saab oma teenuse nime funktsioonist `get_active_db_instances`.
2. Iga lisainstants (index > 0) laeb oma profiili, saab sealt SID-i, pordi ja pildi.
3. Saladused, volume-id ja secrets-sektsioonid genereeritakse tsüklis.

```bash
generate_override_and_secrets() {
  local PROXY_SERVICE_KEY
  PROXY_SERVICE_KEY=$(get_active_db_instances | head -n 1 | cut -d'|' -f1)
  
  # Peamine proxy-baas
  cat <<EOF > "$OVERRIDE_FILE"
services:
  ${PROXY_SERVICE_KEY}:
    image: ${RESOLVED_DB_IMAGE}
EOF

  # Lisabaasid (index > 0)
  local active_instances=($(get_active_db_instances))
  if [ "${#active_instances[@]}" -gt 1 ]; then
    for ((i=1; i<${#active_instances[@]}; i++)); do
      IFS='|' read -r c_name prof key <<< "${active_instances[$i]}"
      (
        load_db_profile "$prof"
        # Kõik parameetrid dünaamiliselt profiilist
        cat <<EOF >> "$OVERRIDE_FILE"
  ${c_name}:
    image: ${RESOLVED_DB_IMAGE}
    ports:
      - "${PROFILE_DB_PORT}:${PROFILE_CONTAINER_PORT}"
    environment:
      - ORACLE_SID=${PROFILE_DB_SID}
EOF
      )
    done
  fi
}
```

---

## 6. Saladuste (Secrets) Haldus

### Loomine (`generate-passwords.sh`)
- Genereerib juhuslikud turvalised paroolid `openssl rand` abil.
- Salvestab need ainult Podman Secrets daemoni tasemel (`podman secret create`).
- Mitte kunagi ei kirjuta paroole kettale tavatekstina.

### Kontroll (`setup-all.sh`)
```bash
for secret in $(get_required_secret_names); do
  if ! podman secret exists "$secret"; then
    "$SCRIPT_DIR/internal/generate-passwords.sh" --force
    break
  fi
done
```

### Kustutamine (`reset-all.sh`)
```bash
for sec in $(get_required_secret_names); do
  podman secret rm "$sec" 2>/dev/null || true
done
```

---

## 7. Skriptide Kataloogistruktuur

```
scripts/
├── setup-all.sh            # Orkestreerimiskiht (AINULT delegeerimine)
├── reset-all.sh             # Puhastuse orkestreerimiskiht
├── start-containers.sh      # Konteinerite käivitamine
└── internal/                # Teostajaskriptid (äriloogika)
    ├── load-db-profile.sh   # YAML profiili laadimine ja muutujate eksport
    ├── generate-passwords.sh # Podman Secrets genereerimine
    ├── init-db-instance.sh  # DB instantsi algseadistamine
    ├── install-apex.sh      # APEX Engine paigaldamine
    ├── apply-apex-patch.sh  # APEX patchide rakendamine
    ├── apply-profile-users.sh # Kasutajate ja rollide loomine
    ├── create-wallet.sh     # Oracle Wallet genereerimine
    ├── generate-local-certs.sh # SSL/TLS sertifikaadid
    └── ...
├── sqlcl.sh                 # Natiivne SQLcl CLI wrapper (käsurea ühendused)

---

## 8. CLI Shell Integratsioon ja SQLcl Wrapper (`scripts/sqlcl.sh`)

1. **Automaatne kesta seadistus:** `setup-all.sh` kirjutab automaatselt `export TNS_ADMIN` ja `alias sql="$SCRIPT_DIR/sqlcl.sh"` kõikidesse kasutaja kesta profiilidesse (`~/.zshrc`, `~/.zshenv`, `~/.bashrc`, `~/.bash_profile`).
2. **Dünaamiline Walleti/Secreti parsimine:** `scripts/sqlcl.sh` eraldab käsuliini parameetrist `/@ALIAS` aliase ning pärib vajadusel paroolid automaatselt `view-wallet-credential.sh` / Podman secrets utiliidist ilma ühegi kõvakodeeritud paroolita.
3. **Binaarparooli fallback:** Kui `mkstore` tagastab krüpteeritud binaarbaidid, loeb süsteem parooli automaatselt Podman secret store'ist, vältides SQLcl parseri viga `Syntax error at column 14: '`.

```

---

## 8. Kontrollnimekiri Uue Sammu Lisamisel

Enne uue sammu lisamist `setup-all.sh` faili kontrolli järgmist:

- [ ] Kas samm delegeeritakse `scripts/internal/*.sh` abiskripti?
- [ ] Kas ükski väärtus (port, SID, PDB, pildi nimi, parool) pole koodis sisse kirjutatud?
- [ ] Kas kõik parameetrid tulevad profiilist (`PROFILE_*`) või `.env` muutujatest?
- [ ] Kas sammu kestus mõõdetakse ja salvestatakse `metrics/` kausta?
- [ ] Kas sammu logi salvestatakse `install_logs/` kausta?
- [ ] Kas `get_required_secret_names` ja `get_active_db_instances` töötavad uue sammuga korrektselt?
- [ ] Kas README.md on uuendatud vastavalt Mandatory Documentation Maintenance reeglile?
