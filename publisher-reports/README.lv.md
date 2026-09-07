[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📑 Analytics Publisher Atskaišu direktorijs (`publisher-reports/`)

Šis direktorijs satur Oracle Analytics Publisher atskaišu veidnes (`.rtf`, `.xpt`) un datu modeļus (`.xdm`).

---

## 🚀 Darbības

- **Direktorija struktūra:** `Custom/` (visas pielāgotās izstrādātāja atskaites).
- **Automatizēta ieviešana:**
  ```bash
  ./scripts/publisher/deploy-publisher-reports.sh
  ```
- **Kataloga dublēšana un eksportēšana:**
  ```bash
  ./scripts/publisher/backup-publisher-catalog.sh
  ```
