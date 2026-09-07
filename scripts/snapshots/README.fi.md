[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📸 Tietokannan Tilannevedosten (Golden Snapshots) Hallintakomentosarjat (`scripts/snapshots/`)

Tämä hakemisto sisältää komentosarjat tietokantavolyymien pakattujen kylmävarmuuskopioiden (Golden Snapshots) luomiseen, palauttamiseen ja hallintaan nopeaa ~15s toipumista varten.

---

## 🛠️ Käytettävissä Olevat Komentosarjat

- **`create-golden-snapshots.sh`:** Luo pakatun `.tar.gz`-arkiston tietokantavolyymeistä hakemistoon `golden-snapshots/`.
  ```bash
  # Tavallinen perustilannevedos:
  ./scripts/snapshots/create-golden-snapshots.sh

  # Nimetty mukautettu tilannevedos:
  ./scripts/snapshots/create-golden-snapshots.sh --name "crm-app"
  ```
- **`restore-golden-snapshots.sh`:** Palauttaa tietokantavolyymit uusimmasta tai määritetystä tilannevedoksesta.
  ```bash
  # Palauta uusin tilannevedos automaattisesti:
  ./scripts/snapshots/restore-golden-snapshots.sh --force

  # Palauta nimetty tilannevedos:
  ./scripts/snapshots/restore-golden-snapshots.sh --name "crm-app"

  # Valitse interaktiivisesta valikosta:
  ./scripts/snapshots/restore-golden-snapshots.sh
  ```
- **`clean-golden-snapshots.sh`:** Poistaa vanhat tilannevedokset levytilan vapauttamiseksi säilyttäen uusimman kopion.
  ```bash
  ./scripts/snapshots/clean-golden-snapshots.sh
  ```
