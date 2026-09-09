[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📸 Skript för hantering av ögonblicksbilder (golden snapshots) (`scripts/snapshots/`)

Denna katalog tillhandahåller skript för att skapa, återställa och hantera komprimerade kalla säkerhetskopior (Golden Snapshots) av databasvolymer för snabb återställning (~15s).

---

## 🛠️ Tillgängliga Skript

- **`create-golden-snapshots.sh`:** Skapar ett komprimerat `.tar.gz`-arkiv av databasvolymer i `golden-snapshots/`.
  ```bash
  # Standard ögonblicksbild:
  ./scripts/snapshots/create-golden-snapshots.sh

  # Namngiven anpassad ögonblicksbild:
  ./scripts/snapshots/create-golden-snapshots.sh --name "crm-app"
  ```
- **`restore-golden-snapshots.sh`:** Återställer databasvolymer från den senaste eller angivna ögonblicksbilden.
  ```bash
  # Återställ senaste ögonblicksbilden automatiskt:
  ./scripts/snapshots/restore-golden-snapshots.sh --force

  # Återställ namngiven ögonblicksbild:
  ./scripts/snapshots/restore-golden-snapshots.sh --name "crm-app"

  # Välj från interaktiv meny:
  ./scripts/snapshots/restore-golden-snapshots.sh
  ```
- **`clean-golden-snapshots.sh`:** Raderar gamla ögonblicksbilder för att frigöra diskutrymme medan den senaste behålls.
  ```bash
  ./scripts/snapshots/clean-golden-snapshots.sh
  ```
