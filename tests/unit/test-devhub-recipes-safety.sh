#!/usr/bin/env bash
# ==============================================================================
# Unit Test: Dev Hub DevOps Recipes 2-Stage Safety & Testing AI Assistant
# Tests:
# 1. Verification of DevOps recipe cards and preview pills
# 2. Recipe Inspector Modal DOM structure in dev-hub.html
# 3. Recipe metadata and safety confirmation logic in app.js
# 4. Testing suite cards AI button and askAiAboutTestSuite integration
# 5. 6-Language i18n key parity for recipes and testing AI
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🛡️ Testing Dev Hub DevOps Recipes 2-Stage Safety & Testing AI Assistant..."

DEV_HUB_HTML="$WORKSPACE_DIR/docs/dev-hub.html"
if [[ ! -f "$DEV_HUB_HTML" ]]; then
  echo "⚠️ dev-hub.html not found, generating first..."
  "$WORKSPACE_DIR/scripts/internal/generate-dev-hub.sh" "$DEV_HUB_HTML"
fi

# 1. Verify recipe cards and preview pill in dev-hub.html
echo "  [1/5] Checking recipe cards and preview pills in dev-hub.html..."
grep -q "openDevOpsRecipeModal('fast-start')" "$DEV_HUB_HTML" || { echo "❌ Missing openDevOpsRecipeModal fast-start"; exit 1; }
grep -q "openDevOpsRecipeModal('onboard-dev')" "$DEV_HUB_HTML" || { echo "❌ Missing openDevOpsRecipeModal onboard-dev"; exit 1; }
grep -q "openDevOpsRecipeModal('full-diag')" "$DEV_HUB_HTML" || { echo "❌ Missing openDevOpsRecipeModal full-diag"; exit 1; }
grep -q "openDevOpsRecipeModal('golden-snap')" "$DEV_HUB_HTML" || { echo "❌ Missing openDevOpsRecipeModal golden-snap"; exit 1; }
grep -q 'recipe-preview-pill' "$DEV_HUB_HTML" || { echo "❌ Missing recipe-preview-pill class in dev-hub.html"; exit 1; }
echo "    ✓ Recipe cards call modal inspector and display preview pills"

# 2. Verify Recipe Inspector Modal DOM structure in dev-hub.html
echo "  [2/5] Checking Recipe Inspector Modal DOM elements in dev-hub.html..."
grep -q 'id="devops-recipe-modal"' "$DEV_HUB_HTML" || { echo "❌ Missing #devops-recipe-modal"; exit 1; }
grep -q 'id="recipe-modal-icon"' "$DEV_HUB_HTML" || { echo "❌ Missing #recipe-modal-icon"; exit 1; }
grep -q 'id="recipe-modal-title"' "$DEV_HUB_HTML" || { echo "❌ Missing #recipe-modal-title"; exit 1; }
grep -q 'id="recipe-modal-risk-badge"' "$DEV_HUB_HTML" || { echo "❌ Missing #recipe-modal-risk-badge"; exit 1; }
grep -q 'id="recipe-modal-time-badge"' "$DEV_HUB_HTML" || { echo "❌ Missing #recipe-modal-time-badge"; exit 1; }
grep -q 'id="recipe-modal-desc"' "$DEV_HUB_HTML" || { echo "❌ Missing #recipe-modal-desc"; exit 1; }
grep -q 'id="recipe-modal-steps"' "$DEV_HUB_HTML" || { echo "❌ Missing #recipe-modal-steps"; exit 1; }
grep -q 'id="recipe-modal-warning"' "$DEV_HUB_HTML" || { echo "❌ Missing #recipe-modal-warning"; exit 1; }
grep -q 'id="btn-execute-recipe"' "$DEV_HUB_HTML" || { echo "❌ Missing #btn-execute-recipe"; exit 1; }
grep -q 'onclick="copyActiveRecipeCommands()"' "$DEV_HUB_HTML" || { echo "❌ Missing copyActiveRecipeCommands button"; exit 1; }
grep -q 'onclick="askAiAboutActiveRecipe()"' "$DEV_HUB_HTML" || { echo "❌ Missing askAiAboutActiveRecipe button"; exit 1; }
echo "    ✓ All Recipe Inspector Modal DOM elements validated"

