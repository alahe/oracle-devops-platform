[ 🇬🇧 English ](../spec-driven-development-and-assembly-line.md) | [ 🇪🇪 Eesti ](../et/spec-driven-development-and-assembly-line.md) | [ 🇫🇮 Suomi ](../fi/spec-driven-development-and-assembly-line.md) | [ 🇸🇪 Svenska ](../sv/spec-driven-development-and-assembly-line.md) | [ 🇱🇻 Latviešu ](../lv/spec-driven-development-and-assembly-line.md) | [ 🇱🇹 Lietuvių ](spec-driven-development-and-assembly-line.md)

# Specifikacijomis Grįstas Vystymas (SDD), Savarankiškos Sistemos (SCS) ir Agentų Konvejeris

> **Architektūros standartas perėjimui prie gamybai paruošto (viable) kodo Oracle DevOps platformoje**

Žiūrėkite išsamią techninę dokumentaciją [🇬🇧 pagrindiniame anglų k. vadove](../spec-driven-development-and-assembly-line.md) arba [🇪🇪 estų k. vadove](../et/spec-driven-development-and-assembly-line.md).

## Pagrindiniai Principai
1. **Julian Wood (AWS) — Spec-Driven Development (SDD):** Reikalavimai, projektas ir užduotys (`docs/specs/<domain>/`) prieš rašant kodą.
2. **Simon Martinelli — Self-Contained Systems (SCS):** PDB izoliacija ir AI konteksto biudžetas (<300–500 eilučių).
3. **Thomas Dohmke (Entire.io / ex-GitHub) — Agentic Assembly Line:** Ralph Loop automatika, sesijų žurnalai (`.agents/trails/`) ir 5 kokybės vartai.
