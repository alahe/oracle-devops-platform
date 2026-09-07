[ 🇬🇧 English ](../publisher-setup.md) | [ 🇪🇪 Eesti ](publisher-setup.md) | [ 🇸🇪 Svenska ](../sv/README.md) | [ 🇱🇻 Latviešu ](../lv/README.md) | [ 🇱🇹 Lietuvių ](../lt/README.md)

# Oracle analytics Publisher (pixel perfect) paigaldus- ja kasutusjuhend

See juhend kirjeldab **Oracle Analytics Publisheri (Pixel Perfect / BI Publisher)** paigaldamist, arhitektuuri, andmeallikate automaatset sidumist ja aruannete haldust blueprintide **Seeria 10–19 ja 40** raames.

---

## 1. Arhitektuur ja portide jaotus

| Komponent | Port | URL / Sihtkoht | Kirjeldus & Roll |
| :--- | :--- | :--- | :--- |
| 📑 **Analytics Publisher UI** | `9502` (HTTP) / `9503` (HTTPS) | `http://localhost:9502/xmlpserver` | Publisheri veebiliides, aruannete toimetaja, andmemudelid ja ajastaja |
| ⚙️ **WebLogic Admin Console** | `9500` / `7001` | `http://localhost:9500/console` | WebLogic AdminServer haldusliides |
| 🗄️ **Publisher DB (`db-publisher`)** | `1531` | `localhost:1531/FREEPDB1` | Pühendatud andmebaas RCU metaandmete (`OAS_STB`, `OAS_BIPLATFORM`, `OAS_OPSS`) hoidmiseks |
| 🗄️ **Äribaas (`db-proxy` / `db-alise`)** | `1532` / `1533` | `localhost:1532/FREEPDB1` | Äriandmete baas, kust Publisher pärib aruannete andmeid |
| 🚀 **ORDS REST API Gateway** | `8088` / `8448` | `https://localhost:8448/ords/` | REST teenuste ja aruannete käivituse API |

---

## 2. Toetatud blueprintid (seeria 10–19)

| Blueprint ID | Faili Nimi | Konteinerid | Otstarve ja Arhitektuur |
| :---: | :--- | :--- | :--- |
| **BP 10** | `.env.10-publisher-dedicated-db` | `db-publisher`, `app-publisher` | **Pühendatud Publisher:** Publisher ja eraldiseisev RCU andmebaas. |
| **BP 11** | `.env.11-publisher-full-enterprise` | 3 DB-d, `app-ords`, `app-publisher` | **Täisisoleeritud Ettevõttestack:** Publisher + 3 eraldatud andmebaasi + ORDS. |
| **BP 12** | `.env.12-publisher-minimal-hybrid` | `db-proxy`, `db-alise`, `app-ords`, `app-publisher` | **Minimaalne Hübriid:** Kombineeritud Publisher/Proxy DB + LIS DB + Publisher. |
| **BP 13** | `.env.13-publisher-all-in-one-db` | `db-proxy`, `app-ords`, `app-publisher` | **Kõik-ühes Publisher:** Kõik skeemid ühes andmebaasis + Publisher. |
| **BP 32** | `.env.32-publisher-gvenzl-with-web-ide` | `db-publisher`, `app-publisher`, `web-ide-dev` | **Publisher Dev Lab:** Pixel Perfect aruandlus kergel baasil koos Web IDE-ga. |
| **BP 40** | `.env.40-ultimate-all-in-one-enterprise` | Kõik 5 konteinerit | **Ultimate Enterprise:** Forms 14c + Publisher + APEX 26.1 + ORDS. |

---

## 3. Automaatne andmeallikate ja SEPS walleti sidumine

Publisher vajab äriandmete pärimiseks ligipääsu andmebaasile. Süsteem automatiseerib selle 100%:

1. **Paroolivaba `PUBLISHER_READER` Konto:**
   - Andmebaasis luuakse piiratud õigustega konto `PUBLISHER_READER`.
   - Parool talletatakse turvaliselt SEPS Walletisse aliase all `DB_PUBLISHER_READER`.
   - Parooli saab pärida: `./scripts/get-password.sh DB_PUBLISHER_READER`
2. **Automaatne JDBC Data Source (`ALISE_APP_DB`):**
   - Skript `scripts/internal/init-publisher-datasource.sh` genereerib automaatselt XML andmeallika konfiguratsiooni, sidudes Publisheri otse aktiivse andmebaasiga.

---

## 4. Aruannete ja mallide tarne (`deploy-publisher-reports.sh`)

Aruannete failide (`.xdo`, `.rtf`, `.xpt`) paigaldamiseks on 3 võimalust:

1. **Lokaalne Kaust (`publisher-reports/`):**
   - Aseta oma aruanded kausta `publisher-reports/Custom/`.
   - Käivita: `./scripts/publisher/deploy-publisher-reports.sh`
2. **Artifactory Ehituspakett:**
   - Määra `.env` failis `PUBLISHER_REPORTS_ARTIFACTORY_URL=https://artifactory.../reports.zip`.
3. **Kataloogi Varundamine:**
   - Varunda kogu kataloog käsuga: `./scripts/publisher/backup-publisher-catalog.sh`

---

## 5. Igapäevased käsurea tööriistad

```bash
# 1. Kontrolli Publisheri staatust ja tervist:
./scripts/publisher/status-publisher.sh

# 2. Taaskäivita Publisheri teenus:
./scripts/publisher/restart-publisher.sh

# 3. Tarnid aruanded Publisheri kataloogi:
./scripts/publisher/deploy-publisher-reports.sh

# 4. Varunda Publisheri kataloog:
./scripts/publisher/backup-publisher-catalog.sh

# 5. Paigalda Publisheri ametlik OPatch uuendus:
./scripts/patches/apply-publisher-patch.sh
```