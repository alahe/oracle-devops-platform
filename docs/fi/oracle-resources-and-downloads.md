# Viralliset Oracle-resurssit ja konttikuvat

[ 🇬🇧 English ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/oracle-resources-and-downloads.md) | [ 🇪🇪 Eesti ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/et/oracle-resources-and-downloads.md) | [ 🇫🇮 Suomi ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/fi/oracle-resources-and-downloads.md) | [ 🇸🇪 Svenska ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/sv/oracle-resources-and-downloads.md) | [ 🇱🇻 Latviešu ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lv/oracle-resources-and-downloads.md) | [ 🇱🇹 Lietuvių ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lt/oracle-resources-and-downloads.md)

> Kokoelma virallisia Oracle Container Registry (OCR) -kuvia, latauslinkkejä, dokumentaatioportaaleja, yhteisöfoorumeita ja oppimisrepositorioita.

---

**Jump to section:** [Konttikuvalähteet (OCR)](#containers) • [Viralliset lataukset](#downloads) • [Dokumentaatio ja pilviportaalit](#portals) • [Yhteisö, foorumit ja tapahtumat](#community) • [Oppiminen ja koodivarastot](#learning)

---

<a id="containers"></a>
## Konttikuvalähteet (OCR)

### Oracle Database 23ai Free `[OCR Official]`
- **Kuvaus:** Virallinen Oracle 23ai Free -tietokantakontti: AI-vektorihaku, JSON-relaatiodualiteetti ja PDB-tuki.
- **Rooli alustalla:** Perustietokanta paikalliseen kehitykseen, CI/CD-putkiin ja testaukseen.
- **Virallinen linkki:** [https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Ffree](https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Ffree)
- **Lataus- tai CLI-komento:**
  ```bash
  podman pull container-registry.oracle.com/database/free:latest
  ```

### Oracle REST Data Services (ORDS) `[OCR Official]`
- **Kuvaus:** Valmiiksi koottu ORDS-kontti: AutoREST-rajapinnat, APEX-staattiset tiedostot ja OAuth2-tietoturva.
- **Rooli alustalla:** Resurssitehokas verkkokuuntelija HTTPS-liikenteen välittämiseen PDB-tietokantoihin.
- **Virallinen linkki:** [https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Fords](https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Fords)
- **Lataus- tai CLI-komento:**
  ```bash
  podman pull container-registry.oracle.com/database/ords:latest
  ```

### Oracle SQLcl CLI Container `[OCR Official]`
- **Kuvaus:** Virallinen SQLcl-konttikuva: Java 21, Liquibase-skeemanhallinta ja APEXlang-kääntäjä.
- **Rooli alustalla:** Mahdollistaa SQLcl-ajon ilman paikallista asennusta lukituilla yrityskoneilla.
- **Virallinen linkki:** [https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Fsqlcl](https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Fsqlcl)
- **Lataus- tai CLI-komento:**
  ```bash
  podman pull container-registry.oracle.com/database/sqlcl:latest
  ```

### Oracle Container Registry (OCR) Portal `[OCR Portal]`
- **Kuvaus:** Oraclen virallinen konttirekisteri sertifioiduille ja tietoturvatarkastetuille konteille.
- **Rooli alustalla:** Käyttöehtojen hyväksyminen ja virallisten Oracle-konttien haku.
- **Virallinen linkki:** [https://container-registry.oracle.com/](https://container-registry.oracle.com/)
- **Lataus- tai CLI-komento:**
  ```bash
  podman login container-registry.oracle.com
  ```

### Oracle Linux 9 Slim `[OCR Base]`
- **Kuvaus:** Minimaalisen kokoinen yritys-Linux-peruskuva tietoturvapäivityksillä.
- **Rooli alustalla:** Pohjakuva omille sovelluslaajennuksille ja kehitystyökaluille.
- **Virallinen linkki:** [https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:os%2Foraclelinux](https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:os%2Foraclelinux)
- **Lataus- tai CLI-komento:**
  ```bash
  podman pull container-registry.oracle.com/os/oraclelinux:9-slim
  ```

### Oracle Database Free FastStart Containers (gvenzl) `[Docker Hub / GitHub]`
- **Kuvaus:** Gerald Venzlin suosittu Oracle Database Free -konttikuvarepositorio FastStart-kuvilla ja AMD64/ARM64-tuella.
- **Rooli alustalla:** Kehitystyön nopeuttaminen FastStart-kuvilla ja natiiviajo Apple Siliconilla.
- **Virallinen linkki:** [https://github.com/gvenzl/oci-oracle-free](https://github.com/gvenzl/oci-oracle-free)
- **Lataus- tai CLI-komento:**
  ```bash
  podman pull docker.io/gvenzl/oracle-free:23-full-faststart
  ```

### Oracle Forms & Reports 14c Container `[Docker Hub]`
- **Kuvaus:** Valmiiksi konfiguroitu Oracle Forms 14c -kontti: WebLogic, noVNC Forms Builder ja kääntäjä.
- **Rooli alustalla:** Blueprint 6 & 7: Forms-järjestelmien modernisointi ja siirto APEXiin.
- **Virallinen linkki:** [https://hub.docker.com/r/allanlahe/oracle-forms](https://hub.docker.com/r/allanlahe/oracle-forms)
- **Lataus- tai CLI-komento:**
  ```bash
  podman pull docker.io/allanlahe/oracle-forms:14.1.2
  ```

### Oracle Analytics Publisher Container `[Docker Hub]`
- **Kuvaus:** Yritystason pixel-perfect raportointikontti OPatch-päivityksillä ja PDF-moottorilla.
- **Rooli alustalla:** Blueprint 4 & 5: Asiakirjojen ja laskujen automatisoitu luonti.
- **Virallinen linkki:** [https://hub.docker.com/r/allanlahe/oracle-publisher](https://hub.docker.com/r/allanlahe/oracle-publisher)
- **Lataus- tai CLI-komento:**
  ```bash
  podman pull docker.io/allanlahe/oracle-publisher:latest
  ```

<a id="downloads"></a>
## Viralliset lataukset

### Oracle APEX Downloads `[Official Download]`
- **Kuvaus:** Uusin virallinen APEX-jakelupaketti tietokantamoottorille ja staattisille tiedostoille.
- **Rooli alustalla:** Automaattinen asennus suoraan konttiin ilman purkamista isäntäkoneelle.
- **Virallinen linkki:** [https://www.oracle.com/tools/downloads/apex-downloads.html](https://www.oracle.com/tools/downloads/apex-downloads.html)
- **Lataus- tai CLI-komento:**
  ```bash
  curl -LO https://download.oracle.com/otn_software/apex/apex-latest.zip
  ```

### Oracle REST Data Services (ORDS) Downloads `[Official Download]`
- **Kuvaus:** Viralliset ORDS-binaarit itsenäisiin asennuksiin ja rajapintojen hallintaan.
- **Rooli alustalla:** Vaihtoehtoinen paikallinen asennus skriptillä install-ords-standalone.sh.
- **Virallinen linkki:** [https://www.oracle.com/database/technologies/appdev/rest-data-services-downloads.html](https://www.oracle.com/database/technologies/appdev/rest-data-services-downloads.html)
- **Lataus- tai CLI-komento:**
  ```bash
  curl -LO https://download.oracle.com/otn_software/java/ords/ords-latest.zip
  ```

### Oracle SQLcl Standalone Download `[Official Download]`
- **Kuvaus:** Moderni Oracle-tietokannan komentorivityökalu automaattitäydennyksellä ja Liquibase-tuella.
- **Rooli alustalla:** Kehittäjän päivittäinen CLI-työkalu tietokantayhteyksiin ja skripteihin.
- **Virallinen linkki:** [https://www.oracle.com/database/sqldev/technologies/sqlcl/download/](https://www.oracle.com/database/sqldev/technologies/sqlcl/download/)
- **Lataus- tai CLI-komento:**
  ```bash
  curl -LO https://download.oracle.com/otn_software/java/sqldev/sqlcl-latest.zip
  ```

### Oracle Analytics Publisher Software & Template Builder `[Official Download]`
- **Kuvaus:** Oracle Analytics Publisherin viralliset palvelinlataukset ja Desktop Template Builder -mallityökalu (Word/Excel).
- **Rooli alustalla:** Template Builderin asennus MS Wordiin pixel-perfect-raporttien suunnittelua varten.
- **Virallinen linkki:** [https://www.oracle.com/middleware/technologies/analytics-publisher/downloads.html](https://www.oracle.com/middleware/technologies/analytics-publisher/downloads.html)

### Oracle Instant Client (Basic & SDK) `[Official Download]`
- **Kuvaus:** Natiivikirjastot Python-, Node.js- ja C/C++-sovellusten tietokantayhteyksille.
- **Rooli alustalla:** Thick driver -tila ja laajennetut verkko-ominaisuudet.
- **Virallinen linkki:** [https://www.oracle.com/database/technologies/instant-client/downloads.html](https://www.oracle.com/database/technologies/instant-client/downloads.html)
- **Lataus- tai CLI-komento:**
  ```bash
  # Select package for macOS (ARM64/x86), Linux, or Windows
  ```

### Oracle SQL Developer for VS Code `[VS Code Marketplace]`
- **Kuvaus:** Virallinen VS Code -laajennus: SQL-työarkki, objektiselain, integroitu SQLcl ja yhteyksien hallinta.
- **Rooli alustalla:** Graafinen kehitysympäristö, jonka yhteydet määritellään automaattisesti register-connections.sh-skriptillä.
- **Virallinen linkki:** [https://marketplace.visualstudio.com/items?itemName=Oracle.sql-developer](https://marketplace.visualstudio.com/items?itemName=Oracle.sql-developer)
- **Lataus- tai CLI-komento:**
  ```bash
  code --install-extension Oracle.sql-developer
  ```

<a id="portals"></a>
## Dokumentaatio ja pilviportaalit

### Oracle Database Free Home & Features `[Product Overview]`
- **Kuvaus:** Oracle Database Free -tuotesivu teknisine määrittelyineen (2 CPU, 2 GB RAM, 12 GB dataa) ja usein kysyttyine kysymyksineen.
- **Rooli alustalla:** Lisenssiehtojen ja tuotantokäytön rajoitusten tarkistaminen.
- **Virallinen linkki:** [https://www.oracle.com/database/free/](https://www.oracle.com/database/free/)

### Oracle APEX 26.1 APEXlang Specification `[Language Spec]`
- **Kuvaus:** Virallinen APEXlang-kielimäärittely ja kielioppi deklaratiiviselle sovelluskielelle (.apx).
- **Rooli alustalla:** Syntaksin viite APEXlang DSL -luontiin ja tekoälypohjaiseen koodaukseen.
- **Virallinen linkki:** [https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/?component=app](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/?component=app)

### Oracle Architecture Center Technology Catalog `[Architecture Center]`
- **Kuvaus:** Oraclen arkkitehtuurikeskuksen luettelo: referenssiarkkitehtuurit, blueprintit ja yritysratkaisut.
- **Rooli alustalla:** Arkkitehtuurien vertailu ja linjaus hybridi- ja monikantaratkaisuihin.
- **Virallinen linkki:** [https://apexadb.oracle.com/ords/r/tech/catalog/home](https://apexadb.oracle.com/ords/r/tech/catalog/home)

### Oracle Forms 14c (14.1.2) Documentation `[Technical Docs]`
- **Kuvaus:** Täydellinen dokumentaatio Oracle Forms 14c:n asennukselle, WebLogic-määrityksille ja selainintegraatiolle.
- **Rooli alustalla:** Ohjemateriaali Forms-konteille ja APEX-migraatiolle malleissa 6 ja 7.
- **Virallinen linkki:** [https://docs.oracle.com/en/middleware/developer-tools/forms/14.1.2/index.html](https://docs.oracle.com/en/middleware/developer-tools/forms/14.1.2/index.html)

### Oracle Analytics Server & Publisher Documentation `[Technical Docs]`
- **Kuvaus:** Virallinen dokumentaatiokirjasto Oracle Analytics Serverille ja Publisher-raportointimoottorille.
- **Rooli alustalla:** Raportointipalvelimen ja tietoturvan asetukset malleissa 4 ja 5.
- **Virallinen linkki:** [https://docs.oracle.com/en/middleware/bi/analytics-server/index.html](https://docs.oracle.com/en/middleware/bi/analytics-server/index.html)

### Oracle REST Data Services (ORDS) Product Center `[Product Overview]`
- **Kuvaus:** ORDS-tuoteportaali: arkkitehtuurimallit, AutoREST-ominaisuudet ja mikropalveluintegraatiot.
- **Rooli alustalla:** Perehtyminen ORDS OAuth2 -tietoturvaan ja AutoREST-ominaisuuksiin.
- **Virallinen linkki:** [https://www.oracle.com/database/technologies/appdev/rest.html](https://www.oracle.com/database/technologies/appdev/rest.html)

### Oracle Cloud Console (OCI) `[Cloud Portal]`
- **Kuvaus:** Oracle Cloud Infrastructuren hallintaportaali Autonomous Databasen ja pilviresurssien hallintaan.
- **Rooli alustalla:** Kohdeympäristö malleille 10 ja 11 (Hybridi- ja monialuepilvi).
- **Virallinen linkki:** [https://cloud.oracle.com](https://cloud.oracle.com)

### Oracle Live SQL `[Interactive Learning]`
- **Kuvaus:** Ilmainen selaimessa toimiva hiekkalaatikko SQL-kyselyiden ja 23ai-ominaisuuksien testaamiseen.
- **Rooli alustalla:** Nopea syntaksin testaus ja 23ai-uutuuksien kokeilu.
- **Virallinen linkki:** [https://livesql.oracle.com](https://livesql.oracle.com)

### Oracle Database 23ai Official Documentation `[Technical Docs]`
- **Kuvaus:** Kattava tekninen dokumentaatio: SQL- ja PL/SQL-oppaat, tietoturva ja ylläpito.
- **Rooli alustalla:** Virallinen lähdemateriaali tietokannan toiminnoille.
- **Virallinen linkki:** [https://docs.oracle.com/en/database/oracle/oracle-database/23/](https://docs.oracle.com/en/database/oracle/oracle-database/23/)

### Oracle APEX Documentation & Tutorials `[Technical Docs]`
- **Kuvaus:** Virallinen APEX-dokumentaatio, rajapintakuvaukset ja yrityssovellusten oppaat.
- **Rooli alustalla:** Keskeinen opas APEX-komponenttien ja autentikoinnin suunnitteluun.
- **Virallinen linkki:** [https://docs.oracle.com/en/database/oracle/apex/](https://docs.oracle.com/en/database/oracle/apex/)

<a id="community"></a>
## Yhteisö, foorumit ja tapahtumat

### Oracle APEX Community Forums `[Official Community]`
- **Kuvaus:** Virallinen Oracle APEX -yhteisöfoorumi kysymyksille, tuotejulkaisuille ja asiantuntijavastauksille.
- **Rooli alustalla:** Monimutkaisten APEX-haasteiden ratkonta ja asiantuntijaneuvot.
- **Virallinen linkki:** [https://forums.oracle.com/ords/r/apexds/community/home](https://forums.oracle.com/ords/r/apexds/community/home)

### Oracle Analytics & Publisher Community `[Official Community]`
- **Kuvaus:** Oracle Analytics- ja Publisher-yhteisö: Pixel Perfect -raportointi, RTF-mallit ja asiantuntijaneuvonta.
- **Rooli alustalla:** Raportointimallien optimointi ja Publisher-ongelmien selvitys.
- **Virallinen linkki:** [https://community.oracle.com/products/oracleanalytics/](https://community.oracle.com/products/oracleanalytics/)

### Oracle SQL Developer for VS Code Community `[Official Forum]`
- **Kuvaus:** Virallinen tukifoorumi VS Code Oracle SQL Developer -laajennukselle.
- **Rooli alustalla:** Laajennuksen kehitysehdotukset ja yhteysongelmien ratkaisu.
- **Virallinen linkki:** [https://forums.oracle.com/ords/apexds/domain/dev-community/category/sqldev-for-vscode](https://forums.oracle.com/ords/apexds/domain/dev-community/category/sqldev-for-vscode)

### Oracle APEX Global Events & Office Hours `[Events & Webinars]`
- **Kuvaus:** APEX-tapahtumakalenteri: Office Hours -webinaarit, kehittäjätapaamiset ja konferenssit.
- **Rooli alustalla:** Tulevien versioiden ja APEX-tiekartan seuraaminen suorissa lähetyksissä.
- **Virallinen linkki:** [https://oracleapex.com/ords/r/apex_pm/apex-events/events](https://oracleapex.com/ords/r/apex_pm/apex-events/events)

### APEX Blogs Aggregator (CloudNueva) `[Community Aggregator]`
- **Kuvaus:** Kattava yhteisöaggregaattori, joka kokoaa tuhansia APEX-asiantuntijoiden artikkeleita ja ohjeita.
- **Rooli alustalla:** Koodiesimerkkien ja modernien APEX-ratkaisujen haku.
- **Virallinen linkki:** [https://apps.cloudnueva.com/ords/r/apps/apex_blogs/home](https://apps.cloudnueva.com/ords/r/apps/apex_blogs/home)

<a id="learning"></a>
## Oppiminen ja koodivarastot

### Oracle LiveLabs Interactive Workshops `[Hands-on Labs]`
- **Kuvaus:** Ilmaiset ohjatut käytännön harjoituslaboratoriot Oracle 23ai:lle, APEXille ja pilviarkkitehtuureille.
- **Rooli alustalla:** Käytännönläheinen oppiminen alustan teknologioiden hyödyntämiseen.
- **Virallinen linkki:** [https://apexapps.oracle.com/pls/apex/dbpm/r/livelabs/home](https://apexapps.oracle.com/pls/apex/dbpm/r/livelabs/home)

### Oracle MyLearn Digital Learning `[Oracle University]`
- **Kuvaus:** Oracle Universityn digitaalinen oppimisalusta sertifioiduilla kursseilla ja oppimispoluilla.
- **Rooli alustalla:** Ammatilliset sertifioinnit DBA- ja APEX-osaajille.
- **Virallinen linkki:** [https://mylearn.oracle.com/ou/home](https://mylearn.oracle.com/ou/home)

### AskTOM Oracle Database Security Repository `[Security & Hardening]`
- **Kuvaus:** Oracle-tietoturvatiimin ylläpitämä koodivarasto: TDE-salaus, auditointi ja oikeuksien tarkistus.
- **Rooli alustalla:** Tietokannan kovennus ja Zero-Trust-tietoturvamallien käyttöönotto.
- **Virallinen linkki:** [https://github.com/oradbsec/AskTomDBSecurity](https://github.com/oradbsec/AskTomDBSecurity)
- **Lataus- tai CLI-komento:**
  ```bash
  git clone https://github.com/oradbsec/AskTomDBSecurity.git
  ```

### Oracle AI Skills & Agentic Templates `[Agentic AI Skills]`
- **Kuvaus:** Oracle-tekoälytaitojen ja digitaalisten assistenttien avoimen koodin repositorio.
- **Rooli alustalla:** Tekoälypohjaisten kyselyjen liittäminen APEX-sovelluksiin.
- **Virallinen linkki:** [https://github.com/oracle/skills/](https://github.com/oracle/skills/)
- **Lataus- tai CLI-komento:**
  ```bash
  git clone https://github.com/oracle/skills.git
  ```

### Oracle APEX Open Source Hub `[Open Source Hub]`
- **Kuvaus:** Oraclen virallinen avoimen lähdekoodin lisäosien, mallien ja laajennusten keskus APEXille.
- **Rooli alustalla:** Sertifioitujen lisäosien ja dynaamisten toimintojen lisääminen sovelluksiin.
- **Virallinen linkki:** [https://oracle.github.io/apex/](https://oracle.github.io/apex/)

### Official Oracle Container Images Source Repository `[Official GitHub]`
- **Kuvaus:** Virallinen Oracle-repositorio, joka sisältää Dockerfilet ja skriptit Oracle-ohjelmistoille (Database, WebLogic, Forms, Java).
- **Rooli alustalla:** Referenssiohjeet ja skriptit räätälöityjen peruskonttien ja WebLogic-ympäristöjen luomiseen.
- **Virallinen linkki:** [https://github.com/oracle/docker-images/tree/main](https://github.com/oracle/docker-images/tree/main)
- **Lataus- tai CLI-komento:**
  ```bash
  git clone https://github.com/oracle/docker-images.git
  ```

