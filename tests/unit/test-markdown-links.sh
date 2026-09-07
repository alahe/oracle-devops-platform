#!/usr/bin/env bash
# ============================================================================
# Markdown Links Verification Unit Test
# Scans all repository Markdown files (*.md) and asserts that all relative
# links point to valid, existing files and directories.
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🔍 Validating all Markdown links across repository..."

BROKEN_COUNT=$(python3 -c '
import os, re, glob, sys

broken = []
total = 0
workspace = "'"$WORKSPACE_DIR"'"

for md in glob.glob(os.path.join(workspace, "**/*.md"), recursive=True):
    # Ignore hidden folders, logs, .git, etc.
    rel_md = os.path.relpath(md, workspace)
    if "/." in rel_md or rel_md.startswith(".") or "install_logs" in rel_md or "node_modules" in rel_md or "db-install" in rel_md:
        continue
    
    try:
        with open(md, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
    except:
        continue
        
    dir_path = os.path.dirname(md)
    links = re.findall(r"\[([^\]]+)\]\(([^)]+)\)", content)
    for text, link in links:
        if link.startswith("http://") or link.startswith("https://") or link.startswith("#") or link.startswith("mailto:") or link.startswith("file://") or link.startswith("conversation://"):
            continue
        total += 1
        clean_link = link.split("#")[0].strip()
        if not clean_link:
            continue
        target = os.path.normpath(os.path.join(dir_path, clean_link))
        if not os.path.exists(target):
            broken.append((rel_md, text, link, os.path.relpath(target, workspace)))

print(f"Verified {total} Markdown links across repository.")
if broken:
    print(f"❌ Found {len(broken)} broken link(s):")
    for src, txt, lnk, tgt in broken:
        print(f"   • In {src}: [{txt}]({lnk}) -> Target not found: {tgt}")
    sys.exit(len(broken))
else:
    print("✅ All relative Markdown links are 100% valid!")
    sys.exit(0)
')

EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
  echo "$BROKEN_COUNT"
  exit 1
fi

echo "$BROKEN_COUNT"
