[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📑 Katalog för Analytics Publisher rapporter (`publisher-reports/`)

Denna katalog innehåller rapportmallar (`.rtf`, `.xpt`) och datamodeller (`.xdm`) för Oracle Analytics Publisher.

---

## 🚀 Funktioner

- **Katalogstruktur:** `Custom/` (alla anpassade utvecklarrapporter).
- **Automatiserad driftsättning:**
  ```bash
  ./scripts/publisher/deploy-publisher-reports.sh
  ```
- **Katalogsäkerhetskopiering och export:**
  ```bash
  ./scripts/publisher/backup-publisher-catalog.sh
  ```
