[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📑 Analytics Publisher Darbības skripti (`scripts/publisher/`)

Šis direktorijs nodrošina rīkus Oracle Analytics Publisher (Pixel Perfect atskaišu dzinēja), tā WebLogic domēna, atskaišu kataloga dublēšanas un ieviešanas pārvaldībai.

---

## 🛠️ Pieejamie skripti

- **`status-publisher.sh`:** Pārbauda Analytics Publisher servisa un datu avotu statusu un veselību.
  ```bash
  ./scripts/publisher/status-publisher.sh
  ```
- **`restart-publisher.sh`:** Korekti pārstartē Analytics Publisher WebLogic konteineru.
  ```bash
  ./scripts/publisher/restart-publisher.sh
  ```
- **`deploy-publisher-reports.sh`:** Sinhronizē un ievieš atskaites no `publisher-reports/` Publisher katalogā.
  ```bash
  ./scripts/publisher/deploy-publisher-reports.sh
  ```
- **`backup-publisher-catalog.sh`:** Dublē un eksportē Publisher atskaišu katalogu arhīvā.
  ```bash
  ./scripts/publisher/backup-publisher-catalog.sh
  ```
