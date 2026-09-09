#!/usr/bin/env python3
"""
Oracle DevOps Platform — Central FAQ Catalog (faq.py)
Provides a Single Source of Truth (SSOT) for platform Frequently Asked Questions
across 4 distinct categories and 6 languages (EN, ET, FI, SV, LV, LT).
"""

import os
import re

FAQ_CATEGORIES = [
    {
        "id": "all",
        "labels": {
            "en": "All Questions",
            "et": "Kõik küsimused",
            "fi": "Kaikki kysymykset",
            "sv": "Alla frågor",
            "lv": "Visi jautājumi",
            "lt": "Visi klausimai"
        }
    },
    {
        "id": "beginner",
        "labels": {
            "en": "Beginner & Basics",
            "et": "Alustaja ja põhitõed",
            "fi": "Aloittelija ja perusteet",
            "sv": "Nybörjare & grunder",
            "lv": "Iesācējs un pamati",
            "lt": "Pradedantysis ir pagrindai"
        }
    },
    {
        "id": "architect",
        "labels": {
            "en": "Architecture & Cloud",
            "et": "Arhitektuur ja pilv",
            "fi": "Arkkitehtuuri ja pilvi",
            "sv": "Arkitektur & moln",
            "lv": "Arhitektūra un mākonis",
            "lt": "Architektūra ir debesis"
        }
    },
    {
        "id": "dba_security",
        "labels": {
            "en": "DBA & Security",
            "et": "DBA ja turvalisus",
            "fi": "DBA ja tietoturva",
            "sv": "DBA & säkerhet",
            "lv": "DBA un drošība",
            "lt": "DBA ir saugumas"
        }
    },
    {
        "id": "troubleshooting",
        "labels": {
            "en": "Troubleshooting & Recovery",
            "et": "Tõrkeotsing ja taastamine",
            "fi": "Vianmääritys ja palautus",
            "sv": "Felsökning & återställning",
            "lv": "Traucējummeklēšana un atkopšana",
            "lt": "Trikčių šalinimas ir atkūrimas"
        }
    }
]

