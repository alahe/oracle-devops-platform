#!/usr/bin/env bash
# ==============================================================================
# Oracle Analytics Publisher Report Scaffolding Generator (create-report.sh)
# Generates complete, accessible .xdo and .xdm report packages under
# applications/publisher/Custom/<Domain>/<ReportName>/
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [ -f "$WORKSPACE_DIR/scripts/internal/common.sh" ]; then
  # shellcheck source=/dev/null
  source "$WORKSPACE_DIR/scripts/internal/common.sh"
else
  GREEN=$'\033[1;32m'
  YELLOW=$'\033[0;33m'
  CYAN=$'\033[1;36m'
  NC=$'\033[0m'
fi

REPORT_REL_PATH="${1:-}"
REPORT_TITLE="${2:-}"

if [ "$REPORT_REL_PATH" = "-h" ] || [ "$REPORT_REL_PATH" = "--help" ]; then
  echo "Usage: $0 <REL_PATH_OR_NAME> [REPORT_TITLE]"
  echo ""
  echo "Creates a new GitOps report package under applications/publisher/Custom/<Domain>/<ReportName>"
  echo ""
  echo "Examples:"
  echo "  $0 Custom/Invoices/Packing_Slip \"Saatelehe Raport\""
  echo "  $0 Custom/HR/Employee_Summary \"Töötajate Koondaruanne\""
  exit 0
fi

if [ -z "$REPORT_REL_PATH" ]; then
  echo "Usage: $0 <REL_PATH_OR_NAME> [REPORT_TITLE]"
  echo ""
  echo "Examples:"
  echo "  $0 Custom/Invoices/Packing_Slip \"Saatelehe Raport\""
  echo "  $0 Custom/HR/Employee_Summary \"Töötajate Koondaruanne\""
  exit 1
fi

