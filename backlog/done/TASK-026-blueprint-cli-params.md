# [TASK-026]: `setup-all.sh` Blueprintide Nimekirja, Info ja Testimise CLI Parameetrid

**Staatus:** `DONE`  
**Prioriteet:** `MEDIUM`  
**Valdkond:** `Tooling`  
**Dokumentatsioon:** [config/blueprints/README.md](../../config/blueprints/README.md), [scripts/README.md](../../scripts/README.md)  

---

## 1. Probleemi Kirjeldus ja Kontekst
Arendajal ja testijal oli vaja teada kõiki 13 ametlikku blueprinti, nende sisu, aktiivseid konteinereid ja ressursivajadust ilma `config/blueprints/` kausta käsitsi sirvimata. Samuti puudus kiire pre-flight simulatsioon ja võimalus kasutada samu käske testimisel ja CI/CD-s.

## 2. Eesmärk ja Oodatav Tulemus
Pakkuda mugavad, värvilised ja interaktiivsed CLI käsud peaskriptis [`scripts/setup-all.sh`](../../scripts/setup-all.sh) ning modulaarne mootor [`scripts/internal/blueprint-info.sh`](../../scripts/internal/blueprint-info.sh):
- `--list-blueprints` / `-lb` / `-l` (Kuvab dünaamilise tabeli kõigist 13 mudelist, konteineritest ja otstarbest).
- `--show-blueprint <N>` / `-sb <N>` (Kuvab detailse mudeli ülevaate, pordid, APEX/ORDS seadistused ja RAM eelarve).
- `--search-blueprints <QUERY>` / `-search <QUERY>` (Otsib mudeleid märksõna järgi, nt `publisher`, `gvenzl`, `adb`).
- `--dry-run` (Võimaldab simuleerida nii toodangukäivitust `-b <N> --dry-run` kui ka automaatteste `-tb 1,3,7 --dry-run` ilma andmebaase käivitamata).
- `--list-test-reports` / `-ltr` (Kuvab kõigi 13 blueprinti testiraportite olekut kaustas `tests/reports/scenarios/`).

## 3. Tehniline Teostus
- **Loodud mootor:** [`scripts/internal/blueprint-info.sh`](../../scripts/internal/blueprint-info.sh) (100% dünaamiline konteinerite eraldaja `extract_blueprint_containers`, ASCII tabeli generaator ja dry-run simulaator).
- **Lõimitud peaskripti:** [`scripts/setup-all.sh`](../../scripts/setup-all.sh) CLI parameetrite parsimine ja pre-flight konteinerite kuvamine.
- **Ühiktest:** [`tests/unit/test-cli-blueprint-params.sh`](../../tests/unit/test-cli-blueprint-params.sh).

## 4. Verifitseerimine
- Kõik CLI lipud testitud (`-lb`, `-sb 3`, `--search publisher`, `-b 3 --dry-run`, `-tb 1,3 --dry-run`, `-ltr`).
- Ühiktest `test-cli-blueprint-params.sh` läbitud edukalt (PASS).