FAQ_ITEMS = [
    # 1. RAM & Containers
    {
        "id": "faq-ram-requirements",
        "category": "beginner",
        "icon": "🧠",
        "question": {
            "en": "What are the container RAM requirements (4–8 GB min)?",
            "et": "Millised on konteinerite muutmälu (RAM) nõuded (min 4–8 GB)?",
            "fi": "Mitkä ovat konttien muistivaatimukset (RAM min 4–8 Gt)?",
            "sv": "Vilka är minneskraven (RAM min 4–8 GB) för containrar?",
            "lv": "Kādas ir konteineru operatīvās atmiņas (RAM) prasības (min 4–8 GB)?",
            "lt": "Kokie yra konteinerių operatyviosios atminties (RAM) reikalavimai (min 4–8 GB)?"
        },
        "answer": {
            "en": "Oracle 23ai Free requires at least 2.5 GB RAM to operate. If your Podman or Docker virtual machine is allocated less than 4 GB, the database container will terminate unexpectedly (OOM Killer / exit code 137). For multi-container blueprints (Proxy + Business DB + ORDS + Forms), allocate at least 8 GB RAM.",
            "et": "Oracle 23ai Free vajab töötamiseks vähemalt 2.5 GB RAM-i. Kui Podmani või Dockeri virtuaalmasinal on alla 4 GB mälu, peatub andmebaasi konteiner ootamatult (OOM Killer / exit code 137). Mitme konteineriga kavandite (Proxy + Äribaas + ORDS + Forms) puhul määrake vähemalt 8 GB RAM-i.",
            "fi": "Oracle 23ai Free vaatii toimiakseen vähintään 2,5 Gt RAM-muistia. Jos Podman- tai Docker-virtuaalikoneelle on varattu alle 4 Gt, tietokantakontti pysähtyy odottamatta (OOM Killer / poistumiskoodi 137). Usean kontin malleissa varaa vähintään 8 Gt.",
            "sv": "Oracle 23ai Free kräver minst 2,5 GB RAM för att köras. Om din Podman- eller Docker-virtuella maskin har mindre än 4 GB minne stoppas databascontainern oväntat (OOM Killer / felkod 137). För flercontainermallar rekommenderas minst 8 GB RAM.",
            "lv": "Oracle 23ai Free darbībai nepieciešami vismaz 2,5 GB RAM. Ja Podman vai Docker virtuālajai mašīnai piešķirts mazāk par 4 GB, datubāzes konteiners negaidīti apstāsies (OOM Killer / izejas kods 137). Vairāku konteineru scenārijiem piešķiriet vismaz 8 GB.",
            "lt": "Oracle 23ai Free reikalauja bent 2,5 GB RAM. Jei Podman ar Docker virtualiai mašinai priskirta mažiau nei 4 GB, duomenų bazės konteineris netikėtai sustos (OOM Killer / kodas 137). Kelių konteinerių konfigūracijoms skirkite bent 8 GB RAM."
        },
        "code_snippet": "# Check and increase Podman VM memory (macOS / Windows WSL2):\npodman machine stop\npodman machine set --memory 8192 --cpus 4\npodman machine start",
        "doc_ref": "docs/prerequisites.md",
        "links": [
            {"label": "docs/prerequisites.md", "url": "docs/prerequisites.md"},
            {"label": "scripts/check-prerequisites.sh", "url": "scripts/check-prerequisites.sh"}
        ]
    },

    # 2. Port Conflicts
    {
        "id": "faq-port-conflicts",
        "category": "troubleshooting",
        "icon": "🔌",
        "question": {
            "en": "How to resolve port conflicts (8448, 1521, 8080 already in use)?",
            "et": "Kuidas lahendada pordi konflikte (8448, 1521, 8080 hõivatud)?",
            "fi": "Miten ratkaista porttiristiriidat (8448, 1521, 8080 varattu)?",
            "sv": "Hur löser man portkonflikter (8448, 1521, 8080 upptagna)?",
            "lv": "Kā atrisināt portu konfliktus (8448, 1521, 8080 aizņemti)?",
            "lt": "Kaip išspręsti prievadų konfliktus (8448, 1521, 8080 užimti)?"
        },
        "answer": {
            "en": "If your terminal outputs `bind: address already in use`, another web server, container, or local Oracle listener is bound to that port. Identify and terminate the conflicting process or remap the host port cleanly in your `.env` file without modifying any script code.",
            "et": "Kui terminal annab vea `bind: address already in use`, tööta taustal teine veebiserver, konteiner või lokaalne Oracle listener. Tuvastage ja peatage konfliktne protsess või muutke host-porti mugavalt failis `.env` ilma skripte muutmata.",
            "fi": "Jos terminaali ilmoittaa `bind: address already in use`, toinen verkkopalvelin tai Oracle listener varaa portin. Tunnista ja pysäytä häiritsevä prosessi tai vaihda isäntäporttia suoraan `.env`-tiedostossa.",
            "sv": "Om terminalen visar `bind: address already in use` körs en annan webbserver eller Oracle-lyssnare på den porten. Identifiera och avsluta processen eller ändra porten i `.env`-filen.",
            "lv": "Ja terminālī parādās kļūda `bind: address already in use`, kāds cits tīmekļa serveris vai klausītājs aizņem portu. Apturiet procesu vai nomainiet portu `.env` failā.",
            "lt": "Jei terminale rodoma `bind: address already in use`, kitas žiniatinklio serveris užima prievadą. Sustabdykite procesą arba pakeiskite prievadą `.env` faile."
        },
        "code_snippet": "# Identify conflicting process on port:\nlsof -i :8448   # macOS/Linux\n# Change port dynamically in .env:\nHOST_HTTPS_PORT=8449\nHOST_DB_PORT=1522",
        "doc_ref": "docs/port-matrix-and-firewall.md",
        "links": [
            {"label": "docs/port-matrix-and-firewall.md", "url": "docs/port-matrix-and-firewall.md"},
            {"label": "scripts/check-urls.sh", "url": "scripts/check-urls.sh"}
        ]
    },

    # 3. SSL Warning
    {
        "id": "faq-ssl-warning",
        "category": "beginner",
        "icon": "🔒",
        "question": {
            "en": "How to handle the browser \"Connection is not private\" SSL warning?",
            "et": "Kuidas lahendada brauseri \"Ühendus pole privaatne\" SSL hoiatus?",
            "fi": "Miten käsitellä selaimen \"Yhteys ei ole yksityinen\" SSL-varoitus?",
            "sv": "Hur hanteras webbläsarens SSL-varning \"Anslutningen är inte privat\"?",
            "lv": "Kā novērst pārlūka SSL brīdinājumu \"Savienojums nav privāts\"?",
            "lt": "Kaip išspręsti naršyklės SSL įspėjimą \"Ryšys nėra privatus\"?"
        },
        "answer": {
            "en": "Local HTTPS (https://localhost:8448) uses a self-signed root certificate generated automatically for your machine. You can click 'Advanced' -> 'Proceed to localhost' in your browser, or install the certificate once into your OS trust store using the provided zero-admin scripts.",
            "et": "Lokaalne HTTPS (https://localhost:8448) kasutab kohalikku isesertifitseeritud sertifikaati. Klõpsake brauseris 'Advanced' -> 'Proceed to localhost' või lisage sertifikaat süsteemi usaldusnimekirja kaasasolevate 0-admin skriptidega.",
            "fi": "Paikallinen HTTPS (https://localhost:8448) käyttää automaattisesti luotua itseallekirjoitettua varmennetta. Voit ohittaa varoituksen selaimessa tai asentaa varmenteen käyttöjärjestelmän luotettuihin juurivarmenteisiin.",
            "sv": "Lokal HTTPS (https://localhost:8448) använder ett självsignerat rotcertifikat. Klicka på 'Avancerat' -> 'Fortsätt till localhost' eller installera certifikatet i systemets betrodda lager.",
            "lv": "Vietējais HTTPS (https://localhost:8448) izmanto pašparakstītu sertifikātu. Pārlūkā nospiediet 'Advanced' -> 'Proceed to localhost' vai pievienojiet to sistēmas uzticamajiem sertifikātiem.",
            "lt": "Vietinis HTTPS (https://localhost:8448) naudoja savarankiškai pasirašytą sertifikatą. Naršyklėje pasirinkite 'Išsamiau' -> 'Eiti į localhost' arba įtraukite į sistemos patikimų sertifikatų sąrašą."
        },
        "code_snippet": "# macOS Keychain trust:\n./scripts/certs/trust-local-cert-mac.sh\n# Windows CurrentUser trust (Zero-UAC):\n./scripts/certs/trust-local-cert.cmd",
        "doc_ref": "docs/ssl-certificates.md",
        "links": [
            {"label": "docs/ssl-certificates.md", "url": "docs/ssl-certificates.md"},
            {"label": "scripts/certs/trust-local-cert-mac.sh", "url": "scripts/certs/trust-local-cert-mac.sh"}
        ]
    },

    # 4. Passwords & SEPS Wallet
    {
        "id": "faq-wallet-passwords",
        "category": "dba_security",
        "icon": "🔐",
        "question": {
            "en": "Where are passwords stored? (SEPS Wallet vs plaintext files)",
            "et": "Kus asuvad paroolid? (SEPS Wallet vs tekstifailid)",
            "fi": "Missä salasanoja säilytetään? (SEPS Wallet vs tekstitiedostot)",
            "sv": "Var lagras lösenord? (SEPS Wallet vs klartextfiler)",
            "lv": "Kur tiek glabātas paroles? (SEPS Wallet vs teksta faili)",
            "lt": "Kur saugomi slaptažodžiai? (SEPS Wallet vs paprasto teksto failai)?"
        },
        "answer": {
            "en": "In accordance with strict Zero-Trust rules (Rule 5), passwords are NEVER written to the disk in plaintext files (.txt, .json, .env). All credentials reside encrypted inside the Oracle SEPS Auto-Login Wallet (cwallet.sso / ewallet.p12 with AES-256). Passwords are only decrypted in-memory on demand via get-password.sh.",
            "et": "Rangete Zero-Trust reeglite (Reegel 5) järgi ei kirjutata paroole KUNAGI kettale tekstifailidesse (.txt, .json, .env). Kõik mandaadid asuvad krüpteeritult SEPS Auto-Login Walletis (cwallet.sso / ewallet.p12 AES-256 krüptoga). Paroolid deküpteeritakse ainult töömällu käsureatööriistaga get-password.sh.",
            "fi": "Tiukkojen Zero-Trust-periaatteiden (Sääntö 5) mukaisesti salasanoja EI KOSKAAN tallenneta levylle selkokielisinä. Kaikki tunnukset ovat AES-256-salattuina Oracle SEPS Walletissa (cwallet.sso / ewallet.p12). Salasanat puretaan vain muistiin get-password.sh-työkalulla.",
            "sv": "Enligt strikta Zero-Trust-regler (Regel 5) skrivs lösenord ALDRIG till disk i klartext. Alla autentiseringsuppgifter är AES-256-krypterade i Oracle SEPS Wallet (cwallet.sso / ewallet.p12). Lösenord dekrypteras endast i minnet via get-password.sh.",
            "lv": "Saskaņā ar Zero-Trust principiem (5. noteikums) paroles NEKAD netiek saglabātas atklātā tekstā. Visi dati atrodas šifrēti Oracle SEPS makā (cwallet.sso / ewallet.p12). Paroles tiek nolasītas tikai operatīvajā atmiņā caur get-password.sh.",
            "lt": "Laikantis griežtų Zero-Trust taisyklių (5 taisyklė), slaptažodžiai NIEKADA neįrašomi į diską atviru tekstu. Visi duomenys šifruojami Oracle SEPS piniginėje (cwallet.sso / ewallet.p12). Slaptažodžiai iššifruojami tik atmintyje per get-password.sh."
        },
        "code_snippet": "# View password in terminal or copy directly to clipboard (-c):\n./scripts/get-password.sh DB_PROXY_DEV\n./scripts/get-password.sh DB_PROXY_DEV -c\n# Connect passwordlessly via SEPS Wallet alias:\n./scripts/sqlcl.sh /@DB_PROXY_DEV",
        "doc_ref": "docs/wallet-management.md",
        "links": [
            {"label": "docs/wallet-management.md", "url": "docs/wallet-management.md"},
            {"label": "scripts/get-password.sh", "url": "scripts/get-password.sh"},
            {"label": "scripts/check-wallet.sh", "url": "scripts/check-wallet.sh"}
        ]
    },

    # 5. Golden Snapshot Recovery
    {
        "id": "faq-golden-snapshots",
        "category": "troubleshooting",
        "icon": "⚡",
        "question": {
            "en": "How does Golden Snapshot recovery work in ~15 seconds without reinstalling?",
            "et": "Kuidas töötab kuldse hetktõmmise taastamine ~15 sekundiga ilma uuesti paigaldamata?",
            "fi": "Miten kultaisen pikavedoksen palautus toimii ~15 sekunnissa ilman uudelleenasennusta?",
            "sv": "Hur fungerar återställning av gyllene ögonblicksbilder på ~15 sekunder?",
            "lv": "Kā darbojas zelta momentuzņēmuma atjaunošana ~15 sekundēs bez pārinstalēšanas?",
            "lt": "Kaip veikia auksinės momentinės kopijos atkūrimas per ~15 sekundžių be diegimo iš naujo?"
        },
        "answer": {
            "en": "A Golden Snapshot captures the fully configured database files, metadata, and schemas right after setup completes. Instead of running a fresh 12-minute installation, the restore script stops the container, cleanly restores the verified snapshot files, and brings the database back online in about 15 seconds.",
            "et": "Kuldne hetktõmmis (Golden Snapshot) talletab täielikult paigaldatud ja seadistatud andmebaasifailid, skeemid ja metastruktuurid kohe pärast paigalduse lõppu. Uue 12-minutilise paigalduse asemel taastab skript puhta algseisu umbes 15 sekundiga.",
            "fi": "Kultainen pikavedos tallentaa täysin konfiguroidun tietokannan tiedostot ja skeemat heti asennuksen valmistuttua. Uuden 12 minuutin asennuksen sijaan palautusskripti palauttaa puhtaan alkutilan noin 15 sekunnissa.",
            "sv": "En gyllene ögonblicksbild sparar en fullständigt konfigurerad databas direkt efter installationen. Istället för en ny 12 minuters installation återställer skriptet det orörda läget på cirka 15 sekunder.",
            "lv": "Zelta momentuzņēmums fiksē pilnībā nokonfigurēto datubāzi tūlīt pēc uzstādīšanas. Tā vietā, lai gaidītu 12 minūtes jaunu instalāciju, skripts atjauno tīru stāvokli apmēram 15 sekundēs.",
            "lt": "Auksinė momentinė kopija išsaugo pilnai sukonfigūruotą duomenų bazę iškart po įdiegimo. Vietoj naujo 12 minučių diegimo, skriptas atkuria pradinę būseną maždaug per 15 sekundžių."
        },
        "code_snippet": "# Restore clean initial state of active blueprint in ~15s:\n./scripts/snapshots/restore-golden-snapshots.sh\n# Create golden snapshot manually:\n./scripts/snapshots/create-golden-snapshots.sh",
        "doc_ref": "docs/golden-snapshots.md",
        "links": [
            {"label": "docs/golden-snapshots.md", "url": "docs/golden-snapshots.md"},
            {"label": "scripts/snapshots/restore-golden-snapshots.sh", "url": "scripts/snapshots/restore-golden-snapshots.sh"}
        ]
    },

    # 6. Stop & Restart
    {
        "id": "faq-stop-restart",
        "category": "beginner",
        "icon": "🌙",
        "question": {
            "en": "How to pause and resume the environment at the end of the day?",
            "et": "Kuidas tööpäeva lõpus keskkonda peatada ja uuesti käivitada?",
            "fi": "Miten keskeyttää ja käynnistää ympäristö työpäivän päätteeksi?",
            "sv": "Hur pausar och startar man om miljön vid arbetsdagens slut?",
            "lv": "Kā darba dienas beigās apturēt un atsākt vides darbību?",
            "lt": "Kaip darbo dienos pabaigoje pristabdyti ir vėl paleisti aplinką?"
        },
        "answer": {
            "en": "At the end of your workday, stop containers to free up your computer's RAM and CPU without losing any data. In the morning, restart the containers in seconds without re-running setup.",
            "et": "Tööpäeva lõpus peatage konteinerid arvuti ressursside vabastamiseks ilma andmekaota. Hommikul taaskäivitage olemasolevad konteinerid sekunditega ilma paigaldust uuesti tegemata.",
            "fi": "Pysäytä kontit työpäivän päätteeksi vapauttaaksesi RAM- ja CPU-resurssit ilman tietojen menetystä. Käynnistä kontit aamulla uudelleen sekunneissa ilman asennuksen toistamista.",
            "sv": "Vid arbetsdagens slut stoppar du containrarna för att frigöra RAM och CPU utan att förlora data. Starta om dem på några sekunder nästa morgon utan ominstallation.",
            "lv": "Darba dienas beigās apturiet konteinerus, lai atbrīvotu datora resursus bez datu zuduma. No rīta palaidiet tos dažu sekunžu laikā bez atkārtotas uzstādīšanas.",
            "lt": "Darbo dienos pabaigoje sustabdykite konteinerius, kad atlaisvintumėte kompiuterio išteklius be duomenų praradimo. Ryte paleiskite juos per kelias sekundes be diegimo iš naujo."
        },
        "code_snippet": "# Stop containers without data loss:\n./scripts/reset-all.sh\n# Resume existing containers in seconds:\n./scripts/start-containers.sh",
        "doc_ref": "docs/quick-login-guide.md",
        "links": [
            {"label": "docs/quick-login-guide.md", "url": "docs/quick-login-guide.md"},
            {"label": "scripts/start-containers.sh", "url": "scripts/start-containers.sh"},
            {"label": "scripts/reset-all.sh", "url": "scripts/reset-all.sh"}
        ]
    },

    # 7. APEX vs Raw AI Generated Code (Slide 12)
    {
        "id": "faq-apex-vs-raw-code",
        "category": "architect",
        "icon": "🚀",
        "question": {
            "en": "Why choose APEX & declarative blueprints instead of AI-generated raw code (React/Node)?",
            "et": "Miks valida APEX ja deklaratiivsed blueprintid toorkoodi (React/Node) genereerimise asemel?",
            "fi": "Miksi valita APEX ja deklaratiiviset blueprintit raakakoodin generoimisen (React/Node) sijaan?",
            "sv": "Varför välja APEX och deklarativa blueprints istället för AI-genererad råkod (React/Node)?",
            "lv": "Kāpēc izvēlēties APEX un deklaratīvos plānus, nevis AI ģenerētu kodu (React/Node)?",
            "lt": "Kodėl verta rinktis APEX ir deklaratyvius planus vietoj generuoto kodo (React/Node)?"
        },
        "answer": {
            "en": "Generating 10,000+ lines of imperative React/Node glue code creates massive long-term maintenance debt — your team must audit, debug, patch, and maintain every single line. In APEX, declarative blueprints (APEXlang DSL) define business logic, while built-in, certified database engines handle CSRF/XSS protection, session state, responsive rendering, and zero-latency SQL execution out of the box.",
            "et": "10 000+ rea imperatiivse React/Node liimkoodi genereerimisel võtab meeskond endale tohutu pikaajalise hooldusvõla ja vastutuse iga koodirea auditeerimise ja silumise eest. APEXis on kavand nagu kõrgtaseme spetsifikatsioonikeel (APEXlang), kus turvalisuse, sessioonihalduse ja 0ms latentsusega SQL-käituse tagab automaatselt sertifitseeritud platvormimootor.",
            "fi": "Yli 10 000 rivin generoiminen React/Node-liimakoodia luo valtavan ylläpitovelan: tiimin on auditoitava, korjattava ja ylläpidettävä jokaista riviä. APEXissa deklaratiiviset blueprintit määrittelevät logiikan, ja alustan moottori hoitaa tietoturvan, istunnot ja nollaviiveisen SQL-suorituksen automaattisesti.",
            "sv": "Att generera 10 000+ rader imperativ React/Node-kod skapar en enorm underhållsskuld där teamet tvingas förvalta varje rad. I APEX definierar deklarativa blueprints logiken, medan motorn automatiskt hanterar säkerhet, sessioner och prestanda.",
            "lv": "Masveida React/Node koda ģenerēšana rada milzīgu uzturēšanas parādu un atbildību par katru rindu. APEX deklaratīvie plāni definē biznesa prasības, bet drošību, sesijas un 0ms izpildi nodrošina pārbaudīts datubāzes dzinējs.",
            "lt": "Sugeneravus 10 000+ eilučių React/Node kodo sukuriama didžiulė priežiūros skola. APEX atveju deklaratyvūs planai aprašo reikalavimus, o platformos branduolys automatiškai užtikrina saugumą, sesijas ir momentinį SQL vykdymą."
        },
        "code_snippet": "# Compile human-readable APEXlang DSL (.apx) into APEX application:\n./scripts/sqlcl.sh /@DB_PROXY_DEV @apex/app_100.apx",
        "doc_ref": "docs/architecture-overview.md",
        "links": [
            {"label": "docs/architecture-overview.md", "url": "docs/architecture-overview.md"},
            {"label": "docs/apex-devhub-test-plan.md", "url": "docs/apex-devhub-test-plan.md"}
        ]
    },

    # 8. Free DB Limits (Slide 12)
    {
        "id": "faq-free-db-limits",
        "category": "architect",
        "icon": "💾",
        "question": {
            "en": "Are Oracle Free DB limits (2 GB RAM / 12 GB user data) sufficient for enterprise dev?",
            "et": "Kas Oracle Free DB ressursipiirangud (2 GB RAM / 12 GB andmeid) ei jää kitsaks?",
            "fi": "Riittävätkö Oracle Free DB:n resurssirajat (2 Gt RAM / 12 Gt dataa) yrityskehitykseen?",
            "sv": "Räcker begränsningarna i Oracle Free DB (2 GB RAM / 12 GB användardata) för utveckling?",
            "lv": "Vai Oracle Free DB ierobežojumi (2 GB RAM / 12 GB dati) ir pietiekami izstrādei?",
            "lt": "Ar pakanka Oracle Free DB ribų (2 GB RAM / 12 GB duomenų) verslo sistemų kūrimui?"
        },
        "answer": {
            "en": "Yes, absolutely. By decoupling the lightweight presentation layer (Proxy DB) from the business database, and utilizing zero-footprint REST streaming (AutoREST / ORDS), the local database stores only realistic development test subsets. When workloads scale to production, code deploys seamlessly to Oracle Autonomous Database (ADB) in OCI without refactoring.",
            "et": "Jah, kindlasti. Eraldades veebiliidese (Proxy DB) äribaasist ning kasutades null-jalajäljega REST-voogedastust (AutoREST / ORDS), hoitakse lokaalne andmemaht kompaktsena. Toodangusse liikudes skaleerub sama kood ilma muudatusteta otse Oracle Autonomous Database (ADB) pilvebaasi.",
            "fi": "Kyllä, ehdottomasti. Erottamalla käyttöliittymäkerroksen (Proxy DB) liiketoimintatietokannasta ja hyödyntämällä suoratoistavaa RESTiä, paikallinen levynkäyttö pysyy pienenä. Tuotantoon siirryttäessä sama koodi skaalautuu sellaisenaan Autonomous Databaseen.",
            "sv": "Ja, absolut. Genom att separera användargränssnittet (Proxy DB) från affärsdatabasen och använda REST-strömning hålls diskanvändningen minimal. Koden flyttas sömlöst till OCI Autonomous Database vid produktionsstart.",
            "lv": "Jā, pilnīgi noteikti. Atdalot saskarni (Proxy DB) no biznesa datubāzes un izmantojot REST straumēšanu, diska patēriņš ir minimāls. Ražošanā risinājums bez izmaiņām mērogojas uz Oracle Autonomous Database.",
            "lt": "Taip, visiškai. Atskyrus vartotojo sąsają (Proxy DB) nuo verslo duomenų bazės ir taikant REST perdavimą, disko sąnaudos lieka minimalios. Gamybinėje aplinkoje kodas perkeliamas tiesiai į Autonomous Database be pakeitimų."
        },
        "code_snippet": "# Hybrid deployment blueprint test:\n./scripts/setup-all.sh --blueprint 10  # BP 10: Hybrid Cloud ADB",
        "doc_ref": "docs/blueprints-overview.md",
        "links": [
            {"label": "docs/blueprints-overview.md", "url": "docs/blueprints-overview.md"},
            {"label": "docs/remote-multicloud-setup-guide.md", "url": "docs/remote-multicloud-setup-guide.md"}
        ]
    },

    # 9. Version Control & CI/CD (Slide 12)
    {
        "id": "faq-version-control-cicd",
        "category": "architect",
        "icon": "📜",
        "question": {
            "en": "How are version control, Liquibase changelogs, and zero-trust CI/CD verified?",
            "et": "Kuidas tagatakse versioonihaldus, Liquibase koodiajalugu ja CI/CD?",
            "fi": "Miten versionhallinta, Liquibase ja turvallinen CI/CD taataan?",
            "sv": "Hur säkerställs versionshantering, Liquibase och säker CI/CD?",
            "lv": "Kā tiek nodrošināta versiju kontrole, Liquibase un droša CI/CD?",
            "lt": "Kaip užtikrinamas versijų valdymas, Liquibase ir saugi CI/CD?"
        },
        "answer": {
            "en": "The platform enforces Git-first workflows using official SQLcl split exports, declarative Liquibase changelogs (`controller.xml`), and APEXlang AST validations. Secrets are never checked into Git; pipelines connect using passwordless Oracle SEPS wallets or ephemeral containers, simulating offline CI/CD without cloud dependencies.",
            "et": "Platvorm kasutab Git-keskset töövoogu: ametlikud SQLcl split-ekspordid, deklaratiivsed Liquibase muudatuste logid (`controller.xml`) ja APEXlang AST valideerimine. Paroole ei panda kunagi Giti; CI/CD torud ühenduvad paroolivaba SEPS Walleti või efemeersete konteinerite kaudu ilma pilvesõltuvuseta.",
            "fi": "Alusta noudattaa Git-keskeistä työnkulkua: viralliset SQLcl split-viennit, deklaratiiviset Liquibase-muutoslokit (`controller.xml`) ja APEXlang AST-tarkistukset. Salaisuuksia ei koskaan viedä Gitiin; putket käyttävät salasanatonta SEPS Walletia.",
            "sv": "Plattformen tillämpar ett Git-först-arbetsflöde med SQLcl split-exporter, Liquibase changelogs (`controller.xml`) och AST-validering. Hemligheter sparas aldrig i Git; CI/CD-pipelines använder lösenordsfria SEPS Wallets.",
            "lv": "Platforma izmanto Git darba plūsmu: SQLcl sadalītie eksporti, Liquibase izmaiņu žurnāli (`controller.xml`) un APEXlang AST validācijas. Paroles netiek glabātas Git; CI/CD izmanto bezparoļu SEPS makus.",
            "lt": "Platforma naudoja Git darbo eigą: SQLcl eksportai, Liquibase žurnalai (`controller.xml`) ir APEXlang AST patikros. Slaptažodžiai niekada nepatenka į Git; CI/CD naudoja saugią SEPS piniginę."
        },
        "code_snippet": "# Run offline local CI pipeline simulation:\n./scripts/test-local-ci.sh",
        "doc_ref": "docs/sqlcl-liquibase-guide.md",
        "links": [
            {"label": "docs/sqlcl-liquibase-guide.md", "url": "docs/sqlcl-liquibase-guide.md"},
            {"label": "scripts/test-local-ci.sh", "url": "scripts/test-local-ci.sh"}
        ]
    },

    # 10. Connecting via VS Code
    {
        "id": "faq-vscode-connection",
        "category": "beginner",
        "icon": "💻",
        "question": {
            "en": "How do I connect to databases using VS Code Oracle SQL Developer?",
            "et": "Kuidas luua andmebaasiühendus VS Code Oracle SQL Developeris?",
            "fi": "Miten muodostaa tietokantayhteys VS Code Oracle SQL Developerissa?",
            "sv": "Hur ansluter man till databaser i VS Code Oracle SQL Developer?",
            "lv": "Kā izveidot savienojumu ar datubāzēm VS Code Oracle SQL Developer?",
            "lt": "Kaip prisijungti prie duomenų bazių VS Code Oracle SQL Developer?"
        },
        "answer": {
            "en": "The platform includes an automated registration script that writes database connections directly into VS Code's extension storage (`dbtools-connections.json`) and securely stores passwords in your OS Keychain (macOS / Windows Credential Manager). Run register-connections.sh and reload VS Code to see your ready-to-use connections tree.",
            "et": "Platvormil on automaatne registreerimisskript, mis kirjutab andmebaasiühendused otse VS Code laienduse konfiguratsiooni (`dbtools-connections.json`) ning salvestab paroolid turvaliselt OS Keychaini. Käivitage register-connections.sh ja laadige VS Code uuesti.",
            "fi": "Alusta sisältää automaattisen rekisteröintiskriptin, joka tallentaa tietokantayhteydet suoraan VS Coden asetuksiin (`dbtools-connections.json`) ja salasanat OS Keychainiin. Suorita register-connections.sh ja päivitä VS Code.",
            "sv": "Plattformen har ett automatiserat registreringsskript som skriver anslutningar direkt till VS Code (`dbtools-connections.json`) och sparar lösenord säkert i OS Keychain. Kör register-connections.sh och ladda om VS Code.",
            "lv": "Platforma piedāvā automātisku reģistrācijas skriptu, kas konfigurē savienojumus tieši VS Code (`dbtools-connections.json`) un paroles saglabā sistēmas atslēgu glabātavā. Palaidiet register-connections.sh.",
            "lt": "Platforma turi automatinį registracijos skriptą, kuris įrašo ryšius tiesiai į VS Code (`dbtools-connections.json`) ir išsaugo slaptažodžius sistemos raktinėje. Paleiskite register-connections.sh."
        },
        "code_snippet": "# Register connections automatically into VS Code:\n./scripts/register-connections.sh\n# Test connection via CLI:\n./scripts/sqlcl.sh /@DB_PROXY_DEV",
        "doc_ref": "docs/vscode-oracle-developer-guide.md",
        "links": [
            {"label": "docs/vscode-oracle-developer-guide.md", "url": "docs/vscode-oracle-developer-guide.md"},
            {"label": "scripts/register-connections.sh", "url": "scripts/register-connections.sh"}
        ]
    },

    # 11. Enterprise Corporate Proxy & Artifactory
    {
        "id": "faq-enterprise-proxy-artifactory",
        "category": "dba_security",
        "icon": "🏢",
        "question": {
            "en": "Can this platform run behind corporate TLS-inspecting proxies and private Artifactory?",
            "et": "Kas platvorm töötab ettevõtte TLS-kontrolli teostavate prokside ja privaatse Artifactory taga?",
            "fi": "Toimiiko alusta yrityksen TLS-tarkastusta tekevien välityspalvelinten ja privaatti-Artifactoryn takana?",
            "sv": "Fungerar plattformen bakom företagets TLS-inspekterande proxys och privata Artifactory?",
            "lv": "Vai platforma darbojas aiz uzņēmuma TLS pārbaudes starpniekserveriem un privātā Artifactory?",
            "lt": "Ar platforma veikia už įmonės TLS tikrinančių tarpinių serverių ir privataus Artifactory?"
        },
        "answer": {
            "en": "Yes. The platform follows Rule 4 (Ephemeral Container Fallback) and Enterprise Standards. All container image references are configurable via YAML profiles or environment variables (e.g., pointing to internal Artifactory or Harbor mirrors), corporate CA bundles are automatically injected into WSL2 and containers, and HTTP_PROXY/HTTPS_PROXY settings are respected.",
            "et": "Jah. Platvorm järgib Reeglit 4 (efemeerse konteineri muster) ja ettevõtte standardeid. Kõik konteineritõmmiste aadressid on suunatavad ettevõtte sisesesse Artifactorysse või Harborisse, korporatiivsed Root CA sertifikaadid seotakse konteineritega ning HTTP_PROXY muutujad võetakse arvesse.",
            "fi": "Kyllä. Kaikki konttiviittaukset voidaan ohjata yrityksen sisäiseen Artifactory- tai Harbor-rekisteriin, korporaation CA-varmenteet injektoidaan kontteihin ja HTTP_PROXY-määrityksiä noudatetaan.",
            "sv": "Ja. Alla containeravbildningar kan konfigureras mot interna Artifactory- eller Harbor-speglar, företagets CA-certifikat injiceras i containrar och HTTP_PROXY stöds fullt ut.",
            "lv": "Jā. Visus konteineru attēlus var novirzīt uz uzņēmuma iekšējo Artifactory vai Harbor, korporatīvie CA sertifikāti tiek pievienoti un tiek atbalstīti HTTP_PROXY iestatījumi.",
            "lt": "Taip. Visi konteinerių atvaizdai gali būti nukreipti į vidinį Artifactory arba Harbor registrą, įmonės CA sertifikatai integruojami į konteinerius, o HTTP_PROXY nustatymai palaikomi pilnai."
        },
        "code_snippet": "# Inspect corporate proxy and Artifactory compatibility:\n./scripts/onboard-enterprise.sh --status\n# Run non-destructive enterprise pre-flight checks:\n./scripts/test-windows-dryrun.sh",
        "doc_ref": "docs/enterprise-artifactory-and-proxy.md",
        "links": [
            {"label": "docs/enterprise-artifactory-and-proxy.md", "url": "docs/enterprise-artifactory-and-proxy.md"},
            {"label": "scripts/onboard-enterprise.sh", "url": "scripts/onboard-enterprise.sh"}
        ]
    },

    # 12. Windows Native WSL2 Filesystem Rule
    {
        "id": "faq-windows-wsl2-filesystem",
        "category": "troubleshooting",
        "icon": "🪟",
        "question": {
            "en": "Why must the repository be cloned in WSL2 ext4 and never under /mnt/c/?",
            "et": "Miks peab repositoorium asuma WSL2 ext4 failisüsteemis ja MITTE /mnt/c/ all?",
            "fi": "Miksi tietovarasto on kloonattava WSL2 ext4 -järjestelmään eikä polkuun /mnt/c/?",
            "sv": "Varför måste repot klonas i WSL2 ext4 och INTE under /mnt/c/?",
            "lv": "Kāpēc repozitorijs jāklonē WSL2 ext4, nevis zem /mnt/c/?",
            "lt": "Kodėl saugykla turi būti klonuojama WSL2 ext4, o NE po /mnt/c/?"
        },
        "answer": {
            "en": "In accordance with Rule 14, execution from the Windows host mount (`/mnt/c/...`) is strictly prohibited. Plan9 (9P) translation between Linux and NTFS causes severe I/O slowdowns (10x–50x slower) and strips POSIX file permissions, breaking SEPS Wallet security (`chmod 0600` failure). Always clone inside `~/oracle-free-db-in-prod`.",
            "et": "Reegli 14 järgi on Windowsi kettahaake (`/mnt/c/...`) alt käivitamine rangelt keelatud. Plan9 (9P) sild Linuxi ja NTFS-i vahel on 10–50 korda aeglasem ning nullib Linuxi failiõigused, mistõttu SEPS Wallet ei toimi (`chmod 0600` ebaõnnestub). Kloonige repo alati kasutaja kodukausta `~/oracle-free-db-in-prod`.",
            "fi": "Säännön 14 mukaan Windows-liitospolun (`/mnt/c/...`) käyttö on ehdottomasti kielletty. Plan9-tiedostosillan I/O on 10–50x hitaampi ja se poistaa POSIX-oikeudet, mikä rikkoo SEPS Walletin (`chmod 0600`). Kloonaa aina kotihakemistoon `~/`.",
            "sv": "Enligt Regel 14 är körning från Windows-monteringen (`/mnt/c/...`) strängt förbjuden. Plan9-översättningen är 10–50x långsammare och tar bort Linux-rättigheter (`chmod 0600`). Klona alltid i hemkatalogen `~/`.",
            "lv": "Saskaņā ar 14. noteikumu palaišana no Windows montējuma (`/mnt/c/...`) ir aizliegta. Plan9 slānis ir 10–50x lēnāks un noņem POSIX tiesības (`chmod 0600`). Vienmēr klonējiet savā mājas mapē `~/`.",
            "lt": "Pagal 14 taisyklę vykdymas iš Windows prijungimo (`/mnt/c/...`) yra griežtai draudžiamas. Plan9 I/O yra 10–50 kartų lėtesnis ir panaikina POSIX teises (`chmod 0600`). Visada klonuokite namų aplanke `~/`."
        },
        "code_snippet": "# Clone inside native WSL2 Linux filesystem:\ncd ~\ngit clone https://github.com/allanlahe/oracle-free-db-in-prod.git\ncd oracle-free-db-in-prod",
        "doc_ref": "docs/windows-wsl2-enterprise-setup.md",
        "links": [
            {"label": "docs/windows-wsl2-enterprise-setup.md", "url": "docs/windows-wsl2-enterprise-setup.md"},
            {"label": "scripts/check-prerequisites.sh", "url": "scripts/check-prerequisites.sh"}
        ]
    }
]

