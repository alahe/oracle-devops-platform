#!/usr/bin/env bash
# ==============================================================================
# Unit Test: test-filename-portability.sh
# Verifies cross-platform filename and path portability (Rule 13).
# Ensures zero Windows NTFS/FAT illegal characters, no trailing dots/spaces,
# no Windows reserved device names (CON, PRN, AUX, NUL, COM1-9, LPT1-9),
# no spaces or non-ASCII diacritics in pathnames, and no case collisions.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🔍 Auditing repository paths for cross-platform portability (Rule 13)..."

python3 - << 'PYEOF'
import os, sys, re, subprocess

workspace_dir = os.environ.get("WORKSPACE_DIR", os.path.abspath("."))

# Retrieve tracked files using git ls-files -z for exact NUL-delimited paths
try:
    proc = subprocess.run(
        ["git", "ls-files", "-z"],
        cwd=workspace_dir,
        capture_output=True,
        check=True
    )
    files = [f for f in proc.stdout.decode('utf-8', errors='surrogateescape').split('\0') if f]
except Exception as e:
    # Fallback to os.walk if git is unavailable
    files = []
    for root, dirs, fnames in os.walk(workspace_dir):
        if '.git' in root.split(os.sep):
            continue
        for fn in fnames:
            rel = os.path.relpath(os.path.join(root, fn), workspace_dir)
            files.append(rel)

# Forbidden characters on Windows NTFS/FAT: < > : " \ | ? *
ILLEGAL_CHARS_PATTERN = re.compile(r'[<>:"\\|?*]')

# Windows reserved device names: CON, PRN, AUX, NUL, COM1-COM9, LPT1-LPT9 (case-insensitive)
RESERVED_DOS_NAMES = re.compile(r'^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(\..*)?$', re.IGNORECASE)

# Non-ASCII detection
NON_ASCII_PATTERN = re.compile(r'[^\x00-\x7F]')

errors = []
case_collision_map = {} # dir_path -> {lower_name: original_name}

for path in files:
    # Check max length
    if len(path) > 240:
        errors.append(f"PATH TOO LONG ({len(path)} > 240 chars): {path}")

    # Check non-ASCII in path
    if NON_ASCII_PATTERN.search(path):
        errors.append(f"NON-ASCII CHARACTERS IN PATH: {path}")

    # Check spaces in path
    if ' ' in path:
        errors.append(f"UNESCAPED SPACE IN PATH: {path}")

    parts = path.split('/')
    parent_dir = '/'.join(parts[:-1]) if len(parts) > 1 else ''
    filename = parts[-1]

    # Check case collisions in the same directory
    dir_entry = case_collision_map.setdefault(parent_dir, {})
    lower_fn = filename.lower()
    if lower_fn in dir_entry and dir_entry[lower_fn] != filename:
        errors.append(f"CASE COLLISION: '{parent_dir}/{filename}' conflicts with '{parent_dir}/{dir_entry[lower_fn]}'")
    else:
        dir_entry[lower_fn] = filename

    # Check parts for illegal characters, trailing dots/spaces, reserved names
    for part in parts:
        if ILLEGAL_CHARS_PATTERN.search(part):
            errors.append(f"FORBIDDEN CHARACTERS (< > : \" \\ | ? *): {path} (in segment '{part}')")
        if part.endswith(' ') or part.endswith('.'):
            errors.append(f"TRAILING DOT OR SPACE: {path} (in segment '{part}')")
        if RESERVED_DOS_NAMES.match(part):
            errors.append(f"RESERVED WINDOWS DEVICE NAME: {path} (in segment '{part}')")

if errors:
    print(f"\n❌ FAILED: Found {len(errors)} cross-platform filename portability violation(s):\n")
    for err in errors:
        print(f"   ⚠️  {err}")
    print("\n👉 Refer to Rule 13 in .agents/AGENTS.md and .agents/skills/cross_platform_portability/SKILL.md")
    print("👉 Windows NTFS and FAT filesystems prohibit these characters and patterns.")
    sys.exit(1)

print(f"✅ PASSED: All {len(files)} repository paths comply with cross-platform portability rules.")
PYEOF
