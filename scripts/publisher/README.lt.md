[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📑 Analytics Publisher veiklos scenarijai (`scripts/publisher/`)

Šiame kataloge pateikiami įrankiai, skirti valdyti Oracle Analytics Publisher (Pixel Perfect ataskaitų variklį), jo WebLogic domeną, katalogų atsargines kopijas ir ataskaitų diegimą.

---

## 🛠️ Prieinami scenarijai

- **`status-publisher.sh`:** Tikrina Analytics Publisher paslaugos ir duomenų šaltinių būseną ir sveikatą.
  ```bash
  ./scripts/publisher/status-publisher.sh
  ```
- **`restart-publisher.sh`:** Tvarkingai iš naujo paleidžia Analytics Publisher WebLogic konteinerį.
  ```bash
  ./scripts/publisher/restart-publisher.sh
  ```
- **`deploy-publisher-reports.sh`:** Sinchronizuoja ir įdiegia ataskaitas iš `publisher-reports/` į katalogą.
  ```bash
  ./scripts/publisher/deploy-publisher-reports.sh
  ```
- **`backup-publisher-catalog.sh`:** Sukuria Publisher ataskaitų katalogo atsarginę kopiją ir eksportuoja į archyvą.
  ```bash
  ./scripts/publisher/backup-publisher-catalog.sh
  ```
