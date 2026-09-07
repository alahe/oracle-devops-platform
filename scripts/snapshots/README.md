[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📸 Golden Snapshots Management Scripts (`scripts/snapshots/`)

This directory provides scripts for creating, restoring, and managing compressed cold backups (Golden Snapshots) of database volumes for fast ~15s recovery and disaster resilience.

---

## 🛠️ Available Scripts

- **`create-golden-snapshots.sh`:** Creates a compressed `.tar.gz` archive of database data volumes in `golden-snapshots/`.
  ```bash
  # Standard base snapshot:
  ./scripts/snapshots/create-golden-snapshots.sh

  # Named custom snapshot:
  ./scripts/snapshots/create-golden-snapshots.sh --name "crm-app"
  ```
- **`restore-golden-snapshots.sh`:** Restores database volumes from the latest or specified snapshot.
  ```bash
  # Restore latest snapshot automatically:
  ./scripts/snapshots/restore-golden-snapshots.sh --force

  # Restore named snapshot:
  ./scripts/snapshots/restore-golden-snapshots.sh --name "crm-app"

  # Interactive selection menu:
  ./scripts/snapshots/restore-golden-snapshots.sh
  ```
- **`clean-golden-snapshots.sh`:** Deletes old snapshots to free disk space while preserving the latest snapshot.
  ```bash
  ./scripts/snapshots/clean-golden-snapshots.sh
  ```
