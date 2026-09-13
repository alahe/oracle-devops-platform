#!/usr/bin/env bash
# ==============================================================================
# Unit Test: Dev Hub GitHub Copilot Assistant & Zero-Trust RAG Integration
# Tests:
# 1. Python copilot engine (status, sanitization, RAG context, offline response)
# 2. Zero-Trust secret redaction (Rule 5)
# 3. Dev Hub Bridge endpoint definitions
# 4. 6-Language i18n key symmetry (EN, ET, FI, SV, LV, LT)
# 5. Frontend template DOM elements in dev-hub.html
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🤖 Testing Dev Hub GitHub Copilot Assistant & RAG Engine..."

# 1. Test copilot.py python module integrity & basic execution
echo "  [1/5] Testing copilot.py core functions and status detection..."
python3 -c '
import sys, os
sys.path.insert(0, os.path.join("'"$WORKSPACE_DIR"'", "scripts", "internal"))
from dev_hub.copilot import get_copilot_status, sanitize_text, get_smart_rag_context, generate_offline_response, generate_vscode_deeplink

# Status check
status = get_copilot_status()
assert isinstance(status, dict), "Status must be a dictionary"
assert "available" in status, "Missing available key in status"
assert "auth_type" in status, "Missing auth_type key in status"
assert "model" in status, "Missing model key in status"

# Sanitizer test (Rule 5 Zero-Trust)
dirty_text = "Connect with ADMIN_PASSWORD: MySecretPass123 and token ghp_ABC1234567890123456789012345678901234567"
clean_text = sanitize_text(dirty_text)
assert "MySecretPass123" not in clean_text, "Failed to redact password"
assert "ghp_ABC1234567890123456789012345678901234567" not in clean_text, "Failed to redact GitHub token"
assert "[REDACTED_SECRET]" in clean_text or "[REDACTED_GITHUB_TOKEN]" in clean_text, "Missing redaction placeholder"

# RAG context test
rag = get_smart_rag_context("publisher reports fonts", "en")
assert "active_blueprint_summary" in rag, "Missing active_blueprint_summary in RAG"
assert "sources" in rag, "Missing sources in RAG"

# Offline response test
offline_resp = generate_offline_response("kuidas publisher töötab?", "et", rag)
assert len(offline_resp) > 50, "Offline response too short"

# Deep link test
link_info = generate_vscode_deeplink("test question", "en")
assert link_info["vscode_url"].startswith("vscode://"), "Invalid VS Code protocol URL"
assert len(link_info["clipboard_content"]) > 0, "Missing clipboard context"
print("    ✓ copilot.py core functions passed")
'

# 2. Test Zero-Trust secret redaction against diverse credential patterns
echo "  [2/5] Testing Rule 5 Zero-Trust credential sanitization..."
python3 -c '
import sys, os
sys.path.insert(0, os.path.join("'"$WORKSPACE_DIR"'", "scripts", "internal"))
from dev_hub.copilot import sanitize_text

test_cases = [
    ("ALTER USER c##test IDENTIFIED BY \"VerySecret123!\";", "VerySecret123!"),
    ("export DB_SYS_PASSWORD=\"Or@cleP@ss2026\"", "Or@cleP@ss2026"),
    ("bearer gho_abcdefghijklmnopqrstuvwxyz1234567890", "gho_abcdefghijklmnopqrstuvwxyz1234567890"),
    ("-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASC\n-----END PRIVATE KEY-----", "MIIEvgIBADANBgkqhkiG9w0BAQEFAASC"),
    ("password: secret_cleartext_val", "secret_cleartext_val"),
    ("cwallet.sso /opt/oracle/admin/FREE/wallet", None)
]

for text, secret in test_cases:
    sanitized = sanitize_text(text)
    if secret:
        assert secret not in sanitized, f"Leak detected for: {secret}"
print("    ✓ All Zero-Trust secret patterns successfully redacted")
'

# 3. Test Dev Hub Bridge endpoint definitions
echo "  [3/5] Testing dev-hub-bridge.py endpoint definitions..."
if ! grep -q 'path == "/api/copilot/status"' "$WORKSPACE_DIR/scripts/internal/dev-hub-bridge.py"; then
  echo "❌ Error: /api/copilot/status missing in dev-hub-bridge.py"
  exit 1
fi
if ! grep -q 'path == "/api/copilot/chat"' "$WORKSPACE_DIR/scripts/internal/dev-hub-bridge.py"; then
  echo "❌ Error: /api/copilot/chat missing in dev-hub-bridge.py"
  exit 1
fi
if ! grep -q 'path == "/api/copilot/deeplink"' "$WORKSPACE_DIR/scripts/internal/dev-hub-bridge.py"; then
  echo "❌ Error: /api/copilot/deeplink missing in dev-hub-bridge.py"
  exit 1
fi
echo "    ✓ Dev Hub Bridge routes verified"

# 4. Test 6-language i18n key parity for copilot keys
echo "  [4/5] Testing 6-language i18n parity for Copilot keys..."
node -e '
const fs = require("fs");
const content = fs.readFileSync("'"$WORKSPACE_DIR"'/scripts/internal/dev_hub/assets/i18n.js", "utf8");

const I18N_DICT = (new Function(content + "\nreturn I18N_DICT;"))();
const requiredLangs = ["en", "et", "fi", "sv", "lv", "lt"];
const expectedKeys = [
  "copilot_btn_label",
  "header_copilot_label",
  "tip_header_copilot",
  "btn_cockpit_ai",
  "tip_cockpit_ai",
  "copilot_drawer_title",
  "copilot_drawer_subtitle",
  "copilot_input_placeholder",
  "copilot_btn_send",
  "copilot_btn_vscode",
  "copilot_quick_blueprint",
  "copilot_quick_wallet",
  "copilot_quick_publisher",
  "copilot_quick_testing",
  "copilot_status_connected",
  "copilot_status_offline",
  "copilot_toast_vscode",
  "copilot_clear_chat"
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
console.log("    ✓ All 18 Copilot keys verified across 6 languages (EN, ET, FI, SV, LV, LT)");
'

# 5. Test DOM layout and Dev Hub HTML integration
echo "  [5/5] Testing Copilot DOM components in layout and compiled HTML..."
for elem in "copilot-drawer" "copilot-floating-container" "copilot-trigger-btn" "header-copilot-btn" "btn-compact-ai" "copilot-messages" "copilot-input"; do
  if ! grep -q "$elem" "$WORKSPACE_DIR/scripts/internal/dev_hub/assets/templates/layout.html"; then
    echo "❌ Missing DOM element in layout.html: $elem"
    exit 1
  fi
  if [ -f "$WORKSPACE_DIR/docs/dev-hub.html" ] && ! grep -q "$elem" "$WORKSPACE_DIR/docs/dev-hub.html"; then
    echo "❌ Missing DOM element in compiled docs/dev-hub.html: $elem"
    exit 1
  fi
done
echo "    ✓ Copilot DOM elements verified in layout and dev-hub.html"

echo "✅ ALL Dev Hub GitHub Copilot unit tests passed successfully!"
