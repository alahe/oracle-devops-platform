#!/usr/bin/env python3
"""
Oracle DevOps Platform — Official Oracle Resources & Container Catalog (oracle_resources.py)
Curated Single Source of Truth for official Oracle product downloads, Oracle Container Registry (OCR)
images, technical documentation portals, community forums, and learning repositories across 6 languages (EN, ET, FI, SV, LV, LT).
Strictly contains official Oracle links and curated platform tools (no Wikipedia).
"""

import os
import re

RESOURCE_CATEGORIES = [
    {
        "id": "all",
        "labels": {
            "en": "All Resources",
            "et": "Kõik ressursid",
            "fi": "Kaikki resurssit",
            "sv": "Alla resurser",
            "lv": "Visi resursi",
            "lt": "Visi ištekliai"
        }
    },
    {
        "id": "containers",
        "labels": {
            "en": "Container Registry Images",
            "et": "Konteineritõmmised (OCR)",
            "fi": "Konttikuvalähteet (OCR)",
            "sv": "Containeravbildningar (OCR)",
            "lv": "Konteineru attēli (OCR)",
            "lt": "Konteinerių atvaizdai (OCR)"
        }
    },
    {
        "id": "downloads",
        "labels": {
            "en": "Official Product Downloads",
            "et": "Ametlikud allalaadimised",
            "fi": "Viralliset lataukset",
            "sv": "Officiella nedladdningar",
            "lv": "Oficiālās lejupielādes",
            "lt": "Oficialūs atsisiuntimai"
        }
    },
    {
        "id": "portals",
        "labels": {
            "en": "Documentation & Cloud Portals",
            "et": "Dokumentatsioon ja pilveportaalid",
            "fi": "Dokumentaatio ja pilviportaalit",
            "sv": "Dokumentation & molnportaler",
            "lv": "Dokumentācija un mākoņportāli",
            "lt": "Dokumentacija ir debesų portalai"
        }
    },
    {
        "id": "community",
        "labels": {
            "en": "Community, Forums & Events",
            "et": "Kogukond, foorumid ja üritused",
            "fi": "Yhteisö, foorumit ja tapahtumat",
            "sv": "Gemenskap, forum och evenemang",
            "lv": "Kopiena, forumi un pasākumi",
            "lt": "Bendruomenė, forumai ir renginiai"
        }
    },
    {
        "id": "learning",
        "labels": {
            "en": "Hands-on Labs & Repositories",
            "et": "Õppematerjalid ja koodihoidlad",
            "fi": "Oppiminen ja koodivarastot",
            "sv": "Laborationer och kodarkiv",
            "lv": "Mācības un koda krātuves",
            "lt": "Mokymai ir kodo saugyklos"
        }
    }
]

