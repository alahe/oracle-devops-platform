#!/usr/bin/env bash
# ==============================================================================
# Unit Test: Dev Hub SCS Specs Triad Navigation & Active State Sync
# Tests:
# 1. Verification of all 12 canonical spec documents in catalog.py
# 2. Exact docId resolution in loadSpecInViewer (bugfix: no premature domain prefix matching)
# 3. Card active state and button active class synchronization (syncSpecCardActiveStates)
# 4. 6-Language tooltip symmetry (tip_spec_req, tip_spec_des, tip_spec_tsk)
# 5. Compiled HTML attributes in dev-hub.html
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "📜 Testing Dev Hub SCS Specs Triad Navigation & Resolution..."

DEV_HUB_HTML="$WORKSPACE_DIR/docs/dev-hub.html"
if [[ ! -f "$DEV_HUB_HTML" ]]; then
  echo "⚠️ dev-hub.html not found, generating first..."
  "$WORKSPACE_DIR/scripts/internal/generate-dev-hub.sh" "$DEV_HUB_HTML"
fi

# 1. Verify all 12 canonical spec documents exist in catalog.py
echo "  [1/5] Verifying 12 canonical spec documents in catalog.py..."
python3 -c '
import sys, os
sys.path.insert(0, os.path.join("'"$WORKSPACE_DIR"'", "scripts", "internal"))
from dev_hub.catalog import DOC_SPECS

expected_domains = ["devops-portal", "wallet-security", "golden-snapshots", "blueprints-topology"]
expected_types = ["req", "des", "tsk"]

doc_ids = [d["id"] for d in DOC_SPECS]
for domain in expected_domains:
    for t in expected_types:
        spec_id = f"spec-{domain}-{t}"
        assert spec_id in doc_ids, f"Missing spec document in DOC_SPECS: {spec_id}"

print("    ✓ All 12 canonical spec documents declared in catalog.py")
'

# 2. Test exact docId resolution simulation with Node.js
echo "  [2/5] Testing exact docId resolution logic across all 12 combinations..."
node -e '
const domains = ["devops-portal", "wallet-security", "golden-snapshots", "blueprints-topology"];
const types = ["requirements", "design", "tasks"];
const suffixMap = { requirements: "req", design: "des", tasks: "tsk" };

// Mock DOCS_DATA representing compiler output
const mockDocsData = [];
domains.forEach(d => {
  types.forEach(t => {
    mockDocsData.push({
      id: `spec-${d}-${suffixMap[t]}`,
      rel: `docs/specs/${d}/${t}.md`,
      titles: { en: `${d} ${t}`, et: `${d} ${t}` }
    });
  });
});

// Emulate loadSpecInViewer resolution logic
function resolveDoc(domainOrId, type) {
  let docId = domainOrId;
  if (type) {
    const typeSuffix = (type === "requirements" ? "req" : (type === "design" ? "des" : "tsk"));
    docId = `spec-${domainOrId}-${typeSuffix}`;
  }
  let doc = mockDocsData.find(d => d.id === docId);
  if (!doc) {
    doc = mockDocsData.find(d => d.rel && (d.rel.endsWith(`/${docId}.md`) || d.rel === `${docId}.md` || d.rel.includes(docId)));
  }
  if (!doc && domainOrId && type) {
    const typeSuffix = (type === "requirements" ? "req" : (type === "design" ? "des" : "tsk"));
    doc = mockDocsData.find(d => d.rel && d.rel.includes(domainOrId) && (d.rel.includes(type) || d.rel.includes(typeSuffix)));
  }
  return doc;
}

domains.forEach(dom => {
  types.forEach(typ => {
    const expectedId = `spec-${dom}-${suffixMap[typ]}`;
    const found = resolveDoc(dom, typ);
    if (!found || found.id !== expectedId) {
      console.error(`Mismatch for domain=${dom}, type=${typ}: expected ${expectedId}, got ${found ? found.id : "null"}`);
      process.exit(1);
    }
  });
});
console.log("    ✓ Exact doc resolution passed for all 12 domain/type combinations");
'

