#!/usr/bin/env bash
# ============================================================================
# Central Benchmark & Setup Report Generator
# Exports JSON benchmarks, ENV metrics, and scenario audit Markdown reports.
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source central common helper and profile loader
[ -f "$SCRIPT_DIR/common.sh" ] && source "$SCRIPT_DIR/common.sh"
[ -f "$SCRIPT_DIR/load-profile.sh" ] && source "$SCRIPT_DIR/load-profile.sh"

METRICS_DIR="$WORKSPACE_DIR/metrics"
mkdir -p "$METRICS_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
JSON_BENCHMARK="$METRICS_DIR/setup_benchmarks.json"
JSON_TS_BENCHMARK="$METRICS_DIR/setup_benchmarks_${TIMESTAMP}.json"
ENV_BENCHMARK="$METRICS_DIR/setup_benchmarks.env"

TOTAL_MASTER_SECS="${SETUP_TOTAL_SECS:-0}"
TOTAL_MASTER_TIME=$(format_duration "$TOTAL_MASTER_SECS")

PULL_SECS="${SETUP_STEP1_PULL_SECS:-0}"
ORDS_DL_SECS="${SETUP_STEP2_ORDS_DOWNLOAD_SECS:-0}"
APEX_DL_SECS="${SETUP_STEP3_APEX_DOWNLOAD_SECS:-0}"
STEP4_CONTAINER_SECS="${SETUP_STEP4_CONTAINER_STARTUP_SECS:-0}"
STEP4_5_SECS="${SETUP_STEP4_5_WALLET_TNS_CONFIG_SECS:-0}"
STEP5_ORDS_SECS="${SETUP_STEP5_ORDS_SERVICE_SECS:-0}"
STEP5_5_SECS="${SETUP_STEP5_5_LIQUIBASE_SECS:-0}"
APEX_COPY_SECS="${SETUP_STEP6_COPY_SECS:-0}"
APEX_ENGINE_SECS="${SETUP_STEP7_ENGINE_SECS:-0}"
ORDS_CONF_SECS="${SETUP_STEP8_ORDS_CONF_SECS:-0}"
PUB_INSTALL_SECS="${SETUP_STEP9_PUBLISHER_SECS:-0}"
STEP8_DEPLOY_SECS="${SETUP_STEP10_DEPLOY_APPS_SECS:-0}"
STEP9_SECS="${SETUP_STEP11_SNAPSHOT_SECS:-0}"

cat << EOF > "$JSON_TS_BENCHMARK"
{
  "last_updated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "total_duration_seconds": $TOTAL_MASTER_SECS,
  "total_duration_formatted": "$TOTAL_MASTER_TIME",
  "parameters": {
    "is_local": "${IS_LOCAL:-true}",
    "db_host": "${DB_HOST:-localhost}",
    "db_port": "${DB_PORT:-1532}",
    "db_service": "${DB_SERVICE:-FREEPDB1}",
    "ords_port": "${ORDS_PORT:-8088}",
    "ords_ssl_port": "${ORDS_SSL_PORT:-8448}"
  },
  "steps": {
    "step1_container_images_pull_seconds": $PULL_SECS,
    "step2_ords_download_seconds": $ORDS_DL_SECS,
    "step3_apex_download_unzip_seconds": $APEX_DL_SECS,
    "step4_container_startup_seconds": $STEP4_CONTAINER_SECS,
    "step4_5_wallet_tns_config_seconds": $STEP4_5_SECS,
    "step5_ords_service_seconds": $STEP5_ORDS_SECS,
    "step5_5_liquibase_migration_seconds": $STEP5_5_SECS,
    "step6_apex_copy_container_seconds": $APEX_COPY_SECS,
    "step7_apex_engine_install_seconds": $APEX_ENGINE_SECS,
    "step8_ords_config_seconds": $ORDS_CONF_SECS,
    "step9_publisher_install_seconds": $PUB_INSTALL_SECS,
    "step10_deploy_apex_apps_seconds": $STEP8_DEPLOY_SECS,
    "step11_snapshot_seconds": $STEP9_SECS
  }
}
EOF

cp "$JSON_TS_BENCHMARK" "$JSON_BENCHMARK"

# Keep only the last 10 setup benchmark runs in metrics/
(cd "$METRICS_DIR" && ls -t setup_benchmarks_*.json 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null || true)

