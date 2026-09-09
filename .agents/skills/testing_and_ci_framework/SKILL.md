---
name: testing_and_ci_framework
description: >-
  Comprehensive guide and operational runbook for the Oracle DevOps Platform testing suite (155+ test scripts),
  Local GitHub Actions CI simulator (test-local-ci.sh), 6-language i18n audit (test-multilingual-support.sh),
  cross-platform portability tests, lifecycle regression, and Dev Hub test execution history.
  ACTIVATE THIS SKILL whenever creating new tests, debugging CI failures, verifying language symmetry, or running regression suites.
---

# 🧪 Oracle DevOps Platform — Testing & CI Framework Runbook

This skill provides complete guidelines for authoring, running, and maintaining the platform's **155+ automated tests**, local CI/CD pipelines, and historical quality benchmarks.

---

## 1. 🎯 When to Use & Negative Routing

### Positive Triggers (Activate Immediately):
- Running local offline CI/CD simulation: `./tests/test-local-ci.sh`
- Verifying cross-platform filename portability: `./tests/unit/test-filename-portability.sh`
- Auditing 6-language i18n symmetry (Rule 9): `./tests/test-multilingual-support.sh --all`
- Writing new unit tests or adding test coverage in `tests/unit/`
- Reviewing test execution history and regression benchmarks in Dev Hub

### Negative Routing (Redirect to Specialized Skills):
| If the task is primarily about... | DO NOT handle here. Route immediately to: |
|:---|:---|
| Overall repository orientation or finding source code | `repo_codebase_navigator` |
| Fixing database setup scripts or orchestration lifecycle | `setup_orchestration` |
| Restoring clean baseline from golden snapshot before test run | `golden_snapshots_dr` |
| Tuning Oracle DB container limits or SGA/PGA | `oracle_containers` |
| Updating test history display or cards in Dev Hub | `devhub_architecture` |

---

## 2. 🏗️ Testing Architecture Overview

The testing framework is built on a 4-tier hierarchy:

```
tests/
├── unit/                       # 🔬 Tier 1: Fast Isolation Tests (<1s each)
│   ├── test-filename-portability.sh   # Enforces Windows/NTFS/FAT ASCII rule (Rule 13)
│   ├── test-enterprise-onboarding.sh  # Validates corporate proxy & Artifactory parser
│   ├── test-devhub-search-and-filters.sh # Verifies Dev Hub search & filter logic
│   └── test-windows-enterprise-rules.sh  # WSL2 ext4 & port conflict guardrails
│
├── reports/                    # 📄 Generated Markdown Test Summaries
│   ├── blueprints_live_test_report.md
│   └── devhub_lifecycle_full_report.md
│
├── test-local-ci.sh            # 🚀 Tier 2: Local GitHub Actions Runner & CI Simulator
├── test-multilingual-support.sh# 🌐 Tier 3: 6-Language Nordic-Baltic i18n Audit (Rule 9)
├── test-devhub-browser-blueprints.sh # 🖥️ Tier 4: Browser Headless Blueprint Live Testing
└── test-devhub-lifecycle-full.sh     # 🔄 Full Lifecycle (Start, Snapshot, Reset, Rebuild)
```

---

## 2. ⚡ Core Test Suites & Execution Commands

| Test Suite | Purpose | Command to Execute | Expected Outcome |
|:---|:---|:---|:---|
| **Portability Audit (Rule 13)** | Verifies all 1890+ repository paths for Windows NTFS/FAT compliance | `./tests/unit/test-filename-portability.sh` | 100% PASS (0 invalid chars) |
| **Multi-Language Audit (Rule 9)** | Verifies 100% dictionary symmetry across EN, ET, FI, SV, LV, LT | `./tests/test-multilingual-support.sh --all` | 100% PASS (12 / 12 tests) |
| **Local CI/CD Simulator** | Simulates GitHub Actions `.github/workflows/deploy-apex.yml` locally | `./scripts/test-local-ci.sh` | Ephemeral container passes |
| **APEX Test Suite** | Provisions developer accounts and tests APEX REST endpoints | `./scripts/test-apex-suite.sh` | HTTP 200 on all endpoints |
| **SEPS Wallet Verification** | Tests passwordless DB auto-login across all PDBs | `./scripts/check-wallet.sh` | All aliases CONNECTED |
| **Web Service Health Check** | Verifies HTTP/HTTPS responses for APEX, ORDS, Forms, Publisher | `./scripts/check-urls.sh` | All active services 🟢 ONLINE |
| **Full Lifecycle Matrix** | Stresses start, snapshot capture, reset-deep, and recovery | `./tests/test-devhub-lifecycle-full.sh` | Total recovery in ~15s |

