[ 🇬🇧 English ](../publisher-setup.md) | [ 🇪🇪 Eesti ](../et/publisher-setup.md) | [ 🇫🇮 Suomi ](publisher-setup.md) | [ 🇸🇪 Svenska ](../sv/README.md) | [ 🇱🇻 Latviešu ](../lv/README.md) | [ 🇱🇹 Lietuvių ](../lt/README.md)

# Oracle Analytics Publisher (Pixel Perfect) Asennus- ja Käyttöohje

Tämä ohje kuvaa **Oracle Analytics Publisherin (Pixel Perfect / BI Publisher)** asennuksen, arkkitehtuurin, tietolähteiden automaattisen liittämisen ja raporttien hallinnan **sarjoissa 10–19 ja 40**.

---

## 1. Arkkitehtuuri ja Porttijako

| Komponentti | Portti | URL / Kohde | Kuvaus & Rooli |
| :--- | :--- | :--- | :--- |
| 📑 **Analytics Publisher UI** | `9502` (HTTP) / `9503` (HTTPS) | `http://localhost:9502/xmlpserver` | Publisher-verkkoliittymä, raporttieditori, tietomallit ja ajastin |
| ⚙️ **WebLogic Admin Console** | `9500` / `7001` | `http://localhost:9500/console` | WebLogic AdminServer -hallintaliittymä |
| 🗄️ **Publisher DB (`db-publisher`)** | `1535` | `localhost:1535/FREEPDB1` | Erillinen tietokanta RCU-metatiedoille (`OAS_STB`, `OAS_BIPLATFORM`, `OAS_OPSS`) |
| 🗄️ **Liiketoiminta DB (`db-alise`)** | `1533` | `localhost:1533/FREEPDB1` | Liiketoimintatietokanta, josta Publisher hakee raporttidatan |
| 🚀 **ORDS REST API Gateway** | `8088` / `8448` | `https://localhost:8448/ords/` | REST-palvelut ja raporttien käynnistyksen API |

---

## 2. Tuetut Blueprintit (Sarja 10–19)

| Blueprint ID | Tiedostonimi | Kontit | Tarkoitus ja Arkkitehtuuri |
| :---: | :--- | :--- | :--- |
| **BP 10** | `.env.10-publisher-dedicated-db` | `db-publisher`, `app-publisher` | **Erillinen Publisher:** Publisher ja erillinen RCU-tietokanta. |
| **BP 11** | `.env.11-publisher-full-enterprise` | 3 DB:tä, `app-ords`, `app-publisher` | **Täysin eristetty yrityspino:** Publisher + 3 erillistä tietokantaa + ORDS. |
| **BP 12** | `.env.12-publisher-minimal-hybrid` | `db-proxy`, `db-alise`, `app-ords`, `app-publisher` | **Minimaalinen Hybridi:** Yhdistetty Publisher/Proxy DB + Sovellus DB + Publisher. |
| **BP 13** | `.env.13-publisher-all-in-one-db` | `db-proxy`, `app-ords`, `app-publisher` | **Kaikki-yhdessä Publisher:** Kaikki skeemat yhdessä tietokannassa + Publisher. |
| **BP 40** | `.env.40-ultimate-all-in-one-enterprise` | Kaikki kontit | **Ultimate Enterprise:** Forms 14c + Publisher + APEX 26.1 + ORDS. |

---

## 3. Automaattinen Tietolähteiden ja SEPS Walletin Liittäminen

1. **Salasanaton `PUBLISHER_READER` -Tili:**
   - Tietokantaan luodaan rajatun oikeuden tili `PUBLISHER_READER`.
   - Salasana tallennetaan turvallisesti SEPS Walletiin aliaksella `DB_PUBLISHER_READER`.
   - Salasana noudetaan: `./scripts/get-password.sh DB_PUBLISHER_READER`
2. **Automaattinen JDBC Data Source:**
   - Skripti alustaa XML-tietolähdekonfiguraation automaattisesti liittäen Publisherin suoraan aktiiviseen tietokantaan.

---

## 4. Raporttien ja Mallien Jakelu (`deploy-publisher-reports.sh`)

1. **Paikallinen Kansio (`publisher-reports/`):**
   - Sijoita raportit kansioon `publisher-reports/Custom/`.
   - Suorita: `./scripts/publisher/deploy-publisher-reports.sh`
2. **Kuvaston Varmuuskopiointi:**
   - Varmuuskopioi koko kuvasto komennolla: `./scripts/publisher/backup-publisher-catalog.sh`