# 3. Test recipe metadata and safety confirmation logic in app.js
echo "  [3/5] Testing DEVOPS_RECIPES_META and safety confirmation in app.js..."
node -e '
const fs = require("fs");
const path = require("path");
const appJsPath = path.join("'"$WORKSPACE_DIR"'", "scripts/internal/dev_hub/assets/app.js");
const code = fs.readFileSync(appJsPath, "utf-8");

// Check function declarations
const requiredFns = [
  "openDevOpsRecipeModal",
  "closeDevOpsRecipeModal",
  "copyActiveRecipeCommands",
  "askAiAboutActiveRecipe",
  "executeActiveRecipeConfirmed"
];
requiredFns.forEach(fn => {
  if (!code.includes(`function ${fn}`)) {
    console.error(`Missing function ${fn} in app.js`);
    process.exit(1);
  }
});

// Check DEVOPS_RECIPES_META definition
if (!code.includes("const DEVOPS_RECIPES_META = {")) {
  console.error("Missing DEVOPS_RECIPES_META dictionary in app.js");
  process.exit(1);
}

// Check destructive safety confirmation
if (!code.includes("if (recipeKey === \x27fast-start\x27)") || !code.includes("confirm(confirmMsg)")) {
  console.error("Missing destructive confirmation check for fast-start in executeActiveRecipeConfirmed");
  process.exit(1);
}
console.log("    ✓ Recipe metadata, safety confirmation and controller functions validated");
'

# 4. Verify Testing Suites AI Button and askAiAboutTestSuite in app.js
echo "  [4/5] Checking Testing Suites AI button in app.js..."
node -e '
const fs = require("fs");
const path = require("path");
const appJsPath = path.join("'"$WORKSPACE_DIR"'", "scripts/internal/dev_hub/assets/app.js");
const code = fs.readFileSync(appJsPath, "utf-8");

if (!code.includes("askAiAboutTestSuite")) {
  console.error("Missing askAiAboutTestSuite in app.js");
  process.exit(1);
}
if (!code.includes("select-suite-")) {
  console.error("askAiAboutTestSuite does not reference select-suite- element");
  process.exit(1);
}
if (!code.includes("btn_test_ai")) {
  console.error("Missing btn_test_ai i18n usage in renderTestingSuites");
  process.exit(1);
}
console.log("    ✓ Testing suites AI button and context generator verified");
'

# 5. Verify 6-language i18n parity for recipe and testing AI keys
echo "  [5/5] Testing 6-language i18n parity for recipe and test AI keys..."
node -e '
const fs = require("fs");
const path = require("path");
const i18nPath = path.join("'"$WORKSPACE_DIR"'", "scripts/internal/dev_hub/assets/i18n.js");
const content = fs.readFileSync(i18nPath, "utf-8");
const sandbox = {};
const fn = new Function("window", content + "; return I18N_DICT;");
const dict = fn(sandbox);

const requiredKeys = [
  "recipe_pipeline_title",
  "recipe_warning_title",
  "recipe_warning_desc",
  "btn_copy_commands",
  "btn_execute_recipe",
  "recipe_toast_copied",
  "recipe_confirm_faststart",
  "btn_test_ai",
  "tip_test_ai"
];
const langs = ["en", "et", "fi", "sv", "lv", "lt"];

langs.forEach(lang => {
  if (!dict[lang]) {
    console.error(`Missing language ${lang}`);
    process.exit(1);
  }
  requiredKeys.forEach(k => {
    if (!dict[lang][k]) {
      console.error(`Missing key ${k} in language ${lang}`);
      process.exit(1);
    }
  });
});
console.log("    ✓ 6-language parity confirmed for all 9 recipe and test AI keys");
'

echo "✅ All Dev Hub DevOps Recipes Safety & Testing AI tests passed!"
