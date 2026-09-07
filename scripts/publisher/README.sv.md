[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📑 Driftskript för Analytics Publisher (`scripts/publisher/`)

Denna katalog tillhandahåller verktyg för hantering av Oracle Analytics Publisher (Pixel Perfect rapportmotor), dess WebLogic-domän, katalogbackuper och rapportdriftsättning.

---

## 🛠️ Tillgängliga Skript

- **`status-publisher.sh`:** Kontrollerar hälsan och statusen för Analytics Publisher och dess datakällor.
  ```bash
  ./scripts/publisher/status-publisher.sh
  ```
- **`restart-publisher.sh`:** Startar om Analytics Publisher WebLogic-containern på ett kontrollerat sätt.
  ```bash
  ./scripts/publisher/restart-publisher.sh
  ```
- **`deploy-publisher-reports.sh`:** Synkroniserar och driftsätter rapporter från `publisher-reports/` till katalogen.
  ```bash
  ./scripts/publisher/deploy-publisher-reports.sh
  ```
- **`backup-publisher-catalog.sh`:** Säkerhetskopierar och exporterar Publisher-rapportkatalogen till ett arkiv.
  ```bash
  ./scripts/publisher/backup-publisher-catalog.sh
  ```
