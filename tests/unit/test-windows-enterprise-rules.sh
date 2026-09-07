#!/usr/bin/env bash
# ==============================================================================
# Unit Test: test-windows-enterprise-rules.sh
# Validates Rule 14 (Enterprise Windows & WSL2 Compatibility Rule) and AI Skill:
# 1. .gitattributes LF/CRLF line ending rules
# 2. Windows launchers (setup.cmd, setup.ps1, configure-wsl-enterprise.ps1)
# 3. WSL2 9P performance penalty and Hyper-V port pre-flight checks
# 4. Mandatory Rule 14 in .agents/AGENTS.md and windows_enterprise_devops skill
# 5. Multi-language documentation (Rule 9) in all 6 languages
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🔍 Validating Rule 14: Enterprise Windows & WSL2 Compatibility..."

ERRORS=0

# 1. Check .gitattributes existence and rules
echo "  [1/5] Checking .gitattributes line-ending invariants..."
GITATTRIBUTES="$WORKSPACE_DIR/.gitattributes"
if [ ! -f "$GITATTRIBUTES" ]; then
  echo "❌ Error: .gitattributes is missing in workspace root!"
  ERRORS=$((ERRORS + 1))
else
  for pattern in "eol=lf" "eol=crlf" "*.sh" "*.cmd" "*.ps1"; do
    if ! grep -q "$pattern" "$GITATTRIBUTES"; then
      echo "❌ Error: .gitattributes missing required rule: $pattern"
      ERRORS=$((ERRORS + 1))
    fi
  done
fi

# 2. Check Windows launchers & scripts
echo "  [2/5] Checking Windows native launchers..."
LAUNCHERS=(
  "setup.cmd"
  "setup.ps1"
  "scripts/wsl/configure-wsl-enterprise.ps1"
  "scripts/certs/trust-local-cert.cmd"
  "scripts/certs/trust-local-cert.ps1"
)

for file in "${LAUNCHERS[@]}"; do
  full_path="$WORKSPACE_DIR/$file"
  if [ ! -f "$full_path" ]; then
    echo "❌ Error: Required Windows launcher missing: $file"
    ERRORS=$((ERRORS + 1))
  else
    # Verify zero admin elevation / runas requirements
    if grep -iE "runas /user:administrator|Start-Process.*-Verb RunAs" "$full_path" 2>/dev/null; then
      echo "❌ Error: Elevated admin requirement detected in $file (Violates Zero-Admin Rule 14)"
      ERRORS=$((ERRORS + 1))
    fi
  fi
done

# Verify setup.cmd contains 9P mount detection
if [ -f "$WORKSPACE_DIR/setup.cmd" ]; then
  if ! grep -q "/mnt/" "$WORKSPACE_DIR/setup.cmd"; then
    echo "❌ Error: setup.cmd does not check for /mnt/ 9P mount path!"
    ERRORS=$((ERRORS + 1))
  fi
fi

# 3. Check pre-flight checks in check-prerequisites.sh
echo "  [3/5] Checking check-prerequisites.sh for WSL2 enterprise validations..."
PREREQ_SCRIPT="$WORKSPACE_DIR/scripts/internal/check-prerequisites.sh"
if [ ! -f "$PREREQ_SCRIPT" ]; then
  echo "❌ Error: check-prerequisites.sh missing!"
  ERRORS=$((ERRORS + 1))
else
  if ! grep -q "Plan9 (9P)" "$PREREQ_SCRIPT"; then
    echo "❌ Error: check-prerequisites.sh missing WSL2 /mnt/ 9P check!"
    ERRORS=$((ERRORS + 1))
  fi
  if ! grep -q "excludedportrange" "$PREREQ_SCRIPT"; then
    echo "❌ Error: check-prerequisites.sh missing Hyper-V excluded port check!"
    ERRORS=$((ERRORS + 1))
  fi
  if ! grep -q "Podman VM memory is low" "$PREREQ_SCRIPT"; then
    echo "❌ Error: check-prerequisites.sh missing Podman machine RAM check!"
    ERRORS=$((ERRORS + 1))
  fi
fi

# 4. Check AI Governance (AGENTS.md Rule 14 & AI Skill)
echo "  [4/5] Checking AI Governance & Rule 14 enforcement..."
AGENTS_MD="$WORKSPACE_DIR/.agents/AGENTS.md"
SKILL_MD="$WORKSPACE_DIR/.agents/skills/windows_enterprise_devops/SKILL.md"

if [ ! -f "$AGENTS_MD" ]; then
  echo "❌ Error: .agents/AGENTS.md missing!"
  ERRORS=$((ERRORS + 1))
else
  if ! grep -q "14. Enterprise Windows & WSL2 Compatibility Rule" "$AGENTS_MD"; then
    echo "❌ Error: Rule 14 missing in .agents/AGENTS.md!"
    ERRORS=$((ERRORS + 1))
  fi
fi

if [ ! -f "$SKILL_MD" ]; then
  echo "❌ Error: windows_enterprise_devops/SKILL.md missing!"
  ERRORS=$((ERRORS + 1))
else
  for keyword in "windows_enterprise_devops" "Contract 1" "Contract 8" "Zero-Admin" "Hyper-V"; do
    if ! grep -q "$keyword" "$SKILL_MD"; then
      echo "❌ Error: windows_enterprise_devops/SKILL.md missing keyword: $keyword"
      ERRORS=$((ERRORS + 1))
    fi
  done
fi

# 5. Check 6-Language Documentation (Rule 9)
echo "  [5/5] Checking 6-language Windows enterprise setup guides..."
DOC_GUIDES=(
  "docs/windows-enterprise-setup-guide.md"
  "docs/et/windows-enterprise-setup-guide.md"
  "docs/fi/windows-enterprise-setup-guide.md"
  "docs/sv/windows-enterprise-setup-guide.md"
  "docs/lv/windows-enterprise-setup-guide.md"
  "docs/lt/windows-enterprise-setup-guide.md"
)

for doc in "${DOC_GUIDES[@]}"; do
  full_path="$WORKSPACE_DIR/$doc"
  if [ ! -f "$full_path" ]; then
    echo "❌ Error: Localized Windows setup guide missing: $doc"
    ERRORS=$((ERRORS + 1))
  else
    # Verify language switcher
    if ! grep -q "English" "$full_path" || ! grep -q "Eesti" "$full_path" || ! grep -q "Suomi" "$full_path"; then
      echo "❌ Error: Language switcher missing or incomplete in $doc"
      ERRORS=$((ERRORS + 1))
    fi
  fi
done

if [ "$ERRORS" -gt 0 ]; then
  echo "❌ Rule 14 validation failed with $ERRORS error(s)!"
  exit 1
fi

echo "✅ Rule 14: Enterprise Windows & WSL2 Compatibility validation passed successfully!"
exit 0