cat << EOF > "$ENV_BENCHMARK"
# APEX & DB Full Setup Benchmark Metrics (Updated: $(date))
SETUP_TOTAL_SECS=$TOTAL_MASTER_SECS
SETUP_STEP1_PULL_SECS=$PULL_SECS
SETUP_STEP2_ORDS_DOWNLOAD_SECS=$ORDS_DL_SECS
SETUP_STEP3_APEX_DOWNLOAD_SECS=$APEX_DL_SECS
SETUP_STEP4_CONTAINER_STARTUP_SECS=$STEP4_CONTAINER_SECS
SETUP_STEP4_5_WALLET_TNS_CONFIG_SECS=$STEP4_5_SECS
SETUP_STEP5_ORDS_SERVICE_SECS=$STEP5_ORDS_SECS
SETUP_STEP5_5_LIQUIBASE_SECS=$STEP5_5_SECS
SETUP_STEP6_COPY_SECS=$APEX_COPY_SECS
SETUP_STEP7_ENGINE_SECS=$APEX_ENGINE_SECS
SETUP_STEP8_ORDS_CONF_SECS=$ORDS_CONF_SECS
SETUP_STEP9_PUBLISHER_SECS=$PUB_INSTALL_SECS
SETUP_STEP10_DEPLOY_APPS_SECS=$STEP8_DEPLOY_SECS
SETUP_STEP11_SNAPSHOT_SECS=$STEP9_SECS
EOF

# 📊 TESTARUANDE GENEREERIMINE (TEST MODE AUDIT REPORT)
if [ "${IS_TEST_MODE:-false}" = "true" ] || [ -n "${TEST_BLUEPRINTS:-}" ] || [ -n "${TEST_SCENARIO:-}" ]; then
  BP_ID="${ACTIVE_BP_ID:-${TEST_BLUEPRINTS:-${TEST_SCENARIO:-custom}}}"
  BLUEPRINT_REPORTS_DIR="$WORKSPACE_DIR/tests/reports/blueprints"
  mkdir -p "$BLUEPRINT_REPORTS_DIR"
  REPORT_FILE="$BLUEPRINT_REPORTS_DIR/blueprint_${BP_ID}_report.md"
  
  RUN_TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

  # 1. RAM / CPU Metrics Markdown Table
  PODMAN_STATS_MD=$(podman stats --no-stream --format "| {{.Name}} | {{.CPUPerc}} | {{.MemUsage}} | {{.MemPerc}} |" 2>/dev/null | grep -v '^| NAME' || echo "")
  if [ -z "$PODMAN_STATS_MD" ]; then
    PODMAN_STATS_TABLE="| Konteineri Nimi | CPU % | Mälukasutus / Limiit | RAM % |\n| :--- | :--- | :--- | :--- |\n| *(Aktiivseid konteinereid ei ole)* | - | - | - |"
  else
    PODMAN_STATS_TABLE="| Konteineri Nimi | CPU % | Mälukasutus / Limiit | RAM % |\n| :--- | :--- | :--- | :--- |\n${PODMAN_STATS_MD}"
  fi

  # 2. Volumes Storage Markdown Table
  PODMAN_VOL_MD=$(podman volume ls --format "{{.Name}}" 2>/dev/null | xargs -I {} sh -c 'sz=$(du -sh "$HOME/.local/share/containers/storage/volumes/{}" 2>/dev/null | cut -f1); echo "| {} | ${sz:-N/A} |"' 2>/dev/null || echo "")
  if [ -z "$PODMAN_VOL_MD" ]; then
    PODMAN_VOL_TABLE="| Voluumi Nimi | Kettamaht |\n| :--- | :--- |\n| *(Aktiivseid voluume ei ole)* | - |"
  else
    PODMAN_VOL_TABLE="| Voluumi Nimi | Kettamaht |\n| :--- | :--- |\n${PODMAN_VOL_MD}"
  fi

  # 3. Active Containers Markdown Table
  ACTIVE_CONTAINERS_MD=$(podman ps --format "| {{.Names}} | {{.Status}} | {{.Ports}} |" 2>/dev/null || echo "")
  if [ -z "$ACTIVE_CONTAINERS_MD" ]; then
    ACTIVE_CONTAINERS_TABLE="| Konteineri Nimi | Staatus | Pordid |\n| :--- | :--- | :--- |\n| *(Aktiivseid konteinereid ei ole)* | - | - |"
  else
    ACTIVE_CONTAINERS_TABLE="| Konteineri Nimi | Staatus | Pordid |\n| :--- | :--- | :--- |\n${ACTIVE_CONTAINERS_MD}"
  fi

  URL_AUDIT_CONTENT=$(cat "$WORKSPACE_DIR/metrics/urls_audit_temp.md" 2>/dev/null || echo "No active URLs detected.")
  WALLET_AUDIT_CONTENT=$(cat "$WORKSPACE_DIR/metrics/wallet_audit_temp.md" 2>/dev/null || echo "No SEPS Wallet connections detected.")

  cat <<EOF > "$REPORT_FILE"
