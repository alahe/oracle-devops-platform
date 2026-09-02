#!/usr/bin/env bash
# ============================================================================
# Golden Snapshot Clean & Purge Utility
# Purges obsolete Golden Snapshots according to retention rules.
# Preserves "*latest.tar.gz" Golden Snapshots by default.
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)/golden-snapshots"

if [ ! -d "$BACKUP_DIR" ]; then
  echo "📂 Snapshots directory does not exist ($BACKUP_DIR) — nothing to clean."
  exit 0
fi

# Count existing snapshots and directory size
TOTAL_FILES=$(find "$BACKUP_DIR" -type f ! -name "*latest.tar.gz" ! -name ".gitignore" ! -name ".gitkeep" 2>/dev/null | wc -l | tr -d ' ')
if [ "$TOTAL_FILES" -eq 0 ]; then
  echo "ℹ️  No old snapshots found to delete in snapshots directory (only latest.tar.gz preserved or directory empty)."
  exit 0
fi

TOTAL_SIZE=$(du -sh "$BACKUP_DIR" | awk '{print $1}')
echo "=================================================================="
echo "🧹 GOLDEN SNAPSHOT CLEAN & PURGE UTILITY"
echo "   Directory:                  $BACKUP_DIR"
echo "   Total eligible files:       $TOTAL_FILES"
echo "   Total snapshot space used:  $TOTAL_SIZE"
echo "=================================================================="

# Argument parsing (-y, --yes, --days=N)
AUTO_YES=false
DAYS=0

for arg in "$@"; do
  case $arg in
    -y|--yes|-f|--force)
      AUTO_YES=true
      ;;
    --days=*)
      DAYS="${arg#*=}"
      ;;
    [0-9]*)
      DAYS="$arg"
      ;;
  esac
done

if [ "$AUTO_YES" = "false" ] && [ -t 0 ]; then
  read -p "❓ Enter retention days to purge snapshots older than N days (0 = keep only latest snapshot, default 0): " USER_DAYS
  [ -n "$USER_DAYS" ] && DAYS="$USER_DAYS"
fi

# Validate input
if [[ ! "$DAYS" =~ ^[0-9]+$ ]]; then
  echo "❌ Error: Input must be a positive integer (0 or greater)!"
  exit 1
fi

echo "------------------------------------------------------------------"

if [ "$DAYS" -eq 0 ]; then
  echo "🗑  Purging all older Golden Snapshots (preserving latest snapshot)..."
  find "$BACKUP_DIR" -type f ! -name "*latest.tar.gz" ! -name ".gitignore" ! -name ".gitkeep" -delete
  echo "✅ Obsolete snapshots purged successfully!"
else
  # Delete snapshot files older than specified retention days
  MTIME_VAL=$((DAYS - 1))
  
  TO_DELETE=$(find "$BACKUP_DIR" -type f ! -name "*latest.tar.gz" ! -name ".gitignore" ! -name ".gitkeep" -mtime +$MTIME_VAL 2>/dev/null | wc -l | tr -d ' ')
  
  if [ "$TO_DELETE" -eq 0 ]; then
    echo "ℹ️  No snapshot files found older than $DAYS day(s)."
  else
    find "$BACKUP_DIR" -type f ! -name "*latest.tar.gz" ! -name ".gitignore" ! -name ".gitkeep" -mtime +$MTIME_VAL -delete
    echo "✅ Successfully purged $TO_DELETE snapshot file(s)!"
  fi
fi

echo "=================================================================="
