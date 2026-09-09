# Oficiālie Oracle resursi un konteineru attēli

[ 🇬🇧 English ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/oracle-resources-and-downloads.md) | [ 🇪🇪 Eesti ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/et/oracle-resources-and-downloads.md) | [ 🇫🇮 Suomi ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/fi/oracle-resources-and-downloads.md) | [ 🇸🇪 Svenska ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/sv/oracle-resources-and-downloads.md) | [ 🇱🇻 Latviešu ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lv/oracle-resources-and-downloads.md) | [ 🇱🇹 Lietuvių ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lt/oracle-resources-and-downloads.md)

> Apkopots oficiālo Oracle Container Registry (OCR) attēlu, lejupielāžu, dokumentācijas portālu, kopienas forumu un mācību krātuvju saraksts.

---

**Jump to section:** [Konteineru attēli (OCR)](#containers) • [Oficiālās lejupielādes](#downloads) • [Dokumentācija un mākoņportāli](#portals) • [Kopiena, forumi un pasākumi](#community) • [Mācības un koda krātuves](#learning)

---

<a id="containers"></a>
## Konteineru attēli (OCR)

### Oracle Database 23ai Free `[OCR Official]`
- **Apraksts:** Oficiālais Oracle 23ai Free datubāzes konteiners ar AI vektoru meklēšanu, JSON-relāciju dualitāti un PDB atbalstu.
- **Loma platformā:** Bāzes datubāze vietējai izstrādei, CI/CD cauruļvadiem un testēšanai.
- **Oficiālā saite:** [https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Ffree](https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Ffree)
- **Lejupielādes / CLI komanda:**
  ```bash
  podman pull container-registry.oracle.com/database/free:latest
  ```

### Oracle REST Data Services (ORDS) `[OCR Official]`
- **Apraksts:** Sertificēts ORDS konteiners: AutoREST API, APEX resursu maršrutēšana un OAuth2 drošība.
- **Loma platformā:** Viegls tīmekļa klausītājs HTTPS trafika novirzīšanai uz PDB datubāzēm.
- **Oficiālā saite:** [https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Fords](https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Fords)
- **Lejupielādes / CLI komanda:**
  ```bash
  podman pull container-registry.oracle.com/database/ords:latest
  ```

### Oracle SQLcl CLI Container `[OCR Official]`
- **Apraksts:** Oficiāls SQLcl konteiners ar Java 21, Liquibase un APEXlang kompilatoru.
- **Loma platformā:** Nodrošina SQLcl izpildi bez lokālas instalācijas korporatīvajās darbstacijās.
- **Oficiālā saite:** [https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Fsqlcl](https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Fsqlcl)
- **Lejupielādes / CLI komanda:**
  ```bash
  podman pull container-registry.oracle.com/database/sqlcl:latest
  ```

### Oracle Container Registry (OCR) Portal `[OCR Portal]`
- **Apraksts:** Oracle oficiālais konteineru reģistrs ar sertificētiem un drošības pārbaudītiem attēliem.
- **Loma platformā:** Licences noteikumu pieņemšana un oficiālo konteineru meklēšana.
- **Oficiālā saite:** [https://container-registry.oracle.com/](https://container-registry.oracle.com/)
- **Lejupielādes / CLI komanda:**
  ```bash
  podman login container-registry.oracle.com
  ```

### Oracle Linux 9 Slim `[OCR Base]`
- **Apraksts:** Minimāls uzņēmuma Linux bāzes attēls ar drošības ielāpiem.
- **Loma platformā:** Bāzes attēls pielāgotu aplikāciju veidošanai.
- **Oficiālā saite:** [https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:os%2Foraclelinux](https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:os%2Foraclelinux)
- **Lejupielādes / CLI komanda:**
  ```bash
  podman pull container-registry.oracle.com/os/oraclelinux:9-slim
  ```

### Oracle Database Free FastStart Containers (gvenzl) `[Docker Hub / GitHub]`
- **Apraksts:** Džeralda Venzla Oracle Database Free konteineru krātuve ar FastStart attēliem un AMD64/ARM64 atbalstu.
- **Loma platformā:** Ātra izstrādes plūsma ar FastStart attēliem un darbs uz Apple Silicon.
- **Oficiālā saite:** [https://github.com/gvenzl/oci-oracle-free](https://github.com/gvenzl/oci-oracle-free)
- **Lejupielādes / CLI komanda:**
  ```bash
  podman pull docker.io/gvenzl/oracle-free:23-full-faststart
  ```

### Oracle Forms & Reports 14c Container `[Docker Hub]`
- **Apraksts:** Pilnībā sagatavots Oracle Forms 14c konteiners ar WebLogic un noVNC Forms Builder.
- **Loma platformā:** Blueprint 6 & 7: Forms sistēmu modernizācija un migrācija uz APEX.
- **Oficiālā saite:** [https://hub.docker.com/r/allanlahe/oracle-forms](https://hub.docker.com/r/allanlahe/oracle-forms)
- **Lejupielādes / CLI komanda:**
  ```bash
  podman pull docker.io/allanlahe/oracle-forms:14.1.2
  ```

### Oracle Analytics Publisher Container `[Docker Hub]`
- **Apraksts:** Pārskatu dzinēja konteiners ar OPatch drošības ielāpiem un PDF ģenerēšanu.
- **Loma platformā:** Blueprint 4 & 5: Automatizēta dokumentu un rēķinu izveide.
- **Oficiālā saite:** [https://hub.docker.com/r/allanlahe/oracle-publisher](https://hub.docker.com/r/allanlahe/oracle-publisher)
- **Lejupielādes / CLI komanda:**
  ```bash
  podman pull docker.io/allanlahe/oracle-publisher:latest
  ```

<a id="downloads"></a>
## Oficiālās lejupielādes

### Oracle APEX Downloads `[Official Download]`
- **Apraksts:** Jaunākā oficiālā APEX pakotne ar shēmām, dzinēju un resursiem.
- **Loma platformā:** Automatizēta instalācija konteinerā bez atarhivēšanas resursdatorā.
- **Oficiālā saite:** [https://www.oracle.com/tools/downloads/apex-downloads.html](https://www.oracle.com/tools/downloads/apex-downloads.html)
- **Lejupielādes / CLI komanda:**
  ```bash
  curl -LO https://download.oracle.com/otn_software/apex/apex-latest.zip
  ```

### Oracle REST Data Services (ORDS) Downloads `[Official Download]`
- **Apraksts:** Oficiālās ORDS binārās pakotnes pielāgotām instalācijām.
- **Loma platformā:** Alternatīva lokālā uzstādīšana ar install-ords-standalone.sh.
- **Oficiālā saite:** [https://www.oracle.com/database/technologies/appdev/rest-data-services-downloads.html](https://www.oracle.com/database/technologies/appdev/rest-data-services-downloads.html)
- **Lejupielādes / CLI komanda:**
  ```bash
  curl -LO https://download.oracle.com/otn_software/java/ords/ords-latest.zip
  ```

### Oracle SQLcl Standalone Download `[Official Download]`
- **Apraksts:** Mūsdienīgs komandrindas rīks Oracle datubāzei ar koda pabeigšanu un Liquibase.
- **Loma platformā:** Izstrādātāja ikdienas CLI rīks darbam ar datubāzi.
- **Oficiālā saite:** [https://www.oracle.com/database/sqldev/technologies/sqlcl/download/](https://www.oracle.com/database/sqldev/technologies/sqlcl/download/)
- **Lejupielādes / CLI komanda:**
  ```bash
  curl -LO https://download.oracle.com/otn_software/java/sqldev/sqlcl-latest.zip
  ```

### Oracle Analytics Publisher Software & Template Builder `[Official Download]`
- **Apraksts:** Oficiālās lejupielādes Oracle Analytics Publisher serverim un Desktop Template Builder rīkam priekš Word/Excel.
- **Loma platformā:** Template Builder uzstādīšana programmā MS Word pārskatu vizuālai veidošanai.
- **Oficiālā saite:** [https://www.oracle.com/middleware/technologies/analytics-publisher/downloads.html](https://www.oracle.com/middleware/technologies/analytics-publisher/downloads.html)

### Oracle Instant Client (Basic & SDK) `[Official Download]`
- **Apraksts:** Klienta bibliotēkas Python, Node.js un C/C++ lietotņu savienošanai ar Oracle.
- **Loma platformā:** Thick-driver režīms un paplašināts tīkla protokolu atbalsts.
- **Oficiālā saite:** [https://www.oracle.com/database/technologies/instant-client/downloads.html](https://www.oracle.com/database/technologies/instant-client/downloads.html)
- **Lejupielādes / CLI komanda:**
  ```bash
  # Select package for macOS (ARM64/x86), Linux, or Windows
  ```

### Oracle SQL Developer for VS Code `[VS Code Marketplace]`
- **Apraksts:** Oficiālais VS Code paplašinājums ar SQL redaktoru, objektu koku un iebūvētu SQLcl.
- **Loma platformā:** IDE vide, kas tiek automātiski nokonfigurēta ar register-connections.sh.
- **Oficiālā saite:** [https://marketplace.visualstudio.com/items?itemName=Oracle.sql-developer](https://marketplace.visualstudio.com/items?itemName=Oracle.sql-developer)
- **Lejupielādes / CLI komanda:**
  ```bash
  code --install-extension Oracle.sql-developer
  ```

<a id="portals"></a>
## Dokumentācija un mākoņportāli

### Oracle Database Free Home & Features `[Product Overview]`
- **Apraksts:** Oracle Database Free oficiālā produkta lapa ar tehniskajām specifikācijām un ierobežojumiem (2 CPU, 2 GB RAM, 12 GB dati).
- **Loma platformā:** Licences noteikumu un ražošanas ierobežojumu pārbaude.
- **Oficiālā saite:** [https://www.oracle.com/database/free/](https://www.oracle.com/database/free/)

### Oracle APEX 26.1 APEXlang Specification `[Language Spec]`
- **Apraksts:** Oficiālā APEXlang valodas specifikācija un gramatika deklaratīvai lietotņu definēšanai (.apx).
- **Loma platformā:** Sintakses rokasgrāmata APEXlang DSL un AI koda ģenerēšanai.
- **Oficiālā saite:** [https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/?component=app](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/?component=app)

### Oracle Architecture Center Technology Catalog `[Architecture Center]`
- **Apraksts:** Oracle arhitektūras centra katalogs: references arhitektūras, plāni un korporatīvie risinājumi.
- **Loma platformā:** Arhitektūras salīdzināšana hibrīdmākoņa un daudzslāņu sistēmām.
- **Oficiālā saite:** [https://apexadb.oracle.com/ords/r/tech/catalog/home](https://apexadb.oracle.com/ords/r/tech/catalog/home)

### Oracle Forms 14c (14.1.2) Documentation `[Technical Docs]`
- **Apraksts:** Pilna dokumentācija Oracle Forms 14c uzstādīšanai, WebLogic konfigurēšanai un modernizācijai.
- **Loma platformā:** Rokasgrāmata Blueprint 6 un 7 modeļiem un Forms migrācijai.
- **Oficiālā saite:** [https://docs.oracle.com/en/middleware/developer-tools/forms/14.1.2/index.html](https://docs.oracle.com/en/middleware/developer-tools/forms/14.1.2/index.html)

### Oracle Analytics Server & Publisher Documentation `[Technical Docs]`
- **Apraksts:** Oficiālā tehniskā dokumentācija Oracle Analytics Server un Publisher dzinējam.
- **Loma platformā:** Konfigurācijas ceļvedis Blueprint 4 un 5 risinājumiem.
- **Oficiālā saite:** [https://docs.oracle.com/en/middleware/bi/analytics-server/index.html](https://docs.oracle.com/en/middleware/bi/analytics-server/index.html)

### Oracle REST Data Services (ORDS) Product Center `[Product Overview]`
- **Apraksts:** ORDS produkta centrs ar arhitektūras plāniem un AutoREST integrācijas iespējām.
- **Loma platformā:** ORDS OAuth2 drošības modeļa un API vārtejas izpēte.
- **Oficiālā saite:** [https://www.oracle.com/database/technologies/appdev/rest.html](https://www.oracle.com/database/technologies/appdev/rest.html)

### Oracle Cloud Console (OCI) `[Cloud Portal]`
- **Apraksts:** Oracle Cloud Infrastructure pārvaldības konsole ar Autonomous Database un API atslēgām.
- **Loma platformā:** Mērķa mākoņvide Blueprint 10 un 11 arhitektūrām.
- **Oficiālā saite:** [https://cloud.oracle.com](https://cloud.oracle.com)

### Oracle Live SQL `[Interactive Learning]`
- **Apraksts:** Bezmaksas interaktīva vide pārlūkā SQL vaicājumu un 23ai funkciju apguvei.
- **Loma platformā:** Ātra sintakses pārbaude un iepazīšanās ar jaunajām 23ai funkcijām.
- **Oficiālā saite:** [https://livesql.oracle.com](https://livesql.oracle.com)

### Oracle Database 23ai Official Documentation `[Technical Docs]`
- **Apraksts:** Pilna tehniskā dokumentācija: SQL, PL/SQL, drošība un administrēšana.
- **Loma platformā:** Autoritatīvs avots datubāzes iespēju un sintakses izpētei.
- **Oficiālā saite:** [https://docs.oracle.com/en/database/oracle/oracle-database/23/](https://docs.oracle.com/en/database/oracle/oracle-database/23/)

### Oracle APEX Documentation & Tutorials `[Technical Docs]`
- **Apraksts:** Oficiālā APEX dokumentācija, API rokasgrāmatas un arhitektūras ceļveži.
- **Loma platformā:** Būtiska rokasgrāmata APEX komponentu un autentifikācijas izstrādei.
- **Oficiālā saite:** [https://docs.oracle.com/en/database/oracle/apex/](https://docs.oracle.com/en/database/oracle/apex/)

<a id="community"></a>
## Kopiena, forumi un pasākumi

### Oracle APEX Community Forums `[Official Community]`
- **Apraksts:** Oficiālais Oracle APEX kopienas forums jautājumiem, atbildēm un jaunumiem.
- **Loma platformā:** APEX kļūdu novēršana un konsultācijas ar kopienas ekspertiem.
- **Oficiālā saite:** [https://forums.oracle.com/ords/r/apexds/community/home](https://forums.oracle.com/ords/r/apexds/community/home)

### Oracle Analytics & Publisher Community `[Official Community]`
- **Apraksts:** Oracle Analytics un Publisher kopiena: Pixel Perfect atskaites, veidnes un ekspertu atbalsts.
- **Loma platformā:** Pārskatu veidņu apmaiņa un formatēšanas problēmu risināšana.
- **Oficiālā saite:** [https://community.oracle.com/products/oracleanalytics/](https://community.oracle.com/products/oracleanalytics/)

### Oracle SQL Developer for VS Code Community `[Official Forum]`
- **Apraksts:** Oficiālais atbalsta forums VS Code Oracle SQL Developer paplašinājumam.
- **Loma platformā:** Kļūdu ziņošana un savienojumu problēmu risināšana.
- **Oficiālā saite:** [https://forums.oracle.com/ords/apexds/domain/dev-community/category/sqldev-for-vscode](https://forums.oracle.com/ords/apexds/domain/dev-community/category/sqldev-for-vscode)

### Oracle APEX Global Events & Office Hours `[Events & Webinars]`
- **Apraksts:** Globālais APEX pasākumu, Office Hours vebināru un konferenču kalendārs.
- **Loma platformā:** Jauno APEX versiju un funkciju demonstrāciju vērošana tiešraidē.
- **Oficiālā saite:** [https://oracleapex.com/ords/r/apex_pm/apex-events/events](https://oracleapex.com/ords/r/apex_pm/apex-events/events)

### APEX Blogs Aggregator (CloudNueva) `[Community Aggregator]`
- **Apraksts:** Kopienas emuāru apkopotājs ar tūkstošiem tehnisko rakstu un padomu par Oracle APEX.
- **Loma platformā:** Mūsdienīgu koda paraugu un dizaina risinājumu meklēšana.
- **Oficiālā saite:** [https://apps.cloudnueva.com/ords/r/apps/apex_blogs/home](https://apps.cloudnueva.com/ords/r/apps/apex_blogs/home)

<a id="learning"></a>
## Mācības un koda krātuves

### Oracle LiveLabs Interactive Workshops `[Hands-on Labs]`
- **Apraksts:** Bezmaksas praktiskās apmācību laboratorijas par Oracle 23ai, APEX un mākoņtehnoloģijām.
- **Loma platformā:** Praktiska apmācība platformas tehnoloģiju apguvei.
- **Oficiālā saite:** [https://apexapps.oracle.com/pls/apex/dbpm/r/livelabs/home](https://apexapps.oracle.com/pls/apex/dbpm/r/livelabs/home)

### Oracle MyLearn Digital Learning `[Oracle University]`
- **Apraksts:** Oracle University digitālā mācību platforma ar sertificētiem kursiem un eksāmeniem.
- **Loma platformā:** Profesionālā sertifikācija datubāzu administratoriem un izstrādātājiem.
- **Oficiālā saite:** [https://mylearn.oracle.com/ou/home](https://mylearn.oracle.com/ou/home)

### AskTOM Oracle Database Security Repository `[Security & Hardening]`
- **Apraksts:** Oracle drošības komandas krātuve ar skriptiem TDE šifrēšanai, auditam un stiprināšanai.
- **Loma platformā:** Datubāzes drošības paaugstināšana un Zero-Trust ieviešana.
- **Oficiālā saite:** [https://github.com/oradbsec/AskTomDBSecurity](https://github.com/oradbsec/AskTomDBSecurity)
- **Lejupielādes / CLI komanda:**
  ```bash
  git clone https://github.com/oradbsec/AskTomDBSecurity.git
  ```

### Oracle AI Skills & Agentic Templates `[Agentic AI Skills]`
- **Apraksts:** Oracle atvērtā koda krātuve AI prasmēm un digitālajiem asistentiem.
- **Loma platformā:** Dabiskās valodas vaicājumu integrēšana APEX lietotnēs.
- **Oficiālā saite:** [https://github.com/oracle/skills/](https://github.com/oracle/skills/)
- **Lejupielādes / CLI komanda:**
  ```bash
  git clone https://github.com/oracle/skills.git
  ```

### Oracle APEX Open Source Hub `[Open Source Hub]`
- **Apraksts:** Oficiālā Oracle atvērtā koda spraudņu un veidņu vietne APEX izstrādātājiem.
- **Loma platformā:** Pārbaudītu spraudņu un dinamisko darbību pievienošana lietotnēm.
- **Oficiālā saite:** [https://oracle.github.io/apex/](https://oracle.github.io/apex/)

### Official Oracle Container Images Source Repository `[Official GitHub]`
- **Apraksts:** Oficiālā Oracle krātuve ar Dockerfile un būvēšanas skriptiem Oracle programmatūrai (Database, WebLogic, Forms, Java).
- **Loma platformā:** Bāzes receptes pielāgotu konteineru un WebLogic domēnu būvēšanai.
- **Oficiālā saite:** [https://github.com/oracle/docker-images/tree/main](https://github.com/oracle/docker-images/tree/main)
- **Lejupielādes / CLI komanda:**
  ```bash
  git clone https://github.com/oracle/docker-images.git
  ```

