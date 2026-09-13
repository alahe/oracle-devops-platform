#!/usr/bin/env bash
# ==============================================================================
# Automated Semantic Release Engine (Rule 16 — Conventional Commits & Git Tags)
#
# Analyzes commit history since the last Git release tag, computes the target
# SemVer bump (MAJOR, MINOR, PATCH), updates CHANGELOG.md and VERSION,
# recompiles Dev Hub HTML, creates an annotated Git tag, and supports push.
#
# Usage:
#   ./scripts/release.sh                     # Interactive release
#   ./scripts/release.sh --dry-run           # Preview analysis and changelog
#   ./scripts/release.sh --auto              # Non-interactive (for pre-push hook)
#   ./scripts/release.sh --type minor        # Force minor bump
#   ./scripts/release.sh --version 2.5.0     # Explicit version
#   ./scripts/release.sh --push              # Push commit and tags to origin
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VERSION_FILE="$WORKSPACE_DIR/VERSION"
CHANGELOG_FILE="$WORKSPACE_DIR/CHANGELOG.md"

# ANSI Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

DRY_RUN=false
AUTO_MODE=false
DO_PUSH=false
FORCE_TYPE=""
EXPLICIT_VER=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --auto)
      AUTO_MODE=true
      shift
      ;;
    --push)
      DO_PUSH=true
      shift
      ;;
    --type|-t)
      FORCE_TYPE="${2:-}"
      shift 2 || true
      ;;
    --version|-v)
      EXPLICIT_VER="${2:-}"
      shift 2 || true
      ;;
    *)
      if [[ -z "$EXPLICIT_VER" && "$1" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)? ]]; then
        EXPLICIT_VER="$1"
        shift
      else
        echo "Tundmatu parameeter: $1"
        exit 1
      fi
      ;;
  esac
done

# 1. Read Current Version & Strip Iteration
CURRENT_VER="2.4.2"
if [[ -f "$VERSION_FILE" ]]; then
  CURRENT_VER="$(tr -d '[:space:]' < "$VERSION_FILE")"
fi

IFS='.' read -r -a CURRENT_PARTS <<< "$CURRENT_VER"
CUR_MAJOR="${CURRENT_PARTS[0]:-2}"
CUR_MINOR="${CURRENT_PARTS[1]:-4}"
CUR_PATCH="${CURRENT_PARTS[2]:-2}"
BASE_SEMVER="${CUR_MAJOR}.${CUR_MINOR}.${CUR_PATCH}"

# 2. Find Latest Git Release Tag
LATEST_TAG=""
if git -C "$WORKSPACE_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  LATEST_TAG="$(git -C "$WORKSPACE_DIR" tag -l "v[0-9]*" --sort=-v:refname | head -n 1 || true)"
fi

# 3. Collect Commits Since Latest Tag
COMMIT_RANGE=""
if [[ -n "$LATEST_TAG" ]]; then
  COMMIT_RANGE="${LATEST_TAG}..HEAD"
else
  # If no tags exist yet, inspect up to last 30 commits
  COMMIT_RANGE="HEAD~30..HEAD"
  if ! git -C "$WORKSPACE_DIR" rev-parse --verify "HEAD~30" >/dev/null 2>&1; then
    COMMIT_RANGE="HEAD"
  fi
fi

COMMITS_LOG=""
if [[ "$COMMIT_RANGE" = "HEAD" ]]; then
  COMMITS_LOG="$(git -C "$WORKSPACE_DIR" log --oneline || true)"
else
  COMMITS_LOG="$(git -C "$WORKSPACE_DIR" log "$COMMIT_RANGE" --oneline 2>/dev/null || git -C "$WORKSPACE_DIR" log -n 15 --oneline || true)"
fi

# 4. Analyze Commit Messages for Semantic Versioning
HAS_BREAKING=false
HAS_FEAT=false
HAS_FIX=false

FEATURES=()
FIXES=()
OTHERS=()

