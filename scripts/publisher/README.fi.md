[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📑 Analytics publisherin toiminnalliset komentosarjat (`scripts/publisher/`)

Tämä hakemisto tarjoaa työkalut Oracle Analytics Publisherin (Pixel Perfect -raportointimoottorin), sen WebLogic-toimialueen, luetteloiden varmuuskopioinnin ja raporttien käyttöönoton hallintaan.

---

## 🛠️ Käytettävissä Olevat komentosarjat

- **`status-publisher.sh`:** Tarkistaa Analytics Publisherin ja sen tietolähteiden tilan ja terveyden.
  ```bash
  ./scripts/publisher/status-publisher.sh
  ```
- **`restart-publisher.sh`:** Käynnistää Analytics Publisherin WebLogic-säilön uudelleen siististi.
  ```bash
  ./scripts/publisher/restart-publisher.sh
  ```
- **`deploy-publisher-reports.sh`:** Synkronoi ja ottaa käyttöön raportit hakemistosta `publisher-reports/` luetteloon.
  ```bash
  ./scripts/publisher/deploy-publisher-reports.sh
  ```
- **`backup-publisher-catalog.sh`:** Varmuuskopioi ja vie Publisher-raporttiluettelon arkistoon.
  ```bash
  ./scripts/publisher/backup-publisher-catalog.sh
  ```
