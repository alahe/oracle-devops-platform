# [TASK-023]: Keskne Auditilogi ja SIEM Integratsioon (Unified Auditing)

**Staatus:** `TODO`  
**Prioriteet:** `MEDIUM`  
**Valdkond:** `Security`  

---

## 1. Probleemi Kirjeldus ja Kontekst
Andmebaasi turvasündmused, volitamata päringud ja administraatori tegevused peavad laekuma kesksesse logihaldussüsteemi (Splunk, Elastic, Azure Sentinel).

## 2. Eesmärk ja Oodatav Tulemus
Rakendada Oracle Unified Auditing poliitikad ja logiforwarder konteineri profiil (Vector / Fluentd).

## 3. Tehniline Teostus
- Skript `scripts/internal/init-unified-auditing.sql` ja logiforwarder seadistus.

## 4. Verifitseerimine
- Kontrollida turvalogi laekumist ja sündmuste filtreerimist.
