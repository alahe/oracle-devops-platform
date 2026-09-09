[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📸 Andmebaasi hetktõmmiste (golden snapshots) halduse skriptid (`scripts/snapshots/`)

Käesolev kataloog sisaldab skripte andmebaasi mahutite tihendatud külmvarunduse (Golden Snapshots) loomiseks, taastamiseks ja haldamiseks, tagades kiire ~15s taastumise ja töökindluse.

---

## 🛠️ Saadaolevad skriptid

- **`create-golden-snapshots.sh`:** Loob andmemahtudest tihendatud `.tar.gz` arhiivi kausta `golden-snapshots/`.
  ```bash
  # Standardne baas-tõmmis:
  ./scripts/snapshots/create-golden-snapshots.sh

  # Eraldi nimega custom-tõmmis:
  ./scripts/snapshots/create-golden-snapshots.sh --name "crm-app"
  ```
- **`restore-golden-snapshots.sh`:** Taastab andmemahud viimasest või määratud hetktõmmisest.
  ```bash
  # Taasta viimane hetktõmmis automaatselt:
  ./scripts/snapshots/restore-golden-snapshots.sh --force

  # Taasta nimega hetktõmmis:
  ./scripts/snapshots/restore-golden-snapshots.sh --name "crm-app"

  # Vali interaktiivsest menüüst:
  ./scripts/snapshots/restore-golden-snapshots.sh
  ```
- **`clean-golden-snapshots.sh`:** Kustutab vanad hetktõmmised kettamahu vabastamiseks, jättes alles viimase koopia.
  ```bash
  ./scripts/snapshots/clean-golden-snapshots.sh
  ```
