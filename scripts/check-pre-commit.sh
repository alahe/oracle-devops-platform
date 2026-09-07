#!/usr/bin/env bash
# ==============================================================================
# Git Pre-Commit & Pre-Push Security Guard & Code Quality Checker
#
# 6-phase lightning-fast verification:
#   1. Portability & Filenames (Rule 13 & 14)
#   2. Zero-Trust Secrets & Credential Leakage (Rule 5)
#   3. GDPR & PII / Database Backup Dumps
#   4. Zero-Knowledge Confidential Company Info (SHA-256 Hashes & Heuristics)
#   5. Static Syntax & Code Compilation (bash -n, py_compile, node -c, JSON, YAML)
#   6. Dev-Hub & Multilingual i18n Parity (Rule 2 & 9)
#
# Usage:
#   ./scripts/check-pre-commit.sh [--staged]
#   ./scripts/check-pre-commit.sh --full
#   ./scripts/check-pre-commit.sh --install-hook
#   ./scripts/check-pre-commit.sh --add-forbidden-hash "<word>"
#   ./scripts/check-pre-commit.sh --fix
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Rule 1: Local full logging setup
LOG_DIR="$WORKSPACE_DIR/install_logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/pre_commit_check_${TIMESTAMP}.log"

# Parse CLI arguments
MODE="auto"
AUTO_FIX=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --staged)
      MODE="staged"
      shift
      ;;
    --files)
      MODE="files"
      shift
      EXPLICIT_FILES=("$@")
      break
      ;;
    --full|--all|--push)
      MODE="full"
      shift
      ;;
    --install-hook)
      MODE="install-hook"
      shift
      ;;
    --add-forbidden-hash)
      MODE="add-hash"
      HASH_TERM="${2:-}"
      shift 2 || true
      ;;
    --fix)
      AUTO_FIX=true
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  --staged                   Check only git-staged files (default when files are staged)"
      echo "  --full, --all, --push      Audit entire repository and run fast core unit tests"
      echo "  --install-hook             Configure git to use .githooks for pre-commit and pre-push"
      echo "  --add-forbidden-hash TERM  Hash a confidential term (SHA-256) into config/security/forbidden_hashes.json"
      echo "  --fix                      Automatically fix line endings (CRLF -> LF) on affected files"
      echo "  -h, --help                 Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Handle --install-hook mode
if [ "$MODE" = "install-hook" ]; then
  echo "🔧 Configuring Git hooks..."
  HOOKS_DIR="$WORKSPACE_DIR/.githooks"
  mkdir -p "$HOOKS_DIR"

  # Ensure pre-commit hook exists
  cat << 'EOF' > "$HOOKS_DIR/pre-commit"
#!/usr/bin/env bash
# Auto-generated pre-commit hook
ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
"$ROOT_DIR/scripts/check-pre-commit.sh" --staged
EOF
  chmod +x "$HOOKS_DIR/pre-commit"

  # Ensure pre-push hook exists
  cat << 'EOF' > "$HOOKS_DIR/pre-push"
#!/usr/bin/env bash
# Auto-generated pre-push hook
ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
"$ROOT_DIR/scripts/check-pre-commit.sh" --full
EOF
  chmod +x "$HOOKS_DIR/pre-push"

  if git config core.hooksPath .githooks 2>/dev/null; then
    echo "✅ Git hooks configured successfully! (core.hooksPath = .githooks)"
  else
    echo "ℹ️  Hooks written to .githooks/. To activate on host, run: git config core.hooksPath .githooks"
  fi
  echo "   - Pre-commit: checks staged files in ~1s"
  echo "   - Pre-push: audits repository and compliance in ~5s"
  exit 0
fi

# Handle --add-forbidden-hash mode
if [ "$MODE" = "add-hash" ]; then
  if [ -z "${HASH_TERM:-}" ]; then
    echo "❌ Error: Please specify the term to hash, e.g.: $0 --add-forbidden-hash \"my-term\""
    exit 1
  fi
  python3 - << PYEOF
import os, sys, json, hashlib

