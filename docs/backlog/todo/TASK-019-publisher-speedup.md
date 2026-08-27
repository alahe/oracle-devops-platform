# [TASK-019]: Analytics Publisheri & Multi-DB Paigalduse Kiirendus

**Staatus:** `TODO`  
**Prioriteet:** `HIGH`  
**Valdkond:** `Performance`  
**Seotud Blueprintid:** `.env.4-*`, `.env.7-*`, `.env.12-*`, `.env.13-*`  

---

## 1. Probleemi Kirjeldus ja Kontekst
Analytics Publisheri WebLogic domeeni ehitus (`create_base_domain.py`) ja RCU skeemid võtavad esmasel paigaldusel ~8 minutit.

## 2. Eesmärk ja Oodatav Tulemus
Vähendada Publisheri stardiaeg alla 1 minuti.

## 3. Tehniline Teostus
- Eel-ehitatud WebLogic BI domeenipilt (`oracle-publisher-domain-prebuilt:2025`).
- Nutikas paralleelne orkestreerimine piisava RAM-iga masinates (≥ 8 GB).

## 4. Verifitseerimine
- Benchmark ajamõõtmine ja Publisheri URL tervisekontroll.