ORACLE_RESOURCES = [
    # --- CONTAINERS (OCR & Repositories) ---
    {
        "id": "ocr-db-free",
        "name": "Oracle Database 23ai Free",
        "category": "containers",
        "badge": "OCR Official",
        "url": "https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Ffree",
        "pull_cmd": "podman pull container-registry.oracle.com/database/free:latest",
        "desc": {
            "en": "Official Oracle 23ai Free database container image featuring AI Vector Search, JSON-Relational Duality, and PDB support.",
            "et": "Ametlik Oracle 23ai Free andmebaasi konteiner: tehisintellekti vektorotsing (Vector Search), JSON-relatsiooniline duaalsus ja PDB tugi.",
            "fi": "Virallinen Oracle 23ai Free -tietokantakontti: AI-vektorihaku, JSON-relaatiodualiteetti ja PDB-tuki.",
            "sv": "Officiell Oracle 23ai Free container med AI Vector Search, JSON-relational duality och PDB-stöd.",
            "lv": "Oficiālais Oracle 23ai Free datubāzes konteiners ar AI vektoru meklēšanu, JSON-relāciju dualitāti un PDB atbalstu.",
            "lt": "Oficialus Oracle 23ai Free duomenų bazės konteineris su AI vektorine paieška, JSON-reliacine dualybe ir PDB palaikymu."
        },
        "use_case": {
            "en": "Foundation database layer for local development, CI/CD pipelines, and automated test runners.",
            "et": "Alusbaas kohalikuks arenduseks, CI/CD torudeks ja automatiseeritud testideks.",
            "fi": "Perustietokanta paikalliseen kehitykseen, CI/CD-putkiin ja testaukseen.",
            "sv": "Grunddatabas för lokal utveckling, CI/CD-pipelines och testning.",
            "lv": "Bāzes datubāze vietējai izstrādei, CI/CD cauruļvadiem un testēšanai.",
            "lt": "Pagrindinė duomenų bazė vietiniam kūrimui, CI/CD konvejeriams ir testams."
        }
    },
    {
        "id": "ocr-ords",
        "name": "Oracle REST Data Services (ORDS)",
        "category": "containers",
        "badge": "OCR Official",
        "url": "https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Fords",
        "pull_cmd": "podman pull container-registry.oracle.com/database/ords:latest",
        "desc": {
            "en": "Prebuilt, certified standalone ORDS container delivering AutoREST APIs, APEX static resource routing, and OAuth2 security.",
            "et": "Eelvalmistatud sertifitseeritud ORDS konteiner: AutoREST API-d, APEX staatiliste failide teenindus ja OAuth2 turvalisus.",
            "fi": "Valmiiksi koottu ORDS-kontti: AutoREST-rajapinnat, APEX-staattiset tiedostot ja OAuth2-tietoturva.",
            "sv": "Certifierad ORDS-container: AutoREST-API:er, APEX-resurser och OAuth2-säkerhet.",
            "lv": "Sertificēts ORDS konteiners: AutoREST API, APEX resursu maršrutēšana un OAuth2 drošība.",
            "lt": "Sertifikuotas ORDS konteineris: AutoREST API, APEX failų maršrutizavimas ir OAuth2 saugumas."
        },
        "use_case": {
            "en": "Zero-footprint web application listener bridging HTTPS traffic to Pluggable Databases.",
            "et": "Kerge veebikuulaja, mis vahendab HTTPS liiklust PDB andmebaasidesse ilma litsentsikuluta.",
            "fi": "Resurssitehokas verkkokuuntelija HTTPS-liikenteen välittämiseen PDB-tietokantoihin.",
            "sv": "Webblyssnare som dirigerar HTTPS-trafik till PDB-databaser.",
            "lv": "Viegls tīmekļa klausītājs HTTPS trafika novirzīšanai uz PDB datubāzēm.",
            "lt": "Lengvasvaris žiniatinklio gavėjas, nukreipiantis HTTPS srautą į PDB duomenų bazes."
        }
    },
    {
        "id": "ocr-sqlcl",
        "name": "Oracle SQLcl CLI Container",
        "category": "containers",
        "badge": "OCR Official",
        "url": "https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Fsqlcl",
        "pull_cmd": "podman pull container-registry.oracle.com/database/sqlcl:latest",
        "desc": {
            "en": "Official ephemeral SQLcl container image providing Java 21 runtime, Liquibase schema orchestration, and APEXlang compiler.",
            "et": "Ametlik SQLcl efemeerne konteiner: Java 21 käitusaeg, Liquibase skeemihalduse tugi ja APEXlang kompilaator.",
            "fi": "Virallinen SQLcl-konttikuva: Java 21, Liquibase-skeemanhallinta ja APEXlang-kääntäjä.",
            "sv": "Officiell SQLcl-container med Java 21, Liquibase och APEXlang-kompilator.",
            "lv": "Oficiāls SQLcl konteiners ar Java 21, Liquibase un APEXlang kompilatoru.",
            "lt": "Oficialus SQLcl konteineris su Java 21, Liquibase ir APEXlang kompiliatoriumi."
        },
        "use_case": {
            "en": "Enables zero-local-install execution (Rule 4) in locked-down or zero-admin corporate workstations.",
            "et": "Võimaldab käitada SQLcl käske (Reegel 4) ilma kohalikku Javat või tööriistu paigaldamata piiratud õigustega arvutites.",
            "fi": "Mahdollistaa SQLcl-ajon ilman paikallista asennusta lukituilla yrityskoneilla.",
            "sv": "Möjliggör SQLcl-körning utan lokal installation på låsta företagsklienter.",
            "lv": "Nodrošina SQLcl izpildi bez lokālas instalācijas korporatīvajās darbstacijās.",
            "lt": "Suteikia galimybę vykdyti SQLcl be vietinio diegimo apribotose įmonės darbo vietose."
        }
    },
    {
        "id": "ocr-portal-root",
        "name": "Oracle Container Registry (OCR) Portal",
        "category": "containers",
        "badge": "OCR Portal",
        "url": "https://container-registry.oracle.com/",
        "pull_cmd": "podman login container-registry.oracle.com",
        "desc": {
            "en": "Central portal and registry catalog for certified, prebuilt Oracle container images with enterprise SLA.",
            "et": "Oracle ametlik keskne konteineriregister: sertifitseeritud ja turvakontrollitud ametlikud tõmmised koos litsentsitingimustega.",
            "fi": "Oraclen virallinen konttirekisteri sertifioiduille ja tietoturvatarkastetuille konteille.",
            "sv": "Oracles officiella containerregister för certifierade och säkerhetsgranskade behållare.",
            "lv": "Oracle oficiālais konteineru reģistrs ar sertificētiem un drošības pārbaudītiem attēliem.",
            "lt": "Oficialus Oracle konteinerių registras su sertifikuotais ir patikrintais atvaizdais."
        },
        "use_case": {
            "en": "Accepting terms of use (Standard Terms of Acceptance) and exploring official Oracle enterprise images.",
            "et": "Litsentsitingimuste aktsepteerimine ja ametlike Oracle konteinerite otsing ning autentimine.",
            "fi": "Käyttöehtojen hyväksyminen ja virallisten Oracle-konttien haku.",
            "sv": "Godkännande av licensvillkor och sökning av officiella behållare.",
            "lv": "Licences noteikumu pieņemšana un oficiālo konteineru meklēšana.",
            "lt": "Licencijos sąlygų patvirtinimas ir oficialių konteinerių paieška."
        }
    },
    {
        "id": "ocr-ol9-slim",
        "name": "Oracle Linux 9 Slim",
        "category": "containers",
        "badge": "OCR Base",
        "url": "https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:os%2Foraclelinux",
        "pull_cmd": "podman pull container-registry.oracle.com/os/oraclelinux:9-slim",
        "desc": {
            "en": "Minimal footprint enterprise Linux base image with enterprise security patches and glibc compatibility.",
            "et": "Minimaalse jalajäljega ettevõtte Linuxi baastõmmis turvapaikade ja ametliku glibc toega.",
            "fi": "Minimaalisen kokoinen yritys-Linux-peruskuva tietoturvapäivityksillä.",
            "sv": "Minimal enterprise Linux-basavbildning med säkerhetsuppdateringar.",
            "lv": "Minimāls uzņēmuma Linux bāzes attēls ar drošības ielāpiem.",
            "lt": "Minimalaus dydžio įmonės lygio Linux bazinis atvaizdas su saugumo pataisomis."
        },
        "use_case": {
            "en": "Base layer for custom application extensions and developer toolchains.",
            "et": "Baastõmmis kohalike erirakenduste ja arendustööriistade kompileerimiseks.",
            "fi": "Pohjakuva omille sovelluslaajennuksille ja kehitystyökaluille.",
            "sv": "Grund för anpassade applikationer och utvecklingsverktyg.",
            "lv": "Bāzes attēls pielāgotu aplikāciju veidošanai.",
            "lt": "Bazinė platforma individualiems konteineriams kurti."
        }
    },
    {
        "id": "repo-gvenzl-oci-oracle-free",
        "name": "Oracle Database Free FastStart Containers (gvenzl)",
        "category": "containers",
        "badge": "Docker Hub / GitHub",
        "url": "https://github.com/gvenzl/oci-oracle-free",
        "pull_cmd": "podman pull docker.io/gvenzl/oracle-free:23-full-faststart",
        "desc": {
            "en": "Popular Oracle Database Free container images by Gerald Venzl featuring instant FastStart boot (~10s) and multi-architecture AMD64/ARM64 support.",
            "et": "Gerald Venzli Oracle Database Free konteineripiltide koodihoidla: ülikiire FastStart käivitus (~10s) ja AMD64/ARM64 (Apple Silicon) tugi.",
            "fi": "Gerald Venzlin suosittu Oracle Database Free -konttikuvarepositorio FastStart-kuvilla ja AMD64/ARM64-tuella.",
            "sv": "Gerald Venzls containerarkiv för Oracle Database Free med FastStart-avbildningar och stöd för AMD64/ARM64.",
            "lv": "Džeralda Venzla Oracle Database Free konteineru krātuve ar FastStart attēliem un AMD64/ARM64 atbalstu.",
            "lt": "Gerald Venzl Oracle Database Free konteinerių saugykla su FastStart atvaizdais ir AMD64/ARM64 palaikymu."
        },
        "use_case": {
            "en": "High-speed developer workflows, Apple Silicon native testing, and FastStart pre-seeded databases.",
            "et": "Arenduse kiirendamine FastStart profiilidega ning optimeeritud käitamine Apple Silicon (M1/M2/M3/M4) masinates.",
            "fi": "Kehitystyön nopeuttaminen FastStart-kuvilla ja natiiviajo Apple Siliconilla.",
            "sv": "Snabba utvecklingsflöden och optimerad körning på Apple Silicon.",
            "lv": "Ātra izstrādes plūsma ar FastStart attēliem un darbs uz Apple Silicon.",
            "lt": "Spartus kūrimo procesas su FastStart atvaizdais ir vietinis darbas su Apple Silicon."
        }
    },
    {
        "id": "img-forms-14c",
        "name": "Oracle Forms & Reports 14c Container",
        "category": "containers",
        "badge": "Docker Hub",
        "url": "https://hub.docker.com/r/allanlahe/oracle-forms",
        "pull_cmd": "podman pull docker.io/allanlahe/oracle-forms:14.1.2",
        "desc": {
            "en": "Fully pre-configured Oracle Forms 14c container with WebLogic Server, HTML5 noVNC Forms Builder GUI, and compiler.",
            "et": "Eelseadistatud Oracle Forms 14c konteiner: WebLogic Server, HTML5 noVNC brauseripõhine Forms Builder ja fmx kompilaator.",
            "fi": "Valmiiksi konfiguroitu Oracle Forms 14c -kontti: WebLogic, noVNC Forms Builder ja kääntäjä.",
            "sv": "Förkonfigurerad Oracle Forms 14c container med WebLogic och noVNC Forms Builder GUI.",
            "lv": "Pilnībā sagatavots Oracle Forms 14c konteiners ar WebLogic un noVNC Forms Builder.",
            "lt": "Paruoštas Oracle Forms 14c konteineris su WebLogic ir noVNC Forms Builder sąsaja."
        },
        "use_case": {
            "en": "Blueprint 6 & 7: Modernization, headless compilation, and legacy migration to APEX.",
            "et": "Kavandid 6 & 7: Vana Forms-süsteemi kaasajastamine, fmx kompileerimine ja migratsioon APEX-isse.",
            "fi": "Blueprint 6 & 7: Forms-järjestelmien modernisointi ja siirto APEXiin.",
            "sv": "Blueprint 6 & 7: Modernisering och migrering från Forms till APEX.",
            "lv": "Blueprint 6 & 7: Forms sistēmu modernizācija un migrācija uz APEX.",
            "lt": "Blueprint 6 ir 7: Forms modernizavimas ir perkėlimas į APEX."
        }
    },
    {
        "id": "img-publisher",
        "name": "Oracle Analytics Publisher Container",
        "category": "containers",
        "badge": "Docker Hub",
        "url": "https://hub.docker.com/r/allanlahe/oracle-publisher",
        "pull_cmd": "podman pull docker.io/allanlahe/oracle-publisher:latest",
        "desc": {
            "en": "Enterprise pixel-perfect reporting engine container pre-patched with OPatch security updates and PDF generator.",
            "et": "Pixel-perfect aruandlusmootori konteiner: OPatch turvapaigad, PDF genereerimine ja REST API teenused.",
            "fi": "Yritystason pixel-perfect raportointikontti OPatch-päivityksillä ja PDF-moottorilla.",
            "sv": "Pixel-perfect rapportmotor i container med säkerhetspatchar och PDF-generering.",
            "lv": "Pārskatu dzinēja konteiners ar OPatch drošības ielāpiem un PDF ģenerēšanu.",
            "lt": "Verslo ataskaitų konteineris su OPatch saugumo pataisomis ir PDF generatoriumi."
        },
        "use_case": {
            "en": "Blueprint 4 & 5: High-volume document creation, invoice generation, and report deployment.",
            "et": "Kavandid 4 & 5: Suuremahuline arvete, dokumentide ja raportite automaatne genereerimine.",
            "fi": "Blueprint 4 & 5: Asiakirjojen ja laskujen automatisoitu luonti.",
            "sv": "Blueprint 4 & 5: Dokument- och fakturagenerering i stor skala.",
            "lv": "Blueprint 4 & 5: Automatizēta dokumentu un rēķinu izveide.",
            "lt": "Blueprint 4 ir 5: Masinis dokumentų ir sąskaitų generavimas."
        }
    },

    # --- OFFICIAL DOWNLOADS ---
    {
        "id": "dl-apex",
        "name": "Oracle APEX Downloads",
        "category": "downloads",
        "badge": "Official Download",
        "url": "https://www.oracle.com/tools/downloads/apex-downloads.html",
        "pull_cmd": "curl -LO https://download.oracle.com/otn_software/apex/apex-latest.zip",
        "desc": {
            "en": "Latest official distribution archive containing complete APEX application schemas, runtime engines, and static images.",
            "et": "Ametlik APEX jaotusarhiiv: andmebaasiskeemid, käitusmootor ja staatilised veebifailid.",
            "fi": "Uusin virallinen APEX-jakelupaketti tietokantamoottorille ja staattisille tiedostoille.",
            "sv": "Senaste officiella APEX-arkivet med scheman, körmotor och statiska resurser.",
            "lv": "Jaunākā oficiālā APEX pakotne ar shēmām, dzinēju un resursiem.",
            "lt": "Naujausias oficialus APEX paketas su schemomis, varikliu ir statiniais failais."
        },
        "use_case": {
            "en": "Automated in-container installation by install-apex.sh into Proxy DB without host unpacking.",
            "et": "Automaatne paigaldus andmebaasi skriptiga install-apex.sh ilma host-kettale lahtipakkimata (Reegel 4).",
            "fi": "Automaattinen asennus suoraan konttiin ilman purkamista isäntäkoneelle.",
            "sv": "Automatiserad installation direkt i containern utan uppackning på värddatorn.",
            "lv": "Automatizēta instalācija konteinerā bez atarhivēšanas resursdatorā.",
            "lt": "Automatizuotas diegimas tiesiai į konteinerį be išskleidimo pagrindiniame kompiuteryje."
        }
    },
    {
        "id": "dl-ords",
        "name": "Oracle REST Data Services (ORDS) Downloads",
        "category": "downloads",
        "badge": "Official Download",
        "url": "https://www.oracle.com/database/technologies/appdev/rest-data-services-downloads.html",
        "pull_cmd": "curl -LO https://download.oracle.com/otn_software/java/ords/ords-latest.zip",
        "desc": {
            "en": "Official standalone ORDS binaries for custom host configurations or embedded application setups.",
            "et": "Ametlik ORDS jaotuspakett eraldiseisvateks host-paigaldusteks või kohandatud lüüsiks.",
            "fi": "Viralliset ORDS-binaarit itsenäisiin asennuksiin ja rajapintojen hallintaan.",
            "sv": "Officiella ORDS-binärer för anpassade installationer.",
            "lv": "Oficiālās ORDS binārās pakotnes pielāgotām instalācijām.",
            "lt": "Oficialūs ORDS paketai individualiems diegimams."
        },
        "use_case": {
            "en": "Alternative host-native installation via install-ords-standalone.sh.",
            "et": "Alternatiivne lokaalne paigaldus skriptiga install-ords-standalone.sh.",
            "fi": "Vaihtoehtoinen paikallinen asennus skriptillä install-ords-standalone.sh.",
            "sv": "Alternativ lokal installation via install-ords-standalone.sh.",
            "lv": "Alternatīva lokālā uzstādīšana ar install-ords-standalone.sh.",
            "lt": "Alternatyvus vietinis diegimas per install-ords-standalone.sh."
        }
    },
    {
        "id": "dl-sqlcl",
        "name": "Oracle SQLcl Standalone Download",
        "category": "downloads",
        "badge": "Official Download",
        "url": "https://www.oracle.com/database/sqldev/technologies/sqlcl/download/",
        "pull_cmd": "curl -LO https://download.oracle.com/otn_software/java/sqldev/sqlcl-latest.zip",
        "desc": {
            "en": "Modern command-line interface for Oracle Database featuring inline auto-completion, Liquibase, and APEX export tools.",
            "et": "Kaasaegne Oracle andmebaasi käsurida: automaatne koodilõpetus, Liquibase integratsioon ja APEX koodieksport.",
            "fi": "Moderni Oracle-tietokannan komentorivityökalu automaattitäydennyksellä ja Liquibase-tuella.",
            "sv": "Modernt kommandoradsverktyg för Oracle Database med Liquibase och automatisk kodkomplettering.",
            "lv": "Mūsdienīgs komandrindas rīks Oracle datubāzei ar koda pabeigšanu un Liquibase.",
            "lt": "Modernus komandinės eilutės įrankis su kodo pildymu ir Liquibase integracija."
        },
        "use_case": {
            "en": "Standard command-line client for developer workstations across macOS, Linux, and Windows.",
            "et": "Arendaja igapäevane CLI tööriist andmebaasiga suhtlemiseks ja automatiseerimiseks.",
            "fi": "Kehittäjän päivittäinen CLI-työkalu tietokantayhteyksiin ja skripteihin.",
            "sv": "Utvecklarens primära CLI-verktyg för databaskörningar.",
            "lv": "Izstrādātāja ikdienas CLI rīks darbam ar datubāzi.",
            "lt": "Kūrėjo kasdienis komandinės eilutės įrankis darbui su duomenų baze."
        }
    },
    {
        "id": "dl-publisher",
        "name": "Oracle Analytics Publisher Software & Template Builder",
        "category": "downloads",
        "badge": "Official Download",
        "url": "https://www.oracle.com/middleware/technologies/analytics-publisher/downloads.html",
        "pull_cmd": "",
        "desc": {
            "en": "Official downloads page for Oracle Analytics Publisher Desktop Template Builder (Word/Excel add-in) and enterprise server binaries.",
            "et": "Oracle Analytics Publisher ametlik tarkvara ja töölaua mallikoostaja (Desktop Template Builder Wordile/Excelile) allalaadimine.",
            "fi": "Oracle Analytics Publisherin viralliset palvelinlataukset ja Desktop Template Builder -mallityökalu (Word/Excel).",
            "sv": "Officiella nedladdningar för Oracle Analytics Publisher och Desktop Template Builder för Word/Excel.",
            "lv": "Oficiālās lejupielādes Oracle Analytics Publisher serverim un Desktop Template Builder rīkam priekš Word/Excel.",
            "lt": "Oficialūs atsisiuntimai Oracle Analytics Publisher ir Desktop Template Builder įrankiui su Word/Excel palaikymu."
        },
        "use_case": {
            "en": "Installing MS Word Template Builder for designing pixel-perfect RTF/PDF report layouts.",
            "et": "Template Builderi paigaldamine MS Wordi sisse täppisvormindusega (pixel-perfect) RTF ja PDF aruannete kujundamiseks.",
            "fi": "Template Builderin asennus MS Wordiin pixel-perfect-raporttien suunnittelua varten.",
            "sv": "Installation av Template Builder för Word för design av pixel-perfect-rapporter.",
            "lv": "Template Builder uzstādīšana programmā MS Word pārskatu vizuālai veidošanai.",
            "lt": "Template Builder diegimas į MS Word tikslių ataskaitų maketavimui."
        }
    },
    {
        "id": "dl-instantclient",
        "name": "Oracle Instant Client (Basic & SDK)",
        "category": "downloads",
        "badge": "Official Download",
        "url": "https://www.oracle.com/database/technologies/instant-client/downloads.html",
        "pull_cmd": "# Select package for macOS (ARM64/x86), Linux, or Windows",
        "desc": {
            "en": "High-performance native client libraries required by Python (python-oracledb), Node.js, and C/C++ applications.",
            "et": "Jõulised natiivsed klienditeegid Pythoni (python-oracledb), Node.js ja C/C++ rakenduste ühendamiseks.",
            "fi": "Natiivikirjastot Python-, Node.js- ja C/C++-sovellusten tietokantayhteyksille.",
            "sv": "Klientbibliotek för Python, Node.js och C/C++-applikationer mot Oracle Database.",
            "lv": "Klienta bibliotēkas Python, Node.js un C/C++ lietotņu savienošanai ar Oracle.",
            "lt": "Kliento bibliotekos, skirtos Python, Node.js ir C/C++ programoms prijungti prie Oracle."
        },
        "use_case": {
            "en": "Direct native driver mode (Thick driver) and legacy client connectivity.",
            "et": "Thick-driver draiveri režiim ja laiendatud Oracle võrguprotokollide tugi.",
            "fi": "Thick driver -tila ja laajennetut verkko-ominaisuudet.",
            "sv": "Thick driver-läge och avancerade nätverksfunktioner.",
            "lv": "Thick-driver režīms un paplašināts tīkla protokolu atbalsts.",
            "lt": "Thick-driver režimas ir išplėstinis tinklo protokolų palaikymas."
        }
    },
    {
        "id": "dl-vscode-ext",
        "name": "Oracle SQL Developer for VS Code",
        "category": "downloads",
        "badge": "VS Code Marketplace",
        "url": "https://marketplace.visualstudio.com/items?itemName=Oracle.sql-developer",
        "pull_cmd": "code --install-extension Oracle.sql-developer",
        "desc": {
            "en": "Official Visual Studio Code extension providing SQL worksheet, object navigator, embedded SQLcl, and connection manager.",
            "et": "Ametlik VS Code laiendus: SQL tööleht, andmebaasiobjektide puu, integreeritud SQLcl ja ühenduste haldur.",
            "fi": "Virallinen VS Code -laajennus: SQL-työarkki, objektiselain, integroitu SQLcl ja yhteyksien hallinta.",
            "sv": "Officiellt VS Code-tillägg med SQL-editor, objektutforskare och inbyggd SQLcl.",
            "lv": "Oficiālais VS Code paplašinājums ar SQL redaktoru, objektu koku un iebūvētu SQLcl.",
            "lt": "Oficialus VS Code plėtinys su SQL rengykle, objektų naršykle ir integruotu SQLcl."
        },
        "use_case": {
            "en": "Integrated IDE environment configured automatically via register-connections.sh.",
            "et": "Graafiline arenduskeskkond, mille ühendused seadistatakse automaatselt skriptiga register-connections.sh.",
            "fi": "Graafinen kehitysympäristö, jonka yhteydet määritellään automaattisesti register-connections.sh-skriptillä.",
            "sv": "IDE-miljö som konfigureras automatiskt med register-connections.sh.",
            "lv": "IDE vide, kas tiek automātiski nokonfigurēta ar register-connections.sh.",
            "lt": "Integruota kūrimo aplinka, automatiškai sukonfigūruojama per register-connections.sh."
        }
    },

    # --- PORTALS & DOCUMENTATION ---
    {
        "id": "portal-db-free-overview",
        "name": "Oracle Database Free Home & Features",
        "category": "portals",
        "badge": "Product Overview",
        "url": "https://www.oracle.com/database/free/",
        "pull_cmd": "",
        "desc": {
            "en": "Official product landing page with complete technical specifications, hardware resource limits (2 CPU, 2 GB RAM, 12 GB user data), and FAQ.",
            "et": "Oracle Database Free ametlik tooteleht: tehniline ülevaade, riistvara piirmäärad (2 CPU tuuma, 2 GB RAM, 12 GB kasutajaandmeid) ja litsentsikord.",
            "fi": "Oracle Database Free -tuotesivu teknisine määrittelyineen (2 CPU, 2 GB RAM, 12 GB dataa) ja usein kysyttyine kysymyksineen.",
            "sv": "Officiell produktsida för Oracle Database Free med tekniska specifikationer och begränsningar (2 CPU, 2 GB RAM, 12 GB data).",
            "lv": "Oracle Database Free oficiālā produkta lapa ar tehniskajām specifikācijām un ierobežojumiem (2 CPU, 2 GB RAM, 12 GB dati).",
            "lt": "Oficialus Oracle Database Free puslapis su techninėmis specifikacijomis ir ribojimais (2 CPU, 2 GB RAM, 12 GB duomenų)."
        },
        "use_case": {
            "en": "Reviewing licensing rules, production usage allowances, and resource boundaries.",
            "et": "Litsentsireeglite, toodangukasutuse tingimuste ja ressursipiirangute kontrollimine.",
            "fi": "Lisenssiehtojen ja tuotantokäytön rajoitusten tarkistaminen.",
            "sv": "Granskning av licensregler och produktionsbegränsningar.",
            "lv": "Licences noteikumu un ražošanas ierobežojumu pārbaude.",
            "lt": "Licencijavimo taisyklių ir gamybinio naudojimo sąlygų peržiūra."
        }
    },
    {
        "id": "portal-apexlang-spec",
        "name": "Oracle APEX 26.1 APEXlang Specification",
        "category": "portals",
        "badge": "Language Spec",
        "url": "https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/?component=app",
        "pull_cmd": "",
        "desc": {
            "en": "Official language reference and grammar specification for Oracle APEXlang declarative application definition DSL (.apx).",
            "et": "Ametlik APEXlang keele- ja süntaksispetsifikatsioon Oracle APEX deklaratiivse rakenduskeele (.apx) koostamiseks.",
            "fi": "Virallinen APEXlang-kielimäärittely ja kielioppi deklaratiiviselle sovelluskielelle (.apx).",
            "sv": "Officiell APEXlang-språkspecifikation och grammatik för deklarativ applikationsdefinition (.apx).",
            "lv": "Oficiālā APEXlang valodas specifikācija un gramatika deklaratīvai lietotņu definēšanai (.apx).",
            "lt": "Oficiali APEXlang kalbos specifikacija ir gramatika deklaratyviam programų aprašymui (.apx)."
        },
        "use_case": {
            "en": "Grammar reference for APEXlang DSL generators, AI coding prompts, and declarative app compilation.",
            "et": "Süntaksi alus APEXlang DSL genereerimisel, tehisintellekti viipadega rakenduste loomisel ja koodikompileerimisel.",
            "fi": "Syntaksin viite APEXlang DSL -luontiin ja tekoälypohjaiseen koodaukseen.",
            "sv": "Syntaktisk referens för APEXlang DSL och AI-stödd kodning.",
            "lv": "Sintakses rokasgrāmata APEXlang DSL un AI koda ģenerēšanai.",
            "lt": "Sintaksės šaltinis APEXlang DSL ir AI kodo generavimui."
        }
    },
    {
        "id": "portal-arch-center-catalog",
        "name": "Oracle Architecture Center Technology Catalog",
        "category": "portals",
        "badge": "Architecture Center",
        "url": "https://apexadb.oracle.com/ords/r/tech/catalog/home",
        "pull_cmd": "",
        "desc": {
            "en": "Curated catalog of reference architectures, blueprints, deployment topologies, and enterprise solution playbooks.",
            "et": "Oracle ametlik arhitektuurikeskuse kataloog: etalonarhitektuurid, juhendkavandid (blueprints) ja paigalduse parimad praktikad.",
            "fi": "Oraclen arkkitehtuurikeskuksen luettelo: referenssiarkkitehtuurit, blueprintit ja yritysratkaisut.",
            "sv": "Katalog över referensarkitekturer, blueprints och företagsmönster från Oracle Architecture Center.",
            "lv": "Oracle arhitektūras centra katalogs: references arhitektūras, plāni un korporatīvie risinājumi.",
            "lt": "Oracle architektūros centro katalogas: etaloninės architektūros, planai ir įmonių sprendimai."
        },
        "use_case": {
            "en": "Architectural alignment for hybrid cloud, multi-database LIS topology, and zero-trust deployments.",
            "et": "Etalonarhitektuuride joondamine hübriidpilve, mitme andmebaasiga LIS süsteemi ja zero-trust turvamudelitega.",
            "fi": "Arkkitehtuurien vertailu ja linjaus hybridi- ja monikantaratkaisuihin.",
            "sv": "Arkitektonisk anpassning för hybridmoln och säkerhetsmodeller.",
            "lv": "Arhitektūras salīdzināšana hibrīdmākoņa un daudzslāņu sistēmām.",
            "lt": "Architektūrų suderinimas hibridinio debesies ir nulinio pasitikėjimo modeliams."
        }
    },
    {
        "id": "portal-forms-14c-docs",
        "name": "Oracle Forms 14c (14.1.2) Documentation",
        "category": "portals",
        "badge": "Technical Docs",
        "url": "https://docs.oracle.com/en/middleware/developer-tools/forms/14.1.2/index.html",
        "pull_cmd": "",
        "desc": {
            "en": "Complete documentation suite covering Oracle Forms 14c deployment, WebLogic configuration, and modern web integration.",
            "et": "Terviklik dokumentatsioon: Oracle Forms 14c paigaldus, WebLogic häälestus, headless kompileerimine ja brauseritugi.",
            "fi": "Täydellinen dokumentaatio Oracle Forms 14c:n asennukselle, WebLogic-määrityksille ja selainintegraatiolle.",
            "sv": "Fullständig dokumentation för Oracle Forms 14c med WebLogic och moderniseringsguider.",
            "lv": "Pilna dokumentācija Oracle Forms 14c uzstādīšanai, WebLogic konfigurēšanai un modernizācijai.",
            "lt": "Išsami dokumentacija Oracle Forms 14c diegimui, WebLogic konfigūravimui ir modernizavimui."
        },
        "use_case": {
            "en": "Reference documentation for Blueprint 6 & 7 (Forms container lifecycle, FMX compiler parameters, and APEX migration).",
            "et": "Alusdokumentatsioon kavanditele 6 ja 7 (Forms konteiner, fmx kompileerimine ja migratsioonitee APEX-isse).",
            "fi": "Ohjemateriaali Forms-konteille ja APEX-migraatiolle malleissa 6 ja 7.",
            "sv": "Referens för Blueprint 6 och 7 gällande Forms-konfigurering.",
            "lv": "Rokasgrāmata Blueprint 6 un 7 modeļiem un Forms migrācijai.",
            "lt": "Šaltinis Blueprint 6 ir 7 modeliams bei Forms perkėlimui į APEX."
        }
    },
    {
        "id": "portal-oas-docs",
        "name": "Oracle Analytics Server & Publisher Documentation",
        "category": "portals",
        "badge": "Technical Docs",
        "url": "https://docs.oracle.com/en/middleware/bi/analytics-server/index.html",
        "pull_cmd": "",
        "desc": {
            "en": "Official technical documentation library for Oracle Analytics Server (OAS), Publisher engine, XML data models, and REST APIs.",
            "et": "Oracle Analytics Server (OAS) ja Publisheri ametlik dokumentatsiooniraamatukogu: andmemudelid, XML skeemid ja REST API.",
            "fi": "Virallinen dokumentaatiokirjasto Oracle Analytics Serverille ja Publisher-raportointimoottorille.",
            "sv": "Teknisk dokumentation för Oracle Analytics Server och Publisher-motorn.",
            "lv": "Oficiālā tehniskā dokumentācija Oracle Analytics Server un Publisher dzinējam.",
            "lt": "Oficiali techninė dokumentacija, skirta Oracle Analytics Server ir Publisher varikliui."
        },
        "use_case": {
            "en": "Configuring Blueprint 4 & 5 (Catalog management, WebLogic EmbeddedLDAP security, and automated report scheduling).",
            "et": "Kavandite 4 ja 5 seadistamine (Publisheri kataloog, WebLogic turvalisus ja aruannete automaatne genereerimine).",
            "fi": "Raportointipalvelimen ja tietoturvan asetukset malleissa 4 ja 5.",
            "sv": "Konfiguration av Publisher och säkerhet för Blueprints 4 och 5.",
            "lv": "Konfigurācijas ceļvedis Blueprint 4 un 5 risinājumiem.",
            "lt": "Konfigūravimo gairės Blueprint 4 ir 5 sprendimams."
        }
    },
    {
        "id": "portal-ords-home",
        "name": "Oracle REST Data Services (ORDS) Product Center",
        "category": "portals",
        "badge": "Product Overview",
        "url": "https://www.oracle.com/database/technologies/appdev/rest.html",
        "pull_cmd": "",
        "desc": {
            "en": "Product overview, architecture blueprints, feature highlights, and enterprise REST enablement resources for Oracle Database.",
            "et": "ORDS ametlik tooteportaal: arhitektuursed põhimõtted, AutoREST omadused ja ettevõtte mikroteenuste integreerimine.",
            "fi": "ORDS-tuoteportaali: arkkitehtuurimallit, AutoREST-ominaisuudet ja mikropalveluintegraatiot.",
            "sv": "Officiellt produktcenter för ORDS med arkitekturmönster och mikrotjänstresurser.",
            "lv": "ORDS produkta centrs ar arhitektūras plāniem un AutoREST integrācijas iespējām.",
            "lt": "ORDS produktų centras su architektūros planais ir AutoREST galimybėmis."
        },
        "use_case": {
            "en": "Deep-dive into ORDS OAuth2 architecture, AutoREST capabilities, and secure API gateways.",
            "et": "Põhjalik ülevaade ORDS OAuth2 turvamudelist, AutoREST võimekusest ja API lüüsi arhitektuurist.",
            "fi": "Perehtyminen ORDS OAuth2 -tietoturvaan ja AutoREST-ominaisuuksiin.",
            "sv": "Fördjupning i ORDS OAuth2-säkerhetsmodellen och API-gateway.",
            "lv": "ORDS OAuth2 drošības modeļa un API vārtejas izpēte.",
            "lt": "ORDS OAuth2 saugumo modelio ir API šliuzo analizė."
        }
    },
    {
        "id": "portal-oci",
        "name": "Oracle Cloud Console (OCI)",
        "category": "portals",
        "badge": "Cloud Portal",
        "url": "https://cloud.oracle.com",
        "pull_cmd": "",
        "desc": {
            "en": "Web management console for Oracle Cloud Infrastructure, Autonomous Database (ADB), compartments, and API keys.",
            "et": "Oracle Cloud Infrastructure veebipõhine halduskonsool: Autonomous Database (ADB), virtuaalvõrgud ja API võtmed.",
            "fi": "Oracle Cloud Infrastructuren hallintaportaali Autonomous Databasen ja pilviresurssien hallintaan.",
            "sv": "Webbkonsol för Oracle Cloud Infrastructure, Autonomous Database och API-nycklar.",
            "lv": "Oracle Cloud Infrastructure pārvaldības konsole ar Autonomous Database un API atslēgām.",
            "lt": "Oracle Cloud Infrastructure valdymo pultas, skirtas Autonomous Database ir API raktams."
        },
        "use_case": {
            "en": "Target cloud environment for Blueprints 10 & 11 (Hybrid Cloud & Multi-Region).",
            "et": "Sihtkeskkond kavanditele 10 ja 11 (Hübriidpilv ja Autonomous Database).",
            "fi": "Kohdeympäristö malleille 10 ja 11 (Hybridi- ja monialuepilvi).",
            "sv": "Mål för Blueprints 10 och 11 (Hybridmoln och Autonomous Database).",
            "lv": "Mērķa mākoņvide Blueprint 10 un 11 arhitektūrām.",
            "lt": "Tikslinė debesų aplinka Blueprint 10 ir 11 architektūroms."
        }
    },
    {
        "id": "portal-livesql",
        "name": "Oracle Live SQL",
        "category": "portals",
        "badge": "Interactive Learning",
        "url": "https://livesql.oracle.com",
        "pull_cmd": "",
        "desc": {
            "en": "Free, browser-based interactive sandbox for testing SQL queries, 23ai features, schemas, and tutorials.",
            "et": "Tasuta brauseripõhine interaktiivne liivakast SQL päringute, 23ai võimaluste ja skeemide katsetamiseks.",
            "fi": "Ilmainen selaimessa toimiva hiekkalaatikko SQL-kyselyiden ja 23ai-ominaisuuksien testaamiseen.",
            "sv": "Kostnadsfri webbaserad sandlåda för att testa SQL-frågor och 23ai-funktioner.",
            "lv": "Bezmaksas interaktīva vide pārlūkā SQL vaicājumu un 23ai funkciju apguvei.",
            "lt": "Nemokama interaktyvi smėliadėžė naršyklėje SQL užklausoms ir 23ai galimybėms išbandyti."
        },
        "use_case": {
            "en": "Quick syntax validation and exploring Oracle 23ai Vector Search / JSON duality syntax.",
            "et": "Kiire süntaksi testimine ja 23ai uute võimaluste tundmaõppimine ilma kohaliku paigalduseta.",
            "fi": "Nopea syntaksin testaus ja 23ai-uutuuksien kokeilu.",
            "sv": "Snabb verifiering av syntax och 23ai-funktioner.",
            "lv": "Ātra sintakses pārbaude un iepazīšanās ar jaunajām 23ai funkcijām.",
            "lt": "Greitas sintaksės tikrinimas ir susipažinimas su 23ai naujovėmis."
        }
    },
    {
        "id": "portal-db23-docs",
        "name": "Oracle Database 23ai Official Documentation",
        "category": "portals",
        "badge": "Technical Docs",
        "url": "https://docs.oracle.com/en/database/oracle/oracle-database/23/",
        "pull_cmd": "",
        "desc": {
            "en": "Comprehensive technical documentation covering SQL language reference, PL/SQL, security, and administration.",
            "et": "Terviklik tehniline dokumentatsioon: SQL teatmik, PL/SQL paketid, turvakäsiraamat ja administreerimine.",
            "fi": "Kattava tekninen dokumentaatio: SQL- ja PL/SQL-oppaat, tietoturva ja ylläpito.",
            "sv": "Fullständig teknisk dokumentation: SQL, PL/SQL, säkerhet och administration.",
            "lv": "Pilna tehniskā dokumentācija: SQL, PL/SQL, drošība un administrēšana.",
            "lt": "Išsami techninė dokumentacija: SQL, PL/SQL, saugumas ir administravimas."
        },
        "use_case": {
            "en": "Definitive technical reference for all database features and syntax.",
            "et": "Ametlik tehniline tugimaterjal andmebaasifunktsioonide ja süntaksi kontrollimiseks.",
            "fi": "Virallinen lähdemateriaali tietokannan toiminnoille.",
            "sv": "Auktoritativ referens för alla databasfunktioner.",
            "lv": "Autoritatīvs avots datubāzes iespēju un sintakses izpētei.",
            "lt": "Oficialus techninis šaltinis duomenų bazės galimybėms nagrinėti."
        }
    },
    {
        "id": "portal-apex-docs",
        "name": "Oracle APEX Documentation & Tutorials",
        "category": "portals",
        "badge": "Technical Docs",
        "url": "https://docs.oracle.com/en/database/oracle/apex/",
        "pull_cmd": "",
        "desc": {
            "en": "Official documentation, API references, architecture guides, and enterprise application deployment tutorials.",
            "et": "Ametlik APEX dokumentatsioon, API teatmikud, arhitektuurijuhendid ja ettevõtterakenduste õppematerjalid.",
            "fi": "Virallinen APEX-dokumentaatio, rajapintakuvaukset ja yrityssovellusten oppaat.",
            "sv": "Officiell APEX-dokumentation, API-referenser och arkitekturguider.",
            "lv": "Oficiālā APEX dokumentācija, API rokasgrāmatas un arhitektūras ceļveži.",
            "lt": "Oficiali APEX dokumentacija, API žinynai ir architektūros gairės."
        },
        "use_case": {
            "en": "Essential guide for APEX component design, authentication schemes, and JavaScript APIs.",
            "et": "Põhjalik abimaterjal APEX komponentide, autentimise ja REST liideste loomisel.",
            "fi": "Keskeinen opas APEX-komponenttien ja autentikoinnin suunnitteluun.",
            "sv": "Guide för design av APEX-komponenter och autentisering.",
            "lv": "Būtiska rokasgrāmata APEX komponentu un autentifikācijas izstrādei.",
            "lt": "Pagrindinis vadovas kuriant APEX komponentus ir autentifikacijos schemas."
        }
    },

    # --- COMMUNITY, FORUMS & EVENTS ---
    {
        "id": "comm-apex-forum",
        "name": "Oracle APEX Community Forums",
        "category": "community",
        "badge": "Official Community",
        "url": "https://forums.oracle.com/ords/r/apexds/community/home",
        "pull_cmd": "",
        "desc": {
            "en": "Official worldwide Oracle APEX community discussion platform, Q&A, product announcements, and expert troubleshooting.",
            "et": "Oracle APEX ametlik globaalne arutelufoorum: küsimused-vastused, tooteuuendused ja kogukonna parimad praktikad.",
            "fi": "Virallinen Oracle APEX -yhteisöfoorumi kysymyksille, tuotejulkaisuille ja asiantuntijavastauksille.",
            "sv": "Officiellt Oracle APEX-forum för frågor, svar och produktnyheter.",
            "lv": "Oficiālais Oracle APEX kopienas forums jautājumiem, atbildēm un jaunumiem.",
            "lt": "Oficialus Oracle APEX bendruomenės forumas klausimams, atsakymams ir naujienoms."
        },
        "use_case": {
            "en": "Troubleshooting complex APEX issues, interactive grid tricks, and consulting Oracle product managers.",
            "et": "Keeruliste APEX probleemide lahendamine, interaktiivsete tabelite nipid ja otsesuhtlus Oracle tootejuhtidega.",
            "fi": "Monimutkaisten APEX-haasteiden ratkonta ja asiantuntijaneuvot.",
            "sv": "Felsökning av APEX-problem och rådgivning med produktrådgivare.",
            "lv": "APEX kļūdu novēršana un konsultācijas ar kopienas ekspertiem.",
            "lt": "APEX problemų sprendimas ir konsultacijos su ekspertais."
        }
    },
    {
        "id": "comm-analytics-community",
        "name": "Oracle Analytics & Publisher Community",
        "category": "community",
        "badge": "Official Community",
        "url": "https://community.oracle.com/products/oracleanalytics/",
        "pull_cmd": "",
        "desc": {
            "en": "Official community hub for Oracle Analytics Server, BI Publisher, Pixel Perfect reporting, and template design.",
            "et": "Oracle Analytics Server ja Publisher ametlik kogukonnaportaal: Pixel Perfect aruandlus, RTF/XSL mallide kujundus ja nõuanded.",
            "fi": "Oracle Analytics- ja Publisher-yhteisö: Pixel Perfect -raportointi, RTF-mallit ja asiantuntijaneuvonta.",
            "sv": "Oracle Analytics och Publisher-gemenskap med fokus på Pixel Perfect-rapportering och mallar.",
            "lv": "Oracle Analytics un Publisher kopiena: Pixel Perfect atskaites, veidnes un ekspertu atbalsts.",
            "lt": "Oracle Analytics ir Publisher bendruomenė: Pixel Perfect ataskaitos, šablonai ir palaikymas."
        },
        "use_case": {
            "en": "Sharing RTF templates, data model queries, and resolving Publisher formatting anomalies.",
            "et": "RTF mallide jagamine, andmemudelite päringute optimeerimine ja Publisheri veateadete lahendamine.",
            "fi": "Raportointimallien optimointi ja Publisher-ongelmien selvitys.",
            "sv": "Delning av rapportmallar och lösning av formateringsproblem.",
            "lv": "Pārskatu veidņu apmaiņa un formatēšanas problēmu risināšana.",
            "lt": "Ataskaitų šablonų dalijimasis ir problemų sprendimas."
        }
    },
    {
        "id": "comm-sqldev-vscode-forum",
        "name": "Oracle SQL Developer for VS Code Community",
        "category": "community",
        "badge": "Official Forum",
        "url": "https://forums.oracle.com/ords/apexds/domain/dev-community/category/sqldev-for-vscode",
        "pull_cmd": "",
        "desc": {
            "en": "Official feedback and support forum for the Oracle SQL Developer extension in Visual Studio Code.",
            "et": "Ametlik tagasiside- ja tugifoorum VS Code Oracle SQL Developer laienduse arendajatele ja kasutajatele.",
            "fi": "Virallinen tukifoorumi VS Code Oracle SQL Developer -laajennukselle.",
            "sv": "Officiellt diskussionsforum för Oracle SQL Developer-tillägget i VS Code.",
            "lv": "Oficiālais atbalsta forums VS Code Oracle SQL Developer paplašinājumam.",
            "lt": "Oficialus pagalbos forumas VS Code Oracle SQL Developer plėtiniui."
        },
        "use_case": {
            "en": "Reporting extension defects, submitting feature requests, and verifying DBTU connection behavior.",
            "et": "Laienduse vigadest teatamine, uute funktsioonide soovimine ja ühenduste tõrkeotsing.",
            "fi": "Laajennuksen kehitysehdotukset ja yhteysongelmien ratkaisu.",
            "sv": "Felrapportering och funktionsförfrågningar för VS Code-tillägget.",
            "lv": "Kļūdu ziņošana un savienojumu problēmu risināšana.",
            "lt": "Pranešimai apie klaidas ir naujų funkcijų siūlymai plėtiniui."
        }
    },
    {
        "id": "comm-apex-events",
        "name": "Oracle APEX Global Events & Office Hours",
        "category": "community",
        "badge": "Events & Webinars",
        "url": "https://oracleapex.com/ords/r/apex_pm/apex-events/events",
        "pull_cmd": "",
        "desc": {
            "en": "Live directory of upcoming APEX product office hours, developer meetups, technical webinars, and global user group conferences.",
            "et": "APEX ülemaailmsete ürituste kalender: regulaarsed tootejuhtide veebiseminarid (Office Hours), arendajate kohtumised ja konverentsid.",
            "fi": "APEX-tapahtumakalenteri: Office Hours -webinaarit, kehittäjätapaamiset ja konferenssit.",
            "sv": "Global kalender för APEX-evenemang, Office Hours och tekniska webbinarier.",
            "lv": "Globālais APEX pasākumu, Office Hours vebināru un konferenču kalendārs.",
            "lt": "Pasaulinis APEX renginių, Office Hours vebinarų ir konferencijų kalendorius."
        },
        "use_case": {
            "en": "Staying informed about release roadmaps, APEX 26 new features, and live demonstrations.",
            "et": "Uute versioonide teekaardi (APEX 26+), funktsioonide ja live-demonstratsioonide jälgimine.",
            "fi": "Tulevien versioiden ja APEX-tiekartan seuraaminen suorissa lähetyksissä.",
            "sv": "Uppföljning av färdplan och nya APEX-funktioner.",
            "lv": "Jauno APEX versiju un funkciju demonstrāciju vērošana tiešraidē.",
            "lt": "Naujų APEX versijų gairių ir demonstracijų stebėjimas."
        }
    },
    {
        "id": "comm-apex-blogs",
        "name": "APEX Blogs Aggregator (CloudNueva)",
        "category": "community",
        "badge": "Community Aggregator",
        "url": "https://apps.cloudnueva.com/ords/r/apps/apex_blogs/home",
        "pull_cmd": "",
        "desc": {
            "en": "Comprehensive community aggregator indexing thousands of technical articles and tutorials authored by global Oracle APEX experts.",
            "et": "Maailma suurim APEX tehniliste artiklite koondleht: indekseerib sadade ekspertide ja arendajate blogipostitusi ja koodinäiteid.",
            "fi": "Kattava yhteisöaggregaattori, joka kokoaa tuhansia APEX-asiantuntijoiden artikkeleita ja ohjeita.",
            "sv": "Gemenskapens bloggaggregator med tusentals tekniska artiklar och tips från APEX-experter.",
            "lv": "Kopienas emuāru apkopotājs ar tūkstošiem tehnisko rakstu un padomu par Oracle APEX.",
            "lt": "Bendruomenės tinklaraščių agregatorius su tūkstančiais techninių straipsnių ir patarimų apie APEX."
        },
        "use_case": {
            "en": "Discovering modern code snippets, CSS/JavaScript tricks, and real-world APEX solutions.",
            "et": "Kaasaegsete koodinäidete, CSS/JS kujunduslahenduste ja praktiliste arhitektuurivõtete leidmine.",
            "fi": "Koodiesimerkkien ja modernien APEX-ratkaisujen haku.",
            "sv": "Sökning efter praktiska kodexempel och CSS/JS-tips.",
            "lv": "Mūsdienīgu koda paraugu un dizaina risinājumu meklēšana.",
            "lt": "Šiuolaikinių kodo pavyzdžių ir praktinių sprendimų paieška."
        }
    },

    # --- LEARNING & OPEN SOURCE REPOSITORIES ---
    {
        "id": "learn-livelabs",
        "name": "Oracle LiveLabs Interactive Workshops",
        "category": "learning",
        "badge": "Hands-on Labs",
        "url": "https://apexapps.oracle.com/pls/apex/dbpm/r/livelabs/home",
        "pull_cmd": "",
        "desc": {
            "en": "Free step-by-step guided hands-on workshops for Oracle Database 23ai, Vector Search, APEX, CI/CD, and Cloud Architecture.",
            "et": "Oracle tasuta praktilised samm-sammult õppelaborid: 23ai tehisintellekt, Vector Search, APEX, CI/CD ja pilvearhitektuur.",
            "fi": "Ilmaiset ohjatut käytännön harjoituslaboratoriot Oracle 23ai:lle, APEXille ja pilviarkkitehtuureille.",
            "sv": "Kostnadsfria praktiska laborationer och workshops för Oracle Database 23ai, APEX och molnet.",
            "lv": "Bezmaksas praktiskās apmācību laboratorijas par Oracle 23ai, APEX un mākoņtehnoloģijām.",
            "lt": "Nemokamos praktinės mokymosi laboratorijos apie Oracle 23ai, APEX ir debesų architektūrą."
        },
        "use_case": {
            "en": "Self-paced hands-on training on 23ai features directly applicable to platform development.",
            "et": "Praktiline iseseisev väljaõpe 23ai uute võimaluste ja arhitektuuride omandamiseks.",
            "fi": "Käytännönläheinen oppiminen alustan teknologioiden hyödyntämiseen.",
            "sv": "Praktisk utbildning i moderna Oracle-teknologier.",
            "lv": "Praktiska apmācība platformas tehnoloģiju apguvei.",
            "lt": "Praktiniai mokymai platformos galimybėms perprasti."
        }
    },
    {
        "id": "learn-oracle-university",
        "name": "Oracle MyLearn Digital Learning",
        "category": "learning",
        "badge": "Oracle University",
        "url": "https://mylearn.oracle.com/ou/home",
        "pull_cmd": "",
        "desc": {
            "en": "Official Oracle University digital learning platform offering certified courses, role-based learning paths, and exams.",
            "et": "Oracle University ametlik digiõppe platvorm: sertifitseeritud e-kursused, rollipõhised õppeteed ja sertifitseerimiseksamid.",
            "fi": "Oracle Universityn digitaalinen oppimisalusta sertifioiduilla kursseilla ja oppimispoluilla.",
            "sv": "Oracle Universitys digitala utbildningsplattform med certifierade kurser och examina.",
            "lv": "Oracle University digitālā mācību platforma ar sertificētiem kursiem un eksāmeniem.",
            "lt": "Oracle University skaitmeninė mokymosi platforma su sertifikuotais kursais ir egzaminais."
        },
        "use_case": {
            "en": "Professional certifications for Oracle Database Administrator (DBA) and APEX Developer.",
            "et": "Oracle andmebaasiadministraatori (DBA) ja APEX arendaja ametlikud pädevuskoolitused ja sertifikaadid.",
            "fi": "Ammatilliset sertifioinnit DBA- ja APEX-osaajille.",
            "sv": "Professionella certifieringar för DBA och APEX-utvecklare.",
            "lv": "Profesionālā sertifikācija datubāzu administratoriem un izstrādātājiem.",
            "lt": "Profesiniai DBA ir APEX kūrėjų sertifikatai."
        }
    },
    {
        "id": "learn-asktom-security",
        "name": "AskTOM Oracle Database Security Repository",
        "category": "learning",
        "badge": "Security & Hardening",
        "url": "https://github.com/oradbsec/AskTomDBSecurity",
        "pull_cmd": "git clone https://github.com/oradbsec/AskTomDBSecurity.git",
        "desc": {
            "en": "Curated scripts, demonstrations, and test suites maintained by Oracle's Database Security product management team.",
            "et": "Oracle ametliku andmebaasiturbe tiimi haldatav koodihoidla: turvaskriptid, TDE krüpteerimine, Unified Auditing ja privileegide audit.",
            "fi": "Oracle-tietoturvatiimin ylläpitämä koodivarasto: TDE-salaus, auditointi ja oikeuksien tarkistus.",
            "sv": "Oracle-säkerhetsteamets kodarkiv med skript för TDE, granskning och härdning.",
            "lv": "Oracle drošības komandas krātuve ar skriptiem TDE šifrēšanai, auditam un stiprināšanai.",
            "lt": "Oracle saugumo komandos saugykla su scenarijais TDE šifravimui, auditui ir stiprinimui."
        },
        "use_case": {
            "en": "Enterprise database hardening, Zero-Trust compliance, and security policy automation.",
            "et": "Andmebaasi turvataseme tõstmine (Hardening), Zero-Trust nõuete täitmine ja auditilogide seadistamine.",
            "fi": "Tietokannan kovennus ja Zero-Trust-tietoturvamallien käyttöönotto.",
            "sv": "Härdning av databas och implementering av Zero-Trust.",
            "lv": "Datubāzes drošības paaugstināšana un Zero-Trust ieviešana.",
            "lt": "Duomenų bazės stiprinimas ir nulinio pasitikėjimo reikalavimų vykdymas."
        }
    },
    {
        "id": "learn-oracle-skills",
        "name": "Oracle AI Skills & Agentic Templates",
        "category": "learning",
        "badge": "Agentic AI Skills",
        "url": "https://github.com/oracle/skills/",
        "pull_cmd": "git clone https://github.com/oracle/skills.git",
        "desc": {
            "en": "Open-source repository of Oracle digital assistant skills, agentic AI workflows, and conversational database integration tools.",
            "et": "Oracle digitaalsete assistentide ja agentse tehisintellekti oskuste koodihoidla: vestluslikud andmebaasiliidesed ja töövoomallid.",
            "fi": "Oracle-tekoälytaitojen ja digitaalisten assistenttien avoimen koodin repositorio.",
            "sv": "Oracles öppna kodarkiv för AI-färdigheter och digitala assistenter.",
            "lv": "Oracle atvērtā koda krātuve AI prasmēm un digitālajiem asistentiem.",
            "lt": "Oracle atviro kodo saugykla AI įgūdžiams ir skaitmeniniams asistentams."
        },
        "use_case": {
            "en": "Integrating intelligent natural language database queries with APEX applications.",
            "et": "Loomuliku keele tehisintellekti päringute integreerimine APEX rakendustesse ja andmebaasi.",
            "fi": "Tekoälypohjaisten kyselyjen liittäminen APEX-sovelluksiin.",
            "sv": "Integrering av AI-frågor i APEX-applikationer.",
            "lv": "Dabiskās valodas vaicājumu integrēšana APEX lietotnēs.",
            "lt": "Natūralios kalbos užklausų integravimas į APEX programas."
        }
    },
    {
        "id": "learn-oracle-apex-github",
        "name": "Oracle APEX Open Source Hub",
        "category": "learning",
        "badge": "Open Source Hub",
        "url": "https://oracle.github.io/apex/",
        "pull_cmd": "",
        "desc": {
            "en": "Curated showcase of official open-source plug-ins, developer extensions, UI templates, and starter projects by Oracle.",
            "et": "Oracle APEX ametlik avatud lähtekoodiga pistikprogrammide (plug-ins), laienduste ja kujundusmallide keskus.",
            "fi": "Oraclen virallinen avoimen lähdekoodin lisäosien, mallien ja laajennusten keskus APEXille.",
            "sv": "Oracles officiella portal för öppna insticksprogram, mallar och tillägg för APEX.",
            "lv": "Oficiālā Oracle atvērtā koda spraudņu un veidņu vietne APEX izstrādātājiem.",
            "lt": "Oficiali Oracle atviro kodo įskiepių ir šablonų svetainė APEX kūrėjams."
        },
        "use_case": {
            "en": "Adding certified interactive plug-ins, custom item types, and responsive dynamic actions to applications.",
            "et": "Sertifitseeritud pistikprogrammide, dünaamiliste tegevuste ja erielementide lisamine APEX rakendustesse.",
            "fi": "Sertifioitujen lisäosien ja dynaamisten toimintojen lisääminen sovelluksiin.",
            "sv": "Installation av certifierade insticksprogram i APEX.",
            "lv": "Pārbaudītu spraudņu un dinamisko darbību pievienošana lietotnēm.",
            "lt": "Patikrintų įskiepių ir dinaminių veiksmų diegimas į programas."
        }
    },
    {
        "id": "repo-oracle-docker-images",
        "name": "Official Oracle Container Images Source Repository",
        "category": "learning",
        "badge": "Official GitHub",
        "url": "https://github.com/oracle/docker-images/tree/main",
        "pull_cmd": "git clone https://github.com/oracle/docker-images.git",
        "desc": {
            "en": "Official repository with Dockerfiles and build scripts for Oracle commercial and open-source software (Database, WebLogic, Forms, FMW, Java, Linux).",
            "et": "Oracle ametlik repositoorium Dockerfile'ide ja ehitusskriptidega: Oracle Database, WebLogic Server, Forms, FMW, Java ja Oracle Linux.",
            "fi": "Virallinen Oracle-repositorio, joka sisältää Dockerfilet ja skriptit Oracle-ohjelmistoille (Database, WebLogic, Forms, Java).",
            "sv": "Officiellt Oracle-arkiv med Dockerfiler och byggskript för Oracle-programvara (Database, WebLogic, Forms, Java).",
            "lv": "Oficiālā Oracle krātuve ar Dockerfile un būvēšanas skriptiem Oracle programmatūrai (Database, WebLogic, Forms, Java).",
            "lt": "Oficiali Oracle saugykla su Dockerfile ir kompiliavimo scenarijais Oracle programinei įrangai (Database, WebLogic, Forms, Java)."
        },
        "use_case": {
            "en": "Reference recipes and build scripts for building custom base containers and WebLogic domains.",
            "et": "Alusretseptid ja ehitusskriptid kohandatud baaskonteinerite ja WebLogic domeenide loomiseks.",
            "fi": "Referenssiohjeet ja skriptit räätälöityjen peruskonttien ja WebLogic-ympäristöjen luomiseen.",
            "sv": "Referensrecept för att bygga anpassade behållare och WebLogic-domäner.",
            "lv": "Bāzes receptes pielāgotu konteineru un WebLogic domēnu būvēšanai.",
            "lt": "Pavyzdiniai šablonai individualiems konteineriams ir WebLogic domenams kurti."
        }
    }
]

