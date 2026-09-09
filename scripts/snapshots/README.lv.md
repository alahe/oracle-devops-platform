[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📸 Datu bāzes momentuzņēmumu (golden snapshots) pārvaldības skripti (`scripts/snapshots/`)

Šis direktorijs nodrošina skriptus saspiestu rezerves kopiju (Golden Snapshots) izveidei, atjaunošanai un pārvaldībai no datubāzes sējumiem ātrai ~15s atkopšanai.

---

## 🛠️ Pieejamie skripti

- **`create-golden-snapshots.sh`:** Izveido saspiestu `.tar.gz` arhīvu no datubāzes sējumiem mapē `golden-snapshots/`.
  ```bash
  # Standarta bāzes momentuzņēmums:
  ./scripts/snapshots/create-golden-snapshots.sh

  # Pielāgots momentuzņēmums ar nosaukumu:
  ./scripts/snapshots/create-golden-snapshots.sh --name "crm-app"
  ```
- **`restore-golden-snapshots.sh`:** Atjauno datubāzes sējumus no jaunākā vai norādītā momentuzņēmuma.
  ```bash
  # Atjaunot jaunāko momentuzņēmumu automātiski:
  ./scripts/snapshots/restore-golden-snapshots.sh --force

  # Atjaunot nosaukto momentuzņēmumu:
  ./scripts/snapshots/restore-golden-snapshots.sh --name "crm-app"

  # Izvēlēties no interaktīvās izvēlnes:
  ./scripts/snapshots/restore-golden-snapshots.sh
  ```
- **`clean-golden-snapshots.sh`:** Dzēš vecos momentuzņēmumus diska vietas atbrīvošanai, saglabājot jaunāko kopiju.
  ```bash
  ./scripts/snapshots/clean-golden-snapshots.sh
  ```
