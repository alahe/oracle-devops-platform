# [TASK-018]: Paigalduse Ajakulu Optimeerimine (APEX DB Kiirendus 15m ➔ 1–2m)

**Staatus:** `TODO`  
**Prioriteet:** `HIGH`  
**Valdkond:** `Performance`  
**Seotud Blueprintid:** Kõik APEX-iga blueprintid  

---

## 1. Probleemi Kirjeldus ja Kontekst
APEX mootori kompileerimine ja DBCA baasi loomine võtab esmasel paigaldusel 10–15 minutit.

## 2. Eesmärk ja Oodatav Tulemus
Lühendada paigalduse aeg alla 1–2 minuti.

## 3. Tehniline Teostus ja Arhitektuurilised Variandid
- **Variant A (Soovitatud):** Eelkonfigureeritud konteineripildid (`oracle-free-apex:26.2`), kus APEX on juba sisse ehitatud.
- **Variant B:** FastStart piltide laialdane kasutamine (`gvenzl/oracle-free:23-full-faststart`).
- **Variant C:** Golden Snapshot kaustade ja volume'ite taastamine.

## 4. Verifitseerimine ja Automaattestid
- `metrics/setup_benchmarks.json` mõõdab kogu paigalduse aja ja võrdleb baasmõõdikutega.
