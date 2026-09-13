#!/usr/bin/env bash
# ==============================================================================
# Bump Iteration Version (Rule 16 — Vibe Coding & SDD Assembly Line)
#
# Increments the 4th build/iteration number (e.g. 2.5.0 -> 2.5.0.1 -> 2.5.0.2)
# in the root VERSION file and synchronizes docs/dev-hub.html.
#
# Usage:
#   ./scripts/bump-iteration.sh
#   ./scripts/bump-iteration.sh --commit "feat(devhub): add new feature"
#   ./scripts/bump-iteration.sh --dry-run
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VERSION_FILE="$WORKSPACE_DIR/VERSION"

# ANSI Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

COMMIT_MSG=""
DRY_RUN=false
NO_COMPILE=false
QUIET=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --commit|-m)
      COMMIT_MSG="${2:-}"
      shift 2 || true
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --no-compile)
      NO_COMPILE=true
      shift
      ;;
    --quiet|-q)
      QUIET=true
      shift
      ;;
    *)
      if [[ -z "$COMMIT_MSG" && "$1" != -* ]]; then
        COMMIT_MSG="$1"
        shift
      else
        echo "Tundmatu parameeter: $1"
        exit 1
      fi
      ;;
  esac
done

# 1. Read Current Version
CURRENT_VER="2.5.0.0"
if [[ -f "$VERSION_FILE" ]]; then
  CURRENT_VER="$(tr -d '[:space:]' < "$VERSION_FILE")"
fi

# 2. Parse & Increment 4th Component
# Formats supported: X.Y.Z or X.Y.Z.W
IFS='.' read -r -a PARTS <<< "$CURRENT_VER"
PART_COUNT="${#PARTS[@]}"

if [[ "$PART_COUNT" -eq 3 ]]; then
  MAJOR="${PARTS[0]}"
  MINOR="${PARTS[1]}"
  PATCH="${PARTS[2]}"
  BUILD="1"
  NEW_VER="${MAJOR}.${MINOR}.${PATCH}.${BUILD}"
elif [[ "$PART_COUNT" -ge 4 ]]; then
  MAJOR="${PARTS[0]}"
  MINOR="${PARTS[1]}"
  PATCH="${PARTS[2]}"
  OLD_BUILD="${PARTS[3]}"
  # Ensure numeric
  if [[ "$OLD_BUILD" =~ ^[0-9]+$ ]]; then
    BUILD=$((OLD_BUILD + 1))
  else
    BUILD=1
  fi
  NEW_VER="${MAJOR}.${MINOR}.${PATCH}.${BUILD}"
else
  NEW_VER="2.5.0.1"
fi

if [[ "$DRY_RUN" = "true" ]]; then
  echo -e "🔍 [Dry-Run] Praegune versioon: ${YELLOW}v${CURRENT_VER}${NC} ➔ Uus iteratsioon: ${GREEN}v${NEW_VER}${NC}"
  exit 0
fi

# 3. Write New Version
echo "$NEW_VER" > "$VERSION_FILE"

if [[ "$QUIET" = "false" ]]; then
  echo -e "🚀 ${BOLD}Iteratsiooni versioon tõstetud:${NC} ${YELLOW}v${CURRENT_VER}${NC} ➔ ${GREEN}${BOLD}v${NEW_VER}${NC}"
fi

# 4. Synchronize Dev Hub HTML
if [[ "$NO_COMPILE" = "false" && -f "$WORKSPACE_DIR/scripts/internal/dev_hub/compiler.py" ]]; then
  if [[ "$QUIET" = "false" ]]; then
    echo -e "   ⚡ Sünkroniseerin Dev Hub HTML faili (${CYAN}docs/dev-hub.html${NC})..."
  fi
  python3 "$WORKSPACE_DIR/scripts/internal/dev_hub/compiler.py" >/dev/null 2>&1 || true
fi

# 5. Optional Git Commit
if [[ -n "$COMMIT_MSG" ]]; then
  git -C "$WORKSPACE_DIR" add "$VERSION_FILE" "docs/dev-hub.html"
  git -C "$WORKSPACE_DIR" commit -m "$COMMIT_MSG (iter v${NEW_VER})"
  if [[ "$QUIET" = "false" ]]; then
    echo -e "   ✅ Git commit loodud: ${CYAN}${COMMIT_MSG}${NC}"
  fi
fi

if [[ "$QUIET" = "false" ]]; then
  echo -e "   ✨ ${GREEN}Valmis! Dev Hub on uuendatud iteratsioonile v${NEW_VER}.${NC}"
fi
