#!/usr/bin/env python3
"""
Oracle DevOps Platform — Central Glossary & Acronyms Catalog (glossary.py)
Provides comprehensive 4-part explanations for all acronyms used in documentation,
presentation slides, scripts, and Dev Hub across 6 languages (EN, ET, FI, SV, LV, LT).
"""

import os
import re

# 50+ canonical acronyms across the Oracle Free DB in Prod ecosystem
GLOSSARY_ITEMS = [
    {
        "acronym": "ADB",
        "expansion": "Autonomous Database",
        "category": "cloud",
        "ref_url": "https://www.oracle.com/autonomous-database/",
        "ref_title": "Oracle Autonomous Database",
        "def": {
            "en": "Oracle's fully managed cloud database service that automates provisioning, patching, tuning, and scaling using AI/ML.",
            "et": "Oracle täishallatud pilveandmebaasi teenus, mis automatiseerib paigalduse, turvapaigad, häälestuse ja skaleerimise.",
            "fi": "Oraclen täysin hallinnoitu pilvitietokanta, joka automatisoi ylläpidon, päivitykset ja skaalauksen.",
            "sv": "Oracles helhanterade molndatabas som automatiserar provisionering, patchning och skalning.",
            "lv": "Oracle pilnībā pārvaldīts mākoņa datubāzes pakalpojums ar automatizētu uzturēšanu un mērogošanu.",
            "lt": "Visiškai valdoma Oracle debesų duomenų bazė su automatizuotu atnaujinimu ir mastelio keitimu."
        },
        "project_role": {
            "en": "Target cloud environment for hybrid migrations (BP 10 & 11) via mTLS wallet connections without redesigning local code.",
            "et": "Hübriidse pilvemigratsiooni sihtkeskkond (BP 10 & 11) mTLS walleti kaudu ilma kohalikku koodi ümber kirjutamata.",
            "fi": "Hybridi-pilvimigraation kohde (BP 10 & 11) mTLS-lompakkoyhteydellä ilman paikallisen koodin muuttamista.",
            "sv": "Mål för hybridmolnmigrering (BP 10 & 11) via mTLS-wallet utan att skriva om lokal kod.",
            "lv": "Hibrīda mākoņa migrācijas mērķis (BP 10 & 11) ar mTLS maku bez vietējā koda maiņas.",
            "lt": "Hibridinės debesų migracijos tikslas (BP 10 ir 11) per mTLS piniginę nekeičiant vietinio kodo."
        },
        "links": [
            {"label": "docs/remote-multicloud-setup-guide.md", "url": "docs/remote-multicloud-setup-guide.md"},
            {"label": "scripts/deploy-remote.sh", "url": "scripts/deploy-remote.sh"}
        ]
    },
    {
        "acronym": "APEX",
        "expansion": "Oracle Application Express",
        "category": "app",
        "ref_url": "https://en.wikipedia.org/wiki/Oracle_APEX",
        "ref_title": "Wikipedia: Oracle APEX",
        "def": {
            "en": "Oracle's low-code enterprise web application development platform running directly inside the database.",
            "et": "Oracle madala koodivajadusega (low-code) veebirakenduste arendusplatvorm, mis töötab otse andmebaasi sees.",
            "fi": "Oraclen low-code-sovelluskehitysalusta yrityssovelluksille suoraan tietokannan sisällä.",
            "sv": "Oracles low-code utvecklingsplattform för webbapplikationer som körs direkt i databasen.",
            "lv": "Oracle low-code tīmekļa lietojumprogrammu izstrādes platforma tieši datubāzē.",
            "lt": "Oracle mažo kodo (low-code) žiniatinklio programų kūrimo platforma duomenų bazėje."
        },
        "project_role": {
            "en": "Central UI runtime hosted in Proxy DB (port 8448/8088), automated via APEXlang DSL and split SQLcl Git exports.",
            "et": "Peamine veebiliides Proxy andmebaasis (port 8448/8088), mida juhitakse APEXlang DSL-i ja Git-põhiste SQLcl eksportidega.",
            "fi": "Keskeinen käyttöliittymä Proxy DB:ssä (portti 8448/8088), ohjataan APEXlang DSL:llä ja Git-vienneillä.",
            "sv": "Centralt användargränssnitt i Proxy DB (port 8448/8088), automatiserat via APEXlang DSL och Git-exporter.",
            "lv": "Galvenā saskarne Proxy DB (ports 8448/8088), pārvaldīta ar APEXlang DSL un Git eksportiem.",
            "lt": "Pagrindinė sąsaja Proxy DB (prievadas 8448/8088), valdoma per APEXlang DSL ir Git eksportą."
        },
        "links": [
            {"label": "docs/apex-devhub-test-plan.md", "url": "docs/apex-devhub-test-plan.md"},
            {"label": "scripts/internal/install-apex.sh", "url": "scripts/internal/install-apex.sh"}
        ]
    },
    {
        "acronym": "APFS",
        "expansion": "Apple File System",
        "category": "os",
        "ref_url": "https://en.wikipedia.org/wiki/Apple_File_System",
        "ref_title": "Wikipedia: Apple File System",
        "def": {
            "en": "Default copy-on-write filesystem for macOS optimized for SSD storage, encryption, and snapshots.",
            "et": "macOS vaikefailisüsteem, optimeeritud SSD-ketastele, krüpteeringule ja tõmmistele (snapshots).",
            "fi": "macOS-käyttöjärjestelmän moderni tiedostojärjestelmä SSD-levyille ja pikavedoksille.",
            "sv": "Standardfilsystem för macOS optimerat för SSD-lagring, kryptering och snapshots.",
            "lv": "Noklusējuma failu sistēma macOS ar SSD optimizāciju un momentuzņēmumiem.",
            "lt": "Numatytoji macOS failų sistema, optimizuota SSD kaupikliams ir momentinėms kopijoms."
        },
        "project_role": {
            "en": "Host filesystem on macOS developer machines where case-preserving portability (Rule 13) is verified against NTFS.",
            "et": "macOS arendusmasina host-failisüsteem, kus tagatakse tõstutundlikkuse porditavus (Reegel 13) Windows NTFS-iga.",
            "fi": "macOS-kehitysympäristön tiedostojärjestelmä, jossa varmistetaan siirrettävyys (Sääntö 13) Windows NTFS:ään.",
            "sv": "macOS utvecklingsfilsystem där portabilitet (Regel 13) verifieras mot Windows NTFS.",
            "lv": "macOS failu sistēma, kur tiek pārbaudīta savietojamība (Noteikums 13) ar Windows NTFS.",
            "lt": "macOS failų sistema, kurioje tikrinamas suderinamumas (13 taisyklė) su Windows NTFS."
        },
        "links": [
            {"label": "tests/unit/test-filename-portability.sh", "url": "tests/unit/test-filename-portability.sh"}
        ]
    },
    {
        "acronym": "API",
        "expansion": "Application Programming Interface",
        "category": "web",
        "ref_url": "https://en.wikipedia.org/wiki/API",
        "ref_title": "Wikipedia: API",
        "def": {
            "en": "A structured set of protocols and routines for building software and enabling systems to communicate.",
            "et": "Struktureeritud protokollide ja funktsioonide kogum süsteemide omavaheliseks programmseks suhtluseks.",
            "fi": "Määritelty rajapinta ohjelmistojen ja järjestelmien väliseen viestintään.",
            "sv": "Strukturerat gränssnitt för programmatisk kommunikation mellan mjukvarusystem.",
            "lv": "Protokolu kopa programmatūras komponentu savstarpējai saziņai.",
            "lt": "Sąsaja, leidžianti skirtingoms programinėms sistemoms keistis duomenimis."
        },
        "project_role": {
            "en": "Exposed locally via ORDS (AutoREST, OAuth2) and Dev Hub Bridge (/api/status, /api/podman, /api/tests) on port 8089.",
            "et": "Ekponeeritud lokaalselt ORDS-i (AutoREST) ja Dev Hub Silla kaudu (/api/status, /api/podman, /api/tests) pordil 8089.",
            "fi": "Käytössä paikallisesti ORDS-palvelun ja Dev Hub Bridgen (/api/status jne.) kautta portissa 8089.",
            "sv": "Tillgängligt lokalt via ORDS och Dev Hub Bridge (/api/status, /api/podman) på port 8089.",
            "lv": "Pieejams lokāli caur ORDS un Dev Hub Bridge (/api/status, /api/tests) portā 8089.",
            "lt": "Pasiekiamas lokaliai per ORDS ir Dev Hub Bridge (/api/status, /api/tests) prievade 8089."
        },
        "links": [
            {"label": "docs/testing-framework-and-devhub.md", "url": "docs/testing-framework-and-devhub.md"},
            {"label": "scripts/internal/dev-hub-bridge.py", "url": "scripts/internal/dev-hub-bridge.py"}
        ]
    },
    {
        "acronym": "BIP",
        "expansion": "Business Intelligence Publisher (Analytics Publisher)",
        "category": "reporting",
        "ref_url": "https://docs.oracle.com/middleware/12213/bip/",
        "ref_title": "Oracle Analytics Publisher Docs",
        "def": {
            "en": "Enterprise document generation engine delivering pixel-perfect PDF, Excel, RTF, and XML reports at high volume.",
            "et": "Ettevõtte tasemel aruandlusmootor pikselintarkade PDF, Excel, RTF ja XML trükivormide suuremahuliseks genereerimiseks.",
            "fi": "Yritystason raportointimoottori pikselintarkkojen PDF-, Excel- ja XML-tulosteiden tuottamiseen.",
            "sv": "Rapportmotor på företagsnivå för pixel-perfect PDF, Excel och XML-rapporter i hög volym.",
            "lv": "Uzņēmuma līmeņa pārskatu ģenerators augstas kvalitātes PDF, Excel un XML dokumentiem.",
            "lt": "Įmonės lygio ataskaitų variklis tiksliems PDF, Excel ir XML dokumentams kurti."
        },
        "project_role": {
            "en": "Integrated in BP 4 & 11 (ports 9502/6083) for automated print templates and headless document generation.",
            "et": "Integreeritud blueprintides BP 4 ja BP 11 (pordid 9502/6083) automatiseeritud trükimallide ja PDF-ide loomiseks.",
            "fi": "Integroitu malleissa BP 4 & 11 (portit 9502/6083) automatisoituun raporttien tulostukseen.",
            "sv": "Integrerat i BP 4 & 11 (portar 9502/6083) för mallbaserad dokumentgenerering.",
            "lv": "Integrēts BP 4 un 11 (porti 9502/6083) automatizētai atskaišu ģenerēšanai.",
            "lt": "Integruota BP 4 ir 11 (prievadai 9502/6083) automatizuotam dokumentų generavimui."
        },
        "links": [
            {"label": "docs/publisher-setup.md", "url": "docs/publisher-setup.md"},
            {"label": "scripts/publisher/restart-publisher.sh", "url": "scripts/publisher/restart-publisher.sh"}
        ]
    },
    {
        "acronym": "BP",
        "expansion": "Blueprint (Architecture Blueprint)",
        "category": "arch",
        "ref_url": "https://en.wikipedia.org/wiki/Blueprint",
        "ref_title": "Wikipedia: Blueprint",
        "def": {
            "en": "Pre-configured, idempotent architectural topologies declaring database containers, middleware, ports, and dev tools.",
            "et": "Eelkonfigureeritud, idempotentsed arhitektuuritopoloogiad andmebaaside, vahevara, portide ja arendustööriistade halduseks.",
            "fi": "Ennalta määritellyt, idempotentit arkkitehtuuritietueet tietokannoille, väliohjelmistoille ja porteille.",
            "sv": "Förkonfigurerade, idempotenta arkitekturmönster som definierar databaser, mellanprogramvara och portar.",
            "lv": "Iepriekš konfigurētas arhitektūras topoloģijas datubāzēm, starpprogrammatūrai un portiem.",
            "lt": "Iš anksto sukonfigūruotos architektūros topologijos duomenų bazėms, tarpinei įrangai ir prievadams."
        },
        "project_role": {
            "en": "12 canonical environments (BP 0 to BP 11) deployable via './scripts/deploy-blueprint.sh <ID>' or Dev Hub Cockpit.",
            "et": "12 kanoonilist keskkonda (BP 0 kuni BP 11), mida saab käivitada käsuga './scripts/deploy-blueprint.sh <ID>' või Dev Hubist.",
            "fi": "12 kanonista ympäristöä (BP 0 - BP 11), jotka käynnistetään './scripts/deploy-blueprint.sh <ID>' tai Dev Hubista.",
            "sv": "12 kanoniska miljöer (BP 0 till BP 11) som distribueras via script eller Dev Hub.",
            "lv": "12 kanooniskas vides (BP 0 līdz BP 11), kas palaižamas ar vienu komandu vai Dev Hub.",
            "lt": "12 kanoninių aplinkų (BP 0 iki BP 11), paleidžiamų per komandą arba Dev Hub."
        },
        "links": [
            {"label": "config/blueprints/README.md", "url": "config/blueprints/README.md"},
            {"label": "scripts/deploy-blueprint.sh", "url": "scripts/deploy-blueprint.sh"}
        ]
    },
    {
        "acronym": "CA",
        "expansion": "Certificate Authority",
        "category": "security",
        "ref_url": "https://en.wikipedia.org/wiki/Certificate_authority",
        "ref_title": "Wikipedia: Certificate Authority",
        "def": {
            "en": "A trusted entity that issues cryptographic digital certificates for verifying identities and enabling TLS encryption.",
            "et": "Usaldusväärne asutus, mis väljastab krüptograafilisi digisertifikaate identiteedi tuvastamiseks ja TLS krüpteeringuks.",
            "fi": "Luotettu taho, joka myöntää digitaalisia varmenteita TLS-salauksen ja identiteetin varmentamiseen.",
            "sv": "En betrodd utfärdare av digitala certifikat för identitetsverifiering och TLS-kryptering.",
            "lv": "Uzticama iestāde, kas izsniedz digitālos sertifikātus TLS šifrēšanai.",
            "lt": "Patikimas centras, išduodantis skaitmeninius sertifikatus TLS šifravimui."
        },
        "project_role": {
            "en": "Platform generates an autonomous local Root CA (certs/ca.crt) registered into OS trust stores (macOS, Windows, Linux).",
            "et": "Platvorm genereerib kohaliku Root CA (certs/ca.crt), mis registreeritakse operatsioonisüsteemi sertifikaadihoidlasse.",
            "fi": "Alusta luo paikallisen Root CA:n (certs/ca.crt), joka asennetaan käyttöjärjestelmän luottamusvarastoon.",
            "sv": "Plattformen skapar en lokal Root CA (certs/ca.crt) som installeras i OS-certifikatarkivet.",
            "lv": "Platforma ģenerē lokālo Root CA (certs/ca.crt), kas reģistrēts OS uzticamajā krātuvē.",
            "lt": "Platforma sukuria vietinį Root CA (certs/ca.crt), registruojamą OS patikimųjų sertifikatų saugykloje."
        },
        "links": [
            {"label": "docs/security.md", "url": "docs/security.md"},
            {"label": "scripts/certs/trust-local-cert-mac.sh", "url": "scripts/certs/trust-local-cert-mac.sh"}
        ]
    },
    {
        "acronym": "CDB",
        "expansion": "Container Database",
        "category": "database",
        "ref_url": "https://docs.oracle.com/en/database/oracle/oracle-database/23/cncpt/multitenant-architecture.html",
        "ref_title": "Oracle Multitenant Architecture",
        "def": {
            "en": "Oracle multitenant architecture root database that houses metadata and contains one or more pluggable databases (PDBs).",
            "et": "Oracle mitmeüürilise arhitektuuri juurandmebaas, mis hoiab süsteemset metaandmestikku ja sisaldab ühte või mitut PDB-d.",
            "fi": "Oraclen multitenant-arkkitehtuurin juuritietokanta, joka sisältää yhden tai useamman PDB-tietokannan.",
            "sv": "Oracles multitenant-rotdatabas som hanterar metadata och rymmer en eller flera PDB:er.",
            "lv": "Oracle multitenant arhitektūras saknes datubāze, kas satur vienu vai vairākas PDB.",
            "lt": "Oracle kelių nuomininkų architektūros šakninė DB, kurioje talpinamos viena ar kelios PDB."
        },
        "project_role": {
            "en": "Standard CDB$ROOT in containerized 23ai Free DB; managed with zero manual configuration by init-db-instance.sh.",
            "et": "Standardne CDB$ROOT konteinerdatud 23ai Free DB-s; hallatakse automaatselt init-db-instance.sh skriptiga.",
            "fi": "Vakio CDB$ROOT kontitetussa 23ai Free DB:ssä; alustetaan automaattisesti init-db-instance.sh -skriptillä.",
            "sv": "Standard CDB$ROOT i 23ai Free DB-containern; hanteras helautomatiskt via init-db-instance.sh.",
            "lv": "Standarta CDB$ROOT 23ai Free DB konteinerā; tiek uzturēta automātiski.",
            "lt": "Standartinė CDB$ROOT 23ai Free DB konteineryje; valdoma automatiškai."
        },
        "links": [
            {"label": "docs/db-profiles-and-topology.md", "url": "docs/db-profiles-and-topology.md"},
            {"label": "scripts/internal/init-db-instance.sh", "url": "scripts/internal/init-db-instance.sh"}
        ]
    },
    {
        "acronym": "CI/CD",
        "expansion": "Continuous Integration / Continuous Deployment",
        "category": "devops",
        "ref_url": "https://en.wikipedia.org/wiki/CI/CD",
        "ref_title": "Wikipedia: CI/CD",
        "def": {
            "en": "DevOps automated pipeline practice for building, testing, validating, and releasing code incrementally and safely.",
            "et": "DevOps automatiseeritud töövood koodi pidevaks kompileerimiseks, testimiseks, valideerimiseks ja toodangusse viimiseks.",
            "fi": "DevOps-automaatioputki koodin jatkuvaan integrointiin, testaukseen ja turvalliseen julkaisuun.",
            "sv": "Automatiserade DevOps-pipelines för kontinuerlig integrering, testning och leverans av kod.",
            "lv": "DevOps automatizēts process nepārtrauktai koda integrācijai, testēšanai un piegādei.",
            "lt": "DevOps automatizuota eiga nuolatiniam kodo integravimui, testavimui ir diegimui."
        },
        "project_role": {
            "en": "Tested locally offline via './tests/test-local-ci.sh' and integrated into Dev Hub's Testing tab with 15 test suites.",
            "et": "Testitav lokaalselt ilma internetita käsuga './tests/test-local-ci.sh' ning Dev Hubi testimisvahelehel 15 komplektiga.",
            "fi": "Testattavissa paikallisesti './tests/test-local-ci.sh' -komennolla ja Dev Hubin Testaus-välilehdellä 15 sarjalla.",
            "sv": "Testas lokalt offline via './tests/test-local-ci.sh' och i Dev Hubs testflik med 15 testsviter.",
            "lv": "Testēts lokāli bezsaistē ar './tests/test-local-ci.sh' un Dev Hub testēšanas cilnē ar 15 komplektiem.",
            "lt": "Testuojama lokaliai be interneto per './tests/test-local-ci.sh' ir Dev Hub testavimo skiltyje su 15 rinkinių."
        },
        "links": [
            {"label": "tests/test-local-ci.sh", "url": "tests/test-local-ci.sh"},
            {"label": "docs/devops-lifecycle-guide.md", "url": "docs/devops-lifecycle-guide.md"}
        ]
    },
    {
        "acronym": "CLI",
        "expansion": "Command Line Interface",
        "category": "tools",
        "ref_url": "https://en.wikipedia.org/wiki/Command-line_interface",
        "ref_title": "Wikipedia: Command-Line Interface",
        "def": {
            "en": "Text-based user interface used to execute commands, automate scripts, and manage operating system resources.",
            "et": "Tekstipõhine kasutajaliides käskude käivitamiseks, skriptide automatiseerimiseks ja süsteemiressursside haldamiseks.",
            "fi": "Tekstipohjainen komentoliittymä ohjelmien suorittamiseen ja järjestelmän hallintaan.",
            "sv": "Textbaserat användargränssnitt för att köra kommandon och automatisera skript.",
            "lv": "Teksta komandrindas saskarne komandu izpildei un procesu automatizācijai.",
            "lt": "Tekstinė komandinė sąsaja komandų vykdymui ir procesų automatizavimui."
        },
        "project_role": {
            "en": "Unified script layout in scripts/ (e.g. sqlcl.sh, get-password.sh, check-urls.sh) with dual terminal/GUI parity.",
            "et": "Ühtne skriptide paigutus kaustas scripts/ (nt sqlcl.sh, get-password.sh, check-urls.sh) täielikus vastavuses Dev Hub GUI-ga.",
            "fi": "Yhdenmukainen komentorivikattaus scripts/-hakemistossa (sqlcl.sh, get-password.sh jne.) täydellä GUI-pariteetilla.",
            "sv": "Enhetliga CLI-verktyg i scripts/ med full paritet gentemot Dev Hub webbgränssnitt.",
            "lv": "Vienota komandrindas rīku struktūra mapē scripts/ ar pilnu saskaņu ar Dev Hub GUI.",
            "lt": "Vieninga komandinės eilutės struktūra aplanke scripts/ su visišku atitikimu Dev Hub GUI."
        },
        "links": [
            {"label": "scripts/README.md", "url": "scripts/README.md"},
            {"label": "scripts/sqlcl.sh", "url": "scripts/sqlcl.sh"}
        ]
    },
    {
        "acronym": "CPU",
        "expansion": "Central Processing Unit",
        "category": "hardware",
        "ref_url": "https://en.wikipedia.org/wiki/Central_processing_unit",
        "ref_title": "Wikipedia: CPU",
        "def": {
            "en": "The primary component of a computer that executes program instructions and processes operational data.",
            "et": "Arvuti keskprotsessor, mis viib täide programmikäske ja teostab põhilisi andmetöötlustoiminguid.",
            "fi": "Tietokoneen keskusyksikkö, joka suorittaa ohjelmakäskyt ja käsittelee tietoa.",
            "sv": "Datorns centralprocessor som exekverar programinstruktioner och bearbetar data.",
            "lv": "Datora centrālais procesors, kas izpilda programmatūras instrukcijas.",
            "lt": "Pagrindinis kompiuterio procesorius, vykdantis programų instrukcijas."
        },
        "project_role": {
            "en": "Monitored per-container in Dev Hub Cockpit; 23ai Free DB constrained to 2 vCPUs without throttled locks.",
            "et": "Jälgitav reaalajas konteinerite kaupa Dev Hubi juhtpaneelis; 23ai Free DB piiratud 2 tuumaga.",
            "fi": "Valvotaan konttikohtaisesti Dev Hubissa; 23ai Free DB toimii tehokkaasti 2 vCPU:n rajoissa.",
            "sv": "Övervakas per container i Dev Hub; 23ai Free DB begränsas till 2 processorkärnor.",
            "lv": "Uzraudzīts katram konteineram Dev Hub panelī; 23ai Free DB ir 2 vCPU ierobežojums.",
            "lt": "Stebimas kiekvienam konteineriui Dev Hub; 23ai Free DB veikia 2 vCPU ribose."
        },
        "links": [
            {"label": "docs/dev-hub.html", "url": "docs/dev-hub.html"}
        ]
    },
    {
        "acronym": "CRLF",
        "expansion": "Carriage Return Line Feed (\\r\\n)",
        "category": "os",
        "ref_url": "https://en.wikipedia.org/wiki/Newline",
        "ref_title": "Wikipedia: Newline (CRLF)",
        "def": {
            "en": "Two-byte newline delimiter standard in Windows DOS/NTFS filesystems, incompatible with Unix shells.",
            "et": "Kahebaidine reavahetusstandard Windowsi failisüsteemides, mis põhjustab vigu Unixi kestades (/bin/bash^M).",
            "fi": "Windows-tiedostojärjestelmien kahden tavun rivinvaihto, joka aiheuttaa virheitä Unix-skripteissä.",
            "sv": "Två-byte radbrytning i Windows som skapar kompileringsfel i Unix-baserade shell-skript.",
            "lv": "Windows divu baitu rindiņas beigu formāts, kas rada kļūdas Unix čaulas skriptos.",
            "lt": "Windows dviejų baitų eilutės pabaigos formatas, sukeliantis klaidas Unix skriptuose."
        },
        "project_role": {
            "en": "Strictly forbidden in shell scripts (.sh) by .gitattributes and verified in Rule 14 Windows dry-run tests.",
            "et": "Rangelt välistatud shelliskriptides (.sh) läbi .gitattributes reeglite ja kontrollitud Windowsi testidega (Reegel 14).",
            "fi": "Ehdottomasti kielletty shell-skripteissä (.sh) .gitattributes-määrityksellä ja Windows-testeillä (Sääntö 14).",
            "sv": "Strikt förbjudet i shell-skript via .gitattributes och verifierat i Windows-tester (Regel 14).",
            "lv": "Stingri aizliegts čaulas skriptos (.sh) ar .gitattributes un pārbaudīts Windows testos.",
            "lt": "Griežtai draudžiamas skriptuose (.sh) per .gitattributes ir tikrinamas Windows testais."
        },
        "links": [
            {"label": ".gitattributes", "url": ".gitattributes"},
            {"label": "tests/unit/test-windows-enterprise-rules.sh", "url": "tests/unit/test-windows-enterprise-rules.sh"}
        ]
    },
    {
        "acronym": "DBA",
        "expansion": "Database Administrator",
        "category": "database",
        "ref_url": "https://en.wikipedia.org/wiki/Database_administrator",
        "ref_title": "Wikipedia: Database Administrator",
        "def": {
            "en": "Professional responsible for database installation, security, tuning, backup recovery, and schema management.",
            "et": "IT-spetsialist, kes vastutab andmebaaside paigalduse, turvalisuse, varukoopiate, taaste ja skeemihalduse eest.",
            "fi": "Tietokanta-asiantuntija, joka vastaa tietokantojen asennuksesta, suorituskyvystä ja varmuuskopioista.",
            "sv": "Databasadministratör med ansvar för drift, säkerhet, prestanda och återställning.",
            "lv": "Datubāzu administrators, kas atbild par uzturēšanu, drošību un rezerves kopijām.",
            "lt": "Duomenų bazių administratorius, atsakingas už diegimą, saugumą ir atkūrimą."
        },
        "project_role": {
            "en": "Platform removes developer bottlenecks by automating 100% of DBA routines (wallet creation, users, grants, restarts).",
            "et": "Platvorm kaotab pudelikaelad, automatiseerides 100% DBA rutiinidest (paroolid, kasutajad, õigused, taaskäivitused).",
            "fi": "Alusta poistaa kehittäjien odotusajat automatisoimalla DBA-rutiinit (lompakot, käyttäjät, oikeudet).",
            "sv": "Plattformen eliminerar flaskhalsar genom att automatisera 100% av DBA-rutinerna.",
            "lv": "Platforma novērš aiztures, automatizējot visas ikdienas DBA procedūras.",
            "lt": "Platforma panaikina kliūtis, automatizuodama 100% kasdienių DBA procedūrų."
        },
        "links": [
            {"label": "scripts/internal/apply-profile-users.sh", "url": "scripts/internal/apply-profile-users.sh"},
            {"label": "scripts/create-developer.sh", "url": "scripts/create-developer.sh"}
        ]
    },
    {
        "acronym": "DR",
        "expansion": "Disaster Recovery",
        "category": "devops",
        "ref_url": "https://en.wikipedia.org/wiki/Disaster_recovery",
        "ref_title": "Wikipedia: Disaster Recovery",
        "def": {
            "en": "Processes and strategies that restore access to applications, data, and IT infrastructure following a catastrophe.",
            "et": "Protsessid ja strateegiad andmebaasi, andmete ja IT-taristu välkkiireks taastamiseks pärast tõrget või riket.",
            "fi": "Menetelmät ja valmiudet järjestelmien ja datan palauttamiseksi vakavien häiriöiden jälkeen.",
            "sv": "Processer för att snabbt återställa data och infrastruktur efter allvarliga incidenter.",
            "lv": "Procedūras datu un infrastruktūras ātrai atjaunošanai avāriju gadījumā.",
            "lt": "Procesai ir strategijos greitam duomenų ir sistemų atkūrimui po gedimų."
        },
        "project_role": {
            "en": "Achieved in ~15 seconds via Golden Snapshots (scripts/snapshots/), resetting corrupt environments with zero DBA tickets.",
            "et": "Saavutatakse ~15 sekundiga Golden Snapshotide abil (scripts/snapshots/), taastades rikutud keskkonnad piletivabalt.",
            "fi": "Toteutetaan ~15 sekunnissa Golden Snapshot -pikapalautuksella (scripts/snapshots/) ilman DBA-tikettejä.",
            "sv": "Uppnås på ~15 sekunder via Golden Snapshots som återställer miljöer utan administration.",
            "lv": "Realizēts ~15 sekundēs ar Golden Snapshot palīdzību, pilnībā atjaunojot vidi.",
            "lt": "Pasiekiama per ~15 sekundžių su Golden Snapshot pagalba, atkuriant aplinką be bilietų."
        },
        "links": [
            {"label": "scripts/snapshots/README.md", "url": "scripts/snapshots/README.md"},
            {"label": "scripts/snapshots/restore-golden-snapshots.sh", "url": "scripts/snapshots/restore-golden-snapshots.sh"}
        ]
    },
    {
        "acronym": "DSL",
        "expansion": "Domain-Specific Language",
        "category": "tools",
        "ref_url": "https://en.wikipedia.org/wiki/Domain-specific_language",
        "ref_title": "Wikipedia: Domain-Specific Language",
        "def": {
            "en": "A specialized programming or specification language tailored specifically to solve problems in a single domain.",
            "et": "Spetsialiseeritud programmeerimis- või spetsifitseerimiskeel, mis on kohandatud kindla valdkonna lahendamiseks.",
            "fi": "Tiettyyn sovellusalueeseen räätälöity erikoiskieli (kuten deklaratiivinen määrityskieli).",
            "sv": "Ett specialiserat programmeringsspråk anpassat för en specifik problemdomän.",
            "lv": "Specializēta valoda konkrēta domēna uzdevumu risināšanai.",
            "lt": "Specializuota kalba, skirta konkrečios srities uždaviniams aprašyti."
        },
        "project_role": {
            "en": "APEXlang (.apx) declarative language for describing APEX pages, regions, items, and multi-language tokens.",
            "et": "APEXlang (.apx) deklaratiivne keel APEX lehekülgede, plokkide, väljade ja mitmekeelsete märgiste kirjeldamiseks.",
            "fi": "APEXlang (.apx) deklaratiivinen kieli APEX-sivujen, lohkojen ja käännösten määrittämiseen.",
            "sv": "APEXlang (.apx) deklarativt språk för att specificera APEX-sidor och komponenter i Git.",
            "lv": "APEXlang (.apx) deklaratīva valoda APEX lappušu un komponentu aprakstīšanai.",
            "lt": "APEXlang (.apx) deklaratyvi kalba APEX puslapiams ir komponentams aprašyti."
        },
        "links": [
            {"label": "docs/apex-devhub-test-plan.md", "url": "docs/apex-devhub-test-plan.md"}
        ]
    },
    {
        "acronym": "E2E",
        "expansion": "End-to-End Testing",
        "category": "testing",
        "ref_url": "https://en.wikipedia.org/wiki/Software_testing#End-to-end_testing",
        "ref_title": "Wikipedia: End-to-End Testing",
        "def": {
            "en": "Testing methodology that validates entire software flows from user interface down to database persistence.",
            "et": "Testimismetoodika, mis kontrollib kogu tarkvaraprotsessi alates kasutajaliidesest kuni andmebaasi salvestuseni.",
            "fi": "Testausmenetelmä, joka todentaa sovelluksen koko toimintaketjun käyttöliittymästä tietokantaan.",
            "sv": "Testmetodik som verifierar hela flödet från användargränssnitt till databaslagring.",
            "lv": "Testēšanas metodoloģija, kas pārbauda visu procesu no lietotāja saskarnes līdz datubāzei.",
            "lt": "Testavimo metodika, tikrinanti visą grandinę nuo vartotojo sąsajos iki duomenų bazės."
        },
        "project_role": {
            "en": "Represented by 6 suites in Dev Hub Testing tab (test-browser-login.sh, test-devhub-lifecycle-full.sh, etc.).",
            "et": "Esindatud 6 komplektiga Dev Hubi testimisvahelehel (test-browser-login.sh, test-devhub-lifecycle-full.sh jne).",
            "fi": "Käytössä 6 testisatsina Dev Hubin testausvälilehdellä todentaen APEX-kirjautumiset ja elinkaaren.",
            "sv": "Representerat av 6 sviter i Dev Hub testcenter för fullständiga flödestester.",
            "lv": "Ietver 6 komplektus Dev Hub testēšanas rīkā pilnīgai darbības pārbaudei.",
            "lt": "Apima 6 rinkinius Dev Hub testavimo centre visos sistemos patikrinimui."
        },
        "links": [
            {"label": "tests/test-browser-login.sh", "url": "tests/test-browser-login.sh"},
            {"label": "docs/devhub-browser-testing-plan.md", "url": "docs/devhub-browser-testing-plan.md"}
        ]
    },
    {
        "acronym": "FAT / NTFS",
        "expansion": "File Allocation Table / New Technology File System",
        "category": "os",
        "ref_url": "https://en.wikipedia.org/wiki/NTFS",
        "ref_title": "Wikipedia: NTFS",
        "def": {
            "en": "Standard Windows filesystems with reserved characters (<, >, :, \", |, ?, *), trailing dot/space limits, and reserved device names.",
            "et": "Windowsi failisüsteemid, millel on keelatud märgid (<, >, :, \", |, ?, *), tühikud rea lõpus ja reserveeritud nimed (CON, PRN, AUX).",
            "fi": "Windows-tiedostojärjestelmät, joissa on varattuja merkkejä ja laitenimiä (CON, PRN, AUX).",
            "sv": "Windows-filsystem med strikta begränsningar för otillåtna tecken och reserverade enhetsnamn.",
            "lv": "Windows failu sistēmas ar aizliegtajām rakstzīmēm un rezervētajiem ierīču nosaukumiem.",
            "lt": "Windows failų sistemos su draudžiamais simboliais ir rezervuotais įrenginių pavadinimais."
        },
        "project_role": {
            "en": "Enforced by Rule 13 and unit tested across all repo files by tests/unit/test-filename-portability.sh.",
            "et": "Reguleeritud Reegliga 13 ja testitud kõigi failide lõikes skriptiga tests/unit/test-filename-portability.sh.",
            "fi": "Määritelty Säännössä 13 ja valvottu repositorion tiedostoissa siirrettävyystesteillä.",
            "sv": "Hanteras strikt enligt Regel 13 och verifieras av test-filename-portability.sh.",
            "lv": "Tiek kontrolēts atbilstoši 13. noteikumam ar automatizētiem testiem.",
            "lt": "Prižiūrima pagal 13 taisyklę su automatizuotais failų suderinamumo testais."
        },
        "links": [
            {"label": "tests/unit/test-filename-portability.sh", "url": "tests/unit/test-filename-portability.sh"}
        ]
    },
    {
        "acronym": "FMW",
        "expansion": "Fusion Middleware",
        "category": "middleware",
        "ref_url": "https://en.wikipedia.org/wiki/Oracle_Fusion_Middleware",
        "ref_title": "Wikipedia: Oracle Fusion Middleware",
        "def": {
            "en": "Oracle's enterprise software suite including WebLogic Server, Oracle Forms, Reports, and Analytics Publisher.",
            "et": "Oracle ettevõtte tasemel tarkvaraperekond, mis sisaldab WebLogic serverit, Forms, Reports ja Publisher vahevara.",
            "fi": "Oraclen väliohjelmistoperhe, johon kuuluvat WebLogic, Forms ja Analytics Publisher.",
            "sv": "Oracles företagsinfrastruktur bestående av WebLogic Server, Forms och Publisher.",
            "lv": "Oracle starpprogrammatūras saime, ieskaitot WebLogic un Forms komponentes.",
            "lt": "Oracle tarpinės programinės įrangos paketas, apimantis WebLogic ir Forms."
        },
        "project_role": {
            "en": "Containerized in BP 6 & 7 (Forms 14c) and BP 4 & 11 (Analytics Publisher) with automated fast health checks.",
            "et": "Konteinerdatud blueprintides BP 6 & 7 (Forms 14c) ja BP 4 & 11 (Analytics Publisher) kiirete tervisekontrollidega.",
            "fi": "Kontitettu malleissa BP 6 & 7 (Forms) ja BP 4 & 11 (Publisher) automaattisella valvonnalla.",
            "sv": "Körs i containrar för Forms 14c och Analytics Publisher med full automatisering.",
            "lv": "Konteinerizēts Forms 14c un Publisher vidēm ar automātiskām pārbaudēm.",
            "lt": "Konteinerizuota Forms 14c ir Publisher aplinkoms su automatinėmis patikromis."
        },
        "links": [
            {"label": "docs/forms-setup.md", "url": "docs/forms-setup.md"},
            {"label": "docs/publisher-setup.md", "url": "docs/publisher-setup.md"}
        ]
    },
    {
        "acronym": "GUI",
        "expansion": "Graphical User Interface",
        "category": "web",
        "ref_url": "https://en.wikipedia.org/wiki/Graphical_user_interface",
        "ref_title": "Wikipedia: GUI",
        "def": {
            "en": "Visual display interface that allows users to interact with software through icons, buttons, and forms instead of CLI.",
            "et": "Graafiline kasutajaliides, mis võimaldab tarkvaraga suhelda visuaalsete nuppude, vormide ja akende kaudu.",
            "fi": "Graafinen käyttöliittymä visuaalisilla painikkeilla ja lomakkeilla komentorivin sijaan.",
            "sv": "Grafiskt användargränssnitt med knappar och fönster för enkel visuell interaktion.",
            "lv": "Grafiskā lietotāja saskarne ērtai vizuālai darbībai bez komandrindas.",
            "lt": "Grafinė vartotojo sąsaja patogiam darbui per mygtukus ir langus."
        },
        "project_role": {
            "en": "Provided by Dev Hub (dev-hub.html) on port 8448 with 1-click container actions, log streaming, and slide deck.",
            "et": "Pakutud Dev Hubi (dev-hub.html) kaudu pordil 8448 koos 1-kliki konteinerihalduse, logide ja esitlustekiga.",
            "fi": "Tarjotaan Dev Hubin (dev-hub.html) kautta sisältäen konttitoiminnot, lokit ja esityksen.",
            "sv": "Tillhandahålls av Dev Hub med ett-klicks containerkontroll och presentationsvy.",
            "lv": "Nodrošina Dev Hub portā 8448 ar 1-klikšķa konteineru vadību un pārskatiem.",
            "lt": "Pateikiama per Dev Hub prievade 8448 su 1 paspaudimo konteinerių valdymu."
        },
        "links": [
            {"label": "docs/dev-hub.html", "url": "docs/dev-hub.html"},
            {"label": "scripts/internal/generate_dev_hub.py", "url": "scripts/internal/generate_dev_hub.py"}
        ]
    },
    {
        "acronym": "HTTP / HTTPS",
        "expansion": "Hypertext Transfer Protocol (Secure)",
        "category": "web",
        "ref_url": "https://en.wikipedia.org/wiki/HTTPS",
        "ref_title": "Wikipedia: HTTPS",
        "def": {
            "en": "The foundation protocol for data communication on the World Wide Web, secured by TLS encryption in HTTPS.",
            "et": "Veebisuhtluse alusprotokoll, mis HTTPS variandis on turvatud TLS krüpteeringuga.",
            "fi": "Verkkoliikenteen perusprotokolla, joka HTTPS-muodossa on salattu TLS-yhteydellä.",
            "sv": "Grundläggande webbkommunikationsprotokoll, krypterat med TLS i HTTPS.",
            "lv": "Tīmekļa datu pārraides protokols, kas HTTPS versijā ir šifrēts ar TLS.",
            "lt": "Pagrindinis saityno protokolas, HTTPS versijoje apsaugotas TLS šifravimu."
        },
        "project_role": {
            "en": "All platform web services (Dev Hub :8448, ORDS :8448/:8088, Publisher :9502, Forms :9001) run with zero browser warnings.",
            "et": "Kõik veebiteenused (Dev Hub :8448, ORDS :8448, Publisher :9502, Forms :9001) töötavad ilma brauseri hoiatusteta.",
            "fi": "Kaikki alustan verkkopalvelut toimivat turvallisesti ilman selaimen varoituksia.",
            "sv": "Alla plattformens webbtjänster körs säkert över TLS utan säkerhetsvarningar.",
            "lv": "Visi platformas tīmekļa pakalpojumi darbojas šifrēti bez brīdinājumiem pārlūkā.",
            "lt": "Visos platformos žiniatinklio paslaugos veikia saugiai be naršyklės įspėjimų."
        },
        "links": [
            {"label": "scripts/check-urls.sh", "url": "scripts/check-urls.sh"}
        ]
    },
    {
        "acronym": "i18n",
        "expansion": "Internationalization",
        "category": "i18n",
        "ref_url": "https://en.wikipedia.org/wiki/Internationalization_and_localization",
        "ref_title": "Wikipedia: Internationalization (i18n)",
        "def": {
            "en": "Designing software to be adaptable to various languages and regions without engineering code changes.",
            "et": "Tarkvara arhitektuurne ülesehitus, mis võimaldab kohandamist erinevatesse keeltesse ilma koodi muutmata.",
            "fi": "Ohjelmiston suunnittelu useille kielille ja alueille ilman ohjelmakoodin muutoksia.",
            "sv": "Design av mjukvara för stöd för flera språk och regioner utan kodändringar.",
            "lv": "Programmatūras pielāgošana vairākām valodām un reģioniem.",
            "lt": "Programinės įrangos pritaikymas kelioms kalboms be kodo modifikacijų."
        },
        "project_role": {
            "en": "Strictly mandated by Rule 9: 100% dictionary symmetry across 6 languages (EN, ET, FI, SV, LV, LT) in docs and Dev Hub.",
            "et": "Kohustuslik vastavalt Reeglile 9: 100% sõnastikusümmeetria 6 keeles (EN, ET, FI, SV, LV, LT) dokumentides ja Dev Hubis.",
            "fi": "Säännön 9 mukaisesti taataan 100% symmetria 6 kielellä (EN, ET, FI, SV, LV, LT).",
            "sv": "Strikt enligt Regel 9: 100% symmetri över 6 språk i all dokumentation och Dev Hub.",
            "lv": "Noteikuma 9 prasība: 100% simetrija 6 valodās visā platformas dokumentācijā.",
            "lt": "Pagal 9 taisyklę užtikrinama 100% simetrija 6 kalbomis visoje platformoje."
        },
        "links": [
            {"label": "tests/unit/test-i18n-translations.sh", "url": "tests/unit/test-i18n-translations.sh"},
            {"label": "scripts/internal/i18n.sh", "url": "scripts/internal/i18n.sh"}
        ]
    },
    {
        "acronym": "IDE",
        "expansion": "Integrated Development Environment",
        "category": "tools",
        "ref_url": "https://en.wikipedia.org/wiki/Integrated_development_environment",
        "ref_title": "Wikipedia: IDE",
        "def": {
            "en": "Software suite consolidating developer tools (code editor, compiler/interpreter, debugger, version control) into one UI.",
            "et": "Integreeritud arenduskeskkond, mis ühendab koodiredaktori, siluri, terminali ja versioonihalduse ühte programmi.",
            "fi": "Integroitu kehitysympäristö, joka yhdistää koodieditorin, kääntäjän ja virheenkorjauksen.",
            "sv": "Integrerad utvecklingsmiljö som samlar kodredigerare, felsökare och versionshantering.",
            "lv": "Integrēta izstrādes vide koda rakstīšanai, atkļūdošanai un versiju pārvaldībai.",
            "lt": "Integruota kūrimo aplinka kodo redagavimui, derinimui ir versijų valdymui."
        },
        "project_role": {
            "en": "Supported locally via VS Code with Oracle extension and remotely via browser-based Web-IDE (BP 8, port 8090).",
            "et": "Toetatud lokaalselt VS Code-is koos Oracle laiendusega ja brauseris Web-IDE kaudu (BP 8, port 8090).",
            "fi": "Tuettu paikallisesti VS Codella ja selaimessa toimivalla Web-IDE:llä (BP 8, portti 8090).",
            "sv": "Stöds lokalt via VS Code och webbaserat via Web-IDE (BP 8, port 8090).",
            "lv": "Atbalstīts lokāli VS Code un pārlūkā ar Web-IDE (BP 8, ports 8090).",
            "lt": "Palaikoma lokaliai per VS Code ir naršyklėje per Web-IDE (BP 8, prievadas 8090)."
        },
        "links": [
            {"label": "docker/web-ide/README.md", "url": "docker/web-ide/README.md"},
            {"label": "scripts/register-connections.sh", "url": "scripts/register-connections.sh"}
        ]
    },
    {
        "acronym": "JIT",
        "expansion": "Just-In-Time (Decryption / Compilation)",
        "category": "security",
        "ref_url": "https://en.wikipedia.org/wiki/Just-in-time_compilation",
        "ref_title": "Wikipedia: Just-In-Time (JIT)",
        "def": {
            "en": "Execution or evaluation model where artifacts or credentials are processed dynamically in memory at the moment needed.",
            "et": "Töötlusmudel, kus paroolid või tõmmised kompileeritakse/dekrüpteeritakse käitusajal otse mälus ilma kettale salvestamata.",
            "fi": "Käsittelymalli, jossa tiedot tai salasanat avataan muistissa vasta tarvehetkellä ilman tallennusta levylle.",
            "sv": "Modell där autentiseringsuppgifter avkodas i minnet exakt vid körningstillfället utan disklagring.",
            "lv": "Modelis, kur akreditācijas dati tiek atšifrēti operatīvajā atmiņā tieši izpildes brīdī.",
            "lt": "Modelis, kai prisijungimo duomenys iššifruojami atmintyje tik vykdymo metu be disko."
        },
        "project_role": {
            "en": "Core to Zero-Trust Rule 5: passwords decrypted dynamically via ./scripts/get-password.sh into RAM and destroyed on exit.",
            "et": "Zero-Trust Reegli 5 alus: paroolid dekrüpteeritakse mällu käsuga ./scripts/get-password.sh ja hävitatakse väljumisel.",
            "fi": "Zero-Trust-säännön 5 perusta: salasanat avataan vain muistissa ja tuhotaan heti ajon päätyttyä.",
            "sv": "Kärnan i Zero-Trust Regel 5: lösenord läses dynamiskt till minnet och förstörs direkt efter körning.",
            "lv": "Zero-Trust 5. noteikuma pamats: paroles tiek atšifrētas atmiņā un dzēstas pēc izpildes.",
            "lt": "Zero-Trust 5 taisyklės pagrindas: slaptažodžiai nuskaitomi į atmintį ir sunaikinami iškart po vykdymo."
        },
        "links": [
            {"label": "scripts/get-password.sh", "url": "scripts/get-password.sh"},
            {"label": "docs/security.md", "url": "docs/security.md"}
        ]
    },
    {
        "acronym": "JSON",
        "expansion": "JavaScript Object Notation",
        "category": "data",
        "ref_url": "https://en.wikipedia.org/wiki/JSON",
        "ref_title": "Wikipedia: JSON",
        "def": {
            "en": "Standard, lightweight, text-based data interchange format based on JavaScript object syntax.",
            "et": "Standardne kergekaaluline tekstipõhine andmevahetusvorming, mida kasutavad API-d ja konfiguratsioonid.",
            "fi": "Kevyt, tekstipohjainen tiedonsiirtomuoto, jota käytetään rajapinnoissa ja konfiguraatioissa.",
            "sv": "Lättviktigt textbaserat format för datautbyte mellan webbtjänster och applikationer.",
            "lv": "Viegls teksta datu apmaiņas formāts lietojumprogrammām un API.",
            "lt": "Lengvas tekstinis duomenų mainų formatas saityno paslaugoms ir API."
        },
        "project_role": {
            "en": "Used for benchmark metrics (metrics/setup_benchmarks.json), Dev Hub REST APIs, and compiled HTML datasets.",
            "et": "Kasutusel paigaldusmõõdikutes (metrics/setup_benchmarks.json), Dev Hub API-des ja genereeritud HTML-i andmetes.",
            "fi": "Käytössä suorituskykymittareissa, Dev Hubin REST API -vastauksissa ja koostetussa HTML-tiedostossa.",
            "sv": "Används för prestandamätningar, Dev Hub REST API och genererad HTML-data.",
            "lv": "Tiek izmantots veiktspējas datos, Dev Hub API un ģenerētajā HTML failā.",
            "lt": "Naudojamas našumo metrikoje, Dev Hub API ir sukompiliuotame HTML faile."
        },
        "links": [
            {"label": "metrics/setup_benchmarks.json", "url": "metrics/setup_benchmarks.json"}
        ]
    },
    {
        "acronym": "KPI",
        "expansion": "Key Performance Indicator",
        "category": "business",
        "ref_url": "https://en.wikipedia.org/wiki/Performance_indicator",
        "ref_title": "Wikipedia: Key Performance Indicator",
        "def": {
            "en": "Quantifiable measure used to evaluate the success of an organization, platform, or project in meeting objectives.",
            "et": "Mõõdetav tulemusnäitaja organisatsiooni, platvormi või IT-süsteemi tõhususe ja eesmärkide hindamiseks.",
            "fi": "Määrällinen suorituskykymittari alustan tai prosessin tehokkuuden arviointiin.",
            "sv": "Mätbar nyckeltalsindikator för att utvärdera prestanda och mål i projekt och system.",
            "lv": "Izmērāms rādītājs sistēmas efektivitātes un mērķu sasniegšanas novērtēšanai.",
            "lt": "Išmatuojamas rodiklis platformos efektyvumui ir tikslų pasiekimui vertinti."
        },
        "project_role": {
            "en": "Displayed on Dev Hub presentation cards (e.g. -85% SEISAKUID, 1-KLIKK KÄIVITUS, ~15S TAASTE, 0€ LITSENTSIKULU).",
            "et": "Kuvatud Dev Hubi esitluskaartidel (nt -85% SEISAKUID, 1-KLIKK KÄIVITUS, ~15S TAASTE, 0€ LITSENTSIKULU).",
            "fi": "Näytetään Dev Hubin esityskorteissa (esim. -85% SEISOKKEJA, 1-KLIKKAAUKSEN STARTTI jne.).",
            "sv": "Visas på Dev Hubs presentationskort (-85% DRIFTSTOPP, 1-KLICKS START, 0 KR LICENSKOSTNAD).",
            "lv": "Attēlots Dev Hub pārskatu kartītēs (-85% DĪKSTĀVES, 1-KLIKŠĶA STARTS, 0€ LICENCES).",
            "lt": "Rodoma Dev Hub skaidrių kortelėse (-85% PRASTOVŲ, 1 PASPAUDIMO STARTAS, 0€ LICENCIJŲ)."
        },
        "links": [
            {"label": "docs/dev-hub.html", "url": "docs/dev-hub.html"}
        ]
    },
    {
        "acronym": "LF",
        "expansion": "Line Feed (\\n)",
        "category": "os",
        "ref_url": "https://en.wikipedia.org/wiki/Newline",
        "ref_title": "Wikipedia: Newline (LF)",
        "def": {
            "en": "Standard Unix/Linux single-byte newline character required by POSIX shell interpreters.",
            "et": "Standardne Unix/Linux ühebaidine reavahetuse märk, mida nõuavad POSIX shelli interpretaatorid.",
            "fi": "Unix/Linux-standardin mukainen yhden tavun rivinvaihtomerkki shell-tulkeille.",
            "sv": "Unix/Linux standardtecken för radbrytning som krävs av POSIX shell-tolkar.",
            "lv": "Unix/Linux standarta rindiņas beigu rakstzīme, kas nepieciešama POSIX interpretatoriem.",
            "lt": "Unix/Linux standartinis vieno baito eilutės pabaigos simbolis, būtinas POSIX skriptams."
        },
        "project_role": {
            "en": "Mandated by Rule 14 across all .sh, .sql, .yaml, .json, and .md files via .gitattributes repository enforcement.",
            "et": "Kohustuslik vastavalt Reeglile 14 kõigis .sh, .sql, .yaml, .json ja .md failides läbi .gitattributes reeglite.",
            "fi": "Pakollinen Säännön 14 mukaan kaikissa .sh, .sql ja .yaml -tiedostoissa .gitattributes-määrityksellä.",
            "sv": "Obligatoriskt enligt Regel 14 över alla skript- och konfigurationsfiler via .gitattributes.",
            "lv": "Obligāts atbilstoši 14. noteikumam visos repozitorija skriptu un konfigurācijas failos.",
            "lt": "Privalomas pagal 14 taisyklę visiems skriptų ir konfigūracijų failams per .gitattributes."
        },
        "links": [
            {"label": ".gitattributes", "url": ".gitattributes"}
        ]
    },
    {
        "acronym": "LIS",
        "expansion": "Laboratory Information System",
        "category": "app",
        "ref_url": "https://en.wikipedia.org/wiki/Laboratory_information_management_system",
        "ref_title": "Wikipedia: LIS / LIMS",
        "def": {
            "en": "Enterprise software designed to manage healthcare laboratory sample workflows, instrument data, and test results.",
            "et": "Labori infosüsteem tervishoiuasutuste proovide, analüüside ja laboriseadmete andmevahetuse juhtimiseks.",
            "fi": "Laboratoriotietojärjestelmä näytteiden käsittelyyn, laiteintegraatioihin ja analyysituloksiin.",
            "sv": "Laboratorieinformationssystem för hantering av prover, instrument och analysresultat.",
            "lv": "Laboratorijas informācijas sistēma paraugu un analīžu rezultātu pārvaldībai.",
            "lt": "Laboratorinė informacinė sistema mėginių, tyrimų ir analizių duomenims valdyti."
        },
        "project_role": {
            "en": "Demonstrated in Blueprint 3 (Multi-DB with separate db-proxy, db-alise, and db-lis instances) showing schema isolation.",
            "et": "Demonstreeritud Blueprint 3-s (eraldi db-proxy, db-alise ja db-lis baasidega) näidates skeemide isoleeritust.",
            "fi": "Käytössä Blueprint 3 -monikantamallissa (db-proxy, db-alise ja db-lis) eristäen tietokannat.",
            "sv": "Demonstreras i Blueprint 3 med isolerade instanser för proxy, alise och lis.",
            "lv": "Attēlots Blueprint 3 ar atsevišķām proxy, alise un lis datubāzēm.",
            "lt": "Demonstruojama Blueprint 3 su atskiromis proxy, alise ir lis duomenų bazėmis."
        },
        "links": [
            {"label": "config/blueprints/.env.bp3-multi-db-lis", "url": "config/blueprints/.env.bp3-multi-db-lis"},
            {"label": "config/profiles/databases/db-lis.yaml", "url": "config/profiles/databases/db-lis.yaml"}
        ]
    },
    {
        "acronym": "mTLS",
        "expansion": "Mutual Transport Layer Security",
        "category": "security",
        "ref_url": "https://en.wikipedia.org/wiki/Mutual_authentication#mTLS",
        "ref_title": "Wikipedia: Mutual TLS",
        "def": {
            "en": "Two-way cryptographic authentication where both client and server verify each other's digital certificates.",
            "et": "Kahesuunaline krüptograafiline autentimine, kus nii klient kui ka server kontrollivad vastastikku digisertifikaate.",
            "fi": "Kaksisuuntainen TLS-autentikointi, jossa sekä asiakas että palvelin todentavat toisensa varmenteilla.",
            "sv": "Tvåvägs kryptografisk autentisering där både klient och server verifierar varandras certifikat.",
            "lv": "Abpusēja kriptogrāfiskā autentifikācija, kur klients un serveris pārbauda viens otra sertifikātus.",
            "lt": "Dvipusis kriptografinis autentifikavimas, kai klientas ir serveris tikrina vienas kito sertifikatus."
        },
        "project_role": {
            "en": "Powers secure cloud bridging to OCI Autonomous Database (cwallet.sso) without opening unencrypted internet ports.",
            "et": "Võimaldab turvalist pilveühendust OCI Autonomous Database'i (cwallet.sso) ilma avatud krüpteerimata portideta.",
            "fi": "Mahdollistaa turvallisen yhteyden OCI Autonomous Databaseen lompakon (cwallet.sso) kautta.",
            "sv": "Möjliggör säker molnanslutning till OCI Autonomous Database via wallet utan osäkra portar.",
            "lv": "Nodrošina drošu savienojumu ar OCI Autonomous Database mākonī caur šifrētu maku.",
            "lt": "Užtikrina saugų ryšį su OCI Autonomous Database debesyje per šifruotą piniginę."
        },
        "links": [
            {"label": "docs/remote-multicloud-setup-guide.md", "url": "docs/remote-multicloud-setup-guide.md"}
        ]
    },
    {
        "acronym": "noVNC",
        "expansion": "HTML5 VNC Client (WebSocket)",
        "category": "web",
        "ref_url": "https://novnc.com/",
        "ref_title": "Official: noVNC",
        "def": {
            "en": "Browser-based VNC client written in HTML5 and JavaScript using WebSockets to access graphical desktops remotely.",
            "et": "Brauseripõhine VNC klient (HTML5 & WebSockets), mis võimaldab kasutada graafilisi töölauarakendusi veebi vahendusel.",
            "fi": "Selainpohjainen HTML5 VNC -asiakasohjelma graafisten työpöytäsovellusten etäkäyttöön ilman lisäosia.",
            "sv": "Webbläsarbaserad HTML5 VNC-klient för direkt fjärråtkomst till grafiska skrivbordsmiljöer.",
            "lv": "Pārlūkprogrammas HTML5 VNC klients attālai grafisko darbvirsmu izmantošanai.",
            "lt": "Naršyklėje veikiantis HTML5 VNC klientas nuotoliniam grafinių darbalaukių valdymui."
        },
        "project_role": {
            "en": "Delivers zero-install Oracle Forms Builder (port 6082) and BIP Desktop Designer (port 6083) directly in Chrome/Edge.",
            "et": "Võimaldab kasutada Oracle Forms Builderit (port 6082) ja BIP Publisher Designerit (port 6083) otse veebibrauseris.",
            "fi": "Tuo Oracle Forms Builderin (portti 6082) ja Publisher Designerin (6083) suoraan selaimeen ilman asennusta.",
            "sv": "Ger direkt åtkomst till Oracle Forms Builder (port 6082) och Publisher Designer (port 6083) i webbläsaren.",
            "lv": "Nodrošina tūlītēju piekļuvi Forms Builder (ports 6082) un Publisher Designer (6083) tieši pārlūkā.",
            "lt": "Suteikia prieigą prie Forms Builder (prievadas 6082) ir Publisher Designer (6083) tiesiai naršyklėje."
        },
        "links": [
            {"label": "docs/forms-setup.md", "url": "docs/forms-setup.md"},
            {"label": "docs/publisher-template-builder-guide.md", "url": "docs/publisher-template-builder-guide.md"}
        ]
    },
    {
        "acronym": "OCI",
        "expansion": "Oracle Cloud Infrastructure",
        "category": "cloud",
        "ref_url": "https://en.wikipedia.org/wiki/Oracle_Cloud",
        "ref_title": "Wikipedia: Oracle Cloud Infrastructure",
        "def": {
            "en": "Oracle's broad enterprise public cloud platform offering computing, storage, networking, and managed databases.",
            "et": "Oracle avalik pilveplatvorm, mis pakub servereid, andmesalvestust, võrguteenuseid ja hallatud andmebaase.",
            "fi": "Oraclen yritystason julkipilvialusta laskennalle, tallennukselle ja hallinnoiduille tietokannoille.",
            "sv": "Oracles molninfrastruktur för servrar, lagring, nätverk och autonoma databaser.",
            "lv": "Oracle uzņēmuma līmeņa mākoņa infrastruktūra skaitļošanai un datubāzēm.",
            "lt": "Oracle viešoji debesų platforma serveriams, saugykloms ir duomenų bazėms."
        },
        "project_role": {
            "en": "Target cloud platform for automated deployments via scripts/deploy-remote.sh and hybrid blueprints (BP 10 & 11).",
            "et": "Sihtplatvorm pilvepaigaldusele käsuga scripts/deploy-remote.sh ja hübriidsetele blueprintidele (BP 10 & 11).",
            "fi": "Kohdealusta pilvijulkaisuille skriptillä scripts/deploy-remote.sh ja hybridi-blueprinteille (BP 10 & 11).",
            "sv": "Målplattform för molndistribution via scripts/deploy-remote.sh och hybridmodeller (BP 10 & 11).",
            "lv": "Mērķa mākonis automatizētai izvietošanai un hibrīdajiem blueprintiem (BP 10 un 11).",
            "lt": "Tikslinė debesų platforma diegimui per scripts/deploy-remote.sh ir hibridinius modelius (BP 10 ir 11)."
        },
        "links": [
            {"label": "scripts/deploy-remote.sh", "url": "scripts/deploy-remote.sh"},
            {"label": "docs/remote-multicloud-setup-guide.md", "url": "docs/remote-multicloud-setup-guide.md"}
        ]
    },
    {
        "acronym": "OCR",
        "expansion": "Oracle Container Registry",
        "category": "devops",
        "ref_url": "https://container-registry.oracle.com/",
        "ref_title": "Official: Oracle Container Registry",
        "def": {
            "en": "Oracle's official container image registry (container-registry.oracle.com) hosting verified database and middleware images.",
            "et": "Oracle ametlik konteineritõmmiste register (container-registry.oracle.com), mis hoiab kontrollitud baaside ja vahevara pilte.",
            "fi": "Oraclen virallinen konttirekisteri luotetuille tietokanta- ja väliohjelmistokuville.",
            "sv": "Oracles officiella containerregister för verifierade databas- och mellanprogramvaru-images.",
            "lv": "Oracle oficiālais konteineru reģistrs pārbaudītiem datubāzu un starpprogrammatūras attēliem.",
            "lt": "Oficialus Oracle konteinerių registras patvirtintiems DB ir tarpinės įrangos atvaizdams."
        },
        "project_role": {
            "en": "Source for official 23ai Free DB and ORDS images; supports enterprise Artifactory mirrors via REGISTRY_MIRROR config.",
            "et": "Ametlike 23ai Free DB ja ORDS tõmmiste allikas; toetab sisevõrgu Artifactory peeglit REGISTRY_MIRROR kaudu.",
            "fi": "Virallisten 23ai Free DB ja ORDS -kuvien lähde; tukee yrityksen Artifactory-peiliä REGISTRY_MIRROR-muuttujalla.",
            "sv": "Källa för 23ai Free DB och ORDS; stöder Artifactory-speglar via REGISTRY_MIRROR.",
            "lv": "Avots oficiālajiem 23ai Free DB attēliem; atbalsta korporatīvos Artifactory spoguļus.",
            "lt": "Šaltinis 23ai Free DB atvaizdams; palaiko įmonės Artifactory veidrodžius per REGISTRY_MIRROR."
        },
        "links": [
            {"label": "docs/enterprise-onboarding-guide.md", "url": "docs/enterprise-onboarding-guide.md"}
        ]
    },
    {
        "acronym": "OPatch",
        "expansion": "Oracle Interim Patching Tool",
        "category": "tools",
        "ref_url": "https://docs.oracle.com/en/database/oracle/oracle-database/19/install-and-upgrade.html",
        "ref_title": "Oracle Database Patching & Upgrade",
        "def": {
            "en": "Standard Oracle utility used to apply, rollback, and inspect official interim bug fixes and security patches.",
            "et": "Oracle standardtööriist ametlike vaheturvapaikade ja paranduste paigaldamiseks, kontrolliks ja tagasipööramiseks.",
            "fi": "Oraclen virallinen työkalu tietoturva- ja korjauspäivitysten asentamiseen ja hallintaan.",
            "sv": "Oracles standardverktyg för att applicera och rulla tillbaka officiella programvarupatchar.",
            "lv": "Oracle standarta rīks drošības labojumu uzstādīšanai un pārvaldībai.",
            "lt": "Standartinis Oracle įrankis saugumo pataisų diegimui ir valdymui."
        },
        "project_role": {
            "en": "Automated in scripts/internal/install-publisher.sh to patch Analytics Publisher without manual intervention.",
            "et": "Automatiseeritud skriptis scripts/internal/install-publisher.sh Analytics Publisheri paranduste paigaldamiseks.",
            "fi": "Automatisoitu Publisher-asennuksessa päivitysten viemiseksi suoraan konttiin.",
            "sv": "Automatiserat i Publisher-installationsskript för hands-free uppdateringar.",
            "lv": "Automatizēts Publisher skriptos drošības ielāpu uzstādīšanai.",
            "lt": "Automatizuota Publisher skriptuose saugumo pataisų diegimui."
        },
        "links": [
            {"label": "docs/publisher-setup.md", "url": "docs/publisher-setup.md"}
        ]
    },
    {
        "acronym": "ORDS",
        "expansion": "Oracle REST Data Services",
        "category": "middleware",
        "ref_url": "https://www.oracle.com/database/technologies/appdev/rest.html",
        "ref_title": "Oracle REST Data Services",
        "def": {
            "en": "Java EE application server bridge that turns SQL and PL/SQL into secure RESTful APIs and serves APEX applications.",
            "et": "Java vaheserver, mis teisendab SQL ja PL/SQL koodi turvalisteks REST API-deks ning teenindab APEX veebirakendusi.",
            "fi": "Sovelluspalvelinsilta, joka muuntaa SQL/PLSQL-koodin REST-rajapinnoiksi ja jakelee APEX-sovellukset.",
            "sv": "Mellanprogramvara som exponerar SQL/PLSQL som RESTful API:er och levererar APEX-webbsidor.",
            "lv": "Lietojumprogrammu servera tilts, kas pārvērš SQL/PLSQL par REST API un apkalpo APEX.",
            "lt": "Tarpinė programinė įranga, paverčianti SQL/PLSQL į REST API ir teikianti APEX sąsają."
        },
        "project_role": {
            "en": "Core API gateway on port 8088/8448; configured in standalone mode (BP 5 & 10) to eliminate database memory consumption.",
            "et": "Peamine API värav pordil 8088/8448; seadistatud eraldiseisvana (BP 5 & 10), et säästa andmebaasi väärtuslikku operatiivmälu.",
            "fi": "Keskeinen API-yhdyskäytävä portissa 8088/8448; ajetaan erillään tietokannan muistin säästämiseksi.",
            "sv": "Huvudsaklig API-gateway på port 8088/8448; körs fristående (BP 5 & 10) för att spara databasminne.",
            "lv": "Galvenā API vārteja portā 8088/8448; darbojas atsevišķi, lai taupītu datubāzes atmiņu.",
            "lt": "Pagrindiniai API vartai prievade 8088/8448; veikia atskirai DB operatyviajai atminčiai taupyti."
        },
        "links": [
            {"label": "docs/ords-profiles-lifecycle.md", "url": "docs/ords-profiles-lifecycle.md"},
            {"label": "scripts/internal/install-ords-standalone.sh", "url": "scripts/internal/install-ords-standalone.sh"}
        ]
    },
    {
        "acronym": "PDB",
        "expansion": "Pluggable Database",
        "category": "database",
        "ref_url": "https://docs.oracle.com/en/database/oracle/oracle-database/23/cncpt/multitenant-architecture.html",
        "ref_title": "Oracle Pluggable Database (PDB)",
        "def": {
            "en": "A self-contained collection of schemas, schema objects, and non-schema objects that appears as a dedicated database.",
            "et": "Isehaldav skeemide ja objektide kogum Oracle multitenant süsteemis, mis käitub nagu eraldiseisev andmebaas.",
            "fi": "Itsenäinen skeemojen ja objektien kokonaisuus, joka näkyy asiakkaille erillisenä tietokantana.",
            "sv": "Självgående databasinstans i Oracles multitenant-arkitektur som fungerar som en isolerad databas.",
            "lv": "Autonoma shēmu un objektu kopa multitenant arhitektūrā, kas darbojas kā atsevišķa datubāze.",
            "lt": "Autonominis schemų ir objektų rinkinys, veikiantis kaip atskira duomenų bazė."
        },
        "project_role": {
            "en": "Isolates application domains: FREEPDB1 (Proxy/APEX), ALISEPDB (Business Data), LIS_PDB, and BIP_PDB across blueprints.",
            "et": "Isoleerib domeenid: FREEPDB1 (Proxy/APEX), ALISEPDB (Äriandmed), LIS_PDB ja BIP_PDB vastavalt blueprintidele.",
            "fi": "Eristää sovellusalueet: FREEPDB1 (Proxy/APEX), ALISEPDB (Liiketoimintadata), LIS_PDB jne.",
            "sv": "Isolerar applikationsdomäner: FREEPDB1 (Proxy), ALISEPDB (Affärsdata), LIS_PDB och BIP_PDB.",
            "lv": "Izolē lietojumu datus: FREEPDB1 (APEX), ALISEPDB (bizness), LIS_PDB un BIP_PDB.",
            "lt": "Izoliuoja sritis: FREEPDB1 (APEX), ALISEPDB (verslas), LIS_PDB ir BIP_PDB pagal modelius."
        },
        "links": [
            {"label": "docs/db-profiles-and-topology.md", "url": "docs/db-profiles-and-topology.md"},
            {"label": "scripts/internal/resolve-topology.sh", "url": "scripts/internal/resolve-topology.sh"}
        ]
    },
    {
        "acronym": "PID",
        "expansion": "Process Identifier",
        "category": "os",
        "ref_url": "https://en.wikipedia.org/wiki/Process_identifier",
        "ref_title": "Wikipedia: Process Identifier (PID)",
        "def": {
            "en": "A unique numeric identifier assigned by an operating system kernel to each running process.",
            "et": "Unikaalne numbriline identifikaator, mille operatsioonisüsteemi tuum omistab igale töötavale protsessile.",
            "fi": "Käyttöjärjestelmän kullekin käynnissä olevalle prosessille myöntämä yksilöllinen tunniste.",
            "sv": "Unik numerisk identifierare som operativsystemet tilldelar varje aktiv process.",
            "lv": "Unikāls identifikators, ko operētājsistēma piešķir katram aktīvajam procesam.",
            "lt": "Unikalus skaitmeninis identifikatorius, kurį operacinė sistema suteikia kiekvienam procesui."
        },
        "project_role": {
            "en": "Tracked by Dev Hub Bridge and task runners to ensure asynchronous background lifecycle control (Rule 12).",
            "et": "Jälgitav Dev Hubi ja taustatööde mootori poolt asünkroonseks protsessijuhtimiseks (Reegel 12).",
            "fi": "Käytössä taustaprosessien valvonnassa ja tehtävien hallinnassa (Sääntö 12).",
            "sv": "Spåras av Dev Hub för asynkron bakgrundskörning och processkontroll (Regel 12).",
            "lv": "Tiek uzraudzīts asinhronu uzdevumu vadībai un fonu procesiem (12. noteikums).",
            "lt": "Sekamas asinchroninių procesų valdymui ir foninėms užduotims (12 taisyklė)."
        },
        "links": [
            {"label": "scripts/internal/dev-hub-bridge.py", "url": "scripts/internal/dev-hub-bridge.py"}
        ]
    },
    {
        "acronym": "RAM",
        "expansion": "Random Access Memory",
        "category": "hardware",
        "ref_url": "https://en.wikipedia.org/wiki/Random-access_memory",
        "ref_title": "Wikipedia: RAM",
        "def": {
            "en": "High-speed volatile computer data storage used by active applications, operating system kernels, and buffers.",
            "et": "Arvuti kiire operatiivmälu, mida kasutavad aktiivsed programmid, andmebaasi puhvrid ja operatsioonisüsteem.",
            "fi": "Tietokoneen nopea keskusmuisti käynnissä oleville ohjelmille ja tietokantapuskureille.",
            "sv": "Datorns arbetsminne för aktiva program, operativsystem och databasbuffertar.",
            "lv": "Operatīvā atmiņa aktīvām programmām un datubāzes kešatmiņām.",
            "lt": "Operatyvioji kompiuterio atmintis aktyvioms programoms ir DB buferiams."
        },
        "project_role": {
            "en": "23ai Free DB has a hard limit of 2GB RAM; platform's decoupled architecture prevents memory starvation.",
            "et": "23ai Free DB-l on range 2GB RAM piirang; lahtisidestatud kihtidega arhitektuur hoiab süsteemi stabiilse.",
            "fi": "23ai Free DB:ssä on 2GB RAM -rajoitus; jaettu arkkitehtuuri estää muistin loppumisen.",
            "sv": "23ai Free DB har en hård gräns på 2GB RAM; modulär arkitektur förhindrar minnesbrist.",
            "lv": "23ai Free DB ir 2GB RAM limits; sadalītā arhitektūra novērš atmiņas pārslodzi.",
            "lt": "23ai Free DB turi 2GB RAM ribą; atskirta architektūra apsaugo nuo atminties trūkumo."
        },
        "links": [
            {"label": "docs/enterprise-distributed-architecture.md", "url": "docs/enterprise-distributed-architecture.md"}
        ]
    },
    {
        "acronym": "RCU",
        "expansion": "Repository Creation Utility",
        "category": "middleware",
        "ref_url": "https://docs.oracle.com/en/middleware/fusion-middleware/12.2.1.4/rcuug/",
        "ref_title": "Oracle Repository Creation Utility Docs",
        "def": {
            "en": "Oracle utility used to create, configure, and drop database schemas required by Fusion Middleware components.",
            "et": "Oracle utiliit Fusion Middleware vahevara (Forms, WebLogic, Publisher) vajalike andmebaasiskeemide loomiseks.",
            "fi": "Oraclen työkalu Fusion Middleware -tuotteiden tarvitsemien tietokantaskeemoja luontiin.",
            "sv": "Oracle-verktyg för att skapa och konfigurera databasscheman för Fusion Middleware.",
            "lv": "Oracle rīks Fusion Middleware nepieciešamo datubāzes shēmu izveidei.",
            "lt": "Oracle įrankis Fusion Middleware reikalingų duomenų bazės schemų kūrimui."
        },
        "project_role": {
            "en": "Automated silently in headless containers for Forms 14c and Analytics Publisher initialization.",
            "et": "Automatiseeritud taustal konteinerites Forms 14c ja Analytics Publisheri skeemide ettevalmistamiseks.",
            "fi": "Automatisoitu Forms 14c ja Publisher -skeemojen alustukseen ilman manuaalisia vaiheita.",
            "sv": "Automatiseras tyst i containrar för att initiera scheman för Forms och Publisher.",
            "lv": "Automatizēts konteineros Forms un Publisher shēmu sagatavošanai.",
            "lt": "Automatizuota konteineriuose Forms ir Publisher schemų paruošimui."
        },
        "links": [
            {"label": "docs/forms-setup.md", "url": "docs/forms-setup.md"}
        ]
    },
    {
        "acronym": "REST",
        "expansion": "Representational State Transfer",
        "category": "web",
        "ref_url": "https://en.wikipedia.org/wiki/REST",
        "ref_title": "Wikipedia: REST",
        "def": {
            "en": "Stateless, standard HTTP architectural design pattern for building decoupled, scalable web services and APIs.",
            "et": "Olekuvaba veebiarhitektuuri standard hajutatud, skaleeritavate veebiteenuste ja API-de ehitamiseks üle HTTP.",
            "fi": "Tilaton arkkitehtuurimalli hajautettujen verkkopalveluiden ja rajapintojen rakentamiseen HTTP:n yli.",
            "sv": "Tillståndslös arkitekturmodell för att bygga skalbara webbtjänster och API:er över HTTP.",
            "lv": "Stāvokli nesaglabājoša tīmekļa arhitektūra mērogojamu API izveidei caur HTTP.",
            "lt": "Būsenos nesaugantis saityno architektūros modelis keitimuisi duomenimis per HTTP."
        },
        "project_role": {
            "en": "Delivered natively via ORDS AutoREST, connecting APEX, external microservices, and Dev Hub without database drivers.",
            "et": "Tagatud ORDS AutoREST-i kaudu, sidudes APEX-i, välised mikroteenused ja Dev Hubi ilma spetsiaalsete draiveriteta.",
            "fi": "Toteutettu ORDS AutoREST -toiminnolla yhdistäen palvelut ilman raskaita tietokanta-ajureita.",
            "sv": "Levereras via ORDS AutoREST och ansluter mikrotjänster och Dev Hub utan databasdrivrutiner.",
            "lv": "Realizēts ar ORDS AutoREST palīdzību ārējiem pakalpojumiem un mikroservisiem.",
            "lt": "Realizuota per ORDS AutoREST sujungiant mikropaslaugas be specialių tvarkyklių."
        },
        "links": [
            {"label": "docs/ords-profiles-lifecycle.md", "url": "docs/ords-profiles-lifecycle.md"}
        ]
    },
    {
        "acronym": "ROI",
        "expansion": "Return on Investment",
        "category": "business",
        "ref_url": "https://en.wikipedia.org/wiki/Return_on_investment",
        "ref_title": "Wikipedia: Return on Investment",
        "def": {
            "en": "Financial performance metric measuring the profitability or efficiency gained relative to an investment cost.",
            "et": "Majanduslik tulemuslikkuse mõõdik, mis näitab tehtud investeeringu tasuvust ja rahalist/ajalist säästu.",
            "fi": "Taloudellinen mittari, joka arvioi tehdyn sijoituksen tuottavuutta ja tehokkuutta suhteessa kustannuksiin.",
            "sv": "Finansiellt nyckeltal för att mäta lönsamhet och effektivitet i förhållande till investeringskostnad.",
            "lv": "Finanšu rādītājs investīciju atdeves un izmaksu ietaupījuma novērtēšanai.",
            "lt": "Finansinis rodiklis investicijų grąžai ir sąnaudų sutaupymui įvertinti."
        },
        "project_role": {
            "en": "Highlighted in Slide 5: saving up to 40% Oracle dev licensing costs and eliminating idle cloud cloud hosting fees.",
            "et": "Rõhutatud Dev Hubi slaidil 5: säästab kuni 40% arenduslitsentsidelt ja kaotab tühja seisvate pilveserverite arved.",
            "fi": "Korostettu diassa 5: säästää jopa 40% kehityslisenssikuluista poistaen turhat pilvimaksut.",
            "sv": "Framhävt i bild 5: sparar upp till 40% av utvecklingslicenser och eliminerar onödiga molnkostnader.",
            "lv": "Izcelts 5. slaidā: ietaupa līdz 40% izstrādes licenču izmaksu un novērš dīkstāves mākoņa rēķinus.",
            "lt": "Akcentuota 5 skaidrėje: sutaupo iki 40% kūrimo licencijų ir panaikina nenaudojamų debesų sąskaitas."
        },
        "links": [
            {"label": "docs/dev-hub.html", "url": "docs/dev-hub.html"}
        ]
    },
    {
        "acronym": "SDW",
        "expansion": "SQL Developer Web (Database Actions)",
        "category": "tools",
        "ref_url": "https://docs.oracle.com/en/database/oracle/sql-developer-web/",
        "ref_title": "Oracle SQL Developer Web",
        "def": {
            "en": "Browser-based management interface provided by ORDS for executing SQL, data modeling, REST services, and monitoring.",
            "et": "ORDS-i sisseehitatud veebipõhine töölaud SQL päringute, andmemudelite, REST teenuste ja seire haldamiseks.",
            "fi": "ORDS-palvelun selainpohjainen käyttöliittymä SQL-kyselyille, REST-määrityksille ja tietokannan valvonnalle.",
            "sv": "Webbläsarbaserat gränssnitt i ORDS för att köra SQL, bygga REST-tjänster och övervaka databasen.",
            "lv": "Pārlūka saskarne ORDS ietvaros SQL vaicājumiem, REST pakalpojumiem un uzraudzībai.",
            "lt": "Naršyklės sąsaja ORDS sistemoje SQL užklausoms, REST paslaugoms ir stebėsenai."
        },
        "project_role": {
            "en": "Accessible via Dev Hub 1-click links for DBA_ADMIN, PROXY_DEV, and ALISE_DEV with auto-copied credentials.",
            "et": "Kättesaadav Dev Hubi 1-kliki linkidest DBA_ADMIN, PROXY_DEV ja ALISE_DEV kasutajatele koos parooli kopeerimisega.",
            "fi": "Käytettävissä Dev Hubista yhdellä klikkauksella DBA-, PROXY- ja ALISE-käyttäjille automaattikopioinnilla.",
            "sv": "Tillgängligt via ett klick i Dev Hub med automatisk lösenordshjälp för DBA_ADMIN och utvecklare.",
            "lv": "Pieejams ar 1 klikšķi no Dev Hub ar automātisku akreditācijas datu sagatavošanu.",
            "lt": "Pasiekiamas 1 paspaudimu iš Dev Hub su automatiniu slaptažodžio nukopijavimu."
        },
        "links": [
            {"label": "docs/quick-login-guide.md", "url": "docs/quick-login-guide.md"}
        ]
    },
    {
        "acronym": "SEPS",
        "expansion": "Secure External Password Store (Oracle Wallet)",
        "category": "security",
        "ref_url": "https://docs.oracle.com/en/database/oracle/oracle-database/19/dbseg/",
        "ref_title": "Oracle Database Security Guide",
        "def": {
            "en": "Oracle's AES-256 encrypted auto-login wallet store (cwallet.sso) that enables passwordless client authentication.",
            "et": "Oracle krüpteeritud paroolihoidla (cwallet.sso / ewallet.p12), mis võimaldab paroolivaba klientautentimist.",
            "fi": "Oraclen AES-256-salattu lompakko (cwallet.sso), joka mahdollistaa salasanattoman todennuksen.",
            "sv": "Oracles krypterade plånbok (cwallet.sso) som möjliggör lösenordsfri klientautentisering.",
            "lv": "Oracle šifrēts maks (cwallet.sso) drošai bezparoļu autentifikācijai.",
            "lt": "Oracle šifruota piniginė (cwallet.sso) saugiam prisijungimui be slaptažodžių."
        },
        "project_role": {
            "en": "Mandated by Rule 5: 0 plaintext passwords on disk; all CLI scripts (sqlcl.sh /@ALIAS) authenticate via SEPS wallet.",
            "et": "Kohustuslik vastavalt Reeglile 5: kettal 0 parooli; kõik skriptid (sqlcl.sh /@ALIAS) autendivad SEPS walleti abil.",
            "fi": "Pakollinen Säännön 5 mukaan: nolla selväkielistä salasanaa; kaikki skriptit käyttävät SEPS-lompakkoa.",
            "sv": "Strikt enligt Regel 5: noll lösenord i klartext; all CLI-autentisering sker via SEPS-plånboken.",
            "lv": "Obligāts atbilstoši 5. noteikumam: neviena parole atklātā tekstā; visi skripti izmanto SEPS maku.",
            "lt": "Privalomas pagal 5 taisyklę: jokių slaptažodžių tekstu; visi skriptai jungiasi per SEPS piniginę."
        },
        "links": [
            {"label": "docs/security.md", "url": "docs/security.md"},
            {"label": "scripts/get-password.sh", "url": "scripts/get-password.sh"},
            {"label": "scripts/check-wallet.sh", "url": "scripts/check-wallet.sh"}
        ]
    },
    {
        "acronym": "SGA / PGA",
        "expansion": "System Global Area / Program Global Area",
        "category": "database",
        "ref_url": "https://en.wikipedia.org/wiki/Oracle_Database#Memory_structures",
        "ref_title": "Wikipedia: Oracle Database Memory Architecture",
        "def": {
            "en": "Oracle database memory architectures: SGA is shared across all processes, PGA is dedicated to individual server processes.",
            "et": "Oracle andmebaasi mälustruktuurid: SGA on jagatud puhvrite mälu, PGA on igale serveriprotsessile eraldatud mälu.",
            "fi": "Oraclen keskeiset muistirakenteet: SGA jaettuna kaikille prosesseille ja PGA palvelinprosessikohtaisena.",
            "sv": "Oracles minnesstrukturer: SGA delas mellan alla processer, PGA är dedikerat per serverprocess.",
            "lv": "Oracle atmiņas struktūras: SGA ir koplietojama atmiņa, PGA ir procesam piesaistīta atmiņa.",
            "lt": "Oracle atminties struktūros: SGA yra bendra visiems procesams, PGA skirta atskiram procesui."
        },
        "project_role": {
            "en": "Dynamically tuned in init-db-instance.sql so combined memory strictly fits within the 2GB Free DB container boundary.",
            "et": "Dünaamiliselt häälestatud init-db-instance.sql skriptis, et kogumaht mahuks täpselt 2GB Free DB konteineri sisse.",
            "fi": "Hienosäädetty automaattisesti siten, että kokonaismuisti pysyy 2GB Free DB -rajoissa.",
            "sv": "Dynamiskt konfigurerat för att garantera att minnesanvändningen ryms inom 2GB i containern.",
            "lv": "Dinamiski noregulēts, lai iekļautos Free DB 2GB konteinera robežās.",
            "lt": "Dinamiškai suderinta, kad bendra atmintis neviršytų 2GB Free DB konteinerio ribos."
        },
        "links": [
            {"label": "scripts/internal/init-db-instance.sql", "url": "scripts/internal/init-db-instance.sql"}
        ]
    },
    {
        "acronym": "SPA",
        "expansion": "Single Page Application",
        "category": "web",
        "ref_url": "https://en.wikipedia.org/wiki/Single-page_application",
        "ref_title": "Wikipedia: Single-Page Application",
        "def": {
            "en": "A web application that interacts with the user by dynamically rewriting the current web page rather than loading entire new pages.",
            "et": "Üheleheline veebirakendus, mis uuendab sisu dünaamiliselt brauseri mälus ilma terveid lehti uuesti laadimata.",
            "fi": "Yhden sivun verkkosovellus, joka päivittää näkymää dynaamisesti lataamatta koko sivua uudelleen.",
            "sv": "Ensidesapplikation som dynamiskt uppdaterar innehållet utan att ladda om hela sidan.",
            "lv": "Vienas lapas tīmekļa lietotne, kas atjaunina saturu dinamiski bez visas lapas pārlādes.",
            "lt": "Vieno puslapio programa, dinamiškai atnaujinanti turinį be viso puslapio perkrovimo."
        },
        "project_role": {
            "en": "Architecture of Dev Hub (docs/dev-hub.html): 100% standalone, zero CDN dependencies, instant tab navigation.",
            "et": "Dev Hubi (docs/dev-hub.html) arhitektuur: 100% iseseisev, ilma väliste CDN sõltuvusteta, kohene vahelehtede vahetus.",
            "fi": "Dev Hubin arkkitehtuuri: täysin itsenäinen, ei ulkoisia CDN-riippuvuuksia, välitön välilehtien vaihto.",
            "sv": "Dev Hubs arkitektur: 100% fristående, inga externa CDN-beroenden, blixtsnabb navigering.",
            "lv": "Dev Hub arhitektūra: pilnībā autonoma, bez CDN atkarībām, tūlītēja ciļņu pārslēgšana.",
            "lt": "Dev Hub architektūra: visiškai autonomiška, be CDN priklausomybių, momentinis naršymas."
        },
        "links": [
            {"label": "docs/dev-hub.html", "url": "docs/dev-hub.html"}
        ]
    },
    {
        "acronym": "SPFILE",
        "expansion": "Server Parameter File",
        "category": "database",
        "ref_url": "https://en.wikipedia.org/wiki/Oracle_Database#Initialization_parameters",
        "ref_title": "Wikipedia: Oracle Initialization Parameters",
        "def": {
            "en": "Binary server parameter initialization file maintained on the database server across instance restarts.",
            "et": "Oracle andmebaasi binaarne parameetrifail, mis säilitab konfiguratsioonimuudatused üle andmebaasi taaskäivituste.",
            "fi": "Oraclen binaarinen parametritiedosto, joka säilyttää asetukset tietokannan uudelleenkäynnistysten yli.",
            "sv": "Binär parameterfil som bevarar databasens konfigurationsändringar över omstarter.",
            "lv": "Oracle binārais parametru fails, kas saglabā konfigurācijas izmaiņas pēc restartēšanas.",
            "lt": "Binarinis parametrų failas, išsaugantis DB nustatymus po perkrovimo."
        },
        "project_role": {
            "en": "Configured in container db-oracle to ensure optimal memory targets and APEX proxy authentication settings.",
            "et": "Konfigureeritud db-oracle konteineris mälupiirangute ja APEX proxy autentimise püsivaks määramiseks.",
            "fi": "Määritetty db-oracle-kontissa varmistamaan optimaaliset muistiasetukset ja APEX-välityksen.",
            "sv": "Konfigureras i databascontainern för att garantera optimal minnesallokering och APEX-stöd.",
            "lv": "Konfigurēts konteinerā, lai nodrošinātu atmiņas iestatījumus un APEX savienojumus.",
            "lt": "Sukonfigūruota DB konteineryje optimaliems atminties ir APEX nustatymams užtikrinti."
        },
        "links": [
            {"label": "scripts/internal/init-db-instance.sh", "url": "scripts/internal/init-db-instance.sh"}
        ]
    },
    {
        "acronym": "SQL",
        "expansion": "Structured Query Language",
        "category": "database",
        "ref_url": "https://en.wikipedia.org/wiki/SQL",
        "ref_title": "Wikipedia: SQL",
        "def": {
            "en": "Domain-specific standard language for managing data held in a relational database management system.",
            "et": "Standardne päringukeel relatsioonilistes andmebaasides andmete haldamiseks ja pärimiseks.",
            "fi": "Standardi kyselykieli relaatiotietokantojen tietojen hallintaan ja kyselyihin.",
            "sv": "Standardiserat frågespråk för att hantera och söka data i relationsdatabaser.",
            "lv": "Standarta vaicājumu valoda relāciju datubāzu datu pārvaldībai.",
            "lt": "Standartinė užklausų kalba duomenų valdymui reliacinėse duomenų bazėse."
        },
        "project_role": {
            "en": "All platform schema setups, users, tablespaces, and grants executed via standard SQL files in scripts/internal/.",
            "et": "Kõik platvormi skeemid, kasutajad, tabeliruumid ja õigused paigaldatakse SQL failidega kaustast scripts/internal/.",
            "fi": "Kaikki skeemat, käyttäjät ja oikeudet ajetaan SQL-skripteillä scripts/internal/-hakemistosta.",
            "sv": "Alla scheman, användare och behörigheter skapas via SQL-filer i scripts/internal/.",
            "lv": "Visas shēmas, lietotāji un atļaujas tiek izveidotas ar SQL skriptiem mapē scripts/internal/.",
            "lt": "Visos schemos, vartotojai ir teisės diegiami per SQL failus aplanke scripts/internal/."
        },
        "links": [
            {"label": "scripts/internal/init-db-instance.sql", "url": "scripts/internal/init-db-instance.sql"}
        ]
    },
    {
        "acronym": "SQLcl",
        "expansion": "Oracle SQL Developer Command Line",
        "category": "tools",
        "ref_url": "https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/",
        "ref_title": "Oracle SQLcl Official",
        "def": {
            "en": "Modern Java/GraalVM-based command-line interface for Oracle Database featuring inline editing, Liquibase, and Git integration.",
            "et": "Kaasaegne Java/GraalVM-põhine käsureatööriist Oracle andmebaasile koos Liquibase'i, automaattäienduse ja Git toega.",
            "fi": "Moderni Oraclen komentorivityökalu inline-muokkauksella, Liquibase-tuella ja Git-integraatiolla.",
            "sv": "Modernt kommandoradsverktyg för Oracle Database med stöd för Liquibase och Git.",
            "lv": "Mūsdienīgs komandrindas rīks Oracle datubāzei ar Liquibase un Git integrāciju.",
            "lt": "Šiuolaikinis Oracle komandinės eilutės įrankis su Liquibase ir Git integracija."
        },
        "project_role": {
            "en": "Mandatory standard CLI per Rule 6 (legacy sqlplus strictly prohibited); auto-resolves VS Code extension binary.",
            "et": "Kohustuslik standard CLI vastavalt Reeglile 6 (sqlplus keelatud); kasutab eelisjärjekorras VS Code SQLcl binaari.",
            "fi": "Pakollinen standardi Säännön 6 mukaan (sqlplus kielletty); käyttää ensisijaisesti VS Coden SQLcl-binaaria.",
            "sv": "Obligatorisk standard enligt Regel 6 (legacy sqlplus förbjudet); prioriterar VS Coden SQLcl.",
            "lv": "Obligāts standarts saskaņā ar 6. noteikumu; prioritāri izmanto VS Code SQLcl bināro failu.",
            "lt": "Privalomas standartas pagal 6 taisyklę; pirmenybę teikia VS Code SQLcl programai."
        },
        "links": [
            {"label": "scripts/sqlcl.sh", "url": "scripts/sqlcl.sh"},
            {"label": "docs/quick-login-guide.md", "url": "docs/quick-login-guide.md"}
        ]
    },
    {
        "acronym": "SSO",
        "expansion": "Single Sign-On",
        "category": "security",
        "ref_url": "https://en.wikipedia.org/wiki/Single_sign-on",
        "ref_title": "Wikipedia: Single Sign-On",
        "def": {
            "en": "Authentication scheme that allows a user to log in with a single ID to any of several related, yet independent software systems.",
            "et": "Ühekordne sisselogimine, mis võimaldab kasutajal ühe identiteediga logida mitmesse seotud süsteemi ilma uuesti parooli sisestamata.",
            "fi": "Kertakirjautuminen, joka mahdollistaa pääsyn useisiin järjestelmiin yhdellä todennuksella.",
            "sv": "Enkel inloggning som ger användaren åtkomst till flera system med en enda inloggning.",
            "lv": "Vienotā pieteikšanās, kas ļauj piekļūt vairākām sistēmām ar vienu autentifikāciju.",
            "lt": "Vieningas prisijungimas, leidžiantis vienu prisijungimu pasiekti kelias sistemas."
        },
        "project_role": {
            "en": "Integrated for enterprise deployments with Azure Entra-ID, ORDS, and APEX authentication schemes.",
            "et": "Integreeritav ettevõtte keskkondades Azure Entra-ID, ORDS ja APEX autentimisskeemidega.",
            "fi": "Integroitu yrityskäytössä Azure Entra-ID-, ORDS- ja APEX-todennukseen.",
            "sv": "Integrerat för företagsmiljöer med Azure Entra-ID, ORDS och APEX.",
            "lv": "Integrēts korporatīvajās vidēs ar Azure Entra-ID un APEX.",
            "lt": "Integruota įmonių aplinkose su Azure Entra-ID ir APEX."
        },
        "links": [
            {"label": "tests/test-browser-login.sh", "url": "tests/test-browser-login.sh"}
        ]
    },
    {
        "acronym": "TCO",
        "expansion": "Total Cost of Ownership",
        "category": "business",
        "ref_url": "https://en.wikipedia.org/wiki/Total_cost_of_ownership",
        "ref_title": "Wikipedia: Total Cost of Ownership",
        "def": {
            "en": "Comprehensive assessment of information technology or other costs across social, hardware, software, and operational life.",
            "et": "Omamise kogukulu: terviklik finantsanalüüs, mis võtab arvesse litsentsid, taristu, halduse ja seisakute kulud.",
            "fi": "Kokonaiskustannusarvio, joka huomioi lisenssit, infrastruktuurin, ylläpidon ja seisokit.",
            "sv": "Total ägandekostnad som inkluderar licenser, infrastruktur, underhåll och driftstopp.",
            "lv": "Kopējās īpašumtiesību izmaksas, ieskaitot licences, uzturēšanu un dīkstāves.",
            "lt": "Bendra nuosavybės kaina, apimanti licencijas, infrastruktūrą ir priežiūrą."
        },
        "project_role": {
            "en": "Reduced dramatically by Oracle Free DB in Prod: 0€ license fees for development and internal tools.",
            "et": "Vähendatud märkimisväärselt tänu Free DB-le: arenduse ja sisetööriistade litsentsikulud on täpselt 0€.",
            "fi": "Pienenee dramaattisesti Free DB:n avulla: nollakulut kehitys- ja sisäisille työkaluille.",
            "sv": "Reducerat drastiskt med Free DB: noll licensavgifter för utveckling och interna verktyg.",
            "lv": "Būtiski samazināts ar Free DB: 0€ licenču maksas izstrādei un iekšējiem rīkiem.",
            "lt": "Reikšmingai sumažinta su Free DB: 0€ licencijų kaštai kūrimui ir vidiniams įrankiams."
        },
        "links": [
            {"label": "docs/dev-hub.html", "url": "docs/dev-hub.html"}
        ]
    },
    {
        "acronym": "TLS",
        "expansion": "Transport Layer Security",
        "category": "security",
        "ref_url": "https://en.wikipedia.org/wiki/Transport_Layer_Security",
        "ref_title": "Wikipedia: Transport Layer Security",
        "def": {
            "en": "Cryptographic protocol designed to provide end-to-end communications security over computer networks.",
            "et": "Krüptograafiline turvaprotokoll, mis tagab andmeside konfidentsiaalsuse ja tervikluse üle arvutivõrgu.",
            "fi": "Kryptografinen protokolla turvallisen ja salatun tiedonsiirron takaamiseksi tietoverkoissa.",
            "sv": "Kryptografiskt protokoll för att erbjuda säker och krypterad kommunikation över nätverk.",
            "lv": "Kriptogrāfisks protokols drošai un šifrētai datu pārraidei tīklā.",
            "lt": "Kriptografinis protokolas saugiam ir šifruotam duomenų perdavimui tinkle."
        },
        "project_role": {
            "en": "Generated locally via scripts/internal/generate-local-certs.sh for HTTPS on port 8448 and ORDS TLS termination.",
            "et": "Genereeritud lokaalselt skriptiga generate-local-certs.sh HTTPS-i jaoks pordil 8448 ja ORDS TLS lõpetamiseks.",
            "fi": "Luodaan paikallisesti skriptillä generate-local-certs.sh HTTPS-liikenteelle portissa 8448.",
            "sv": "Genereras lokalt för HTTPS på port 8448 och säker ORDS-anslutning.",
            "lv": "Ģenerēts lokāli HTTPS protokolam portā 8448 un ORDS šifrēšanai.",
            "lt": "Generuojama lokaliai HTTPS ryšiui prievade 8448 ir ORDS šifravimui."
        },
        "links": [
            {"label": "docs/security.md", "url": "docs/security.md"},
            {"label": "scripts/internal/generate-local-certs.sh", "url": "scripts/internal/generate-local-certs.sh"}
        ]
    },
    {
        "acronym": "TNS",
        "expansion": "Transparent Network Substrate",
        "category": "database",
        "ref_url": "https://en.wikipedia.org/wiki/Transparent_Network_Substrate",
        "ref_title": "Wikipedia: Transparent Network Substrate",
        "def": {
            "en": "Oracle's proprietary networking technology that enables peer-to-peer connectivity between clients and databases.",
            "et": "Oracle võrgutehnoloogia klientrakenduste ja andmebaaside vaheliseks ühenduse loomiseks (tnsnames.ora).",
            "fi": "Oraclen verkkoteknologia asiakassovellusten ja tietokantojen väliseen viestintään.",
            "sv": "Oracles nätverksteknologi för anslutning mellan klienter och databaser via tnsnames.ora.",
            "lv": "Oracle tīkla tehnoloģija klientu savienošanai ar datubāzēm.",
            "lt": "Oracle tinklo technologija klientų sujungimui su duomenų bazėmis."
        },
        "project_role": {
            "en": "Auto-configured in tnsnames/tnsnames.ora with aliases like FREEPDB1, ALISEPDB, and automatically exported via TNS_ADMIN.",
            "et": "Automaatselt seadistatud failis tnsnames/tnsnames.ora aliastena (FREEPDB1, ALISEPDB) ning eksporditud TNS_ADMIN abil.",
            "fi": "Määritetty automaattisesti tnsnames/tnsnames.ora -tiedostoon ja jaettu TNS_ADMIN-muuttujalla.",
            "sv": "Konfigureras automatiskt i tnsnames.ora och exporteras via TNS_ADMIN till alla terminaler.",
            "lv": "Automātiski konfigurēts tnsnames.ora failā un eksportēts ar TNS_ADMIN.",
            "lt": "Automatiškai sukonfigūruota tnsnames.ora faile ir eksportuota per TNS_ADMIN."
        },
        "links": [
            {"label": "tnsnames/tnsnames.ora", "url": "tnsnames/tnsnames.ora"},
            {"label": "scripts/register-connections.sh", "url": "scripts/register-connections.sh"}
        ]
    },
    {
        "acronym": "UAC",
        "expansion": "User Account Control",
        "category": "os",
        "ref_url": "https://en.wikipedia.org/wiki/User_Account_Control",
        "ref_title": "Wikipedia: User Account Control",
        "def": {
            "en": "Windows security mechanism that prompts users for administrative permission before making system-wide changes.",
            "et": "Windowsi turvamehhanism, mis küsib administraatori luba enne süsteemsete muudatuste tegemist.",
            "fi": "Windowsin suojausominaisuus, joka pyytää järjestelmänvalvojan oikeuksia ennen järjestelmämuutoksia.",
            "sv": "Windows säkerhetsfunktion som begär administratörsrättigheter för systemändringar.",
            "lv": "Windows drošības mehānisms, kas pieprasa administratora atļauju sistēmas izmaiņām.",
            "lt": "Windows saugumo funkcija, reikalaujanti administratoriaus leidimo sistemos pakeitimams."
        },
        "project_role": {
            "en": "Bypassed cleanly by Rule 14 (Zero-Admin): certificates registered to CurrentUser store, needing 0 elevation prompts.",
            "et": "Välditud täielikult Reegli 14 alusel: sertifikaadid lisatakse CurrentUser hoidlasse ilma administraatori õiguste nõudeta.",
            "fi": "Vältetään täysin Säännön 14 mukaisesti: sertifikaatit asennetaan käyttäjäkohtaisesti ilman pääkäyttäjäoikeuksia.",
            "sv": "Undviks enligt Regel 14: certifikat registreras på användarnivå utan krav på administratörsrättigheter.",
            "lv": "Apiets atbilstoši 14. noteikumam: sertifikāti tiek pievienoti lietotāja līmenī bez administratora tiesībām.",
            "lt": "Apeinama pagal 14 taisyklę: sertifikatai registruojami vartotojo lygiu be administratoriaus teisių."
        },
        "links": [
            {"label": "scripts/certs/trust-local-cert.cmd", "url": "scripts/certs/trust-local-cert.cmd"},
            {"label": "docs/windows-enterprise-setup-guide.md", "url": "docs/windows-enterprise-setup-guide.md"}
        ]
    },
    {
        "acronym": "UI / UX",
        "expansion": "User Interface / User Experience",
        "category": "design",
        "ref_url": "https://en.wikipedia.org/wiki/User_interface_design",
        "ref_title": "Wikipedia: UI/UX Design",
        "def": {
            "en": "The visual appearance, controls, navigation, and holistic usability experience of a digital product or application.",
            "et": "Kasutajaliides ja kasutajakogemus: visuaalne kujundus, juhtnupud, navigeerimine ja süsteemi kasutusmugavus.",
            "fi": "Käyttöliittymä ja käyttäjäkokemus: sovelluksen ulkoasu, painikkeet ja kokonaisvaltainen käytettävyys.",
            "sv": "Användargränssnitt och användarupplevelse: design, navigering och helhetsintryck för användaren.",
            "lv": "Lietotāja saskarne un pieredze: vizuālais noformējums, navigācija un lietošanas ērtums.",
            "lt": "Vartotojo sąsaja ir patirtis: vizualus dizainas, valdikliai ir bendras patogumas."
        },
        "project_role": {
            "en": "Polished in Dev Hub: dark modern theme, 1-click clipboard helpers, interactive slides, and live container terminal UX.",
            "et": "Lihvitud Dev Hubis: modernne tume teema, 1-kliki paroolikopeerijad, interaktiivsed slaidid ja reaalajas logid.",
            "fi": "Viimeistelty Dev Hubissa modernilla tummalla teemalla, pikanäppäimillä ja reaaliaikaisilla lokeilla.",
            "sv": "Optimerat i Dev Hub med mörkt tema, snabbknappar och realtidsövervakning.",
            "lv": "Pilnveidots Dev Hub ar modernu tumšo tēmu, ātrajiem rīkiem un reāllaika žurnāliem.",
            "lt": "Ištobulinta Dev Hub su modernia tamsia tema, greitaisiais įrankiais ir žurnalais realiuoju laiku."
        },
        "links": [
            {"label": "docs/dev-hub.html", "url": "docs/dev-hub.html"}
        ]
    },
    {
        "acronym": "URI / URL",
        "expansion": "Uniform Resource Identifier / Locator",
        "category": "web",
        "ref_url": "https://en.wikipedia.org/wiki/Uniform_Resource_Identifier",
        "ref_title": "Wikipedia: URI / URL",
        "def": {
            "en": "Standard address string used to identify and locate resources (web pages, APIs, documents) on a network.",
            "et": "Standardne veebiaadress võrguressursside (veebilehtede, API otspunktide, dokumentide) tuvastamiseks ja avamiseks.",
            "fi": "Standardi verkko-osoite resurssien (verkkosivujen, rajapintojen) yksilöimiseen ja paikantamiseen.",
            "sv": "Standardiserad adress för att identifiera och lokalisera resurser på nätverket.",
            "lv": "Standarta tīmekļa adrese resursu atrašanai un identificēšanai tīklā.",
            "lt": "Standartinis saityno adresas ištekliams rasti ir identifikuoti tinkle."
        },
        "project_role": {
            "en": "Validated on platform startup by scripts/check-urls.sh ensuring all web services respond with HTTP 200/302.",
            "et": "Valideeritud platvormi käivitusel skriptiga scripts/check-urls.sh, tagades et kõik teenused vastavad HTTP 200/302.",
            "fi": "Tarkistetaan käynnistyksessä skriptillä scripts/check-urls.sh varmistaen vastauskoodit HTTP 200/302.",
            "sv": "Verifieras vid uppstart av scripts/check-urls.sh för att säkerställa att tjänster svarar med HTTP 200/302.",
            "lv": "Pārbaudīts starta laikā ar scripts/check-urls.sh, pārliecinoties par HTTP 200/302 atbildēm.",
            "lt": "Tikrinama paleidimo metu su scripts/check-urls.sh užtikrinant HTTP 200/302 atsakus."
        },
        "links": [
            {"label": "scripts/check-urls.sh", "url": "scripts/check-urls.sh"}
        ]
    },
    {
        "acronym": "VPN",
        "expansion": "Virtual Private Network",
        "category": "network",
        "ref_url": "https://en.wikipedia.org/wiki/Virtual_private_network",
        "ref_title": "Wikipedia: Virtual Private Network",
        "def": {
            "en": "Encrypted tunnel extending a private corporate network across a public network, protecting data traffic from interception.",
            "et": "Krüpteeritud võrgutunnel, mis võimaldab turvalist ligipääsu ettevõtte sisevõrgule üle avaliku interneti.",
            "fi": "Salattu verkkotunneli, joka yhdistää etälaitteen turvallisesti yrityksen sisäverkkoon internetin yli.",
            "sv": "Krypterad nätverkstunnel för säker anslutning till företagets interna nätverk över internet.",
            "lv": "Šifrēts tīkla tunelis drošai piekļuvei korporatīvajam tīklam no ārpuses.",
            "lt": "Šifruotas tinklo tunelis saugiam prisijungimui prie įmonės vidinio tinklo per internetą."
        },
        "project_role": {
            "en": "Protected under Windows WSL2 via 'dnsTunneling=true' in .wslconfig, preventing corporate VPNs from dropping DNS.",
            "et": "Kaitstud Windows WSL2 all parameetriga 'dnsTunneling=true' failis .wslconfig, vältides sisevõrgu DNS-i katkemist.",
            "fi": "Suojattu Windows WSL2:ssa asetuksella 'dnsTunneling=true' estäen yritys-VPN:n DNS-katkokset.",
            "sv": "Skyddat i Windows WSL2 via 'dnsTunneling=true' så att företags-VPN inte bryter namnserveruppslag.",
            "lv": "Aizsargāts Windows WSL2 ar 'dnsTunneling=true' parametru, novēršot DNS kļūmes.",
            "lt": "Apsaugota Windows WSL2 per 'dnsTunneling=true' nustatymą, kad įmonės VPN nenutrauktų DNS."
        },
        "links": [
            {"label": "docs/windows-enterprise-setup-guide.md", "url": "docs/windows-enterprise-setup-guide.md"}
        ]
    },
    {
        "acronym": "VS Code",
        "expansion": "Visual Studio Code",
        "category": "tools",
        "ref_url": "https://en.wikipedia.org/wiki/Visual_Studio_Code",
        "ref_title": "Wikipedia: Visual Studio Code",
        "def": {
            "en": "Extensible, lightweight source-code editor developed by Microsoft with rich language and plugin support.",
            "et": "Microsofti arendatud kergekaaluline ja laiendatav koodiredaktor rikkaliku pistikprogrammide ökosüsteemiga.",
            "fi": "Microsoftin suosittu laajennettava koodieditori laajalla lisäosatuella.",
            "sv": "Populär och anpassningsbar källkodsredigerare från Microsoft med omfattande tilläggsstöd.",
            "lv": "Paplašināms koda redaktors no Microsoft ar plašu spraudņu klāstu.",
            "lt": "Populiarus ir išplečiamas kodo redaktorius iš Microsoft su gausiu įskiepių palaikymu."
        },
        "project_role": {
            "en": "Primary IDE: auto-registers connections to Oracle SQL Developer extension via scripts/register-connections.sh.",
            "et": "Peamine arenduskeskkond: registreerib ühendused Oracle laiendusse skriptiga scripts/register-connections.sh.",
            "fi": "Ensisijainen kehityseditori: rekisteröi yhteydet Oracle-laajennukseen skriptillä scripts/register-connections.sh.",
            "sv": "Primär editor: anslutningar registreras automatiskt till Oracle-tillägget via scripts/register-connections.sh.",
            "lv": "Galvenais koda redaktors: automātiski reģistrē savienojumus ar Oracle paplašinājumu.",
            "lt": "Pagrindinis kodo redaktorius: automatiškai registruoja ryšius su Oracle plėtiniu."
        },
        "links": [
            {"label": "scripts/register-connections.sh", "url": "scripts/register-connections.sh"}
        ]
    },
    {
        "acronym": "WSL / WSL2",
        "expansion": "Windows Subsystem for Linux (Version 2)",
        "category": "os",
        "ref_url": "https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux",
        "ref_title": "Wikipedia: Windows Subsystem for Linux",
        "def": {
            "en": "Native lightweight virtualized Linux utility inside Windows 10/11 running an authentic Linux kernel.",
            "et": "Microsoft Windowsi sisseehitatud Linuxi alamsüsteem, mis käitab ehtsat Linuxi tuuma virtuaalmasinas.",
            "fi": "Windowsin sisäänrakennettu Linux-alijärjestelmä, joka ajaa aitoa Linux-ydintä virtuaalisesti.",
            "sv": "Windows integrerade Linux-miljö som kör en äkta Linux-kärna i en lättvikts-VM.",
            "lv": "Windows iebūvētā Linux apakšsistēma ar īstu Linux kodolu.",
            "lt": "Integruota Windows Linux posistemė, paleidžianti tikrą Linux branduolį."
        },
        "project_role": {
            "en": "Mandated by Rule 14: workspace must live strictly inside native ext4 filesystem (~/ or /home/), never under /mnt/c/.",
            "et": "Kohustuslik vastavalt Reeglile 14: kood peab asuma natiivses ext4 failisüsteemis (~/ või /home/), mitte /mnt/c/ all.",
            "fi": "Säännön 14 vaatimus: projektin on sijaittava natiivissa ext4-tiedostojärjestelmässä, ei /mnt/c/ -polulla.",
            "sv": "Krav enligt Regel 14: källkoden måste ligga i det interna ext4-filsystemet, aldrig under /mnt/c/.",
            "lv": "14. noteikuma prasība: videi jāatrodas natīvajā ext4 failu sistēmā (~/), nevis /mnt/c/.",
            "lt": "14 taisyklės reikalavimas: projektas privalo būti vidinėje ext4 sistemoje (~/), o ne /mnt/c/."
        },
        "links": [
            {"label": "docs/windows-enterprise-setup-guide.md", "url": "docs/windows-enterprise-setup-guide.md"},
            {"label": "setup.cmd", "url": "setup.cmd"}
        ]
    },
    {
        "acronym": "YAML",
        "expansion": "YAML Ain't Markup Language",
        "category": "data",
        "ref_url": "https://en.wikipedia.org/wiki/YAML",
        "ref_title": "Wikipedia: YAML",
        "def": {
            "en": "Human-readable data serialization standard commonly used for configuration files and infrastructure declarations.",
            "et": "Inimloetav andmevorming, mida kasutatakse konfiguratsioonifailides ja taristu deklaratsioonides.",
            "fi": "Ihmisluettava tiedonkuvausmuoto konfiguraatiotiedostoille ja infrastruktuurin määrityksille.",
            "sv": "Lättläst dataformat för konfigurationsfiler och infrastrukturdeklarationer.",
            "lv": "Cilvēkam viegli lasāms datu formāts konfigurācijas failiem un deklarācijām.",
            "lt": "Žmogui lengvai skaitomas duomenų formatas konfigūracijoms ir deklaracijoms."
        },
        "project_role": {
            "en": "Mandated by Rule 11 as Single Source of Truth for database profiles (config/profiles/databases/*.yaml) and user grants.",
            "et": "Kohustuslik vastavalt Reeglile 11 andmebaaside profiilide (config/profiles/databases/*.yaml) ja kasutajate ainsa tõeallikana.",
            "fi": "Toimii Säännön 11 mukaan ainoana totuuden lähteenä tietokantaprofiileille ja käyttäjille.",
            "sv": "Krav enligt Regel 11 som enda sanningskälla för databasprofiler och användarbehörigheter.",
            "lv": "11. noteikuma prasība kā vienīgais patiesības avots datubāzu profiliem un lietotājiem.",
            "lt": "11 taisyklės reikalavimas kaip vienintelis tiesos šaltinis DB profiliams ir teisėms."
        },
        "links": [
            {"label": "config/profiles/databases/db-oracle.yaml", "url": "config/profiles/databases/db-oracle.yaml"}
        ]
    }
]