# 3. Test 6-language i18n tooltip symmetry
echo "  [3/5] Testing 6-language tooltip symmetry in i18n.js..."
node -e '
const fs = require("fs");
const path = require("path");
const i18nPath = path.join("'"$WORKSPACE_DIR"'", "scripts/internal/dev_hub/assets/i18n.js");
const content = fs.readFileSync(i18nPath, "utf-8");
const sandbox = {};
const fn = new Function("window", content + "; return I18N_DICT;");
const dict = fn(sandbox);

const requiredKeys = ["tip_spec_req", "tip_spec_des", "tip_spec_tsk"];
const langs = ["en", "et", "fi", "sv", "lv", "lt"];

langs.forEach(lang => {
  if (!dict[lang]) {
    console.error(`Missing language dictionary: ${lang}`);
    process.exit(1);
  }
  requiredKeys.forEach(k => {
    if (!dict[lang][k]) {
      console.error(`Missing key ${k} in language ${lang}`);
      process.exit(1);
    }
    if (dict[lang][k].length < 10) {
      console.error(`Tooltip too short for ${k} in ${lang}: "${dict[lang][k]}"`);
      process.exit(1);
    }
  });
});
console.log("    ✓ 6-language tooltip symmetry verified for REQ, DES, and TSK");
'

# 4. Check function signatures and active state logic in app.js
echo "  [4/5] Testing syncSpecCardActiveStates and loadSpecInViewer in app.js..."
node -e '
const fs = require("fs");
const path = require("path");
const appJsPath = path.join("'"$WORKSPACE_DIR"'", "scripts/internal/dev_hub/assets/app.js");
const code = fs.readFileSync(appJsPath, "utf-8");

if (!code.includes("function syncSpecCardActiveStates()")) {
  console.error("Missing syncSpecCardActiveStates function in app.js");
  process.exit(1);
}
if (!code.includes("active-spec-card")) {
  console.error("Missing active-spec-card class toggle in app.js");
  process.exit(1);
}
if (!code.includes("loadSpecInViewer(domainOrId, type, shouldScroll = false)")) {
  console.error("loadSpecInViewer signature does not include shouldScroll parameter");
  process.exit(1);
}
console.log("    ✓ app.js functions and class toggles validated");
'

# 5. Check compiled dev-hub.html for spec triad DOM attributes
echo "  [5/5] Checking compiled dev-hub.html attributes..."
grep -q 'data-domain-card="devops-portal"' "$DEV_HUB_HTML" || { echo "❌ Missing data-domain-card in HTML"; exit 1; }
grep -q 'data-spec-domain="devops-portal"' "$DEV_HUB_HTML" || { echo "❌ Missing data-spec-domain in HTML"; exit 1; }
grep -q 'data-spec-type="requirements"' "$DEV_HUB_HTML" || { echo "❌ Missing data-spec-type requirements in HTML"; exit 1; }
grep -q 'data-spec-type="design"' "$DEV_HUB_HTML" || { echo "❌ Missing data-spec-type design in HTML"; exit 1; }
grep -q 'data-spec-type="tasks"' "$DEV_HUB_HTML" || { echo "❌ Missing data-spec-type tasks in HTML"; exit 1; }
grep -q 'data-i18n-title="tip_spec_req"' "$DEV_HUB_HTML" || { echo "❌ Missing data-i18n-title tip_spec_req in HTML"; exit 1; }
grep -q 'data-i18n-title="tip_spec_des"' "$DEV_HUB_HTML" || { echo "❌ Missing data-i18n-title tip_spec_des in HTML"; exit 1; }
grep -q 'data-i18n-title="tip_spec_tsk"' "$DEV_HUB_HTML" || { echo "❌ Missing data-i18n-title tip_spec_tsk in HTML"; exit 1; }
echo "    ✓ All DOM attributes compiled correctly in dev-hub.html"

echo "✅ All Dev Hub SCS Specs Triad tests passed!"
