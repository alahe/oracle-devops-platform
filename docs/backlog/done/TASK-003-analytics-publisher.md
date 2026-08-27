# [TASK-003]: Oracle Analytics Publisher (Pixel Perfect) Kohalik Käivitamine

**Staatus:** `DONE`  
**Prioriteet:** `HIGH`  
**Valdkond:** `Architecture`  
**Seotud Blueprintid:** `.env.4-*`, `.env.7-*`, `.env.12-*`, `.env.13-*`  
**Dokumentatsioon:** [docs/publisher-guide.md](../publisher-guide.md)  

---

## 1. Probleemi Kirjeldus ja Kontekst
Ettevõtte aruandlus vajab Pixel-Perfect PDF/Excel/XML genereerimist (Oracle Analytics Publisher / BI Publisher), kuid selle kohalik seadistamine WebLogic domeenis on keerukas.

## 2. Eesmärk ja Oodatav Tulemus
Automatiseeritud WebLogic RCU metaandmete baasi initsialiseerimine, domeeni loomine ja Publisher teenuse käivitamine konteineris pordil 9502.

## 3. Tehniline Teostus
- Skriptid `scripts/internal/install-publisher.sh`, `scripts/internal/init-publisher-rcu.sh`, `scripts/internal/init-publisher-datasource.sh`.
- Analytics Publisheri operatsioonide CLI tööriistad kaustas `scripts/publisher/`.

## 4. Verifitseerimine
- Kontrollitud `http://localhost:9502/xmlpserver/login.jsp` reageerimist (HTTP 200 OK) ja `<title>Oracle Analytics Publisher Login</title>`.