while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  # Extract commit subject without hash
  SUBJECT="$(echo "$line" | sed -E 's/^[a-f0-9]+ //')"

  if echo "$SUBJECT" | grep -Eq "(BREAKING CHANGE|BREAKING-CHANGE|^[a-z]+(\([^\)]+\))?!:)"; then
    HAS_BREAKING=true
    FEATURES+=("$SUBJECT")
  elif echo "$SUBJECT" | grep -Eq "^feat(\([^\)]+\))?:"; then
    HAS_FEAT=true
    FEATURES+=("$SUBJECT")
  elif echo "$SUBJECT" | grep -Eq "^(fix|perf)(\([^\)]+\))?:"; then
    HAS_FIX=true
    FIXES+=("$SUBJECT")
  else
    OTHERS+=("$SUBJECT")
  fi
done <<< "$COMMITS_LOG"

# 5. Determine Bump Type
CALCULATED_TYPE="patch"
if [[ "$HAS_BREAKING" = "true" ]]; then
  CALCULATED_TYPE="major"
elif [[ "$HAS_FEAT" = "true" ]]; then
  CALCULATED_TYPE="minor"
elif [[ "$HAS_FIX" = "true" ]]; then
  CALCULATED_TYPE="patch"
fi

BUMP_TYPE="${FORCE_TYPE:-$CALCULATED_TYPE}"

# 6. Calculate New SemVer
NEW_MAJOR="$CUR_MAJOR"
NEW_MINOR="$CUR_MINOR"
NEW_PATCH="$CUR_PATCH"

if [[ -n "$EXPLICIT_VER" ]]; then
  TARGET_SEMVER="${EXPLICIT_VER#v}"
else
  case "$BUMP_TYPE" in
    major)
      NEW_MAJOR=$((CUR_MAJOR + 1))
      NEW_MINOR=0
      NEW_PATCH=0
      ;;
    minor)
      NEW_MINOR=$((CUR_MINOR + 1))
      NEW_PATCH=0
      ;;
    patch|*)
      NEW_PATCH=$((CUR_PATCH + 1))
      ;;
  esac
  TARGET_SEMVER="${NEW_MAJOR}.${NEW_MINOR}.${NEW_PATCH}"
fi

RELEASE_TAG="v${TARGET_SEMVER}"
RELEASE_DATE="$(date +"%Y-%m-%d")"

