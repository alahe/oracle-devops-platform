#!/usr/bin/env bash
# ==============================================================================
# Unit Test: Dev Hub Multi-Provider AI (GitHub Copilot + Google Antigravity)
# Tests:
# 1. Python AI status detection (both Copilot & Antigravity)
# 2. Antigravity chat execution & deterministic local fallback
# 3. Antigravity deep-link URL and rich clipboard context generation
# 4. Rule 5 Zero-Trust credential sanitization for Antigravity queries
# 5. Dev Hub Bridge /api/ai/* and /api/copilot/* endpoint definitions
# 6. 6-Language i18n key parity across EN, ET, FI, SV, LV, LT
# 7. Frontend layout DOM elements (provider switcher, dual export buttons)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🤖 Testing Dev Hub Multi-Provider AI (Copilot + Antigravity)..."

# 1. Test copilot.py multi-provider functions and status detection
echo "  [1/6] Testing get_ai_status and get_antigravity_status..."
python3 -c '
import sys, os
sys.path.insert(0, os.path.join("'"$WORKSPACE_DIR"'", "scripts", "internal"))
from dev_hub.copilot import get_ai_status, get_antigravity_status, get_copilot_status

ai_st = get_ai_status()
assert ai_st["status"] == "ok", "Invalid AI status"
assert "providers" in ai_st, "Missing providers dict in AI status"
assert "copilot" in ai_st["providers"], "Missing copilot provider in AI status"
assert "antigravity" in ai_st["providers"], "Missing antigravity provider in AI status"

ag_st = get_antigravity_status()
assert ag_st["status"] == "ok", "Invalid Antigravity status"
assert "available" in ag_st, "Missing available key in Antigravity status"
assert "app_installed" in ag_st, "Missing app_installed key in Antigravity status"
assert "has_cli" in ag_st, "Missing has_cli key in Antigravity status"
assert "version" in ag_st, "Missing version key in Antigravity status"
print("    ✓ AI multi-provider status check passed")
'

# 2. Test ask_ai with antigravity provider
echo "  [2/6] Testing ask_ai(provider=\"antigravity\")..."
python3 -c '
import sys, os
sys.path.insert(0, os.path.join("'"$WORKSPACE_DIR"'", "scripts", "internal"))
from dev_hub.copilot import ask_ai

resp_et = ask_ai("antigravity", "kuidas käivitada blueprint 3?", current_lang="et")
assert resp_et["status"] == "ok", "Antigravity chat response failed (ET)"
assert resp_et["provider"] == "antigravity", "Wrong provider in response"
assert len(resp_et["reply"]) > 50, "Antigravity reply too short"

resp_en = ask_ai("antigravity", "how to get passwords from wallet?", current_lang="en")
assert resp_en["status"] == "ok", "Antigravity chat response failed (EN)"
assert "sources" in resp_en, "Missing sources in response"
print("    ✓ ask_ai(provider=\"antigravity\") execution passed")
'

# 3. Test generate_ai_deeplink with target antigravity
echo "  [3/6] Testing generate_ai_deeplink(target=\"antigravity\")..."
python3 -c '
import sys, os
sys.path.insert(0, os.path.join("'"$WORKSPACE_DIR"'", "scripts", "internal"))
from dev_hub.copilot import generate_ai_deeplink

link_info = generate_ai_deeplink("antigravity", "kuidas muuta publisher malli?", current_lang="et")
assert link_info["status"] == "ok", "Failed to generate antigravity deeplink"
assert link_info["target"] == "antigravity", "Wrong target in deeplink"
assert link_info["antigravity_url"].startswith("antigravity://"), "Invalid antigravity URL protocol"
assert "## Context: Oracle DevOps Platform" in link_info["clipboard_content"], "Missing context header in clipboard payload"
assert "kuidas muuta publisher malli?" in link_info["clipboard_content"], "Missing user query in clipboard payload"
print("    ✓ Antigravity deep-link & clipboard generation passed")
'

# 4. Test Zero-Trust secret redaction during Antigravity execution
echo "  [4/6] Testing Rule 5 Zero-Trust credential sanitization for Antigravity..."
python3 -c '
import sys, os
sys.path.insert(0, os.path.join("'"$WORKSPACE_DIR"'", "scripts", "internal"))
from dev_hub.copilot import ask_ai

dirty_query = "Kuidas logida sisse kui password: SecretPassword999 ja token gho_1234567890abcdefghijklmnopqrstuvwxyz?"
resp = ask_ai("antigravity", dirty_query, current_lang="et")
assert "SecretPassword999" not in resp["reply"], "Password leaked into response"
assert "gho_1234567890abcdefghijklmnopqrstuvwxyz" not in resp["reply"], "GitHub token leaked into response"
print("    ✓ Zero-Trust credential sanitization verified")
'

# 5. Test Bridge endpoint definitions
echo "  [5/6] Testing dev-hub-bridge.py endpoint definitions..."
for ep in "/api/ai/status" "/api/ai/chat" "/api/ai/deeplink" "/api/copilot/status" "/api/copilot/chat" "/api/copilot/deeplink"; do
  if ! grep -q "$ep" "$WORKSPACE_DIR/scripts/internal/dev-hub-bridge.py"; then
    echo "❌ Error: Endpoint $ep missing in dev-hub-bridge.py"
    exit 1
  fi
done
echo "    ✓ All bridge endpoints (/api/ai/* & legacy /api/copilot/*) verified"

# 6. Test 6-language i18n key parity and DOM layout elements
echo "  [6/6] Testing 6-language i18n parity and DOM elements..."
node -e '
const fs = require("fs");
const content = fs.readFileSync("'"$WORKSPACE_DIR"'/scripts/internal/dev_hub/assets/i18n.js", "utf8");
const I18N_DICT = (new Function(content + "\nreturn I18N_DICT;"))();

const requiredLangs = ["en", "et", "fi", "sv", "lv", "lt"];
const expectedKeys = [
  "copilot_btn_antigravity",
  "copilot_provider_copilot",
  "copilot_provider_antigravity",
  "copilot_status_antigravity",
  "copilot_toast_antigravity"
];

for (const lang of requiredLangs) {
  if (!I18N_DICT[lang]) {
    console.error(`❌ Language ${lang} missing from I18N dictionary`);
    process.exit(1);
  }
  for (const k of expectedKeys) {
    if (!I18N_DICT[lang][k]) {
      console.error(`❌ Key ${k} missing in language ${lang}`);
      process.exit(1);
    }
  }
}
console.log("    ✓ All Antigravity keys verified across 6 languages");
'

for elem in "ai-provider-copilot" "ai-provider-antigravity" "copilot-vscode-btn" "copilot-antigravity-btn"; do
  if ! grep -q "$elem" "$WORKSPACE_DIR/scripts/internal/dev_hub/assets/templates/layout.html"; then
    echo "❌ Missing DOM element in layout.html: $elem"
    exit 1
  fi
done
echo "    ✓ All Antigravity DOM elements verified in layout.html"

echo "✅ ALL Dev Hub Multi-Provider AI (Copilot + Antigravity) unit tests passed successfully!"