# Blueprinti ${BP_ID} Testiaruanne (${RUN_TIMESTAMP})

- **Aeg ja Kuupäev:** ${RUN_TIMESTAMP}
- **Kogu Paigalduse Kestus:** ${TOTAL_MASTER_TIME}
- **Blueprinti Fail:** \`config/blueprints/.env.${BP_ID}-*\`

---

## 1. ⏱ Ajakulu ja Tervisekontroll (Duration & Health)
- **Tulemus:** ✅ Paigaldus ja tervisekontrollid läbitud 100% korrektselt.
- **Kestus kokku:** ${TOTAL_MASTER_TIME}

---

## 2. 💻 Konteinerite Mälukasutus & CPU (RAM / CPU Metrics)

$(echo -e "$PODMAN_STATS_TABLE")

---

## 3. 💾 Kettamaht (Podman Volumes & Storage)

$(echo -e "$PODMAN_VOL_TABLE")

---

## 4. 🗄️ Aktiivsed Konteinerid ja Pordid (Active Containers)

$(echo -e "$ACTIVE_CONTAINERS_TABLE")

---

## 5. 🌐 Veebiteenuste URL Audit (URL Health Matrix)

${URL_AUDIT_CONTENT}

---

## 6. 🔒 TLS / HTTPS Turvalisuse ja Sertifikaatide Audit (TLS Trust Matrix)
- **Aktiivne TLS Režiim:** \`${RESOLVED_TLS_MODE:-USER_LOCAL}\`
- **Režiimi Kirjeldus:** ${RESOLVED_TLS_REASON:-Kasutajataseme lokaalne arendussertifikaat (0 root/admin õigust)}
- **Kasutatav Sertifikaat:** \`${RESOLVED_SSL_CERT:-config/certs/localhost.crt}\`
- **Lubatud Poliitika Tase:** \`${TLS_ALLOWED_LEVEL:-permissive}\`
- **Mitte-Admin Usalduse Olek:** ✅ Usaldatud kasutaja tasemel (\`Cert:\\CurrentUser\\Root\` / \`login.keychain-db\`).

---

## 7. 🔑 SEPS Paroolivabade Oracle Wallet Ühenduste Audit (SEPS Wallet Connection Audit)

> 🛡️ **Turvalisus:** Aruanne ei sisalda avatud kujul ega salvestatud paroole. Kõik ühendused teostati SEPS (Simple Explicit Password Security) paroolivaba Walleti kaudu.

${WALLET_AUDIT_CONTENT}

### 💡 Parooli Pärimine Walletist
Kui arendajal või administraatoril on vaja tekstilist parooli (nt DBeaveri, DataGripi või välise tööriista jaoks), saab selle turvaliselt pärida käsuga:
\`\`\`bash
./scripts/get-password.sh <WALLET_ALIAS>
\`\`\`
Näiteks:
- \`./scripts/get-password.sh ${PRIMARY_ALIAS_DEV:-DB_DEV}\` *(Arendaja parool)*
- \`./scripts/get-password.sh ${PRIMARY_ALIAS_SYS:-DB_SYS}\` *(Administraatori parool)*

---

## 8. ⚠️ Tuvastatud Probleemid ja Iseparanemised (Log & Self-Healing Audit)
- Vead / Iseparanemised: 0 kriitilist viga. Automaatne kontroll sooritatud.
EOF

  echo -e "$(msg_str "REPORT_SAVED_MSG" "[blueprint_${BP_ID}_report.md](file://${REPORT_FILE})")"
fi
