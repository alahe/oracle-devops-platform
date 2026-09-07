# Arkitekturordlista och akronymer

[ 🇬🇧 English ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/glossary.md) | [ 🇪🇪 Eesti ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/et/glossary.md) | [ 🇫🇮 Suomi ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/fi/glossary.md) | **[ 🇸🇪 Svenska ]** | [ 🇱🇻 Latviešu ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lv/glossary.md) | [ 🇱🇹 Lietuvių ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lt/glossary.md)

> Omfattande register över förkortningar, tekniska definitioner och praktisk projektanvändning.

---

**A–Z Register:** [A](#a) • [B](#b) • [C](#c) • [D](#d) • [E](#e) • [F](#f) • [G](#g) • [H](#h) • [I](#i) • [J](#j) • [K](#k) • [L](#l) • [M](#m) • [N](#n) • [O](#o) • [P](#p) • [R](#r) • [S](#s) • [T](#t) • [U](#u) • [V](#v) • [W](#w) • [Y](#y)

---

## A

### `ADB` — Autonomous Database
- **Definition:** Oracles helhanterade molndatabas som automatiserar provisionering, patchning och skalning.
- **Roll i detta projekt:** Mål för hybridmolnmigrering (BP 10 & 11) via mTLS-wallet utan att skriva om lokal kod.
- **Officiell referens / Wikipedia:** [Oracle Autonomous Database](https://www.oracle.com/autonomous-database/)
- **Relaterade guider och skript:** [docs/remote-multicloud-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/remote-multicloud-setup-guide.md), [scripts/deploy-remote.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/deploy-remote.sh)

### `APEX` — Oracle Application Express
- **Definition:** Oracles low-code utvecklingsplattform för webbapplikationer som körs direkt i databasen.
- **Roll i detta projekt:** Centralt användargränssnitt i Proxy DB (port 8448/8088), automatiserat via APEXlang DSL och Git-exporter.
- **Officiell referens / Wikipedia:** [Wikipedia: Oracle APEX](https://en.wikipedia.org/wiki/Oracle_APEX)
- **Relaterade guider och skript:** [docs/apex-devhub-test-plan.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/apex-devhub-test-plan.md), [scripts/internal/install-apex.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/install-apex.sh)

### `APFS` — Apple File System
- **Definition:** Standardfilsystem för macOS optimerat för SSD-lagring, kryptering och snapshots.
- **Roll i detta projekt:** macOS utvecklingsfilsystem där portabilitet (Regel 13) verifieras mot Windows NTFS.
- **Officiell referens / Wikipedia:** [Wikipedia: Apple File System](https://en.wikipedia.org/wiki/Apple_File_System)
- **Relaterade guider och skript:** [tests/unit/test-filename-portability.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/unit/test-filename-portability.sh)

### `API` — Application Programming Interface
- **Definition:** Strukturerat gränssnitt för programmatisk kommunikation mellan mjukvarusystem.
- **Roll i detta projekt:** Tillgängligt lokalt via ORDS och Dev Hub Bridge (/api/status, /api/podman) på port 8089.
- **Officiell referens / Wikipedia:** [Wikipedia: API](https://en.wikipedia.org/wiki/API)
- **Relaterade guider och skript:** [docs/testing-framework-and-devhub.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/testing-framework-and-devhub.md), [scripts/internal/dev-hub-bridge.py](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/dev-hub-bridge.py)

## B

### `BIP` — Business Intelligence Publisher (Analytics Publisher)
- **Definition:** Rapportmotor på företagsnivå för pixel-perfect PDF, Excel och XML-rapporter i hög volym.
- **Roll i detta projekt:** Integrerat i BP 4 & 11 (portar 9502/6083) för mallbaserad dokumentgenerering.
- **Officiell referens / Wikipedia:** [Oracle Analytics Publisher Docs](https://docs.oracle.com/middleware/12213/bip/)
- **Relaterade guider och skript:** [docs/publisher-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/publisher-setup.md), [scripts/publisher/restart-publisher.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/publisher/restart-publisher.sh)

### `BP` — Blueprint (Architecture Blueprint)
- **Definition:** Förkonfigurerade, idempotenta arkitekturmönster som definierar databaser, mellanprogramvara och portar.
- **Roll i detta projekt:** 12 kanoniska miljöer (BP 0 till BP 11) som distribueras via script eller Dev Hub.
- **Officiell referens / Wikipedia:** [Wikipedia: Blueprint](https://en.wikipedia.org/wiki/Blueprint)
- **Relaterade guider och skript:** [config/blueprints/README.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/config/blueprints/README.md), [scripts/deploy-blueprint.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/deploy-blueprint.sh)

## C

### `CA` — Certificate Authority
- **Definition:** En betrodd utfärdare av digitala certifikat för identitetsverifiering och TLS-kryptering.
- **Roll i detta projekt:** Plattformen skapar en lokal Root CA (certs/ca.crt) som installeras i OS-certifikatarkivet.
- **Officiell referens / Wikipedia:** [Wikipedia: Certificate Authority](https://en.wikipedia.org/wiki/Certificate_authority)
- **Relaterade guider och skript:** [docs/security.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/security.md), [scripts/certs/trust-local-cert-mac.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/certs/trust-local-cert-mac.sh)

### `CDB` — Container Database
- **Definition:** Oracles multitenant-rotdatabas som hanterar metadata och rymmer en eller flera PDB:er.
- **Roll i detta projekt:** Standard CDB$ROOT i 23ai Free DB-containern; hanteras helautomatiskt via init-db-instance.sh.
- **Officiell referens / Wikipedia:** [Oracle Multitenant Architecture](https://docs.oracle.com/en/database/oracle/oracle-database/23/cncpt/multitenant-architecture.html)
- **Relaterade guider och skript:** [docs/db-profiles-and-topology.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/db-profiles-and-topology.md), [scripts/internal/init-db-instance.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/init-db-instance.sh)

### `CI/CD` — Continuous Integration / Continuous Deployment
- **Definition:** Automatiserade DevOps-pipelines för kontinuerlig integrering, testning och leverans av kod.
- **Roll i detta projekt:** Testas lokalt offline via './tests/test-local-ci.sh' och i Dev Hubs testflik med 15 testsviter.
- **Officiell referens / Wikipedia:** [Wikipedia: CI/CD](https://en.wikipedia.org/wiki/CI/CD)
- **Relaterade guider och skript:** [tests/test-local-ci.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/test-local-ci.sh), [docs/devops-lifecycle-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/devops-lifecycle-guide.md)

### `CLI` — Command Line Interface
- **Definition:** Textbaserat användargränssnitt för att köra kommandon och automatisera skript.
- **Roll i detta projekt:** Enhetliga CLI-verktyg i scripts/ med full paritet gentemot Dev Hub webbgränssnitt.
- **Officiell referens / Wikipedia:** [Wikipedia: Command-Line Interface](https://en.wikipedia.org/wiki/Command-line_interface)
- **Relaterade guider och skript:** [scripts/README.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/README.md), [scripts/sqlcl.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/sqlcl.sh)

### `CPU` — Central Processing Unit
- **Definition:** Datorns centralprocessor som exekverar programinstruktioner och bearbetar data.
- **Roll i detta projekt:** Övervakas per container i Dev Hub; 23ai Free DB begränsas till 2 processorkärnor.
- **Officiell referens / Wikipedia:** [Wikipedia: CPU](https://en.wikipedia.org/wiki/Central_processing_unit)
- **Relaterade guider och skript:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

### `CRLF` — Carriage Return Line Feed (\r\n)
- **Definition:** Två-byte radbrytning i Windows som skapar kompileringsfel i Unix-baserade shell-skript.
- **Roll i detta projekt:** Strikt förbjudet i shell-skript via .gitattributes och verifierat i Windows-tester (Regel 14).
- **Officiell referens / Wikipedia:** [Wikipedia: Newline (CRLF)](https://en.wikipedia.org/wiki/Newline)
- **Relaterade guider och skript:** [.gitattributes](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/.gitattributes), [tests/unit/test-windows-enterprise-rules.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/unit/test-windows-enterprise-rules.sh)

## D

### `DBA` — Database Administrator
- **Definition:** Databasadministratör med ansvar för drift, säkerhet, prestanda och återställning.
- **Roll i detta projekt:** Plattformen eliminerar flaskhalsar genom att automatisera 100% av DBA-rutinerna.
- **Officiell referens / Wikipedia:** [Wikipedia: Database Administrator](https://en.wikipedia.org/wiki/Database_administrator)
- **Relaterade guider och skript:** [scripts/internal/apply-profile-users.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/apply-profile-users.sh), [scripts/create-developer.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/create-developer.sh)

### `DR` — Disaster Recovery
- **Definition:** Processer för att snabbt återställa data och infrastruktur efter allvarliga incidenter.
- **Roll i detta projekt:** Uppnås på ~15 sekunder via Golden Snapshots som återställer miljöer utan administration.
- **Officiell referens / Wikipedia:** [Wikipedia: Disaster Recovery](https://en.wikipedia.org/wiki/Disaster_recovery)
- **Relaterade guider och skript:** [scripts/snapshots/README.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/snapshots/README.md), [scripts/snapshots/restore-golden-snapshots.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/snapshots/restore-golden-snapshots.sh)

### `DSL` — Domain-Specific Language
- **Definition:** Ett specialiserat programmeringsspråk anpassat för en specifik problemdomän.
- **Roll i detta projekt:** APEXlang (.apx) deklarativt språk för att specificera APEX-sidor och komponenter i Git.
- **Officiell referens / Wikipedia:** [Wikipedia: Domain-Specific Language](https://en.wikipedia.org/wiki/Domain-specific_language)
- **Relaterade guider och skript:** [docs/apex-devhub-test-plan.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/apex-devhub-test-plan.md)

## E

### `E2E` — End-to-End Testing
- **Definition:** Testmetodik som verifierar hela flödet från användargränssnitt till databaslagring.
- **Roll i detta projekt:** Representerat av 6 sviter i Dev Hub testcenter för fullständiga flödestester.
- **Officiell referens / Wikipedia:** [Wikipedia: End-to-End Testing](https://en.wikipedia.org/wiki/Software_testing#End-to-end_testing)
- **Relaterade guider och skript:** [tests/test-browser-login.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/test-browser-login.sh), [docs/devhub-browser-testing-plan.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/devhub-browser-testing-plan.md)

## F

### `FAT / NTFS` — File Allocation Table / New Technology File System
- **Definition:** Windows-filsystem med strikta begränsningar för otillåtna tecken och reserverade enhetsnamn.
- **Roll i detta projekt:** Hanteras strikt enligt Regel 13 och verifieras av test-filename-portability.sh.
- **Officiell referens / Wikipedia:** [Wikipedia: NTFS](https://en.wikipedia.org/wiki/NTFS)
- **Relaterade guider och skript:** [tests/unit/test-filename-portability.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/unit/test-filename-portability.sh)

### `FMW` — Fusion Middleware
- **Definition:** Oracles företagsinfrastruktur bestående av WebLogic Server, Forms och Publisher.
- **Roll i detta projekt:** Körs i containrar för Forms 14c och Analytics Publisher med full automatisering.
- **Officiell referens / Wikipedia:** [Wikipedia: Oracle Fusion Middleware](https://en.wikipedia.org/wiki/Oracle_Fusion_Middleware)
- **Relaterade guider och skript:** [docs/forms-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/forms-setup.md), [docs/publisher-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/publisher-setup.md)

## G

### `GUI` — Graphical User Interface
- **Definition:** Grafiskt användargränssnitt med knappar och fönster för enkel visuell interaktion.
- **Roll i detta projekt:** Tillhandahålls av Dev Hub med ett-klicks containerkontroll och presentationsvy.
- **Officiell referens / Wikipedia:** [Wikipedia: GUI](https://en.wikipedia.org/wiki/Graphical_user_interface)
- **Relaterade guider och skript:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html), [scripts/internal/generate_dev_hub.py](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/generate_dev_hub.py)

## H

### `HTTP / HTTPS` — Hypertext Transfer Protocol (Secure)
- **Definition:** Grundläggande webbkommunikationsprotokoll, krypterat med TLS i HTTPS.
- **Roll i detta projekt:** Alla plattformens webbtjänster körs säkert över TLS utan säkerhetsvarningar.
- **Officiell referens / Wikipedia:** [Wikipedia: HTTPS](https://en.wikipedia.org/wiki/HTTPS)
- **Relaterade guider och skript:** [scripts/check-urls.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-urls.sh)

## I

### `i18n` — Internationalization
- **Definition:** Design av mjukvara för stöd för flera språk och regioner utan kodändringar.
- **Roll i detta projekt:** Strikt enligt Regel 9: 100% symmetri över 6 språk i all dokumentation och Dev Hub.
- **Officiell referens / Wikipedia:** [Wikipedia: Internationalization (i18n)](https://en.wikipedia.org/wiki/Internationalization_and_localization)
- **Relaterade guider och skript:** [tests/unit/test-i18n-translations.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/unit/test-i18n-translations.sh), [scripts/internal/i18n.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/i18n.sh)

### `IDE` — Integrated Development Environment
- **Definition:** Integrerad utvecklingsmiljö som samlar kodredigerare, felsökare och versionshantering.
- **Roll i detta projekt:** Stöds lokalt via VS Code och webbaserat via Web-IDE (BP 8, port 8090).
- **Officiell referens / Wikipedia:** [Wikipedia: IDE](https://en.wikipedia.org/wiki/Integrated_development_environment)
- **Relaterade guider och skript:** [docker/web-ide/README.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docker/web-ide/README.md), [scripts/register-connections.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/register-connections.sh)

## J

### `JIT` — Just-In-Time (Decryption / Compilation)
- **Definition:** Modell där autentiseringsuppgifter avkodas i minnet exakt vid körningstillfället utan disklagring.
- **Roll i detta projekt:** Kärnan i Zero-Trust Regel 5: lösenord läses dynamiskt till minnet och förstörs direkt efter körning.
- **Officiell referens / Wikipedia:** [Wikipedia: Just-In-Time (JIT)](https://en.wikipedia.org/wiki/Just-in-time_compilation)
- **Relaterade guider och skript:** [scripts/get-password.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/get-password.sh), [docs/security.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/security.md)

### `JSON` — JavaScript Object Notation
- **Definition:** Lättviktigt textbaserat format för datautbyte mellan webbtjänster och applikationer.
- **Roll i detta projekt:** Används för prestandamätningar, Dev Hub REST API och genererad HTML-data.
- **Officiell referens / Wikipedia:** [Wikipedia: JSON](https://en.wikipedia.org/wiki/JSON)
- **Relaterade guider och skript:** [metrics/setup_benchmarks.json](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/metrics/setup_benchmarks.json)

## K

### `KPI` — Key Performance Indicator
- **Definition:** Mätbar nyckeltalsindikator för att utvärdera prestanda och mål i projekt och system.
- **Roll i detta projekt:** Visas på Dev Hubs presentationskort (-85% DRIFTSTOPP, 1-KLICKS START, 0 KR LICENSKOSTNAD).
- **Officiell referens / Wikipedia:** [Wikipedia: Key Performance Indicator](https://en.wikipedia.org/wiki/Performance_indicator)
- **Relaterade guider och skript:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

## L

### `LF` — Line Feed (\n)
- **Definition:** Unix/Linux standardtecken för radbrytning som krävs av POSIX shell-tolkar.
- **Roll i detta projekt:** Obligatoriskt enligt Regel 14 över alla skript- och konfigurationsfiler via .gitattributes.
- **Officiell referens / Wikipedia:** [Wikipedia: Newline (LF)](https://en.wikipedia.org/wiki/Newline)
- **Relaterade guider och skript:** [.gitattributes](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/.gitattributes)

### `LIS` — Laboratory Information System
- **Definition:** Laboratorieinformationssystem för hantering av prover, instrument och analysresultat.
- **Roll i detta projekt:** Demonstreras i Blueprint 3 med isolerade instanser för proxy, alise och lis.
- **Officiell referens / Wikipedia:** [Wikipedia: LIS / LIMS](https://en.wikipedia.org/wiki/Laboratory_information_management_system)
- **Relaterade guider och skript:** [config/blueprints/.env.bp3-multi-db-lis](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/config/blueprints/.env.bp3-multi-db-lis), [config/profiles/databases/db-lis.yaml](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/config/profiles/databases/db-lis.yaml)

## M

### `mTLS` — Mutual Transport Layer Security
- **Definition:** Tvåvägs kryptografisk autentisering där både klient och server verifierar varandras certifikat.
- **Roll i detta projekt:** Möjliggör säker molnanslutning till OCI Autonomous Database via wallet utan osäkra portar.
- **Officiell referens / Wikipedia:** [Wikipedia: Mutual TLS](https://en.wikipedia.org/wiki/Mutual_authentication#mTLS)
- **Relaterade guider och skript:** [docs/remote-multicloud-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/remote-multicloud-setup-guide.md)

## N

### `noVNC` — HTML5 VNC Client (WebSocket)
- **Definition:** Webbläsarbaserad HTML5 VNC-klient för direkt fjärråtkomst till grafiska skrivbordsmiljöer.
- **Roll i detta projekt:** Ger direkt åtkomst till Oracle Forms Builder (port 6082) och Publisher Designer (port 6083) i webbläsaren.
- **Officiell referens / Wikipedia:** [Official: noVNC](https://novnc.com/)
- **Relaterade guider och skript:** [docs/forms-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/forms-setup.md), [docs/publisher-template-builder-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/publisher-template-builder-guide.md)

## O

### `OCI` — Oracle Cloud Infrastructure
- **Definition:** Oracles molninfrastruktur för servrar, lagring, nätverk och autonoma databaser.
- **Roll i detta projekt:** Målplattform för molndistribution via scripts/deploy-remote.sh och hybridmodeller (BP 10 & 11).
- **Officiell referens / Wikipedia:** [Wikipedia: Oracle Cloud Infrastructure](https://en.wikipedia.org/wiki/Oracle_Cloud)
- **Relaterade guider och skript:** [scripts/deploy-remote.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/deploy-remote.sh), [docs/remote-multicloud-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/remote-multicloud-setup-guide.md)

### `OCR` — Oracle Container Registry
- **Definition:** Oracles officiella containerregister för verifierade databas- och mellanprogramvaru-images.
- **Roll i detta projekt:** Källa för 23ai Free DB och ORDS; stöder Artifactory-speglar via REGISTRY_MIRROR.
- **Officiell referens / Wikipedia:** [Official: Oracle Container Registry](https://container-registry.oracle.com/)
- **Relaterade guider och skript:** [docs/enterprise-onboarding-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/enterprise-onboarding-guide.md)

### `OPatch` — Oracle Interim Patching Tool
- **Definition:** Oracles standardverktyg för att applicera och rulla tillbaka officiella programvarupatchar.
- **Roll i detta projekt:** Automatiserat i Publisher-installationsskript för hands-free uppdateringar.
- **Officiell referens / Wikipedia:** [Oracle Database Patching & Upgrade](https://docs.oracle.com/en/database/oracle/oracle-database/19/install-and-upgrade.html)
- **Relaterade guider och skript:** [docs/publisher-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/publisher-setup.md)

### `ORDS` — Oracle REST Data Services
- **Definition:** Mellanprogramvara som exponerar SQL/PLSQL som RESTful API:er och levererar APEX-webbsidor.
- **Roll i detta projekt:** Huvudsaklig API-gateway på port 8088/8448; körs fristående (BP 5 & 10) för att spara databasminne.
- **Officiell referens / Wikipedia:** [Oracle REST Data Services](https://www.oracle.com/database/technologies/appdev/rest.html)
- **Relaterade guider och skript:** [docs/ords-profiles-lifecycle.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/ords-profiles-lifecycle.md), [scripts/internal/install-ords-standalone.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/install-ords-standalone.sh)

## P

### `PDB` — Pluggable Database
- **Definition:** Självgående databasinstans i Oracles multitenant-arkitektur som fungerar som en isolerad databas.
- **Roll i detta projekt:** Isolerar applikationsdomäner: FREEPDB1 (Proxy), ALISEPDB (Affärsdata), LIS_PDB och BIP_PDB.
- **Officiell referens / Wikipedia:** [Oracle Pluggable Database (PDB)](https://docs.oracle.com/en/database/oracle/oracle-database/23/cncpt/multitenant-architecture.html)
- **Relaterade guider och skript:** [docs/db-profiles-and-topology.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/db-profiles-and-topology.md), [scripts/internal/resolve-topology.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/resolve-topology.sh)

### `PID` — Process Identifier
- **Definition:** Unik numerisk identifierare som operativsystemet tilldelar varje aktiv process.
- **Roll i detta projekt:** Spåras av Dev Hub för asynkron bakgrundskörning och processkontroll (Regel 12).
- **Officiell referens / Wikipedia:** [Wikipedia: Process Identifier (PID)](https://en.wikipedia.org/wiki/Process_identifier)
- **Relaterade guider och skript:** [scripts/internal/dev-hub-bridge.py](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/dev-hub-bridge.py)

## R

### `RAM` — Random Access Memory
- **Definition:** Datorns arbetsminne för aktiva program, operativsystem och databasbuffertar.
- **Roll i detta projekt:** 23ai Free DB har en hård gräns på 2GB RAM; modulär arkitektur förhindrar minnesbrist.
- **Officiell referens / Wikipedia:** [Wikipedia: RAM](https://en.wikipedia.org/wiki/Random-access_memory)
- **Relaterade guider och skript:** [docs/enterprise-distributed-architecture.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/enterprise-distributed-architecture.md)

### `RCU` — Repository Creation Utility
- **Definition:** Oracle-verktyg för att skapa och konfigurera databasscheman för Fusion Middleware.
- **Roll i detta projekt:** Automatiseras tyst i containrar för att initiera scheman för Forms och Publisher.
- **Officiell referens / Wikipedia:** [Oracle Repository Creation Utility Docs](https://docs.oracle.com/en/middleware/fusion-middleware/12.2.1.4/rcuug/)
- **Relaterade guider och skript:** [docs/forms-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/forms-setup.md)

### `REST` — Representational State Transfer
- **Definition:** Tillståndslös arkitekturmodell för att bygga skalbara webbtjänster och API:er över HTTP.
- **Roll i detta projekt:** Levereras via ORDS AutoREST och ansluter mikrotjänster och Dev Hub utan databasdrivrutiner.
- **Officiell referens / Wikipedia:** [Wikipedia: REST](https://en.wikipedia.org/wiki/REST)
- **Relaterade guider och skript:** [docs/ords-profiles-lifecycle.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/ords-profiles-lifecycle.md)

### `ROI` — Return on Investment
- **Definition:** Finansiellt nyckeltal för att mäta lönsamhet och effektivitet i förhållande till investeringskostnad.
- **Roll i detta projekt:** Framhävt i bild 5: sparar upp till 40% av utvecklingslicenser och eliminerar onödiga molnkostnader.
- **Officiell referens / Wikipedia:** [Wikipedia: Return on Investment](https://en.wikipedia.org/wiki/Return_on_investment)
- **Relaterade guider och skript:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

## S

### `SDW` — SQL Developer Web (Database Actions)
- **Definition:** Webbläsarbaserat gränssnitt i ORDS för att köra SQL, bygga REST-tjänster och övervaka databasen.
- **Roll i detta projekt:** Tillgängligt via ett klick i Dev Hub med automatisk lösenordshjälp för DBA_ADMIN och utvecklare.
- **Officiell referens / Wikipedia:** [Oracle SQL Developer Web](https://docs.oracle.com/en/database/oracle/sql-developer-web/)
- **Relaterade guider och skript:** [docs/quick-login-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/quick-login-guide.md)

### `SEPS` — Secure External Password Store (Oracle Wallet)
- **Definition:** Oracles krypterade plånbok (cwallet.sso) som möjliggör lösenordsfri klientautentisering.
- **Roll i detta projekt:** Strikt enligt Regel 5: noll lösenord i klartext; all CLI-autentisering sker via SEPS-plånboken.
- **Officiell referens / Wikipedia:** [Oracle Database Security Guide](https://docs.oracle.com/en/database/oracle/oracle-database/19/dbseg/)
- **Relaterade guider och skript:** [docs/security.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/security.md), [scripts/get-password.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/get-password.sh), [scripts/check-wallet.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-wallet.sh)

### `SGA / PGA` — System Global Area / Program Global Area
- **Definition:** Oracles minnesstrukturer: SGA delas mellan alla processer, PGA är dedikerat per serverprocess.
- **Roll i detta projekt:** Dynamiskt konfigurerat för att garantera att minnesanvändningen ryms inom 2GB i containern.
- **Officiell referens / Wikipedia:** [Wikipedia: Oracle Database Memory Architecture](https://en.wikipedia.org/wiki/Oracle_Database#Memory_structures)
- **Relaterade guider och skript:** [scripts/internal/init-db-instance.sql](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/init-db-instance.sql)

### `SPA` — Single Page Application
- **Definition:** Ensidesapplikation som dynamiskt uppdaterar innehållet utan att ladda om hela sidan.
- **Roll i detta projekt:** Dev Hubs arkitektur: 100% fristående, inga externa CDN-beroenden, blixtsnabb navigering.
- **Officiell referens / Wikipedia:** [Wikipedia: Single-Page Application](https://en.wikipedia.org/wiki/Single-page_application)
- **Relaterade guider och skript:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

### `SPFILE` — Server Parameter File
- **Definition:** Binär parameterfil som bevarar databasens konfigurationsändringar över omstarter.
- **Roll i detta projekt:** Konfigureras i databascontainern för att garantera optimal minnesallokering och APEX-stöd.
- **Officiell referens / Wikipedia:** [Wikipedia: Oracle Initialization Parameters](https://en.wikipedia.org/wiki/Oracle_Database#Initialization_parameters)
- **Relaterade guider och skript:** [scripts/internal/init-db-instance.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/init-db-instance.sh)

### `SQL` — Structured Query Language
- **Definition:** Standardiserat frågespråk för att hantera och söka data i relationsdatabaser.
- **Roll i detta projekt:** Alla scheman, användare och behörigheter skapas via SQL-filer i scripts/internal/.
- **Officiell referens / Wikipedia:** [Wikipedia: SQL](https://en.wikipedia.org/wiki/SQL)
- **Relaterade guider och skript:** [scripts/internal/init-db-instance.sql](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/init-db-instance.sql)

### `SQLcl` — Oracle SQL Developer Command Line
- **Definition:** Modernt kommandoradsverktyg för Oracle Database med stöd för Liquibase och Git.
- **Roll i detta projekt:** Obligatorisk standard enligt Regel 6 (legacy sqlplus förbjudet); prioriterar VS Coden SQLcl.
- **Officiell referens / Wikipedia:** [Oracle SQLcl Official](https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/)
- **Relaterade guider och skript:** [scripts/sqlcl.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/sqlcl.sh), [docs/quick-login-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/quick-login-guide.md)

### `SSO` — Single Sign-On
- **Definition:** Enkel inloggning som ger användaren åtkomst till flera system med en enda inloggning.
- **Roll i detta projekt:** Integrerat för företagsmiljöer med Azure Entra-ID, ORDS och APEX.
- **Officiell referens / Wikipedia:** [Wikipedia: Single Sign-On](https://en.wikipedia.org/wiki/Single_sign-on)
- **Relaterade guider och skript:** [tests/test-browser-login.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/test-browser-login.sh)

## T

### `TCO` — Total Cost of Ownership
- **Definition:** Total ägandekostnad som inkluderar licenser, infrastruktur, underhåll och driftstopp.
- **Roll i detta projekt:** Reducerat drastiskt med Free DB: noll licensavgifter för utveckling och interna verktyg.
- **Officiell referens / Wikipedia:** [Wikipedia: Total Cost of Ownership](https://en.wikipedia.org/wiki/Total_cost_of_ownership)
- **Relaterade guider och skript:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

### `TLS` — Transport Layer Security
- **Definition:** Kryptografiskt protokoll för att erbjuda säker och krypterad kommunikation över nätverk.
- **Roll i detta projekt:** Genereras lokalt för HTTPS på port 8448 och säker ORDS-anslutning.
- **Officiell referens / Wikipedia:** [Wikipedia: Transport Layer Security](https://en.wikipedia.org/wiki/Transport_Layer_Security)
- **Relaterade guider och skript:** [docs/security.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/security.md), [scripts/internal/generate-local-certs.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/generate-local-certs.sh)

### `TNS` — Transparent Network Substrate
- **Definition:** Oracles nätverksteknologi för anslutning mellan klienter och databaser via tnsnames.ora.
- **Roll i detta projekt:** Konfigureras automatiskt i tnsnames.ora och exporteras via TNS_ADMIN till alla terminaler.
- **Officiell referens / Wikipedia:** [Wikipedia: Transparent Network Substrate](https://en.wikipedia.org/wiki/Transparent_Network_Substrate)
- **Relaterade guider och skript:** [tnsnames/tnsnames.ora](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tnsnames/tnsnames.ora), [scripts/register-connections.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/register-connections.sh)

## U

### `UAC` — User Account Control
- **Definition:** Windows säkerhetsfunktion som begär administratörsrättigheter för systemändringar.
- **Roll i detta projekt:** Undviks enligt Regel 14: certifikat registreras på användarnivå utan krav på administratörsrättigheter.
- **Officiell referens / Wikipedia:** [Wikipedia: User Account Control](https://en.wikipedia.org/wiki/User_Account_Control)
- **Relaterade guider och skript:** [scripts/certs/trust-local-cert.cmd](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/certs/trust-local-cert.cmd), [docs/windows-enterprise-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/windows-enterprise-setup-guide.md)

### `UI / UX` — User Interface / User Experience
- **Definition:** Användargränssnitt och användarupplevelse: design, navigering och helhetsintryck för användaren.
- **Roll i detta projekt:** Optimerat i Dev Hub med mörkt tema, snabbknappar och realtidsövervakning.
- **Officiell referens / Wikipedia:** [Wikipedia: UI/UX Design](https://en.wikipedia.org/wiki/User_interface_design)
- **Relaterade guider och skript:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

### `URI / URL` — Uniform Resource Identifier / Locator
- **Definition:** Standardiserad adress för att identifiera och lokalisera resurser på nätverket.
- **Roll i detta projekt:** Verifieras vid uppstart av scripts/check-urls.sh för att säkerställa att tjänster svarar med HTTP 200/302.
- **Officiell referens / Wikipedia:** [Wikipedia: URI / URL](https://en.wikipedia.org/wiki/Uniform_Resource_Identifier)
- **Relaterade guider och skript:** [scripts/check-urls.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-urls.sh)

## V

### `VPN` — Virtual Private Network
- **Definition:** Krypterad nätverkstunnel för säker anslutning till företagets interna nätverk över internet.
- **Roll i detta projekt:** Skyddat i Windows WSL2 via 'dnsTunneling=true' så att företags-VPN inte bryter namnserveruppslag.
- **Officiell referens / Wikipedia:** [Wikipedia: Virtual Private Network](https://en.wikipedia.org/wiki/Virtual_private_network)
- **Relaterade guider och skript:** [docs/windows-enterprise-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/windows-enterprise-setup-guide.md)

### `VS Code` — Visual Studio Code
- **Definition:** Populär och anpassningsbar källkodsredigerare från Microsoft med omfattande tilläggsstöd.
- **Roll i detta projekt:** Primär editor: anslutningar registreras automatiskt till Oracle-tillägget via scripts/register-connections.sh.
- **Officiell referens / Wikipedia:** [Wikipedia: Visual Studio Code](https://en.wikipedia.org/wiki/Visual_Studio_Code)
- **Relaterade guider och skript:** [scripts/register-connections.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/register-connections.sh)

## W

### `WSL / WSL2` — Windows Subsystem for Linux (Version 2)
- **Definition:** Windows integrerade Linux-miljö som kör en äkta Linux-kärna i en lättvikts-VM.
- **Roll i detta projekt:** Krav enligt Regel 14: källkoden måste ligga i det interna ext4-filsystemet, aldrig under /mnt/c/.
- **Officiell referens / Wikipedia:** [Wikipedia: Windows Subsystem for Linux](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux)
- **Relaterade guider och skript:** [docs/windows-enterprise-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/windows-enterprise-setup-guide.md), [setup.cmd](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/setup.cmd)

## Y

### `YAML` — YAML Ain't Markup Language
- **Definition:** Lättläst dataformat för konfigurationsfiler och infrastrukturdeklarationer.
- **Roll i detta projekt:** Krav enligt Regel 11 som enda sanningskälla för databasprofiler och användarbehörigheter.
- **Officiell referens / Wikipedia:** [Wikipedia: YAML](https://en.wikipedia.org/wiki/YAML)
- **Relaterade guider och skript:** [config/profiles/databases/db-oracle.yaml](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/config/profiles/databases/db-oracle.yaml)

