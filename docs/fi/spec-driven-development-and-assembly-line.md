[ 🇬🇧 English ](../spec-driven-development-and-assembly-line.md) | [ 🇪🇪 Eesti ](../et/spec-driven-development-and-assembly-line.md) | [ 🇫🇮 Suomi ](spec-driven-development-and-assembly-line.md) | [ 🇸🇪 Svenska ](../sv/spec-driven-development-and-assembly-line.md) | [ 🇱🇻 Latviešu ](../lv/spec-driven-development-and-assembly-line.md) | [ 🇱🇹 Lietuvių ](../lt/spec-driven-development-and-assembly-line.md)

# Spesifikaatiolähtöinen Kehitys (SDD), Itsenäiset Järjestelmät (SCS) ja Agenttiliukuhihna

> **Arkkitehtuuristandardi siirtymiseen kokeellisesta koodauksesta tuotantolaatuiseen (viable) koodiin Oracle DevOps -alustalla**

Katso täydellinen tekninen dokumentaatio [🇬🇧 englanninkielisestä pääoppaasta](../spec-driven-development-and-assembly-line.md) tai [🇪🇪 vironkielisestä oppaasta](../et/spec-driven-development-and-assembly-line.md).

## Keskeiset Periaatteet
1. **Julian Wood (AWS) — Spec-Driven Development (SDD):** Vaatimukset, suunnittelu ja tehtävät (`docs/specs/<domain>/`) ennen koodin kirjoittamista.
2. **Simon Martinelli — Self-Contained Systems (SCS):** PDB-eristys ja AI-konteksti-ikkunan optimointi (<300–500 riviä).
3. **Thomas Dohmke (Entire.io / ex-GitHub) — Agentic Assembly Line:** Ralph Loop -automaattikorjaus, istuntolokit (`.agents/trails/`) ja 5 laatuporttia.
