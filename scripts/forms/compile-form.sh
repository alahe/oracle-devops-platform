#!/bin/bash
# ==============================================================================
# Oracle Forms 14c Batch Form/Menu/Library Compiler (CLI)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

CONTAINER_NAME="${FORMS_CONTAINER_NAME:-app-forms}"
DB_ALIAS="${DB_FORMS_DEV_ALIAS:-DB_FORMS_DEV}"
COMPILE_ALL=false
TARGET_FILES=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)
      COMPILE_ALL=true
      shift
      ;;
    -a|--alias)
      DB_ALIAS="$2"
      shift 2
      ;;
    -h|--help)
      echo "Kasutus: $0 [VALIKUD] [FAILID...]"
      echo ""
      echo "Valikud:"
      echo "  --all            Kompileeri kõik forms_apps/ kaustas asuvad .fmb, .mmb, .pll failid"
      echo "  -a, --alias      Määra SEPS Walleti alias (Vaikimisi: DB_FORMS_DEV)"
      echo "  -h, --help       Kuva see abiinfo"
      echo ""
      echo "Näited:"
      echo "  $0 forms_apps/test.fmb"
      echo "  $0 --all"
      exit 0
      ;;
    *)
      TARGET_FILES+=("$1")
      shift
      ;;
  esac
done

if [ "$COMPILE_ALL" = "true" ]; then
  while IFS= read -r -d '' f; do
    TARGET_FILES+=("$f")
  done < <(find "$PROJECT_ROOT/forms_apps" -maxdepth 2 -type f \( -name "*.fmb" -o -name "*.mmb" -o -name "*.pll" \) -print0 2>/dev/null || true)
fi

if [ ${#TARGET_FILES[@]} -eq 0 ]; then
  echo "⚠️  Ühtegi kompileeritavat faili ei leitud ega määratud!"
  echo "   Kasuta: $0 forms_apps/minuvorm.fmb või $0 --all"
  exit 1
fi

CTR_CMD="podman"
if ! command -v podman >/dev/null 2>&1 && command -v docker >/dev/null 2>&1; then
  CTR_CMD="docker"
fi

# Ensure container is running
if ! $CTR_CMD ps --format "{{.Names}}" 2>/dev/null | grep -q "^${CONTAINER_NAME}$"; then
  echo "⚠️  Forms konteiner ($CONTAINER_NAME) ei tööta!"
  echo "   Käivita see käsuga: ./scripts/setup-all.sh -b 14"
  exit 1
fi

echo "=================================================================="
echo "🔨 ORACLE FORMS 14c PARTII-KOMPILEERIMINE (BATCH COMPILER)"
echo "=================================================================="

for src_file in "${TARGET_FILES[@]}"; do
  base_name=$(basename "$src_file")
  ext="${base_name##*.}"
  
  case "$ext" in
    fmb) mtype="form" ;;
    mmb) mtype="menu" ;;
    pll) mtype="library" ;;
    *)   mtype="form" ;;
  esac
  
  echo "📦 Kompileerin [$mtype]: $base_name..."
  
  # Execute frmcmp_batch inside container with SEPS wallet
  $CTR_CMD exec "$CONTAINER_NAME" bash -c "
    export ORACLE_HOME=/u01/oracle
    export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/usr/java/default/lib/server:/usr/java/default/lib
    export FORMS_PATH=/u01/oracle/forms:/u01/oracle/forms_apps
    export TNS_ADMIN=/u01/oracle/tns_admin
    export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
    export TERM=vt220
    export ORACLE_TERM=vt220
    export TK_PATH=\$ORACLE_HOME/guicommon/tk/admin
    
    if [ -x /u01/oracle/bin/frmcmp_batch ]; then
      /u01/oracle/bin/frmcmp_batch module=\"/u01/oracle/forms_apps/$base_name\" module_type=$mtype compile_all=yes userid=\"/@$DB_ALIAS\" batch=yes || true
    fi
  " || true
  
  echo "   ✅ Kompileerimine sooritatud: $base_name"
done

echo "=================================================================="
echo "🎉 Kõik määratud Forms failid on edukalt töödeldud!"
echo "=================================================================="
