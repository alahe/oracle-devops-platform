# Architektūros žodynas ir akronimai

[ 🇬🇧 English ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/glossary.md) | [ 🇪🇪 Eesti ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/et/glossary.md) | [ 🇫🇮 Suomi ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/fi/glossary.md) | [ 🇸🇪 Svenska ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/sv/glossary.md) | [ 🇱🇻 Latviešu ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lv/glossary.md) | **[ 🇱🇹 Lietuvių ]**

> Išsamus akronimų, techninių apibrėžimų ir praktinio pritaikymo projekte sąvadas.

---

**A–Z Register:** [A](#a) • [B](#b) • [C](#c) • [D](#d) • [E](#e) • [F](#f) • [G](#g) • [H](#h) • [I](#i) • [J](#j) • [K](#k) • [L](#l) • [M](#m) • [N](#n) • [O](#o) • [P](#p) • [R](#r) • [S](#s) • [T](#t) • [U](#u) • [V](#v) • [W](#w) • [Y](#y)

---

## A

### `ADB` — Autonomous Database
- **Apibrėžimas:** Visiškai valdoma Oracle debesų duomenų bazė su automatizuotu atnaujinimu ir mastelio keitimu.
- **Vaidmuo šiame projekte:** Hibridinės debesų migracijos tikslas (BP 10 ir 11) per mTLS piniginę nekeičiant vietinio kodo.
- **Oficiali nuoroda / Vikipedija:** [Oracle Autonomous Database](https://www.oracle.com/autonomous-database/)
- **Susijusi dokumentacija ir skriptai:** [docs/remote-multicloud-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/remote-multicloud-setup-guide.md), [scripts/deploy-remote.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/deploy-remote.sh)

### `APEX` — Oracle Application Express
- **Apibrėžimas:** Oracle mažo kodo (low-code) žiniatinklio programų kūrimo platforma duomenų bazėje.
- **Vaidmuo šiame projekte:** Pagrindinė sąsaja Proxy DB (prievadas 8448/8088), valdoma per APEXlang DSL ir Git eksportą.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: Oracle APEX](https://en.wikipedia.org/wiki/Oracle_APEX)
- **Susijusi dokumentacija ir skriptai:** [docs/apex-devhub-test-plan.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/apex-devhub-test-plan.md), [scripts/internal/install-apex.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/install-apex.sh)

### `APFS` — Apple File System
- **Apibrėžimas:** Numatytoji macOS failų sistema, optimizuota SSD kaupikliams ir momentinėms kopijoms.
- **Vaidmuo šiame projekte:** macOS failų sistema, kurioje tikrinamas suderinamumas (13 taisyklė) su Windows NTFS.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: Apple File System](https://en.wikipedia.org/wiki/Apple_File_System)
- **Susijusi dokumentacija ir skriptai:** [tests/unit/test-filename-portability.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/unit/test-filename-portability.sh)

### `API` — Application Programming Interface
- **Apibrėžimas:** Sąsaja, leidžianti skirtingoms programinėms sistemoms keistis duomenimis.
- **Vaidmuo šiame projekte:** Pasiekiamas lokaliai per ORDS ir Dev Hub Bridge (/api/status, /api/tests) prievade 8089.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: API](https://en.wikipedia.org/wiki/API)
- **Susijusi dokumentacija ir skriptai:** [docs/testing-framework-and-devhub.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/testing-framework-and-devhub.md), [scripts/internal/dev-hub-bridge.py](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/dev-hub-bridge.py)

## B

### `BIP` — Business Intelligence Publisher (Analytics Publisher)
- **Apibrėžimas:** Įmonės lygio ataskaitų variklis tiksliems PDF, Excel ir XML dokumentams kurti.
- **Vaidmuo šiame projekte:** Integruota BP 4 ir 11 (prievadai 9502/6083) automatizuotam dokumentų generavimui.
- **Oficiali nuoroda / Vikipedija:** [Oracle Analytics Publisher Docs](https://docs.oracle.com/middleware/12213/bip/)
- **Susijusi dokumentacija ir skriptai:** [docs/publisher-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/publisher-setup.md), [scripts/publisher/restart-publisher.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/publisher/restart-publisher.sh)

### `BP` — Blueprint (Architecture Blueprint)
- **Apibrėžimas:** Iš anksto sukonfigūruotos architektūros topologijos duomenų bazėms, tarpinei įrangai ir prievadams.
- **Vaidmuo šiame projekte:** 12 kanoninių aplinkų (BP 0 iki BP 11), paleidžiamų per komandą arba Dev Hub.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: Blueprint](https://en.wikipedia.org/wiki/Blueprint)
- **Susijusi dokumentacija ir skriptai:** [config/blueprints/README.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/config/blueprints/README.md), [scripts/deploy-blueprint.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/deploy-blueprint.sh)

## C

### `CA` — Certificate Authority
- **Apibrėžimas:** Patikimas centras, išduodantis skaitmeninius sertifikatus TLS šifravimui.
- **Vaidmuo šiame projekte:** Platforma sukuria vietinį Root CA (certs/ca.crt), registruojamą OS patikimųjų sertifikatų saugykloje.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: Certificate Authority](https://en.wikipedia.org/wiki/Certificate_authority)
- **Susijusi dokumentacija ir skriptai:** [docs/security.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/security.md), [scripts/certs/trust-local-cert-mac.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/certs/trust-local-cert-mac.sh)

### `CDB` — Container Database
- **Apibrėžimas:** Oracle kelių nuomininkų architektūros šakninė DB, kurioje talpinamos viena ar kelios PDB.
- **Vaidmuo šiame projekte:** Standartinė CDB$ROOT 23ai Free DB konteineryje; valdoma automatiškai.
- **Oficiali nuoroda / Vikipedija:** [Oracle Multitenant Architecture](https://docs.oracle.com/en/database/oracle/oracle-database/23/cncpt/multitenant-architecture.html)
- **Susijusi dokumentacija ir skriptai:** [docs/db-profiles-and-topology.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/db-profiles-and-topology.md), [scripts/internal/init-db-instance.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/init-db-instance.sh)

### `CI/CD` — Continuous Integration / Continuous Deployment
- **Apibrėžimas:** DevOps automatizuota eiga nuolatiniam kodo integravimui, testavimui ir diegimui.
- **Vaidmuo šiame projekte:** Testuojama lokaliai be interneto per './tests/test-local-ci.sh' ir Dev Hub testavimo skiltyje su 15 rinkinių.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: CI/CD](https://en.wikipedia.org/wiki/CI/CD)
- **Susijusi dokumentacija ir skriptai:** [tests/test-local-ci.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/test-local-ci.sh), [docs/devops-lifecycle-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/devops-lifecycle-guide.md)

### `CLI` — Command Line Interface
- **Apibrėžimas:** Tekstinė komandinė sąsaja komandų vykdymui ir procesų automatizavimui.
- **Vaidmuo šiame projekte:** Vieninga komandinės eilutės struktūra aplanke scripts/ su visišku atitikimu Dev Hub GUI.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: Command-Line Interface](https://en.wikipedia.org/wiki/Command-line_interface)
- **Susijusi dokumentacija ir skriptai:** [scripts/README.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/README.md), [scripts/sqlcl.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/sqlcl.sh)

### `CPU` — Central Processing Unit
- **Apibrėžimas:** Pagrindinis kompiuterio procesorius, vykdantis programų instrukcijas.
- **Vaidmuo šiame projekte:** Stebimas kiekvienam konteineriui Dev Hub; 23ai Free DB veikia 2 vCPU ribose.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: CPU](https://en.wikipedia.org/wiki/Central_processing_unit)
- **Susijusi dokumentacija ir skriptai:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

### `CRLF` — Carriage Return Line Feed (\r\n)
- **Apibrėžimas:** Windows dviejų baitų eilutės pabaigos formatas, sukeliantis klaidas Unix skriptuose.
- **Vaidmuo šiame projekte:** Griežtai draudžiamas skriptuose (.sh) per .gitattributes ir tikrinamas Windows testais.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: Newline (CRLF)](https://en.wikipedia.org/wiki/Newline)
- **Susijusi dokumentacija ir skriptai:** [.gitattributes](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/.gitattributes), [tests/unit/test-windows-enterprise-rules.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/unit/test-windows-enterprise-rules.sh)

## D

### `DBA` — Database Administrator
- **Apibrėžimas:** Duomenų bazių administratorius, atsakingas už diegimą, saugumą ir atkūrimą.
- **Vaidmuo šiame projekte:** Platforma panaikina kliūtis, automatizuodama 100% kasdienių DBA procedūrų.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: Database Administrator](https://en.wikipedia.org/wiki/Database_administrator)
- **Susijusi dokumentacija ir skriptai:** [scripts/internal/apply-profile-users.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/apply-profile-users.sh), [scripts/create-developer.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/create-developer.sh)

### `DR` — Disaster Recovery
- **Apibrėžimas:** Procesai ir strategijos greitam duomenų ir sistemų atkūrimui po gedimų.
- **Vaidmuo šiame projekte:** Pasiekiama per ~15 sekundžių su Golden Snapshot pagalba, atkuriant aplinką be bilietų.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: Disaster Recovery](https://en.wikipedia.org/wiki/Disaster_recovery)
- **Susijusi dokumentacija ir skriptai:** [scripts/snapshots/README.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/snapshots/README.md), [scripts/snapshots/restore-golden-snapshots.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/snapshots/restore-golden-snapshots.sh)

### `DSL` — Domain-Specific Language
- **Apibrėžimas:** Specializuota kalba, skirta konkrečios srities uždaviniams aprašyti.
- **Vaidmuo šiame projekte:** APEXlang (.apx) deklaratyvi kalba APEX puslapiams ir komponentams aprašyti.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: Domain-Specific Language](https://en.wikipedia.org/wiki/Domain-specific_language)
- **Susijusi dokumentacija ir skriptai:** [docs/apex-devhub-test-plan.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/apex-devhub-test-plan.md)

## E

### `E2E` — End-to-End Testing
- **Apibrėžimas:** Testavimo metodika, tikrinanti visą grandinę nuo vartotojo sąsajos iki duomenų bazės.
- **Vaidmuo šiame projekte:** Apima 6 rinkinius Dev Hub testavimo centre visos sistemos patikrinimui.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: End-to-End Testing](https://en.wikipedia.org/wiki/Software_testing#End-to-end_testing)
- **Susijusi dokumentacija ir skriptai:** [tests/test-browser-login.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/test-browser-login.sh), [docs/devhub-browser-testing-plan.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/devhub-browser-testing-plan.md)

## F

### `FAT / NTFS` — File Allocation Table / New Technology File System
- **Apibrėžimas:** Windows failų sistemos su draudžiamais simboliais ir rezervuotais įrenginių pavadinimais.
- **Vaidmuo šiame projekte:** Prižiūrima pagal 13 taisyklę su automatizuotais failų suderinamumo testais.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: NTFS](https://en.wikipedia.org/wiki/NTFS)
- **Susijusi dokumentacija ir skriptai:** [tests/unit/test-filename-portability.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/unit/test-filename-portability.sh)

### `FMW` — Fusion Middleware
- **Apibrėžimas:** Oracle tarpinės programinės įrangos paketas, apimantis WebLogic ir Forms.
- **Vaidmuo šiame projekte:** Konteinerizuota Forms 14c ir Publisher aplinkoms su automatinėmis patikromis.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: Oracle Fusion Middleware](https://en.wikipedia.org/wiki/Oracle_Fusion_Middleware)
- **Susijusi dokumentacija ir skriptai:** [docs/forms-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/forms-setup.md), [docs/publisher-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/publisher-setup.md)

## G

### `GUI` — Graphical User Interface
- **Apibrėžimas:** Grafinė vartotojo sąsaja patogiam darbui per mygtukus ir langus.
- **Vaidmuo šiame projekte:** Pateikiama per Dev Hub prievade 8448 su 1 paspaudimo konteinerių valdymu.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: GUI](https://en.wikipedia.org/wiki/Graphical_user_interface)
- **Susijusi dokumentacija ir skriptai:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html), [scripts/internal/generate_dev_hub.py](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/generate_dev_hub.py)

## H

### `HTTP / HTTPS` — Hypertext Transfer Protocol (Secure)
- **Apibrėžimas:** Pagrindinis saityno protokolas, HTTPS versijoje apsaugotas TLS šifravimu.
- **Vaidmuo šiame projekte:** Visos platformos žiniatinklio paslaugos veikia saugiai be naršyklės įspėjimų.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: HTTPS](https://en.wikipedia.org/wiki/HTTPS)
- **Susijusi dokumentacija ir skriptai:** [scripts/check-urls.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-urls.sh)

## I

### `i18n` — Internationalization
- **Apibrėžimas:** Programinės įrangos pritaikymas kelioms kalboms be kodo modifikacijų.
- **Vaidmuo šiame projekte:** Pagal 9 taisyklę užtikrinama 100% simetrija 6 kalbomis visoje platformoje.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: Internationalization (i18n)](https://en.wikipedia.org/wiki/Internationalization_and_localization)
- **Susijusi dokumentacija ir skriptai:** [tests/unit/test-i18n-translations.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/unit/test-i18n-translations.sh), [scripts/internal/i18n.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/i18n.sh)

### `IDE` — Integrated Development Environment
- **Apibrėžimas:** Integruota kūrimo aplinka kodo redagavimui, derinimui ir versijų valdymui.
- **Vaidmuo šiame projekte:** Palaikoma lokaliai per VS Code ir naršyklėje per Web-IDE (BP 8, prievadas 8090).
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: IDE](https://en.wikipedia.org/wiki/Integrated_development_environment)
- **Susijusi dokumentacija ir skriptai:** [docker/web-ide/README.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docker/web-ide/README.md), [scripts/register-connections.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/register-connections.sh)

## J

### `JIT` — Just-In-Time (Decryption / Compilation)
- **Apibrėžimas:** Modelis, kai prisijungimo duomenys iššifruojami atmintyje tik vykdymo metu be disko.
- **Vaidmuo šiame projekte:** Zero-Trust 5 taisyklės pagrindas: slaptažodžiai nuskaitomi į atmintį ir sunaikinami iškart po vykdymo.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: Just-In-Time (JIT)](https://en.wikipedia.org/wiki/Just-in-time_compilation)
- **Susijusi dokumentacija ir skriptai:** [scripts/get-password.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/get-password.sh), [docs/security.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/security.md)

### `JSON` — JavaScript Object Notation
- **Apibrėžimas:** Lengvas tekstinis duomenų mainų formatas saityno paslaugoms ir API.
- **Vaidmuo šiame projekte:** Naudojamas našumo metrikoje, Dev Hub API ir sukompiliuotame HTML faile.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: JSON](https://en.wikipedia.org/wiki/JSON)
- **Susijusi dokumentacija ir skriptai:** [metrics/setup_benchmarks.json](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/metrics/setup_benchmarks.json)

## K

### `KPI` — Key Performance Indicator
- **Apibrėžimas:** Išmatuojamas rodiklis platformos efektyvumui ir tikslų pasiekimui vertinti.
- **Vaidmuo šiame projekte:** Rodoma Dev Hub skaidrių kortelėse (-85% PRASTOVŲ, 1 PASPAUDIMO STARTAS, 0€ LICENCIJŲ).
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: Key Performance Indicator](https://en.wikipedia.org/wiki/Performance_indicator)
- **Susijusi dokumentacija ir skriptai:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

## L

### `LF` — Line Feed (\n)
- **Apibrėžimas:** Unix/Linux standartinis vieno baito eilutės pabaigos simbolis, būtinas POSIX skriptams.
- **Vaidmuo šiame projekte:** Privalomas pagal 14 taisyklę visiems skriptų ir konfigūracijų failams per .gitattributes.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: Newline (LF)](https://en.wikipedia.org/wiki/Newline)
- **Susijusi dokumentacija ir skriptai:** [.gitattributes](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/.gitattributes)

### `LIS` — Laboratory Information System
- **Apibrėžimas:** Laboratorinė informacinė sistema mėginių, tyrimų ir analizių duomenims valdyti.
- **Vaidmuo šiame projekte:** Demonstruojama Blueprint 3 su atskiromis proxy, alise ir lis duomenų bazėmis.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: LIS / LIMS](https://en.wikipedia.org/wiki/Laboratory_information_management_system)
- **Susijusi dokumentacija ir skriptai:** [config/blueprints/.env.bp3-multi-db-lis](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/config/blueprints/.env.bp3-multi-db-lis), [config/profiles/databases/db-lis.yaml](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/config/profiles/databases/db-lis.yaml)

## M

### `mTLS` — Mutual Transport Layer Security
- **Apibrėžimas:** Dvipusis kriptografinis autentifikavimas, kai klientas ir serveris tikrina vienas kito sertifikatus.
- **Vaidmuo šiame projekte:** Užtikrina saugų ryšį su OCI Autonomous Database debesyje per šifruotą piniginę.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: Mutual TLS](https://en.wikipedia.org/wiki/Mutual_authentication#mTLS)
- **Susijusi dokumentacija ir skriptai:** [docs/remote-multicloud-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/remote-multicloud-setup-guide.md)

## N

### `noVNC` — HTML5 VNC Client (WebSocket)
- **Apibrėžimas:** Naršyklėje veikiantis HTML5 VNC klientas nuotoliniam grafinių darbalaukių valdymui.
- **Vaidmuo šiame projekte:** Suteikia prieigą prie Forms Builder (prievadas 6082) ir Publisher Designer (6083) tiesiai naršyklėje.
- **Oficiali nuoroda / Vikipedija:** [Official: noVNC](https://novnc.com/)
- **Susijusi dokumentacija ir skriptai:** [docs/forms-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/forms-setup.md), [docs/publisher-template-builder-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/publisher-template-builder-guide.md)

## O

### `OCI` — Oracle Cloud Infrastructure
- **Apibrėžimas:** Oracle viešoji debesų platforma serveriams, saugykloms ir duomenų bazėms.
- **Vaidmuo šiame projekte:** Tikslinė debesų platforma diegimui per scripts/deploy-remote.sh ir hibridinius modelius (BP 10 ir 11).
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: Oracle Cloud Infrastructure](https://en.wikipedia.org/wiki/Oracle_Cloud)
- **Susijusi dokumentacija ir skriptai:** [scripts/deploy-remote.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/deploy-remote.sh), [docs/remote-multicloud-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/remote-multicloud-setup-guide.md)

### `OCR` — Oracle Container Registry
- **Apibrėžimas:** Oficialus Oracle konteinerių registras patvirtintiems DB ir tarpinės įrangos atvaizdams.
- **Vaidmuo šiame projekte:** Šaltinis 23ai Free DB atvaizdams; palaiko įmonės Artifactory veidrodžius per REGISTRY_MIRROR.
- **Oficiali nuoroda / Vikipedija:** [Official: Oracle Container Registry](https://container-registry.oracle.com/)
- **Susijusi dokumentacija ir skriptai:** [docs/enterprise-onboarding-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/enterprise-onboarding-guide.md)

### `OPatch` — Oracle Interim Patching Tool
- **Apibrėžimas:** Standartinis Oracle įrankis saugumo pataisų diegimui ir valdymui.
- **Vaidmuo šiame projekte:** Automatizuota Publisher skriptuose saugumo pataisų diegimui.
- **Oficiali nuoroda / Vikipedija:** [Oracle Database Patching & Upgrade](https://docs.oracle.com/en/database/oracle/oracle-database/19/install-and-upgrade.html)
- **Susijusi dokumentacija ir skriptai:** [docs/publisher-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/publisher-setup.md)

### `ORDS` — Oracle REST Data Services
- **Apibrėžimas:** Tarpinė programinė įranga, paverčianti SQL/PLSQL į REST API ir teikianti APEX sąsają.
- **Vaidmuo šiame projekte:** Pagrindiniai API vartai prievade 8088/8448; veikia atskirai DB operatyviajai atminčiai taupyti.
- **Oficiali nuoroda / Vikipedija:** [Oracle REST Data Services](https://www.oracle.com/database/technologies/appdev/rest.html)
- **Susijusi dokumentacija ir skriptai:** [docs/ords-profiles-lifecycle.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/ords-profiles-lifecycle.md), [scripts/internal/install-ords-standalone.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/install-ords-standalone.sh)

## P

### `PDB` — Pluggable Database
- **Apibrėžimas:** Autonominis schemų ir objektų rinkinys, veikiantis kaip atskira duomenų bazė.
- **Vaidmuo šiame projekte:** Izoliuoja sritis: FREEPDB1 (APEX), ALISEPDB (verslas), LIS_PDB ir BIP_PDB pagal modelius.
- **Oficiali nuoroda / Vikipedija:** [Oracle Pluggable Database (PDB)](https://docs.oracle.com/en/database/oracle/oracle-database/23/cncpt/multitenant-architecture.html)
- **Susijusi dokumentacija ir skriptai:** [docs/db-profiles-and-topology.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/db-profiles-and-topology.md), [scripts/internal/resolve-topology.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/resolve-topology.sh)

### `PID` — Process Identifier
- **Apibrėžimas:** Unikalus skaitmeninis identifikatorius, kurį operacinė sistema suteikia kiekvienam procesui.
- **Vaidmuo šiame projekte:** Sekamas asinchroninių procesų valdymui ir foninėms užduotims (12 taisyklė).
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: Process Identifier (PID)](https://en.wikipedia.org/wiki/Process_identifier)
- **Susijusi dokumentacija ir skriptai:** [scripts/internal/dev-hub-bridge.py](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/dev-hub-bridge.py)

## R

### `RAM` — Random Access Memory
- **Apibrėžimas:** Operatyvioji kompiuterio atmintis aktyvioms programoms ir DB buferiams.
- **Vaidmuo šiame projekte:** 23ai Free DB turi 2GB RAM ribą; atskirta architektūra apsaugo nuo atminties trūkumo.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: RAM](https://en.wikipedia.org/wiki/Random-access_memory)
- **Susijusi dokumentacija ir skriptai:** [docs/enterprise-distributed-architecture.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/enterprise-distributed-architecture.md)

### `RCU` — Repository Creation Utility
- **Apibrėžimas:** Oracle įrankis Fusion Middleware reikalingų duomenų bazės schemų kūrimui.
- **Vaidmuo šiame projekte:** Automatizuota konteineriuose Forms ir Publisher schemų paruošimui.
- **Oficiali nuoroda / Vikipedija:** [Oracle Repository Creation Utility Docs](https://docs.oracle.com/en/middleware/fusion-middleware/12.2.1.4/rcuug/)
- **Susijusi dokumentacija ir skriptai:** [docs/forms-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/forms-setup.md)

### `REST` — Representational State Transfer
- **Apibrėžimas:** Būsenos nesaugantis saityno architektūros modelis keitimuisi duomenimis per HTTP.
- **Vaidmuo šiame projekte:** Realizuota per ORDS AutoREST sujungiant mikropaslaugas be specialių tvarkyklių.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: REST](https://en.wikipedia.org/wiki/REST)
- **Susijusi dokumentacija ir skriptai:** [docs/ords-profiles-lifecycle.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/ords-profiles-lifecycle.md)

### `ROI` — Return on Investment
- **Apibrėžimas:** Finansinis rodiklis investicijų grąžai ir sąnaudų sutaupymui įvertinti.
- **Vaidmuo šiame projekte:** Akcentuota 5 skaidrėje: sutaupo iki 40% kūrimo licencijų ir panaikina nenaudojamų debesų sąskaitas.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: Return on Investment](https://en.wikipedia.org/wiki/Return_on_investment)
- **Susijusi dokumentacija ir skriptai:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

## S

### `SDW` — SQL Developer Web (Database Actions)
- **Apibrėžimas:** Naršyklės sąsaja ORDS sistemoje SQL užklausoms, REST paslaugoms ir stebėsenai.
- **Vaidmuo šiame projekte:** Pasiekiamas 1 paspaudimu iš Dev Hub su automatiniu slaptažodžio nukopijavimu.
- **Oficiali nuoroda / Vikipedija:** [Oracle SQL Developer Web](https://docs.oracle.com/en/database/oracle/sql-developer-web/)
- **Susijusi dokumentacija ir skriptai:** [docs/quick-login-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/quick-login-guide.md)

### `SEPS` — Secure External Password Store (Oracle Wallet)
- **Apibrėžimas:** Oracle šifruota piniginė (cwallet.sso) saugiam prisijungimui be slaptažodžių.
- **Vaidmuo šiame projekte:** Privalomas pagal 5 taisyklę: jokių slaptažodžių tekstu; visi skriptai jungiasi per SEPS piniginę.
- **Oficiali nuoroda / Vikipedija:** [Oracle Database Security Guide](https://docs.oracle.com/en/database/oracle/oracle-database/19/dbseg/)
- **Susijusi dokumentacija ir skriptai:** [docs/security.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/security.md), [scripts/get-password.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/get-password.sh), [scripts/check-wallet.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-wallet.sh)

### `SGA / PGA` — System Global Area / Program Global Area
- **Apibrėžimas:** Oracle atminties struktūros: SGA yra bendra visiems procesams, PGA skirta atskiram procesui.
- **Vaidmuo šiame projekte:** Dinamiškai suderinta, kad bendra atmintis neviršytų 2GB Free DB konteinerio ribos.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: Oracle Database Memory Architecture](https://en.wikipedia.org/wiki/Oracle_Database#Memory_structures)
- **Susijusi dokumentacija ir skriptai:** [scripts/internal/init-db-instance.sql](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/init-db-instance.sql)

### `SPA` — Single Page Application
- **Apibrėžimas:** Vieno puslapio programa, dinamiškai atnaujinanti turinį be viso puslapio perkrovimo.
- **Vaidmuo šiame projekte:** Dev Hub architektūra: visiškai autonomiška, be CDN priklausomybių, momentinis naršymas.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: Single-Page Application](https://en.wikipedia.org/wiki/Single-page_application)
- **Susijusi dokumentacija ir skriptai:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

### `SPFILE` — Server Parameter File
- **Apibrėžimas:** Binarinis parametrų failas, išsaugantis DB nustatymus po perkrovimo.
- **Vaidmuo šiame projekte:** Sukonfigūruota DB konteineryje optimaliems atminties ir APEX nustatymams užtikrinti.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: Oracle Initialization Parameters](https://en.wikipedia.org/wiki/Oracle_Database#Initialization_parameters)
- **Susijusi dokumentacija ir skriptai:** [scripts/internal/init-db-instance.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/init-db-instance.sh)

### `SQL` — Structured Query Language
- **Apibrėžimas:** Standartinė užklausų kalba duomenų valdymui reliacinėse duomenų bazėse.
- **Vaidmuo šiame projekte:** Visos schemos, vartotojai ir teisės diegiami per SQL failus aplanke scripts/internal/.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: SQL](https://en.wikipedia.org/wiki/SQL)
- **Susijusi dokumentacija ir skriptai:** [scripts/internal/init-db-instance.sql](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/init-db-instance.sql)

### `SQLcl` — Oracle SQL Developer Command Line
- **Apibrėžimas:** Šiuolaikinis Oracle komandinės eilutės įrankis su Liquibase ir Git integracija.
- **Vaidmuo šiame projekte:** Privalomas standartas pagal 6 taisyklę; pirmenybę teikia VS Code SQLcl programai.
- **Oficiali nuoroda / Vikipedija:** [Oracle SQLcl Official](https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/)
- **Susijusi dokumentacija ir skriptai:** [scripts/sqlcl.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/sqlcl.sh), [docs/quick-login-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/quick-login-guide.md)

### `SSO` — Single Sign-On
- **Apibrėžimas:** Vieningas prisijungimas, leidžiantis vienu prisijungimu pasiekti kelias sistemas.
- **Vaidmuo šiame projekte:** Integruota įmonių aplinkose su Azure Entra-ID ir APEX.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: Single Sign-On](https://en.wikipedia.org/wiki/Single_sign-on)
- **Susijusi dokumentacija ir skriptai:** [tests/test-browser-login.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/test-browser-login.sh)

## T

### `TCO` — Total Cost of Ownership
- **Apibrėžimas:** Bendra nuosavybės kaina, apimanti licencijas, infrastruktūrą ir priežiūrą.
- **Vaidmuo šiame projekte:** Reikšmingai sumažinta su Free DB: 0€ licencijų kaštai kūrimui ir vidiniams įrankiams.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: Total Cost of Ownership](https://en.wikipedia.org/wiki/Total_cost_of_ownership)
- **Susijusi dokumentacija ir skriptai:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

### `TLS` — Transport Layer Security
- **Apibrėžimas:** Kriptografinis protokolas saugiam ir šifruotam duomenų perdavimui tinkle.
- **Vaidmuo šiame projekte:** Generuojama lokaliai HTTPS ryšiui prievade 8448 ir ORDS šifravimui.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: Transport Layer Security](https://en.wikipedia.org/wiki/Transport_Layer_Security)
- **Susijusi dokumentacija ir skriptai:** [docs/security.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/security.md), [scripts/internal/generate-local-certs.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/generate-local-certs.sh)

### `TNS` — Transparent Network Substrate
- **Apibrėžimas:** Oracle tinklo technologija klientų sujungimui su duomenų bazėmis.
- **Vaidmuo šiame projekte:** Automatiškai sukonfigūruota tnsnames.ora faile ir eksportuota per TNS_ADMIN.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: Transparent Network Substrate](https://en.wikipedia.org/wiki/Transparent_Network_Substrate)
- **Susijusi dokumentacija ir skriptai:** [tnsnames/tnsnames.ora](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tnsnames/tnsnames.ora), [scripts/register-connections.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/register-connections.sh)

## U

### `UAC` — User Account Control
- **Apibrėžimas:** Windows saugumo funkcija, reikalaujanti administratoriaus leidimo sistemos pakeitimams.
- **Vaidmuo šiame projekte:** Apeinama pagal 14 taisyklę: sertifikatai registruojami vartotojo lygiu be administratoriaus teisių.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: User Account Control](https://en.wikipedia.org/wiki/User_Account_Control)
- **Susijusi dokumentacija ir skriptai:** [scripts/certs/trust-local-cert.cmd](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/certs/trust-local-cert.cmd), [docs/windows-enterprise-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/windows-enterprise-setup-guide.md)

### `UI / UX` — User Interface / User Experience
- **Apibrėžimas:** Vartotojo sąsaja ir patirtis: vizualus dizainas, valdikliai ir bendras patogumas.
- **Vaidmuo šiame projekte:** Ištobulinta Dev Hub su modernia tamsia tema, greitaisiais įrankiais ir žurnalais realiuoju laiku.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: UI/UX Design](https://en.wikipedia.org/wiki/User_interface_design)
- **Susijusi dokumentacija ir skriptai:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

### `URI / URL` — Uniform Resource Identifier / Locator
- **Apibrėžimas:** Standartinis saityno adresas ištekliams rasti ir identifikuoti tinkle.
- **Vaidmuo šiame projekte:** Tikrinama paleidimo metu su scripts/check-urls.sh užtikrinant HTTP 200/302 atsakus.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: URI / URL](https://en.wikipedia.org/wiki/Uniform_Resource_Identifier)
- **Susijusi dokumentacija ir skriptai:** [scripts/check-urls.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-urls.sh)

## V

### `VPN` — Virtual Private Network
- **Apibrėžimas:** Šifruotas tinklo tunelis saugiam prisijungimui prie įmonės vidinio tinklo per internetą.
- **Vaidmuo šiame projekte:** Apsaugota Windows WSL2 per 'dnsTunneling=true' nustatymą, kad įmonės VPN nenutrauktų DNS.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: Virtual Private Network](https://en.wikipedia.org/wiki/Virtual_private_network)
- **Susijusi dokumentacija ir skriptai:** [docs/windows-enterprise-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/windows-enterprise-setup-guide.md)

### `VS Code` — Visual Studio Code
- **Apibrėžimas:** Populiarus ir išplečiamas kodo redaktorius iš Microsoft su gausiu įskiepių palaikymu.
- **Vaidmuo šiame projekte:** Pagrindinis kodo redaktorius: automatiškai registruoja ryšius su Oracle plėtiniu.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: Visual Studio Code](https://en.wikipedia.org/wiki/Visual_Studio_Code)
- **Susijusi dokumentacija ir skriptai:** [scripts/register-connections.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/register-connections.sh)

## W

### `WSL / WSL2` — Windows Subsystem for Linux (Version 2)
- **Apibrėžimas:** Integruota Windows Linux posistemė, paleidžianti tikrą Linux branduolį.
- **Vaidmuo šiame projekte:** 14 taisyklės reikalavimas: projektas privalo būti vidinėje ext4 sistemoje (~/), o ne /mnt/c/.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: Windows Subsystem for Linux](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux)
- **Susijusi dokumentacija ir skriptai:** [docs/windows-enterprise-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/windows-enterprise-setup-guide.md), [setup.cmd](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/setup.cmd)

## Y

### `YAML` — YAML Ain't Markup Language
- **Apibrėžimas:** Žmogui lengvai skaitomas duomenų formatas konfigūracijoms ir deklaracijoms.
- **Vaidmuo šiame projekte:** 11 taisyklės reikalavimas kaip vienintelis tiesos šaltinis DB profiliams ir teisėms.
- **Oficiali nuoroda / Vikipedija:** [Wikipedia: YAML](https://en.wikipedia.org/wiki/YAML)
- **Susijusi dokumentacija ir skriptai:** [config/profiles/databases/db-oracle.yaml](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/config/profiles/databases/db-oracle.yaml)

