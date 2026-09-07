[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📑 Analytics Publisher Operational Scripts (`scripts/publisher/`)

This directory provides operational tools for managing Oracle Analytics Publisher (Pixel Perfect reporting engine), its WebLogic domain, catalog backups, and report deployments.

---

## 🛠️ Available Scripts

- **`status-publisher.sh`:** Checks the health and status of Analytics Publisher and its data sources.
  ```bash
  ./scripts/publisher/status-publisher.sh
  ```
- **`restart-publisher.sh`:** Restarts the Analytics Publisher WebLogic container gracefully.
  ```bash
  ./scripts/publisher/restart-publisher.sh
  ```
- **`deploy-publisher-reports.sh`:** Synchronizes and deploys reports from `publisher-reports/` to the Publisher catalog.
  ```bash
  ./scripts/publisher/deploy-publisher-reports.sh
  ```
- **`backup-publisher-catalog.sh`:** Backs up and exports the Publisher report catalog into an archive.
  ```bash
  ./scripts/publisher/backup-publisher-catalog.sh
  ```
