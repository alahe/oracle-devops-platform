# Oficialūs Oracle ištekliai ir konteinerių atvaizdai

[ 🇬🇧 English ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/oracle-resources-and-downloads.md) | [ 🇪🇪 Eesti ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/et/oracle-resources-and-downloads.md) | [ 🇫🇮 Suomi ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/fi/oracle-resources-and-downloads.md) | [ 🇸🇪 Svenska ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/sv/oracle-resources-and-downloads.md) | [ 🇱🇻 Latviešu ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lv/oracle-resources-and-downloads.md) | [ 🇱🇹 Lietuvių ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lt/oracle-resources-and-downloads.md)

> Oficialių Oracle Container Registry (OCR) atvaizdų, atsisiuntimų, dokumentacijos portalų, bendruomenės forumų ir mokymosi saugyklų katalogas.

---

**Jump to section:** [Konteinerių atvaizdai (OCR)](#containers) • [Oficialūs atsisiuntimai](#downloads) • [Dokumentacija ir debesų portalai](#portals) • [Bendruomenė, forumai ir renginiai](#community) • [Mokymai ir kodo saugyklos](#learning)

---

<a id="containers"></a>
## Konteinerių atvaizdai (OCR)

### Oracle Database 23ai Free `[OCR Official]`
- **Aprašymas:** Oficialus Oracle 23ai Free duomenų bazės konteineris su AI vektorine paieška, JSON-reliacine dualybe ir PDB palaikymu.
- **Vaidmuo platformoje:** Pagrindinė duomenų bazė vietiniam kūrimui, CI/CD konvejeriams ir testams.
- **Oficiali nuoroda:** [https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Ffree](https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Ffree)
- **Atsisiuntimo / CLI komanda:**
  ```bash
  podman pull container-registry.oracle.com/database/free:latest
  ```

### Oracle REST Data Services (ORDS) `[OCR Official]`
- **Aprašymas:** Sertifikuotas ORDS konteineris: AutoREST API, APEX failų maršrutizavimas ir OAuth2 saugumas.
- **Vaidmuo platformoje:** Lengvasvaris žiniatinklio gavėjas, nukreipiantis HTTPS srautą į PDB duomenų bazes.
- **Oficiali nuoroda:** [https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Fords](https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Fords)
- **Atsisiuntimo / CLI komanda:**
  ```bash
  podman pull container-registry.oracle.com/database/ords:latest
  ```

### Oracle SQLcl CLI Container `[OCR Official]`
- **Aprašymas:** Oficialus SQLcl konteineris su Java 21, Liquibase ir APEXlang kompiliatoriumi.
- **Vaidmuo platformoje:** Suteikia galimybę vykdyti SQLcl be vietinio diegimo apribotose įmonės darbo vietose.
- **Oficiali nuoroda:** [https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Fsqlcl](https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Fsqlcl)
- **Atsisiuntimo / CLI komanda:**
  ```bash
  podman pull container-registry.oracle.com/database/sqlcl:latest
  ```

### Oracle Container Registry (OCR) Portal `[OCR Portal]`
- **Aprašymas:** Oficialus Oracle konteinerių registras su sertifikuotais ir patikrintais atvaizdais.
- **Vaidmuo platformoje:** Licencijos sąlygų patvirtinimas ir oficialių konteinerių paieška.
- **Oficiali nuoroda:** [https://container-registry.oracle.com/](https://container-registry.oracle.com/)
- **Atsisiuntimo / CLI komanda:**
  ```bash
  podman login container-registry.oracle.com
  ```

### Oracle Linux 9 Slim `[OCR Base]`
- **Aprašymas:** Minimalaus dydžio įmonės lygio Linux bazinis atvaizdas su saugumo pataisomis.
- **Vaidmuo platformoje:** Bazinė platforma individualiems konteineriams kurti.
- **Oficiali nuoroda:** [https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:os%2Foraclelinux](https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:os%2Foraclelinux)
- **Atsisiuntimo / CLI komanda:**
  ```bash
  podman pull container-registry.oracle.com/os/oraclelinux:9-slim
  ```

### Oracle Database Free FastStart Containers (gvenzl) `[Docker Hub / GitHub]`
- **Aprašymas:** Gerald Venzl Oracle Database Free konteinerių saugykla su FastStart atvaizdais ir AMD64/ARM64 palaikymu.
- **Vaidmuo platformoje:** Spartus kūrimo procesas su FastStart atvaizdais ir vietinis darbas su Apple Silicon.
- **Oficiali nuoroda:** [https://github.com/gvenzl/oci-oracle-free](https://github.com/gvenzl/oci-oracle-free)
- **Atsisiuntimo / CLI komanda:**
  ```bash
  podman pull docker.io/gvenzl/oracle-free:23-full-faststart
  ```

### Oracle Forms & Reports 14c Container `[Docker Hub]`
- **Aprašymas:** Paruoštas Oracle Forms 14c konteineris su WebLogic ir noVNC Forms Builder sąsaja.
- **Vaidmuo platformoje:** Blueprint 6 ir 7: Forms modernizavimas ir perkėlimas į APEX.
- **Oficiali nuoroda:** [https://hub.docker.com/r/allanlahe/oracle-forms](https://hub.docker.com/r/allanlahe/oracle-forms)
- **Atsisiuntimo / CLI komanda:**
  ```bash
  podman pull docker.io/allanlahe/oracle-forms:14.1.2
  ```

### Oracle Analytics Publisher Container `[Docker Hub]`
- **Aprašymas:** Verslo ataskaitų konteineris su OPatch saugumo pataisomis ir PDF generatoriumi.
- **Vaidmuo platformoje:** Blueprint 4 ir 5: Masinis dokumentų ir sąskaitų generavimas.
- **Oficiali nuoroda:** [https://hub.docker.com/r/allanlahe/oracle-publisher](https://hub.docker.com/r/allanlahe/oracle-publisher)
- **Atsisiuntimo / CLI komanda:**
  ```bash
  podman pull docker.io/allanlahe/oracle-publisher:latest
  ```

<a id="downloads"></a>
## Oficialūs atsisiuntimai

### Oracle APEX Downloads `[Official Download]`
- **Aprašymas:** Naujausias oficialus APEX paketas su schemomis, varikliu ir statiniais failais.
- **Vaidmuo platformoje:** Automatizuotas diegimas tiesiai į konteinerį be išskleidimo pagrindiniame kompiuteryje.
- **Oficiali nuoroda:** [https://www.oracle.com/tools/downloads/apex-downloads.html](https://www.oracle.com/tools/downloads/apex-downloads.html)
- **Atsisiuntimo / CLI komanda:**
  ```bash
  curl -LO https://download.oracle.com/otn_software/apex/apex-latest.zip
  ```

### Oracle REST Data Services (ORDS) Downloads `[Official Download]`
- **Aprašymas:** Oficialūs ORDS paketai individualiems diegimams.
- **Vaidmuo platformoje:** Alternatyvus vietinis diegimas per install-ords-standalone.sh.
- **Oficiali nuoroda:** [https://www.oracle.com/database/technologies/appdev/rest-data-services-downloads.html](https://www.oracle.com/database/technologies/appdev/rest-data-services-downloads.html)
- **Atsisiuntimo / CLI komanda:**
  ```bash
  curl -LO https://download.oracle.com/otn_software/java/ords/ords-latest.zip
  ```

### Oracle SQLcl Standalone Download `[Official Download]`
- **Aprašymas:** Modernus komandinės eilutės įrankis su kodo pildymu ir Liquibase integracija.
- **Vaidmuo platformoje:** Kūrėjo kasdienis komandinės eilutės įrankis darbui su duomenų baze.
- **Oficiali nuoroda:** [https://www.oracle.com/database/sqldev/technologies/sqlcl/download/](https://www.oracle.com/database/sqldev/technologies/sqlcl/download/)
- **Atsisiuntimo / CLI komanda:**
  ```bash
  curl -LO https://download.oracle.com/otn_software/java/sqldev/sqlcl-latest.zip
  ```

### Oracle Analytics Publisher Software & Template Builder `[Official Download]`
- **Aprašymas:** Oficialūs atsisiuntimai Oracle Analytics Publisher ir Desktop Template Builder įrankiui su Word/Excel palaikymu.
- **Vaidmuo platformoje:** Template Builder diegimas į MS Word tikslių ataskaitų maketavimui.
- **Oficiali nuoroda:** [https://www.oracle.com/middleware/technologies/analytics-publisher/downloads.html](https://www.oracle.com/middleware/technologies/analytics-publisher/downloads.html)

### Oracle Instant Client (Basic & SDK) `[Official Download]`
- **Aprašymas:** Kliento bibliotekos, skirtos Python, Node.js ir C/C++ programoms prijungti prie Oracle.
- **Vaidmuo platformoje:** Thick-driver režimas ir išplėstinis tinklo protokolų palaikymas.
- **Oficiali nuoroda:** [https://www.oracle.com/database/technologies/instant-client/downloads.html](https://www.oracle.com/database/technologies/instant-client/downloads.html)
- **Atsisiuntimo / CLI komanda:**
  ```bash
  # Select package for macOS (ARM64/x86), Linux, or Windows
  ```

### Oracle SQL Developer for VS Code `[VS Code Marketplace]`
- **Aprašymas:** Oficialus VS Code plėtinys su SQL rengykle, objektų naršykle ir integruotu SQLcl.
- **Vaidmuo platformoje:** Integruota kūrimo aplinka, automatiškai sukonfigūruojama per register-connections.sh.
- **Oficiali nuoroda:** [https://marketplace.visualstudio.com/items?itemName=Oracle.sql-developer](https://marketplace.visualstudio.com/items?itemName=Oracle.sql-developer)
- **Atsisiuntimo / CLI komanda:**
  ```bash
  code --install-extension Oracle.sql-developer
  ```

<a id="portals"></a>
## Dokumentacija ir debesų portalai

### Oracle Database Free Home & Features `[Product Overview]`
- **Aprašymas:** Oficialus Oracle Database Free puslapis su techninėmis specifikacijomis ir ribojimais (2 CPU, 2 GB RAM, 12 GB duomenų).
- **Vaidmuo platformoje:** Licencijavimo taisyklių ir gamybinio naudojimo sąlygų peržiūra.
- **Oficiali nuoroda:** [https://www.oracle.com/database/free/](https://www.oracle.com/database/free/)

### Oracle APEX 26.1 APEXlang Specification `[Language Spec]`
- **Aprašymas:** Oficiali APEXlang kalbos specifikacija ir gramatika deklaratyviam programų aprašymui (.apx).
- **Vaidmuo platformoje:** Sintaksės šaltinis APEXlang DSL ir AI kodo generavimui.
- **Oficiali nuoroda:** [https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/?component=app](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/?component=app)

### Oracle Architecture Center Technology Catalog `[Architecture Center]`
- **Aprašymas:** Oracle architektūros centro katalogas: etaloninės architektūros, planai ir įmonių sprendimai.
- **Vaidmuo platformoje:** Architektūrų suderinimas hibridinio debesies ir nulinio pasitikėjimo modeliams.
- **Oficiali nuoroda:** [https://apexadb.oracle.com/ords/r/tech/catalog/home](https://apexadb.oracle.com/ords/r/tech/catalog/home)

### Oracle Forms 14c (14.1.2) Documentation `[Technical Docs]`
- **Aprašymas:** Išsami dokumentacija Oracle Forms 14c diegimui, WebLogic konfigūravimui ir modernizavimui.
- **Vaidmuo platformoje:** Šaltinis Blueprint 6 ir 7 modeliams bei Forms perkėlimui į APEX.
- **Oficiali nuoroda:** [https://docs.oracle.com/en/middleware/developer-tools/forms/14.1.2/index.html](https://docs.oracle.com/en/middleware/developer-tools/forms/14.1.2/index.html)

### Oracle Analytics Server & Publisher Documentation `[Technical Docs]`
- **Aprašymas:** Oficiali techninė dokumentacija, skirta Oracle Analytics Server ir Publisher varikliui.
- **Vaidmuo platformoje:** Konfigūravimo gairės Blueprint 4 ir 5 sprendimams.
- **Oficiali nuoroda:** [https://docs.oracle.com/en/middleware/bi/analytics-server/index.html](https://docs.oracle.com/en/middleware/bi/analytics-server/index.html)

### Oracle REST Data Services (ORDS) Product Center `[Product Overview]`
- **Aprašymas:** ORDS produktų centras su architektūros planais ir AutoREST galimybėmis.
- **Vaidmuo platformoje:** ORDS OAuth2 saugumo modelio ir API šliuzo analizė.
- **Oficiali nuoroda:** [https://www.oracle.com/database/technologies/appdev/rest.html](https://www.oracle.com/database/technologies/appdev/rest.html)

### Oracle Cloud Console (OCI) `[Cloud Portal]`
- **Aprašymas:** Oracle Cloud Infrastructure valdymo pultas, skirtas Autonomous Database ir API raktams.
- **Vaidmuo platformoje:** Tikslinė debesų aplinka Blueprint 10 ir 11 architektūroms.
- **Oficiali nuoroda:** [https://cloud.oracle.com](https://cloud.oracle.com)

### Oracle Live SQL `[Interactive Learning]`
- **Aprašymas:** Nemokama interaktyvi smėliadėžė naršyklėje SQL užklausoms ir 23ai galimybėms išbandyti.
- **Vaidmuo platformoje:** Greitas sintaksės tikrinimas ir susipažinimas su 23ai naujovėmis.
- **Oficiali nuoroda:** [https://livesql.oracle.com](https://livesql.oracle.com)

### Oracle Database 23ai Official Documentation `[Technical Docs]`
- **Aprašymas:** Išsami techninė dokumentacija: SQL, PL/SQL, saugumas ir administravimas.
- **Vaidmuo platformoje:** Oficialus techninis šaltinis duomenų bazės galimybėms nagrinėti.
- **Oficiali nuoroda:** [https://docs.oracle.com/en/database/oracle/oracle-database/23/](https://docs.oracle.com/en/database/oracle/oracle-database/23/)

### Oracle APEX Documentation & Tutorials `[Technical Docs]`
- **Aprašymas:** Oficiali APEX dokumentacija, API žinynai ir architektūros gairės.
- **Vaidmuo platformoje:** Pagrindinis vadovas kuriant APEX komponentus ir autentifikacijos schemas.
- **Oficiali nuoroda:** [https://docs.oracle.com/en/database/oracle/apex/](https://docs.oracle.com/en/database/oracle/apex/)

<a id="community"></a>
## Bendruomenė, forumai ir renginiai

### Oracle APEX Community Forums `[Official Community]`
- **Aprašymas:** Oficialus Oracle APEX bendruomenės forumas klausimams, atsakymams ir naujienoms.
- **Vaidmuo platformoje:** APEX problemų sprendimas ir konsultacijos su ekspertais.
- **Oficiali nuoroda:** [https://forums.oracle.com/ords/r/apexds/community/home](https://forums.oracle.com/ords/r/apexds/community/home)

### Oracle Analytics & Publisher Community `[Official Community]`
- **Aprašymas:** Oracle Analytics ir Publisher bendruomenė: Pixel Perfect ataskaitos, šablonai ir palaikymas.
- **Vaidmuo platformoje:** Ataskaitų šablonų dalijimasis ir problemų sprendimas.
- **Oficiali nuoroda:** [https://community.oracle.com/products/oracleanalytics/](https://community.oracle.com/products/oracleanalytics/)

### Oracle SQL Developer for VS Code Community `[Official Forum]`
- **Aprašymas:** Oficialus pagalbos forumas VS Code Oracle SQL Developer plėtiniui.
- **Vaidmuo platformoje:** Pranešimai apie klaidas ir naujų funkcijų siūlymai plėtiniui.
- **Oficiali nuoroda:** [https://forums.oracle.com/ords/apexds/domain/dev-community/category/sqldev-for-vscode](https://forums.oracle.com/ords/apexds/domain/dev-community/category/sqldev-for-vscode)

### Oracle APEX Global Events & Office Hours `[Events & Webinars]`
- **Aprašymas:** Pasaulinis APEX renginių, Office Hours vebinarų ir konferencijų kalendorius.
- **Vaidmuo platformoje:** Naujų APEX versijų gairių ir demonstracijų stebėjimas.
- **Oficiali nuoroda:** [https://oracleapex.com/ords/r/apex_pm/apex-events/events](https://oracleapex.com/ords/r/apex_pm/apex-events/events)

### APEX Blogs Aggregator (CloudNueva) `[Community Aggregator]`
- **Aprašymas:** Bendruomenės tinklaraščių agregatorius su tūkstančiais techninių straipsnių ir patarimų apie APEX.
- **Vaidmuo platformoje:** Šiuolaikinių kodo pavyzdžių ir praktinių sprendimų paieška.
- **Oficiali nuoroda:** [https://apps.cloudnueva.com/ords/r/apps/apex_blogs/home](https://apps.cloudnueva.com/ords/r/apps/apex_blogs/home)

<a id="learning"></a>
## Mokymai ir kodo saugyklos

### Oracle LiveLabs Interactive Workshops `[Hands-on Labs]`
- **Aprašymas:** Nemokamos praktinės mokymosi laboratorijos apie Oracle 23ai, APEX ir debesų architektūrą.
- **Vaidmuo platformoje:** Praktiniai mokymai platformos galimybėms perprasti.
- **Oficiali nuoroda:** [https://apexapps.oracle.com/pls/apex/dbpm/r/livelabs/home](https://apexapps.oracle.com/pls/apex/dbpm/r/livelabs/home)

### Oracle MyLearn Digital Learning `[Oracle University]`
- **Aprašymas:** Oracle University skaitmeninė mokymosi platforma su sertifikuotais kursais ir egzaminais.
- **Vaidmuo platformoje:** Profesiniai DBA ir APEX kūrėjų sertifikatai.
- **Oficiali nuoroda:** [https://mylearn.oracle.com/ou/home](https://mylearn.oracle.com/ou/home)

### AskTOM Oracle Database Security Repository `[Security & Hardening]`
- **Aprašymas:** Oracle saugumo komandos saugykla su scenarijais TDE šifravimui, auditui ir stiprinimui.
- **Vaidmuo platformoje:** Duomenų bazės stiprinimas ir nulinio pasitikėjimo reikalavimų vykdymas.
- **Oficiali nuoroda:** [https://github.com/oradbsec/AskTomDBSecurity](https://github.com/oradbsec/AskTomDBSecurity)
- **Atsisiuntimo / CLI komanda:**
  ```bash
  git clone https://github.com/oradbsec/AskTomDBSecurity.git
  ```

### Oracle AI Skills & Agentic Templates `[Agentic AI Skills]`
- **Aprašymas:** Oracle atviro kodo saugykla AI įgūdžiams ir skaitmeniniams asistentams.
- **Vaidmuo platformoje:** Natūralios kalbos užklausų integravimas į APEX programas.
- **Oficiali nuoroda:** [https://github.com/oracle/skills/](https://github.com/oracle/skills/)
- **Atsisiuntimo / CLI komanda:**
  ```bash
  git clone https://github.com/oracle/skills.git
  ```

### Oracle APEX Open Source Hub `[Open Source Hub]`
- **Aprašymas:** Oficiali Oracle atviro kodo įskiepių ir šablonų svetainė APEX kūrėjams.
- **Vaidmuo platformoje:** Patikrintų įskiepių ir dinaminių veiksmų diegimas į programas.
- **Oficiali nuoroda:** [https://oracle.github.io/apex/](https://oracle.github.io/apex/)

### Official Oracle Container Images Source Repository `[Official GitHub]`
- **Aprašymas:** Oficiali Oracle saugykla su Dockerfile ir kompiliavimo scenarijais Oracle programinei įrangai (Database, WebLogic, Forms, Java).
- **Vaidmuo platformoje:** Pavyzdiniai šablonai individualiems konteineriams ir WebLogic domenams kurti.
- **Oficiali nuoroda:** [https://github.com/oracle/docker-images/tree/main](https://github.com/oracle/docker-images/tree/main)
- **Atsisiuntimo / CLI komanda:**
  ```bash
  git clone https://github.com/oracle/docker-images.git
  ```

