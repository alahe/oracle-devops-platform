#!/usr/bin/env bash
# ============================================================================
# Golden Snapshot Puhastamise Utiliit
# Kustutab golden-snapshots/ kaustast vanad hetktõmmised vastavalt kasutaja valikule.
# Vaikimisi jäetakse alati alles "*latest.tar.gz" hetktõmmised.
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)/golden-snapshots"

if [ ! -d "$BACKUP_DIR" ]; then
  echo "📂 Hetktõmmiste kausta ei eksisteeri ($BACKUP_DIR) — midagi pole puhastada."
  exit 0
fi

# Loeme olemasolevate hetktõmmiste arvu ja mahu
TOTAL_FILES=$(find "$BACKUP_DIR" -type f ! -name "*latest.tar.gz" ! -name ".gitignore" ! -name ".gitkeep" 2>/dev/null | wc -l | tr -d ' ')
if [ "$TOTAL_FILES" -eq 0 ]; then
  echo "ℹ️  Hetktõmmiste kaustas ei ole vanu hetktõmmiseid, mida kustutada (alles on vaid latest.tar.gz või kaust on tühi)."
  exit 0
fi

TOTAL_SIZE=$(du -sh "$BACKUP_DIR" | awk '{print $1}')
echo "=================================================================="
echo "🧹 HETKTÕMMISTE (GOLDEN SNAPSHOTS) PUHASTAMISE UTILIIT"
echo "   Asukoht:     $BACKUP_DIR"
echo "   Kokku faile (kustutatavaid): $TOTAL_FILES"
echo "   Kataloogi kogumaht:         $TOTAL_SIZE"
echo "=================================================================="

# Küsime kasutajalt päevade arvu
read -p "❓ Sisesta päevade arv, millest vanemad hetktõmmised kustutada (0 = säilita ainult viimane koopia, vaikimisi 0): " DAYS

# Vaikimisi väärtus on 0
if [ -z "$DAYS" ]; then
  DAYS=0
fi

# Valideerime sisendit
if [[ ! "$DAYS" =~ ^[0-9]+$ ]]; then
  echo "❌ Viga: Sisend peab olema arv (0 või suurem)!"
  exit 1
fi

echo "------------------------------------------------------------------"

if [ "$DAYS" -eq 0 ]; then
  echo "🗑  Kustutan kõik vanad hetktõmmised (jättes alles viimase 'latest' koopia)..."
  find "$BACKUP_DIR" -type f ! -name "*latest.tar.gz" ! -name ".gitignore" ! -name ".gitkeep" -delete
  echo "✅ Vanad hetktõmmised edukalt kustutatud!"
else
  # Kustutame failid, mis on vanemad kui DAYS päeva
  MTIME_VAL=$((DAYS - 1))
  
  TO_DELETE=$(find "$BACKUP_DIR" -type f ! -name "*latest.tar.gz" ! -name ".gitignore" ! -name ".gitkeep" -mtime +$MTIME_VAL 2>/dev/null | wc -l | tr -d ' ')
  
  if [ "$TO_DELETE" -eq 0 ]; then
    echo "ℹ️  Ei leitud ühtegi hetktõmmise faili, mis oleks vanem kui $DAYS päev(a)."
  else
    find "$BACKUP_DIR" -type f ! -name "*latest.tar.gz" ! -name ".gitignore" ! -name ".gitkeep" -mtime +$MTIME_VAL -delete
    echo "✅ Edukalt kustutatud $TO_DELETE hetktõmmise faili!"
  fi
fi

echo "=================================================================="