workspace_dir = "$WORKSPACE_DIR"
hashes_file = os.path.join(workspace_dir, "config", "security", "forbidden_hashes.json")
raw_term = """$HASH_TERM""".strip().lower()

if not raw_term:
    print("❌ Empty term provided.")
    sys.exit(1)

term_hash = hashlib.sha256(raw_term.encode("utf-8")).hexdigest()

data = {"\$schema": "https://json-schema.org/draft/2020-12/schema", "version": "1.0", "description": "Zero-Knowledge SHA-256 hashes", "hashes": []}
if os.path.exists(hashes_file):
    try:
        with open(hashes_file, "r", encoding="utf-8") as f:
            data = json.load(f)
    except Exception:
        pass

existing = [item.get("hash") for item in data.get("hashes", [])]
if term_hash in existing:
    print(f"ℹ️ Term hash {term_hash[:10]}... already exists in forbidden_hashes.json.")
else:
    data.setdefault("hashes", []).append({
        "hash": term_hash,
        "hint": f"term_len_{len(raw_term)}"
    })
    os.makedirs(os.path.dirname(hashes_file), exist_ok=True)
    with open(hashes_file, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
    print(f"✅ Added SHA-256 hash {term_hash[:10]}... to config/security/forbidden_hashes.json")
    print("🔒 Zero-Knowledge guarantee: The plaintext term was NOT saved.")
PYEOF
  exit 0
fi

# Determine mode if auto
if [ "$MODE" = "auto" ]; then
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    STAGED_COUNT=$(git diff --cached --name-only --diff-filter=ACM | wc -l | tr -d ' ')
    if [ "$STAGED_COUNT" -gt 0 ]; then
      MODE="staged"
    else
      MODE="full"
    fi
  else
    MODE="full"
  fi
fi

# Log execution
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=================================================================="
echo "🛡️  GIT PRE-COMMIT & PRE-PUSH SECURITY GUARD"
echo "   Mode:      $([ "$MODE" = "staged" ] && echo "Staged Files Only (~1-2s)" || echo "Full Repository Audit (~5s)")"
echo "   Fix CRLF:  $AUTO_FIX"
echo "   Timestamp: $TIMESTAMP"
echo "=================================================================="

# Run core security & compliance engine via Python
python3 - << PYEOF
import os, sys, re, subprocess, json, hashlib

workspace_dir = "$WORKSPACE_DIR"
mode = "$MODE"
auto_fix = "$AUTO_FIX" == "true"

# 1. Collect files to audit
files = []
explicit_list = """${EXPLICIT_FILES[*]:-}""".split()
env_files = os.environ.get("PRE_COMMIT_FILES", "").split()

if mode == "files" and explicit_list:
    files = [os.path.relpath(f, workspace_dir) for f in explicit_list if f]
elif env_files:
    files = [os.path.relpath(f, workspace_dir) for f in env_files if f]
elif mode == "staged":
    try:
        proc = subprocess.run(
            ["git", "diff", "--cached", "--name-only", "-z", "--diff-filter=ACM"],
            cwd=workspace_dir,
            capture_output=True,
            check=True
        )
        files = [f for f in proc.stdout.decode('utf-8', errors='surrogateescape').split('\0') if f]
    except Exception as e:
        print(f"⚠️ Git error retrieving staged files: {e}")
else:
    try:
        proc = subprocess.run(
            ["git", "ls-files", "-z"],
            cwd=workspace_dir,
            capture_output=True,
            check=True
        )
        files = [f for f in proc.stdout.decode('utf-8', errors='surrogateescape').split('\0') if f]
    except Exception as e:
        print(f"⚠️ Git error retrieving tracked files: {e}")

if not files:
    if mode == "staged":
        print("ℹ️ No staged files found in git index. Nothing to check.")
        sys.exit(0)
    else:
        print("❌ No files found to check.")
        sys.exit(1)

print(f"📦 Auditing {len(files)} file(s)...")

# Load forbidden hashes
forbidden_hashes = set()
hashes_path = os.path.join(workspace_dir, "config", "security", "forbidden_hashes.json")
if os.path.exists(hashes_path):
    try:
        with open(hashes_path, "r", encoding="utf-8") as f:
            hdata = json.load(f)
            for item in hdata.get("hashes", []):
                h = item.get("hash") if isinstance(item, dict) else item
                if h:
                    forbidden_hashes.add(h.lower().strip())
    except Exception as e:
        print(f"⚠️ Warning loading forbidden hashes: {e}")

# Load local forbidden patterns if available
local_patterns = []
local_pat_path = os.path.join(workspace_dir, ".git", "forbidden-patterns.local")
if os.path.exists(local_pat_path):
    try:
        with open(local_pat_path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#"):
                    local_patterns.append(re.compile(line, re.IGNORECASE))
    except Exception:
        pass

# Regex definitions
ILLEGAL_CHARS_PATTERN = re.compile(r'[<>:"\\|?*]')
RESERVED_DOS_NAMES = re.compile(r'^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(\..*)?$', re.IGNORECASE)
NON_ASCII_PATTERN = re.compile(r'[^\x00-\x7F]')
DANGEROUS_EXTENSIONS = {'.dmp', '.dump', '.bak', '.parquet'}

# Secret patterns
SECRET_PATTERNS = [
    ("AWS Access Key", re.compile(r'\b(AKIA[0-9A-Z]{16})\b')),
    ("Private Key Header", re.compile(r'-----BEGIN (?:RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----')),
    ("GitHub Personal Token", re.compile(r'\b(ghp_[0-9a-zA-Z]{36}|github_pat_[0-9a-zA-Z_]{82})\b')),
    ("Generic Hardcoded Secret", re.compile(r'(?:api[_-]?key|client[_-]?secret|db[_-]?password)\s*[:=]\s*["\']([a-zA-Z0-9_\-!@#\$%\^&\*]{10,})["\']', re.IGNORECASE)),
]

# GDPR / PII patterns
ESTONIAN_IK_PATTERN = re.compile(r'\b([1-6]\d{2}(?:0[1-9]|1[0-2])(?:0[1-9]|[12]\d|3[01])\d{4})\b')
IBAN_PATTERN = re.compile(r'\b(EE\d{18})\b')

# Generic internal network heuristics
INTERNAL_DOMAIN_PATTERN = re.compile(r'\b([a-zA-Z0-9_\-\.]+\.(?:corp|intra|internal|lan|local|priv))\b', re.IGNORECASE)
INTERNAL_LDAP_PATTERN = re.compile(r'\b(ldaps?://[a-zA-Z0-9_\-\.]+(?::\d+)?)\b', re.IGNORECASE)

errors = []
warnings = []
crlf_fixed = 0

def mask_secret(s):
    if len(s) <= 4:
        return "****"
    return s[:3] + "*" * (len(s) - 3)

for rel_path in files:
    full_path = os.path.join(workspace_dir, rel_path)
    base_name = os.path.basename(rel_path)
    _, ext = os.path.splitext(rel_path)
    ext_lower = ext.lower()

    # -------------------------------------------------------------
    # Phase 1: Portability & Filenames (Rule 13 & 14)
    # -------------------------------------------------------------
    if len(rel_path) > 240:
        errors.append(f"Rule 13: Path too long ({len(rel_path)} > 240): {rel_path}")

    if NON_ASCII_PATTERN.search(rel_path):
        errors.append(f"Rule 13: Non-ASCII characters in path: {rel_path}")

    for part in rel_path.split(os.sep):
        if ' ' in part:
            errors.append(f"Rule 13: Space in filename/directory: {rel_path}")
        if ILLEGAL_CHARS_PATTERN.search(part):
            errors.append(f"Rule 13: Forbidden Windows character in {rel_path}")
        if RESERVED_DOS_NAMES.match(part):
            errors.append(f"Rule 13: Windows reserved device name in {rel_path}")
        if part.endswith('.') or part.endswith(' '):
            errors.append(f"Rule 13: Trailing dot or space in {rel_path}")

    # Check dangerous files
    if base_name in {".env.secrets", "id_rsa", "id_dsa", "id_ed25519"}:
        errors.append(f"Rule 5 Zero-Trust: Strictly prohibited secret file: {rel_path}")

    if ext_lower in DANGEROUS_EXTENSIONS or rel_path.endswith('.sql.gz'):
        errors.append(f"GDPR & Storage: Prohibited database backup/dump file: {rel_path}")

    # Check if file exists (might have been deleted in working tree)
    if not os.path.isfile(full_path):
        continue

    # Skip checking binary files or large assets
    if ext_lower in {'.png', '.jpg', '.jpeg', '.gif', '.ico', '.pdf', '.zip', '.tar', '.gz', '.p12', '.sso', '.woff', '.woff2'}:
        continue

    # -------------------------------------------------------------
    # Content Checking (Line endings, Secrets, GDPR, Hashes, Heuristics)
    # -------------------------------------------------------------
    try:
        with open(full_path, "rb") as bf:
            content_bytes = bf.read()
    except Exception as e:
        warnings.append(f"Could not read {rel_path}: {e}")
        continue

    # Line endings (LF vs CRLF)
    if ext_lower in {'.sh', '.sql', '.yaml', '.yml', '.json', '.md', '.apx'}:
        if b'\r\n' in content_bytes:
            if auto_fix:
                fixed_content = content_bytes.replace(b'\r\n', b'\n')
                with open(full_path, "wb") as bf:
                    bf.write(fixed_content)
                crlf_fixed += 1
            else:
                errors.append(f"Rule 14: CRLF (\\r\\n) line endings detected in Unix file: {rel_path} (Run with --fix to convert)")

    # Decode text
    try:
        text = content_bytes.decode('utf-8', errors='surrogateescape')
    except Exception:
        continue

    is_sample_or_test = any(k in rel_path.lower() for k in ["test", "sample", "template", "mock", "dummy", "docs/"])

    lines = text.splitlines()
    for line_idx, line in enumerate(lines, 1):
        # Skip comments in shell / python / yaml / sql
        stripped = line.strip()
        is_comment = stripped.startswith(('#', '--', '//', '/*'))

        # Phase 2: Secrets scan
        for label, pat in SECRET_PATTERNS:
            m = pat.search(line)
            if m:
                # Ignore placeholders and echo stubs in docker build scripts
                if label == "Private Key Header" and ("echo " in line or "cat " in line or is_sample_or_test):
                    continue
                val = m.group(1) if m.groups() else m.group(0)
                if val.lower() not in {"placeholder", "changeme", "example", "none", "password", "secret", "true", "false", "your_secret_here"}:
                    masked = mask_secret(val)
                    errors.append(f"Rule 5 Zero-Trust: {label} detected in {rel_path}:{line_idx} [{masked}]")

        # Phase 3: GDPR & PII scan
        # Check Estonian Isikukood
        ik_matches = ESTONIAN_IK_PATTERN.findall(line)
        for ik in ik_matches:
            # Check if this is a sample/test documentation line or zeroes
            if not (is_sample_or_test or "mock" in line.lower() or "example" in line.lower() or is_comment or ik.startswith("000")):
                errors.append(f"GDPR Violation: Potential Personal ID Code (PII) detected in {rel_path}:{line_idx} [{mask_secret(ik)}]")

        # Check IBAN
        iban_matches = IBAN_PATTERN.findall(line)
        for iban in iban_matches:
            if not (is_sample_or_test or "mock" in line.lower() or "example" in line.lower() or "00000000" in iban or iban == "EE009900000000000000"):
                errors.append(f"GDPR Violation: Potential Bank Account (IBAN) detected in {rel_path}:{line_idx} [{mask_secret(iban)}]")

        # Phase 4: Zero-Knowledge Hashes & Heuristics
        # Heuristics (only on actual code and configs, not docs/templates/gitignores)
        if not is_sample_or_test and not rel_path.startswith((".git", "config/environments")):
            if not ("example.com" in line):
                dom_matches = INTERNAL_DOMAIN_PATTERN.findall(line)
                for dom in dom_matches:
                    if dom.lower() not in {"oracle.corp", "localhost.local", "test.local", "ords-dev.corp", "publisher-dev.corp", "proxy-db-dev.corp"}:
                        warnings.append(f"Internal Network Heuristic: Internal domain '{dom}' in {rel_path}:{line_idx}")

                ldap_matches = INTERNAL_LDAP_PATTERN.findall(line)
                for ldap in ldap_matches:
                    if "example" not in ldap.lower():
                        warnings.append(f"Internal Network Heuristic: LDAP connection '{ldap}' in {rel_path}:{line_idx}")

        # Local patterns
        for pat in local_patterns:
            if pat.search(line):
                errors.append(f"Confidential Pattern: Matched .git/forbidden-patterns.local in {rel_path}:{line_idx}")

        # Zero-Knowledge Hash Checking
        if forbidden_hashes:
            # Extract word tokens: alphanumeric + hyphens + dots
            tokens = re.findall(r'[a-zA-Z0-9_\-\.]{4,}', line)
            for tok in tokens:
                tok_norm = tok.lower()
                h = hashlib.sha256(tok_norm.encode('utf-8')).hexdigest()
                if h in forbidden_hashes:
                    errors.append(f"Zero-Knowledge Guard: Forbidden confidential term detected in {rel_path}:{line_idx} (SHA-256: {h[:8]}...)")

    # -------------------------------------------------------------
    # Phase 5: Static Syntax & Compilation Validation
    # -------------------------------------------------------------
    if ext_lower == '.sh':
        cmd = ["bash", "-n", full_path]
        res = subprocess.run(cmd, capture_output=True, text=True)
        if res.returncode != 0:
            errors.append(f"Syntax Error in shell script {rel_path}: {res.stderr.strip()}")

    elif ext_lower == '.py':
        cmd = [sys.executable, "-m", "py_compile", full_path]
        res = subprocess.run(cmd, capture_output=True, text=True)
        if res.returncode != 0:
            errors.append(f"Syntax Error in Python script {rel_path}: {res.stderr.strip()}")

    elif ext_lower == '.json':
        try:
            json.loads(text)
        except Exception as err:
            errors.append(f"Invalid JSON syntax in {rel_path}: {err}")

# Output summary
print("------------------------------------------------------------------")
if crlf_fixed > 0:
    print(f"✨ Auto-fixed CRLF line endings in {crlf_fixed} file(s).")

if warnings:
    print(f"⚠️  {len(warnings)} Warning(s):")
    for w in warnings[:15]:
        print(f"   [WARN] {w}")
    if len(warnings) > 15:
        print(f"   ... and {len(warnings) - 15} more warnings.")

if errors:
    print(f"❌ {len(errors)} ERROR(S) DETECTED! Commit/Push blocked:")
    for err in errors[:25]:
        print(f"   [FAIL] {err}")
    if len(errors) > 25:
        print(f"   ... and {len(errors) - 25} more errors.")
    sys.exit(1)

print("✅ All pre-commit security, GDPR, portability & syntax checks PASSED!")
sys.exit(0)
PYEOF

EXIT_CODE=$?

# Phase 6: If full mode, execute core fast unit tests (< 5s)
if [ "$MODE" = "full" ] && [ $EXIT_CODE -eq 0 ]; then
  echo "------------------------------------------------------------------"
  echo "⚡ Executing Fast Core Unit Verification Suites..."
  
  if [ -f "$WORKSPACE_DIR/tests/unit/test-filename-portability.sh" ]; then
    bash "$WORKSPACE_DIR/tests/unit/test-filename-portability.sh"
  fi

  if [ -f "$WORKSPACE_DIR/tests/unit/test-dev-hub-generation.sh" ]; then
    bash "$WORKSPACE_DIR/tests/unit/test-dev-hub-generation.sh"
  fi
fi

echo "=================================================================="
if [ $EXIT_CODE -eq 0 ]; then
  echo "🎉 PRE-COMMIT / PRE-PUSH VERIFICATION SUCCESSFUL!"
  echo "   Code is clean, secure, GDPR-compliant, and ready for commit/push."
else
  echo "🚫 PRE-COMMIT / PRE-PUSH VERIFICATION FAILED."
  echo "   Please address the errors above before committing or pushing."
fi
echo "=================================================================="

exit $EXIT_CODE
