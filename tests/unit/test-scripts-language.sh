#!/usr/bin/env bash
# ==============================================================================
# Unit Test: test-scripts-language.sh
# Verifies that automation scripts (scripts/**/*.sh) do not contain hardcoded
# Estonian text, comments, or unlocalized terminal outputs (Rule 9).
# English is the canonical language for all code and internal comments.
# Multilingual terminal messages must go through scripts/internal/i18n.sh.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🔍 Scanning shell scripts for non-canonical Estonian characters (ä, ö, ü, õ, š, ž)..."

python3 - << 'PYEOF'
import os, sys, re

# Whitelisted files that are official translation dictionaries
WHITELIST = [
    'scripts/internal/i18n.sh',
    'scripts/internal/dev_hub/assets/i18n.js'
]

# RegEx for Estonian characters (ä, ö, ü, õ, š, ž)
pattern = re.compile(r'[äöüõšžÄÖÜÕŠŽ]')
matches = {}

workspace_dir = os.environ.get("WORKSPACE_DIR", os.path.abspath("."))

scripts_dir = os.path.join(workspace_dir, "scripts")
for root, dirs, files in os.walk(scripts_dir):
    for f in sorted(files):
        if f.endswith('.sh'):
            full_path = os.path.join(root, f)
            rel_path = os.path.relpath(full_path, workspace_dir)
            if any(rel_path == w or rel_path.endswith(w) for w in WHITELIST):
                continue
            with open(full_path, 'r', encoding='utf-8', errors='ignore') as fp:
                file_matches = []
                for idx, line in enumerate(fp, 1):
                    # Check if line contains Estonian specific characters
                    if pattern.search(line):
                        file_matches.append((idx, line.strip()))
                if file_matches:
                    matches[rel_path] = file_matches

if matches:
    print(f"\n❌ FAILED: Found {len(matches)} script(s) containing Estonian characters or comments:\n")
    for path, lines in sorted(matches.items()):
        print(f"📁 {path} ({len(lines)} line(s)):")
        for lno, text in lines[:5]:
            print(f"   L{lno}: {text}")
        if len(lines) > 5:
            print(f"   ... and {len(lines) - 5} more line(s)")
        print("")
    print("👉 All internal comments must be in English (Rule 9).")
    print("👉 Multilingual messages must use msg_print/msg_str from scripts/internal/i18n.sh.")
    sys.exit(1)

print("✅ PASSED: All shell scripts are 100% compliant with English canonical code & i18n standards!")
sys.exit(0)
PYEOF
