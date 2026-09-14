[ 🇬🇧 English ](../spec-driven-development-and-assembly-line.md) | [ 🇪🇪 Eesti ](../et/spec-driven-development-and-assembly-line.md) | [ 🇫🇮 Suomi ](../fi/spec-driven-development-and-assembly-line.md) | [ 🇸🇪 Svenska ](spec-driven-development-and-assembly-line.md) | [ 🇱🇻 Latviešu ](../lv/spec-driven-development-and-assembly-line.md) | [ 🇱🇹 Lietuvių ](../lt/spec-driven-development-and-assembly-line.md)

# Specifikationsdriven utveckling (SDD), självständiga system (SCS) och agentisk monteringslinje

> **Arkitekturstandard för övergång från experimentell kodning till produktionsfärdig (viable) kod på Oracle DevOps-plattformen**

Se fullständig teknisk dokumentation i den [🇬🇧 engelska huvudguiden](../spec-driven-development-and-assembly-line.md) eller den [🇪🇪 estniska guiden](../et/spec-driven-development-and-assembly-line.md).

## Kärnprinciper
1. **Julian Wood (AWS) — Spec-Driven Development (SDD):** Krav, design och uppgifter (`docs/specs/<domain>/`) före kodning.
2. **Simon Martinelli — Self-Contained Systems (SCS):** PDB-isolering och kontextbudget (<300–500 rader).
3. **Thomas Dohmke (Entire.io / ex-GitHub) — Agentic Assembly Line:** Ralph Loop-autonomi, sessionsloggar (`.agents/trails/`) och 5 kvalitetsgrindar.
