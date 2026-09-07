# Arkkitehtuurisanasto ja lyhenteet

[ 🇬🇧 English ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/glossary.md) | [ 🇪🇪 Eesti ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/et/glossary.md) | **[ 🇫🇮 Suomi ]** | [ 🇸🇪 Svenska ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/sv/glossary.md) | [ 🇱🇻 Latviešu ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lv/glossary.md) | [ 🇱🇹 Lietuvių ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lt/glossary.md)

> Kattava luettelo lyhenteistä, teknisistä määritelmistä ja käytännön rooleista projektissa.

---

**A–Z Register:** [A](#a) • [B](#b) • [C](#c) • [D](#d) • [E](#e) • [F](#f) • [G](#g) • [H](#h) • [I](#i) • [J](#j) • [K](#k) • [L](#l) • [M](#m) • [N](#n) • [O](#o) • [P](#p) • [R](#r) • [S](#s) • [T](#t) • [U](#u) • [V](#v) • [W](#w) • [Y](#y)

---

## A

### `ADB` — Autonomous Database
- **Määritelmä:** Oraclen täysin hallinnoitu pilvitietokanta, joka automatisoi ylläpidon, päivitykset ja skaalauksen.
- **Rooli tässä projektissa:** Hybridi-pilvimigraation kohde (BP 10 & 11) mTLS-lompakkoyhteydellä ilman paikallisen koodin muuttamista.
- **Virallinen viite / Wikipedia:** [Oracle Autonomous Database](https://www.oracle.com/autonomous-database/)
- **Liittyvät ohjeet ja skriptit:** [docs/remote-multicloud-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/remote-multicloud-setup-guide.md), [scripts/deploy-remote.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/deploy-remote.sh)

### `APEX` — Oracle Application Express
- **Määritelmä:** Oraclen low-code-sovelluskehitysalusta yrityssovelluksille suoraan tietokannan sisällä.
- **Rooli tässä projektissa:** Keskeinen käyttöliittymä Proxy DB:ssä (portti 8448/8088), ohjataan APEXlang DSL:llä ja Git-vienneillä.
- **Virallinen viite / Wikipedia:** [Wikipedia: Oracle APEX](https://en.wikipedia.org/wiki/Oracle_APEX)
- **Liittyvät ohjeet ja skriptit:** [docs/apex-devhub-test-plan.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/apex-devhub-test-plan.md), [scripts/internal/install-apex.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/install-apex.sh)

### `APFS` — Apple File System
- **Määritelmä:** macOS-käyttöjärjestelmän moderni tiedostojärjestelmä SSD-levyille ja pikavedoksille.
- **Rooli tässä projektissa:** macOS-kehitysympäristön tiedostojärjestelmä, jossa varmistetaan siirrettävyys (Sääntö 13) Windows NTFS:ään.
- **Virallinen viite / Wikipedia:** [Wikipedia: Apple File System](https://en.wikipedia.org/wiki/Apple_File_System)
- **Liittyvät ohjeet ja skriptit:** [tests/unit/test-filename-portability.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/unit/test-filename-portability.sh)

### `API` — Application Programming Interface
- **Määritelmä:** Määritelty rajapinta ohjelmistojen ja järjestelmien väliseen viestintään.
- **Rooli tässä projektissa:** Käytössä paikallisesti ORDS-palvelun ja Dev Hub Bridgen (/api/status jne.) kautta portissa 8089.
- **Virallinen viite / Wikipedia:** [Wikipedia: API](https://en.wikipedia.org/wiki/API)
- **Liittyvät ohjeet ja skriptit:** [docs/testing-framework-and-devhub.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/testing-framework-and-devhub.md), [scripts/internal/dev-hub-bridge.py](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/dev-hub-bridge.py)

## B

### `BIP` — Business Intelligence Publisher (Analytics Publisher)
- **Määritelmä:** Yritystason raportointimoottori pikselintarkkojen PDF-, Excel- ja XML-tulosteiden tuottamiseen.
- **Rooli tässä projektissa:** Integroitu malleissa BP 4 & 11 (portit 9502/6083) automatisoituun raporttien tulostukseen.
- **Virallinen viite / Wikipedia:** [Oracle Analytics Publisher Docs](https://docs.oracle.com/middleware/12213/bip/)
- **Liittyvät ohjeet ja skriptit:** [docs/publisher-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/publisher-setup.md), [scripts/publisher/restart-publisher.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/publisher/restart-publisher.sh)

### `BP` — Blueprint (Architecture Blueprint)
- **Määritelmä:** Ennalta määritellyt, idempotentit arkkitehtuuritietueet tietokannoille, väliohjelmistoille ja porteille.
- **Rooli tässä projektissa:** 12 kanonista ympäristöä (BP 0 - BP 11), jotka käynnistetään './scripts/deploy-blueprint.sh <ID>' tai Dev Hubista.
- **Virallinen viite / Wikipedia:** [Wikipedia: Blueprint](https://en.wikipedia.org/wiki/Blueprint)
- **Liittyvät ohjeet ja skriptit:** [config/blueprints/README.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/config/blueprints/README.md), [scripts/deploy-blueprint.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/deploy-blueprint.sh)

## C

### `CA` — Certificate Authority
- **Määritelmä:** Luotettu taho, joka myöntää digitaalisia varmenteita TLS-salauksen ja identiteetin varmentamiseen.
- **Rooli tässä projektissa:** Alusta luo paikallisen Root CA:n (certs/ca.crt), joka asennetaan käyttöjärjestelmän luottamusvarastoon.
- **Virallinen viite / Wikipedia:** [Wikipedia: Certificate Authority](https://en.wikipedia.org/wiki/Certificate_authority)
- **Liittyvät ohjeet ja skriptit:** [docs/security.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/security.md), [scripts/certs/trust-local-cert-mac.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/certs/trust-local-cert-mac.sh)

### `CDB` — Container Database
- **Määritelmä:** Oraclen multitenant-arkkitehtuurin juuritietokanta, joka sisältää yhden tai useamman PDB-tietokannan.
- **Rooli tässä projektissa:** Vakio CDB$ROOT kontitetussa 23ai Free DB:ssä; alustetaan automaattisesti init-db-instance.sh -skriptillä.
- **Virallinen viite / Wikipedia:** [Oracle Multitenant Architecture](https://docs.oracle.com/en/database/oracle/oracle-database/23/cncpt/multitenant-architecture.html)
- **Liittyvät ohjeet ja skriptit:** [docs/db-profiles-and-topology.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/db-profiles-and-topology.md), [scripts/internal/init-db-instance.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/init-db-instance.sh)

### `CI/CD` — Continuous Integration / Continuous Deployment
- **Määritelmä:** DevOps-automaatioputki koodin jatkuvaan integrointiin, testaukseen ja turvalliseen julkaisuun.
- **Rooli tässä projektissa:** Testattavissa paikallisesti './tests/test-local-ci.sh' -komennolla ja Dev Hubin Testaus-välilehdellä 15 sarjalla.
- **Virallinen viite / Wikipedia:** [Wikipedia: CI/CD](https://en.wikipedia.org/wiki/CI/CD)
- **Liittyvät ohjeet ja skriptit:** [tests/test-local-ci.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/test-local-ci.sh), [docs/devops-lifecycle-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/devops-lifecycle-guide.md)

### `CLI` — Command Line Interface
- **Määritelmä:** Tekstipohjainen komentoliittymä ohjelmien suorittamiseen ja järjestelmän hallintaan.
- **Rooli tässä projektissa:** Yhdenmukainen komentorivikattaus scripts/-hakemistossa (sqlcl.sh, get-password.sh jne.) täydellä GUI-pariteetilla.
- **Virallinen viite / Wikipedia:** [Wikipedia: Command-Line Interface](https://en.wikipedia.org/wiki/Command-line_interface)
- **Liittyvät ohjeet ja skriptit:** [scripts/README.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/README.md), [scripts/sqlcl.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/sqlcl.sh)

### `CPU` — Central Processing Unit
- **Määritelmä:** Tietokoneen keskusyksikkö, joka suorittaa ohjelmakäskyt ja käsittelee tietoa.
- **Rooli tässä projektissa:** Valvotaan konttikohtaisesti Dev Hubissa; 23ai Free DB toimii tehokkaasti 2 vCPU:n rajoissa.
- **Virallinen viite / Wikipedia:** [Wikipedia: CPU](https://en.wikipedia.org/wiki/Central_processing_unit)
- **Liittyvät ohjeet ja skriptit:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

### `CRLF` — Carriage Return Line Feed (\r\n)
- **Määritelmä:** Windows-tiedostojärjestelmien kahden tavun rivinvaihto, joka aiheuttaa virheitä Unix-skripteissä.
- **Rooli tässä projektissa:** Ehdottomasti kielletty shell-skripteissä (.sh) .gitattributes-määrityksellä ja Windows-testeillä (Sääntö 14).
- **Virallinen viite / Wikipedia:** [Wikipedia: Newline (CRLF)](https://en.wikipedia.org/wiki/Newline)
- **Liittyvät ohjeet ja skriptit:** [.gitattributes](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/.gitattributes), [tests/unit/test-windows-enterprise-rules.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/unit/test-windows-enterprise-rules.sh)

## D

### `DBA` — Database Administrator
- **Määritelmä:** Tietokanta-asiantuntija, joka vastaa tietokantojen asennuksesta, suorituskyvystä ja varmuuskopioista.
- **Rooli tässä projektissa:** Alusta poistaa kehittäjien odotusajat automatisoimalla DBA-rutiinit (lompakot, käyttäjät, oikeudet).
- **Virallinen viite / Wikipedia:** [Wikipedia: Database Administrator](https://en.wikipedia.org/wiki/Database_administrator)
- **Liittyvät ohjeet ja skriptit:** [scripts/internal/apply-profile-users.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/apply-profile-users.sh), [scripts/create-developer.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/create-developer.sh)

### `DR` — Disaster Recovery
- **Määritelmä:** Menetelmät ja valmiudet järjestelmien ja datan palauttamiseksi vakavien häiriöiden jälkeen.
- **Rooli tässä projektissa:** Toteutetaan ~15 sekunnissa Golden Snapshot -pikapalautuksella (scripts/snapshots/) ilman DBA-tikettejä.
- **Virallinen viite / Wikipedia:** [Wikipedia: Disaster Recovery](https://en.wikipedia.org/wiki/Disaster_recovery)
- **Liittyvät ohjeet ja skriptit:** [scripts/snapshots/README.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/snapshots/README.md), [scripts/snapshots/restore-golden-snapshots.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/snapshots/restore-golden-snapshots.sh)

### `DSL` — Domain-Specific Language
- **Määritelmä:** Tiettyyn sovellusalueeseen räätälöity erikoiskieli (kuten deklaratiivinen määrityskieli).
- **Rooli tässä projektissa:** APEXlang (.apx) deklaratiivinen kieli APEX-sivujen, lohkojen ja käännösten määrittämiseen.
- **Virallinen viite / Wikipedia:** [Wikipedia: Domain-Specific Language](https://en.wikipedia.org/wiki/Domain-specific_language)
- **Liittyvät ohjeet ja skriptit:** [docs/apex-devhub-test-plan.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/apex-devhub-test-plan.md)

## E

### `E2E` — End-to-End Testing
- **Määritelmä:** Testausmenetelmä, joka todentaa sovelluksen koko toimintaketjun käyttöliittymästä tietokantaan.
- **Rooli tässä projektissa:** Käytössä 6 testisatsina Dev Hubin testausvälilehdellä todentaen APEX-kirjautumiset ja elinkaaren.
- **Virallinen viite / Wikipedia:** [Wikipedia: End-to-End Testing](https://en.wikipedia.org/wiki/Software_testing#End-to-end_testing)
- **Liittyvät ohjeet ja skriptit:** [tests/test-browser-login.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/test-browser-login.sh), [docs/devhub-browser-testing-plan.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/devhub-browser-testing-plan.md)

## F

### `FAT / NTFS` — File Allocation Table / New Technology File System
- **Määritelmä:** Windows-tiedostojärjestelmät, joissa on varattuja merkkejä ja laitenimiä (CON, PRN, AUX).
- **Rooli tässä projektissa:** Määritelty Säännössä 13 ja valvottu repositorion tiedostoissa siirrettävyystesteillä.
- **Virallinen viite / Wikipedia:** [Wikipedia: NTFS](https://en.wikipedia.org/wiki/NTFS)
- **Liittyvät ohjeet ja skriptit:** [tests/unit/test-filename-portability.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/unit/test-filename-portability.sh)

### `FMW` — Fusion Middleware
- **Määritelmä:** Oraclen väliohjelmistoperhe, johon kuuluvat WebLogic, Forms ja Analytics Publisher.
- **Rooli tässä projektissa:** Kontitettu malleissa BP 6 & 7 (Forms) ja BP 4 & 11 (Publisher) automaattisella valvonnalla.
- **Virallinen viite / Wikipedia:** [Wikipedia: Oracle Fusion Middleware](https://en.wikipedia.org/wiki/Oracle_Fusion_Middleware)
- **Liittyvät ohjeet ja skriptit:** [docs/forms-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/forms-setup.md), [docs/publisher-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/publisher-setup.md)

## G

### `GUI` — Graphical User Interface
- **Määritelmä:** Graafinen käyttöliittymä visuaalisilla painikkeilla ja lomakkeilla komentorivin sijaan.
- **Rooli tässä projektissa:** Tarjotaan Dev Hubin (dev-hub.html) kautta sisältäen konttitoiminnot, lokit ja esityksen.
- **Virallinen viite / Wikipedia:** [Wikipedia: GUI](https://en.wikipedia.org/wiki/Graphical_user_interface)
- **Liittyvät ohjeet ja skriptit:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html), [scripts/internal/generate_dev_hub.py](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/generate_dev_hub.py)

## H

### `HTTP / HTTPS` — Hypertext Transfer Protocol (Secure)
- **Määritelmä:** Verkkoliikenteen perusprotokolla, joka HTTPS-muodossa on salattu TLS-yhteydellä.
- **Rooli tässä projektissa:** Kaikki alustan verkkopalvelut toimivat turvallisesti ilman selaimen varoituksia.
- **Virallinen viite / Wikipedia:** [Wikipedia: HTTPS](https://en.wikipedia.org/wiki/HTTPS)
- **Liittyvät ohjeet ja skriptit:** [scripts/check-urls.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-urls.sh)

## I

### `i18n` — Internationalization
- **Määritelmä:** Ohjelmiston suunnittelu useille kielille ja alueille ilman ohjelmakoodin muutoksia.
- **Rooli tässä projektissa:** Säännön 9 mukaisesti taataan 100% symmetria 6 kielellä (EN, ET, FI, SV, LV, LT).
- **Virallinen viite / Wikipedia:** [Wikipedia: Internationalization (i18n)](https://en.wikipedia.org/wiki/Internationalization_and_localization)
- **Liittyvät ohjeet ja skriptit:** [tests/unit/test-i18n-translations.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/unit/test-i18n-translations.sh), [scripts/internal/i18n.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/i18n.sh)

### `IDE` — Integrated Development Environment
- **Määritelmä:** Integroitu kehitysympäristö, joka yhdistää koodieditorin, kääntäjän ja virheenkorjauksen.
- **Rooli tässä projektissa:** Tuettu paikallisesti VS Codella ja selaimessa toimivalla Web-IDE:llä (BP 8, portti 8090).
- **Virallinen viite / Wikipedia:** [Wikipedia: IDE](https://en.wikipedia.org/wiki/Integrated_development_environment)
- **Liittyvät ohjeet ja skriptit:** [docker/web-ide/README.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docker/web-ide/README.md), [scripts/register-connections.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/register-connections.sh)

## J

### `JIT` — Just-In-Time (Decryption / Compilation)
- **Määritelmä:** Käsittelymalli, jossa tiedot tai salasanat avataan muistissa vasta tarvehetkellä ilman tallennusta levylle.
- **Rooli tässä projektissa:** Zero-Trust-säännön 5 perusta: salasanat avataan vain muistissa ja tuhotaan heti ajon päätyttyä.
- **Virallinen viite / Wikipedia:** [Wikipedia: Just-In-Time (JIT)](https://en.wikipedia.org/wiki/Just-in-time_compilation)
- **Liittyvät ohjeet ja skriptit:** [scripts/get-password.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/get-password.sh), [docs/security.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/security.md)

### `JSON` — JavaScript Object Notation
- **Määritelmä:** Kevyt, tekstipohjainen tiedonsiirtomuoto, jota käytetään rajapinnoissa ja konfiguraatioissa.
- **Rooli tässä projektissa:** Käytössä suorituskykymittareissa, Dev Hubin REST API -vastauksissa ja koostetussa HTML-tiedostossa.
- **Virallinen viite / Wikipedia:** [Wikipedia: JSON](https://en.wikipedia.org/wiki/JSON)
- **Liittyvät ohjeet ja skriptit:** [metrics/setup_benchmarks.json](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/metrics/setup_benchmarks.json)

## K

### `KPI` — Key Performance Indicator
- **Määritelmä:** Määrällinen suorituskykymittari alustan tai prosessin tehokkuuden arviointiin.
- **Rooli tässä projektissa:** Näytetään Dev Hubin esityskorteissa (esim. -85% SEISOKKEJA, 1-KLIKKAAUKSEN STARTTI jne.).
- **Virallinen viite / Wikipedia:** [Wikipedia: Key Performance Indicator](https://en.wikipedia.org/wiki/Performance_indicator)
- **Liittyvät ohjeet ja skriptit:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

## L

### `LF` — Line Feed (\n)
- **Määritelmä:** Unix/Linux-standardin mukainen yhden tavun rivinvaihtomerkki shell-tulkeille.
- **Rooli tässä projektissa:** Pakollinen Säännön 14 mukaan kaikissa .sh, .sql ja .yaml -tiedostoissa .gitattributes-määrityksellä.
- **Virallinen viite / Wikipedia:** [Wikipedia: Newline (LF)](https://en.wikipedia.org/wiki/Newline)
- **Liittyvät ohjeet ja skriptit:** [.gitattributes](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/.gitattributes)

### `LIS` — Laboratory Information System
- **Määritelmä:** Laboratoriotietojärjestelmä näytteiden käsittelyyn, laiteintegraatioihin ja analyysituloksiin.
- **Rooli tässä projektissa:** Käytössä Blueprint 3 -monikantamallissa (db-proxy, db-alise ja db-lis) eristäen tietokannat.
- **Virallinen viite / Wikipedia:** [Wikipedia: LIS / LIMS](https://en.wikipedia.org/wiki/Laboratory_information_management_system)
- **Liittyvät ohjeet ja skriptit:** [config/blueprints/.env.bp3-multi-db-lis](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/config/blueprints/.env.bp3-multi-db-lis), [config/profiles/databases/db-lis.yaml](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/config/profiles/databases/db-lis.yaml)

## M

### `mTLS` — Mutual Transport Layer Security
- **Määritelmä:** Kaksisuuntainen TLS-autentikointi, jossa sekä asiakas että palvelin todentavat toisensa varmenteilla.
- **Rooli tässä projektissa:** Mahdollistaa turvallisen yhteyden OCI Autonomous Databaseen lompakon (cwallet.sso) kautta.
- **Virallinen viite / Wikipedia:** [Wikipedia: Mutual TLS](https://en.wikipedia.org/wiki/Mutual_authentication#mTLS)
- **Liittyvät ohjeet ja skriptit:** [docs/remote-multicloud-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/remote-multicloud-setup-guide.md)

## N

### `noVNC` — HTML5 VNC Client (WebSocket)
- **Määritelmä:** Selainpohjainen HTML5 VNC -asiakasohjelma graafisten työpöytäsovellusten etäkäyttöön ilman lisäosia.
- **Rooli tässä projektissa:** Tuo Oracle Forms Builderin (portti 6082) ja Publisher Designerin (6083) suoraan selaimeen ilman asennusta.
- **Virallinen viite / Wikipedia:** [Official: noVNC](https://novnc.com/)
- **Liittyvät ohjeet ja skriptit:** [docs/forms-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/forms-setup.md), [docs/publisher-template-builder-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/publisher-template-builder-guide.md)

## O

### `OCI` — Oracle Cloud Infrastructure
- **Määritelmä:** Oraclen yritystason julkipilvialusta laskennalle, tallennukselle ja hallinnoiduille tietokannoille.
- **Rooli tässä projektissa:** Kohdealusta pilvijulkaisuille skriptillä scripts/deploy-remote.sh ja hybridi-blueprinteille (BP 10 & 11).
- **Virallinen viite / Wikipedia:** [Wikipedia: Oracle Cloud Infrastructure](https://en.wikipedia.org/wiki/Oracle_Cloud)
- **Liittyvät ohjeet ja skriptit:** [scripts/deploy-remote.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/deploy-remote.sh), [docs/remote-multicloud-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/remote-multicloud-setup-guide.md)

### `OCR` — Oracle Container Registry
- **Määritelmä:** Oraclen virallinen konttirekisteri luotetuille tietokanta- ja väliohjelmistokuville.
- **Rooli tässä projektissa:** Virallisten 23ai Free DB ja ORDS -kuvien lähde; tukee yrityksen Artifactory-peiliä REGISTRY_MIRROR-muuttujalla.
- **Virallinen viite / Wikipedia:** [Official: Oracle Container Registry](https://container-registry.oracle.com/)
- **Liittyvät ohjeet ja skriptit:** [docs/enterprise-onboarding-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/enterprise-onboarding-guide.md)

### `OPatch` — Oracle Interim Patching Tool
- **Määritelmä:** Oraclen virallinen työkalu tietoturva- ja korjauspäivitysten asentamiseen ja hallintaan.
- **Rooli tässä projektissa:** Automatisoitu Publisher-asennuksessa päivitysten viemiseksi suoraan konttiin.
- **Virallinen viite / Wikipedia:** [Oracle Database Patching & Upgrade](https://docs.oracle.com/en/database/oracle/oracle-database/19/install-and-upgrade.html)
- **Liittyvät ohjeet ja skriptit:** [docs/publisher-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/publisher-setup.md)

### `ORDS` — Oracle REST Data Services
- **Määritelmä:** Sovelluspalvelinsilta, joka muuntaa SQL/PLSQL-koodin REST-rajapinnoiksi ja jakelee APEX-sovellukset.
- **Rooli tässä projektissa:** Keskeinen API-yhdyskäytävä portissa 8088/8448; ajetaan erillään tietokannan muistin säästämiseksi.
- **Virallinen viite / Wikipedia:** [Oracle REST Data Services](https://www.oracle.com/database/technologies/appdev/rest.html)
- **Liittyvät ohjeet ja skriptit:** [docs/ords-profiles-lifecycle.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/ords-profiles-lifecycle.md), [scripts/internal/install-ords-standalone.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/install-ords-standalone.sh)

## P

### `PDB` — Pluggable Database
- **Määritelmä:** Itsenäinen skeemojen ja objektien kokonaisuus, joka näkyy asiakkaille erillisenä tietokantana.
- **Rooli tässä projektissa:** Eristää sovellusalueet: FREEPDB1 (Proxy/APEX), ALISEPDB (Liiketoimintadata), LIS_PDB jne.
- **Virallinen viite / Wikipedia:** [Oracle Pluggable Database (PDB)](https://docs.oracle.com/en/database/oracle/oracle-database/23/cncpt/multitenant-architecture.html)
- **Liittyvät ohjeet ja skriptit:** [docs/db-profiles-and-topology.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/db-profiles-and-topology.md), [scripts/internal/resolve-topology.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/resolve-topology.sh)

### `PID` — Process Identifier
- **Määritelmä:** Käyttöjärjestelmän kullekin käynnissä olevalle prosessille myöntämä yksilöllinen tunniste.
- **Rooli tässä projektissa:** Käytössä taustaprosessien valvonnassa ja tehtävien hallinnassa (Sääntö 12).
- **Virallinen viite / Wikipedia:** [Wikipedia: Process Identifier (PID)](https://en.wikipedia.org/wiki/Process_identifier)
- **Liittyvät ohjeet ja skriptit:** [scripts/internal/dev-hub-bridge.py](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/dev-hub-bridge.py)

## R

### `RAM` — Random Access Memory
- **Määritelmä:** Tietokoneen nopea keskusmuisti käynnissä oleville ohjelmille ja tietokantapuskureille.
- **Rooli tässä projektissa:** 23ai Free DB:ssä on 2GB RAM -rajoitus; jaettu arkkitehtuuri estää muistin loppumisen.
- **Virallinen viite / Wikipedia:** [Wikipedia: RAM](https://en.wikipedia.org/wiki/Random-access_memory)
- **Liittyvät ohjeet ja skriptit:** [docs/enterprise-distributed-architecture.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/enterprise-distributed-architecture.md)

### `RCU` — Repository Creation Utility
- **Määritelmä:** Oraclen työkalu Fusion Middleware -tuotteiden tarvitsemien tietokantaskeemoja luontiin.
- **Rooli tässä projektissa:** Automatisoitu Forms 14c ja Publisher -skeemojen alustukseen ilman manuaalisia vaiheita.
- **Virallinen viite / Wikipedia:** [Oracle Repository Creation Utility Docs](https://docs.oracle.com/en/middleware/fusion-middleware/12.2.1.4/rcuug/)
- **Liittyvät ohjeet ja skriptit:** [docs/forms-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/forms-setup.md)

### `REST` — Representational State Transfer
- **Määritelmä:** Tilaton arkkitehtuurimalli hajautettujen verkkopalveluiden ja rajapintojen rakentamiseen HTTP:n yli.
- **Rooli tässä projektissa:** Toteutettu ORDS AutoREST -toiminnolla yhdistäen palvelut ilman raskaita tietokanta-ajureita.
- **Virallinen viite / Wikipedia:** [Wikipedia: REST](https://en.wikipedia.org/wiki/REST)
- **Liittyvät ohjeet ja skriptit:** [docs/ords-profiles-lifecycle.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/ords-profiles-lifecycle.md)

### `ROI` — Return on Investment
- **Määritelmä:** Taloudellinen mittari, joka arvioi tehdyn sijoituksen tuottavuutta ja tehokkuutta suhteessa kustannuksiin.
- **Rooli tässä projektissa:** Korostettu diassa 5: säästää jopa 40% kehityslisenssikuluista poistaen turhat pilvimaksut.
- **Virallinen viite / Wikipedia:** [Wikipedia: Return on Investment](https://en.wikipedia.org/wiki/Return_on_investment)
- **Liittyvät ohjeet ja skriptit:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

## S

### `SDW` — SQL Developer Web (Database Actions)
- **Määritelmä:** ORDS-palvelun selainpohjainen käyttöliittymä SQL-kyselyille, REST-määrityksille ja tietokannan valvonnalle.
- **Rooli tässä projektissa:** Käytettävissä Dev Hubista yhdellä klikkauksella DBA-, PROXY- ja ALISE-käyttäjille automaattikopioinnilla.
- **Virallinen viite / Wikipedia:** [Oracle SQL Developer Web](https://docs.oracle.com/en/database/oracle/sql-developer-web/)
- **Liittyvät ohjeet ja skriptit:** [docs/quick-login-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/quick-login-guide.md)

### `SEPS` — Secure External Password Store (Oracle Wallet)
- **Määritelmä:** Oraclen AES-256-salattu lompakko (cwallet.sso), joka mahdollistaa salasanattoman todennuksen.
- **Rooli tässä projektissa:** Pakollinen Säännön 5 mukaan: nolla selväkielistä salasanaa; kaikki skriptit käyttävät SEPS-lompakkoa.
- **Virallinen viite / Wikipedia:** [Oracle Database Security Guide](https://docs.oracle.com/en/database/oracle/oracle-database/19/dbseg/)
- **Liittyvät ohjeet ja skriptit:** [docs/security.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/security.md), [scripts/get-password.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/get-password.sh), [scripts/check-wallet.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-wallet.sh)

### `SGA / PGA` — System Global Area / Program Global Area
- **Määritelmä:** Oraclen keskeiset muistirakenteet: SGA jaettuna kaikille prosesseille ja PGA palvelinprosessikohtaisena.
- **Rooli tässä projektissa:** Hienosäädetty automaattisesti siten, että kokonaismuisti pysyy 2GB Free DB -rajoissa.
- **Virallinen viite / Wikipedia:** [Wikipedia: Oracle Database Memory Architecture](https://en.wikipedia.org/wiki/Oracle_Database#Memory_structures)
- **Liittyvät ohjeet ja skriptit:** [scripts/internal/init-db-instance.sql](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/init-db-instance.sql)

### `SPA` — Single Page Application
- **Määritelmä:** Yhden sivun verkkosovellus, joka päivittää näkymää dynaamisesti lataamatta koko sivua uudelleen.
- **Rooli tässä projektissa:** Dev Hubin arkkitehtuuri: täysin itsenäinen, ei ulkoisia CDN-riippuvuuksia, välitön välilehtien vaihto.
- **Virallinen viite / Wikipedia:** [Wikipedia: Single-Page Application](https://en.wikipedia.org/wiki/Single-page_application)
- **Liittyvät ohjeet ja skriptit:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

### `SPFILE` — Server Parameter File
- **Määritelmä:** Oraclen binaarinen parametritiedosto, joka säilyttää asetukset tietokannan uudelleenkäynnistysten yli.
- **Rooli tässä projektissa:** Määritetty db-oracle-kontissa varmistamaan optimaaliset muistiasetukset ja APEX-välityksen.
- **Virallinen viite / Wikipedia:** [Wikipedia: Oracle Initialization Parameters](https://en.wikipedia.org/wiki/Oracle_Database#Initialization_parameters)
- **Liittyvät ohjeet ja skriptit:** [scripts/internal/init-db-instance.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/init-db-instance.sh)

### `SQL` — Structured Query Language
- **Määritelmä:** Standardi kyselykieli relaatiotietokantojen tietojen hallintaan ja kyselyihin.
- **Rooli tässä projektissa:** Kaikki skeemat, käyttäjät ja oikeudet ajetaan SQL-skripteillä scripts/internal/-hakemistosta.
- **Virallinen viite / Wikipedia:** [Wikipedia: SQL](https://en.wikipedia.org/wiki/SQL)
- **Liittyvät ohjeet ja skriptit:** [scripts/internal/init-db-instance.sql](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/init-db-instance.sql)

### `SQLcl` — Oracle SQL Developer Command Line
- **Määritelmä:** Moderni Oraclen komentorivityökalu inline-muokkauksella, Liquibase-tuella ja Git-integraatiolla.
- **Rooli tässä projektissa:** Pakollinen standardi Säännön 6 mukaan (sqlplus kielletty); käyttää ensisijaisesti VS Coden SQLcl-binaaria.
- **Virallinen viite / Wikipedia:** [Oracle SQLcl Official](https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/)
- **Liittyvät ohjeet ja skriptit:** [scripts/sqlcl.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/sqlcl.sh), [docs/quick-login-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/quick-login-guide.md)

### `SSO` — Single Sign-On
- **Määritelmä:** Kertakirjautuminen, joka mahdollistaa pääsyn useisiin järjestelmiin yhdellä todennuksella.
- **Rooli tässä projektissa:** Integroitu yrityskäytössä Azure Entra-ID-, ORDS- ja APEX-todennukseen.
- **Virallinen viite / Wikipedia:** [Wikipedia: Single Sign-On](https://en.wikipedia.org/wiki/Single_sign-on)
- **Liittyvät ohjeet ja skriptit:** [tests/test-browser-login.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/test-browser-login.sh)

## T

### `TCO` — Total Cost of Ownership
- **Määritelmä:** Kokonaiskustannusarvio, joka huomioi lisenssit, infrastruktuurin, ylläpidon ja seisokit.
- **Rooli tässä projektissa:** Pienenee dramaattisesti Free DB:n avulla: nollakulut kehitys- ja sisäisille työkaluille.
- **Virallinen viite / Wikipedia:** [Wikipedia: Total Cost of Ownership](https://en.wikipedia.org/wiki/Total_cost_of_ownership)
- **Liittyvät ohjeet ja skriptit:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

### `TLS` — Transport Layer Security
- **Määritelmä:** Kryptografinen protokolla turvallisen ja salatun tiedonsiirron takaamiseksi tietoverkoissa.
- **Rooli tässä projektissa:** Luodaan paikallisesti skriptillä generate-local-certs.sh HTTPS-liikenteelle portissa 8448.
- **Virallinen viite / Wikipedia:** [Wikipedia: Transport Layer Security](https://en.wikipedia.org/wiki/Transport_Layer_Security)
- **Liittyvät ohjeet ja skriptit:** [docs/security.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/security.md), [scripts/internal/generate-local-certs.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/generate-local-certs.sh)

### `TNS` — Transparent Network Substrate
- **Määritelmä:** Oraclen verkkoteknologia asiakassovellusten ja tietokantojen väliseen viestintään.
- **Rooli tässä projektissa:** Määritetty automaattisesti tnsnames/tnsnames.ora -tiedostoon ja jaettu TNS_ADMIN-muuttujalla.
- **Virallinen viite / Wikipedia:** [Wikipedia: Transparent Network Substrate](https://en.wikipedia.org/wiki/Transparent_Network_Substrate)
- **Liittyvät ohjeet ja skriptit:** [tnsnames/tnsnames.ora](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tnsnames/tnsnames.ora), [scripts/register-connections.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/register-connections.sh)

## U

### `UAC` — User Account Control
- **Määritelmä:** Windowsin suojausominaisuus, joka pyytää järjestelmänvalvojan oikeuksia ennen järjestelmämuutoksia.
- **Rooli tässä projektissa:** Vältetään täysin Säännön 14 mukaisesti: sertifikaatit asennetaan käyttäjäkohtaisesti ilman pääkäyttäjäoikeuksia.
- **Virallinen viite / Wikipedia:** [Wikipedia: User Account Control](https://en.wikipedia.org/wiki/User_Account_Control)
- **Liittyvät ohjeet ja skriptit:** [scripts/certs/trust-local-cert.cmd](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/certs/trust-local-cert.cmd), [docs/windows-enterprise-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/windows-enterprise-setup-guide.md)

### `UI / UX` — User Interface / User Experience
- **Määritelmä:** Käyttöliittymä ja käyttäjäkokemus: sovelluksen ulkoasu, painikkeet ja kokonaisvaltainen käytettävyys.
- **Rooli tässä projektissa:** Viimeistelty Dev Hubissa modernilla tummalla teemalla, pikanäppäimillä ja reaaliaikaisilla lokeilla.
- **Virallinen viite / Wikipedia:** [Wikipedia: UI/UX Design](https://en.wikipedia.org/wiki/User_interface_design)
- **Liittyvät ohjeet ja skriptit:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

### `URI / URL` — Uniform Resource Identifier / Locator
- **Määritelmä:** Standardi verkko-osoite resurssien (verkkosivujen, rajapintojen) yksilöimiseen ja paikantamiseen.
- **Rooli tässä projektissa:** Tarkistetaan käynnistyksessä skriptillä scripts/check-urls.sh varmistaen vastauskoodit HTTP 200/302.
- **Virallinen viite / Wikipedia:** [Wikipedia: URI / URL](https://en.wikipedia.org/wiki/Uniform_Resource_Identifier)
- **Liittyvät ohjeet ja skriptit:** [scripts/check-urls.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-urls.sh)

## V

### `VPN` — Virtual Private Network
- **Määritelmä:** Salattu verkkotunneli, joka yhdistää etälaitteen turvallisesti yrityksen sisäverkkoon internetin yli.
- **Rooli tässä projektissa:** Suojattu Windows WSL2:ssa asetuksella 'dnsTunneling=true' estäen yritys-VPN:n DNS-katkokset.
- **Virallinen viite / Wikipedia:** [Wikipedia: Virtual Private Network](https://en.wikipedia.org/wiki/Virtual_private_network)
- **Liittyvät ohjeet ja skriptit:** [docs/windows-enterprise-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/windows-enterprise-setup-guide.md)

### `VS Code` — Visual Studio Code
- **Määritelmä:** Microsoftin suosittu laajennettava koodieditori laajalla lisäosatuella.
- **Rooli tässä projektissa:** Ensisijainen kehityseditori: rekisteröi yhteydet Oracle-laajennukseen skriptillä scripts/register-connections.sh.
- **Virallinen viite / Wikipedia:** [Wikipedia: Visual Studio Code](https://en.wikipedia.org/wiki/Visual_Studio_Code)
- **Liittyvät ohjeet ja skriptit:** [scripts/register-connections.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/register-connections.sh)

## W

### `WSL / WSL2` — Windows Subsystem for Linux (Version 2)
- **Määritelmä:** Windowsin sisäänrakennettu Linux-alijärjestelmä, joka ajaa aitoa Linux-ydintä virtuaalisesti.
- **Rooli tässä projektissa:** Säännön 14 vaatimus: projektin on sijaittava natiivissa ext4-tiedostojärjestelmässä, ei /mnt/c/ -polulla.
- **Virallinen viite / Wikipedia:** [Wikipedia: Windows Subsystem for Linux](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux)
- **Liittyvät ohjeet ja skriptit:** [docs/windows-enterprise-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/windows-enterprise-setup-guide.md), [setup.cmd](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/setup.cmd)

## Y

### `YAML` — YAML Ain't Markup Language
- **Määritelmä:** Ihmisluettava tiedonkuvausmuoto konfiguraatiotiedostoille ja infrastruktuurin määrityksille.
- **Rooli tässä projektissa:** Toimii Säännön 11 mukaan ainoana totuuden lähteenä tietokantaprofiileille ja käyttäjille.
- **Virallinen viite / Wikipedia:** [Wikipedia: YAML](https://en.wikipedia.org/wiki/YAML)
- **Liittyvät ohjeet ja skriptit:** [config/profiles/databases/db-oracle.yaml](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/config/profiles/databases/db-oracle.yaml)

