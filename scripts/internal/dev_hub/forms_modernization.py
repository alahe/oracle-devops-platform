# -*- coding: utf-8 -*-
"""
Oracle DevOps Platform - Forms Modernization Presentation & Strategy
Contains:
1. FORMS_SLIDES_CONTENT: 13-slide interactive presentation deck (EN, ET, FI, SV, LV, LT)
2. FORMS_ROLE_TRACKS: 5 role tracks (all, exec, dev, biz, ops)
3. FORMS_SUMMARY_HTML: Rich textual strategy with high-contrast Mermaid diagrams and comparison tables
"""

FORMS_ROLE_TRACKS = {
    "all": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13],
    "exec": [1, 2, 8, 11, 12],
    "dev": [1, 4, 5, 8, 10, 13],
    "biz": [1, 3, 6, 7, 11],
    "ops": [1, 4, 9, 10, 12, 13]
}

FORMS_SLIDES_CONTENT = {
    1: {
        "badge": {
            "en": "🌟 SLIDE 1 / 13 • VISION &amp; STARTING POINT",
            "et": "🌟 SLAID 1 / 13 • VISIOON JA LÄHTEOLUKORD",
            "fi": "🌟 DIA 1 / 13 • VISIO JA LÄHTÖKOHTA",
            "sv": "🌟 BILD 1 / 13 • VISION OCH UTGÅNGSPUNKT",
            "lv": "🌟 SLAIDS 1 / 13 • VĪZIJA UN IZEJAS PUNKTS",
            "lt": "🌟 SKAIDRĖ 1 / 13 • VIZIJA IR PRADINĖ PADĖTIS"
        },
        "title": {
            "en": "Modernizing 150 Oracle Forms: Why PL/SQL Packages Are Pure Gold",
            "et": "150 Oracle Forms vormi moderniseerimine: Miks PL/SQL paketid on kullaauk",
            "fi": "150 Oracle Forms -lomakkeen modernisointi: Miksi PL/SQL-paketit ovat kultakaivos",
            "sv": "Modernisering av 150 Oracle Forms: Varför PL/SQL-paket är rent guld",
            "lv": "150 Oracle Forms modernizācija: Kāpēc PL/SQL pakotnes ir tīrs zelts",
            "lt": "150 Oracle Forms modernizavimas: Kodėl PL/SQL paketai yra tikras auksas"
        },
        "lead": {
            "en": "Our 25-year-old core system has already moved 80–90% of business logic into database packages. APEX utilizes PL/SQL and REST APIs, while the remaining 10–20% is centralized during migration.",
            "et": "Meie 25-aastane põhisüsteem on juba 80–90% äriloogikast viinud andmebaasipakettidesse. APEX rakendab PL/SQL ja REST API loogikat, viies ka ülejäänud 10–20% tsentraalselt baasi.",
            "fi": "25-vuotias ydinjärjestelmämme on jo siirtänyt 80–90% liiketoimintalogiikasta tietokantapaketteihin. APEX hyödyntää PL/SQL- ja REST API -logiikkaa, ja loput 10–20% keskitetään siirtymässä.",
            "sv": "Vårt 25-åriga kärnsystem har redan flyttat 80–90% av affärslogiken till databasen. APEX utnyttjar PL/SQL och REST API:er, och resterande 10–20% centraliseras under migreringen.",
            "lv": "Mūsu 25 gadus vecā sistēma jau 80–90% biznesa loģikas ir pārcēlusi uz datubāzes pakotnēm. APEX izmanto PL/SQL un REST API, bet atlikušie 10–20% tiek centralizēti migrācijas laikā.",
            "lt": "Mūsų 25 metų sistema jau 80–90% verslo logikos perkėlė į duomenų bazės paketus. APEX naudoja PL/SQL ir REST API, o likę 10–20% centralizuojami migracijos metu."
        },
        "cards": [
            {
                "icon": "🏛️",
                "kpi": "80–90% ÄRITÕDE BAASIS",
                "title": {
                    "en": "Rock-Solid Business Logic",
                    "et": "Läbiproovitud äriloogika",
                    "fi": "Koeteltu liiketoimintalogiikka",
                    "sv": "Beprövad affärslogik",
                    "lv": "Pārbaudīta biznesa loģika",
                    "lt": "Patikrinta verslo logika"
                },
                "desc": {
                    "en": "25 years of edge cases, tax rules, and domain logic reside 80–90% in PL/SQL packages. The remaining 10–20% in forms is centralized to DB or REST APIs during migration.",
                    "et": "25 aasta erandid, maksureeglid ja äriloogika elavad 80–90% ulatuses PL/SQL pakettides. Vormidesse jäänud 10–20% viiakse üleminekul samuti baasi või REST API kihti.",
                    "fi": "25 vuoden säännöt ja poikkeukset elävät 80–90%:sti PL/SQL-paketeissa. Vain 10–20% siirretään kantaan tai REST API -kerrokseen.",
                    "sv": "25 års regler och undantag finns till 80–90% i PL/SQL. Resterande 10–20% flyttas till databasen eller REST API under migreringen.",
                    "lv": "25 gadu loģika par 80–90% atrodas PL/SQL pakotnēs. Atlikušie 10–20% tiek pārcelti uz datubāzi vai REST API.",
                    "lt": "25 metų logika 80–90% gyvena PL/SQL paketuose. Likę 10–20% perkeliami į DB arba REST API."
                }
            },
            {
                "icon": "🎯",
                "kpi": "150 VORMI → APEX & REST",
                "title": {
                    "en": "Forms Is Only the UI",
                    "et": "Forms on vaid ekraanivorm",
                    "fi": "Forms on vain näyttökerros",
                    "sv": "Forms är bara ett presentationslager",
                    "lv": "Forms ir tikai ekrāna slānis",
                    "lt": "Forms yra tik sąsajos sluoksnis"
                },
                "desc": {
                    "en": "Forms served as a window into the database. Oracle APEX directly leverages existing PL/SQL or REST API logic as a modern web UI.",
                    "et": "Vana Forms oli vaid aken andmebaasi. Oracle APEX kasutab ära olemasoleva PL/SQL või REST API loogika kaasaegse ja kiire veebiliidesena.",
                    "fi": "Forms toimi vain ikkunana tietokantaan. APEX hyödyntää suoraan olemassa olevaa PL/SQL- tai REST API -logiikkaa modernina web-liittymänä.",
                    "sv": "Forms var bara ett fönster till databasen. APEX utnyttjar befintlig PL/SQL- eller REST API-logik som ett modernt webbgränssnitt.",
                    "lv": "Forms bija tikai logs uz datubāzi. APEX izmanto esošo PL/SQL vai REST API loģiku kā modernu tīmekļa saskarni.",
                    "lt": "Forms buvo tik langas į duomenų bazę. APEX tiesiogiai naudoja esamą PL/SQL arba REST API logiką kaip modernią saityno sąsają."
                }
            },
            {
                "icon": "👥",
                "kpi": "5 DEV + 3 ANALYST + 1 JAVA",
                "title": {
                    "en": "Core Team & Java Anchor",
                    "et": "Põhitiim & Java tugisammas",
                    "fi": "Ydintiimi & Java-tukipilari",
                    "sv": "Kärnteam & Java-stöttepelare",
                    "lv": "Pamata komanda & Java balsts",
                    "lt": "Pagrindinė komanda ir Java ramstis"
                },
                "desc": {
                    "en": "5 veteran DB engineers, 3 business analysts, and 1 senior Java consultant. The Java consultant maintains the batch portal (freeing DB developers 100% for Forms migration) and builds future microservices.",
                    "et": "5 kogenud andmebaasiinseneri, 3 analüütikut ja 1 kogenud Java konsultant/arendaja. Java konsultant hoiab töös batch-portaali (vabastades DB arendajad 100% Forms-to-APEX tööle) ja jääb tiimi ehitama mikroteenuseid.",
                    "fi": "5 kokenutta DB-kehittäjää, 3 analyytikkoa ja 1 senior Java-konsultti. Java-konsultti hoitaa batch-portaalia (vapauttaen DB-tiimin Formsille) ja rakentaa tulevia mikropalveluja.",
                    "sv": "5 erfarna DB-utvecklare, 3 analytiker och 1 senior Java-konsult. Java-konsulten driver batch-portalen (frigör DB-teamet för Forms) och bygger framtida mikrotjänster.",
                    "lv": "5 DB inženieri, 3 analītiķi un 1 vecākais Java konsultants. Java konsultants uztur batch portālu (atbrīvojot DB komandu Forms) un nākotnē veido mikropakalpojumus.",
                    "lt": "5 DB inžinieriai, 3 analitikai ir 1 vyresnysis Java konsultantas. Java konsultantas palaiko batch portalą (atlaisvina DB komandą Forms) ir ateityje kuria mikropaslaugas."
                }
            }
        ],
        "speaker_notes": {
            "en": "🎯 Core Takeaway: 80–90% of business logic already resides safely in the database. APEX leverages PL/SQL and REST APIs directly, while the remaining 10–20% is centralized into packages during migration.<br/>💡 Talking Points: 5 DB engineers, 3 business analysts, and 1 senior Java consultant form our autonomous strike team. Retaining the Java consultant keeps the existing batch portal stable, freeing DB developers 100% for Forms, and provides permanent microservices expertise.<br/>⚠️ Key Emphasis: We are not starting from scratch; we build on 25 years of battle-tested domain logic.",
            "et": "🎯 Peamine sõnum: 80–90% äriloogikast on juba andmebaasis turvaliselt olemas. APEX võtab otse kasutusele PL/SQL ja REST API kihid ning puuduv 10–20% tsentraliseeritakse migratsiooniga samuti baasi.<br/>💡 Rääkimispunktid: 5 DB inseneri, 3 analüütikut ja 1 kogenud Java konsultant moodustavad autonoomse tiimi. Java konsultandi säilitamine hoiab praeguse batch-portaali töös, vabastades andmebaasiarendajad 100% Formsi üleviimisele, ning tagab püsiva võimekuse ehitada väliseid mikroteenuseid.<br/>⚠️ Mida rõhutada: Me ei alusta puhtalt lehelt – me toetume 25 aasta testitud ärireeglitele.",
            "fi": "🎯 Pääviesti: 80–90% liiketoimintalogiikasta on jo tietokannassa. APEX hyödyntää PL/SQL- ja REST API -kerroksia suoraan, ja puuttuva 10–20% siirretään paketteihin.<br/>💡 Puhujan muistiinpanot: 5 DB-kehittäjää, 3 analyytikkoa ja 1 kokenut Java-konsultti muodostavat tiimin. Java-konsultti ylläpitää batch-portaalia, jolloin DB-tiimi voi keskittyä 100% Formsiin, ja rakentaa jatkossa mikropalveluja.<br/>⚠️ Tärkeä painotus: Emme aloita alusta.",
            "sv": "🎯 Huvudbudskap: 80–90% av affärslogiken finns redan säkert i databasen. APEX utnyttjar PL/SQL och REST API direkt, och resterande 10–20% centraliseras under migreringen.<br/>💡 Talarpunkter: 5 DB-utvecklare, 3 analytiker och 1 senior Java-konsult skapar ett starkt internt team. Java-konsulten sköter batch-portalen så DB-teamet kan fokusera 100% på Forms, och bygger framtida mikrotjänster.<br/>⚠️ Viktig betoning: Vi börjar inte från noll.",
            "lv": "🎯 Galvenais vēstījums: 80–90% biznesa loģikas jau droši atrodas datubāzē. APEX tieši izmanto PL/SQL un REST API, bet atlikušie 10–20% tiek centralizēti migrācijas gaitā.<br/>💡 Runātāja piezīmes: 5 DB inženieri, 3 analītiķi un 1 Java konsultants nodrošina pilnu jaudu. Java konsultants uztur batch portālu, atbrīvojot DB komandu 100% Forms darbam, un nākotnē veido mikropakalpojumus.<br/>⚠️ Uzsvars: Mēs nesākam no nulles.",
            "lt": "🎯 Pagrindinė žinutė: 80–90% verslo logikos jau saugiai gyvena duomenų bazėje. APEX tiesiogiai naudoja PL/SQL ir REST API, o likę 10–20% centralizuojami migracijos metu.<br/>💡 Pranešėjo pastabos: 5 DB inžinieriai, 3 analitikai ir 1 Java konsultantas sudaro pajėgią komandą. Java konsultantas prižiūri batch portalą, atlaisvina DB komandą Forms darbams ir vėliau kuria mikropaslaugas.<br/>⚠️ Svarbus akcentas: Mes nepradedame nuo nulio."
        }
    },
    2: {
        "badge": {
            "en": "💼 SLIDE 2 / 13 • STRATEGY, TCO &amp; PROVEN PLATFORM",
            "et": "💼 SLAID 2 / 13 • JUHTKONNA VALIKUD &amp; OLEMASOLEV TARISTU",
            "fi": "💼 DIA 2 / 13 • JOHDON VALINNAT &amp; NYKYINEN ALUSTA",
            "sv": "💼 BILD 2 / 13 • LEDNINGENS VAL &amp; BEFINTLIG INFRASTRUKTUR",
            "lv": "💼 SLAIDS 2 / 13 • VADĪBAS IZVĒLE &amp; ESOŠĀ INFRASTRUKTŪRA",
            "lt": "💼 SKAIDRĖ 2 / 13 • VADOVYBĖS PASIRINKIMAS IR ESAMA INFRASTRUKTŪRA"
        },
        "title": {
            "en": "Management's 3 Paths: Avoiding the Neighbor Product's 10-Year Trap",
            "et": "Juhtkonna 3 valikut: Naabertoote 10-aastase lõksu vältimine",
            "fi": "Johdon 3 vaihtoehtoa: Naapurituotteen 10 vuoden ansan välttäminen",
            "sv": "Ledningens 3 vägar: Undvik grannprojektets 10-åriga fälla",
            "lv": "Vadības 3 ceļi: Izvairīšanās no kaimiņu produkta 10 gadu slazda",
            "lt": "Vadovybės 3 keliai: Kaip išvengti kaimynų 10 metų spąstų"
        },
        "lead": {
            "en": "A full rewrite into Vue/Java failed next door (4 years spent, 5–10 years to go). APEX on our existing platform is 100% production-ready with 0 new components, 0 DR changes, and 0€ license fees.",
            "et": "Naabertoote ümberkirjutus Vue/Java virna kukkus läbi (4 aastat tehtud, 5–10 aastat minna). APEX ja olemasolev taristu on 100% valmis ilma uute komponentide, DR-tellimuste või lisalitsentsideta.",
            "fi": "Naapurituotteen uudelleenkirjoitus Vue/Javaan epäonnistui (4v tehty, 5–10v jäljellä). APEX ja nykyinen alusta ovat 100% valmiita ilman uusia komponentteja tai DR-tilauksia.",
            "sv": "Omskrivning i Vue/Java misslyckades hos grannen (4 år har gått, 5–10 kvar). APEX och befintlig infrastruktur är 100% produktionsredo utan nya komponenter eller DR-beställningar.",
            "lv": "Pārrakstīšana uz Vue/Java blakus nodaļā cieta neveiksmi (4 gadi pagājuši, 5–10 vēl priekšā). APEX un esošā infrastruktūra ir 100% gatava bez jauniem komponentiem vai DR pasūtījumiem.",
            "lt": "Perrašymas į Vue/Java pas kaimynus patyrė nesėkmę (4 metai praėjo, 5–10 liko). APEX ir esama infrastruktūra yra 100% paruošta be naujų komponentų ar DR užsakymų."
        },
        "comparison_diagram": {
            "title": {
                "en": "Architectural Strategy Comparison",
                "et": "Strateegiliste valikute võrdlus",
                "fi": "Strategisten valintojen vertailu",
                "sv": "Jämförelse av strategiska val",
                "lv": "Stratēģisko izvēļu salīdzinājums",
                "lt": "Strateginių pasirinkimų palyginimas"
            },
            "bad": {
                "label": {
                    "en": "PATH A: REWRITE TO VUE/JAVA (NEIGHBOR DISASTER)",
                    "et": "VALIK A: ÜMBERKIRJUTUS VUE/JAVA (NAABERTOODE)",
                    "fi": "VAIHTOEHTO A: UUDELLEENKIRJOITUS VUE/JAVAAN (NAAPURITUOTE)",
                    "sv": "VÄG A: OMSKRIVNING I VUE/JAVA (GRANNFIASKO)",
                    "lv": "CEĻŠ A: PĀRRAKSTĪŠANA UZ VUE/JAVA (KATASTROFA)",
                    "lt": "KELIAS A: PERRAŠYMAS Į VUE/JAVA (NESĖKMĖ)"
                },
                "nodes": [
                    {
                        "icon": "💸",
                        "title": {"en": "Millions Burned", "et": "Miljonid kulutatud", "fi": "Miljoonia poltettu", "sv": "Miljoner brända", "lv": "Miljoni iztērēti", "lt": "Sudeginti milijonai"},
                        "sub": {"en": "4 years spent, 5-10 yrs left", "et": "4a tehtud, 5–10a veel minna", "fi": "4v mennyt, 5-10v jäljellä", "sv": "4 år har gått, 5-10 kvar", "lv": "4 gadi pagājuši, vēl 5-10", "lt": "4 metai praėjo, dar 5-10"}
                    },
                    {
                        "icon": "❄️",
                        "title": {"en": "Business Frozen", "et": "Äriarendus külmunud", "fi": "Kehitys jäässä", "sv": "Affären står still", "lv": "Bizness iesaldēts", "lt": "Verslo plėtra įšaldyta"},
                        "sub": {"en": "0 new features delivered", "et": "0 uut ärifunktsiooni turule", "fi": "0 uutta ominaisuutta", "sv": "0 nya funktioner levererade", "lv": "0 jaunu iespēju", "lt": "0 naujų funkcijų"}
                    },
                    {
                        "icon": "📋",
                        "title": {"en": "Specification Trap", "et": "Spetsifikatsioonilõks", "fi": "Määrittelyansa", "sv": "Specifikationsfälla", "lv": "Specifikāciju slazds", "lt": "Specifikacijų spąstai"},
                        "sub": {"en": "Agencies lack DB context, laws overtake", "et": "Konsultandid ei tunne backend'i, seadused jooksevad eest", "fi": "Konsultit eivät tunne kantaa, lakimuutokset ajavat ohi", "sv": "Konsulter saknar backend-kunskap, lagkrav springer förbi", "lv": "Konsultanti nepārzina backend, likumi apsteidz", "lt": "Konsultantai nepažįsta backend, įstatymai aplenkia"}
                    }
                ]
            },
            "good": {
                "label": {
                    "en": "PATH B: EVOLUTION VIA APEX & EXISTING PLATFORM",
                    "et": "VALIK B: EVOLUTSIOON APEX & OLEMASOLEV TARISTU",
                    "fi": "VAIHTOEHTO B: EVOLUUTIO APEX & NYKYINEN ALUSTA",
                    "sv": "VÄG B: EVOLUTION MED APEX & BEFINTLIG INFRASTRUKTUR",
                    "lv": "CEĻŠ B: EVOLŪCIJA AR APEX & ESOŠĀ INFRASTRUKTŪRA",
                    "lt": "KELIAS B: EVOLIUCIJA SU APEX IR ESAMA INFRASTRUKTŪRA"
                },
                "nodes": [
                    {
                        "icon": "⚡",
                        "title": {"en": "10-15 Month Delivery", "et": "10–15 kuud valmimiseni", "fi": "10-15 kk valmistumiseen", "sv": "Klart på 10-15 månader", "lv": "Gatavs 10-15 mēnešos", "lt": "Parengta per 10-15 mėn."},
                        "sub": {"en": "Iterative sprint demos", "et": "2-nädalased sprindid & demod", "fi": "2 viikon sprintit", "sv": "2-veckors sprintar", "lv": "2 nedēļu sprinti", "lt": "2 savaičių sprintai"}
                    },
                    {
                        "icon": "🏢",
                        "title": {"en": "Environment 100% Ready", "et": "Keskkond 100% valmis", "fi": "Ympäristö 100% valmis", "sv": "Miljön är 100% redo", "lv": "Vide ir 100% gatava", "lt": "Aplinka 100% paruošta"},
                        "sub": {"en": "0 new components, 0 new DR orders", "et": "0 lisakomponenti, 0 uut DR-tellimust", "fi": "0 uutta komponenttia, 0 uutta DR-tilausta", "sv": "0 nya komponenter, 0 nya DR-beställningar", "lv": "0 jaunu komponentu, 0 jaunu DR pasūtījumu", "lt": "0 naujų komponentų, 0 naujų DR užsakymų"}
                    },
                    {
                        "icon": "🧹",
                        "title": {"en": "Radical Simplification", "et": "Lihtsustatud arhitektuur", "fi": "Yksinkertaistettu arkkitehtuuri", "sv": "Förenklad arkitektur", "lv": "Vienkāršota arhitektūra", "lt": "Supaprastinta architektūra"},
                        "sub": {"en": "Forms, batch portal & WebLogic vanish", "et": "Forms, batch-portaal ja WebLogic kaovad", "fi": "Forms, batch-portaali ja WebLogic poistuvat", "sv": "Forms, batch-portal och WebLogic avvecklas", "lv": "Forms, batch portāls un WebLogic pazūd", "lt": "Forms, batch portalas ir WebLogic pašalinami"}
                    }
                ]
            }
        },
        "speaker_notes": {
            "en": "🎯 Core Takeaway: The neighbor team's disaster with Vue/Java proves that full rewrites with external consultancies fall into specification traps and lose business focus as legal requirements and platform lifecycles move ahead.<br/>💡 Talking Points: Our environment is already 100% production-ready. We do not need architectural overhauls, new DR procurement, or alien components. Forms and batch portal are retired alongside WebLogic, dramatically simplifying operational complexity.<br/>⚠️ Key Emphasis: We eliminate multi-million euro waste, prevent project failure, and retain total mastery over our core system.",
            "et": "🎯 Peamine sõnum: Naabertoote katastroof Vue/Java virnaga tõestab, et täielik ümberkirjutamine väliste konsultantidega viib spetsifikatsioonilõksu ja fookuse kaoni – seadusemuudatused ja elutsükkel jooksevad eest ära.<br/>💡 Rääkimispunktid: Meie keskkond on juba 100% valmis. Me ei pea tegema arhitektuurseid muudatusi, ei pea tellima uusi DR-võimekusi ega lisama ühtegi võõrast komponenti. Forms ja batch-portaal eemaldatakse koos WebLogicuga, mis teeb süsteemi arhitektuurselt puhtamaks ja lihtsamaks.<br/>⚠️ Mida rõhutada: Säästame miljoneid eurosid, välistame riskid ja säilitame täieliku kontrolli oma süsteemi üle.",
            "fi": "🎯 Pääviesti: Naapurituotteen katastrofi Vue/Java-pinolla todistaa, että täysi uudelleenkirjoitus ulkoisilla konsulteilla johtaa määrittelyansaan ja fokuksen hukkumiseen lakimuutosten ajaessa ohi.<br/>💡 Puhujan muistiinpanot: Ympäristömme on jo 100% valmis. Emme tarvitse arkkitehtuurimuutoksia tai uusia DR-tilauksia. Forms, batch-portaali ja WebLogic poistuvat yksinkertaistaen järjestelmää.<br/>⚠️ Tärkeä painotus: Säästämme miljoonia ja hallitsemme omaa järjestelmäämme.",
            "sv": "🎯 Huvudbudskap: Grannprojektets haveri med Vue/Java visar att omskrivning med externa konsulter leder till specifikationsfällor och förlorat affärsfokus när lagkrav och livscykel springer ifrån.<br/>💡 Talarpunkter: Vår miljö är redan 100% produktionsklar. Inga nya arkitekturförändringar, DR-beställningar eller främmande komponenter krävs. Forms och batch-portalen avvecklas med WebLogic, vilket förenklar allt.<br/>⚠️ Viktig betoning: Vi sparar miljoner och behåller full kontroll över systemet.",
            "lv": "🎯 Galvenais vēstījums: Kaimiņu projekta neveiksme ar Vue/Java pierāda, ka pilnīga pārrakstīšana noved pie specifikāciju slazda un fokusa zaudēšanas likumu un dzīves cikla izmaiņu dēļ.<br/>💡 Runātāja piezīmes: Mūsu vide jau ir 100% gatava. Nav vajadzīgas arhitektūras izmaiņas vai jauni DR pasūtījumi. Forms, batch portāls un WebLogic tiek likvidēti, vienkāršojot uzturēšanu.<br/>⚠️ Uzsvars: Mēs ietaupām miljonus un saglabājam pilnu kontroli.",
            "lt": "🎯 Pagrindinė žinutė: Kaimynų katastrofa su Vue/Java įrodo, kad visiškas perrašymas su išoriniais konsultantais veda į specifikacijų spąstus ir verslo dėmesio praradimą.<br/>💡 Pranešėjo pastabos: Mūsų aplinka jau 100% paruošta. Nereikia architektūrinių pokyčių ar naujų DR užsakymų. Forms, batch portalas ir WebLogic pašalinami, supaprastinant sistemą.<br/>⚠️ Svarbus akcentas: Sutaupome milijonus ir išlaikome pilną kontrolę."
        }
    },
    3: {
        "badge": {
            "en": "📊 SLIDE 3 / 13 • QUICK WIN: REPORTS &amp; QUERIES",
            "et": "📊 SLAID 3 / 13 • QUICK WIN: ARUANDED JA PÄRINGUD",
            "fi": "📊 DIA 3 / 13 • QUICK WIN: RAPORTIT JA KYSELYT",
            "sv": "📊 BILD 3 / 13 • QUICK WIN: RAPPORTER &amp; SÖKNINGAR",
            "lv": "📊 SLAIDS 3 / 13 • QUICK WIN: ATSKAITES UN VAICĀJUMI",
            "lt": "📊 SKAIDRĖ 3 / 13 • GREITA PERGALĖ: ATASKAITOS IR UŽKLAUSOS"
        },
        "title": {
            "en": "Priority 1: Migrating ~45 Query Forms in 3–4 Weeks",
            "et": "Prioriteet 1: ~45 päringu- ja aruandevormi migratsioon 3–4 nädalaga",
            "fi": "Prioriteetti 1: ~45 kyselylomakkeen siirto 3–4 viikossa",
            "sv": "Prioritet 1: Flytta ~45 sökformulär på 3–4 veckor",
            "lv": "Prioritāte 1: ~45 vaicājumu formu migrācija 3–4 nedēļās",
            "lt": "1 prioritetas: ~45 užklausų formų migracija per 3–4 savaites"
        },
        "lead": {
            "en": "The safest, highest-impact way to start: reports and read-only searches touch 0 database transactions, provide instant 1-click Excel exports, and build user confidence.",
            "et": "Kõige turvalisem ja kiireim viis alustada: päringud ja aruanded ei muuda baasis andmeid, toovad kohese 1-kliki Excel ekspordi ja loovad kasutajates vaimustuse.",
            "fi": "Turvallisin ja nopein tapa aloittaa: kyselyt eivät muokkaa dataa, tuovat välittömän Excel-viennin ja herättävät käyttäjien luottamuksen.",
            "sv": "Det säkraste sättet att börja: rapporter rör noll databastransaktioner, ger direkt Excel-export och bygger förtroende.",
            "lv": "Visdrošākais sākums: atskaites nemaina datus, nodrošina tūlītēju Excel eksportu un iegūst lietotāju uzticību.",
            "lt": "Saugiausia pradžia: ataskaitos nekeičia duomenų, suteikia greitą Excel eksportą ir kuria pasitikėjimą."
        },
        "cards": [
            {
                "icon": "📈",
                "kpi": "~45 VORMI (30%)",
                "title": {
                    "en": "30% of All Forms",
                    "et": "30% kõigist vormidest",
                    "fi": "30% kaikista lomakkeista",
                    "sv": "30% av alla formulär",
                    "lv": "30% no visām formām",
                    "lt": "30% visų formų"
                },
                "desc": {
                    "en": "Nearly a third of our Forms system consists of simple record browsing and search screens. Ideal for early delivery.",
                    "et": "Peaaegu kolmandik vormidest on puhtad otsingu- ja vaateaknad. Ideaalne materjal kiireks esimese kuu võiduks.",
                    "fi": "Kolmasosa lomakkeista on pelkkiä selaus- ja hakuruutuja. Täydellinen ensimmäisen kuukauden voitto.",
                    "sv": "Nästan en tredjedel är bara sök- och visningsskärmar. Perfekt för snabb start.",
                    "lv": "Gandrīz trešdaļa ir vienkāršas meklēšanas formas. Ideāli pirmajam mēnesim.",
                    "lt": "Trečdalis formų yra tik paieškos langai. Idealu pirmajam mėnesiui."
                }
            },
            {
                "icon": "⚡",
                "kpi": "INTERACTIVE GRID",
                "title": {
                    "en": "Modern Interactive Grids",
                    "et": "Interaktiivsed tabelid",
                    "fi": "Interaktiiviset ruudukot",
                    "sv": "Interaktiva tabeller",
                    "lv": "Interaktīvās tabulas",
                    "lt": "Interaktyvios lentelės"
                },
                "desc": {
                    "en": "Instant column sorting, multi-criteria filtering, grouping, chart views, and CSV/Excel exports with 0 coding.",
                    "et": "Kiirfiltreerimine, veergude peitmine, rühmitamine, graafikud ja 1-klikiga Excel eksport ilma ainsatki koodirida kirjutamata.",
                    "fi": "Pikasuodatus, sarakkeiden piilotus, ryhmittely ja Excel-vienti ilman koodiriviäkään.",
                    "sv": "Direktsökning, kolumnfilter, grafer och Excel-export med noll rader kod.",
                    "lv": "Tūlītēja filtrēšana, grupēšana un Excel eksports bez programmēšanas.",
                    "lt": "Greitas filtravimas, stulpelių grupavimas ir Excel eksportas be jokio kodo."
                }
            },
            {
                "icon": "🛡️",
                "kpi": "0 TRANSAKTSIOONIRISKI",
                "title": {
                    "en": "Zero Risk to Production",
                    "et": "Null riski tootmisbaasile",
                    "fi": "Nolla riskiä tuotannolle",
                    "sv": "Noll risk för produktion",
                    "lv": "Nulle risku produkcijai",
                    "lt": "Nulis rizikos gamybai"
                },
                "desc": {
                    "en": "Read-only queries cannot corrupt data. Users experience immediate benefits while production runs uninterrupted.",
                    "et": "Lugemispäringud ei saa andmeid rikkuda. Kasutajad saavad kohese kasu, samal ajal kui igapäevatöö jätkub segamatult.",
                    "fi": "Pelkät kyselyt eivät voi korruptoida dataa. Käyttäjät näkevät hyödyn heti.",
                    "sv": "Läsåtkomst kan inte skada data. Användarna får omedelbara fördelar.",
                    "lv": "Tikai lasīšanas vaicājumi nevar sabojāt datus. Lietotāji iegūst tūlītēju labumu.",
                    "lt": "Tik skaitymo užklausos negali sugadinti duomenų. Naudotojai iškart mato naudą."
                }
            }
        ],
        "speaker_notes": {
            "en": "🎯 Core Takeaway: Start where risk is lowest and user delight is highest. Delivering ~45 report screens in Month 1 wins the business over immediately.<br/>💡 Talking Points: Show how users currently export to Excel by copy-pasting from Forms. In APEX, it is native 1-click.<br/>⚠️ Key Emphasis: Reassure DBAs that read-only queries use optimized execution plans.",
            "et": "🎯 Peamine sõnum: Alusta sealt, kus risk on null ja kasutajate rõõm maksimaalne. 45 aruandevormi valmimine 1. kuul võidab kogu organisatsiooni usalduse.<br/>💡 Rääkimispunktid: Näita, kuidas kasutajad kopeerivad vanast Formsist andmeid käsitsi Excelisse. APEXis on see 1 klikk.<br/>⚠️ Mida rõhutada: Päringud kasutavad täpselt samu optimeeritud indekseid.",
            "fi": "🎯 Pääviesti: Aloita sieltä, missä riski on pienin ja hyöty suurin.<br/>💡 Puhujan muistiinpanot: Näytä 1-klikkauksen Excel-vienti.",
            "sv": "🎯 Huvudbudskap: Börja med lägsta risk. 45 rapportskärmar klara månad 1 bygger förtroende.",
            "lv": "🎯 Galvenais vēstījums: Sāciet ar mazāko risku un lielāko labumu.",
            "lt": "🎯 Pagrindinė žinutė: Pradėkite ten, kur rizika mažiausia, o nauda didžiausia."
        }
    },
    4: {
        "badge": {
            "en": "🧙‍♂️ SLIDE 4 / 13 • GURU RULES &amp; PARADIGM SHIFT",
            "et": "🧙‍♂️ SLAID 4 / 13 • FORMS → APEX PARADIGMANIHE (GURU REEGLID)",
            "fi": "🧙‍♂️ DIA 4 / 13 • FORMS → APEX PARADIGMAMUUTOS (GURU)",
            "sv": "🧙‍♂️ BILD 4 / 13 • FORMS → APEX PARADIGMSKIFTE (GURU)",
            "lv": "🧙‍♂️ SLAIDS 4 / 13 • FORMS → APEX PARADIGMAS MAIŅA (GURU)",
            "lt": "🧙‍♂️ SKAIDRĖ 4 / 13 • FORMS → APEX PARADIGMOS POKYTIS (GURU)"
        },
        "title": {
            "en": "Forms vs APEX Architecture: 5 Non-Negotiable Rules from Migration Veterans",
            "et": "Forms vs APEX arhitektuur: 5 kriitilist reeglit 20-aastase staažiga gurult",
            "fi": "Forms vs APEX arkkitehtuuri: 5 kriittistä sääntöä 20v kokeneelta gurulta",
            "sv": "Forms vs APEX arkitektur: 5 gyllene regler från erfarna experter",
            "lv": "Forms pret APEX arhitektūru: 5 zelta likumi no ekspertiem",
            "lt": "Forms vs APEX architektūra: 5 auksinės taisyklės iš ekspertų"
        },
        "lead": {
            "en": "APEX is not web-Forms. To succeed, senior teams must master stateless sessions, optimistic locking, and declarative master-detail links.",
            "et": "APEX ei ole veebipõhine Forms. Edu saavutamiseks peab tiim omandama olekuta seansid, optimistliku lukustuse ja deklaratiivsed seosed.",
            "fi": "APEX ei ole web-Forms. Menestys vaatii tilattomuuden, optimistisen lukituksen ja deklaratiivisuuden hallintaa.",
            "sv": "APEX är inte webb-Forms. För att lyckas måste teamet förstå tillståndslöshet och optimistisk låsning.",
            "lv": "APEX nav Forms interneta pārlūkā. Jāsaprot bezstāvokļa sesijas un optimistiskā bloķēšana.",
            "lt": "APEX nėra internetinė Forms kopija. Sėkmei būtina suprasti optimistinio užrakinimo principus."
        },
        "cards": [
            {
                "icon": "🔒",
                "kpi": "OPTIMISTLIK LUKUSTUS",
                "title": {
                    "en": "Pessimistic vs Optimistic Locking",
                    "et": "Pessimistlik vs optimistlik lukk",
                    "fi": "Pessimistinen vs optimistinen lukitus",
                    "sv": "Pessimistisk vs optimistisk låsning",
                    "lv": "Pesimistiskā pret optimistisko bloķēšanu",
                    "lt": "Pesimistinis vs optimistinis užrakinimas"
                },
                "desc": {
                    "en": "Forms locked rows immediately with SELECT FOR UPDATE. APEX uses stateless checksums (Lost Update Protection) without locking DB sessions.",
                    "et": "Forms lukustas read kohe sisestamisel. APEX kasutab olekuta SHA-256 kontrollsummasid, vabastades baasi pikkadest lukkudest.",
                    "fi": "Forms lukitsi rivit heti. APEX käyttää tilattomia SHA-256 tarkistussummia ilman pitkiä tietokantalukkoja.",
                    "sv": "Forms låste rader direkt. APEX använder tillståndslösa kontrollsummor utan att blockera databasen.",
                    "lv": "Forms bloķēja rindas uzreiz. APEX izmanto kontrolsummas bez ilgstošiem blokiem.",
                    "lt": "Forms užrakindavo iškart. APEX naudoja kontrolines sumas be ilgų duomenų bazės užraktų."
                }
            },
            {
                "icon": "🚫",
                "kpi": "STOP CHATTY NETWORK",
                "title": {
                    "en": "De-Chattify Triggers",
                    "et": "Trigerite de-chattifitseerimine",
                    "fi": "Vältä turhia verkkokutsuja",
                    "sv": "Undvik chattiga nätverksanrop",
                    "lv": "Izvairieties no liekiem tīkla pieprasījumiem",
                    "lt": "Venkite perteklinių tinklo užklausų"
                },
                "desc": {
                    "en": "Do not replicate WHEN-VALIDATE-ITEM with Ajax Dynamic Actions! Use HTML5 client checks and single-submit Page Validations.",
                    "et": "Ärge kopeerige WHEN-VALIDATE-ITEM trigereid Ajax Dynamic Actioniteks! Kasutage HTML5 valideerimist ja lehe esitamise kontrolle.",
                    "fi": "Älä tee jokaisesta kentästä Ajax-kyselyä. Käytä HTML5-validointia ja sivun lähetystä.",
                    "sv": "Kopiera inte WHEN-VALIDATE-ITEM till Ajax-anrop. Använd HTML5 och sidvalidering.",
                    "lv": "Nekopējiet katru trigeri uz Ajax. Lietojiet HTML5 un lapas validāciju.",
                    "lt": "Nekopijuokite kiekvieno trigerio į Ajax. Naudokite HTML5 ir puslapio patvirtinimą."
                }
            },
            {
                "icon": "🔗",
                "kpi": "NATIIVNE IG",
                "title": {
                    "en": "Native Master-Detail Grids",
                    "et": "Natiivne Master-Detail",
                    "fi": "Natiivi Master-Detail",
                    "sv": "Inbyggd Master-Detail",
                    "lv": "Iebūvētais Master-Detail",
                    "lt": "Numatytasis Master-Detail"
                },
                "desc": {
                    "en": "Forms Relation blocks become native Interactive Grid Master-Detail regions with automatic parent key cascading and zero custom JS.",
                    "et": "Formsi keerulised plokkide seosed asendatakse Interactive Grid Master-Detailiga – võõrvõtmete pärimine toimub deklaratiivselt.",
                    "fi": "Formsin monimutkaiset relaatiot korvataan Interactive Gridin sisäänrakennetulla Master-Detaililla.",
                    "sv": "Formulärrelationer ersätts med Interactive Grids inbyggda Master-Detail.",
                    "lv": "Sarežģīti bloki tiek aizstāti ar Interactive Grid deklaratīvo sasaisti.",
                    "lt": "Sudėtingi ryšiai pakeičiami deklaratyvia Interactive Grid sąsaja."
                }
            }
        ],
        "speaker_notes": {
            "en": "🎯 Core Takeaway: APEX is stateless. If developers try to recreate Forms triggers 1:1, the app will be slow and fragile. Follow Guru rules.<br/>💡 Talking Points: Explain optimistic locking. When a collision occurs, APEX tells the user cleanly. No more hanging sessions locking entire tables.<br/>⚠️ Key Emphasis: Master-Detail in Interactive Grid takes 2 clicks to configure declaratively.",
            "et": "🎯 Peamine sõnum: APEX on olekuta veebirakendus. Kui arendajad üritavad Formsi trigereid 1:1 kopeerida, tekib aeglane süsteem. Järgi guru reegleid.<br/>💡 Rääkimispunktid: Selgita optimistlikku lukustust. Enam ei ole rippuvaid sessioone, mis hoiavad poolt tabelit lukus.<br/>⚠️ Mida rõhutada: Master-Detail Interactive Gridis seadistatakse deklaratiivselt ilma omakirjutatud koodita.",
            "fi": "🎯 Pääviesti: APEX on tilaton. Älä kopioi Formsin triggereitä sellaisenaan.<br/>💡 Puhujan muistiinpanot: Selitä optimistinen lukitus.",
            "sv": "🎯 Huvudbudskap: APEX är tillståndslöst. Följ guruns regler för prestanda och stabilitet.",
            "lv": "🎯 Galvenais vēstījums: APEX ir bezstāvokļa sistēma. Nelietojiet liekus tīkla zvanus.",
            "lt": "🎯 Pagrindinė žinutė: APEX yra būsenos nesauganti sistema. Laikykitės taisyklių."
        }
    },
    5: {
        "badge": {
            "en": "⚡ SLIDE 5 / 13 • APEXLANG &amp; AI VIBE-CODING",
            "et": "⚡ SLAID 5 / 13 • APEXLANG DSL &amp; AI VIBE-CODING",
            "fi": "⚡ DIA 5 / 13 • APEXLANG DSL &amp; AI VIBE-CODING",
            "sv": "⚡ BILD 5 / 13 • APEXLANG DSL &amp; AI VIBE-CODING",
            "lv": "⚡ SLAIDS 5 / 13 • APEXLANG DSL &amp; AI VIBE-CODING",
            "lt": "⚡ SKAIDRĖ 5 / 13 • APEXLANG DSL IR AI VIBE-CODING"
        },
        "title": {
            "en": "Low-Code as Code: 4–8x Acceleration via APEXlang DSL and MCP",
            "et": "Low-Code koodina: 4–8x kiiruse kasv tänu APEXlang DSL-ile ja MCP-le",
            "fi": "Low-Code koodina: 4–8x nopeus APEXlang DSL:n ja MCP:n avulla",
            "sv": "Low-Code som kod: 4–8x snabbare med APEXlang DSL och MCP",
            "lv": "Low-Code kā kods: 4–8x paātrinājums ar APEXlang DSL un MCP",
            "lt": "Low-Code kaip kodas: 4–8x greičiau su APEXlang DSL ir MCP"
        },
        "lead": {
            "en": "Official Oracle APEXlang (.apx) files, EBNF grammar constraints (GBNF), and SQLcl MCP server eliminate drag-and-drop drag. Version everything in Git as text.",
            "et": "Ametlikud Oracle APEXlang (.apx) failid, EBNF grammatikapiirangud (GBNF) ja SQLcl MCP server kaotavad hiirega lohistamise. Kogu kood on Git-is tekstina.",
            "fi": "Viralliset APEXlang (.apx) -tiedostot, EBNF-kielioppi ja SQLcl MCP poistavat hiirellä raahaamisen. Kaikki koodi hallitaan Gitissä tekstinä.",
            "sv": "Officiella APEXlang (.apx) filer och SQLcl MCP ersätter visuellt klickande. Allt versionshanteras som text i Git.",
            "lv": "Oficiālie APEXlang (.apx) faili un SQLcl MCP aizstāj manuālu vilkšanu. Viss tiek glabāts Git kā teksts.",
            "lt": "Oficialūs APEXlang (.apx) failai ir SQLcl MCP pašalina rankinį vilkimą. Viskas valdoma Git kaip tekstas."
        },
        "cards": [
            {
                "icon": "📝",
                "kpi": ".APX DEKLARATIIVNE",
                "title": {
                    "en": "Indirect Generation",
                    "et": "Kaudne koodigeneratsioon",
                    "fi": "Epäsuora generointi",
                    "sv": "Indirekt generering",
                    "lv": "Netiešā ģenerēšana",
                    "lt": "Netiesioginis generavimas"
                },
                "desc": {
                    "en": "AI generates 20 lines of declarative intent (.apx), while the APEX engine handles sessions, CSRF, rendering, and security. Zero framework rot.",
                    "et": "AI genereerib 20 rida deklaratiivset kavatsust (.apx). APEXi tuumikmootor tagab seansi, CSRF kaitse ja renderdamise. Kood ei aegu.",
                    "fi": "AI tuottaa 20 riviä deklaratiivista koodia (.apx). APEX-moottori hoitaa tietoturvan ja renderöinnin ilman koodimätää.",
                    "sv": "AI skapar 20 rader deklarativ kod (.apx). Motorn sköter säkerhet och rendering.",
                    "lv": "AI ģenerē 20 deklaratīvas koda rindas (.apx). Dzinējs rūpējas par drošību.",
                    "lt": "AI sugeneruoja 20 eilučių (.apx). Variklis rūpinasi saugumu ir atvaizdavimu."
                }
            },
            {
                "icon": "🛡️",
                "kpi": "EBNF & GBNF",
                "title": {
                    "en": "Zero Hallucination Guarantee",
                    "et": "Grammatikapiirangud (GBNF)",
                    "fi": "Kielioppirajoitteet (GBNF)",
                    "sv": "Grammatikspärrar (GBNF)",
                    "lv": "Gramatikas ierobežojumi (GBNF)",
                    "lt": "Gramatikos apribojimai (GBNF)"
                },
                "desc": {
                    "en": "The published apexlang.ebnf grammar enforces syntax at the token level. AI physically cannot emit invalid properties or illegal AST nodes.",
                    "et": "Ametlik apexlang.ebnf grammatika sunnib tehisintellekti genereerima korrektset süntaksit. Mudel ei saa füüsiliselt luua vigaseid parameetreid.",
                    "fi": "Julkaistu apexlang.ebnf pakottaa syntaksin token-tasolla. AI ei voi tuottaa virheellisiä ominaisuuksia.",
                    "sv": "Officiell EBNF-grammatik tvingar AI att hålla sig till syntaxen. Noll ogiltiga attribut.",
                    "lv": "Oficiālā EBNF gramatika nodrošina precīzu sintaksi bez halucinācijām.",
                    "lt": "Oficiali EBNF gramatika užtikrina tikslią sintaksę be haliucinacijų."
                }
            },
            {
                "icon": "🤖",
                "kpi": "SQLCL MCP SERVER",
                "title": {
                    "en": "6-Stage Vibe-Coding Loop",
                    "et": "6-astmeline Vibe-Coding tsükkel",
                    "fi": "6-vaiheinen Vibe-Coding-silmukka",
                    "sv": "6-stegs Vibe-Coding loop",
                    "lv": "6 soļu Vibe-Coding cikls",
                    "lt": "6 žingsnių Vibe-Coding ciklas"
                },
                "desc": {
                    "en": "1. Live Schema Query via MCP -> 2. PL/SQL VALID -> 3. .apx generation -> 4. apexctl validate -> 5. apex import -> 6. Git Diff review.",
                    "et": "1. Skeemi päring läbi MCP -> 2. PL/SQL kontroll -> 3. .apx generatsioon -> 4. apexctl valideerimine -> 5. import DEV baasi -> 6. Git diff ülevaatus.",
                    "fi": "1. Skeemakysely MCP:llä -> 2. PL/SQL -> 3. .apx -> 4. apexctl validointi -> 5. import DEV -> 6. Git diff tarkistus.",
                    "sv": "1. Schemaläsning via MCP -> 2. PL/SQL -> 3. .apx -> 4. Validering -> 5. Import -> 6. Git diff.",
                    "lv": "1. Shēmas lasīšana ar MCP -> 2. PL/SQL -> 3. .apx -> 4. Validācija -> 5. Imports -> 6. Git diff.",
                    "lt": "1. Schemos skaitymas per MCP -> 2. PL/SQL -> 3. .apx -> 4. Tikrinimas -> 5. Importas -> 6. Git diff."
                }
            }
        ],
        "speaker_notes": {
            "en": "🎯 Core Takeaway: APEXlang transforms APEX into professional software engineering. AI writes the code, SQLcl compiles it, and Git tracks every diff.<br/>💡 Talking Points: Contrast visual page building with APEXlang. In visual builder, doing 150 forms takes years. With APEXlang + MCP, it takes weeks.<br/>⚠️ Key Emphasis: Kris Rice principle: 'Generate what you want to own, own what you generate.'",
            "et": "🎯 Peamine sõnum: APEXlang teeb APEXist tõelise tarkvarainseneeria. AI kirjutab koodi, SQLcl kompileerib ja Git peab versioonihaldust.<br/>💡 Rääkimispunktid: Võrdle hiirega klikkimist APEXlangiga. Visuaalses vaates võtaks 150 vormi aastaid. APEXlang + MCP abil tehakse see kuudega.<br/>⚠️ Mida rõhutada: Kris Rice'i põhimõte: 'Genereeri ainult seda, mida tahad ise omada!'",
            "fi": "🎯 Pääviesti: APEXlang tekee APEXista oikeaa ohjelmistokehitystä Git-versioinnilla.<br/>💡 Puhujan muistiinpanot: 4-8x tuottavuusloikka.",
            "sv": "🎯 Huvudbudskap: APEXlang förvandlar APEX till professionell mjukvaruutveckling i Git.",
            "lv": "🎯 Galvenais vēstījums: APEXlang padara APEX par īstu programmatūras inženieriju.",
            "lt": "🎯 Pagrindinė žinutė: APEXlang paverčia APEX tikra programinės įrangos inžinerija."
        }
    },
    6: {
        "badge": {
            "en": "🎨 SLIDE 6 / 13 • UX &amp; KEYBOARD ERGONOMICS",
            "et": "🎨 SLAID 6 / 13 • KASUTAJAKOGEMUS &amp; KLAVIATUUR",
            "fi": "🎨 DIA 6 / 13 • KÄYTTÄJÄKOKEMUS &amp; NÄPPÄIMISTÖ",
            "sv": "🎨 BILD 6 / 13 • ANVÄNDARUPPLEVELSE &amp; TANGENTBORD",
            "lv": "🎨 SLAIDS 6 / 13 • LIETOTĀJA PIEREDZE &amp; TASTATŪRA",
            "lt": "🎨 SKAIDRĖ 6 / 13 • VARTOTOJO PATIRTIS IR KLAVIATŪRA"
        },
        "title": {
            "en": "High-Density Data Entry: Mouse-Free Navigation for Heavy Power Users",
            "et": "Kompaktne andmesisestus: Hiirevaba navigatsioon professionaalsele kasutajale",
            "fi": "Korkea tiheys: Hiiretön navigointi teho- ja ammattikäyttäjille",
            "sv": "Kompakt datainmatning: Musfri navigering för professionella användare",
            "lv": "Kompakta datu ievade: Navigācija bez peles profesionāliem lietotājiem",
            "lt": "Kompaktiškas duomenų įvedimas: Navigacija be pelės profesionalams"
        },
        "lead": {
            "en": "Operators enter thousands of lines daily. We eliminate white-space bloat with Dense Mode, preserve Enter/Tab muscle memory, and prevent accidental data loss.",
            "et": "Operaatorid sisestavad tuhandeid ridu päevas. Kaotame tühja ruumi Compact režiimiga, säilitame Enter/Tab lihasmälu ja välistame andmekao.",
            "fi": "Käyttäjät syöttävät tuhansia rivejä päivässä. Poistamme turhan tyhjän tilan Compact-tilalla ja säilytämme Enter/Tab-lihasmuistin.",
            "sv": "Användare matar in tusentals rader dagligen. Vi tar bort onödigt tomrum och behåller tangentbordsminnet.",
            "lv": "Lietotāji ievada tūkstošiem rindu dienā. Mēs novēršam lieko tukšo vietu un saglabājam taustiņu ieradumus.",
            "lt": "Vartotojai kasdien suveda tūkstančius eilučių. Pašaliname tuščią erdvę ir išsaugome klaviatūros įpročius."
        },
        "cards": [
            {
                "icon": "📐",
                "kpi": "DENSE / COMPACT MODE",
                "title": {
                    "en": "Dense UI Layout",
                    "et": "Andmetihe ekraanikujundus",
                    "fi": "Kompakti tiheä asettelu",
                    "sv": "Kompakt skärmlayout",
                    "lv": "Kompakts ekrāna izkārtojums",
                    "lt": "Kompaktiškas ekrano išdėstymas"
                },
                "desc": {
                    "en": "Universal Theme configured for high row density: 30-40 rows visible without scrolling. No giant mobile-first gaps.",
                    "et": "Universal Theme kohandatud andmetihedusele: 30–40 rida nähtaval ilma kerimata. Ei mingeid hiiglaslikke tühimikke.",
                    "fi": "Universal Theme viritetty tiheäksi: 30-40 riviä näkyvissä ilman vieritystä.",
                    "sv": "Universal Theme inställt för hög täthet: 30-40 rader synliga direkt.",
                    "lv": "Pielāgots augstam blīvumam: 30-40 rindas redzamas bez ritināšanas.",
                    "lt": "Pritaikyta dideliam tankumui: 30-40 eilučių matoma be slinkties."
                }
            },
            {
                "icon": "⌨️",
                "kpi": "ENTER / TAB / ESC",
                "title": {
                    "en": "Keyboard-First Workflows",
                    "et": "Klaviatuuripõhine sisestus",
                    "fi": "Näppäimistökeskeinen syöttö",
                    "sv": "Tangentbordsfokuserat arbetsflöde",
                    "lv": "Ievade ar tastatūru",
                    "lt": "Klaviatūra grįstas darbas"
                },
                "desc": {
                    "en": "Tab and Enter advance fields sequentially. F7/F8 query shortcuts mapped cleanly. Ctrl+S commits changes instantly.",
                    "et": "Tab ja Enter liiguvad järjestikku. Vana F7/F8 päringuasendus töötab kiirklahvina. Ctrl+S salvestab koheselt ilma hiirt puudutamata.",
                    "fi": "Tab ja Enter siirtävät kenttää. F7/F8-kyselyoikotiet säilytetty. Ctrl+S tallentaa heti ilman hiirtä.",
                    "sv": "Tab och Enter flyttar fokus logiskt. F7/F8 stöds. Ctrl+S sparar direkt.",
                    "lv": "Tab un Enter pārvieto kursoru secīgi. F7/F8 īsceļi saglabāti. Ctrl+S saglabā uzreiz.",
                    "lt": "Tab ir Enter perkelia žymeklį nuosekliai. F7/F8 išsaugoti. Ctrl+S išsaugo iškart."
                }
            },
            {
                "icon": "⚠️",
                "kpi": "WARN UNSAVED CHANGES",
                "title": {
                    "en": "Zero Accidental Data Loss",
                    "et": "Andmekao täielik välistamine",
                    "fi": "Ei tahatonta datan häviämistä",
                    "sv": "Noll oavsiktlig dataförlust",
                    "lv": "Datu zuduma novēršana",
                    "lt": "Apsauga nuo duomenų praradimo"
                },
                "desc": {
                    "en": "Built-in browser 'Warn on Unsaved Changes' dialog prevents accidental navigation away from partially entered forms.",
                    "et": "Lehe sisseehitatud 'Hoiata salvestamata muudatuste eest' dialoog välistab poolelioleva vormi kogemata sulgemise.",
                    "fi": "Varoitus tallentamattomista muutoksista estää lomakkeen sulkemisen vahingossa.",
                    "sv": "Varning för osparade ändringar förhindrar att data förloras av misstag.",
                    "lv": "Brīdinājums par nesaglabātām izmaiņām novērš nejaušu aizvēršanu.",
                    "lt": "Įspėjimas apie neišsaugotus pakeitimus apsaugo nuo netyčinio uždarymo."
                }
            }
        ],
        "speaker_notes": {
            "en": "🎯 Core Takeaway: We protect user muscle memory. If operators have to grab the mouse for every line, they will hate the new system. We give them keyboard-first speed.<br/>💡 Talking Points: Demonstrate Compact Mode vs standard padding. Show that Enter advances to the next cell in Interactive Grid.",
            "et": "🎯 Peamine sõnum: Me austame kasutaja lihasmälu. Kui raamatupidaja peab iga rea järel hiirt haarama, siis uus süsteem kukub läbi. Tagame hiirevaba kiiruse.<br/>💡 Rääkimispunktid: Näita tiheda režiimi ekraani. Tõesta, et Enter ja Tab liiguvad tabelis nagu vanas Forms vormis.",
            "fi": "🎯 Pääviesti: Suojelemme käyttäjien lihasmuistia ja tarjoamme hiirettömän nopeuden.<br/>💡 Puhujan muistiinpanot: Näytä Compact-tila.",
            "sv": "🎯 Huvudbudskap: Vi bevarar användarnas muskelminne för snabb inmatning utan mus.",
            "lv": "🎯 Galvenais vēstījums: Saglabājam lietotāju taustiņu ieradumus ātrai ievadei.",
            "lt": "🎯 Pagrindinė žinutė: Gerbiame naudotojų įpročius greitam darbui be pelės."
        }
    },
    7: {
        "badge": {
            "en": "👥 SLIDE 7 / 13 • END-USER SAFETY NET &amp; PARALLEL RUN",
            "et": "👥 SLAID 7 / 13 • LÕPPKASUTAJA TURVAVÕRK &amp; PARALLEELKASUTUS",
            "fi": "👥 DIA 7 / 13 • KÄYTTÄJÄN TURVAVERKKO &amp; RINNAKKAISKÄYTTÖ",
            "sv": "👥 BILD 7 / 13 • ANVÄNDARENS NÖDNÄT &amp; PARALLELLDRIFT",
            "lv": "👥 SLAIDS 7 / 13 • LIETOTĀJA DROŠĪBAS TĪKLS &amp; PARALĒLĀ LIETOŠANA",
            "lt": "👥 SKAIDRĖ 7 / 13 • NAUDOTOJO SAUGUMO TINKLAS IR LYGIAGRETI VEIKLA"
        },
        "title": {
            "en": "Zero Duplicate Entry: 1 Database, 30-Day Coexistence Safety Net",
            "et": "0 topeltandmesisestust: 1 andmebaas, 30-päevane turvaline tagasipöördumine",
            "fi": "0 kaksinkertaista syöttöä: 1 tietokanta, 30 päivän rinnakkaiskäyttö",
            "sv": "Noll dubbelinmatning: 1 databas och 30 dagars säkerhetsnät",
            "lv": "0 dubultās ievades: 1 datubāze un 30 dienu drošības tīkls",
            "lt": "0 dvigubo įvedimo: 1 duomenų bazė ir 30 dienų saugumo garantija"
        },
        "lead": {
            "en": "Users do not have to type data into two systems. Forms and APEX share the identical tables and packages simultaneously, with an instant 1-click fallback button.",
            "et": "Kasutajad ei pea andmeid sisestama kahte kohta. Forms ja APEX töötavad täpselt samade tabelite ja pakettide peal reaalajas.",
            "fi": "Käyttäjien ei tarvitse syöttää tietoja kahteen paikkaan. Forms ja APEX jakavat samat taulut reaaliajassa.",
            "sv": "Ingen dubbelinmatning. Forms och APEX delar samma tabeller samtidigt, med en 1-klicks nödknapp tillbaka.",
            "lv": "Nekādas dubultas ievades. Forms un APEX izmanto tās pašas tabulas ar tūlītēju atgriešanās pogu.",
            "lt": "Jokio dvigubo vedimo. Forms ir APEX realiu laiku naudoja tas pačias lenteles su atgaliniu mygtuku."
        },
        "cards": [
            {
                "icon": "🔄",
                "kpi": "1 REAALNE ANDMEBAAS",
                "title": {
                    "en": "Single Source of Truth",
                    "et": "Üks ja seesama andmetõde",
                    "fi": "Yksi ainoa totuus",
                    "sv": "En enda sanningskälla",
                    "lv": "Vienots datu avots",
                    "lt": "Vienintelis tiesos šaltinis"
                },
                "desc": {
                    "en": "An order saved in APEX is instantly visible in old Forms, and vice versa. 0 data migration batches during the transition.",
                    "et": "APEXis salvestatud tellimus on koheselt nähtav vanas Formsis ja vastupidi. Ülemineku ajal puudub igasugune andmete sünkroniseerimise viide.",
                    "fi": "APEXissa tallennettu tilaus näkyy heti vanhassa Formsissa ja päinvastoin. Nolla synkronointiviivettä.",
                    "sv": "En order sparad i APEX syns direkt i Forms och tvärtom. Noll fördröjning.",
                    "lv": "APEX saglabātais pasūtījums uzreiz redzams Forms. Nulle aiztures.",
                    "lt": "APEX išsaugotas užsakymas iškart matomas Forms sistemoje ir atvirkščiai."
                }
            },
            {
                "icon": "🛟",
                "kpi": "30 PÄEVA TURVAVÕRK",
                "title": {
                    "en": "1-Click Fallback Button",
                    "et": "30-päevane tagasitee nupp",
                    "fi": "30 päivän paluupainike",
                    "sv": "30 dagars nödknapp tillbaka",
                    "lv": "30 dienu atgriešanās poga",
                    "lt": "30 dienų grįžimo mygtukas"
                },
                "desc": {
                    "en": "If a user hits an edge case in the new APEX screen, a header button opens the old Form with the identical record pre-loaded. Panic eliminated.",
                    "et": "Kui kasutaja satub uues vormis ootamatusse olukorda, viib päises olev nupp ta koheselt vanasse vormi sama kirjega. Paanika ja hirm on maandatud.",
                    "fi": "Jos uudessa ruudussa tulee ongelma, painike avaa vanhan Formsin samalla tietueella.",
                    "sv": "Om problem uppstår öppnar en knapp det gamla formuläret med samma post laddad.",
                    "lv": "Ja rodas problēma, poga atver veco formu ar to pašu ierakstu.",
                    "lt": "Kilus problemai, mygtukas atidaro senąją formą su tuo pačiu įrašu."
                }
            },
            {
                "icon": "💬",
                "kpi": "1-KLIKI TAGASISIDE",
                "title": {
                    "en": "Contextual In-App Feedback",
                    "et": "1-klikiga tagasiside lehel",
                    "fi": "Välitön palaute suoraan ruudulta",
                    "sv": "Direkt feedback från skärmen",
                    "lv": "Atsauksmes ar vienu klikšķi",
                    "lt": "Atsiliepimai vienu paspaudimu"
                },
                "desc": {
                    "en": "Built-in APEX Feedback dialog captures screenshots, user session ID, and page parameters directly into the developers' issue tracker.",
                    "et": "Päises asuv tagasiside nupp teeb automaatselt ekraanipildi ja salvestab veateate koos parameetritega otse arendajate töölauale.",
                    "fi": "Palautepainike tallentaa ruutukaappauksen ja parametrit suoraan kehittäjien jonoon.",
                    "sv": "Feedback-knapp sparar skärmdump och parametrar direkt till utvecklarna.",
                    "lv": "Poga saglabā ekrānuzņēmumu un kļūdu uzreiz izstrādātājiem.",
                    "lt": "Mygtukas išsaugo ekrano kopiją ir klaidą tiesiai programuotojams."
                }
            }
        ],
        "speaker_notes": {
            "en": "🎯 Core Takeaway: End users will not revolt because they are not trapped. They have a 30-day safety net to fall back to the old form if they feel stuck.<br/>💡 Talking Points: Highlight the 0-duplicate-entry reality. Both UIs talk to the same database. Demonstrate the in-app feedback dialog.",
            "et": "🎯 Peamine sõnum: Lõppkasutajad ei hakka vastu, sest neil on turvatunne. Neil on 30 päeva turvaline tagasipöördumise nupp vanasse vormi.<br/>💡 Rääkimispunktid: Rõhuta, et puudub topeltandmesisestus. Mõlemad süsteemid vaatavad samu tabeleid reaalajas.<br/>⚠️ Mida rõhutada: Tagasiside nupp viib vead otse arendajate järjekorda.",
            "fi": "🎯 Pääviesti: Käyttäjillä on turvaverkko eikä kaksoissyöttöä tarvita.<br/>💡 Puhujan muistiinpanot: 30 päivän paluumahdollisuus poistaa muutosvastarinnan.",
            "sv": "🎯 Huvudbudskap: Trygghet för användarna med 30 dagars parallell drift och nödknapp.",
            "lv": "🎯 Galvenais vēstījums: Lietotājiem ir drošības tīkls un nav dubultas ievades.",
            "lt": "🎯 Pagrindinė žinutė: Naudotojai jaučiasi saugūs su 30 dienų garantija."
        }
    },
    8: {
        "badge": {
            "en": "🤝 SLIDE 8 / 13 • TEAM WORK RULES (60/40)",
            "et": "🤝 SLAID 8 / 13 • TIIMI TÖÖKOKKULEPPED (60/40 REEGEL)",
            "fi": "🤝 DIA 8 / 13 • TIIMIN TYÖSOPIMUS (60/40 SÄÄNTÖ)",
            "sv": "🤝 BILD 8 / 13 • TEAMETS ARBETSREGLER (60/40)",
            "lv": "🤝 SLAIDS 8 / 13 • KOMANDAS VIENOŠANĀS (60/40 NOTEIKUMS)",
            "lt": "🤝 SKAIDRĖ 8 / 13 • KOMANDOS SUSITARIMAS (60/40 TAISYKLĖ)"
        },
        "title": {
            "en": "Team Agreements & Governance: Protecting Developers from Burnout",
            "et": "Tiimi töökokkulepped: Arendajate kaitsmine läbipõlemise eest",
            "fi": "Tiimin työsopimukset: Kehittäjien suojaaminen uupumukselta",
            "sv": "Teamets överenskommelser: Skydda utvecklarna mot utbrändhet",
            "lv": "Komandas vienošanās: Izstrādātāju aizsardzība pret izdegšanu",
            "lt": "Komandos susitarimai: Programuotojų apsauga nuo perdegimo"
        },
        "lead": {
            "en": "Executive mandate: 60% capacity reserved for modernization, official Forms feature freeze, strict scope control, and 0 external consultancy arrogance.",
            "et": "Juhtkonna ametlik mandaat: 60% arendusmahust kaitstud moderniseerimiseks, vanade vormide feature freeze ja rangelt 0 äriprotsesside ümberdisaini.",
            "fi": "Johdon mandaatti: 60% kapasiteetista modernisointiin, vanhojen lomakkeiden jäädytys ja nolla ulkoista konsulttia.",
            "sv": "Ledningens mandat: 60% kapacitet för modernisering, frysning av gamla formulär och noll affärsomdesign.",
            "lv": "Vadības mandāts: 60% jaudas modernizācijai, veco formu iesaldēšana un sava komanda.",
            "lt": "Vadovybės mandatas: 60% pajėgumų modernizavimui, senų formų įšaldymas ir sava komanda."
        },
        "cards": [
            {
                "icon": "⚖️",
                "kpi": "60 / 40 KOORMUS",
                "title": {
                    "en": "60/40 Capacity Allocation",
                    "et": "60/40 koormuse jaotus",
                    "fi": "60/40 kapasiteetin jako",
                    "sv": "60/40 kapacitetsfördelning",
                    "lv": "60/40 jaudas sadalījums",
                    "lt": "60/40 pajėgumų paskirstymas"
                },
                "desc": {
                    "en": "60% of developer sprint time is locked strictly for APEX. 40% handles critical production bugs and regulatory compliance.",
                    "et": "60% arendajate ajast on lukustatud rangelt APEXi jaoks. 40% lahendab kriitilisi vigu ja seadusemuudatusi.",
                    "fi": "60% ajasta on lukittu APEXille. 40% hoitaa kriittiset tuotantovirheet ja lakimuutokset.",
                    "sv": "60% låst för APEX. 40% för kritiska fel och lagkrav.",
                    "lv": "60% veltīti APEX. 40% kritiskām kļūdām un likumiem.",
                    "lt": "60% skirta APEX. 40% kritinėms klaidoms ir įstatymams."
                }
            },
            {
                "icon": "🧊",
                "kpi": "FORMS FEATURE FREEZE",
                "title": {
                    "en": "Official Feature Freeze",
                    "et": "Vanade vormide külmutamine",
                    "fi": "Vanhojen lomakkeiden jäädytys",
                    "sv": "Frysning av gamla formulär",
                    "lv": "Veco formu iesaldēšana",
                    "lt": "Senų formų įšaldymas"
                },
                "desc": {
                    "en": "Executive ban on developing new features in Forms. All new business capabilities are built directly in APEX.",
                    "et": "Juhtkonna kirjalik keeld arendada uusi funktsioone vanasse Formsi. Uued soovid ehitatakse otse APEXisse.",
                    "fi": "Johdon kielto kehittää uutta vanhaan Formsiin. Kaikki uusi tehdään APEXiin.",
                    "sv": "Stopp för nyutveckling i gamla Forms. Allt nytt byggs i APEX.",
                    "lv": "Aizliegts izstrādāt jaunas funkcijas vecajā Forms. Viss jaunais top APEX.",
                    "lt": "Draudžiama kurti naujas funkcijas senajame Forms. Viskas kuriama APEX."
                }
            },
            {
                "icon": "🎓",
                "kpi": "0 KONSULTANTI / SERT",
                "title": {
                    "en": "In-House Upskilling",
                    "et": "Oma tiimi sertifitseerimine",
                    "fi": "Oman tiimin sertifiointi",
                    "sv": "Intern certifiering av teamet",
                    "lv": "Savas komandas sertifikācija",
                    "lt": "Savo komandos sertifikavimas"
                },
                "desc": {
                    "en": "Oracle MyLearn APEX Developer certification during work hours. We invest in our people, not external billing machines.",
                    "et": "Oracle MyLearn APEX Developer sertifitseerimine tööajal. Investeerime oma inimestesse, mitte välistesse konsultantidesse.",
                    "fi": "Oracle MyLearn APEX Developer -sertifiointi työajalla. Investoimme omiin ihmisiin.",
                    "sv": "Oracle MyLearn-certifiering på arbetstid. Vi satsar på vårt eget team.",
                    "lv": "Oracle sertifikācija darba laikā. Investējam savos cilvēkos.",
                    "lt": "Oracle sertifikavimas darbo metu. Investuojame į savo darbuotojus."
                }
            }
        ],
        "speaker_notes": {
            "en": "🎯 Core Takeaway: Without governance, modernization fails. The 60/40 rule and feature freeze give our team breathing room and focus.<br/>💡 Talking Points: Explain strict scope control: Lift & shift business logic first, optimize UX second, business re-engineering NEVER during migration.<br/>⚠️ Key Emphasis: Team members learn modern web development without feeling overwhelmed.",
            "et": "🎯 Peamine sõnum: Ilma selge juhtimiseta jookseb projekt liiva. 60/40 reegel ja Forms feature freeze tagavad tiimile fookuse ja rahu.<br/>💡 Rääkimispunktid: Rõhuta ulatuse ranget kontrolli: äriloogika jääb samaks, parandame vaid ekraane. Äriprotsesse ei hakata migreerimise käigus ümber disainima!<br/>⚠️ Mida rõhutada: Kogu tiim saab kaasaegsed oskused ja sertifikaadid.",
            "fi": "🎯 Pääviesti: 60/40-sääntö ja feature freeze antavat tiimille työrauhan.<br/>💡 Puhujan muistiinpanot: Ei prosessimuutoksia siirron aikana.",
            "sv": "🎯 Huvudbudskap: 60/40-regeln och frysning ger teamet arbetsro.",
            "lv": "🎯 Galvenais vēstījums: 60/40 noteikums nodrošina fokusu un mieru.",
            "lt": "🎯 Pagrindinė žinutė: 60/40 taisyklė ir įšaldymas suteikia ramybę komandai."
        }
    },
    9: {
        "badge": {
            "en": "🛡️ SLIDE 9 / 13 • CYBERSECURITY &amp; ENTRA ID SSO",
            "et": "🛡️ SLAID 9 / 13 • KÜBERTURVE &amp; AZURE ENTRA ID SSO",
            "fi": "🛡️ DIA 9 / 13 • TIETOTURVA &amp; AZURE ENTRA ID SSO",
            "sv": "🛡️ BILD 9 / 13 • CYBERSÄKERHET &amp; ENTRA ID SSO",
            "lv": "🛡️ SLAIDS 9 / 13 • KIBERDROŠĪBA &amp; ENTRA ID SSO",
            "lt": "🛡️ SKAIDRĖ 9 / 13 • KIBERNETINIS SAUGUMAS IR ENTRA ID"
        },
        "title": {
            "en": "Zero-Trust Architecture: Azure Entra ID SSO, Session Protection &amp; Audit",
            "et": "Zero-Trust turvaehitus: Azure Entra ID SSO, seansikaitse ja täielik audit",
            "fi": "Zero-Trust tietoturva: Azure Entra ID SSO, istuntosuojaus ja auditointi",
            "sv": "Zero-Trust säkerhet: Azure Entra ID SSO, sessionsskydd och revision",
            "lv": "Zero-Trust drošība: Azure Entra ID SSO, sesiju aizsardzība un audits",
            "lt": "Zero-Trust saugumas: Azure Entra ID SSO, sesijų apsauga ir auditas"
        },
        "lead": {
            "en": "Modernizing identity with corporate OIDC SSO, SHA-256 Session State Protection, IDOR defense, and transparent APP_USER audit context.",
            "et": "Keskne autentimine ettevõtte Entra ID (OIDC) kaudu, SHA-256 URL parameetrite kontrollsummad, IDOR kaitse ja reaalne APP_USER auditijälg.",
            "fi": "Keskitetty tunnistautuminen Entra ID:llä, SHA-256 tarkistussummat, IDOR-suojaus ja aukoton APP_USER auditointi.",
            "sv": "Central autentisering med Entra ID, SHA-256 URL-skydd, IDOR-försvar och full APP_USER-auditering.",
            "lv": "Centralizēta autentifikācija ar Entra ID, SHA-256 kontrolsummas un pilns APP_USER audits.",
            "lt": "Centralizuotas autentifikavimas su Entra ID, SHA-256 kontrolinės sumos ir pilnas APP_USER auditas."
        },
        "cards": [
            {
                "icon": "🔑",
                "kpi": "AZURE ENTRA ID (OIDC)",
                "title": {
                    "en": "Seamless Corporate SSO",
                    "et": "Keskne ettevõtte SSO",
                    "fi": "Keskitetty yritys-SSO",
                    "sv": "Sömlös företags-SSO",
                    "lv": "Vienotā pieteikšanās (SSO)",
                    "lt": "Vieningas įmonės SSO"
                },
                "desc": {
                    "en": "Users log in with their corporate Microsoft account. Roles and security groups synchronize automatically via claims.",
                    "et": "Kasutajad logivad sisse ettevõtte Microsofti kontoga. Rollid ja õigused päritakse automaatselt AD turbegruppidest.",
                    "fi": "Kirjautuminen yrityksen Microsoft-tunnuksella. Roolit synkronoituvat ryhmistä.",
                    "sv": "Inloggning med Microsoft-konto. Roller synkas från grupper.",
                    "lv": "Lietotāji pieslēdzas ar Microsoft kontu. Lomas sinhronizējas automātiski.",
                    "lt": "Prisijungimas su Microsoft paskyra. Rolės sinchronizuojamos automatiškai."
                }
            },
            {
                "icon": "🛡️",
                "kpi": "SHA-256 SSP / IDOR",
                "title": {
                    "en": "Session State Protection",
                    "et": "Seansi oleku krüptokaitse",
                    "fi": "Istunnon tilasuojaus",
                    "sv": "Sessionsskydd med SHA-256",
                    "lv": "Sesijas stāvokļa aizsardzība",
                    "lt": "Sesijos būsenos apsauga"
                },
                "desc": {
                    "en": "Tamper-proof URL parameters signed with SHA-256 prevent IDOR attacks. Users cannot modify item values in URLs.",
                    "et": "URL parameetrite SHA-256 signeerimine välistab IDOR ründed. Kasutaja ei saa brauseri aadressireal ID-sid omavoliliselt muuta.",
                    "fi": "SHA-256 allekirjoitetut URL-parametrit estävät IDOR-hyökkäykset.",
                    "sv": "SHA-256 signerade parametrar förhindrar manipulation i webbläsaren.",
                    "lv": "SHA-256 parakstīti URL parametri novērš manipulācijas.",
                    "lt": "SHA-256 pasirašyti URL parametrai apsaugo nuo manipuliacijų."
                }
            },
            {
                "icon": "📋",
                "kpi": "APP_USER AUDIT & SIEM",
                "title": {
                    "en": "Enterprise Audit Context",
                    "et": "Täielik auditikontekst",
                    "fi": "Kattava auditointikonteksti",
                    "sv": "Full revisionskontext",
                    "lv": "Pilns audita konteksts",
                    "lt": "Pilnas audito kontekstas"
                },
                "desc": {
                    "en": "DBMS_SESSION.SET_IDENTIFIER sets real user identity in database triggers. Logs export to corporate SIEM (Azure Monitor / Splunk).",
                    "et": "DBMS_SESSION.SET_IDENTIFIER seob kasutaja pärisnime andmebaasi trigeritega. Logid suunatakse ettevõtte SIEM-i (Azure Monitor).",
                    "fi": "Käyttäjän todellinen identiteetti välittyy tietokantatriggereille ja SIEM-järjestelmään.",
                    "sv": "Verklig användaridentitet sätts i databastriggers och exporteras till SIEM.",
                    "lv": "Lietotāja identitāte tiek nodota trigeriem un SIEM sistēmai.",
                    "lt": "Tikroji tapatybė perduodama trigeriams ir SIEM sistemai."
                }
            }
        ],
        "speaker_notes": {
            "en": "🎯 Core Takeaway: Security posture is significantly upgraded. We move from legacy database user passwords in Forms to enterprise Azure Entra ID SSO and tamper-proof URLs.<br/>💡 Talking Points: Show how Session State Protection prevents IDOR. Explain that the database audit trail knows the exact user via APP_USER.",
            "et": "🎯 Peamine sõnum: Turvalisuse tase teeb hiiglasliku hüppe. Liigume vanadest andmebaasikasutajatest ettevõtte Entra ID SSO ja SHA-256 URL kaitse peale.<br/>💡 Rääkimispunktid: Selgita IDOR kaitset ja näita, kuidas andmebaasi audititabelites säilib päris kasutaja nimi läbi APP_USER konteksti.",
            "fi": "🎯 Pääviesti: Tietoturva paranee merkittävästi Entra ID SSO:n ja SHA-256:n myötä.<br/>💡 Puhujan muistiinpanot: Korosta aukotonta auditointia.",
            "sv": "🎯 Huvudbudskap: Säkerheten höjs markant med Azure Entra ID och SHA-256.",
            "lv": "🎯 Galvenais vēstījums: Drošības līmenis būtiski pieaug ar Entra ID SSO.",
            "lt": "🎯 Pagrindinė žinutė: Saugumas ženkliai išauga su Entra ID SSO."
        }
    },
    10: {
        "badge": {
            "en": "📑 SLIDE 10 / 13 • PUBLISHER &amp; ENTERPRISE API GATEWAY",
            "et": "📑 SLAID 10 / 13 • TRÜKISED &amp; ETTEVÕTTE API VÄRAV",
            "fi": "📑 DIA 10 / 13 • TULOSTUS &amp; YRITYKSEN API-VÄYLÄ",
            "sv": "📑 BILD 10 / 13 • DOKUMENT &amp; ENTERPRISE API GATEWAY",
            "lv": "📑 SLAIDS 10 / 13 • DOKUMENTI &amp; UZŅĒMUMA API VĀRTI",
            "lt": "📑 SKAIDRĖ 10 / 13 • DOKUMENTAI IR ĮMONĖS API VARTAI"
        },
        "title": {
            "en": "Preserving Publisher Templates &amp; Exposing OpenAPI 3.0 via ORDS",
            "et": "Olemasolevate trükiste säilitamine ja ORDS kui OpenAPI 3.0 API värav",
            "fi": "Tulostemallien säilyttäminen ja ORDS OpenAPI 3.0 -rajapintana",
            "sv": "Bevara Publisher-mallar och exponera OpenAPI 3.0 via ORDS",
            "lv": "Dokumentu veidņu saglabāšana un ORDS kā OpenAPI 3.0 vārteja",
            "lt": "Dokumentų šablonų išsaugojimas ir ORDS kaip OpenAPI 3.0 vartai"
        },
        "lead": {
            "en": "0€ rewritten on complex PDF/invoice templates: APEX natively triggers Analytics Publisher. ORDS publishes formal OpenAPI contracts for batch portals.",
            "et": "0€ lisakulu keerukatele arvete ja lepingute trükistele: APEX käivitab otse Analytics Publisheri. ORDS pakub OpenAPI 3.0 lepinguid teistele süsteemidele.",
            "fi": "0€ lisäkustannus monimutkaisille tulosteille: APEX laukaisee suoraan Publisher-mallit. ORDS tarjoaa viralliset OpenAPI-rajapinnat.",
            "sv": "Noll omskrivning av faktura- och rapportmallar. ORDS publicerar OpenAPI 3.0-kontrakt för batch-portaler.",
            "lv": "0€ papildu izmaksu sarežģītām veidnēm. ORDS nodrošina OpenAPI 3.0 līgumus.",
            "lt": "0€ papildomų išlaidų sąskaitų šablonams. ORDS teikia OpenAPI 3.0 sutartis."
        },
        "cards": [
            {
                "icon": "🖨️",
                "kpi": "0€ TRÜKISTE ÜMBERTEGEMIST",
                "title": {
                    "en": "100% Template Reuse",
                    "et": "Trükiste 100% taaskasutus",
                    "fi": "100% mallien uudelleenkäyttö",
                    "sv": "100% återanvändning av mallar",
                    "lv": "100% veidņu atkārtota izmantošana",
                    "lt": "100% šablonų pakartotinis panaudojimas"
                },
                "desc": {
                    "en": "All existing Oracle Analytics Publisher RTF/PDF layouts continue operating unmodified. APEX generates documents with 1 click.",
                    "et": "Kõik olemasolevad Analytics Publisheri RTF/PDF mallid töötavad muutmata kujul edasi. APEX genereerib trükise 1 klikiga.",
                    "fi": "Kaikki olemassa olevat Publisher RTF/PDF-mallit toimivat sellaisenaan APEXista.",
                    "sv": "Alla befintliga RTF/PDF-mallar fortsätter fungera utan ändringar.",
                    "lv": "Visas esošās veidnes turpina darboties bez izmaiņām.",
                    "lt": "Visi esami RTF/PDF šablonai veikia be pakeitimų."
                }
            },
            {
                "icon": "🌐",
                "kpi": "OPENAPI 3.0 (SWAGGER)",
                "title": {
                    "en": "Enterprise API Gateway",
                    "et": "Ametlik OpenAPI 3.0 värav",
                    "fi": "Virallinen OpenAPI 3.0 -väylä",
                    "sv": "Officiell OpenAPI 3.0-gateway",
                    "lv": "Oficiālā OpenAPI 3.0 vārteja",
                    "lt": "Oficialūs OpenAPI 3.0 vartai"
                },
                "desc": {
                    "en": "ORDS AutoREST exposes PL/SQL business APIs as machine-readable OpenAPI specs for Azure API Management and external partners.",
                    "et": "ORDS AutoREST teeb andmebaasipaketid kättesaadavaks standardsete OpenAPI/Swagger lepingutena ettevõtte API haldusele.",
                    "fi": "ORDS julkaisee PL/SQL-rajapinnat standardeina OpenAPI-sopimuksina yrityksen API Managementille.",
                    "sv": "ORDS publicerar PL/SQL som standardiserade OpenAPI-kontrakt för Azure API Management.",
                    "lv": "ORDS publicē PL/SQL kā standarta OpenAPI līgumus.",
                    "lt": "ORDS skelbia PL/SQL kaip standartines OpenAPI sutartis."
                }
            },
            {
                "icon": "🛡️",
                "kpi": "JAVA PORTAALI KAITSE",
                "title": {
                    "en": "Java Portal Integration",
                    "et": "Java taustaportaali kaitsekilp",
                    "fi": "Java-portaalin suojakilpi",
                    "sv": "Skydd för Java-portalen",
                    "lv": "Aizsardzība Java portālam",
                    "lt": "Java portalo apsauga"
                },
                "desc": {
                    "en": "The legacy Java backoffice portal communicates with the database via secured OAuth2 REST endpoints, preventing direct DB coupling.",
                    "et": "Ettevõtte Java taustaportaal ja massitöötlused liidestuvad turvalise OAuth2 REST API kaudu, vältides otsest baasisidumist.",
                    "fi": "Java-taustaportaali kytkeytyy suojatulla OAuth2 REST API:lla ilman suoraa tietokantariippuvuutta.",
                    "sv": "Java-portalen ansluter via säker OAuth2 REST API utan direkt databaskoppling.",
                    "lv": "Java portāls pieslēdzas caur drošu OAuth2 REST API.",
                    "lt": "Java portalas jungiasi per saugią OAuth2 REST API sąsają."
                }
            }
        ],
        "speaker_notes": {
            "en": "🎯 Core Takeaway: We do not throw away expensive report templates. Analytics Publisher integrates seamlessly with APEX. ORDS turns our database into a modern REST API hub.<br/>💡 Talking Points: Point out that our 1 Java developer is protected by clean OpenAPI 3.0 REST contracts.",
            "et": "🎯 Peamine sõnum: Me ei viska minema olemasolevaid keerulisi arvemalle. Analytics Publisher integreerub APEXiga 1 klikiga. ORDS teeb baasist ametliku REST API keskuse.<br/>💡 Rääkimispunktid: Meie 1 Java arendaja saab selged OpenAPI 3.0 lepingud, mitte ei pea koodi lahti harutama.",
            "fi": "🎯 Pääviesti: Säästämme tulostemallit ja suojaamme Java-portaalin ORDS REST -rajapinnalla.",
            "sv": "🎯 Huvudbudskap: Alla rapportmallar återanvänds och Java-portalen skyddas via ORDS REST.",
            "lv": "🎯 Galvenais vēstījums: Veidnes tiek saglabātas un Java portāls pasargāts ar ORDS REST.",
            "lt": "🎯 Pagrindinė žinutė: Visi šablonai išsaugomi, o Java portalas apsaugomas per ORDS REST."
        }
    },
    11: {
        "badge": {
            "en": "📋 SLIDE 11 / 13 • 150 FORMS AUDIT &amp; TIERS",
            "et": "📋 SLAID 11 / 13 • 150 VORMI AUDIT &amp; RASKUSASTMED",
            "fi": "📋 DIA 11 / 13 • 150 LOMAKKEEN AUDITOINTI &amp; TASOT",
            "sv": "📋 BILD 11 / 13 • AUDIT AV 150 FORMULÄR &amp; NIVÅER",
            "lv": "📋 SLAIDS 11 / 13 • 150 FORMU AUDITS &amp; LĪMEŅI",
            "lt": "📋 SKAIDRĖ 11 / 13 • 150 FORMŲ AUDITAS IR LYGIAI"
        },
        "title": {
            "en": "150 Forms Portfolio Audit: Pruning 20% Obsolete &amp; Classifying Complexity",
            "et": "150 vormi portfelli audit: 20% vanade karsimine ja 3 raskusastet",
            "fi": "150 lomakkeen auditointi: 20% turhien poisto ja 3 vaativuustasoa",
            "sv": "Audit av 150 formulär: Rensa 20% inaktuella och 3 komplexitetsnivåer",
            "lv": "150 formu audits: 20% neaktīvo dzēšana un 3 sarežģītības līmeņi",
            "lt": "150 formų auditas: 20% nenaudojamų pašalinimas ir 3 sudėtingumo lygiai"
        },
        "lead": {
            "en": "We don't migrate blindly. Telemetry audits eliminate 20-30 unused screens, leaving ~120 forms categorized into Tier A (simple), Tier B (medium), and Tier C (complex).",
            "et": "Me ei koli pimesi. Kasutusstatistika audit karsib 20–30 mittevajalikku vormi, jättes alles ~120 vormi jaotatuna kolme selgesse kategooriasse.",
            "fi": "Emme siirrä sokeasti. Käyttöauditointi karsii 20-30 turhaa ruutua, jättäen ~120 lomaketta selkeisiin vaativuustasoihin.",
            "sv": "Vi migrerar inte i blindo. 20-30 oanvända formulär rensas bort och kvarvarande delas in i 3 nivåer.",
            "lv": "Mēs nemigrējam akli. Tiek dzēstas 20-30 nevajadzīgas formas un atlikušās sadalītas 3 līmeņos.",
            "lt": "Mes nemigruojame aklai. Pašalinama 20-30 nenaudojamų formų, likusios suskirstomos į 3 lygius."
        },
        "cards": [
            {
                "icon": "🟢",
                "kpi": "TIER A • 40% (~50 VORMI)",
                "title": {
                    "en": "Tier A: Simple Queries & Lookups",
                    "et": "Tier A: Lihtsad päringud ja teatmikud",
                    "fi": "Taso A: Yksinkertaiset kyselyt",
                    "sv": "Nivå A: Enkla sökningar och register",
                    "lv": "Līmenis A: Vienkārši vaicājumi",
                    "lt": "Lygis A: Paprastos užklausos ir žinynai"
                },
                "desc": {
                    "en": "Read-only reports, catalogs, and single-table lookups. Automated migration via APEXlang takes 1-2 days per form.",
                    "et": "Päringud, klassifikaatorid ja 1 tabeli vormid. APEXlangi abil automatiseeritud migratsioon kestab 1–2 päeva vormi kohta.",
                    "fi": "Kyselyt ja yhden taulun ylläpito. APEXlang-siirto kestää 1-2 päivää lomakkeelta.",
                    "sv": "Rapporter och enkla register. APEXlang tar 1-2 dagar per formulär.",
                    "lv": "Atskaites un vienkārši reģistri. 1-2 dienas uz formu.",
                    "lt": "Ataskaitos ir paprasti žinynai. 1-2 dienos formai."
                }
            },
            {
                "icon": "🟡",
                "kpi": "TIER B • 40% (~50 VORMI)",
                "title": {
                    "en": "Tier B: Master-Detail CRUD",
                    "et": "Tier B: Master-Detail andmesisestus",
                    "fi": "Taso B: Master-Detail lomakkeet",
                    "sv": "Nivå B: Master-Detail inmatning",
                    "lv": "Līmenis B: Master-Detail ievade",
                    "lt": "Lygis B: Master-Detail įvedimas"
                },
                "desc": {
                    "en": "Standard business transactions (orders, invoices, clients). Interactive Grid master-detail takes 3-5 days per form.",
                    "et": "Tavalised äritehingud (tellimused, arved, kliendid). Interactive Grid master-detail võtab 3–5 päeva vormi kohta.",
                    "fi": "Normaalit liiketoimintatapahtumat. Interactive Grid vie 3-5 päivää lomakkeelta.",
                    "sv": "Standardtransaktioner (ordrar, fakturor). Tar 3-5 dagar per formulär.",
                    "lv": "Standarta darījumi (rēķini, pasūtījumi). 3-5 dienas uz formu.",
                    "lt": "Standartinės operacijos (sąskaitos, užsakymai). 3-5 dienos formai."
                }
            },
            {
                "icon": "🔴",
                "kpi": "TIER C • 20% (~20 VORMI)",
                "title": {
                    "en": "Tier C: Complex Multi-Tab Workflows",
                    "et": "Tier C: Keerulised mitme vahelehega töölauad",
                    "fi": "Taso C: Monimutkaiset työpöydät",
                    "sv": "Nivå C: Komplexa arbetsytor",
                    "lv": "Līmenis C: Sarežģītas darba virsmas",
                    "lt": "Lygis C: Sudėtingos kelių kortelių formos"
                },
                "desc": {
                    "en": "High-complexity core operational wizards with 5+ blocks. Refactored into APEX Page Groups and Drawers in 8-12 days per form.",
                    "et": "Kõrge keerukusega töölauad ja viisardid (5+ plokki). Viimistletakse lehegruppide ja modaalakendega 8–12 päeva vormi kohta.",
                    "fi": "Monimutkaiset viisardit ja työpöydät. Vaatii 8-12 päivää lomakkeelta.",
                    "sv": "Komplexa flerblocksformulär. Tar 8-12 dagar per formulär.",
                    "lv": "Sarežģīti vedņi un daudzbloku formas. 8-12 dienas uz formu.",
                    "lt": "Sudėtingi vedliai ir daugiafunkcės formos. 8-12 dienų formai."
                }
            }
        ],
        "speaker_notes": {
            "en": "🎯 Core Takeaway: 150 forms is not an insurmountable mountain. 20-30 forms will be retired, 50 are simple queries, 50 are standard grids, and only ~20 need deep focus.<br/>💡 Talking Points: Emphasize the audit. We do not waste money migrating forms nobody opened in 3 years.",
            "et": "🎯 Peamine sõnum: 150 vormi ei ole ületamatu mägi. 20–30 vormi karsitakse, 50 on lihtsad päringud, 50 tavapärased tabelid ja vaid ~20 nõuavad süvitsiminekut.<br/>💡 Rääkimispunktid: Rõhuta auditit. Me ei raiska aega ega raha selliste vormide migreerimisele, mida keegi pole viimased 3 aastat kasutanud.",
            "fi": "🎯 Pääviesti: 150 lomaketta jaetaan hallittaviin osiin. 20-30 poistetaan kokonaan.<br/>💡 Puhujan muistiinpanot: Emme siirrä turhia ruutuja.",
            "sv": "🎯 Huvudbudskap: 150 formulär bryts ner i hanterbara delar. 20-30 rensas bort.",
            "lv": "🎯 Galvenais vēstījums: 150 formas tiek sadalītas reālos posmos. 20-30 tiek dzēstas.",
            "lt": "🎯 Pagrindinė žinutė: 150 formų suskaidoma į aiškius etapus. 20-30 išvis atmetama."
        }
    },
    12: {
        "badge": {
            "en": "⏱️ SLIDE 12 / 13 • TIMELINES &amp; DECOMMISSIONING GATES",
            "et": "⏱️ SLAID 12 / 13 • AJAGRAAFIKUD &amp; DECOMMISSIONING VÄRAVAD",
            "fi": "⏱️ DIA 12 / 13 • AIKATAULUT &amp; PALVELINTEN ALASAJO",
            "sv": "⏱️ BILD 12 / 13 • TIDPLAN &amp; AVVECKLINGSGRINDAR",
            "lv": "⏱️ SLAIDS 12 / 13 • LAIKA GRAFIKS &amp; DEKOMISIJAS VĀRTI",
            "lt": "⏱️ SKAIDRĖ 12 / 13 • GRAFIKAS IR IŠJUNGIMO VARTAI"
        },
        "title": {
            "en": "Delivery Timelines (10–12 Mo vs 16–18 Mo) &amp; WebLogic Shutdown Milestones",
            "et": "Ajagraafikud (10–12k vs 16–18k) ja WebLogic serverite sulgemise teekaart",
            "fi": "Aikataulut (10–12 kk vs 16–18 kk) ja WebLogic-palvelinten alasajo",
            "sv": "Tidslinjer (10–12 mån vs 16–18 mån) och WebLogic-avveckling",
            "lv": "Termiņi (10–12 mēn pret 16–18 mēn) un WebLogic slēgšana",
            "lt": "Grafikas (10–12 mėn. vs 16–18 mėn.) ir WebLogic išjungimas"
        },
        "lead": {
            "en": "AI-accelerated timeline targets 10–12 months. Realistic buffer accounts for 16–18 months. Clear gates define when legacy servers and licenses are permanently shut down.",
            "et": "AI-kiirendusega graafik sihib 10–12 kuud. Realistlik puhvritega plaan 16–18 kuud. Selged väravad määravad pärandserverite ja litsentside lõpliku sulgemise.",
            "fi": "AI-nopeutettu aikataulu tähtää 10–12 kuukauteen. Realistinen puskurillinen aikataulu 16–18 kk. Selkeät portit WebLogicin sulkemiselle.",
            "sv": "AI-accelererad plan siktar på 10–12 månader. Realistisk plan med buffert 16–18 mån. Tydliga avvecklingsmål.",
            "lv": "AI paātrināts plāns paredz 10–12 mēnešus. Reālistisks ar rezervi 16–18 mēn. Skaidri WebLogic slēgšanas vārti.",
            "lt": "AI pagreitintas grafikas numato 10–12 mėn. Realus su rezervu 16–18 mėn. Aišku, kada išjungiamas WebLogic."
        },
        "cards": [
            {
                "icon": "🚀",
                "kpi": "10–12 KUUD (OPTIMISTLIK)",
                "title": {
                    "en": "AI-Accelerated Pace",
                    "et": "AI-kiirendusega teekond",
                    "fi": "AI-nopeutettu aikataulu",
                    "sv": "AI-accelererad tidsplan",
                    "lv": "AI paātrināts grafiks",
                    "lt": "AI pagreitintas grafikas"
                },
                "desc": {
                    "en": "With APEXlang DSL and Copilot, Tier A forms take 1 day and Tier B forms take 3 days. Total completion in 10-12 months.",
                    "et": "APEXlangi ja Copiloti toel valmivad Tier A vormid 1 päevaga ja Tier B vormid 3 päevaga. Tulemus käes 10–12 kuuga.",
                    "fi": "APEXlangilla ja Copilotilla Tier A valmistuu 1 päivässä ja Tier B 3 päivässä.",
                    "sv": "Med APEXlang tar Tier A 1 dag och Tier B 3 dagar. Mål 10-12 månader.",
                    "lv": "Ar APEXlang Tier A prasa 1 dienu, Tier B 3 dienas. Mērķis 10-12 mēneši.",
                    "lt": "Su APEXlang Tier A trunka 1 dieną, Tier B 3 dienas. Tikslas 10-12 mėnesių."
                }
            },
            {
                "icon": "🛡️",
                "kpi": "16–18 KUUD (REALISTLIK)",
                "title": {
                    "en": "Buffered Enterprise Plan",
                    "et": "Ettevõtte realistlik puhvritega plaan",
                    "fi": "Realistinen puskuroitu suunnitelma",
                    "sv": "Realistisk plan med säkerhetsmarginal",
                    "lv": "Reālistisks plāns ar rezervi",
                    "lt": "Realus planas su saugumo rezervu"
                },
                "desc": {
                    "en": "Accounts for summer holidays, regulatory audits, complex Tier C workflows, and 30-day user adaptation windows.",
                    "et": "Arvestab suvepuhkusi, regulatiivseid auditeid, keerukaid Tier C töövooge ja 30-päevaseid kasutajate kohanemise aknaid.",
                    "fi": "Huomioi kesälomat, viranomaisauditoinnit, Tier C -prosessit ja 30 päivän käyttäjäkoulutukset.",
                    "sv": "Inkluderar semestrar, lagkravsrevisioner och komplexa Tier C-arbetsflöden.",
                    "lv": "Ietver atvaļinājumus, likumdošanas izmaiņas un Tier C procesus.",
                    "lt": "Įtraukia atostogas, auditus ir sudėtingus Tier C procesus."
                }
            },
            {
                "icon": "🚪",
                "kpi": "GATE 1 → 2 → 3",
                "title": {
                    "en": "Decommissioning Gates",
                    "et": "Pärandtaristu sulgemise väravad",
                    "fi": "Alasajon tarkistuspisteet",
                    "sv": "Avvecklingsgrindar",
                    "lv": "Dekomisijas vārti",
                    "lt": "Išjungimo kontrolės vartai"
                },
                "desc": {
                    "en": "Gate 1 (Mo 2): Forms Feature Freeze. Gate 2 (Mo 8): Tier A/B Forms read-only. Gate 3 (Mo 14): Forms & WebLogic servers shutdown.",
                    "et": "Gate 1 (k 2): Forms feature freeze. Gate 2 (k 8): Tier A/B vormid suletud. Gate 3 (k 14): WebLogic ja Forms serverid lõplikult kinni (OpEx sääst!).",
                    "fi": "Portti 1 (kk 2): Jäädytys. Portti 2 (kk 8): Tier A/B suljettu. Portti 3 (kk 14): WebLogic suljetaan pysyvästi.",
                    "sv": "Grind 1 (Mån 2): Frysning. Grind 2 (Mån 8): Tier A/B stängs. Grind 3 (Mån 14): WebLogic stängs av permanent.",
                    "lv": "Vārti 1 (2. mēn): Iesaldēšana. Vārti 2 (8. mēn): Tier A/B slēgts. Vārti 3 (14. mēn): WebLogic tiek izslēgts.",
                    "lt": "Vartai 1 (2 mėn.): Įšaldymas. Vartai 2 (8 mėn.): Tier A/B uždaryta. Vartai 3 (14 mėn.): WebLogic išjungiamas."
                }
            }
        ],
        "speaker_notes": {
            "en": "🎯 Core Takeaway: We give management two honest timelines (10-12 mo best case vs 16-18 mo realistic). Gate 3 provides a concrete milestone for WebLogic license cost elimination.<br/>💡 Talking Points: Emphasize that Gate 3 saves substantial recurring hosting and licensing fees.",
            "et": "🎯 Peamine sõnum: Esitame juhtkonnale kaks ausat graafikut (10–12k parim vs 16–18k realistlik). Gate 3 annab konkreetse kuupäeva, millal WebLogic serveri kulud langevad nulli.<br/>💡 Rääkimispunktid: Püsikulude reaalne vähenemine toimub kohe, kui Gate 3 rakendub.",
            "fi": "🎯 Pääviesti: Selkeät portit 1-3 takaavat, että vanhat palvelimet ajetaan oikeasti alas.",
            "sv": "🎯 Huvudbudskap: Två ärliga tidsplaner och ett tydligt datum för licensbesparingar vid Grind 3.",
            "lv": "🎯 Galvenais vēstījums: Skaidri vārti 1-3 nodrošina reālu izmaksu samazinājumu.",
            "lt": "🎯 Pagrindinė žinutė: Aišku, kada išjungiami serveriai ir sutaupomi pinigai."
        }
    },
    13: {
        "badge": {
            "en": "🏁 SLIDE 13 / 13 • 30-DAY ACTION PLAN &amp; CI/CD",
            "et": "🏁 SLAID 13 / 13 • 30 PÄEVA PLAAN &amp; ORACLE CI/CD",
            "fi": "🏁 DIA 13 / 13 • 30 PÄIVÄN SUUNNITELMA &amp; CI/CD",
            "sv": "🏁 BILD 13 / 13 • 30-DAGARSPLAN &amp; CI/CD",
            "lv": "🏁 SLAIDS 13 / 13 • 30 DIENU PLĀNS &amp; CI/CD",
            "lt": "🏁 SKAIDRĖ 13 / 13 • 30 DIENŲ PLANAS IR CI/CD"
        },
        "title": {
            "en": "Immediate 30-Day Launchpad: Official CI/CD Stack &amp; First Sprint Kickoff",
            "et": "Kohene 30 päeva tegevuskava: Oracle ametlik CI/CD ja 1. sprindi start",
            "fi": "Välitön 30 päivän toimintasuunnitelma: Virallinen CI/CD ja 1. sprintti",
            "sv": "Omedelbar 30-dagarsplan: Officiell CI/CD och start för Sprint 1",
            "lv": "Tūlītējs 30 dienu plāns: Oficiālais CI/CD un 1. sprinta starts",
            "lt": "Neatidėliotinas 30 dienų planas: Oficialus CI/CD ir 1-ojo sprinto pradžia"
        },
        "lead": {
            "en": "Week 1: CI/CD setup (SQLcl Project + Liquibase + Git). Week 2: First pilot report in APEX. Week 3: MyLearn training. Week 4: First executive sprint demo.",
            "et": "Nädal 1: CI/CD paigaldus (SQLcl Project + Liquibase + Git). Nädal 2: Esimene pilootvorm APEXis. Nädal 3: Sisekoolitused. Nädal 4: Pidulik 1. sprindi demo!",
            "fi": "Viikko 1: CI/CD (SQLcl + Liquibase + Git). Viikko 2: Ensimmäinen pilotti. Viikko 3: Koulutukset. Viikko 4: 1. sprintin demo!",
            "sv": "Vecka 1: CI/CD. Vecka 2: Första piloten. Vecka 3: Utbildning. Vecka 4: Demo för ledningen!",
            "lv": "1. nedēļa: CI/CD. 2. nedēļa: Pirmais pilots. 3. nedēļa: Apmācības. 4. nedēļa: 1. sprinta demo!",
            "lt": "1 savaitė: CI/CD. 2 savaitė: Pirmasis pilotas. 3 savaitė: Mokymai. 4 savaitė: 1-ojo sprinto demo!"
        },
        "cards": [
            {
                "icon": "⚙️",
                "kpi": "NÄDAL 1 • AMETLIK CI/CD",
                "title": {
                    "en": "Official Oracle CI/CD Stack",
                    "et": "Oracle ametlik CI/CD konveier",
                    "fi": "Virallinen Oracle CI/CD -pino",
                    "sv": "Officiell Oracle CI/CD-stack",
                    "lv": "Oficiālais Oracle CI/CD steks",
                    "lt": "Oficialus Oracle CI/CD rinkinys"
                },
                "desc": {
                    "en": "SQLcl Project + Liquibase declarative changelogs + GitHub Actions. Automated build, test, and container promotion across environments.",
                    "et": "SQLcl Project + Liquibase deklaratiivsed changelogid + GitHub Actions. Automaatne testimine ja paigaldus DEV -> TEST -> PROD.",
                    "fi": "SQLcl Project + Liquibase + GitHub Actions. Automaattinen asennus ja testaus.",
                    "sv": "SQLcl Project + Liquibase + GitHub Actions för automatisk utrullning.",
                    "lv": "SQLcl Project + Liquibase + GitHub Actions automātiskai ieviešanai.",
                    "lt": "SQLcl Project + Liquibase + GitHub Actions automatiniam diegimui."
                },
                "command": "./scripts/test-local-ci.sh"
            },
            {
                "icon": "🎯",
                "kpi": "NÄDAL 2 • PILOOTVORM",
                "title": {
                    "en": "First Pilot Screen in APEX",
                    "et": "Esimene pilootvorm APEXis",
                    "fi": "Ensimmäinen pilottilomake APEXissa",
                    "sv": "Första pilotformuläret i APEX",
                    "lv": "Pirmā pilota forma APEX",
                    "lt": "Pirmoji bandomoji forma APEX"
                },
                "desc": {
                    "en": "Select 1 high-visibility report. Convert FMB XML to APEXlang DSL. Test Entra ID SSO and 1-click Excel export.",
                    "et": "Valitakse 1 sageli kasutatav aruanne. Teisendatakse FMB XML APEXlang DSL-iks. Testitakse Entra ID SSO-d ja Exceli eksporti.",
                    "fi": "Valitaan 1 tärkeä raportti. Muunnetaan FMB XML APEXlangiksi ja testataan SSO.",
                    "sv": "Välj 1 rapport. Konvertera FMB XML till APEXlang och testa SSO.",
                    "lv": "Izvēlas 1 atskaiti. Konvertē uz APEXlang un pārbauda SSO.",
                    "lt": "Pasirenkama 1 ataskaita. Konvertuojama į APEXlang ir tikrinamas SSO."
                },
                "command": "./scripts/sqlcl.sh"
            },
            {
                "icon": "🎉",
                "kpi": "NÄDAL 4 • PIDULIK DEMO",
                "title": {
                    "en": "Sprint 1 Demo & Celebration",
                    "et": "1. sprindi pidulik demo ja tähistamine",
                    "fi": "Sprintti 1 demo ja juhlistus",
                    "sv": "Sprint 1 demo och firande",
                    "lv": "Sprinta 1 demo un svinības",
                    "lt": "1-ojo sprinto demo ir šventimas"
                },
                "desc": {
                    "en": "Live demonstration to management, business analysts, and users. Proves speed, builds unstoppable team momentum.",
                    "et": "Töötava lahenduse reaalajas esitlus juhtkonnale, ärianalüütikutele ja kasutajatele. Tõestab kiirust ja loob tiimile eduelamuse.",
                    "fi": "Live-demo johdolle ja käyttäjille. Todistaa nopeuden ja tuo onnistumisen ilon.",
                    "sv": "Live-demo för ledning och användare. Bevisar genomförandekraften.",
                    "lv": "Tiešraides demo vadībai un lietotājiem. Pierāda progresu.",
                    "lt": "Tiesioginė demonstracija vadovybei. Įrodo greitį ir kuria sėkmę."
                },
                "command": "./scripts/check-urls.sh"
            }
        ],
        "speaker_notes": {
            "en": "🎯 Core Takeaway: We do not need months of planning to start. In 30 days we have CI/CD running, our team trained, and the first working APEX pilot in front of management.<br/>💡 Talking Points: Reassure everyone that this is an exciting step forward. Invite all roles to the Sprint 1 demo.",
            "et": "🎯 Peamine sõnum: Me ei vaja kuudepikkust venitamist. 30 päevaga on CI/CD püsti, tiim koolitatud ja esimene töötav APEXi piloot juhtkonna ekraanil.<br/>💡 Rääkimispunktid: Kutsuge kõiki sidusrühmi 1. sprindi demopäevale. See on kogu tiimi ühine edulugu.",
            "fi": "🎯 Pääviesti: 30 päivässä meillä on CI/CD, koulutus ja ensimmäinen toimiva pilotti valmiina.",
            "sv": "🎯 Huvudbudskap: På 30 dagar har vi CI/CD, utbildat team och första piloten klar.",
            "lv": "🎯 Galvenais vēstījums: 30 dienās CI/CD ir gatavs un pirmais pilots darbojas.",
            "lt": "🎯 Pagrindinė žinutė: Per 30 dienų paruoštas CI/CD ir pirmoji veikianti demonstracija."
        }
    }
}

