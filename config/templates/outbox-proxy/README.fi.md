[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# Passiivinen Ydintietokanta ja DMZ Proxy -arkkitehtuuri (Transactional Outbox Pattern)

Tämä arkkitehtuurimalli toteuttaa tiukan tietoturvamallin, jossa liiketoimintakanta ei muodosta ulospäin suuntautuvia yhteyksiä.

---

## 1. Tietoturvaperiaate: Ydinkanta EI OLE ulospäin suuntautuva toimija

- **Ydintietokanta (`db-alise`):** Eristetty sisäverkkoon. Palomuurit kieltävät ulospäin suuntautuvat TCP-, HTTP- ja Kafka-yhteydet.
- **DMZ Proxy -tietokanta (`db-proxy` / ORDS):** Välipalvelinkerroksessa sijaitseva kanta, jolla on oikeus tehdä ulkoisia REST- ja Kafka-kutsuja.
