# Arhitektuuri akronüümid ja sõnastik

[ 🇬🇧 English ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/glossary.md) | **[ 🇪🇪 Eesti ]** | [ 🇫🇮 Suomi ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/fi/glossary.md) | [ 🇸🇪 Svenska ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/sv/glossary.md) | [ 🇱🇻 Latviešu ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lv/glossary.md) | [ 🇱🇹 Lietuvių ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lt/glossary.md)

> Põhjalik akronüümide, tehniliste mõistete ja projekti kasutusrollide register.

---

**A–Z Register:** [A](#a) • [B](#b) • [C](#c) • [D](#d) • [E](#e) • [F](#f) • [G](#g) • [H](#h) • [I](#i) • [J](#j) • [K](#k) • [L](#l) • [M](#m) • [N](#n) • [O](#o) • [P](#p) • [R](#r) • [S](#s) • [T](#t) • [U](#u) • [V](#v) • [W](#w) • [Y](#y)

---

## A

### `ADB` — Autonomous Database
- **Definitsioon:** Oracle täishallatud pilveandmebaasi teenus, mis automatiseerib paigalduse, turvapaigad, häälestuse ja skaleerimise.
- **Roll ja kasutus selles projektis:** Hübriidse pilvemigratsiooni sihtkeskkond (BP 10 & 11) mTLS walleti kaudu ilma kohalikku koodi ümber kirjutamata.
- **Ametlik viide / Vikipeedia:** [Oracle Autonomous Database](https://www.oracle.com/autonomous-database/)
- **Seotud juhendid ja skriptid:** [docs/remote-multicloud-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/remote-multicloud-setup-guide.md), [scripts/deploy-remote.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/deploy-remote.sh)

### `APEX` — Oracle Application Express
- **Definitsioon:** Oracle madala koodivajadusega (low-code) veebirakenduste arendusplatvorm, mis töötab otse andmebaasi sees.
- **Roll ja kasutus selles projektis:** Peamine veebiliides Proxy andmebaasis (port 8448/8088), mida juhitakse APEXlang DSL-i ja Git-põhiste SQLcl eksportidega.
- **Ametlik viide / Vikipeedia:** [Wikipedia: Oracle APEX](https://en.wikipedia.org/wiki/Oracle_APEX)
- **Seotud juhendid ja skriptid:** [docs/apex-devhub-test-plan.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/apex-devhub-test-plan.md), [scripts/internal/install-apex.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/install-apex.sh)

### `APFS` — Apple File System
- **Definitsioon:** macOS vaikefailisüsteem, optimeeritud SSD-ketastele, krüpteeringule ja tõmmistele (snapshots).
- **Roll ja kasutus selles projektis:** macOS arendusmasina host-failisüsteem, kus tagatakse tõstutundlikkuse porditavus (Reegel 13) Windows NTFS-iga.
- **Ametlik viide / Vikipeedia:** [Wikipedia: Apple File System](https://en.wikipedia.org/wiki/Apple_File_System)
- **Seotud juhendid ja skriptid:** [tests/unit/test-filename-portability.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/unit/test-filename-portability.sh)

### `API` — Application Programming Interface
- **Definitsioon:** Struktureeritud protokollide ja funktsioonide kogum süsteemide omavaheliseks programmseks suhtluseks.
- **Roll ja kasutus selles projektis:** Ekponeeritud lokaalselt ORDS-i (AutoREST) ja Dev Hub Silla kaudu (/api/status, /api/podman, /api/tests) pordil 8089.
- **Ametlik viide / Vikipeedia:** [Wikipedia: API](https://en.wikipedia.org/wiki/API)
- **Seotud juhendid ja skriptid:** [docs/testing-framework-and-devhub.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/testing-framework-and-devhub.md), [scripts/internal/dev-hub-bridge.py](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/dev-hub-bridge.py)

## B

### `BIP` — Business Intelligence Publisher (Analytics Publisher)
- **Definitsioon:** Ettevõtte tasemel aruandlusmootor pikselintarkade PDF, Excel, RTF ja XML trükivormide suuremahuliseks genereerimiseks.
- **Roll ja kasutus selles projektis:** Integreeritud blueprintides BP 4 ja BP 11 (pordid 9502/6083) automatiseeritud trükimallide ja PDF-ide loomiseks.
- **Ametlik viide / Vikipeedia:** [Oracle Analytics Publisher Docs](https://docs.oracle.com/middleware/12213/bip/)
- **Seotud juhendid ja skriptid:** [docs/publisher-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/publisher-setup.md), [scripts/publisher/restart-publisher.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/publisher/restart-publisher.sh)

### `BP` — Blueprint (Architecture Blueprint)
- **Definitsioon:** Eelkonfigureeritud, idempotentsed arhitektuuritopoloogiad andmebaaside, vahevara, portide ja arendustööriistade halduseks.
- **Roll ja kasutus selles projektis:** 12 kanoonilist keskkonda (BP 0 kuni BP 11), mida saab käivitada käsuga './scripts/deploy-blueprint.sh <ID>' või Dev Hubist.
- **Ametlik viide / Vikipeedia:** [Wikipedia: Blueprint](https://en.wikipedia.org/wiki/Blueprint)
- **Seotud juhendid ja skriptid:** [config/blueprints/README.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/config/blueprints/README.md), [scripts/deploy-blueprint.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/deploy-blueprint.sh)

## C

### `CA` — Certificate Authority
- **Definitsioon:** Usaldusväärne asutus, mis väljastab krüptograafilisi digisertifikaate identiteedi tuvastamiseks ja TLS krüpteeringuks.
- **Roll ja kasutus selles projektis:** Platvorm genereerib kohaliku Root CA (certs/ca.crt), mis registreeritakse operatsioonisüsteemi sertifikaadihoidlasse.
- **Ametlik viide / Vikipeedia:** [Wikipedia: Certificate Authority](https://en.wikipedia.org/wiki/Certificate_authority)
- **Seotud juhendid ja skriptid:** [docs/security.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/security.md), [scripts/certs/trust-local-cert-mac.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/certs/trust-local-cert-mac.sh)

### `CDB` — Container Database
- **Definitsioon:** Oracle mitmeüürilise arhitektuuri juurandmebaas, mis hoiab süsteemset metaandmestikku ja sisaldab ühte või mitut PDB-d.
- **Roll ja kasutus selles projektis:** Standardne CDB$ROOT konteinerdatud 23ai Free DB-s; hallatakse automaatselt init-db-instance.sh skriptiga.
- **Ametlik viide / Vikipeedia:** [Oracle Multitenant Architecture](https://docs.oracle.com/en/database/oracle/oracle-database/23/cncpt/multitenant-architecture.html)
- **Seotud juhendid ja skriptid:** [docs/db-profiles-and-topology.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/db-profiles-and-topology.md), [scripts/internal/init-db-instance.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/init-db-instance.sh)

### `CI/CD` — Continuous Integration / Continuous Deployment
- **Definitsioon:** DevOps automatiseeritud töövood koodi pidevaks kompileerimiseks, testimiseks, valideerimiseks ja toodangusse viimiseks.
- **Roll ja kasutus selles projektis:** Testitav lokaalselt ilma internetita käsuga './tests/test-local-ci.sh' ning Dev Hubi testimisvahelehel 15 komplektiga.
- **Ametlik viide / Vikipeedia:** [Wikipedia: CI/CD](https://en.wikipedia.org/wiki/CI/CD)
- **Seotud juhendid ja skriptid:** [tests/test-local-ci.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/test-local-ci.sh), [docs/devops-lifecycle-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/devops-lifecycle-guide.md)

### `CLI` — Command Line Interface
- **Definitsioon:** Tekstipõhine kasutajaliides käskude käivitamiseks, skriptide automatiseerimiseks ja süsteemiressursside haldamiseks.
- **Roll ja kasutus selles projektis:** Ühtne skriptide paigutus kaustas scripts/ (nt sqlcl.sh, get-password.sh, check-urls.sh) täielikus vastavuses Dev Hub GUI-ga.
- **Ametlik viide / Vikipeedia:** [Wikipedia: Command-Line Interface](https://en.wikipedia.org/wiki/Command-line_interface)
- **Seotud juhendid ja skriptid:** [scripts/README.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/README.md), [scripts/sqlcl.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/sqlcl.sh)

### `CPU` — Central Processing Unit
- **Definitsioon:** Arvuti keskprotsessor, mis viib täide programmikäske ja teostab põhilisi andmetöötlustoiminguid.
- **Roll ja kasutus selles projektis:** Jälgitav reaalajas konteinerite kaupa Dev Hubi juhtpaneelis; 23ai Free DB piiratud 2 tuumaga.
- **Ametlik viide / Vikipeedia:** [Wikipedia: CPU](https://en.wikipedia.org/wiki/Central_processing_unit)
- **Seotud juhendid ja skriptid:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

### `CRLF` — Carriage Return Line Feed (\r\n)
- **Definitsioon:** Kahebaidine reavahetusstandard Windowsi failisüsteemides, mis põhjustab vigu Unixi kestades (/bin/bash^M).
- **Roll ja kasutus selles projektis:** Rangelt välistatud shelliskriptides (.sh) läbi .gitattributes reeglite ja kontrollitud Windowsi testidega (Reegel 14).
- **Ametlik viide / Vikipeedia:** [Wikipedia: Newline (CRLF)](https://en.wikipedia.org/wiki/Newline)
- **Seotud juhendid ja skriptid:** [.gitattributes](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/.gitattributes), [tests/unit/test-windows-enterprise-rules.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/unit/test-windows-enterprise-rules.sh)

## D

### `DBA` — Database Administrator
- **Definitsioon:** IT-spetsialist, kes vastutab andmebaaside paigalduse, turvalisuse, varukoopiate, taaste ja skeemihalduse eest.
- **Roll ja kasutus selles projektis:** Platvorm kaotab pudelikaelad, automatiseerides 100% DBA rutiinidest (paroolid, kasutajad, õigused, taaskäivitused).
- **Ametlik viide / Vikipeedia:** [Wikipedia: Database Administrator](https://en.wikipedia.org/wiki/Database_administrator)
- **Seotud juhendid ja skriptid:** [scripts/internal/apply-profile-users.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/apply-profile-users.sh), [scripts/create-developer.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/create-developer.sh)

### `DR` — Disaster Recovery
- **Definitsioon:** Protsessid ja strateegiad andmebaasi, andmete ja IT-taristu välkkiireks taastamiseks pärast tõrget või riket.
- **Roll ja kasutus selles projektis:** Saavutatakse ~15 sekundiga Golden Snapshotide abil (scripts/snapshots/), taastades rikutud keskkonnad piletivabalt.
- **Ametlik viide / Vikipeedia:** [Wikipedia: Disaster Recovery](https://en.wikipedia.org/wiki/Disaster_recovery)
- **Seotud juhendid ja skriptid:** [scripts/snapshots/README.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/snapshots/README.md), [scripts/snapshots/restore-golden-snapshots.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/snapshots/restore-golden-snapshots.sh)

### `DSL` — Domain-Specific Language
- **Definitsioon:** Spetsialiseeritud programmeerimis- või spetsifitseerimiskeel, mis on kohandatud kindla valdkonna lahendamiseks.
- **Roll ja kasutus selles projektis:** APEXlang (.apx) deklaratiivne keel APEX lehekülgede, plokkide, väljade ja mitmekeelsete märgiste kirjeldamiseks.
- **Ametlik viide / Vikipeedia:** [Wikipedia: Domain-Specific Language](https://en.wikipedia.org/wiki/Domain-specific_language)
- **Seotud juhendid ja skriptid:** [docs/apex-devhub-test-plan.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/apex-devhub-test-plan.md)

## E

### `E2E` — End-to-End Testing
- **Definitsioon:** Testimismetoodika, mis kontrollib kogu tarkvaraprotsessi alates kasutajaliidesest kuni andmebaasi salvestuseni.
- **Roll ja kasutus selles projektis:** Esindatud 6 komplektiga Dev Hubi testimisvahelehel (test-browser-login.sh, test-devhub-lifecycle-full.sh jne).
- **Ametlik viide / Vikipeedia:** [Wikipedia: End-to-End Testing](https://en.wikipedia.org/wiki/Software_testing#End-to-end_testing)
- **Seotud juhendid ja skriptid:** [tests/test-browser-login.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/test-browser-login.sh), [docs/devhub-browser-testing-plan.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/devhub-browser-testing-plan.md)

## F

### `FAT / NTFS` — File Allocation Table / New Technology File System
- **Definitsioon:** Windowsi failisüsteemid, millel on keelatud märgid (<, >, :, ", |, ?, *), tühikud rea lõpus ja reserveeritud nimed (CON, PRN, AUX).
- **Roll ja kasutus selles projektis:** Reguleeritud Reegliga 13 ja testitud kõigi failide lõikes skriptiga tests/unit/test-filename-portability.sh.
- **Ametlik viide / Vikipeedia:** [Wikipedia: NTFS](https://en.wikipedia.org/wiki/NTFS)
- **Seotud juhendid ja skriptid:** [tests/unit/test-filename-portability.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/unit/test-filename-portability.sh)

### `FMW` — Fusion Middleware
- **Definitsioon:** Oracle ettevõtte tasemel tarkvaraperekond, mis sisaldab WebLogic serverit, Forms, Reports ja Publisher vahevara.
- **Roll ja kasutus selles projektis:** Konteinerdatud blueprintides BP 6 & 7 (Forms 14c) ja BP 4 & 11 (Analytics Publisher) kiirete tervisekontrollidega.
- **Ametlik viide / Vikipeedia:** [Wikipedia: Oracle Fusion Middleware](https://en.wikipedia.org/wiki/Oracle_Fusion_Middleware)
- **Seotud juhendid ja skriptid:** [docs/forms-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/forms-setup.md), [docs/publisher-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/publisher-setup.md)

## G

### `GUI` — Graphical User Interface
- **Definitsioon:** Graafiline kasutajaliides, mis võimaldab tarkvaraga suhelda visuaalsete nuppude, vormide ja akende kaudu.
- **Roll ja kasutus selles projektis:** Pakutud Dev Hubi (dev-hub.html) kaudu pordil 8448 koos 1-kliki konteinerihalduse, logide ja esitlustekiga.
- **Ametlik viide / Vikipeedia:** [Wikipedia: GUI](https://en.wikipedia.org/wiki/Graphical_user_interface)
- **Seotud juhendid ja skriptid:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html), [scripts/internal/generate_dev_hub.py](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/generate_dev_hub.py)

## H

### `HTTP / HTTPS` — Hypertext Transfer Protocol (Secure)
- **Definitsioon:** Veebisuhtluse alusprotokoll, mis HTTPS variandis on turvatud TLS krüpteeringuga.
- **Roll ja kasutus selles projektis:** Kõik veebiteenused (Dev Hub :8448, ORDS :8448, Publisher :9502, Forms :9001) töötavad ilma brauseri hoiatusteta.
- **Ametlik viide / Vikipeedia:** [Wikipedia: HTTPS](https://en.wikipedia.org/wiki/HTTPS)
- **Seotud juhendid ja skriptid:** [scripts/check-urls.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-urls.sh)

## I

### `i18n` — Internationalization
- **Definitsioon:** Tarkvara arhitektuurne ülesehitus, mis võimaldab kohandamist erinevatesse keeltesse ilma koodi muutmata.
- **Roll ja kasutus selles projektis:** Kohustuslik vastavalt Reeglile 9: 100% sõnastikusümmeetria 6 keeles (EN, ET, FI, SV, LV, LT) dokumentides ja Dev Hubis.
- **Ametlik viide / Vikipeedia:** [Wikipedia: Internationalization (i18n)](https://en.wikipedia.org/wiki/Internationalization_and_localization)
- **Seotud juhendid ja skriptid:** [tests/unit/test-i18n-translations.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/unit/test-i18n-translations.sh), [scripts/internal/i18n.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/i18n.sh)

### `IDE` — Integrated Development Environment
- **Definitsioon:** Integreeritud arenduskeskkond, mis ühendab koodiredaktori, siluri, terminali ja versioonihalduse ühte programmi.
- **Roll ja kasutus selles projektis:** Toetatud lokaalselt VS Code-is koos Oracle laiendusega ja brauseris Web-IDE kaudu (BP 8, port 8090).
- **Ametlik viide / Vikipeedia:** [Wikipedia: IDE](https://en.wikipedia.org/wiki/Integrated_development_environment)
- **Seotud juhendid ja skriptid:** [docker/web-ide/README.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docker/web-ide/README.md), [scripts/register-connections.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/register-connections.sh)

## J

### `JIT` — Just-In-Time (Decryption / Compilation)
- **Definitsioon:** Töötlusmudel, kus paroolid või tõmmised kompileeritakse/dekrüpteeritakse käitusajal otse mälus ilma kettale salvestamata.
- **Roll ja kasutus selles projektis:** Zero-Trust Reegli 5 alus: paroolid dekrüpteeritakse mällu käsuga ./scripts/get-password.sh ja hävitatakse väljumisel.
- **Ametlik viide / Vikipeedia:** [Wikipedia: Just-In-Time (JIT)](https://en.wikipedia.org/wiki/Just-in-time_compilation)
- **Seotud juhendid ja skriptid:** [scripts/get-password.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/get-password.sh), [docs/security.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/security.md)

### `JSON` — JavaScript Object Notation
- **Definitsioon:** Standardne kergekaaluline tekstipõhine andmevahetusvorming, mida kasutavad API-d ja konfiguratsioonid.
- **Roll ja kasutus selles projektis:** Kasutusel paigaldusmõõdikutes (metrics/setup_benchmarks.json), Dev Hub API-des ja genereeritud HTML-i andmetes.
- **Ametlik viide / Vikipeedia:** [Wikipedia: JSON](https://en.wikipedia.org/wiki/JSON)
- **Seotud juhendid ja skriptid:** [metrics/setup_benchmarks.json](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/metrics/setup_benchmarks.json)

## K

### `KPI` — Key Performance Indicator
- **Definitsioon:** Mõõdetav tulemusnäitaja organisatsiooni, platvormi või IT-süsteemi tõhususe ja eesmärkide hindamiseks.
- **Roll ja kasutus selles projektis:** Kuvatud Dev Hubi esitluskaartidel (nt -85% SEISAKUID, 1-KLIKK KÄIVITUS, ~15S TAASTE, 0€ LITSENTSIKULU).
- **Ametlik viide / Vikipeedia:** [Wikipedia: Key Performance Indicator](https://en.wikipedia.org/wiki/Performance_indicator)
- **Seotud juhendid ja skriptid:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

## L

### `LF` — Line Feed (\n)
- **Definitsioon:** Standardne Unix/Linux ühebaidine reavahetuse märk, mida nõuavad POSIX shelli interpretaatorid.
- **Roll ja kasutus selles projektis:** Kohustuslik vastavalt Reeglile 14 kõigis .sh, .sql, .yaml, .json ja .md failides läbi .gitattributes reeglite.
- **Ametlik viide / Vikipeedia:** [Wikipedia: Newline (LF)](https://en.wikipedia.org/wiki/Newline)
- **Seotud juhendid ja skriptid:** [.gitattributes](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/.gitattributes)

### `LIS` — Laboratory Information System
- **Definitsioon:** Labori infosüsteem tervishoiuasutuste proovide, analüüside ja laboriseadmete andmevahetuse juhtimiseks.
- **Roll ja kasutus selles projektis:** Demonstreeritud Blueprint 3-s (eraldi db-proxy, db-alise ja db-lis baasidega) näidates skeemide isoleeritust.
- **Ametlik viide / Vikipeedia:** [Wikipedia: LIS / LIMS](https://en.wikipedia.org/wiki/Laboratory_information_management_system)
- **Seotud juhendid ja skriptid:** [config/blueprints/.env.bp3-multi-db-lis](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/config/blueprints/.env.bp3-multi-db-lis), [config/profiles/databases/db-lis.yaml](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/config/profiles/databases/db-lis.yaml)

## M

### `mTLS` — Mutual Transport Layer Security
- **Definitsioon:** Kahesuunaline krüptograafiline autentimine, kus nii klient kui ka server kontrollivad vastastikku digisertifikaate.
- **Roll ja kasutus selles projektis:** Võimaldab turvalist pilveühendust OCI Autonomous Database'i (cwallet.sso) ilma avatud krüpteerimata portideta.
- **Ametlik viide / Vikipeedia:** [Wikipedia: Mutual TLS](https://en.wikipedia.org/wiki/Mutual_authentication#mTLS)
- **Seotud juhendid ja skriptid:** [docs/remote-multicloud-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/remote-multicloud-setup-guide.md)

## N

### `noVNC` — HTML5 VNC Client (WebSocket)
- **Definitsioon:** Brauseripõhine VNC klient (HTML5 & WebSockets), mis võimaldab kasutada graafilisi töölauarakendusi veebi vahendusel.
- **Roll ja kasutus selles projektis:** Võimaldab kasutada Oracle Forms Builderit (port 6082) ja BIP Publisher Designerit (port 6083) otse veebibrauseris.
- **Ametlik viide / Vikipeedia:** [Official: noVNC](https://novnc.com/)
- **Seotud juhendid ja skriptid:** [docs/forms-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/forms-setup.md), [docs/publisher-template-builder-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/publisher-template-builder-guide.md)

## O

### `OCI` — Oracle Cloud Infrastructure
- **Definitsioon:** Oracle avalik pilveplatvorm, mis pakub servereid, andmesalvestust, võrguteenuseid ja hallatud andmebaase.
- **Roll ja kasutus selles projektis:** Sihtplatvorm pilvepaigaldusele käsuga scripts/deploy-remote.sh ja hübriidsetele blueprintidele (BP 10 & 11).
- **Ametlik viide / Vikipeedia:** [Wikipedia: Oracle Cloud Infrastructure](https://en.wikipedia.org/wiki/Oracle_Cloud)
- **Seotud juhendid ja skriptid:** [scripts/deploy-remote.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/deploy-remote.sh), [docs/remote-multicloud-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/remote-multicloud-setup-guide.md)

### `OCR` — Oracle Container Registry
- **Definitsioon:** Oracle ametlik konteineritõmmiste register (container-registry.oracle.com), mis hoiab kontrollitud baaside ja vahevara pilte.
- **Roll ja kasutus selles projektis:** Ametlike 23ai Free DB ja ORDS tõmmiste allikas; toetab sisevõrgu Artifactory peeglit REGISTRY_MIRROR kaudu.
- **Ametlik viide / Vikipeedia:** [Official: Oracle Container Registry](https://container-registry.oracle.com/)
- **Seotud juhendid ja skriptid:** [docs/enterprise-onboarding-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/enterprise-onboarding-guide.md)

### `OPatch` — Oracle Interim Patching Tool
- **Definitsioon:** Oracle standardtööriist ametlike vaheturvapaikade ja paranduste paigaldamiseks, kontrolliks ja tagasipööramiseks.
- **Roll ja kasutus selles projektis:** Automatiseeritud skriptis scripts/internal/install-publisher.sh Analytics Publisheri paranduste paigaldamiseks.
- **Ametlik viide / Vikipeedia:** [Oracle Database Patching & Upgrade](https://docs.oracle.com/en/database/oracle/oracle-database/19/install-and-upgrade.html)
- **Seotud juhendid ja skriptid:** [docs/publisher-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/publisher-setup.md)

### `ORDS` — Oracle REST Data Services
- **Definitsioon:** Java vaheserver, mis teisendab SQL ja PL/SQL koodi turvalisteks REST API-deks ning teenindab APEX veebirakendusi.
- **Roll ja kasutus selles projektis:** Peamine API värav pordil 8088/8448; seadistatud eraldiseisvana (BP 5 & 10), et säästa andmebaasi väärtuslikku operatiivmälu.
- **Ametlik viide / Vikipeedia:** [Oracle REST Data Services](https://www.oracle.com/database/technologies/appdev/rest.html)
- **Seotud juhendid ja skriptid:** [docs/ords-profiles-lifecycle.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/ords-profiles-lifecycle.md), [scripts/internal/install-ords-standalone.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/install-ords-standalone.sh)

## P

### `PDB` — Pluggable Database
- **Definitsioon:** Isehaldav skeemide ja objektide kogum Oracle multitenant süsteemis, mis käitub nagu eraldiseisev andmebaas.
- **Roll ja kasutus selles projektis:** Isoleerib domeenid: FREEPDB1 (Proxy/APEX), ALISEPDB (Äriandmed), LIS_PDB ja BIP_PDB vastavalt blueprintidele.
- **Ametlik viide / Vikipeedia:** [Oracle Pluggable Database (PDB)](https://docs.oracle.com/en/database/oracle/oracle-database/23/cncpt/multitenant-architecture.html)
- **Seotud juhendid ja skriptid:** [docs/db-profiles-and-topology.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/db-profiles-and-topology.md), [scripts/internal/resolve-topology.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/resolve-topology.sh)

### `PID` — Process Identifier
- **Definitsioon:** Unikaalne numbriline identifikaator, mille operatsioonisüsteemi tuum omistab igale töötavale protsessile.
- **Roll ja kasutus selles projektis:** Jälgitav Dev Hubi ja taustatööde mootori poolt asünkroonseks protsessijuhtimiseks (Reegel 12).
- **Ametlik viide / Vikipeedia:** [Wikipedia: Process Identifier (PID)](https://en.wikipedia.org/wiki/Process_identifier)
- **Seotud juhendid ja skriptid:** [scripts/internal/dev-hub-bridge.py](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/dev-hub-bridge.py)

## R

### `RAM` — Random Access Memory
- **Definitsioon:** Arvuti kiire operatiivmälu, mida kasutavad aktiivsed programmid, andmebaasi puhvrid ja operatsioonisüsteem.
- **Roll ja kasutus selles projektis:** 23ai Free DB-l on range 2GB RAM piirang; lahtisidestatud kihtidega arhitektuur hoiab süsteemi stabiilse.
- **Ametlik viide / Vikipeedia:** [Wikipedia: RAM](https://en.wikipedia.org/wiki/Random-access_memory)
- **Seotud juhendid ja skriptid:** [docs/enterprise-distributed-architecture.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/enterprise-distributed-architecture.md)

### `RCU` — Repository Creation Utility
- **Definitsioon:** Oracle utiliit Fusion Middleware vahevara (Forms, WebLogic, Publisher) vajalike andmebaasiskeemide loomiseks.
- **Roll ja kasutus selles projektis:** Automatiseeritud taustal konteinerites Forms 14c ja Analytics Publisheri skeemide ettevalmistamiseks.
- **Ametlik viide / Vikipeedia:** [Oracle Repository Creation Utility Docs](https://docs.oracle.com/en/middleware/fusion-middleware/12.2.1.4/rcuug/)
- **Seotud juhendid ja skriptid:** [docs/forms-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/forms-setup.md)

### `REST` — Representational State Transfer
- **Definitsioon:** Olekuvaba veebiarhitektuuri standard hajutatud, skaleeritavate veebiteenuste ja API-de ehitamiseks üle HTTP.
- **Roll ja kasutus selles projektis:** Tagatud ORDS AutoREST-i kaudu, sidudes APEX-i, välised mikroteenused ja Dev Hubi ilma spetsiaalsete draiveriteta.
- **Ametlik viide / Vikipeedia:** [Wikipedia: REST](https://en.wikipedia.org/wiki/REST)
- **Seotud juhendid ja skriptid:** [docs/ords-profiles-lifecycle.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/ords-profiles-lifecycle.md)

### `ROI` — Return on Investment
- **Definitsioon:** Majanduslik tulemuslikkuse mõõdik, mis näitab tehtud investeeringu tasuvust ja rahalist/ajalist säästu.
- **Roll ja kasutus selles projektis:** Rõhutatud Dev Hubi slaidil 5: säästab kuni 40% arenduslitsentsidelt ja kaotab tühja seisvate pilveserverite arved.
- **Ametlik viide / Vikipeedia:** [Wikipedia: Return on Investment](https://en.wikipedia.org/wiki/Return_on_investment)
- **Seotud juhendid ja skriptid:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

## S

### `SDW` — SQL Developer Web (Database Actions)
- **Definitsioon:** ORDS-i sisseehitatud veebipõhine töölaud SQL päringute, andmemudelite, REST teenuste ja seire haldamiseks.
- **Roll ja kasutus selles projektis:** Kättesaadav Dev Hubi 1-kliki linkidest DBA_ADMIN, PROXY_DEV ja ALISE_DEV kasutajatele koos parooli kopeerimisega.
- **Ametlik viide / Vikipeedia:** [Oracle SQL Developer Web](https://docs.oracle.com/en/database/oracle/sql-developer-web/)
- **Seotud juhendid ja skriptid:** [docs/quick-login-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/quick-login-guide.md)

### `SEPS` — Secure External Password Store (Oracle Wallet)
- **Definitsioon:** Oracle krüpteeritud paroolihoidla (cwallet.sso / ewallet.p12), mis võimaldab paroolivaba klientautentimist.
- **Roll ja kasutus selles projektis:** Kohustuslik vastavalt Reeglile 5: kettal 0 parooli; kõik skriptid (sqlcl.sh /@ALIAS) autendivad SEPS walleti abil.
- **Ametlik viide / Vikipeedia:** [Oracle Database Security Guide](https://docs.oracle.com/en/database/oracle/oracle-database/19/dbseg/)
- **Seotud juhendid ja skriptid:** [docs/security.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/security.md), [scripts/get-password.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/get-password.sh), [scripts/check-wallet.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-wallet.sh)

### `SGA / PGA` — System Global Area / Program Global Area
- **Definitsioon:** Oracle andmebaasi mälustruktuurid: SGA on jagatud puhvrite mälu, PGA on igale serveriprotsessile eraldatud mälu.
- **Roll ja kasutus selles projektis:** Dünaamiliselt häälestatud init-db-instance.sql skriptis, et kogumaht mahuks täpselt 2GB Free DB konteineri sisse.
- **Ametlik viide / Vikipeedia:** [Wikipedia: Oracle Database Memory Architecture](https://en.wikipedia.org/wiki/Oracle_Database#Memory_structures)
- **Seotud juhendid ja skriptid:** [scripts/internal/init-db-instance.sql](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/init-db-instance.sql)

### `SPA` — Single Page Application
- **Definitsioon:** Üheleheline veebirakendus, mis uuendab sisu dünaamiliselt brauseri mälus ilma terveid lehti uuesti laadimata.
- **Roll ja kasutus selles projektis:** Dev Hubi (docs/dev-hub.html) arhitektuur: 100% iseseisev, ilma väliste CDN sõltuvusteta, kohene vahelehtede vahetus.
- **Ametlik viide / Vikipeedia:** [Wikipedia: Single-Page Application](https://en.wikipedia.org/wiki/Single-page_application)
- **Seotud juhendid ja skriptid:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

### `SPFILE` — Server Parameter File
- **Definitsioon:** Oracle andmebaasi binaarne parameetrifail, mis säilitab konfiguratsioonimuudatused üle andmebaasi taaskäivituste.
- **Roll ja kasutus selles projektis:** Konfigureeritud db-oracle konteineris mälupiirangute ja APEX proxy autentimise püsivaks määramiseks.
- **Ametlik viide / Vikipeedia:** [Wikipedia: Oracle Initialization Parameters](https://en.wikipedia.org/wiki/Oracle_Database#Initialization_parameters)
- **Seotud juhendid ja skriptid:** [scripts/internal/init-db-instance.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/init-db-instance.sh)

### `SQL` — Structured Query Language
- **Definitsioon:** Standardne päringukeel relatsioonilistes andmebaasides andmete haldamiseks ja pärimiseks.
- **Roll ja kasutus selles projektis:** Kõik platvormi skeemid, kasutajad, tabeliruumid ja õigused paigaldatakse SQL failidega kaustast scripts/internal/.
- **Ametlik viide / Vikipeedia:** [Wikipedia: SQL](https://en.wikipedia.org/wiki/SQL)
- **Seotud juhendid ja skriptid:** [scripts/internal/init-db-instance.sql](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/init-db-instance.sql)

### `SQLcl` — Oracle SQL Developer Command Line
- **Definitsioon:** Kaasaegne Java/GraalVM-põhine käsureatööriist Oracle andmebaasile koos Liquibase'i, automaattäienduse ja Git toega.
- **Roll ja kasutus selles projektis:** Kohustuslik standard CLI vastavalt Reeglile 6 (sqlplus keelatud); kasutab eelisjärjekorras VS Code SQLcl binaari.
- **Ametlik viide / Vikipeedia:** [Oracle SQLcl Official](https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/)
- **Seotud juhendid ja skriptid:** [scripts/sqlcl.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/sqlcl.sh), [docs/quick-login-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/quick-login-guide.md)

### `SSO` — Single Sign-On
- **Definitsioon:** Ühekordne sisselogimine, mis võimaldab kasutajal ühe identiteediga logida mitmesse seotud süsteemi ilma uuesti parooli sisestamata.
- **Roll ja kasutus selles projektis:** Integreeritav ettevõtte keskkondades Azure Entra-ID, ORDS ja APEX autentimisskeemidega.
- **Ametlik viide / Vikipeedia:** [Wikipedia: Single Sign-On](https://en.wikipedia.org/wiki/Single_sign-on)
- **Seotud juhendid ja skriptid:** [tests/test-browser-login.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/test-browser-login.sh)

## T

### `TCO` — Total Cost of Ownership
- **Definitsioon:** Omamise kogukulu: terviklik finantsanalüüs, mis võtab arvesse litsentsid, taristu, halduse ja seisakute kulud.
- **Roll ja kasutus selles projektis:** Vähendatud märkimisväärselt tänu Free DB-le: arenduse ja sisetööriistade litsentsikulud on täpselt 0€.
- **Ametlik viide / Vikipeedia:** [Wikipedia: Total Cost of Ownership](https://en.wikipedia.org/wiki/Total_cost_of_ownership)
- **Seotud juhendid ja skriptid:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

### `TLS` — Transport Layer Security
- **Definitsioon:** Krüptograafiline turvaprotokoll, mis tagab andmeside konfidentsiaalsuse ja tervikluse üle arvutivõrgu.
- **Roll ja kasutus selles projektis:** Genereeritud lokaalselt skriptiga generate-local-certs.sh HTTPS-i jaoks pordil 8448 ja ORDS TLS lõpetamiseks.
- **Ametlik viide / Vikipeedia:** [Wikipedia: Transport Layer Security](https://en.wikipedia.org/wiki/Transport_Layer_Security)
- **Seotud juhendid ja skriptid:** [docs/security.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/security.md), [scripts/internal/generate-local-certs.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/generate-local-certs.sh)

### `TNS` — Transparent Network Substrate
- **Definitsioon:** Oracle võrgutehnoloogia klientrakenduste ja andmebaaside vaheliseks ühenduse loomiseks (tnsnames.ora).
- **Roll ja kasutus selles projektis:** Automaatselt seadistatud failis tnsnames/tnsnames.ora aliastena (FREEPDB1, ALISEPDB) ning eksporditud TNS_ADMIN abil.
- **Ametlik viide / Vikipeedia:** [Wikipedia: Transparent Network Substrate](https://en.wikipedia.org/wiki/Transparent_Network_Substrate)
- **Seotud juhendid ja skriptid:** [tnsnames/tnsnames.ora](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tnsnames/tnsnames.ora), [scripts/register-connections.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/register-connections.sh)

## U

### `UAC` — User Account Control
- **Definitsioon:** Windowsi turvamehhanism, mis küsib administraatori luba enne süsteemsete muudatuste tegemist.
- **Roll ja kasutus selles projektis:** Välditud täielikult Reegli 14 alusel: sertifikaadid lisatakse CurrentUser hoidlasse ilma administraatori õiguste nõudeta.
- **Ametlik viide / Vikipeedia:** [Wikipedia: User Account Control](https://en.wikipedia.org/wiki/User_Account_Control)
- **Seotud juhendid ja skriptid:** [scripts/certs/trust-local-cert.cmd](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/certs/trust-local-cert.cmd), [docs/windows-enterprise-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/windows-enterprise-setup-guide.md)

### `UI / UX` — User Interface / User Experience
- **Definitsioon:** Kasutajaliides ja kasutajakogemus: visuaalne kujundus, juhtnupud, navigeerimine ja süsteemi kasutusmugavus.
- **Roll ja kasutus selles projektis:** Lihvitud Dev Hubis: modernne tume teema, 1-kliki paroolikopeerijad, interaktiivsed slaidid ja reaalajas logid.
- **Ametlik viide / Vikipeedia:** [Wikipedia: UI/UX Design](https://en.wikipedia.org/wiki/User_interface_design)
- **Seotud juhendid ja skriptid:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

### `URI / URL` — Uniform Resource Identifier / Locator
- **Definitsioon:** Standardne veebiaadress võrguressursside (veebilehtede, API otspunktide, dokumentide) tuvastamiseks ja avamiseks.
- **Roll ja kasutus selles projektis:** Valideeritud platvormi käivitusel skriptiga scripts/check-urls.sh, tagades et kõik teenused vastavad HTTP 200/302.
- **Ametlik viide / Vikipeedia:** [Wikipedia: URI / URL](https://en.wikipedia.org/wiki/Uniform_Resource_Identifier)
- **Seotud juhendid ja skriptid:** [scripts/check-urls.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-urls.sh)

## V

### `VPN` — Virtual Private Network
- **Definitsioon:** Krüpteeritud võrgutunnel, mis võimaldab turvalist ligipääsu ettevõtte sisevõrgule üle avaliku interneti.
- **Roll ja kasutus selles projektis:** Kaitstud Windows WSL2 all parameetriga 'dnsTunneling=true' failis .wslconfig, vältides sisevõrgu DNS-i katkemist.
- **Ametlik viide / Vikipeedia:** [Wikipedia: Virtual Private Network](https://en.wikipedia.org/wiki/Virtual_private_network)
- **Seotud juhendid ja skriptid:** [docs/windows-enterprise-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/windows-enterprise-setup-guide.md)

### `VS Code` — Visual Studio Code
- **Definitsioon:** Microsofti arendatud kergekaaluline ja laiendatav koodiredaktor rikkaliku pistikprogrammide ökosüsteemiga.
- **Roll ja kasutus selles projektis:** Peamine arenduskeskkond: registreerib ühendused Oracle laiendusse skriptiga scripts/register-connections.sh.
- **Ametlik viide / Vikipeedia:** [Wikipedia: Visual Studio Code](https://en.wikipedia.org/wiki/Visual_Studio_Code)
- **Seotud juhendid ja skriptid:** [scripts/register-connections.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/register-connections.sh)

## W

### `WSL / WSL2` — Windows Subsystem for Linux (Version 2)
- **Definitsioon:** Microsoft Windowsi sisseehitatud Linuxi alamsüsteem, mis käitab ehtsat Linuxi tuuma virtuaalmasinas.
- **Roll ja kasutus selles projektis:** Kohustuslik vastavalt Reeglile 14: kood peab asuma natiivses ext4 failisüsteemis (~/ või /home/), mitte /mnt/c/ all.
- **Ametlik viide / Vikipeedia:** [Wikipedia: Windows Subsystem for Linux](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux)
- **Seotud juhendid ja skriptid:** [docs/windows-enterprise-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/windows-enterprise-setup-guide.md), [setup.cmd](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/setup.cmd)

## Y

### `YAML` — YAML Ain't Markup Language
- **Definitsioon:** Inimloetav andmevorming, mida kasutatakse konfiguratsioonifailides ja taristu deklaratsioonides.
- **Roll ja kasutus selles projektis:** Kohustuslik vastavalt Reeglile 11 andmebaaside profiilide (config/profiles/databases/*.yaml) ja kasutajate ainsa tõeallikana.
- **Ametlik viide / Vikipeedia:** [Wikipedia: YAML](https://en.wikipedia.org/wiki/YAML)
- **Seotud juhendid ja skriptid:** [config/profiles/databases/db-oracle.yaml](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/config/profiles/databases/db-oracle.yaml)

