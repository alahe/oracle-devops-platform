#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: Publisher Scaffolding & GitOps Deploy (create-report.sh & deploy-template.sh)${NC}"

CREATE_SCRIPT="$WORKSPACE_DIR/scripts/publisher/create-report.sh"
DEPLOY_SCRIPT="$WORKSPACE_DIR/scripts/publisher/deploy-template.sh"

# 1. Syntax checks
echo "  [1/4] Checking bash syntax..."
if [ ! -f "$CREATE_SCRIPT" ] || [ ! -f "$DEPLOY_SCRIPT" ]; then
  echo -e "${RED}❌ Missing script files!${NC}"
  exit 1
fi
bash -n "$CREATE_SCRIPT"
bash -n "$DEPLOY_SCRIPT"
echo -e "${GREEN}  ✓ Bash syntax valid for both scripts${NC}"

# 2. Test Help / CLI validation
echo "  [2/4] Testing CLI argument parsing & help flags..."
"$CREATE_SCRIPT" --help > /dev/null
"$DEPLOY_SCRIPT" --help > /dev/null
echo -e "${GREEN}  ✓ Help flags execute cleanly with exit code 0${NC}"

# 3. Test report scaffolding
TEST_REL_PATH="Custom/TestDomain/Test_Invoice_Unit"
TEST_TARGET_DIR="$WORKSPACE_DIR/applications/publisher/$TEST_REL_PATH"

echo "  [3/4] Testing report package creation ($TEST_REL_PATH)..."
# Ensure clean starting state
rm -rf "$WORKSPACE_DIR/applications/publisher/Custom/TestDomain"

"$CREATE_SCRIPT" "$TEST_REL_PATH" "Test Invoice Report Unit" > /dev/null

if [ ! -f "$TEST_TARGET_DIR/Test_Invoice_Unit.xdo/template.rtf" ]; then
  echo -e "${RED}❌ template.rtf was not created in .xdo package!${NC}"
  exit 1
fi

if [ ! -f "$TEST_TARGET_DIR/Test_Invoice_Unit.xdo/_manifest.xml" ]; then
  echo -e "${RED}❌ _manifest.xml was not created in .xdo package!${NC}"
  exit 1
fi

if [ ! -f "$TEST_TARGET_DIR/Test_Invoice_Unit_DataModel.xdm/datamodel.sql" ]; then
  echo -e "${RED}❌ datamodel.sql was not created in .xdm package!${NC}"
  exit 1
fi

if [ ! -f "$TEST_TARGET_DIR/Test_Invoice_Unit_DataModel.xdm/datamodel.xml" ]; then
  echo -e "${RED}❌ datamodel.xml was not created in .xdm package!${NC}"
  exit 1
fi

if [ ! -f "$TEST_TARGET_DIR/Test_Invoice_Unit_DataModel.xdm/sample_data.xml" ]; then
  echo -e "${RED}❌ sample_data.xml was not created in .xdm package!${NC}"
  exit 1
fi
echo -e "${GREEN}  ✓ All package files (.xdo, .xdm, .rtf, .sql, .xml) successfully generated${NC}"

# 4. Test deploy pre-flight & packaging
echo "  [4/4] Testing deployment pre-flight validation..."
# Non-existent report should fail with code 1
set +e
"$DEPLOY_SCRIPT" "Custom/NonExistent/FakeReport" > /dev/null 2>&1
EXIT_CODE=$?
set -e
if [ "$EXIT_CODE" -eq 0 ]; then
  echo -e "${RED}❌ deploy-template.sh should have failed for non-existent report!${NC}"
  exit 1
fi
echo -e "${GREEN}  ✓ Non-existent report check safely rejected${NC}"

# Cleanup test directory
rm -rf "$WORKSPACE_DIR/applications/publisher/Custom/TestDomain"

echo -e "${GREEN}✅ Test Edukas: Publisher scaffolding and deployment verification passed!${NC}"
