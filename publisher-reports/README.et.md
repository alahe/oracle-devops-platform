[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📑 Analytics Publisher Aruannete Kaust (`publisher-reports/`)

See kataloog sisaldab Oracle Analytics Publisheri aruandemalle (`.rtf`, `.xpt`) ja andmemudeleid (`.xdm`).

---

## 🚀 Operatsioonid

- **Kataloogi struktuur:** `Custom/` (kõik kohalikud arendatavad aruanded).
- **Automaatne tarne:**
  ```bash
  ./scripts/publisher/deploy-publisher-reports.sh
  ```
- **Kataloogi varundus ja eksport:**
  ```bash
  ./scripts/publisher/backup-publisher-catalog.sh
  ```
