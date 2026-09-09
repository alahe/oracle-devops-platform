# Ametlikud Oracle ressursid ja konteineritõmmised

[ 🇬🇧 English ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/oracle-resources-and-downloads.md) | [ 🇪🇪 Eesti ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/et/oracle-resources-and-downloads.md) | [ 🇫🇮 Suomi ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/fi/oracle-resources-and-downloads.md) | [ 🇸🇪 Svenska ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/sv/oracle-resources-and-downloads.md) | [ 🇱🇻 Latviešu ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lv/oracle-resources-and-downloads.md) | [ 🇱🇹 Lietuvių ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lt/oracle-resources-and-downloads.md)

> Ametlike Oracle Container Registry (OCR) tõmmiste, toodete allalaadimiste, dokumentatsiooniportaalide, kogukonnafoorumite ja õppelaborite koondregister.

---

**Jump to section:** [Konteineritõmmised (OCR)](#containers) • [Ametlikud allalaadimised](#downloads) • [Dokumentatsioon ja pilveportaalid](#portals) • [Kogukond, foorumid ja üritused](#community) • [Õppematerjalid ja koodihoidlad](#learning)

---

<a id="containers"></a>
## Konteineritõmmised (OCR)

### Oracle Database 23ai Free `[OCR Official]`
- **Kirjeldus:** Ametlik Oracle 23ai Free andmebaasi konteiner: tehisintellekti vektorotsing (Vector Search), JSON-relatsiooniline duaalsus ja PDB tugi.
- **Roll platvormil:** Alusbaas kohalikuks arenduseks, CI/CD torudeks ja automatiseeritud testideks.
- **Ametlik link:** [https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Ffree](https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Ffree)
- **Allalaadimise / CLI käsk:**
  ```bash
  podman pull container-registry.oracle.com/database/free:latest
  ```

### Oracle REST Data Services (ORDS) `[OCR Official]`
- **Kirjeldus:** Eelvalmistatud sertifitseeritud ORDS konteiner: AutoREST API-d, APEX staatiliste failide teenindus ja OAuth2 turvalisus.
- **Roll platvormil:** Kerge veebikuulaja, mis vahendab HTTPS liiklust PDB andmebaasidesse ilma litsentsikuluta.
- **Ametlik link:** [https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Fords](https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Fords)
- **Allalaadimise / CLI käsk:**
  ```bash
  podman pull container-registry.oracle.com/database/ords:latest
  ```

### Oracle SQLcl CLI Container `[OCR Official]`
- **Kirjeldus:** Ametlik SQLcl efemeerne konteiner: Java 21 käitusaeg, Liquibase skeemihalduse tugi ja APEXlang kompilaator.
- **Roll platvormil:** Võimaldab käitada SQLcl käske (Reegel 4) ilma kohalikku Javat või tööriistu paigaldamata piiratud õigustega arvutites.
- **Ametlik link:** [https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Fsqlcl](https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Fsqlcl)
- **Allalaadimise / CLI käsk:**
  ```bash
  podman pull container-registry.oracle.com/database/sqlcl:latest
  ```

### Oracle Container Registry (OCR) Portal `[OCR Portal]`
- **Kirjeldus:** Oracle ametlik keskne konteineriregister: sertifitseeritud ja turvakontrollitud ametlikud tõmmised koos litsentsitingimustega.
- **Roll platvormil:** Litsentsitingimuste aktsepteerimine ja ametlike Oracle konteinerite otsing ning autentimine.
- **Ametlik link:** [https://container-registry.oracle.com/](https://container-registry.oracle.com/)
- **Allalaadimise / CLI käsk:**
  ```bash
  podman login container-registry.oracle.com
  ```

### Oracle Linux 9 Slim `[OCR Base]`
- **Kirjeldus:** Minimaalse jalajäljega ettevõtte Linuxi baastõmmis turvapaikade ja ametliku glibc toega.
- **Roll platvormil:** Baastõmmis kohalike erirakenduste ja arendustööriistade kompileerimiseks.
- **Ametlik link:** [https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:os%2Foraclelinux](https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:os%2Foraclelinux)
- **Allalaadimise / CLI käsk:**
  ```bash
  podman pull container-registry.oracle.com/os/oraclelinux:9-slim
  ```

### Oracle Database Free FastStart Containers (gvenzl) `[Docker Hub / GitHub]`
- **Kirjeldus:** Gerald Venzli Oracle Database Free konteineripiltide koodihoidla: ülikiire FastStart käivitus (~10s) ja AMD64/ARM64 (Apple Silicon) tugi.
- **Roll platvormil:** Arenduse kiirendamine FastStart profiilidega ning optimeeritud käitamine Apple Silicon (M1/M2/M3/M4) masinates.
- **Ametlik link:** [https://github.com/gvenzl/oci-oracle-free](https://github.com/gvenzl/oci-oracle-free)
- **Allalaadimise / CLI käsk:**
  ```bash
  podman pull docker.io/gvenzl/oracle-free:23-full-faststart
  ```

### Oracle Forms & Reports 14c Container `[Docker Hub]`
- **Kirjeldus:** Eelseadistatud Oracle Forms 14c konteiner: WebLogic Server, HTML5 noVNC brauseripõhine Forms Builder ja fmx kompilaator.
- **Roll platvormil:** Kavandid 6 & 7: Vana Forms-süsteemi kaasajastamine, fmx kompileerimine ja migratsioon APEX-isse.
- **Ametlik link:** [https://hub.docker.com/r/allanlahe/oracle-forms](https://hub.docker.com/r/allanlahe/oracle-forms)
- **Allalaadimise / CLI käsk:**
  ```bash
  podman pull docker.io/allanlahe/oracle-forms:14.1.2
  ```

### Oracle Analytics Publisher Container `[Docker Hub]`
- **Kirjeldus:** Pixel-perfect aruandlusmootori konteiner: OPatch turvapaigad, PDF genereerimine ja REST API teenused.
- **Roll platvormil:** Kavandid 4 & 5: Suuremahuline arvete, dokumentide ja raportite automaatne genereerimine.
- **Ametlik link:** [https://hub.docker.com/r/allanlahe/oracle-publisher](https://hub.docker.com/r/allanlahe/oracle-publisher)
- **Allalaadimise / CLI käsk:**
  ```bash
  podman pull docker.io/allanlahe/oracle-publisher:latest
  ```

<a id="downloads"></a>
## Ametlikud allalaadimised

### Oracle APEX Downloads `[Official Download]`
- **Kirjeldus:** Ametlik APEX jaotusarhiiv: andmebaasiskeemid, käitusmootor ja staatilised veebifailid.
- **Roll platvormil:** Automaatne paigaldus andmebaasi skriptiga install-apex.sh ilma host-kettale lahtipakkimata (Reegel 4).
- **Ametlik link:** [https://www.oracle.com/tools/downloads/apex-downloads.html](https://www.oracle.com/tools/downloads/apex-downloads.html)
- **Allalaadimise / CLI käsk:**
  ```bash
  curl -LO https://download.oracle.com/otn_software/apex/apex-latest.zip
  ```

### Oracle REST Data Services (ORDS) Downloads `[Official Download]`
- **Kirjeldus:** Ametlik ORDS jaotuspakett eraldiseisvateks host-paigaldusteks või kohandatud lüüsiks.
- **Roll platvormil:** Alternatiivne lokaalne paigaldus skriptiga install-ords-standalone.sh.
- **Ametlik link:** [https://www.oracle.com/database/technologies/appdev/rest-data-services-downloads.html](https://www.oracle.com/database/technologies/appdev/rest-data-services-downloads.html)
- **Allalaadimise / CLI käsk:**
  ```bash
  curl -LO https://download.oracle.com/otn_software/java/ords/ords-latest.zip
  ```

### Oracle SQLcl Standalone Download `[Official Download]`
- **Kirjeldus:** Kaasaegne Oracle andmebaasi käsurida: automaatne koodilõpetus, Liquibase integratsioon ja APEX koodieksport.
- **Roll platvormil:** Arendaja igapäevane CLI tööriist andmebaasiga suhtlemiseks ja automatiseerimiseks.
- **Ametlik link:** [https://www.oracle.com/database/sqldev/technologies/sqlcl/download/](https://www.oracle.com/database/sqldev/technologies/sqlcl/download/)
- **Allalaadimise / CLI käsk:**
  ```bash
  curl -LO https://download.oracle.com/otn_software/java/sqldev/sqlcl-latest.zip
  ```

### Oracle Analytics Publisher Software & Template Builder `[Official Download]`
- **Kirjeldus:** Oracle Analytics Publisher ametlik tarkvara ja töölaua mallikoostaja (Desktop Template Builder Wordile/Excelile) allalaadimine.
- **Roll platvormil:** Template Builderi paigaldamine MS Wordi sisse täppisvormindusega (pixel-perfect) RTF ja PDF aruannete kujundamiseks.
- **Ametlik link:** [https://www.oracle.com/middleware/technologies/analytics-publisher/downloads.html](https://www.oracle.com/middleware/technologies/analytics-publisher/downloads.html)

### Oracle Instant Client (Basic & SDK) `[Official Download]`
- **Kirjeldus:** Jõulised natiivsed klienditeegid Pythoni (python-oracledb), Node.js ja C/C++ rakenduste ühendamiseks.
- **Roll platvormil:** Thick-driver draiveri režiim ja laiendatud Oracle võrguprotokollide tugi.
- **Ametlik link:** [https://www.oracle.com/database/technologies/instant-client/downloads.html](https://www.oracle.com/database/technologies/instant-client/downloads.html)
- **Allalaadimise / CLI käsk:**
  ```bash
  # Select package for macOS (ARM64/x86), Linux, or Windows
  ```

### Oracle SQL Developer for VS Code `[VS Code Marketplace]`
- **Kirjeldus:** Ametlik VS Code laiendus: SQL tööleht, andmebaasiobjektide puu, integreeritud SQLcl ja ühenduste haldur.
- **Roll platvormil:** Graafiline arenduskeskkond, mille ühendused seadistatakse automaatselt skriptiga register-connections.sh.
- **Ametlik link:** [https://marketplace.visualstudio.com/items?itemName=Oracle.sql-developer](https://marketplace.visualstudio.com/items?itemName=Oracle.sql-developer)
- **Allalaadimise / CLI käsk:**
  ```bash
  code --install-extension Oracle.sql-developer
  ```

<a id="portals"></a>
## Dokumentatsioon ja pilveportaalid

### Oracle Database Free Home & Features `[Product Overview]`
- **Kirjeldus:** Oracle Database Free ametlik tooteleht: tehniline ülevaade, riistvara piirmäärad (2 CPU tuuma, 2 GB RAM, 12 GB kasutajaandmeid) ja litsentsikord.
- **Roll platvormil:** Litsentsireeglite, toodangukasutuse tingimuste ja ressursipiirangute kontrollimine.
- **Ametlik link:** [https://www.oracle.com/database/free/](https://www.oracle.com/database/free/)

### Oracle APEX 26.1 APEXlang Specification `[Language Spec]`
- **Kirjeldus:** Ametlik APEXlang keele- ja süntaksispetsifikatsioon Oracle APEX deklaratiivse rakenduskeele (.apx) koostamiseks.
- **Roll platvormil:** Süntaksi alus APEXlang DSL genereerimisel, tehisintellekti viipadega rakenduste loomisel ja koodikompileerimisel.
- **Ametlik link:** [https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/?component=app](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/?component=app)

### Oracle Architecture Center Technology Catalog `[Architecture Center]`
- **Kirjeldus:** Oracle ametlik arhitektuurikeskuse kataloog: etalonarhitektuurid, juhendkavandid (blueprints) ja paigalduse parimad praktikad.
- **Roll platvormil:** Etalonarhitektuuride joondamine hübriidpilve, mitme andmebaasiga LIS süsteemi ja zero-trust turvamudelitega.
- **Ametlik link:** [https://apexadb.oracle.com/ords/r/tech/catalog/home](https://apexadb.oracle.com/ords/r/tech/catalog/home)

### Oracle Forms 14c (14.1.2) Documentation `[Technical Docs]`
- **Kirjeldus:** Terviklik dokumentatsioon: Oracle Forms 14c paigaldus, WebLogic häälestus, headless kompileerimine ja brauseritugi.
- **Roll platvormil:** Alusdokumentatsioon kavanditele 6 ja 7 (Forms konteiner, fmx kompileerimine ja migratsioonitee APEX-isse).
- **Ametlik link:** [https://docs.oracle.com/en/middleware/developer-tools/forms/14.1.2/index.html](https://docs.oracle.com/en/middleware/developer-tools/forms/14.1.2/index.html)

### Oracle Analytics Server & Publisher Documentation `[Technical Docs]`
- **Kirjeldus:** Oracle Analytics Server (OAS) ja Publisheri ametlik dokumentatsiooniraamatukogu: andmemudelid, XML skeemid ja REST API.
- **Roll platvormil:** Kavandite 4 ja 5 seadistamine (Publisheri kataloog, WebLogic turvalisus ja aruannete automaatne genereerimine).
- **Ametlik link:** [https://docs.oracle.com/en/middleware/bi/analytics-server/index.html](https://docs.oracle.com/en/middleware/bi/analytics-server/index.html)

### Oracle REST Data Services (ORDS) Product Center `[Product Overview]`
- **Kirjeldus:** ORDS ametlik tooteportaal: arhitektuursed põhimõtted, AutoREST omadused ja ettevõtte mikroteenuste integreerimine.
- **Roll platvormil:** Põhjalik ülevaade ORDS OAuth2 turvamudelist, AutoREST võimekusest ja API lüüsi arhitektuurist.
- **Ametlik link:** [https://www.oracle.com/database/technologies/appdev/rest.html](https://www.oracle.com/database/technologies/appdev/rest.html)

### Oracle Cloud Console (OCI) `[Cloud Portal]`
- **Kirjeldus:** Oracle Cloud Infrastructure veebipõhine halduskonsool: Autonomous Database (ADB), virtuaalvõrgud ja API võtmed.
- **Roll platvormil:** Sihtkeskkond kavanditele 10 ja 11 (Hübriidpilv ja Autonomous Database).
- **Ametlik link:** [https://cloud.oracle.com](https://cloud.oracle.com)

### Oracle Live SQL `[Interactive Learning]`
- **Kirjeldus:** Tasuta brauseripõhine interaktiivne liivakast SQL päringute, 23ai võimaluste ja skeemide katsetamiseks.
- **Roll platvormil:** Kiire süntaksi testimine ja 23ai uute võimaluste tundmaõppimine ilma kohaliku paigalduseta.
- **Ametlik link:** [https://livesql.oracle.com](https://livesql.oracle.com)

### Oracle Database 23ai Official Documentation `[Technical Docs]`
- **Kirjeldus:** Terviklik tehniline dokumentatsioon: SQL teatmik, PL/SQL paketid, turvakäsiraamat ja administreerimine.
- **Roll platvormil:** Ametlik tehniline tugimaterjal andmebaasifunktsioonide ja süntaksi kontrollimiseks.
- **Ametlik link:** [https://docs.oracle.com/en/database/oracle/oracle-database/23/](https://docs.oracle.com/en/database/oracle/oracle-database/23/)

### Oracle APEX Documentation & Tutorials `[Technical Docs]`
- **Kirjeldus:** Ametlik APEX dokumentatsioon, API teatmikud, arhitektuurijuhendid ja ettevõtterakenduste õppematerjalid.
- **Roll platvormil:** Põhjalik abimaterjal APEX komponentide, autentimise ja REST liideste loomisel.
- **Ametlik link:** [https://docs.oracle.com/en/database/oracle/apex/](https://docs.oracle.com/en/database/oracle/apex/)

<a id="community"></a>
## Kogukond, foorumid ja üritused

### Oracle APEX Community Forums `[Official Community]`
- **Kirjeldus:** Oracle APEX ametlik globaalne arutelufoorum: küsimused-vastused, tooteuuendused ja kogukonna parimad praktikad.
- **Roll platvormil:** Keeruliste APEX probleemide lahendamine, interaktiivsete tabelite nipid ja otsesuhtlus Oracle tootejuhtidega.
- **Ametlik link:** [https://forums.oracle.com/ords/r/apexds/community/home](https://forums.oracle.com/ords/r/apexds/community/home)

### Oracle Analytics & Publisher Community `[Official Community]`
- **Kirjeldus:** Oracle Analytics Server ja Publisher ametlik kogukonnaportaal: Pixel Perfect aruandlus, RTF/XSL mallide kujundus ja nõuanded.
- **Roll platvormil:** RTF mallide jagamine, andmemudelite päringute optimeerimine ja Publisheri veateadete lahendamine.
- **Ametlik link:** [https://community.oracle.com/products/oracleanalytics/](https://community.oracle.com/products/oracleanalytics/)

### Oracle SQL Developer for VS Code Community `[Official Forum]`
- **Kirjeldus:** Ametlik tagasiside- ja tugifoorum VS Code Oracle SQL Developer laienduse arendajatele ja kasutajatele.
- **Roll platvormil:** Laienduse vigadest teatamine, uute funktsioonide soovimine ja ühenduste tõrkeotsing.
- **Ametlik link:** [https://forums.oracle.com/ords/apexds/domain/dev-community/category/sqldev-for-vscode](https://forums.oracle.com/ords/apexds/domain/dev-community/category/sqldev-for-vscode)

### Oracle APEX Global Events & Office Hours `[Events & Webinars]`
- **Kirjeldus:** APEX ülemaailmsete ürituste kalender: regulaarsed tootejuhtide veebiseminarid (Office Hours), arendajate kohtumised ja konverentsid.
- **Roll platvormil:** Uute versioonide teekaardi (APEX 26+), funktsioonide ja live-demonstratsioonide jälgimine.
- **Ametlik link:** [https://oracleapex.com/ords/r/apex_pm/apex-events/events](https://oracleapex.com/ords/r/apex_pm/apex-events/events)

### APEX Blogs Aggregator (CloudNueva) `[Community Aggregator]`
- **Kirjeldus:** Maailma suurim APEX tehniliste artiklite koondleht: indekseerib sadade ekspertide ja arendajate blogipostitusi ja koodinäiteid.
- **Roll platvormil:** Kaasaegsete koodinäidete, CSS/JS kujunduslahenduste ja praktiliste arhitektuurivõtete leidmine.
- **Ametlik link:** [https://apps.cloudnueva.com/ords/r/apps/apex_blogs/home](https://apps.cloudnueva.com/ords/r/apps/apex_blogs/home)

<a id="learning"></a>
## Õppematerjalid ja koodihoidlad

### Oracle LiveLabs Interactive Workshops `[Hands-on Labs]`
- **Kirjeldus:** Oracle tasuta praktilised samm-sammult õppelaborid: 23ai tehisintellekt, Vector Search, APEX, CI/CD ja pilvearhitektuur.
- **Roll platvormil:** Praktiline iseseisev väljaõpe 23ai uute võimaluste ja arhitektuuride omandamiseks.
- **Ametlik link:** [https://apexapps.oracle.com/pls/apex/dbpm/r/livelabs/home](https://apexapps.oracle.com/pls/apex/dbpm/r/livelabs/home)

### Oracle MyLearn Digital Learning `[Oracle University]`
- **Kirjeldus:** Oracle University ametlik digiõppe platvorm: sertifitseeritud e-kursused, rollipõhised õppeteed ja sertifitseerimiseksamid.
- **Roll platvormil:** Oracle andmebaasiadministraatori (DBA) ja APEX arendaja ametlikud pädevuskoolitused ja sertifikaadid.
- **Ametlik link:** [https://mylearn.oracle.com/ou/home](https://mylearn.oracle.com/ou/home)

### AskTOM Oracle Database Security Repository `[Security & Hardening]`
- **Kirjeldus:** Oracle ametliku andmebaasiturbe tiimi haldatav koodihoidla: turvaskriptid, TDE krüpteerimine, Unified Auditing ja privileegide audit.
- **Roll platvormil:** Andmebaasi turvataseme tõstmine (Hardening), Zero-Trust nõuete täitmine ja auditilogide seadistamine.
- **Ametlik link:** [https://github.com/oradbsec/AskTomDBSecurity](https://github.com/oradbsec/AskTomDBSecurity)
- **Allalaadimise / CLI käsk:**
  ```bash
  git clone https://github.com/oradbsec/AskTomDBSecurity.git
  ```

### Oracle AI Skills & Agentic Templates `[Agentic AI Skills]`
- **Kirjeldus:** Oracle digitaalsete assistentide ja agentse tehisintellekti oskuste koodihoidla: vestluslikud andmebaasiliidesed ja töövoomallid.
- **Roll platvormil:** Loomuliku keele tehisintellekti päringute integreerimine APEX rakendustesse ja andmebaasi.
- **Ametlik link:** [https://github.com/oracle/skills/](https://github.com/oracle/skills/)
- **Allalaadimise / CLI käsk:**
  ```bash
  git clone https://github.com/oracle/skills.git
  ```

### Oracle APEX Open Source Hub `[Open Source Hub]`
- **Kirjeldus:** Oracle APEX ametlik avatud lähtekoodiga pistikprogrammide (plug-ins), laienduste ja kujundusmallide keskus.
- **Roll platvormil:** Sertifitseeritud pistikprogrammide, dünaamiliste tegevuste ja erielementide lisamine APEX rakendustesse.
- **Ametlik link:** [https://oracle.github.io/apex/](https://oracle.github.io/apex/)

### Official Oracle Container Images Source Repository `[Official GitHub]`
- **Kirjeldus:** Oracle ametlik repositoorium Dockerfile'ide ja ehitusskriptidega: Oracle Database, WebLogic Server, Forms, FMW, Java ja Oracle Linux.
- **Roll platvormil:** Alusretseptid ja ehitusskriptid kohandatud baaskonteinerite ja WebLogic domeenide loomiseks.
- **Ametlik link:** [https://github.com/oracle/docker-images/tree/main](https://github.com/oracle/docker-images/tree/main)
- **Allalaadimise / CLI käsk:**
  ```bash
  git clone https://github.com/oracle/docker-images.git
  ```

