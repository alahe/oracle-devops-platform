# Arhitektūras glosārijs un saīsinājumi

[ 🇬🇧 English ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/glossary.md) | [ 🇪🇪 Eesti ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/et/glossary.md) | [ 🇫🇮 Suomi ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/fi/glossary.md) | [ 🇸🇪 Svenska ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/sv/glossary.md) | **[ 🇱🇻 Latviešu ]** | [ 🇱🇹 Lietuvių ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lt/glossary.md)

> Visaptverošs saīsinājumu, tehnisko terminu un praktiskās izmantošanas reģistrs.

---

**A–Z Register:** [A](#a) • [B](#b) • [C](#c) • [D](#d) • [E](#e) • [F](#f) • [G](#g) • [H](#h) • [I](#i) • [J](#j) • [K](#k) • [L](#l) • [M](#m) • [N](#n) • [O](#o) • [P](#p) • [R](#r) • [S](#s) • [T](#t) • [U](#u) • [V](#v) • [W](#w) • [Y](#y)

---

## A

### `ADB` — Autonomous Database
- **Definīcija:** Oracle pilnībā pārvaldīts mākoņa datubāzes pakalpojums ar automatizētu uzturēšanu un mērogošanu.
- **Loma šajā projektā:** Hibrīda mākoņa migrācijas mērķis (BP 10 & 11) ar mTLS maku bez vietējā koda maiņas.
- **Oficiālā atsauce / Vikipēdija:** [Oracle Autonomous Database](https://www.oracle.com/autonomous-database/)
- **Saistītā dokumentācija un skripti:** [docs/remote-multicloud-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/remote-multicloud-setup-guide.md), [scripts/deploy-remote.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/deploy-remote.sh)

### `APEX` — Oracle Application Express
- **Definīcija:** Oracle low-code tīmekļa lietojumprogrammu izstrādes platforma tieši datubāzē.
- **Loma šajā projektā:** Galvenā saskarne Proxy DB (ports 8448/8088), pārvaldīta ar APEXlang DSL un Git eksportiem.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: Oracle APEX](https://en.wikipedia.org/wiki/Oracle_APEX)
- **Saistītā dokumentācija un skripti:** [docs/apex-devhub-test-plan.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/apex-devhub-test-plan.md), [scripts/internal/install-apex.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/install-apex.sh)

### `APFS` — Apple File System
- **Definīcija:** Noklusējuma failu sistēma macOS ar SSD optimizāciju un momentuzņēmumiem.
- **Loma šajā projektā:** macOS failu sistēma, kur tiek pārbaudīta savietojamība (Noteikums 13) ar Windows NTFS.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: Apple File System](https://en.wikipedia.org/wiki/Apple_File_System)
- **Saistītā dokumentācija un skripti:** [tests/unit/test-filename-portability.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/unit/test-filename-portability.sh)

### `API` — Application Programming Interface
- **Definīcija:** Protokolu kopa programmatūras komponentu savstarpējai saziņai.
- **Loma šajā projektā:** Pieejams lokāli caur ORDS un Dev Hub Bridge (/api/status, /api/tests) portā 8089.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: API](https://en.wikipedia.org/wiki/API)
- **Saistītā dokumentācija un skripti:** [docs/testing-framework-and-devhub.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/testing-framework-and-devhub.md), [scripts/internal/dev-hub-bridge.py](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/dev-hub-bridge.py)

## B

### `BIP` — Business Intelligence Publisher (Analytics Publisher)
- **Definīcija:** Uzņēmuma līmeņa pārskatu ģenerators augstas kvalitātes PDF, Excel un XML dokumentiem.
- **Loma šajā projektā:** Integrēts BP 4 un 11 (porti 9502/6083) automatizētai atskaišu ģenerēšanai.
- **Oficiālā atsauce / Vikipēdija:** [Oracle Analytics Publisher Docs](https://docs.oracle.com/middleware/12213/bip/)
- **Saistītā dokumentācija un skripti:** [docs/publisher-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/publisher-setup.md), [scripts/publisher/restart-publisher.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/publisher/restart-publisher.sh)

### `BP` — Blueprint (Architecture Blueprint)
- **Definīcija:** Iepriekš konfigurētas arhitektūras topoloģijas datubāzēm, starpprogrammatūrai un portiem.
- **Loma šajā projektā:** 12 kanooniskas vides (BP 0 līdz BP 11), kas palaižamas ar vienu komandu vai Dev Hub.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: Blueprint](https://en.wikipedia.org/wiki/Blueprint)
- **Saistītā dokumentācija un skripti:** [config/blueprints/README.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/config/blueprints/README.md), [scripts/deploy-blueprint.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/deploy-blueprint.sh)

## C

### `CA` — Certificate Authority
- **Definīcija:** Uzticama iestāde, kas izsniedz digitālos sertifikātus TLS šifrēšanai.
- **Loma šajā projektā:** Platforma ģenerē lokālo Root CA (certs/ca.crt), kas reģistrēts OS uzticamajā krātuvē.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: Certificate Authority](https://en.wikipedia.org/wiki/Certificate_authority)
- **Saistītā dokumentācija un skripti:** [docs/security.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/security.md), [scripts/certs/trust-local-cert-mac.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/certs/trust-local-cert-mac.sh)

### `CDB` — Container Database
- **Definīcija:** Oracle multitenant arhitektūras saknes datubāze, kas satur vienu vai vairākas PDB.
- **Loma šajā projektā:** Standarta CDB$ROOT 23ai Free DB konteinerā; tiek uzturēta automātiski.
- **Oficiālā atsauce / Vikipēdija:** [Oracle Multitenant Architecture](https://docs.oracle.com/en/database/oracle/oracle-database/23/cncpt/multitenant-architecture.html)
- **Saistītā dokumentācija un skripti:** [docs/db-profiles-and-topology.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/db-profiles-and-topology.md), [scripts/internal/init-db-instance.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/init-db-instance.sh)

### `CI/CD` — Continuous Integration / Continuous Deployment
- **Definīcija:** DevOps automatizēts process nepārtrauktai koda integrācijai, testēšanai un piegādei.
- **Loma šajā projektā:** Testēts lokāli bezsaistē ar './tests/test-local-ci.sh' un Dev Hub testēšanas cilnē ar 15 komplektiem.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: CI/CD](https://en.wikipedia.org/wiki/CI/CD)
- **Saistītā dokumentācija un skripti:** [tests/test-local-ci.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/test-local-ci.sh), [docs/devops-lifecycle-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/devops-lifecycle-guide.md)

### `CLI` — Command Line Interface
- **Definīcija:** Teksta komandrindas saskarne komandu izpildei un procesu automatizācijai.
- **Loma šajā projektā:** Vienota komandrindas rīku struktūra mapē scripts/ ar pilnu saskaņu ar Dev Hub GUI.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: Command-Line Interface](https://en.wikipedia.org/wiki/Command-line_interface)
- **Saistītā dokumentācija un skripti:** [scripts/README.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/README.md), [scripts/sqlcl.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/sqlcl.sh)

### `CPU` — Central Processing Unit
- **Definīcija:** Datora centrālais procesors, kas izpilda programmatūras instrukcijas.
- **Loma šajā projektā:** Uzraudzīts katram konteineram Dev Hub panelī; 23ai Free DB ir 2 vCPU ierobežojums.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: CPU](https://en.wikipedia.org/wiki/Central_processing_unit)
- **Saistītā dokumentācija un skripti:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

### `CRLF` — Carriage Return Line Feed (\r\n)
- **Definīcija:** Windows divu baitu rindiņas beigu formāts, kas rada kļūdas Unix čaulas skriptos.
- **Loma šajā projektā:** Stingri aizliegts čaulas skriptos (.sh) ar .gitattributes un pārbaudīts Windows testos.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: Newline (CRLF)](https://en.wikipedia.org/wiki/Newline)
- **Saistītā dokumentācija un skripti:** [.gitattributes](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/.gitattributes), [tests/unit/test-windows-enterprise-rules.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/unit/test-windows-enterprise-rules.sh)

## D

### `DBA` — Database Administrator
- **Definīcija:** Datubāzu administrators, kas atbild par uzturēšanu, drošību un rezerves kopijām.
- **Loma šajā projektā:** Platforma novērš aiztures, automatizējot visas ikdienas DBA procedūras.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: Database Administrator](https://en.wikipedia.org/wiki/Database_administrator)
- **Saistītā dokumentācija un skripti:** [scripts/internal/apply-profile-users.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/apply-profile-users.sh), [scripts/create-developer.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/create-developer.sh)

### `DR` — Disaster Recovery
- **Definīcija:** Procedūras datu un infrastruktūras ātrai atjaunošanai avāriju gadījumā.
- **Loma šajā projektā:** Realizēts ~15 sekundēs ar Golden Snapshot palīdzību, pilnībā atjaunojot vidi.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: Disaster Recovery](https://en.wikipedia.org/wiki/Disaster_recovery)
- **Saistītā dokumentācija un skripti:** [scripts/snapshots/README.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/snapshots/README.md), [scripts/snapshots/restore-golden-snapshots.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/snapshots/restore-golden-snapshots.sh)

### `DSL` — Domain-Specific Language
- **Definīcija:** Specializēta valoda konkrēta domēna uzdevumu risināšanai.
- **Loma šajā projektā:** APEXlang (.apx) deklaratīva valoda APEX lappušu un komponentu aprakstīšanai.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: Domain-Specific Language](https://en.wikipedia.org/wiki/Domain-specific_language)
- **Saistītā dokumentācija un skripti:** [docs/apex-devhub-test-plan.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/apex-devhub-test-plan.md)

## E

### `E2E` — End-to-End Testing
- **Definīcija:** Testēšanas metodoloģija, kas pārbauda visu procesu no lietotāja saskarnes līdz datubāzei.
- **Loma šajā projektā:** Ietver 6 komplektus Dev Hub testēšanas rīkā pilnīgai darbības pārbaudei.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: End-to-End Testing](https://en.wikipedia.org/wiki/Software_testing#End-to-end_testing)
- **Saistītā dokumentācija un skripti:** [tests/test-browser-login.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/test-browser-login.sh), [docs/devhub-browser-testing-plan.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/devhub-browser-testing-plan.md)

## F

### `FAT / NTFS` — File Allocation Table / New Technology File System
- **Definīcija:** Windows failu sistēmas ar aizliegtajām rakstzīmēm un rezervētajiem ierīču nosaukumiem.
- **Loma šajā projektā:** Tiek kontrolēts atbilstoši 13. noteikumam ar automatizētiem testiem.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: NTFS](https://en.wikipedia.org/wiki/NTFS)
- **Saistītā dokumentācija un skripti:** [tests/unit/test-filename-portability.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/unit/test-filename-portability.sh)

### `FMW` — Fusion Middleware
- **Definīcija:** Oracle starpprogrammatūras saime, ieskaitot WebLogic un Forms komponentes.
- **Loma šajā projektā:** Konteinerizēts Forms 14c un Publisher vidēm ar automātiskām pārbaudēm.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: Oracle Fusion Middleware](https://en.wikipedia.org/wiki/Oracle_Fusion_Middleware)
- **Saistītā dokumentācija un skripti:** [docs/forms-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/forms-setup.md), [docs/publisher-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/publisher-setup.md)

## G

### `GUI` — Graphical User Interface
- **Definīcija:** Grafiskā lietotāja saskarne ērtai vizuālai darbībai bez komandrindas.
- **Loma šajā projektā:** Nodrošina Dev Hub portā 8448 ar 1-klikšķa konteineru vadību un pārskatiem.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: GUI](https://en.wikipedia.org/wiki/Graphical_user_interface)
- **Saistītā dokumentācija un skripti:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html), [scripts/internal/generate_dev_hub.py](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/generate_dev_hub.py)

## H

### `HTTP / HTTPS` — Hypertext Transfer Protocol (Secure)
- **Definīcija:** Tīmekļa datu pārraides protokols, kas HTTPS versijā ir šifrēts ar TLS.
- **Loma šajā projektā:** Visi platformas tīmekļa pakalpojumi darbojas šifrēti bez brīdinājumiem pārlūkā.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: HTTPS](https://en.wikipedia.org/wiki/HTTPS)
- **Saistītā dokumentācija un skripti:** [scripts/check-urls.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-urls.sh)

## I

### `i18n` — Internationalization
- **Definīcija:** Programmatūras pielāgošana vairākām valodām un reģioniem.
- **Loma šajā projektā:** Noteikuma 9 prasība: 100% simetrija 6 valodās visā platformas dokumentācijā.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: Internationalization (i18n)](https://en.wikipedia.org/wiki/Internationalization_and_localization)
- **Saistītā dokumentācija un skripti:** [tests/unit/test-i18n-translations.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/unit/test-i18n-translations.sh), [scripts/internal/i18n.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/i18n.sh)

### `IDE` — Integrated Development Environment
- **Definīcija:** Integrēta izstrādes vide koda rakstīšanai, atkļūdošanai un versiju pārvaldībai.
- **Loma šajā projektā:** Atbalstīts lokāli VS Code un pārlūkā ar Web-IDE (BP 8, ports 8090).
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: IDE](https://en.wikipedia.org/wiki/Integrated_development_environment)
- **Saistītā dokumentācija un skripti:** [docker/web-ide/README.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docker/web-ide/README.md), [scripts/register-connections.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/register-connections.sh)

## J

### `JIT` — Just-In-Time (Decryption / Compilation)
- **Definīcija:** Modelis, kur akreditācijas dati tiek atšifrēti operatīvajā atmiņā tieši izpildes brīdī.
- **Loma šajā projektā:** Zero-Trust 5. noteikuma pamats: paroles tiek atšifrētas atmiņā un dzēstas pēc izpildes.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: Just-In-Time (JIT)](https://en.wikipedia.org/wiki/Just-in-time_compilation)
- **Saistītā dokumentācija un skripti:** [scripts/get-password.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/get-password.sh), [docs/security.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/security.md)

### `JSON` — JavaScript Object Notation
- **Definīcija:** Viegls teksta datu apmaiņas formāts lietojumprogrammām un API.
- **Loma šajā projektā:** Tiek izmantots veiktspējas datos, Dev Hub API un ģenerētajā HTML failā.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: JSON](https://en.wikipedia.org/wiki/JSON)
- **Saistītā dokumentācija un skripti:** [metrics/setup_benchmarks.json](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/metrics/setup_benchmarks.json)

## K

### `KPI` — Key Performance Indicator
- **Definīcija:** Izmērāms rādītājs sistēmas efektivitātes un mērķu sasniegšanas novērtēšanai.
- **Loma šajā projektā:** Attēlots Dev Hub pārskatu kartītēs (-85% DĪKSTĀVES, 1-KLIKŠĶA STARTS, 0€ LICENCES).
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: Key Performance Indicator](https://en.wikipedia.org/wiki/Performance_indicator)
- **Saistītā dokumentācija un skripti:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

## L

### `LF` — Line Feed (\n)
- **Definīcija:** Unix/Linux standarta rindiņas beigu rakstzīme, kas nepieciešama POSIX interpretatoriem.
- **Loma šajā projektā:** Obligāts atbilstoši 14. noteikumam visos repozitorija skriptu un konfigurācijas failos.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: Newline (LF)](https://en.wikipedia.org/wiki/Newline)
- **Saistītā dokumentācija un skripti:** [.gitattributes](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/.gitattributes)

### `LIS` — Laboratory Information System
- **Definīcija:** Laboratorijas informācijas sistēma paraugu un analīžu rezultātu pārvaldībai.
- **Loma šajā projektā:** Attēlots Blueprint 3 ar atsevišķām proxy, alise un lis datubāzēm.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: LIS / LIMS](https://en.wikipedia.org/wiki/Laboratory_information_management_system)
- **Saistītā dokumentācija un skripti:** [config/blueprints/.env.bp3-multi-db-lis](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/config/blueprints/.env.bp3-multi-db-lis), [config/profiles/databases/db-lis.yaml](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/config/profiles/databases/db-lis.yaml)

## M

### `mTLS` — Mutual Transport Layer Security
- **Definīcija:** Abpusēja kriptogrāfiskā autentifikācija, kur klients un serveris pārbauda viens otra sertifikātus.
- **Loma šajā projektā:** Nodrošina drošu savienojumu ar OCI Autonomous Database mākonī caur šifrētu maku.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: Mutual TLS](https://en.wikipedia.org/wiki/Mutual_authentication#mTLS)
- **Saistītā dokumentācija un skripti:** [docs/remote-multicloud-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/remote-multicloud-setup-guide.md)

## N

### `noVNC` — HTML5 VNC Client (WebSocket)
- **Definīcija:** Pārlūkprogrammas HTML5 VNC klients attālai grafisko darbvirsmu izmantošanai.
- **Loma šajā projektā:** Nodrošina tūlītēju piekļuvi Forms Builder (ports 6082) un Publisher Designer (6083) tieši pārlūkā.
- **Oficiālā atsauce / Vikipēdija:** [Official: noVNC](https://novnc.com/)
- **Saistītā dokumentācija un skripti:** [docs/forms-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/forms-setup.md), [docs/publisher-template-builder-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/publisher-template-builder-guide.md)

## O

### `OCI` — Oracle Cloud Infrastructure
- **Definīcija:** Oracle uzņēmuma līmeņa mākoņa infrastruktūra skaitļošanai un datubāzēm.
- **Loma šajā projektā:** Mērķa mākonis automatizētai izvietošanai un hibrīdajiem blueprintiem (BP 10 un 11).
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: Oracle Cloud Infrastructure](https://en.wikipedia.org/wiki/Oracle_Cloud)
- **Saistītā dokumentācija un skripti:** [scripts/deploy-remote.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/deploy-remote.sh), [docs/remote-multicloud-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/remote-multicloud-setup-guide.md)

### `OCR` — Oracle Container Registry
- **Definīcija:** Oracle oficiālais konteineru reģistrs pārbaudītiem datubāzu un starpprogrammatūras attēliem.
- **Loma šajā projektā:** Avots oficiālajiem 23ai Free DB attēliem; atbalsta korporatīvos Artifactory spoguļus.
- **Oficiālā atsauce / Vikipēdija:** [Official: Oracle Container Registry](https://container-registry.oracle.com/)
- **Saistītā dokumentācija un skripti:** [docs/enterprise-onboarding-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/enterprise-onboarding-guide.md)

### `OPatch` — Oracle Interim Patching Tool
- **Definīcija:** Oracle standarta rīks drošības labojumu uzstādīšanai un pārvaldībai.
- **Loma šajā projektā:** Automatizēts Publisher skriptos drošības ielāpu uzstādīšanai.
- **Oficiālā atsauce / Vikipēdija:** [Oracle Database Patching & Upgrade](https://docs.oracle.com/en/database/oracle/oracle-database/19/install-and-upgrade.html)
- **Saistītā dokumentācija un skripti:** [docs/publisher-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/publisher-setup.md)

### `ORDS` — Oracle REST Data Services
- **Definīcija:** Lietojumprogrammu servera tilts, kas pārvērš SQL/PLSQL par REST API un apkalpo APEX.
- **Loma šajā projektā:** Galvenā API vārteja portā 8088/8448; darbojas atsevišķi, lai taupītu datubāzes atmiņu.
- **Oficiālā atsauce / Vikipēdija:** [Oracle REST Data Services](https://www.oracle.com/database/technologies/appdev/rest.html)
- **Saistītā dokumentācija un skripti:** [docs/ords-profiles-lifecycle.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/ords-profiles-lifecycle.md), [scripts/internal/install-ords-standalone.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/install-ords-standalone.sh)

## P

### `PDB` — Pluggable Database
- **Definīcija:** Autonoma shēmu un objektu kopa multitenant arhitektūrā, kas darbojas kā atsevišķa datubāze.
- **Loma šajā projektā:** Izolē lietojumu datus: FREEPDB1 (APEX), ALISEPDB (bizness), LIS_PDB un BIP_PDB.
- **Oficiālā atsauce / Vikipēdija:** [Oracle Pluggable Database (PDB)](https://docs.oracle.com/en/database/oracle/oracle-database/23/cncpt/multitenant-architecture.html)
- **Saistītā dokumentācija un skripti:** [docs/db-profiles-and-topology.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/db-profiles-and-topology.md), [scripts/internal/resolve-topology.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/resolve-topology.sh)

### `PID` — Process Identifier
- **Definīcija:** Unikāls identifikators, ko operētājsistēma piešķir katram aktīvajam procesam.
- **Loma šajā projektā:** Tiek uzraudzīts asinhronu uzdevumu vadībai un fonu procesiem (12. noteikums).
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: Process Identifier (PID)](https://en.wikipedia.org/wiki/Process_identifier)
- **Saistītā dokumentācija un skripti:** [scripts/internal/dev-hub-bridge.py](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/dev-hub-bridge.py)

## R

### `RAM` — Random Access Memory
- **Definīcija:** Operatīvā atmiņa aktīvām programmām un datubāzes kešatmiņām.
- **Loma šajā projektā:** 23ai Free DB ir 2GB RAM limits; sadalītā arhitektūra novērš atmiņas pārslodzi.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: RAM](https://en.wikipedia.org/wiki/Random-access_memory)
- **Saistītā dokumentācija un skripti:** [docs/enterprise-distributed-architecture.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/enterprise-distributed-architecture.md)

### `RCU` — Repository Creation Utility
- **Definīcija:** Oracle rīks Fusion Middleware nepieciešamo datubāzes shēmu izveidei.
- **Loma šajā projektā:** Automatizēts konteineros Forms un Publisher shēmu sagatavošanai.
- **Oficiālā atsauce / Vikipēdija:** [Oracle Repository Creation Utility Docs](https://docs.oracle.com/en/middleware/fusion-middleware/12.2.1.4/rcuug/)
- **Saistītā dokumentācija un skripti:** [docs/forms-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/forms-setup.md)

### `REST` — Representational State Transfer
- **Definīcija:** Stāvokli nesaglabājoša tīmekļa arhitektūra mērogojamu API izveidei caur HTTP.
- **Loma šajā projektā:** Realizēts ar ORDS AutoREST palīdzību ārējiem pakalpojumiem un mikroservisiem.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: REST](https://en.wikipedia.org/wiki/REST)
- **Saistītā dokumentācija un skripti:** [docs/ords-profiles-lifecycle.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/ords-profiles-lifecycle.md)

### `ROI` — Return on Investment
- **Definīcija:** Finanšu rādītājs investīciju atdeves un izmaksu ietaupījuma novērtēšanai.
- **Loma šajā projektā:** Izcelts 5. slaidā: ietaupa līdz 40% izstrādes licenču izmaksu un novērš dīkstāves mākoņa rēķinus.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: Return on Investment](https://en.wikipedia.org/wiki/Return_on_investment)
- **Saistītā dokumentācija un skripti:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

## S

### `SDW` — SQL Developer Web (Database Actions)
- **Definīcija:** Pārlūka saskarne ORDS ietvaros SQL vaicājumiem, REST pakalpojumiem un uzraudzībai.
- **Loma šajā projektā:** Pieejams ar 1 klikšķi no Dev Hub ar automātisku akreditācijas datu sagatavošanu.
- **Oficiālā atsauce / Vikipēdija:** [Oracle SQL Developer Web](https://docs.oracle.com/en/database/oracle/sql-developer-web/)
- **Saistītā dokumentācija un skripti:** [docs/quick-login-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/quick-login-guide.md)

### `SEPS` — Secure External Password Store (Oracle Wallet)
- **Definīcija:** Oracle šifrēts maks (cwallet.sso) drošai bezparoļu autentifikācijai.
- **Loma šajā projektā:** Obligāts atbilstoši 5. noteikumam: neviena parole atklātā tekstā; visi skripti izmanto SEPS maku.
- **Oficiālā atsauce / Vikipēdija:** [Oracle Database Security Guide](https://docs.oracle.com/en/database/oracle/oracle-database/19/dbseg/)
- **Saistītā dokumentācija un skripti:** [docs/security.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/security.md), [scripts/get-password.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/get-password.sh), [scripts/check-wallet.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-wallet.sh)

### `SGA / PGA` — System Global Area / Program Global Area
- **Definīcija:** Oracle atmiņas struktūras: SGA ir koplietojama atmiņa, PGA ir procesam piesaistīta atmiņa.
- **Loma šajā projektā:** Dinamiski noregulēts, lai iekļautos Free DB 2GB konteinera robežās.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: Oracle Database Memory Architecture](https://en.wikipedia.org/wiki/Oracle_Database#Memory_structures)
- **Saistītā dokumentācija un skripti:** [scripts/internal/init-db-instance.sql](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/init-db-instance.sql)

### `SPA` — Single Page Application
- **Definīcija:** Vienas lapas tīmekļa lietotne, kas atjaunina saturu dinamiski bez visas lapas pārlādes.
- **Loma šajā projektā:** Dev Hub arhitektūra: pilnībā autonoma, bez CDN atkarībām, tūlītēja ciļņu pārslēgšana.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: Single-Page Application](https://en.wikipedia.org/wiki/Single-page_application)
- **Saistītā dokumentācija un skripti:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

### `SPFILE` — Server Parameter File
- **Definīcija:** Oracle binārais parametru fails, kas saglabā konfigurācijas izmaiņas pēc restartēšanas.
- **Loma šajā projektā:** Konfigurēts konteinerā, lai nodrošinātu atmiņas iestatījumus un APEX savienojumus.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: Oracle Initialization Parameters](https://en.wikipedia.org/wiki/Oracle_Database#Initialization_parameters)
- **Saistītā dokumentācija un skripti:** [scripts/internal/init-db-instance.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/init-db-instance.sh)

### `SQL` — Structured Query Language
- **Definīcija:** Standarta vaicājumu valoda relāciju datubāzu datu pārvaldībai.
- **Loma šajā projektā:** Visas shēmas, lietotāji un atļaujas tiek izveidotas ar SQL skriptiem mapē scripts/internal/.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: SQL](https://en.wikipedia.org/wiki/SQL)
- **Saistītā dokumentācija un skripti:** [scripts/internal/init-db-instance.sql](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/init-db-instance.sql)

### `SQLcl` — Oracle SQL Developer Command Line
- **Definīcija:** Mūsdienīgs komandrindas rīks Oracle datubāzei ar Liquibase un Git integrāciju.
- **Loma šajā projektā:** Obligāts standarts saskaņā ar 6. noteikumu; prioritāri izmanto VS Code SQLcl bināro failu.
- **Oficiālā atsauce / Vikipēdija:** [Oracle SQLcl Official](https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/)
- **Saistītā dokumentācija un skripti:** [scripts/sqlcl.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/sqlcl.sh), [docs/quick-login-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/quick-login-guide.md)

### `SSO` — Single Sign-On
- **Definīcija:** Vienotā pieteikšanās, kas ļauj piekļūt vairākām sistēmām ar vienu autentifikāciju.
- **Loma šajā projektā:** Integrēts korporatīvajās vidēs ar Azure Entra-ID un APEX.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: Single Sign-On](https://en.wikipedia.org/wiki/Single_sign-on)
- **Saistītā dokumentācija un skripti:** [tests/test-browser-login.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/test-browser-login.sh)

## T

### `TCO` — Total Cost of Ownership
- **Definīcija:** Kopējās īpašumtiesību izmaksas, ieskaitot licences, uzturēšanu un dīkstāves.
- **Loma šajā projektā:** Būtiski samazināts ar Free DB: 0€ licenču maksas izstrādei un iekšējiem rīkiem.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: Total Cost of Ownership](https://en.wikipedia.org/wiki/Total_cost_of_ownership)
- **Saistītā dokumentācija un skripti:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

### `TLS` — Transport Layer Security
- **Definīcija:** Kriptogrāfisks protokols drošai un šifrētai datu pārraidei tīklā.
- **Loma šajā projektā:** Ģenerēts lokāli HTTPS protokolam portā 8448 un ORDS šifrēšanai.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: Transport Layer Security](https://en.wikipedia.org/wiki/Transport_Layer_Security)
- **Saistītā dokumentācija un skripti:** [docs/security.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/security.md), [scripts/internal/generate-local-certs.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/generate-local-certs.sh)

### `TNS` — Transparent Network Substrate
- **Definīcija:** Oracle tīkla tehnoloģija klientu savienošanai ar datubāzēm.
- **Loma šajā projektā:** Automātiski konfigurēts tnsnames.ora failā un eksportēts ar TNS_ADMIN.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: Transparent Network Substrate](https://en.wikipedia.org/wiki/Transparent_Network_Substrate)
- **Saistītā dokumentācija un skripti:** [tnsnames/tnsnames.ora](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tnsnames/tnsnames.ora), [scripts/register-connections.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/register-connections.sh)

## U

### `UAC` — User Account Control
- **Definīcija:** Windows drošības mehānisms, kas pieprasa administratora atļauju sistēmas izmaiņām.
- **Loma šajā projektā:** Apiets atbilstoši 14. noteikumam: sertifikāti tiek pievienoti lietotāja līmenī bez administratora tiesībām.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: User Account Control](https://en.wikipedia.org/wiki/User_Account_Control)
- **Saistītā dokumentācija un skripti:** [scripts/certs/trust-local-cert.cmd](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/certs/trust-local-cert.cmd), [docs/windows-enterprise-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/windows-enterprise-setup-guide.md)

### `UI / UX` — User Interface / User Experience
- **Definīcija:** Lietotāja saskarne un pieredze: vizuālais noformējums, navigācija un lietošanas ērtums.
- **Loma šajā projektā:** Pilnveidots Dev Hub ar modernu tumšo tēmu, ātrajiem rīkiem un reāllaika žurnāliem.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: UI/UX Design](https://en.wikipedia.org/wiki/User_interface_design)
- **Saistītā dokumentācija un skripti:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

### `URI / URL` — Uniform Resource Identifier / Locator
- **Definīcija:** Standarta tīmekļa adrese resursu atrašanai un identificēšanai tīklā.
- **Loma šajā projektā:** Pārbaudīts starta laikā ar scripts/check-urls.sh, pārliecinoties par HTTP 200/302 atbildēm.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: URI / URL](https://en.wikipedia.org/wiki/Uniform_Resource_Identifier)
- **Saistītā dokumentācija un skripti:** [scripts/check-urls.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-urls.sh)

## V

### `VPN` — Virtual Private Network
- **Definīcija:** Šifrēts tīkla tunelis drošai piekļuvei korporatīvajam tīklam no ārpuses.
- **Loma šajā projektā:** Aizsargāts Windows WSL2 ar 'dnsTunneling=true' parametru, novēršot DNS kļūmes.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: Virtual Private Network](https://en.wikipedia.org/wiki/Virtual_private_network)
- **Saistītā dokumentācija un skripti:** [docs/windows-enterprise-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/windows-enterprise-setup-guide.md)

### `VS Code` — Visual Studio Code
- **Definīcija:** Paplašināms koda redaktors no Microsoft ar plašu spraudņu klāstu.
- **Loma šajā projektā:** Galvenais koda redaktors: automātiski reģistrē savienojumus ar Oracle paplašinājumu.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: Visual Studio Code](https://en.wikipedia.org/wiki/Visual_Studio_Code)
- **Saistītā dokumentācija un skripti:** [scripts/register-connections.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/register-connections.sh)

## W

### `WSL / WSL2` — Windows Subsystem for Linux (Version 2)
- **Definīcija:** Windows iebūvētā Linux apakšsistēma ar īstu Linux kodolu.
- **Loma šajā projektā:** 14. noteikuma prasība: videi jāatrodas natīvajā ext4 failu sistēmā (~/), nevis /mnt/c/.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: Windows Subsystem for Linux](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux)
- **Saistītā dokumentācija un skripti:** [docs/windows-enterprise-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/windows-enterprise-setup-guide.md), [setup.cmd](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/setup.cmd)

## Y

### `YAML` — YAML Ain't Markup Language
- **Definīcija:** Cilvēkam viegli lasāms datu formāts konfigurācijas failiem un deklarācijām.
- **Loma šajā projektā:** 11. noteikuma prasība kā vienīgais patiesības avots datubāzu profiliem un lietotājiem.
- **Oficiālā atsauce / Vikipēdija:** [Wikipedia: YAML](https://en.wikipedia.org/wiki/YAML)
- **Saistītā dokumentācija un skripti:** [config/profiles/databases/db-oracle.yaml](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/config/profiles/databases/db-oracle.yaml)