# 7. Format Changelog Section
CHANGELOG_ENTRY="## [${RELEASE_TAG}] - ${RELEASE_DATE}"
if [[ ${#FEATURES[@]} -gt 0 ]]; then
  CHANGELOG_ENTRY+=$'\n\n### 🚀 Uued funktsioonid & Täiendused (Features)\n'
  for item in "${FEATURES[@]}"; do
    CHANGELOG_ENTRY+="- ${item}"$'\n'
  done
fi

if [[ ${#FIXES[@]} -gt 0 ]]; then
  CHANGELOG_ENTRY+=$'\n### 🐛 Parandused & Optimeerimised (Fixes)\n'
  for item in "${FIXES[@]}"; do
    CHANGELOG_ENTRY+="- ${item}"$'\n'
  done
fi

if [[ ${#OTHERS[@]} -gt 0 && ${#FEATURES[@]} -eq 0 && ${#FIXES[@]} -eq 0 ]]; then
  CHANGELOG_ENTRY+=$'\n### 🛠️ Hooldus & Dokumentatsioon (Maintenance)\n'
  for item in "${OTHERS[@]}"; do
    CHANGELOG_ENTRY+="- ${item}"$'\n'
  done
fi

BUMP_UPPER="$(echo "$BUMP_TYPE" | tr '[:lower:]' '[:upper:]')"
CALCULATED_UPPER="$(echo "$CALCULATED_TYPE" | tr '[:lower:]' '[:upper:]')"

# Dry Run Output
if [[ "$DRY_RUN" = "true" ]]; then
  echo -e "=================================================================="
  echo -e "🔍 ${BOLD}SEMANATILINE RELIISI ANALÜÜS (DRY-RUN)${NC}"
  echo -e "=================================================================="
  echo -e "   📌 Praegune põriversioon: ${YELLOW}v${BASE_SEMVER}${NC} (failis: ${CURRENT_VER})"
  echo -e "   🏷️ Viimane Git Tag:       ${CYAN}${LATEST_TAG:-puudub}${NC}"
  echo -e "   ⚡ Tuvastatud muudatused: Breaking: ${HAS_BREAKING}, Feat: ${HAS_FEAT}, Fix: ${HAS_FIX}"
  echo -e "   📈 Tõusu tüüp:            ${BOLD}${BUMP_UPPER}${NC}"
  echo -e "   🎯 Sihtversioon:          ${GREEN}${BOLD}${RELEASE_TAG}${NC}"
  echo -e ""
  echo -e "📋 ${BOLD}Kavandatav CHANGELOG.md kirje:${NC}"
  echo -e "$CHANGELOG_ENTRY"
  echo -e "=================================================================="
  exit 0
fi

# Interactive confirmation if not in auto mode
if [[ "$AUTO_MODE" = "false" ]]; then
  echo -e "=================================================================="
  echo -e "🚀 ${BOLD}ORACLE DEVOPS PLATFORM — AMETLIK RELIIS${NC}"
  echo -e "=================================================================="
  echo -e "   📌 Praegune versioon: ${YELLOW}v${BASE_SEMVER}${NC} (iteratsioon: ${CURRENT_VER})"
  echo -e "   📈 Tõusu tüüp:        ${BOLD}${BUMP_UPPER}${NC} (${CALCULATED_UPPER})"
  echo -e "   🎯 Uus reliis:        ${GREEN}${BOLD}${RELEASE_TAG}${NC}"
  echo -e "=================================================================="
  read -r -p "Kas soovid jätkata reliisiga ${RELEASE_TAG}? (y/N) " CONFIRM
  if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "❌ Reliis katkestatud kasutaja poolt."
    exit 0
  fi
fi

# 8. Apply Release Changes
echo -e "📝 1/5 Uuendan faili ${CYAN}VERSION${NC} -> ${GREEN}${TARGET_SEMVER}${NC}..."
echo "$TARGET_SEMVER" > "$VERSION_FILE"

# 9. Update CHANGELOG.md
echo -e "📜 2/5 Täiendan faili ${CYAN}CHANGELOG.md${NC}..."
if [[ -f "$CHANGELOG_FILE" ]]; then
  TMP_CHANGELOG=$(mktemp)
  echo -e "${CHANGELOG_ENTRY}\n" > "$TMP_CHANGELOG"
  cat "$CHANGELOG_FILE" >> "$TMP_CHANGELOG"
  mv "$TMP_CHANGELOG" "$CHANGELOG_FILE"
else
  cat <<EOF > "$CHANGELOG_FILE"
# Changelog — Oracle DevOps Platform

Kõik märkimisväärsed platvormi muudatused dokumenteeritakse selles failis vastavalt [Semantic Versioning](https://semver.org/) standardile.

${CHANGELOG_ENTRY}
EOF
fi

# 10. Recompile Dev Hub HTML
echo -e "⚡ 3/5 Kompileerin ${CYAN}docs/dev-hub.html${NC} uue versiooniga..."
python3 "$WORKSPACE_DIR/scripts/internal/dev_hub/compiler.py" >/dev/null 2>&1 || true

# 11. Git Commit & Annotated Tag
echo -e "🏷️ 4/5 Loon Git commiti ja tagi ${GREEN}${RELEASE_TAG}${NC}..."
git -C "$WORKSPACE_DIR" add "$VERSION_FILE" "$CHANGELOG_FILE" "docs/dev-hub.html"
git -C "$WORKSPACE_DIR" commit -m "chore(release): release ${RELEASE_TAG}" || true
git -C "$WORKSPACE_DIR" tag -a "$RELEASE_TAG" -m "release: ${RELEASE_TAG} [skip ci]"

# 12. Optional Push
if [[ "$DO_PUSH" = "true" ]]; then
  echo -e "🌐 5/5 Pushin muudatused ja tagi serverisse..."
  git -C "$WORKSPACE_DIR" push origin HEAD || true
  git -C "$WORKSPACE_DIR" push origin "$RELEASE_TAG" || true
else
  echo -e "ℹ️  5/5 Git push vahele jäetud (kasuta --push või pushi käsitsi: git push && git push origin ${RELEASE_TAG})."
fi

echo -e ""
echo -e "🎉 ${GREEN}${BOLD}RELIIS ${RELEASE_TAG} ON EDUKALT KINNITATUD!${NC}"
echo -e "   Käivita järgmise arenduse alustamiseks: ${CYAN}./scripts/bump-iteration.sh${NC}"
