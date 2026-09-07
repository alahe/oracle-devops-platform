[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📑 Analytics Publisher -Raporttien Hakemisto (`publisher-reports/`)

Tämä hakemisto sisältää Oracle Analytics Publisherin raporttimallit (`.rtf`, `.xpt`) ja tietomallit (`.xdm`).

---

## 🚀 Toiminnot

- **Hakemistorakenne:** `Custom/` (kaikki mukautetut kehittäjän raportit).
- **Automaattinen käyttöönotto:**
  ```bash
  ./scripts/publisher/deploy-publisher-reports.sh
  ```
- **Luettelon varmuuskopiointi ja vienti:**
  ```bash
  ./scripts/publisher/backup-publisher-catalog.sh
  ```
