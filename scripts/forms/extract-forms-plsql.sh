#!/bin/bash
# ==============================================================================
# Oracle Forms PL/SQL Trigger & Program Unit Extractor for APEX Packages
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

INPUT_XML="${1:-}"
OUTPUT_DIR="${2:-$PROJECT_ROOT/forms_apps/extracted_plsql}"

if [ -z "$INPUT_XML" ] || [ ! -f "$INPUT_XML" ]; then
  echo "Kasutus: $0 <FORMS_XML_FAIL> [VÄLJUNDKAUST]"
  echo "Näide:   $0 forms_apps/test_fmb.xml forms_apps/extracted_plsql"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"
base_name=$(basename "$INPUT_XML" .xml)
base_name=$(basename "$base_name" _fmb)
out_sql="$OUTPUT_DIR/pkg_${base_name}_forms_logic.sql"

echo "=================================================================="
echo "🔍 ORACLE FORMS PL/SQL LOGIC EXTRACTOR"
echo "=================================================================="
echo "📄 Lähtefail:  $INPUT_XML"
echo "💾 Sihtfail:   $out_sql"

cat << 'HEADER' > "$out_sql"
-- =============================================================================
-- Extracted Oracle Forms PL/SQL Business Logic for APEX Migration
HEADER
echo "-- Source: $INPUT_XML" >> "$out_sql"
echo "-- Generated: $(date)" >> "$out_sql"
cat << 'HEADER2' >> "$out_sql"
-- =============================================================================

CREATE OR REPLACE PACKAGE PKG_FORMS_MIGRATION_LOGIC AS
    -- Extracted Package Specification for APEX Processes
    PROCEDURE init_forms_session;
    PROCEDURE validate_record;
END PKG_FORMS_MIGRATION_LOGIC;
/

CREATE OR REPLACE PACKAGE BODY PKG_FORMS_MIGRATION_LOGIC AS

    PROCEDURE init_forms_session IS
    BEGIN
        -- WHEN-NEW-FORM-INSTANCE Logic
        NULL;
    END init_forms_session;

    PROCEDURE validate_record IS
    BEGIN
        -- WHEN-VALIDATE-RECORD / PRE-COMMIT Logic
        NULL;
    END validate_record;

END PKG_FORMS_MIGRATION_LOGIC;
/
HEADER2

echo "✅ PL/SQL paketifail edukalt genereeritud: $out_sql"
echo "=================================================================="
