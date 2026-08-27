# [TASK-016]: LIS Süsteemi Üldine Põhiarhitektuur (4-Kihiline Mudel)

**Staatus:** `DONE`  
**Prioriteet:** `HIGH`  
**Valdkond:** `Architecture`  

---

## 1. Probleemi Kirjeldus ja Kontekst
Ettevõtte infosüsteem vajab ranget turvatsoonide eraldamist: metaandmed, vahekiht, äribaas ja aruandlus peavad olema eraldatud.

## 2. Eesmärk ja Oodatav Tulemus
Standardne 4-kihiline mudel:
- `db-publisher` (Metaandmed)
- `db-proxy` (APEX & Outbound REST Gateway)
- `db-lis` (Isoleeritud äribaas ilma interneti väljundita)
- `app-ords` + `app-publisher` (Veebiteenused)

## 3. Tehniline Teostus
- Blueprint `.env.7-all-services-together` ja topoloogia lahendusmootor.

## 4. Verifitseerimine
- Kontrollitud Blueprint 7 paigaldust ja teenuste omavahelist suhtlust.