def get_faq_catalog():
    """Returns the master FAQ catalog list."""
    return FAQ_ITEMS

def get_faq_categories():
    """Returns the FAQ categories."""
    return FAQ_CATEGORIES

def generate_markdown_faq(ws, lang="en"):
    """Generates a complete markdown FAQ document for a specific language."""
    titles = {
        "en": "Platform Frequently Asked Questions (FAQ)",
        "et": "Platvormi Korduma Kippuvad Küsimused (KKK)",
        "fi": "Alustan Usein Kysytyt Kysymykset (UKK)",
        "sv": "Vanliga Frågor och Svar (FAQ)",
        "lv": "Biežāk Uzdotie Jautājumi (BUJ)",
        "lt": "Dažniausiai Užduodami Klausimai (DUK)"
    }
    subtitles = {
        "en": "Single Source of Truth (SSOT) covering architecture, zero-trust security, beginner onboarding, and troubleshooting.",
        "et": "Tsentraalne infobaas (SSOT), mis katab arhitektuuri, Zero-Trust turvalisust, alustamist ja tõrkeotsingut.",
        "fi": "Keskitetty tietolähde (SSOT), joka kattaa arkkitehtuurin, Zero-Trust-tietoturvan, aloituksen ja vianmäärityksen.",
        "sv": "Central informationskälla (SSOT) för arkitektur, Zero-Trust-säkerhet, introduktion och felsökning.",
        "lv": "Vienotais informācijas avots (SSOT) par arhitektūru, Zero-Trust drošību, darba sākšanu un traucējummeklēšanu.",
        "lt": "Vieningas informacijos šaltinis (SSOT), apimantis architektūrą, Zero-Trust saugumą, pradžią ir trikčių šalinimą."
    }

    switcher = "[ 🇬🇧 English ](file://" + os.path.join(ws, "docs/faq.md") + ") | " \
               "[ 🇪🇪 Eesti ](file://" + os.path.join(ws, "docs/et/faq.md") + ") | " \
               "[ 🇫🇮 Suomi ](file://" + os.path.join(ws, "docs/fi/faq.md") + ") | " \
               "[ 🇸🇪 Svenska ](file://" + os.path.join(ws, "docs/sv/faq.md") + ") | " \
               "[ 🇱🇻 Latviešu ](file://" + os.path.join(ws, "docs/lv/faq.md") + ") | " \
               "[ 🇱🇹 Lietuvių ](file://" + os.path.join(ws, "docs/lt/faq.md") + ")"

    lbl_answer = {
        "en": "Answer", "et": "Vastus", "fi": "Vastaus",
        "sv": "Svar", "lv": "Atbilde", "lt": "Atsakymas"
    }[lang]

    lbl_commands = {
        "en": "Helpful Commands", "et": "Kasulikud käsud", "fi": "Hyödylliset komennot",
        "sv": "Nyttiga kommandon", "lv": "Noderīgas komandas", "lt": "Naudingos komandos"
    }[lang]

    lbl_links = {
        "en": "Related Documentation & Scripts", "et": "Seotud dokumentatsioon ja skriptid",
        "fi": "Liittyvät dokumentit ja skriptit", "sv": "Relaterad dokumentation och skript",
        "lv": "Saistītā dokumentācija un skripti", "lt": "Susijusi dokumentacija ir skriptai"
    }[lang]

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

    # Category jump index
    cat_jumps = []
    for cat in FAQ_CATEGORIES:
        if cat["id"] == "all":
            continue
        c_label = cat["labels"].get(lang, cat["labels"]["en"])
        cat_jumps.append(f"[{c_label}](#{cat['id']})")
    lines.append(f"**Jump to category:** {' • '.join(cat_jumps)}")
    lines.append("")
    lines.append("---")
    lines.append("")

    for cat in FAQ_CATEGORIES:
        if cat["id"] == "all":
            continue
        c_label = cat["labels"].get(lang, cat["labels"]["en"])
        cat_items = [i for i in FAQ_ITEMS if i["category"] == cat["id"]]
        if not cat_items:
            continue

        lines.append(f"<a id=\"{cat['id']}\"></a>")
        lines.append(f"## {c_label}")
        lines.append("")

        for item in cat_items:
            q_text = item["question"].get(lang, item["question"]["en"])
            a_text = item["answer"].get(lang, item["answer"]["en"])
            icon = item.get("icon", "❓")
            cat_id = cat['id']
            item_id = item.get("id", f"faq-{cat_id}")
            lines.append(f'<details class="faq-item" id="{item_id}" data-cat="{cat_id}">')
            lines.append(f'<summary class="faq-summary"><strong>{icon} {q_text}</strong> <span class="faq-cat-tag">{c_label}</span></summary>')
            lines.append("")
            lines.append('<div class="faq-body">')
            lines.append("")
            lines.append(f"**{lbl_answer}:** {a_text}")
            lines.append("")

            if item.get("code_snippet"):
                lines.append(f"**{lbl_commands}:**")
                lines.append("```bash")
                for c_line in item["code_snippet"].split("\n"):
                    lines.append(f"{c_line}")
                lines.append("```")
                lines.append("")

            if item.get("links"):
                link_strs = [f"[{l['label']}](file://{os.path.join(ws, l['url'])})" for l in item["links"]]
                lines.append(f"**{lbl_links}:** {', '.join(link_strs)}")
                lines.append("")

            lines.append("</div>")
            lines.append("</details>")
            lines.append("")

    return "\n".join(lines) + "\n"

def write_all_markdown_faqs(ws):
    """Writes docs/faq.md and docs/{et,fi,sv,lv,lt}/faq.md."""
    paths = {
        "en": os.path.join(ws, "docs", "faq.md"),
        "et": os.path.join(ws, "docs", "et", "faq.md"),
        "fi": os.path.join(ws, "docs", "fi", "faq.md"),
        "sv": os.path.join(ws, "docs", "sv", "faq.md"),
        "lv": os.path.join(ws, "docs", "lv", "faq.md"),
        "lt": os.path.join(ws, "docs", "lt", "faq.md")
    }

    for lang, p in paths.items():
        os.makedirs(os.path.dirname(p), exist_ok=True)
        content = generate_markdown_faq(ws, lang)
        with open(p, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"✅ Generated FAQ markdown: {p}")

if __name__ == "__main__":
    ws = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.."))
    write_all_markdown_faqs(ws)
