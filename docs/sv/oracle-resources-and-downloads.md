# Officiella Oracle-resurser och containeravbildningar

[ 🇬🇧 English ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/oracle-resources-and-downloads.md) | [ 🇪🇪 Eesti ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/et/oracle-resources-and-downloads.md) | [ 🇫🇮 Suomi ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/fi/oracle-resources-and-downloads.md) | [ 🇸🇪 Svenska ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/sv/oracle-resources-and-downloads.md) | [ 🇱🇻 Latviešu ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lv/oracle-resources-and-downloads.md) | [ 🇱🇹 Lietuvių ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lt/oracle-resources-and-downloads.md)

> Samlad katalog över officiella Oracle Container Registry (OCR) avbildningar, nedladdningar, dokumentationsportaler, forum och laborationer.

---

**Jump to section:** [Containeravbildningar (OCR)](#containers) • [Officiella nedladdningar](#downloads) • [Dokumentation & molnportaler](#portals) • [Gemenskap, forum och evenemang](#community) • [Laborationer och kodarkiv](#learning)

---

<a id="containers"></a>
## Containeravbildningar (OCR)

### Oracle Database 23ai Free `[OCR Official]`
- **Beskrivning:** Officiell Oracle 23ai Free container med AI Vector Search, JSON-relational duality och PDB-stöd.
- **Roll i plattformen:** Grunddatabas för lokal utveckling, CI/CD-pipelines och testning.
- **Officiell länk:** [https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Ffree](https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Ffree)
- **Nedladdnings- / CLI-kommando:**
  ```bash
  podman pull container-registry.oracle.com/database/free:latest
  ```

### Oracle REST Data Services (ORDS) `[OCR Official]`
- **Beskrivning:** Certifierad ORDS-container: AutoREST-API:er, APEX-resurser och OAuth2-säkerhet.
- **Roll i plattformen:** Webblyssnare som dirigerar HTTPS-trafik till PDB-databaser.
- **Officiell länk:** [https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Fords](https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Fords)
- **Nedladdnings- / CLI-kommando:**
  ```bash
  podman pull container-registry.oracle.com/database/ords:latest
  ```

### Oracle SQLcl CLI Container `[OCR Official]`
- **Beskrivning:** Officiell SQLcl-container med Java 21, Liquibase och APEXlang-kompilator.
- **Roll i plattformen:** Möjliggör SQLcl-körning utan lokal installation på låsta företagsklienter.
- **Officiell länk:** [https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Fsqlcl](https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Fsqlcl)
- **Nedladdnings- / CLI-kommando:**
  ```bash
  podman pull container-registry.oracle.com/database/sqlcl:latest
  ```

### Oracle Container Registry (OCR) Portal `[OCR Portal]`
- **Beskrivning:** Oracles officiella containerregister för certifierade och säkerhetsgranskade behållare.
- **Roll i plattformen:** Godkännande av licensvillkor och sökning av officiella behållare.
- **Officiell länk:** [https://container-registry.oracle.com/](https://container-registry.oracle.com/)
- **Nedladdnings- / CLI-kommando:**
  ```bash
  podman login container-registry.oracle.com
  ```

### Oracle Linux 9 Slim `[OCR Base]`
- **Beskrivning:** Minimal enterprise Linux-basavbildning med säkerhetsuppdateringar.
- **Roll i plattformen:** Grund för anpassade applikationer och utvecklingsverktyg.
- **Officiell länk:** [https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:os%2Foraclelinux](https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:os%2Foraclelinux)
- **Nedladdnings- / CLI-kommando:**
  ```bash
  podman pull container-registry.oracle.com/os/oraclelinux:9-slim
  ```

### Oracle Database Free FastStart Containers (gvenzl) `[Docker Hub / GitHub]`
- **Beskrivning:** Gerald Venzls containerarkiv för Oracle Database Free med FastStart-avbildningar och stöd för AMD64/ARM64.
- **Roll i plattformen:** Snabba utvecklingsflöden och optimerad körning på Apple Silicon.
- **Officiell länk:** [https://github.com/gvenzl/oci-oracle-free](https://github.com/gvenzl/oci-oracle-free)
- **Nedladdnings- / CLI-kommando:**
  ```bash
  podman pull docker.io/gvenzl/oracle-free:23-full-faststart
  ```

### Oracle Forms & Reports 14c Container `[Docker Hub]`
- **Beskrivning:** Förkonfigurerad Oracle Forms 14c container med WebLogic och noVNC Forms Builder GUI.
- **Roll i plattformen:** Blueprint 6 & 7: Modernisering och migrering från Forms till APEX.
- **Officiell länk:** [https://hub.docker.com/r/allanlahe/oracle-forms](https://hub.docker.com/r/allanlahe/oracle-forms)
- **Nedladdnings- / CLI-kommando:**
  ```bash
  podman pull docker.io/allanlahe/oracle-forms:14.1.2
  ```

### Oracle Analytics Publisher Container `[Docker Hub]`
- **Beskrivning:** Pixel-perfect rapportmotor i container med säkerhetspatchar och PDF-generering.
- **Roll i plattformen:** Blueprint 4 & 5: Dokument- och fakturagenerering i stor skala.
- **Officiell länk:** [https://hub.docker.com/r/allanlahe/oracle-publisher](https://hub.docker.com/r/allanlahe/oracle-publisher)
- **Nedladdnings- / CLI-kommando:**
  ```bash
  podman pull docker.io/allanlahe/oracle-publisher:latest
  ```

<a id="downloads"></a>
## Officiella nedladdningar

### Oracle APEX Downloads `[Official Download]`
- **Beskrivning:** Senaste officiella APEX-arkivet med scheman, körmotor och statiska resurser.
- **Roll i plattformen:** Automatiserad installation direkt i containern utan uppackning på värddatorn.
- **Officiell länk:** [https://www.oracle.com/tools/downloads/apex-downloads.html](https://www.oracle.com/tools/downloads/apex-downloads.html)
- **Nedladdnings- / CLI-kommando:**
  ```bash
  curl -LO https://download.oracle.com/otn_software/apex/apex-latest.zip
  ```

### Oracle REST Data Services (ORDS) Downloads `[Official Download]`
- **Beskrivning:** Officiella ORDS-binärer för anpassade installationer.
- **Roll i plattformen:** Alternativ lokal installation via install-ords-standalone.sh.
- **Officiell länk:** [https://www.oracle.com/database/technologies/appdev/rest-data-services-downloads.html](https://www.oracle.com/database/technologies/appdev/rest-data-services-downloads.html)
- **Nedladdnings- / CLI-kommando:**
  ```bash
  curl -LO https://download.oracle.com/otn_software/java/ords/ords-latest.zip
  ```

### Oracle SQLcl Standalone Download `[Official Download]`
- **Beskrivning:** Modernt kommandoradsverktyg för Oracle Database med Liquibase och automatisk kodkomplettering.
- **Roll i plattformen:** Utvecklarens primära CLI-verktyg för databaskörningar.
- **Officiell länk:** [https://www.oracle.com/database/sqldev/technologies/sqlcl/download/](https://www.oracle.com/database/sqldev/technologies/sqlcl/download/)
- **Nedladdnings- / CLI-kommando:**
  ```bash
  curl -LO https://download.oracle.com/otn_software/java/sqldev/sqlcl-latest.zip
  ```

### Oracle Analytics Publisher Software & Template Builder `[Official Download]`
- **Beskrivning:** Officiella nedladdningar för Oracle Analytics Publisher och Desktop Template Builder för Word/Excel.
- **Roll i plattformen:** Installation av Template Builder för Word för design av pixel-perfect-rapporter.
- **Officiell länk:** [https://www.oracle.com/middleware/technologies/analytics-publisher/downloads.html](https://www.oracle.com/middleware/technologies/analytics-publisher/downloads.html)

### Oracle Instant Client (Basic & SDK) `[Official Download]`
- **Beskrivning:** Klientbibliotek för Python, Node.js och C/C++-applikationer mot Oracle Database.
- **Roll i plattformen:** Thick driver-läge och avancerade nätverksfunktioner.
- **Officiell länk:** [https://www.oracle.com/database/technologies/instant-client/downloads.html](https://www.oracle.com/database/technologies/instant-client/downloads.html)
- **Nedladdnings- / CLI-kommando:**
  ```bash
  # Select package for macOS (ARM64/x86), Linux, or Windows
  ```

### Oracle SQL Developer for VS Code `[VS Code Marketplace]`
- **Beskrivning:** Officiellt VS Code-tillägg med SQL-editor, objektutforskare och inbyggd SQLcl.
- **Roll i plattformen:** IDE-miljö som konfigureras automatiskt med register-connections.sh.
- **Officiell länk:** [https://marketplace.visualstudio.com/items?itemName=Oracle.sql-developer](https://marketplace.visualstudio.com/items?itemName=Oracle.sql-developer)
- **Nedladdnings- / CLI-kommando:**
  ```bash
  code --install-extension Oracle.sql-developer
  ```

<a id="portals"></a>
## Dokumentation & molnportaler

### Oracle Database Free Home & Features `[Product Overview]`
- **Beskrivning:** Officiell produktsida för Oracle Database Free med tekniska specifikationer och begränsningar (2 CPU, 2 GB RAM, 12 GB data).
- **Roll i plattformen:** Granskning av licensregler och produktionsbegränsningar.
- **Officiell länk:** [https://www.oracle.com/database/free/](https://www.oracle.com/database/free/)

### Oracle APEX 26.1 APEXlang Specification `[Language Spec]`
- **Beskrivning:** Officiell APEXlang-språkspecifikation och grammatik för deklarativ applikationsdefinition (.apx).
- **Roll i plattformen:** Syntaktisk referens för APEXlang DSL och AI-stödd kodning.
- **Officiell länk:** [https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/?component=app](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/?component=app)

### Oracle Architecture Center Technology Catalog `[Architecture Center]`
- **Beskrivning:** Katalog över referensarkitekturer, blueprints och företagsmönster från Oracle Architecture Center.
- **Roll i plattformen:** Arkitektonisk anpassning för hybridmoln och säkerhetsmodeller.
- **Officiell länk:** [https://apexadb.oracle.com/ords/r/tech/catalog/home](https://apexadb.oracle.com/ords/r/tech/catalog/home)

### Oracle Forms 14c (14.1.2) Documentation `[Technical Docs]`
- **Beskrivning:** Fullständig dokumentation för Oracle Forms 14c med WebLogic och moderniseringsguider.
- **Roll i plattformen:** Referens för Blueprint 6 och 7 gällande Forms-konfigurering.
- **Officiell länk:** [https://docs.oracle.com/en/middleware/developer-tools/forms/14.1.2/index.html](https://docs.oracle.com/en/middleware/developer-tools/forms/14.1.2/index.html)

### Oracle Analytics Server & Publisher Documentation `[Technical Docs]`
- **Beskrivning:** Teknisk dokumentation för Oracle Analytics Server och Publisher-motorn.
- **Roll i plattformen:** Konfiguration av Publisher och säkerhet för Blueprints 4 och 5.
- **Officiell länk:** [https://docs.oracle.com/en/middleware/bi/analytics-server/index.html](https://docs.oracle.com/en/middleware/bi/analytics-server/index.html)

### Oracle REST Data Services (ORDS) Product Center `[Product Overview]`
- **Beskrivning:** Officiellt produktcenter för ORDS med arkitekturmönster och mikrotjänstresurser.
- **Roll i plattformen:** Fördjupning i ORDS OAuth2-säkerhetsmodellen och API-gateway.
- **Officiell länk:** [https://www.oracle.com/database/technologies/appdev/rest.html](https://www.oracle.com/database/technologies/appdev/rest.html)

### Oracle Cloud Console (OCI) `[Cloud Portal]`
- **Beskrivning:** Webbkonsol för Oracle Cloud Infrastructure, Autonomous Database och API-nycklar.
- **Roll i plattformen:** Mål för Blueprints 10 och 11 (Hybridmoln och Autonomous Database).
- **Officiell länk:** [https://cloud.oracle.com](https://cloud.oracle.com)

### Oracle Live SQL `[Interactive Learning]`
- **Beskrivning:** Kostnadsfri webbaserad sandlåda för att testa SQL-frågor och 23ai-funktioner.
- **Roll i plattformen:** Snabb verifiering av syntax och 23ai-funktioner.
- **Officiell länk:** [https://livesql.oracle.com](https://livesql.oracle.com)

### Oracle Database 23ai Official Documentation `[Technical Docs]`
- **Beskrivning:** Fullständig teknisk dokumentation: SQL, PL/SQL, säkerhet och administration.
- **Roll i plattformen:** Auktoritativ referens för alla databasfunktioner.
- **Officiell länk:** [https://docs.oracle.com/en/database/oracle/oracle-database/23/](https://docs.oracle.com/en/database/oracle/oracle-database/23/)

### Oracle APEX Documentation & Tutorials `[Technical Docs]`
- **Beskrivning:** Officiell APEX-dokumentation, API-referenser och arkitekturguider.
- **Roll i plattformen:** Guide för design av APEX-komponenter och autentisering.
- **Officiell länk:** [https://docs.oracle.com/en/database/oracle/apex/](https://docs.oracle.com/en/database/oracle/apex/)

<a id="community"></a>
## Gemenskap, forum och evenemang

### Oracle APEX Community Forums `[Official Community]`
- **Beskrivning:** Officiellt Oracle APEX-forum för frågor, svar och produktnyheter.
- **Roll i plattformen:** Felsökning av APEX-problem och rådgivning med produktrådgivare.
- **Officiell länk:** [https://forums.oracle.com/ords/r/apexds/community/home](https://forums.oracle.com/ords/r/apexds/community/home)

### Oracle Analytics & Publisher Community `[Official Community]`
- **Beskrivning:** Oracle Analytics och Publisher-gemenskap med fokus på Pixel Perfect-rapportering och mallar.
- **Roll i plattformen:** Delning av rapportmallar och lösning av formateringsproblem.
- **Officiell länk:** [https://community.oracle.com/products/oracleanalytics/](https://community.oracle.com/products/oracleanalytics/)

### Oracle SQL Developer for VS Code Community `[Official Forum]`
- **Beskrivning:** Officiellt diskussionsforum för Oracle SQL Developer-tillägget i VS Code.
- **Roll i plattformen:** Felrapportering och funktionsförfrågningar för VS Code-tillägget.
- **Officiell länk:** [https://forums.oracle.com/ords/apexds/domain/dev-community/category/sqldev-for-vscode](https://forums.oracle.com/ords/apexds/domain/dev-community/category/sqldev-for-vscode)

### Oracle APEX Global Events & Office Hours `[Events & Webinars]`
- **Beskrivning:** Global kalender för APEX-evenemang, Office Hours och tekniska webbinarier.
- **Roll i plattformen:** Uppföljning av färdplan och nya APEX-funktioner.
- **Officiell länk:** [https://oracleapex.com/ords/r/apex_pm/apex-events/events](https://oracleapex.com/ords/r/apex_pm/apex-events/events)

### APEX Blogs Aggregator (CloudNueva) `[Community Aggregator]`
- **Beskrivning:** Gemenskapens bloggaggregator med tusentals tekniska artiklar och tips från APEX-experter.
- **Roll i plattformen:** Sökning efter praktiska kodexempel och CSS/JS-tips.
- **Officiell länk:** [https://apps.cloudnueva.com/ords/r/apps/apex_blogs/home](https://apps.cloudnueva.com/ords/r/apps/apex_blogs/home)

<a id="learning"></a>
## Laborationer och kodarkiv

### Oracle LiveLabs Interactive Workshops `[Hands-on Labs]`
- **Beskrivning:** Kostnadsfria praktiska laborationer och workshops för Oracle Database 23ai, APEX och molnet.
- **Roll i plattformen:** Praktisk utbildning i moderna Oracle-teknologier.
- **Officiell länk:** [https://apexapps.oracle.com/pls/apex/dbpm/r/livelabs/home](https://apexapps.oracle.com/pls/apex/dbpm/r/livelabs/home)

### Oracle MyLearn Digital Learning `[Oracle University]`
- **Beskrivning:** Oracle Universitys digitala utbildningsplattform med certifierade kurser och examina.
- **Roll i plattformen:** Professionella certifieringar för DBA och APEX-utvecklare.
- **Officiell länk:** [https://mylearn.oracle.com/ou/home](https://mylearn.oracle.com/ou/home)

### AskTOM Oracle Database Security Repository `[Security & Hardening]`
- **Beskrivning:** Oracle-säkerhetsteamets kodarkiv med skript för TDE, granskning och härdning.
- **Roll i plattformen:** Härdning av databas och implementering av Zero-Trust.
- **Officiell länk:** [https://github.com/oradbsec/AskTomDBSecurity](https://github.com/oradbsec/AskTomDBSecurity)
- **Nedladdnings- / CLI-kommando:**
  ```bash
  git clone https://github.com/oradbsec/AskTomDBSecurity.git
  ```

### Oracle AI Skills & Agentic Templates `[Agentic AI Skills]`
- **Beskrivning:** Oracles öppna kodarkiv för AI-färdigheter och digitala assistenter.
- **Roll i plattformen:** Integrering av AI-frågor i APEX-applikationer.
- **Officiell länk:** [https://github.com/oracle/skills/](https://github.com/oracle/skills/)
- **Nedladdnings- / CLI-kommando:**
  ```bash
  git clone https://github.com/oracle/skills.git
  ```

### Oracle APEX Open Source Hub `[Open Source Hub]`
- **Beskrivning:** Oracles officiella portal för öppna insticksprogram, mallar och tillägg för APEX.
- **Roll i plattformen:** Installation av certifierade insticksprogram i APEX.
- **Officiell länk:** [https://oracle.github.io/apex/](https://oracle.github.io/apex/)

### Official Oracle Container Images Source Repository `[Official GitHub]`
- **Beskrivning:** Officiellt Oracle-arkiv med Dockerfiler och byggskript för Oracle-programvara (Database, WebLogic, Forms, Java).
- **Roll i plattformen:** Referensrecept för att bygga anpassade behållare och WebLogic-domäner.
- **Officiell länk:** [https://github.com/oracle/docker-images/tree/main](https://github.com/oracle/docker-images/tree/main)
- **Nedladdnings- / CLI-kommando:**
  ```bash
  git clone https://github.com/oracle/docker-images.git
  ```