def get_glossary_catalog():
    """Returns sorted glossary catalog by acronym."""
    return sorted(GLOSSARY_ITEMS, key=lambda x: x["acronym"].upper())

def generate_markdown_glossary(ws, lang="en"):
    """Generates markdown documentation for glossary across 6 languages."""
    catalog = get_glossary_catalog()
    
    titles = {
        "en": ("Architecture Glossary & Acronyms Reference", "Comprehensive index of acronyms, technical definitions, and practical project roles."),
        "et": ("Arhitektuuri akronüümid ja sõnastik", "Põhjalik akronüümide, tehniliste mõistete ja projekti kasutusrollide register."),
        "fi": ("Arkkitehtuurisanasto ja lyhenteet", "Kattava luettelo lyhenteistä, teknisistä määritelmistä ja käytännön rooleista projektissa."),
        "sv": ("Arkitekturordlista och akronymer", "Omfattande register över förkortningar, tekniska definitioner och praktisk projektanvändning."),
        "lv": ("Arhitektūras glosārijs un saīsinājumi", "Visaptverošs saīsinājumu, tehnisko terminu un praktiskās izmantošanas reģistrs."),
        "lt": ("Architektūros žodynas ir akronimai", "Išsamus akronimų, techninių apibrėžimų ir praktinio pritaikymo projekte sąvadas.")
    }
    
    sec_labels = {
        "en": ("Definition", "Role in this Project", "Related Documentation & Scripts", "Official / External Reference"),
        "et": ("Definitsioon", "Roll ja kasutus selles projektis", "Seotud juhendid ja skriptid", "Ametlik viide / Vikipeedia"),
        "fi": ("Määritelmä", "Rooli tässä projektissa", "Liittyvät ohjeet ja skriptit", "Virallinen viite / Wikipedia"),
        "sv": ("Definition", "Roll i detta projekt", "Relaterade guider och skript", "Officiell referens / Wikipedia"),
        "lv": ("Definīcija", "Loma šajā projektā", "Saistītā dokumentācija un skripti", "Oficiālā atsauce / Vikipēdija"),
        "lt": ("Apibrėžimas", "Vaidmuo šiame projekte", "Susijusi dokumentacija ir skriptai", "Oficiali nuoroda / Vikipedija")
    }

    doc_title, doc_lead = titles.get(lang, titles["en"])
    lbl_def, lbl_role, lbl_links, lbl_ref = sec_labels.get(lang, sec_labels["en"])

    # Language switcher header
    lang_links = [
        "[ 🇬🇧 English ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/glossary.md)" if lang != "en" else "**[ 🇬🇧 English ]**",
        "[ 🇪🇪 Eesti ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/et/glossary.md)" if lang != "et" else "**[ 🇪🇪 Eesti ]**",
        "[ 🇫🇮 Suomi ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/fi/glossary.md)" if lang != "fi" else "**[ 🇫🇮 Suomi ]**",
        "[ 🇸🇪 Svenska ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/sv/glossary.md)" if lang != "sv" else "**[ 🇸🇪 Svenska ]**",
        "[ 🇱🇻 Latviešu ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lv/glossary.md)" if lang != "lv" else "**[ 🇱🇻 Latviešu ]**",
        "[ 🇱🇹 Lietuvių ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lt/glossary.md)" if lang != "lt" else "**[ 🇱🇹 Lietuvių ]**"
    ]
    header_switcher = " | ".join(lang_links)

    lines = [
        f"# {doc_title}",
        "",
        header_switcher,
        "",
        f"> {doc_lead}",
        "",
        "---",
        ""
    ]

    # Quick Jump Letters
    letters = sorted(list(set(item["acronym"][0].upper() for item in catalog)))
    jump_links = " • ".join(f"[{let}](#{let.lower()})" for let in letters)
    lines.append(f"**A–Z Register:** {jump_links}")
    lines.append("")
    lines.append("---")
    lines.append("")

    current_letter = None
    for item in catalog:
        first_letter = item["acronym"][0].upper()
        if first_letter != current_letter:
            current_letter = first_letter
            lines.append(f"## {current_letter}")
            lines.append("")

        acronym = item["acronym"]
        expansion = item["expansion"]
        def_text = item["def"].get(lang, item["def"]["en"])
        role_text = item["project_role"].get(lang, item["project_role"]["en"])
        ref_url = item.get("ref_url")
        ref_title = item.get("ref_title", "Wikipedia")
        links_list = item.get("links", [])

        lines.append(f"### `{acronym}` — {expansion}")
        lines.append(f"- **{lbl_def}:** {def_text}")
        lines.append(f"- **{lbl_role}:** {role_text}")
        if ref_url:
            lines.append(f"- **{lbl_ref}:** [{ref_title}]({ref_url})")
        if links_list:
            link_strs = [f"[{l['label']}](file://{os.path.join(ws, l['url'])})" for l in links_list]
            lines.append(f"- **{lbl_links}:** {', '.join(link_strs)}")
        lines.append("")

    return "\n".join(lines) + "\n"

def write_all_markdown_glossaries(ws):
    """Writes docs/glossary.md and docs/{et,fi,sv,lv,lt}/glossary.md."""
    paths = {
        "en": os.path.join(ws, "docs", "glossary.md"),
        "et": os.path.join(ws, "docs", "et", "glossary.md"),
        "fi": os.path.join(ws, "docs", "fi", "glossary.md"),
        "sv": os.path.join(ws, "docs", "sv", "glossary.md"),
        "lv": os.path.join(ws, "docs", "lv", "glossary.md"),
        "lt": os.path.join(ws, "docs", "lt", "glossary.md")
    }

    for lang, p in paths.items():
        os.makedirs(os.path.dirname(p), exist_ok=True)
        content = generate_markdown_glossary(ws, lang)
        with open(p, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"✅ Generated glossary markdown: {p}")

if __name__ == "__main__":
    ws = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.."))
    write_all_markdown_glossaries(ws)
