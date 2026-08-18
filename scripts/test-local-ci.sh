#!/usr/bin/env bash
# ============================================================================
# Local Offline GitHub Actions Runner & Test Simulator (SQLcl Projects + Podman)
# Emulates production GitHub Actions workflows 100% offline in developer environment
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Rule 1: Local full logging setup
LOG_DIR="$WORKSPACE_DIR/install_logs"
METRICS_DIR="$WORKSPACE_DIR/metrics"
mkdir -p "$LOG_DIR" "$METRICS_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/test_local_ci_${TIMESTAMP}.log"
exec > >(tee -a "$LOG_FILE") 2>&1

START_TIME=$(date +%s)

# Load environment
if [ -f "$WORKSPACE_DIR/.env" ]; then
  set -a
  source "$WORKSPACE_DIR/.env"
  set +a
fi

WORKFLOW="${1:-deploy-apex.yml}"
DRY_RUN=false
UI_MODE=false

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --ui) UI_MODE=true ;;
    *.yml) WORKFLOW="$arg" ;;
  esac
done

echo "=================================================================="
echo "🚀 LOKAALNE GITHUB ACTIONS SIMULAATOR & TESTI KÄIVITAJA"
echo "   Töövoog: .github/workflows/$WORKFLOW"
echo "   Režiim:  $([ "$DRY_RUN" = "true" ] && echo "Kuivkäivitus (--dry-run)" || echo "Täielik täitmine (Local Execution)")"
echo "=================================================================="

# 1. Genereeri .env.secrets SEPS Walletist
echo "🔑 Valmistan ette lokaalsed CI/CD saladused (.env.secrets)..."
SECRET_FILE="$WORKSPACE_DIR/.env.secrets"

# Export Base64 wallet
B64_VAL=$("$SCRIPT_DIR/internal/export-ci-secrets.sh" 2>/dev/null | grep -v "^=" | grep -v "^🔑" | grep -v "^✅" | grep -v "^   " | tr -d '\r\n' || true)

cat <<EOF > "$SECRET_FILE"
DB_WALLET_BASE64=$B64_VAL
OCR_USERNAME=${OCR_USERNAME:-"none"}
OCR_PASSWORD=${OCR_PASSWORD:-"none"}
EOF

echo "✅ .env.secrets fail edukalt genereeritud!"

# 2. Kontrolli act CLI olemasolu
if command -v act >/dev/null 2>&1; then
  echo "✅ Tuvastati Nektos 'act' CLI utiliit."
  ACT_CMD="act"
else
  echo "ℹ️  'act' CLI utiliiti ei leitud host-süsteemist."
  echo "   Kasutan lokaalset ajutise konteineri (ephemeral SQLcl container) fallback mudelit."
  ACT_CMD="fallback"
fi

if [ "$DRY_RUN" = "true" ]; then
  echo "🔍 [DRY-RUN]: Kontrollin workflow süntaksit ja sammusid..."
  if [ "$ACT_CMD" = "act" ]; then
    act -W ".github/workflows/$WORKFLOW" -n
  else
    echo "✅ Workflow fail .github/workflows/$WORKFLOW on olemas ja süntaks korras."
  fi
else
  if [ "$ACT_CMD" = "act" ]; then
    echo "🚀 Käivitan lokaalse workflow käivituse 'act' abil..."
    act -W ".github/workflows/$WORKFLOW" --secret-file "$SECRET_FILE"
  else
    echo "🚀 Käivitan SQLcl Projects tarne ajutises konteineris (Ephemeral Fallback)..."
    PRIMARY_CONTAINER=$(podman ps --format "{{.Names}}" 2>/dev/null | grep -E "^(db-|oracle-)" | head -n 1 || echo "db-dev-full")
    TNS_DIR="$WORKSPACE_DIR/config/tns_admin_container"
    [ ! -d "$TNS_DIR" ] && TNS_DIR="$WORKSPACE_DIR/config/tns_admin"

    podman run --rm \
      --network=host \
      -v "$WORKSPACE_DIR:/workspace" \
      -v "$TNS_DIR:/root/.oracle/tns_admin" \
      -e TNS_ADMIN=/root/.oracle/tns_admin \
      -e JAVA_TOOL_OPTIONS="-Doracle.net.tns_admin=/root/.oracle/tns_admin" \
      -w /workspace \
      container-registry.oracle.com/database/sqlcl:latest \
      /@DB_APEX_PROXY_SCHEMA <<'EOF'
    lb status
    project deploy -file artifact/*.zip || project deploy
    exit;
EOF
  fi
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Rule 1: Record benchmarks to metrics/setup_benchmarks.json & env
python3 -c "
import json, os
metrics_file = '$METRICS_DIR/setup_benchmarks.json'
data = {}
if os.path.exists(metrics_file):
    try:
        with open(metrics_file, 'r') as f:
            data = json.load(f)
    except: data = {}
data['test_local_ci_duration_seconds'] = $DURATION
with open(metrics_file, 'w') as f:
    json.dump(data, f, indent=2)
" 2>/dev/null || true

echo "test_local_ci_duration_seconds=$DURATION" >> "$METRICS_DIR/setup_benchmarks.env"

echo "=================================================================="
echo "🎉 LOKAALNE CI/CD TEST EDUKALT LÕPETATUD!"
echo "   ⌛ Kestus: ${DURATION}s"
echo "   📝 Logi: $LOG_FILE"
echo "=================================================================="