---

## 3. 📜 Rule 1: Automatic Test Duration & History Tracking

Whenever automated tests run, their results must be logged for regression tracking:

1. **Persistent History:**
   - Results are automatically appended to [`metrics/test_execution_history.json`](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/metrics/test_execution_history.json):
     ```json
     {
       "timestamp": "2026-09-08T22:30:00",
       "suite": "i18n",
       "script": "tests/test-multilingual-support.sh",
       "status": "PASS",
       "exit_code": 0,
       "duration_seconds": 4,
       "log_file": "install_logs/test_i18n_20260908_223000.log"
     }
     ```
2. **Local Logs (`install_logs/`):**
   - Full execution output is teed into a timestamped file under `install_logs/`.
   - Never commit `install_logs/` to Git.

---

## 4. ✍️ How to Author a New Unit Test

Follow this template when creating new tests under `tests/unit/test-<feature>.sh`:

```bash
#!/usr/bin/env bash
# ============================================================================
# Unit Test: test-<feature>.sh
# Purpose: Validates <feature description>
# Contract: Exits 0 on success, exits 1 on failure. Zero hardcoded passwords.
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [ -f "$WORKSPACE_DIR/scripts/internal/common.sh" ]; then
  source "$WORKSPACE_DIR/scripts/internal/common.sh"
fi

echo "🔍 Running <feature> verification..."

# Assertion helper
assert_equals() {
  local expected="$1"
  local actual="$2"
  local msg="$3"
  if [ "$expected" != "$actual" ]; then
    echo "❌ Assertion failed: $msg (Expected: $expected, got: $actual)" >&2
    exit 1
  fi
}

# Test step execution
# ... your test logic here ...

echo "✅ PASSED: <feature> passed all assertions."
exit 0
```

---

## 5. 🌐 Rule 9: Multilingual Audit Requirements

When adding user-facing scripts or tests:
1. Every message key printed via `msg_print "KEY"` or `msg_str "KEY"` must have corresponding definitions in `scripts/internal/i18n.sh` for all 6 languages (`en_*`, `et_*`, `fi_*`, `sv_*`, `lv_*`, `lt_*`).
2. Script comments must remain in technical English (Rule 9.3).
3. Validate by running:
   ```bash
   ./tests/test-multilingual-support.sh --all
   ```

---

## 6. 🚫 Testing Anti-Patterns (What NOT to Do)

- **Do NOT bypass SEPS Wallet:** Automated tests must never extract passwords from disk or use plaintext fallbacks. Always use `./scripts/get-password.sh <alias>`.
- **Do NOT leave background containers running:** Use ephemeral containers with `--rm` for one-off CLI or Liquibase tests (Rule 4).
- **Do NOT write Windows-reserved filenames:** Test filenames must strictly follow `[a-z0-9._-]` without spaces or colon symbols (`:`).
- **Do NOT use non-portable bashisms:** Tests must run under macOS bash 3.2, Linux bash 5.x, and zsh without syntax errors. Use `tr '[:upper:]' '[:lower:]'` instead of `${VAR,,}`.

---

## 7. 🩺 Diagnostic Signatures & 1-Line Remedies

| Symptom / Error | Root Cause | 1-Line Remedy |
|:---|:---|:---|
| Portability test fails on path | File/dir contains space, uppercase extension, or NTFS reserved char | Rename path to kebab-case ASCII: `mv "bad path" "bad-path"`. |
| `test-multilingual-support.sh` fails on key | Missing translation key in one of EN/ET/FI/SV/LV/LT | Add missing key across all 6 language blocks in `scripts/internal/i18n.sh` or `dev_hub/assets/i18n.js`. |
| `test-local-ci.sh` fails on Liquibase | Malformed YAML/XML changelog or missing rollback block | Validate changelog syntax against SQLcl Liquibase parser or check `install_logs/`. |
| Test hangs during container probe | Waiting on unresponsive container healthcheck | Check `podman ps` and inspect container logs: `podman logs <c_name> --tail 20`. |
| Bash syntax error: `${VAR,,}: bad substitution` | Non-portable bashism running under macOS `/bin/bash` 3.2 | Replace `${VAR,,}` with portable `echo "$VAR" \| tr '[:upper:]' '[:lower:]'`. |

