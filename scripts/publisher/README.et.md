[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📑 Analytics publisheri operatsioonide skriptid (`scripts/publisher/`)

Käesolev kataloog sisaldab tööriistu Oracle Analytics Publisheri (Pixel Perfect aruandlusmootori), selle WebLogic domeeni, aruannete kataloogi varunduse ja tarnimise haldamiseks.

---

## 🛠️ Saadaolevad skriptid

- **`status-publisher.sh`:** Kontrollib Publisheri teenuse ja andmeallikate tervist ja staatust.
  ```bash
  ./scripts/publisher/status-publisher.sh
  ```
- **`restart-publisher.sh`:** Taaskäivitab Publisheri WebLogic konteineri puhtalt.
  ```bash
  ./scripts/publisher/restart-publisher.sh
  ```
- **`deploy-publisher-reports.sh`:** Sünkroniseerib ja paigaldab aruanded kaustast `publisher-reports/` Publisheri kataloogi.
  ```bash
  ./scripts/publisher/deploy-publisher-reports.sh
  ```
- **`backup-publisher-catalog.sh`:** Varundab ja ekspordib Publisheri aruannete kataloogi arhiivi.
  ```bash
  ./scripts/publisher/backup-publisher-catalog.sh
  ```