FORMS_SUMMARY_HTML = """
<div class="forms-modernization-summary card" style="background: linear-gradient(180deg, #0b1120 0%, #030712 100%); border: 1px solid rgba(56, 189, 248, 0.35); border-radius: 12px; padding: 28px; margin-top: 24px; box-shadow: 0 20px 40px -15px rgba(0, 0, 0, 0.7);">
    
    <!-- HEADER -->
    <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 16px; border-bottom: 1px solid rgba(255,255,255,0.08); padding-bottom: 20px; margin-bottom: 24px;">
        <div>
            <div style="display: inline-flex; align-items: center; gap: 8px; background: rgba(56, 189, 248, 0.12); border: 1px solid rgba(56, 189, 248, 0.3); border-radius: 9999px; padding: 4px 12px; font-size: 0.75rem; font-weight: 700; color: #38bdf8; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 8px;">
                <span>📑</span> Strateegiline Tegevuskava &amp; Arhitektuur
            </div>
            <h2 style="font-size: 1.45rem; font-weight: 800; color: #f8fafc; margin: 0 0 6px 0; letter-spacing: -0.02em;">
                Oracle Forms → APEX Moderniseerimise Strateegia &amp; Tegevuskava
            </h2>
            <p style="font-size: 0.88rem; color: #94a3b8; margin: 0; max-width: 850px; line-height: 1.5;">
                Põhjalik strateegia 150 Oracle Forms vormi sujuvaks evolutsiooniks kaasaegsele Oracle APEX platvormile. Säilitab 25 aasta intellektuaalomandi, väldib naabertoote 10-aastast krahhi ning tagab 100% kooskõla ettevõtte Azure-pilvestrateegiaga.
            </p>
        </div>
        <div style="display: flex; gap: 10px; align-items: center;">
            <button class="btn btn-secondary" onclick="window.print()" style="font-size: 0.82rem; padding: 7px 14px;">
                <span>🖨️</span> Prindi raport
            </button>
            <button class="btn btn-primary" onclick="goToSlide(0)" style="font-size: 0.82rem; padding: 7px 14px;">
                <span>🎬</span> Tagasi esitlusele
            </button>
        </div>
    </div>

    <!-- STRATEGIC COMPARISON TABLE -->
    <div style="margin-bottom: 32px;">
        <h3 style="font-size: 1.1rem; color: #38bdf8; margin: 0 0 14px 0; display: flex; align-items: center; gap: 8px;">
            <span>⚖️</span> Strateegiliste Valikute Võrdlusmaatriks: Miks Evolutsioon Võidab
        </h3>
        <div style="overflow-x: auto;">
            <table class="services-table" style="width: 100%; border-collapse: collapse; font-size: 0.84rem;">
                <thead>
                    <tr style="background: rgba(15, 23, 42, 0.9);">
                        <th style="padding: 10px 14px; text-align: left; color: #94a3b8; border-bottom: 1px solid rgba(255,255,255,0.1);">Mõõdik / Kriteerium</th>
                        <th style="padding: 10px 14px; text-align: left; color: #f87171; border-bottom: 1px solid rgba(255,255,255,0.1);">Valik A: Big-Bang Ümberkirjutus (Vue/Java)</th>
                        <th style="padding: 10px 14px; text-align: left; color: #4ade80; border-bottom: 1px solid rgba(255,255,255,0.1);">Valik B: APEX &amp; Olemasolev Taristu</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td style="padding: 10px 14px; font-weight: 600; color: #f8fafc; border-bottom: 1px solid rgba(255,255,255,0.05);">Valmimise tähtaeg</td>
                        <td style="padding: 10px 14px; color: #fca5a5; border-bottom: 1px solid rgba(255,255,255,0.05);">5–10 aastat (naabertoode on juba 4a teinud, lõppu ei paista)</td>
                        <td style="padding: 10px 14px; color: #86efac; font-weight: 700; border-bottom: 1px solid rgba(255,255,255,0.05);">10–12 kuud (optimistlik) / 16–18k (realistlik)</td>
                    </tr>
                    <tr>
                        <td style="padding: 10px 14px; font-weight: 600; color: #f8fafc; border-bottom: 1px solid rgba(255,255,255,0.05);">Spetsifikatsioon &amp; ärifookus</td>
                        <td style="padding: 10px 14px; color: #fca5a5; border-bottom: 1px solid rgba(255,255,255,0.05);">Konsultandid vajavad detailset spetsifikatsiooni ja ei tunne backend'i; seadused ja elutsükkel jooksevad eest</td>
                        <td style="padding: 10px 14px; color: #86efac; font-weight: 700; border-bottom: 1px solid rgba(255,255,255,0.05);">80–90% loogikast juba baasis; oma tiim (5 DB + 3 analüütikut + 1 Java) tagab 0 teadmusekadu</td>
                    </tr>
                    <tr>
                        <td style="padding: 10px 14px; font-weight: 600; color: #f8fafc; border-bottom: 1px solid rgba(255,255,255,0.05);">Taristu valmidus &amp; DR</td>
                        <td style="padding: 10px 14px; color: #cbd5e1; border-bottom: 1px solid rgba(255,255,255,0.05);">Nõuab uusi komponente, uusi DR-tellimusi ja eraldi mikroteenuste haldust</td>
                        <td style="padding: 10px 14px; color: #86efac; font-weight: 700; border-bottom: 1px solid rgba(255,255,255,0.05);">Keskkond on 100% valmis; 0 uut komponenti, 0 uut DR-tellimust, olemasoleva täielik ärakasutus</td>
                    </tr>
                    <tr>
                        <td style="padding: 10px 14px; font-weight: 600; color: #f8fafc; border-bottom: 1px solid rgba(255,255,255,0.05);">Süsteemi keerukus &amp; WebLogic</td>
                        <td style="padding: 10px 14px; color: #fca5a5; border-bottom: 1px solid rgba(255,255,255,0.05);">WebLogic, Forms ja batch-portaal jäävad aastateks paralleelselt; keerukus kahekordistub</td>
                        <td style="padding: 10px 14px; color: #86efac; font-weight: 700; border-bottom: 1px solid rgba(255,255,255,0.05);">Radikaalne lihtsustamine: Forms, batch-portaal ja WebLogic eemaldatakse; halduskoormus langeb</td>
                    </tr>
                    <tr>
                        <td style="padding: 10px 14px; font-weight: 600; color: #f8fafc; border-bottom: 1px solid rgba(255,255,255,0.05);">Täiendav eelarve &amp; litsentsid</td>
                        <td style="padding: 10px 14px; color: #fca5a5; border-bottom: 1px solid rgba(255,255,255,0.05);">&gt; 1 500 000 € (välised konsultandid, uued litsentsid)</td>
                        <td style="padding: 10px 14px; color: #86efac; font-weight: 700; border-bottom: 1px solid rgba(255,255,255,0.05);">0 € lisalitsentsi (APEX sisaldub baasis), oma tiim</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

    <!-- MERMAID DIAGRAM 1: 2-PHASE ARCHITECTURE -->
    <div style="margin-bottom: 32px;">
        <h3 style="font-size: 1.1rem; color: #38bdf8; margin: 0 0 8px 0; display: flex; align-items: center; gap: 8px;">
            <span>🏗️</span> Arhitektuurne Skeem 1: 2-Etapiline Evolutsioon ja Azure ODSA Pilvesiht
        </h3>
        <p style="font-size: 0.8rem; color: #94a3b8; margin: 0 0 12px 0;">
            Kõrge kontrastsusega arhitektuurijoonis (Rule 10): selged otsuse-rombikujulised sõlmed ja mitmekihiline subgraafide hierarhia.
        </p>
        <pre class="mermaid">
flowchart TB
    classDef clientTier fill:#0284c7,stroke:#0369a1,stroke-width:2px,color:#ffffff;
    classDef midTier fill:#0f766e,stroke:#115e59,stroke-width:2px,color:#ffffff;
    classDef dbTier fill:#1e293b,stroke:#334155,stroke-width:2px,color:#ffffff;
    classDef cloudTarget fill:#065f46,stroke:#047857,stroke-width:2px,color:#ffffff;

    subgraph Tier_Clients["1. Esitluskiht ja Kasutajad"]
        direction LR
        U_Web["Veebibrauser<br/>(APEX Responsive UI)"]:::clientTier
        U_Forms["Vana Forms Applet<br/>(30p Tagasitee Võrk)"]:::clientTier
        U_Batch["Ettevõtte Portaal<br/>(Java Batch Teenus)"]:::clientTier
    end

    subgraph Tier_Gateway["2. Identiteedi ja API Värav"]
        direction LR
        GW_SSO["Azure Entra ID<br/>(OIDC SSO Autentimine)"]:::midTier
        GW_ORDS["ORDS 26.1 API Värav<br/>(OpenAPI 3.0 / Swagger)"]:::midTier
    end

    subgraph Tier_DB["3. Tuumik: Oracle Andmebaas (Olemasolev Baas)"]
        direction TB
        DB_APEX["APEX 26.1 Runtime<br/>(Veebirakenduste Mootor)"]:::dbTier
        DB_API["PL/SQL API Kiht<br/>(25a Läbiproovitud Paketid)"]:::dbTier
        DB_DATA["Tabelid ja Tehingud<br/>(Ühtne Andmetõde - SSOT)"]:::dbTier
        DB_APEX --> DB_API
        DB_API --> DB_DATA
    end

    subgraph Tier_Cloud["4. Pilve Sihtarhitektuur (Faas 2)"]
        direction TB
        AZ_ODSA["Oracle Database@Azure<br/>(ODSA Microsoft Azure DC-s)"]:::cloudTarget
        AZ_NET["Azure VNet Integreeritus<br/>(Latentsus alla 1 ms)"]:::cloudTarget
        AZ_ODSA --- AZ_NET
    end

    U_Web --> GW_SSO
    GW_SSO --> DB_APEX
    U_Forms -.->|30p Turvavõrk| DB_API
    U_Batch --> GW_ORDS
    GW_ORDS --> DB_API
    Tier_DB ==>|Faas 2: 0 Koodimuudatust| Tier_Cloud
        </pre>
    </div>

    <!-- MERMAID DIAGRAM 2: 6-STAGE VIBE-CODING LOOP -->
    <div style="margin-bottom: 32px;">
        <h3 style="font-size: 1.1rem; color: #38bdf8; margin: 0 0 8px 0; display: flex; align-items: center; gap: 8px;">
            <span>⚡</span> Arhitektuurne Skeem 2: 6-Etapiline AI Vibe-Coding Tsükkel
        </h3>
        <p style="font-size: 0.8rem; color: #94a3b8; margin: 0 0 12px 0;">
            Kaudne koodigeneratsioon APEXlang DSL (.apx), ametliku EBNF grammatika ja SQLcl MCP serveri koostöös.
        </p>
        <pre class="mermaid">
flowchart LR
    classDef loopStep fill:#1e1b4b,stroke:#4338ca,stroke-width:2px,color:#ffffff;
    classDef gateStep fill:#831843,stroke:#9d174d,stroke-width:2px,color:#ffffff;
    classDef okStep fill:#064e3b,stroke:#047857,stroke-width:2px,color:#ffffff;

    subgraph VibeLoop["AI Vibe-Coding Konveier (150 Vormi Kiirendus)"]
        direction LR
        ST1["1. Skeemitõde<br/>(MCP sql -mcp)"]:::loopStep
        ST2["2. PL/SQL Pakett<br/>(STATUS = VALID)"]:::loopStep
        ST3["3. APEXlang DSL<br/>(.apx + messages.apx)"]:::loopStep
        ST4{"4. Kas süntaks<br/>ja EBNF klapib?<br/>(apexctl validate)"}:::gateStep
        ST5["5. Import DEV Baasi<br/>(apex import)"]:::okStep
        ST6["6. Git Diff Kontroll<br/>(Iniminseneri Heakskiit)"]:::okStep
    end

    ST1 --> ST2
    ST2 --> ST3
    ST3 --> ST4
    ST4 -->|JAH / Kehtiv| ST5
    ST4 -->|EI / Viga| ST3
    ST5 --> ST6
        </pre>
    </div>

    <!-- MERMAID DIAGRAM 3: DECOMMISSIONING GATES -->
    <div style="margin-bottom: 32px;">
        <h3 style="font-size: 1.1rem; color: #38bdf8; margin: 0 0 8px 0; display: flex; align-items: center; gap: 8px;">
            <span>🚪</span> Arhitektuurne Skeem 3: Pärandtaristu Sulgemise Väravad (Decommissioning Gates)
        </h3>
        <p style="font-size: 0.8rem; color: #94a3b8; margin: 0 0 12px 0;">
            Kontrollitud ja turvaline teekaart WebLogic ja Forms serverite sulgemiseks ning püsikulude likvideerimiseks.
        </p>
        <pre class="mermaid">
flowchart TB
    classDef gateBlock fill:#312e81,stroke:#4338ca,stroke-width:2px,color:#ffffff;
    classDef decisionBlock fill:#701a75,stroke:#86198f,stroke-width:2px,color:#ffffff;
    classDef actionBlock fill:#0f766e,stroke:#115e59,stroke-width:2px,color:#ffffff;

    subgraph Gates["Pärandtaristu Sulgemise Verstapostid"]
        direction TB
        G1["VÄRAV 1 (Kuu 2):<br/>Forms Feature Freeze Mandaat"]:::gateBlock
        D1{"Kas vanas vormis<br/>on kriitiline viga<br/>või seadusmuudatus?"}:::decisionBlock
        A1["Lahendatakse vanas<br/>ainult P1 turvavead"]:::actionBlock
        A2["Uued funktsioonid<br/>ehitatakse ainult APEXisse"]:::actionBlock

        G2["VÄRAV 2 (Kuu 8):<br/>Tier A/B Vormide Sulgemine"]:::gateBlock
        D2{"Kas 30p paralleelne<br/>turvavõrk on möödas<br/>ja vigu ei esine?"}:::decisionBlock
        A3["Vorm lülitatakse<br/>Formsis ainult lugemiseks"]:::actionBlock

        G3["VÄRAV 3 (Kuu 14):<br/>WebLogic / Forms Täielik Seiskamine"]:::gateBlock
        A4["Forms Server ja WebLogic suletakse.<br/>Serveripinnad ja litsentsikulud vabad!"]:::actionBlock
    end

    G1 --> D1
    D1 -->|JAH / P1 viga| A1
    D1 -->|EI / Uus soov| A2
    A2 --> G2
    G2 --> D2
    D2 -->|JAH / Stabiilne| A3
    A3 --> G3
    G3 --> A4
        </pre>
    </div>

    <!-- 10 PERSPECTIVES MATRIX -->
    <div style="margin-bottom: 32px;">
        <h3 style="font-size: 1.1rem; color: #38bdf8; margin: 0 0 14px 0; display: flex; align-items: center; gap: 8px;">
            <span>👥</span> Ekspertide ja Sidusrühmade Konsensus: 8 Vaatenurka
        </h3>
        <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 16px;">
            
            <div style="background: rgba(15, 23, 42, 0.7); border: 1px solid rgba(255,255,255,0.08); border-radius: 8px; padding: 14px;">
                <div style="font-weight: 700; color: #38bdf8; margin-bottom: 4px; display: flex; align-items: center; gap: 6px;">
                    <span>👨‍💻</span> Tarkvaraarendaja vaade
                </div>
                <div style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.45;">
                    Stateless seansid ja olemasolevate PL/SQL pakettide taaskasutus. Java taustaportaal isoleeritakse ORDS REST API taha, mis välistab otsese andmebaasisidumise.
                </div>
            </div>

            <div style="background: rgba(15, 23, 42, 0.7); border: 1px solid rgba(255,255,255,0.08); border-radius: 8px; padding: 14px;">
                <div style="font-weight: 700; color: #a855f7; margin-bottom: 4px; display: flex; align-items: center; gap: 6px;">
                    <span>🎨</span> UX-arhitekti vaade
                </div>
                <div style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.45;">
                    Kompaktne režiim (Dense Mode), 30-40 rida ekraanil. Enter/Tab navigatsioon, kiirklahvid (F7/F8 asendus) ja hoiatused salvestamata andmete kaitsmiseks.
                </div>
            </div>

            <div style="background: rgba(15, 23, 42, 0.7); border: 1px solid rgba(255,255,255,0.08); border-radius: 8px; padding: 14px;">
                <div style="font-weight: 700; color: #ef4444; margin-bottom: 4px; display: flex; align-items: center; gap: 6px;">
                    <span>🛡️</span> Küberturbe eksperdi vaade
                </div>
                <div style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.45;">
                    Azure Entra ID (OIDC) SSO, SHA-256 Session State Protection, IDOR kaitse ja reaalne APP_USER auditikontekst andmebaasi trigerites ning SIEM-is.
                </div>
            </div>

            <div style="background: rgba(15, 23, 42, 0.7); border: 1px solid rgba(255,255,255,0.08); border-radius: 8px; padding: 14px;">
                <div style="font-weight: 700; color: #22c55e; margin-bottom: 4px; display: flex; align-items: center; gap: 6px;">
                    <span>👥</span> Lõppkasutaja vaade
                </div>
                <div style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.45;">
                    0 topeltandmesisestust (1 ühine andmebaas). 30-päevane turvaline tagasipöördumise nupp vanasse vormi, 1-kliki tagasiside andmine ja 1-kliki Excel eksport.
                </div>
            </div>

            <div style="background: rgba(15, 23, 42, 0.7); border: 1px solid rgba(255,255,255,0.08); border-radius: 8px; padding: 14px;">
                <div style="font-weight: 700; color: #f59e0b; margin-bottom: 4px; display: flex; align-items: center; gap: 6px;">
                    <span>🤝</span> Tiimiliikme &amp; Töörahu vaade
                </div>
                <div style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.45;">
                    5 DB arendajat + 3 analüütikut + 1 kogenud Java konsultant. Java ekspert hoiab töös batch-portaali (vabastades DB tiimi 100% Formsile) ja ehitab hiljem mikroteenuseid. 60/40 koormusreegel ja Forms feature freeze.
                </div>
            </div>

            <div style="background: rgba(15, 23, 42, 0.7); border: 1px solid rgba(255,255,255,0.08); border-radius: 8px; padding: 14px;">
                <div style="font-weight: 700; color: #38bdf8; margin-bottom: 4px; display: flex; align-items: center; gap: 6px;">
                    <span>🏛️</span> Ettevõtte Arhitekti (EA) vaade
                </div>
                <div style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.45;">
                    Oracle Database@Azure (ODSA) tagab 100% pilvevalmiduse ilma koodi ümberkirjutamata. ORDS kui ametlik OpenAPI 3.0 (Swagger) kataloogi API värav.
                </div>
            </div>

            <div style="background: rgba(15, 23, 42, 0.7); border: 1px solid rgba(255,255,255,0.08); border-radius: 8px; padding: 14px;">
                <div style="font-weight: 700; color: #ec4899; margin-bottom: 4px; display: flex; align-items: center; gap: 6px;">
                    <span>📋</span> Tiimijuhi &amp; PM-i vaade
                </div>
                <div style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.45;">
                    Range ulatuse kontroll (0 äriprotsesside ümberdisaini 1. faasis). 2-nädalased sprindid, 1. kuu varajane demo ja läbipaistev burndown juhtpaneel.
                </div>
            </div>

            <div style="background: rgba(15, 23, 42, 0.7); border: 1px solid rgba(255,255,255,0.08); border-radius: 8px; padding: 14px;">
                <div style="font-weight: 700; color: #10b981; margin-bottom: 4px; display: flex; align-items: center; gap: 6px;">
                    <span>💼</span> Juhtkonna (C-Level) vaade
                </div>
                <div style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.45;">
                    Äririskide täielik maandamine, 0€ lisalitsentsi, talitluspidevus ja kirjalik Forms feature freeze direktiiv meeskonna kaitseks.
                </div>
            </div>

            <div style="background: rgba(15, 23, 42, 0.7); border: 1px solid rgba(255,255,255,0.08); border-radius: 8px; padding: 14px;">
                <div style="font-weight: 700; color: #6366f1; margin-bottom: 4px; display: flex; align-items: center; gap: 6px;">
                    <span>🧙‍♂️</span> Forms &amp; APEX Guru reeglid
                </div>
                <div style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.45;">
                    Optimistlik lukustus (Lost Update Protection) asendab SELECT FOR UPDATE. Trigerite de-chattifitseerimine ja natiivne Interactive Grid master-detail.
                </div>
            </div>

            <div style="background: rgba(15, 23, 42, 0.7); border: 1px solid rgba(255,255,255,0.08); border-radius: 8px; padding: 14px;">
                <div style="font-weight: 700; color: #06b6d4; margin-bottom: 4px; display: flex; align-items: center; gap: 6px;">
                    <span>🤖</span> AI &amp; APEXlang Guru printsiibid
                </div>
                <div style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.45;">
                    Kaudne generatsioon ("genereeri ainult seda, mida soovid ise omada"). Ametlik EBNF grammatika (GBNF), SQLcl MCP skeemitõde ja Git diff kontroll.
                </div>
            </div>

        </div>
    </div>

    <!-- 30-DAY ACTION PLAN TABLE -->
    <div>
        <h3 style="font-size: 1.1rem; color: #38bdf8; margin: 0 0 14px 0; display: flex; align-items: center; gap: 8px;">
            <span>🏁</span> 30 Päeva Stardi Tegevuskava (Nädalate Lõikes)
        </h3>
        <div style="overflow-x: auto;">
            <table class="services-table" style="width: 100%; border-collapse: collapse; font-size: 0.84rem;">
                <thead>
                    <tr style="background: rgba(15, 23, 42, 0.9);">
                        <th style="padding: 10px 14px; text-align: left; color: #94a3b8; border-bottom: 1px solid rgba(255,255,255,0.1); width: 120px;">Aeg</th>
                        <th style="padding: 10px 14px; text-align: left; color: #38bdf8; border-bottom: 1px solid rgba(255,255,255,0.1);">Põhitegevused &amp; Verstapostid</th>
                        <th style="padding: 10px 14px; text-align: left; color: #4ade80; border-bottom: 1px solid rgba(255,255,255,0.1);">Oodatav Tulemus &amp; Artefakt</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td style="padding: 10px 14px; font-weight: 700; color: #f8fafc; border-bottom: 1px solid rgba(255,255,255,0.05);">Nädal 1</td>
                        <td style="padding: 10px 14px; color: #cbd5e1; border-bottom: 1px solid rgba(255,255,255,0.05);">
                            Ametliku CI/CD konveieri seadistamine (SQLcl Project + Liquibase changelogid + Git repo). Forms feature freeze direktiivi allkirjastamine.
                        </td>
                        <td style="padding: 10px 14px; color: #86efac; border-bottom: 1px solid rgba(255,255,255,0.05);">
                            Töötav <code>test-local-ci.sh</code> simulatsioon, Git branchimine ja selge mandaat.
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 10px 14px; font-weight: 700; color: #f8fafc; border-bottom: 1px solid rgba(255,255,255,0.05);">Nädal 2</td>
                        <td style="padding: 10px 14px; color: #cbd5e1; border-bottom: 1px solid rgba(255,255,255,0.05);">
                            Esimese pilootvormi valik (Tier A aruanne). FMB XML dekonstrueerimine APEXlang DSL-iks, lehe genereerimine ja import DEV keskkonda.
                        </td>
                        <td style="padding: 10px 14px; color: #86efac; border-bottom: 1px solid rgba(255,255,255,0.05);">
                            Töötav APEXi interaktiivne aruanne, 1-kliki Excel eksport ja Entra ID SSO test.
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 10px 14px; font-weight: 700; color: #f8fafc; border-bottom: 1px solid rgba(255,255,255,0.05);">Nädal 3</td>
                        <td style="padding: 10px 14px; color: #cbd5e1; border-bottom: 1px solid rgba(255,255,255,0.05);">
                            5 andmebaasiarendaja sisekoolitus (Oracle MyLearn APEX Developer kursus). SQLcl MCP serveri ja Copilot integratsiooni häälestus töökohtadel.
                        </td>
                        <td style="padding: 10px 14px; color: #86efac; border-bottom: 1px solid rgba(255,255,255,0.05);">
                            Arendajatel on töölaual AI Vibe-Coding valmidus ja ühtsed standardid.
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 10px 14px; font-weight: 700; color: #f8fafc; border-bottom: 1px solid rgba(255,255,255,0.05);">Nädal 4</td>
                        <td style="padding: 10px 14px; color: #cbd5e1; border-bottom: 1px solid rgba(255,255,255,0.05);">
                            Sprint 1 pidulik reaalajas demo juhtkonnale, ärianalüütikutele ja kasutajatele. Esimese 10 aruandevormi tootmisse viimine.
                        </td>
                        <td style="padding: 10px 14px; color: #86efac; border-bottom: 1px solid rgba(255,255,255,0.05);">
                            Vankumatu usaldus juhtkonnas ja eduelamus kogu tiimis.
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

</div>
"""