def get_oracle_resources_catalog():
    """Returns the full list of official Oracle resources."""
    return ORACLE_RESOURCES

def get_oracle_resource_categories():
    """Returns the categories list."""
    return RESOURCE_CATEGORIES

def generate_markdown_resources(ws, lang="en"):
    """Generates a complete markdown resources document for a specific language."""
    titles = {
        "en": "Official Oracle Resources & Container Images",
        "et": "Ametlikud Oracle Ressursid ja Konteineritõmmised",
        "fi": "Viralliset Oracle-resurssit ja Konttikuvat",
        "sv": "Officiella Oracle-resurser och Containeravbildningar",
        "lv": "Oficiālie Oracle Resursi un Konteineru Attēli",
        "lt": "Oficialūs Oracle Ištekliai ir Konteinerių Atvaizdai"
    }
    subtitles = {
        "en": "Curated index of official Oracle Container Registry (OCR) images, product downloads, documentation portals, community forums, and learning repositories.",
        "et": "Ametlike Oracle Container Registry (OCR) tõmmiste, toodete allalaadimiste, dokumentatsiooniportaalide, kogukonnafoorumite ja õppelaborite koondregister.",
        "fi": "Kokoelma virallisia Oracle Container Registry (OCR) -kuvia, latauslinkkejä, dokumentaatioportaaleja, yhteisöfoorumeita ja oppimisrepositorioita.",
        "sv": "Samlad katalog över officiella Oracle Container Registry (OCR) avbildningar, nedladdningar, dokumentationsportaler, forum och laborationer.",
        "lv": "Apkopots oficiālo Oracle Container Registry (OCR) attēlu, lejupielāžu, dokumentācijas portālu, kopienas forumu un mācību krātuvju saraksts.",
        "lt": "Oficialių Oracle Container Registry (OCR) atvaizdų, atsisiuntimų, dokumentacijos portalų, bendruomenės forumų ir mokymosi saugyklų katalogas."
    }

    switcher = "[ 🇬🇧 English ](file://" + os.path.join(ws, "docs/oracle-resources-and-downloads.md") + ") | " \
               "[ 🇪🇪 Eesti ](file://" + os.path.join(ws, "docs/et/oracle-resources-and-downloads.md") + ") | " \
               "[ 🇫🇮 Suomi ](file://" + os.path.join(ws, "docs/fi/oracle-resources-and-downloads.md") + ") | " \
               "[ 🇸🇪 Svenska ](file://" + os.path.join(ws, "docs/sv/oracle-resources-and-downloads.md") + ") | " \
               "[ 🇱🇻 Latviešu ](file://" + os.path.join(ws, "docs/lv/oracle-resources-and-downloads.md") + ") | " \
               "[ 🇱🇹 Lietuvių ](file://" + os.path.join(ws, "docs/lt/oracle-resources-and-downloads.md") + ")"

    lbl_desc = {"en": "Description", "et": "Kirjeldus", "fi": "Kuvaus", "sv": "Beskrivning", "lv": "Apraksts", "lt": "Aprašymas"}[lang]
    lbl_use = {"en": "Project Role", "et": "Roll platvormil", "fi": "Rooli alustalla", "sv": "Roll i plattformen", "lv": "Loma platformā", "lt": "Vaidmuo platformoje"}[lang]
    lbl_link = {"en": "Official Link", "et": "Ametlik link", "fi": "Virallinen linkki", "sv": "Officiell länk", "lv": "Oficiālā saite", "lt": "Oficiali nuoroda"}[lang]
    lbl_cmd = {"en": "Download / CLI Command", "et": "Allalaadimise / CLI käsk", "fi": "Lataus- tai CLI-komento", "sv": "Nedladdnings- / CLI-kommando", "lv": "Lejupielādes / CLI komanda", "lt": "Atsisiuntimo / CLI komanda"}[lang]

    lines = [
        f"# {titles.get(lang, titles['en'])}",
        "",
        switcher,
        "",
        f"> {subtitles.get(lang, subtitles['en'])}",
        "",
        "---",
        ""
    ]

    # Jumps
    cat_jumps = []
    for cat in RESOURCE_CATEGORIES:
        if cat["id"] == "all":
            continue
        c_label = cat["labels"].get(lang, cat["labels"]["en"])
        cat_jumps.append(f"[{c_label}](#{cat['id']})")
    lines.append(f"**Jump to section:** {' • '.join(cat_jumps)}")
    lines.append("")
    lines.append("---")
    lines.append("")

    for cat in RESOURCE_CATEGORIES:
        if cat["id"] == "all":
            continue
        c_label = cat["labels"].get(lang, cat["labels"]["en"])
        items = [i for i in ORACLE_RESOURCES if i["category"] == cat["id"]]
        if not items:
            continue
        cat_id = cat["id"]
        lines.append(f'<a id="{cat_id}"></a>')
        lines.append(f"## {c_label}")
        lines.append("")

        for item in items:
            d_text = item["desc"].get(lang, item["desc"]["en"])
            u_text = item["use_case"].get(lang, item["use_case"]["en"])
            lines.append(f"### {item['name']} `[{item['badge']}]`")
            lines.append(f"- **{lbl_desc}:** {d_text}")
            lines.append(f"- **{lbl_use}:** {u_text}")
            lines.append(f"- **{lbl_link}:** [{item['url']}]({item['url']})")
            if item.get("pull_cmd"):
                lines.append(f"- **{lbl_cmd}:**")
                lines.append("  ```bash")
                lines.append(f"  {item['pull_cmd']}")
                lines.append("  ```")
            lines.append("")

    return "\n".join(lines) + "\n"

def write_all_markdown_resources(ws):
    """Writes docs/oracle-resources-and-downloads.md and localized mirrors."""
    paths = {
        "en": os.path.join(ws, "docs", "oracle-resources-and-downloads.md"),
        "et": os.path.join(ws, "docs", "et", "oracle-resources-and-downloads.md"),
        "fi": os.path.join(ws, "docs", "fi", "oracle-resources-and-downloads.md"),
        "sv": os.path.join(ws, "docs", "sv", "oracle-resources-and-downloads.md"),
        "lv": os.path.join(ws, "docs", "lv", "oracle-resources-and-downloads.md"),
        "lt": os.path.join(ws, "docs", "lt", "oracle-resources-and-downloads.md")
    }

    for lang, p in paths.items():
        os.makedirs(os.path.dirname(p), exist_ok=True)
        content = generate_markdown_resources(ws, lang)
        with open(p, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"✅ Generated Oracle Resources markdown: {p}")

if __name__ == "__main__":
    ws = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.."))
    write_all_markdown_resources(ws)
