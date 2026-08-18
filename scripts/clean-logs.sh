#!/usr/bin/env bash
# ============================================================================
# Log Cleanup Utility Script
# Kustutab install_logs/ kaustast vanad logifailid vastavalt kasutaja valikule.
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$(cd "$SCRIPT_DIR/.." && pwd)/install_logs"

if [ ! -d "$LOG_DIR" ]; then
  echo "📂 Logide kausta ei eksisteeri ($LOG_DIR) — midagi pole puhastada."
  exit 0
fi

# Loeme olemasolevate logifailide arvu ja mahu
TOTAL_FILES=$(find "$LOG_DIR" -type f ! -name ".gitignore" ! -name ".gitkeep" 2>/dev/null | wc -l | tr -d ' ')
if [ "$TOTAL_FILES" -eq 0 ]; then
  echo "ℹ️  Logide kaust on juba tühi."
  exit 0
fi

TOTAL_SIZE=$(du -sh "$LOG_DIR" | awk '{print $1}')
echo "=================================================================="
echo "🧹 LOGIFAILIDE PUHASTAMISE UTILIIT"
echo "   Asukoht:     $LOG_DIR"
echo "   Kokku faile: $TOTAL_FILES"
echo "   Kogumaht:    $TOTAL_SIZE"
echo "=================================================================="

# Küsime kasutajalt päevade arvu
read -p "❓ Sisesta päevade arv, millest vanemad logid kustutada (0 = kustuta kõik, vaikimisi 1): " DAYS

# Vaikimisi väärtus on 1
if [ -z "$DAYS" ]; then
  DAYS=1
fi

# Valideerime sisendit (peab olema positiivne täisarv või 0)
if [[ ! "$DAYS" =~ ^[0-9]+$ ]]; then
  echo "❌ Viga: Sisend peab olema arv (0 või suurem)!"
  exit 1
fi

echo "------------------------------------------------------------------"

if [ "$DAYS" -eq 0 ]; then
  echo "🗑  Kustutan KÕIK logifailid..."
  find "$LOG_DIR" -type f ! -name ".gitignore" ! -name ".gitkeep" -delete
  echo "✅ Kõik logifailid edukalt kustutatud!"
else
  # Kustutame failid, mis on vanemad kui DAYS päeva (DAYS * 24 tundi)
  # find -mtime +0 leiab failid, mis on muudetud rohkem kui 24h tagasi (1 päev)
  MTIME_VAL=$((DAYS - 1))
  
  TO_DELETE=$(find "$LOG_DIR" -type f ! -name ".gitignore" ! -name ".gitkeep" -mtime +$MTIME_VAL 2>/dev/null | wc -l | tr -d ' ')
  
  if [ "$TO_DELETE" -eq 0 ]; then
    echo "ℹ️  Ei leitud ühtegi logifaili, mis oleks vanem kui $DAYS päev(a) (muudetud rohkem kui $((DAYS * 24)) tundi tagasi)."
  else
    find "$LOG_DIR" -type f ! -name ".gitignore" ! -name ".gitkeep" -mtime +$MTIME_VAL -delete
    echo "✅ Edukalt kustutatud $TO_DELETE logifail(i)!"
  fi
fi

echo "=================================================================="
