# [TASK-026]: `setup-all.sh` Blueprintide Nimekirja ja Info CLI Parameetrid

**Staatus:** `TODO`  
**Prioriteet:** `MEDIUM`  
**Valdkond:** `Tooling`  

---

## 1. Probleemi Kirjeldus ja Kontekst
Arendajal on vaja teada kõiki 13 ametlikku blueprinti, nende sisu ja vajalikke ressursse ilma `config/blueprints/` kausta käsitsi sirvimata.

## 2. Eesmärk ja Oodatav Tulemus
CLI parameetrid peaskriptis [`scripts/setup-all.sh`](../../scripts/setup-all.sh):
- `--list-blueprints` / `-lb` (Kuvab terminalis värvilise tabeli kõigist 13 mudelist).
- `--show-blueprint <N>` / `-sb <N>` (Kuvab konkreetse mudeli konfiguratsiooni).
- `--search-blueprints <MÄRKSÕNA>` (Filtreerib mudeleid teenuse järgi).
- `-b <N> --dry-run` (Simuleerib käivitust ja kuvab eelinfo).

## 3. Tehniline Teostus
- Parameetrite parsimine ja tabeli väljastusfunktsioon peaskriptis `scripts/setup-all.sh` ning abiskriptis `scripts/internal/load-profile.sh`.

## 4. Verifitseerimine
- Kontrollida käskude `./scripts/setup-all.sh --list-blueprints` ja `./scripts/setup-all.sh -sb 3` väljundit.
