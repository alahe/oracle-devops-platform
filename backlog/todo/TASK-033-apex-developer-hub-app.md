# [TASK-033]: Developer Hub Realiseerimine ja Automaatne Paigaldus OracleAPEX Rakendusena (ApexLang)

**Staatus:** `TODO` (Backlog)  
**Prioriteet:** `MEDIUM`  
**Valdkond:** `APEX / DevOps Automation`  
**Seotud Komponendid:** `binaries/apex_apps/`, `scripts/setup-all.sh` (Samm 8), `docs/dev-hub.html`

---

## 1. Probleemi Kirjeldus ja Kontekst
Praegune Developer Hub luuakse universaalse staatilise veebirakendusena (ORDS Docroot / HTML+JS SPA). Tulevikus soovitakse sama funktsionaalsus (Live Services status, Arhitektuuriskeemid, Blueprintide sirvimine, Docs luger, DevOps käskude dispatching) realiseerida ka **iseseisva Oracle APEX rakendusena**.

See võimaldab testida ja demonstreerida:
1. Kuidas Oracle APEX rakendusi paigaldada automaatselt paigaldusvoos (`scripts/setup-all.sh`  - `Deploy Packaged APEX Apps`).
2. Kuidas APEX rakendusi paigaldada ja hallata automaatselt. (ORDS Developer Hub).
3. Kuidas kasutada **ApexLang** keelt / APEX rakenduse eksporditud ApxLang faile .*.apx formaadis versioonihalduseks ja tarnimiseks. Kasutada selleks SQLcl project käske.  
4. Kuidas APEX saab suhelda andmebaasi pakettide (`DBMS_SCHEDULER`, `APEX_WEB_SERVICE`) kaudu konteinerite ja süsteemsete mõõdikutega.

---

## 2. Eesmärk ja Oodatav Tulemus
1. **APEX Rakendus:** Luua APEX rakendus (nt App ID 101 või 200) nimega "Oracle DevOps Platform Developer Hub".
2. **ApexLang / SQL Export:** Pakendada rakendus kausta `binaries/apex_apps/`.
3. **Automaatne Import:** `scripts/setup-all.sh` sammus 8 imporditakse rakendus automaatselt andmebaasi (`PROXY_WORKSPACE` või `DEV_WORKSPACE`).
4. **Disain ja Funktsionaalsus:** APEX rakenduse lehed ja kaardid vastavad 1:1 ORDS Developer Hubile.

---

## 3. Tehniline Arhitektuur
- **APEX Universal Theme:** Tume teema (Vita - Dark / Redwood Dark).
- **APEX REST Data Sources:** Reaalajas staatuste pärimine ORDS ja konteinerite REST otspunktidest.
- **ApexLang / SQLcl Project:** Rakenduse komponentide automaatne eksport ja import SQLcl `project` või `apex export` käskude kaudu.

---

## 4. Tegevuskava (Kui see ülesanne töösse võetakse)
1. Luua APEX rakenduse skeem ja lehtede struktuur.
2. Lisada Mermaid.js tugi APEX lehe päisesse.
3. Eksportida rakenduse SQL kood kausta `binaries/apex_apps/`.
4. Testida impordi kiirust ja toimivust `setup-all.sh` sammus 8.
