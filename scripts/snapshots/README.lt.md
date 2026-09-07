[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📸 Duomenų Bazės momentinių kopijų (golden snapshots) valdymo scenarijai (`scripts/snapshots/`)

Šiame kataloge pateikiami scenarijai, skirti kurti, atkurti ir valdyti suspaustas duomenų bazių tomų atsargines kopijas (Golden Snapshots) greitam atstatymui (~15s).

---

## 🛠️ Prieinami scenarijai

- **`create-golden-snapshots.sh`:** Sukuria suspaustą `.tar.gz` archyvą iš duomenų bazės tomų kataloge `golden-snapshots/`.
  ```bash
  # Standartinė bazinė momentinė kopija:
  ./scripts/snapshots/create-golden-snapshots.sh

  # Vardinė pasirinktinė momentinė kopija:
  ./scripts/snapshots/create-golden-snapshots.sh --name "crm-app"
  ```
- **`restore-golden-snapshots.sh`:** Atkuria duomenų bazės tomus iš naujausios arba nurodytos momentinės kopijos.
  ```bash
  # Automatiškai atkurti naujausią momentinę kopiją:
  ./scripts/snapshots/restore-golden-snapshots.sh --force

  # Atkurti įvardytą momentinę kopiją:
  ./scripts/snapshots/restore-golden-snapshots.sh --name "crm-app"

  # Pasirinkti iš interaktyvaus meniu:
  ./scripts/snapshots/restore-golden-snapshots.sh
  ```
- **`clean-golden-snapshots.sh`:** Ištrina senas momentines kopijas disko vietos atlaisvinimui, palikdamas naujausią kopiją.
  ```bash
  ./scripts/snapshots/clean-golden-snapshots.sh
  ```
