# Agentic Assembly Line — Session Trails & Institutional Memory

See kaust talletab **Thomas Dohmke (Entire.io / endine GitHub CEO)** *"The Agentic Assembly Line"* kontseptsiooni alusel projekti **institutsionaalset mälu (Session Logs & Intent Trails)**.

---

## Miks see kaust eksisteerib?

Traditsioonilises tarkvaraarenduses kaob vestlus arendaja ja AI vahel peale brauseri või IDE akna sulgemist. Git salvestab koodidiffi, kuid ei salvesta seda, **MIKS** midagi tehti, milliseid alternatiive kaaluti, millised olid AI viibad ning millised vead lahendati Ralph Loop autonoomsetes parandustsüklites.

### Iga sessioonilogi (`trail_YYYYMMDD_*.md`) talletab:
1. **Kavatsus (Intent):** Mida arendaja või agent saavutada soovis.
2. **Arhitektuuriline raamistik:** Seos kanooniliste nõuetega (`docs/specs/`) ja otsustega (`docs/adr/`).
3. **Läbitud iteratsioonid (Ralph Loops):** Mis esialgu ebaõnnestus ja kuidas see lahendati.
4. **Kvaliteediväravate tõendid (Evaluation Gates):** Millised testid kinnitasid muudatuse tootmiskõlblikkust.
5. **AI mudeli andmed:** Kasutatud AI mootor (Copilot, Antigravity, Claude, Gemini) ja seansi staatus.

Tulevased agendid ja tiimiliikmed loevad neid faile, et vältida juba lahendatud vigade kordamist ja mõista koodi sügavat tausta.