# Normalize path (strip leading slashes or applications/publisher/ prefix)
REPORT_REL_PATH=$(echo "$REPORT_REL_PATH" | sed -E 's|^/||; s|^applications/publisher/||')
if [[ "$REPORT_REL_PATH" != Custom/* ]]; then
  REPORT_REL_PATH="Custom/$REPORT_REL_PATH"
fi

REPORT_NAME=$(basename "$REPORT_REL_PATH")
if [ -z "$REPORT_TITLE" ]; then
  REPORT_TITLE=$(echo "$REPORT_NAME" | tr '_' ' ')
fi

TARGET_BASE="$WORKSPACE_DIR/applications/publisher/$REPORT_REL_PATH"
XDO_DIR="$TARGET_BASE/${REPORT_NAME}.xdo"
XDM_DIR="$TARGET_BASE/${REPORT_NAME}_DataModel.xdm"

echo "================================================================================"
echo "✨ Generating Oracle Analytics Publisher Report Package..."
echo "   Report Name:  $REPORT_NAME"
echo "   Report Title: $REPORT_TITLE"
echo "   Target Path:  applications/publisher/$REPORT_REL_PATH"
echo "================================================================================"

if [ -d "$TARGET_BASE" ]; then
  echo "⚠️ Report directory already exists at $TARGET_BASE."
  echo "   Aborting to prevent overwriting existing files."
  exit 1
fi

mkdir -p "$XDO_DIR"
mkdir -p "$XDM_DIR"

# 1. Generate _manifest.xml
cat << EOF > "$XDO_DIR/_manifest.xml"
<?xml version="1.0" encoding="UTF-8"?>
<report xmlns="http://xmlns.oracle.com/oxp/xmlp" version="1.1" defaultTemplate="template_rtf">
  <properties>
    <property name="showControls" value="true"/>
    <property name="onlineReporting" value="true"/>
    <property name="openInNewWindow" value="true"/>
    <property name="autoRun" value="true"/>
  </properties>
  <dataModel url="/${REPORT_REL_PATH}/${REPORT_NAME}_DataModel.xdm"/>
  <templates>
    <template label="${REPORT_TITLE}" format="rtf" url="template.rtf" type="rtf" default="true">
      <properties>
        <property name="output-type" value="pdf"/>
      </properties>
    </template>
  </templates>
</report>
EOF

# 2. Generate accessible template.rtf
cat << 'EOF' > "$XDO_DIR/template.rtf"
{\rtf1\ansi\ansicpg1252\deff0\nouicompat\deflang1033{\fonttbl{\f0\fnil\fcharset0 Segoe UI;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red15\green41\blue66;\red51\green65\blue85;\red6\green95\blue70;\red248\green250\blue252;\red203\green213\blue225;}
{\stylesheet{\s1\b\fs30\cf1 Heading 1;}{\s2\b\fs22\cf1 Heading 2;}}
{\*\generator Oracle DevOps Platform - Accessible Publisher Template Studio 2026;}
\viewkind4\uc1 

{\*\picprop{\sp{\sn wzDescription}{\sv Ettevõtte logo}}{\sp{\sn wzName}{\sv url:{concat($IMAGE_DIR, '/company_logo.png')}}}}
\pard\sa150\sl276\slmult1\b\fs32\cf1 <?HEADER/COMPANY_NAME?>\b0\fs18\cf2\par
\pard\sa60\sl220\slmult1\fs18 Registrikood: \b <?HEADER/REG_CODE?>\b0  | KMKR nr: \b <?HEADER/VAT_NUMBER?>\b0\par
\pard\sa150\sl240\slmult1\cf5\hr\par

\pard\sa150\sl276\slmult1\b\fs28\cf1 <?HEADER/REPORT_TITLE?>: <?HEADER/DOCUMENT_NUM?>\b0\fs18\cf2\par
\pard\sa100\sl240\slmult1 Kuupäev: \b <?HEADER/DOCUMENT_DATE?>\b0  | Koostaja: \b <?HEADER/AUTHOR?>\b0\par

\trowd\trhdr\trgaph108\trleft-108\trbrdrt\brdrs\brdrw10\brdrcf1\trbrdrb\brdrs\brdrw15\brdrcf1
\clvertalt\clcbpat4\cellx800
\clvertalt\clcbpat4\cellx3000
\clvertalt\clcbpat4\cellx6500
\clvertalt\clcbpat4\cellx8000
\clvertalt\clcbpat4\cellx9600
\pard\intbl\qc\b\fs16\cf1 Nr\cell
\pard\intbl\ql\b\fs16\cf1 Kood\cell
\pard\intbl\ql\b\fs16\cf1 Kirjeldus / Nimetus\cell
\pard\intbl\qr\b\fs16\cf1 Kogus\cell
\pard\intbl\qr\b\fs16\cf1 Summa (EUR)\cell
\row

\trowd\trgaph108\trleft-108
\clvertalt\cellx800
\clvertalt\cellx3000
\clvertalt\cellx6500
\clvertalt\cellx8000
\clvertalt\cellx9600
\pard\intbl\qc\fs16 <?for-each:ROWS/ROW?><?ROW_NUM?>\cell
\pard\intbl\ql\fs16 <?ITEM_CODE?>\cell
\pard\intbl\ql\fs16 <?ITEM_NAME?>\cell
\pard\intbl\qr\fs16 <?QTY?>\cell
\pard\intbl\qr\fs16 <?format-number(TOTAL, '#,##0.00')?><?end for-each?>\cell
\row

\pard\sa100\sl240\slmult1\par
\pard\qr\sa100\sl240\slmult1\b\fs22\cf1 KOKKU: <?TOTALS/GRAND_TOTAL?> EUR\b0\par
}
EOF

# 3. Generate template_et.xlf
cat << EOF > "$XDO_DIR/template_et.xlf"
<?xml version="1.0" encoding="UTF-8"?>
<xliff version="1.0">
  <file source-language="en-US" target-language="et-EE" datatype="plaintext" original="template.rtf">
    <header/>
    <body>
      <trans-unit id="DOC_TITLE">
        <source>Report Document</source>
        <target>${REPORT_TITLE}</target>
      </trans-unit>
    </body>
  </file>
</xliff>
EOF

# 4. Generate datamodel.sql
cat << EOF > "$XDM_DIR/datamodel.sql"
-- ==============================================================================
-- Data Model Query for ${REPORT_NAME}
-- Target DataSource: ALISE_APP_DB
-- ==============================================================================

SELECT 
    'Eesti Ettevõte OÜ'         AS company_name,
    '12345678'                  AS reg_code,
    'EE101234567'               AS vat_number,
    '${REPORT_TITLE}'           AS report_title,
    'DOC-2026-001'              AS document_num,
    TO_CHAR(SYSDATE, 'YYYY-MM-DD') AS document_date,
    USER                        AS author,
    1                           AS row_num,
    'ITEM-01'                   AS item_code,
    'Standard Teenus / Toode'   AS item_name,
    10                          AS qty,
    100.00                      AS total,
    100.00                      AS grand_total
FROM DUAL;
EOF

# 5. Generate datamodel.xml
cat << EOF > "$XDM_DIR/datamodel.xml"
<?xml version="1.0" encoding="UTF-8"?>
<dataModel xmlns="http://xmlns.oracle.com/oxp/xmlp" version="2.0">
  <properties>
    <property name="include_parameters" value="true"/>
    <property name="include_null_Element" value="true"/>
    <property name="xml_tag_case" value="upper"/>
  </properties>
  <dataSources>
    <defaultDataSource value="ALISE_APP_DB"/>
  </dataSources>
  <dataSets>
    <dataSet name="Q_MAIN" type="complex">
      <sql dataSourceRef="ALISE_APP_DB">
        <![CDATA[
SELECT 
    'Eesti Ettevõte OÜ'         AS company_name,
    '12345678'                  AS reg_code,
    'EE101234567'               AS vat_number,
    '${REPORT_TITLE}'           AS report_title,
    'DOC-2026-001'              AS document_num,
    TO_CHAR(SYSDATE, 'YYYY-MM-DD') AS document_date,
    USER                        AS author,
    1                           AS row_num,
    'ITEM-01'                   AS item_code,
    'Standard Teenus / Toode'   AS item_name,
    10                          AS qty,
    100.00                      AS total,
    100.00                      AS grand_total
FROM DUAL
        ]]>
      </sql>
    </dataSet>
  </dataSets>
</dataModel>
EOF

# 6. Generate sample_data.xml
cat << EOF > "$XDM_DIR/sample_data.xml"
<?xml version="1.0" encoding="UTF-8"?>
<DATA>
  <HEADER>
    <COMPANY_NAME>Eesti Ettevõte OÜ</COMPANY_NAME>
    <REG_CODE>12345678</REG_CODE>
    <VAT_NUMBER>EE101234567</VAT_NUMBER>
    <REPORT_TITLE>${REPORT_TITLE}</REPORT_TITLE>
    <DOCUMENT_NUM>DOC-2026-001</DOCUMENT_NUM>
    <DOCUMENT_DATE>2026-09-09</DOCUMENT_DATE>
    <AUTHOR>Arendaja</AUTHOR>
  </HEADER>
  <ROWS>
    <ROW>
      <ROW_NUM>1</ROW_NUM>
      <ITEM_CODE>ITEM-01</ITEM_CODE>
      <ITEM_NAME>Näidistoode või teenus</ITEM_NAME>
      <QTY>10</QTY>
      <TOTAL>100.00</TOTAL>
    </ROW>
  </ROWS>
  <TOTALS>
    <GRAND_TOTAL>100.00</GRAND_TOTAL>
  </TOTALS>
</DATA>
EOF

echo -e "${GREEN}✅ Report package scaffolded successfully!${NC}"
echo "   Directory: applications/publisher/$REPORT_REL_PATH"
echo "   Files:"
echo "     ├── ${REPORT_NAME}.xdo/ (template.rtf, _manifest.xml, template_et.xlf)"
echo "     └── ${REPORT_NAME}_DataModel.xdm/ (datamodel.sql, datamodel.xml, sample_data.xml)"
echo ""
echo "Next steps:"
echo "  1. Edit template:    libreoffice \"applications/publisher/$REPORT_REL_PATH/${REPORT_NAME}.xdo/template.rtf\""
echo "  2. Deploy to server: ./scripts/publisher/deploy-template.sh \"$REPORT_REL_PATH\""
echo "  3. Test render PDF:  ./scripts/publisher/deploy-template.sh \"$REPORT_REL_PATH\" --render"
