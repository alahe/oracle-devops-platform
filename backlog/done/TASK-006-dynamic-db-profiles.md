# [TASK-006]: Dünaamiline YAML Andmebaasi Profiilide Mootor & Topoloogia Haldur

**Staatus:** `DONE`  
**Prioriteet:** `HIGH`  
**Valdkond:** `Architecture`  
**Dokumentatsioon:** [docs/db-profiles-and-topology.md](../../docs/db-profiles-and-topology.md)  

---

## 1. Probleemi Kirjeldus ja Kontekst
Mitme andmebaasi instantsi, portide ja kasutajate kõvakodeerimine skriptidesse tekitas vigade ohtu ja muutis uute arhitektuuride lisamise keeruliseks.

## 2. Eesmärk ja Oodatav Tulemus
Deklaratiivne YAML-põhine konfiguratsioon (`config/profiles/*.yaml`), mis kirjeldab andmebaasi pildid, pordid, APEX/ORDS seadistused ja kasutajad.

## 3. Tehniline Teostus
- Skriptid `scripts/internal/load-profile.sh`, `scripts/internal/resolve-topology.sh`, `scripts/internal/generate-compose-override.sh`.
- 13 arhitektuurset Blueprinti kaustas `config/blueprints/`.

## 4. Verifitseerimine
- Kõigi 13 blueprinti valideerimine ja testraamistik [`tests/README.md`](../../tests/README.md).
