#!/usr/bin/env python3
"""
Generate Developer & DevOps Command Center (docs/dev-hub.html)
Features:
- Full 5-language localization (🇬🇧 EN, 🇪🇪 ET, 🇸🇪 SV, 🇱🇻 LV, 🇱🇹 LT) across ALL tabs:
  1. Services & Status (Explicit cards for APEX WS, APEX Admin, SDW, ORDS, Publisher, Forms Runtime, Forms GUI noVNC, Web IDE)
  2. Architecture & Topology (Interactive Mermaid.js diagrams with translated node labels across 5 languages)
  3. Blueprints Explorer (23 canonical blueprints with localized titles & descriptions)
  4. Documentation Reader (Zero-CORS, renders localized markdown per active language)
  5. DevOps Commands (Localized cards, descriptions, and helper snippets)
  6. Logs & Benchmarks (Localized table headers, step benchmarks, and status badges)
"""

import os
import sys
import json
import glob
import re
import subprocess

WORKSPACE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))
OUTPUT_FILE = sys.argv[1] if len(sys.argv) > 1 else os.path.join(WORKSPACE_DIR, "docs/dev-hub.html")

# 1. Embedded Documentation Files (Multilingual files & titles)
DOC_SPECS = [
    {
        "id": "readme",
        "rel": "README.md",
        "titles": {
            "en": "📖 Quick Start & Platform Overview",
            "et": "📖 Kiiralustus ja Platvormi Ülevaade",
            "sv": "📖 Snabbstart & Plattformöversikt",
            "lv": "📖 Ātrā Darba Sākšana & Pārskats",
            "lt": "📖 Greitas Pradžiamokslis ir Apžvalga"
        },
        "files": {
            "en": "README.md",
            "et": "docs/et/README.md",
            "sv": "docs/sv/README.md",
            "lv": "docs/lv/README.md",
            "lt": "docs/lt/README.md"
        }
    },
    {
        "id": "quick-login",
        "rel": "docs/quick-login-guide.md",
        "titles": {
            "en": "🚀 Quick Login & Clipboard Guide",
            "et": "🚀 Kiirjuhend Sisselogimiseks",
            "fi": "🚀 Pikaopas Kirjautumiseen",
            "sv": "🚀 Snabbguide för Inloggning",
            "lv": "🚀 Ātrās Pieteikšanās Rokasgrāmata",
            "lt": "🚀 Greito Prisijungimo Gidas"
        },
        "files": {
            "en": "docs/quick-login-guide.md",
            "et": "docs/et/quick-login-guide.md",
            "fi": "docs/fi/quick-login-guide.md",
            "sv": "docs/quick-login-guide.md",
            "lv": "docs/quick-login-guide.md",
            "lt": "docs/quick-login-guide.md"
        }
    },
    {
        "id": "db-topology",
        "rel": "docs/db-profiles-and-topology.md",
        "titles": {
            "en": "🏗️ Database Profiles & Topology",
            "et": "🏗️ Andmebaasi Profiilid ja Topoloogia",
            "fi": "🏗️ Tietokantaprofiilit ja Topologia",
            "sv": "🏗️ Databasprofiler och Topologi",
            "lv": "🏗️ Datubāzu Profili un Topoloģija",
            "lt": "🏗️ Duomenų Bazių Profiliai ir Topologija"
        },
        "files": {
            "en": "docs/db-profiles-and-topology.md",
            "et": "docs/db-profiles-and-topology.md",
            "fi": "docs/db-profiles-and-topology.md",
            "sv": "docs/db-profiles-and-topology.md",
            "lv": "docs/db-profiles-and-topology.md",
            "lt": "docs/db-profiles-and-topology.md"
        }
    },
    {
        "id": "forms-setup",
        "rel": "docs/forms-setup.md",
        "titles": {
            "en": "📄 Oracle Forms 14c & Modernization",
            "et": "📄 Oracle Forms 14c ja Moderniseerimine",
            "fi": "📄 Oracle Forms 14c & Modernisointi",
            "sv": "📄 Oracle Forms 14c & Modernisering",
            "lv": "📄 Oracle Forms 14c un Modernizācija",
            "lt": "📄 Oracle Forms 14c ir Modernizavimas"
        },
        "files": {
            "en": "docs/forms-setup.md",
            "et": "docs/et/forms-setup.md",
            "fi": "docs/fi/forms-setup.md",
            "sv": "docs/forms-setup.md",
            "lv": "docs/forms-setup.md",
            "lt": "docs/forms-setup.md"
        }
    },
    {
        "id": "publisher-setup",
        "rel": "docs/publisher-setup.md",
        "titles": {
            "en": "📊 Analytics Publisher (Pixel-Perfect)",
            "et": "📊 Analytics Publisher Aruandlus",
            "fi": "📊 Analytics Publisher Raportointi",
            "sv": "📊 Analytics Publisher Rapportering",
            "lv": "📊 Analytics Publisher Atskaites",
            "lt": "📊 Analytics Publisher Ataskaitos"
        },
        "files": {
            "en": "docs/publisher-setup.md",
            "et": "docs/et/publisher-setup.md",
            "fi": "docs/fi/publisher-setup.md",
            "sv": "docs/publisher-setup.md",
            "lv": "docs/publisher-setup.md",
            "lt": "docs/publisher-setup.md"
        }
    },
    {
        "id": "security",
        "rel": "docs/turvalisus.md",
        "titles": {
            "en": "🔐 Security, TLS & SEPS Wallet",
            "et": "🔐 Turvalisus, TLS ja SEPS Wallet",
            "fi": "🔐 Tietoturva, TLS ja SEPS Wallet",
            "sv": "🔐 Säkerhet, TLS och SEPS Wallet",
            "lv": "🔐 Drošība, TLS un SEPS Wallet",
            "lt": "🔐 Saugumas, TLS ir SEPS Wallet"
        },
        "files": {
            "en": "docs/turvalisus.md",
            "et": "docs/turvalisus.md",
            "fi": "docs/turvalisus.md",
            "sv": "docs/turvalisus.md",
            "lv": "docs/turvalisus.md",
            "lt": "docs/turvalisus.md"
        }
    },
    {
        "id": "web-ide",
        "rel": "docs/web-ide-artifactory.md",
        "titles": {
            "en": "💻 Web IDE & Artifactory Setup",
            "et": "💻 Web IDE ja Artifactory Seadistus",
            "fi": "💻 Web IDE & Artifactory -asennus",
            "sv": "💻 Web IDE och Artifactory",
            "lv": "💻 Web IDE un Artifactory",
            "lt": "💻 Web IDE ir Artifactory"
        },
        "files": {
            "en": "docs/web-ide-artifactory.md",
            "et": "docs/et/web-ide-artifactory.md",
            "fi": "docs/fi/web-ide-artifactory.md",
            "sv": "docs/web-ide-artifactory.md",
            "lv": "docs/web-ide-artifactory.md",
            "lt": "docs/lt/web-ide-artifactory.md"
        }
    },
    {
        "id": "apex-deploy",
        "rel": "docs/apex-apps-deployment.md",
        "titles": {
            "en": "📦 APEX Application CI/CD Deployment",
            "et": "📦 APEX Rakenduste CI/CD Tarne",
            "fi": "📦 APEX-sovellusten CI/CD -julkaisu",
            "sv": "📦 APEX Applikation CI/CD Deployment",
            "lv": "📦 APEX Lietotņu CI/CD Piegāde",
            "lt": "📦 APEX Programų CI/CD Diegimas"
        },
        "files": {
            "en": "docs/apex-apps-deployment.md",
            "et": "docs/apex-apps-deployment.md",
            "fi": "docs/apex-apps-deployment.md",
            "sv": "docs/apex-apps-deployment.md",
            "lv": "docs/apex-apps-deployment.md",
            "lt": "docs/apex-apps-deployment.md"
        }
    },
    {
        "id": "setup-workflow",
        "rel": "docs/setup-all-workflow.md",
        "titles": {
            "en": "⚡ Setup-All Architecture & Metrics",
            "et": "⚡ Setup-All Arhitektuur ja Mõõdikud",
            "fi": "⚡ Setup-All Arkkitehtuuri ja Mittarit",
            "sv": "⚡ Setup-All Arkitektur och Mätvärden",
            "lv": "⚡ Setup-All Arhitektūra un Metrika",
            "lt": "⚡ Setup-All Architektūra ir Metrika"
        },
        "files": {
            "en": "docs/setup-all-workflow.md",
            "et": "docs/setup-all-workflow.md",
            "fi": "docs/setup-all-workflow.md",
            "sv": "docs/setup-all-workflow.md",
            "lv": "docs/setup-all-workflow.md",
            "lt": "docs/setup-all-workflow.md"
        }
    },
    {
        "id": "future-plans",
        "rel": "docs/future-plans.md",
        "titles": {
            "en": "🚀 Future Architecture Roadmap",
            "et": "🚀 Tuleviku Arhitektuurne Teekaart",
            "fi": "🚀 Tulevaisuuden Arkkitehtuurin Tie-kartta",
            "sv": "🚀 Framtida Arkitektur Färdplan",
            "lv": "🚀 Nākotnes Arhitektūras Ceļvedis",
            "lt": "🚀 Ateities Architektūros Gairės"
        },
        "files": {
            "en": "docs/future-plans.md",
            "et": "docs/future-plans.md",
            "fi": "docs/future-plans.md",
            "sv": "docs/future-plans.md",
            "lv": "docs/future-plans.md",
            "lt": "docs/future-plans.md"
        }
    },
    {
        "id": "forms-to-apex",
        "rel": "docs/forms-to-apex-migration-guide.md",
        "titles": {
            "en": "🚀 Forms-to-APEX Modernization Guide",
            "et": "🚀 Forms -> APEX Moderniseerimise Juhend",
            "fi": "🚀 Forms -> APEX Modernisointiopas",
            "sv": "🚀 Forms -> APEX Moderniseringsguide",
            "lv": "🚀 Forms -> APEX Modernizācijas Rokasgrāmata",
            "lt": "🚀 Forms -> APEX Modernizavimo Vadovas"
        },
        "files": {
            "en": "docs/forms-to-apex-migration-guide.md",
            "et": "docs/et/forms-to-apex-migration-guide.md",
            "fi": "docs/fi/forms-to-apex-migration-guide.md",
            "sv": "docs/sv/forms-to-apex-migration-guide.md",
            "lv": "docs/lv/forms-to-apex-migration-guide.md",
            "lt": "docs/lt/forms-to-apex-migration-guide.md"
        }
    },
    {
        "id": "blueprints-matrix",
        "rel": "config/blueprints/README.md",
        "titles": {
            "en": "📋 Architecture Blueprints Matrix",
            "et": "📋 Arhitektuursete Kavandite Maatriks",
            "fi": "📋 Arkkitehtuurin Blueprint-Matriisi",
            "sv": "📋 Arkitektur Blueprints Matris",
            "lv": "📋 Arhitektūras Plānu Matrica",
            "lt": "📋 Architektūros Planų Matrica"
        },
        "files": {
            "en": "config/blueprints/README.md",
            "et": "config/blueprints/README.et.md",
            "fi": "config/blueprints/README.fi.md",
            "sv": "config/blueprints/README.md",
            "lv": "config/blueprints/README.md",
            "lt": "config/blueprints/README.md"
        }
    }
]

docs_data = []
for spec in DOC_SPECS:
    contents = {}
    for lang, rel_f in spec["files"].items():
        fp = os.path.join(WORKSPACE_DIR, rel_f)
        if not os.path.exists(fp):
            fp = os.path.join(WORKSPACE_DIR, spec["rel"])
        c = ""
        if os.path.exists(fp):
            with open(fp, "r", encoding="utf-8", errors="ignore") as f:
                c = f.read()
        contents[lang] = c
    
    docs_data.append({
        "id": spec["id"],
        "rel": spec["rel"],
        "titles": spec["titles"],
        "contents": contents
    })

# 2. Blueprints Catalog with Multilingual Metadata (11 Curated Models)
BP_CATALOG = {
    3: {
        "cat": "core", "ram": "3-4 GB", "conts": "db-proxy, db-alise, app-ords",
        "en": ("🌟 2-DB Hybrid Production Stack (DEFAULT)", "Standard 2-layer secure network topology (isolated Proxy DB and ALISE DB) with APEX SSO Gateway and ORDS."),
        "et": ("🌟 2-DB Hübriid Tootmisvirn (VAIKIMISI)", "Standardne 2-kihiline turvaline võrgutopoloogia (eraldatud Proxy DB ja ALISE DB) koos APEX SSO ja ORDS-iga."),
        "fi": ("🌟 2-DB Hybridi Tuotantopino (OLETUS)", "Standardi 2-kerroksinen tietoturvallinen topologia (Proxy DB ja ALISE DB) APEX SSO:lla ja ORDS:lla."),
        "sv": ("🌟 2-DB Hybrid Produktionsstack (STANDARD)", "Standard 2-lagers säker nätverkstopologi (isolerad Proxy DB och ALISE DB) med APEX SSO och ORDS."),
        "lv": ("🌟 2-DB Hibrīda Ražošanas Steks (NOKLUSĒJUMS)", "Standarta 2 slāņu droša tīkla topoloģija (atsevišķa Proxy DB un ALISE DB) ar APEX SSO un ORDS."),
        "lt": ("🌟 2-DB Hibridinis Gamybos Rinkinys (NUMATYTASIS)", "Standartinė 2 sluoksnių saugi tinklo topologija (atskira Proxy DB ir ALISE DB) su APEX SSO ir ORDS.")
    },
    7: {
        "cat": "core", "ram": "3-4 GB", "conts": "db-proxy, db-alise, app-ords",
        "en": ("Multi-Vendor Hybrid Cluster", "Official Oracle 23ai image (Proxy) and Gerald Venzl image (ALISE) co-existing."),
        "et": ("Mitme Tarnija Hübriidklaster", "Ametlik Oracle 23ai pilt (Proxy) ja Gerald Venzl pilt (ALISE) koos töötamas."),
        "fi": ("Monitoimittaja Hybridiryhmä", "Virallinen Oracle 23ai -kuva (Proxy) ja Gerald Venzl -kuva (ALISE) yhdessä."),
        "sv": ("Multi-Vendor Hybridkluster", "Officiell Oracle 23ai-avbild (Proxy) och Gerald Venzl-avbild (ALISE) tillsammans."),
        "lv": ("Daudzu Piegādātāju Hibrīda Klasteris", "Oficiālais Oracle 23ai attēls (Proxy) un Gerald Venzl attēls (ALISE) kopā."),
        "lt": ("Kelių Tiekėjų Hibridinis Klasteris", "Oficialus Oracle 23ai atvaizdas (Proxy) ir Gerald Venzl atvaizdas (ALISE) kartu.")
    },
    11: {
        "cat": "publisher", "ram": "4-6 GB", "conts": "db-publisher, db-alise, db-proxy, app-ords, app-publisher",
        "en": ("Analytics Publisher Dedicated Enterprise", "Pixel-Perfect enterprise PDF/Excel reporting with dedicated RCU DB, ALISE DB, Proxy DB, and ORDS."),
        "et": ("Analytics Publisher Eraldatud Ettevõte", "Pixel-Perfect ettevõtte PDF/Excel aruandlus eraldiseisva RCU baasi, ALISE baasi, Proxy baasi ja ORDS-iga."),
        "fi": ("Analytics Publisher Eristetty Yritys", "Pixel-Perfect raportointi erillisellä RCU DB:llä, ALISE DB:llä, Proxy DB:llä ja ORDS:lla."),
        "sv": ("Analytics Publisher Dedikerad Enterprise", "Pixel-Perfect företagsrapportering med dedikerad RCU DB, ALISE DB, Proxy DB och ORDS."),
        "lv": ("Analytics Publisher Atsevišķs Uzņēmums", "Pixel-Perfect atskaites ar atsevišķu RCU DB, ALISE DB, Proxy DB un ORDS."),
        "lt": ("Analytics Publisher Atskira Įmonė", "Pixel-Perfect ataskaitos su atskira RCU DB, ALISE DB, Proxy DB ir ORDS.")
    },
    13: {
        "cat": "publisher", "ram": "3-4 GB", "conts": "db-proxy, app-ords, app-publisher",
        "en": ("Analytics Publisher All-in-One DB", "All RCU schemas and business data consolidated inside one Free DB (db-proxy) with Publisher and ORDS."),
        "et": ("Analytics Publisher Kõik-Ühes DB", "Kõik RCU skeemid ja äriandmed ühes Free DB-s (db-proxy) koos Publisheri ja ORDS-iga."),
        "fi": ("Analytics Publisher Kaikki-Yhdessä DB", "Kaikki RCU-skeemat ja data yhdessä Free DB:ssä (db-proxy) Publisherin ja ORDS:n kera."),
        "sv": ("Analytics Publisher Allt-i-ett DB", "Alla RCU-scheman och affärsdata samlat i en Free DB (db-proxy) med Publisher och ORDS."),
        "lv": ("Analytics Publisher Viss-Vienā DB", "Visas RCU shēmas un biznesa dati vienā Free DB (db-proxy) ar Publisher un ORDS."),
        "lt": ("Analytics Publisher Viskas-Viename DB", "Visos RCU schemos ir verslo duomenys vienoje Free DB (db-proxy) su Publisher ir ORDS.")
    },
    21: {
        "cat": "forms", "ram": "4-6 GB", "conts": "db-forms, db-alise, db-proxy, app-forms, app-ords",
        "en": ("Forms 14c Full Enterprise Stack", "Dedicated Forms RCU DB + Custom DB + APEX Proxy DB + Forms 14c Services & HTML5 noVNC + ORDS."),
        "et": ("Forms 14c Täielik Ettevõtte Virn", "Eraldi Forms RCU DB + Kohandatud DB + APEX Proxy DB + Forms 14c teenused ja HTML5 noVNC + ORDS."),
        "fi": ("Forms 14c Täysi Yrityspino", "Erillinen Forms RCU DB + Custom DB + APEX Proxy DB + Forms 14c ja HTML5 noVNC + ORDS."),
        "sv": ("Forms 14c Fullständig Enterprise", "Dedikerad Forms RCU DB + Anpassad DB + APEX Proxy DB + Forms 14c & noVNC + ORDS."),
        "lv": ("Forms 14c Pilns Uzņēmuma Steks", "Atsevišķa Forms RCU DB + Pielāgota DB + APEX Proxy DB + Forms 14c un noVNC + ORDS."),
        "lt": ("Forms 14c Pilnas Įmonės Rinkinys", "Atskira Forms RCU DB + Pritaikyta DB + APEX Proxy DB + Forms 14c ir noVNC + ORDS.")
    },
    22: {
        "cat": "forms", "ram": "3-5 GB", "conts": "db-proxy, db-alise, app-forms, app-ords",
        "en": ("Forms 14c Minimal Hybrid Stack", "Combined Forms/Proxy DB + ALISE DB + ORDS + Forms Services (HTML5 noVNC Forms Builder on port 6082)."),
        "et": ("Forms 14c Minimaalne Hübriid", "Kombineeritud Forms/Proxy DB + ALISE DB + ORDS + Forms teenused (HTML5 noVNC pordil 6082)."),
        "fi": ("Forms 14c Minimaalinen Hybridi", "Yhdistetty Forms/Proxy DB + ALISE DB + ORDS + Forms (HTML5 noVNC portissa 6082)."),
        "sv": ("Forms 14c Minimal Hybrid", "Kombinerad Forms/Proxy DB + ALISE DB + ORDS + Forms (HTML5 noVNC på port 6082)."),
        "lv": ("Forms 14c Minimāls Hibrīds", "Kombinēta Forms/Proxy DB + ALISE DB + ORDS + Forms (HTML5 noVNC portā 6082)."),
        "lt": ("Forms 14c Minimalus Hibridinis", "Sujungta Forms/Proxy DB + ALISE DB + ORDS + Forms (HTML5 noVNC prievade 6082).")
    },
    31: {
        "cat": "webide", "ram": "3-4 GB", "conts": "db-proxy, app-ords, web-ide-dev",
        "en": ("Cloud Autonomous DB (ADB) + Web IDE", "Autonomous Database emulator with browser VS Code Web IDE, Oracle SQL Developer extension, and Antigravity AI."),
        "et": ("Pilve Autonomous DB (ADB) + Web IDE", "Autonomous Database emulaator koos brauseri VS Code Web IDE, SQL Developer laienduse ja Antigravity AI-ga."),
        "fi": ("Pilvi Autonomous DB (ADB) + Web IDE", "Autonomous Database -emulaattori selainpohjaisella VS Code Web IDE:llä ja Antigravity AI:lla."),
        "sv": ("Moln Autonomous DB (ADB) + Web IDE", "Autonomous Database-emulator med webbaserad VS Code Web IDE och Antigravity AI."),
        "lv": ("Mākoņa Autonomous DB (ADB) + Web IDE", "Autonomous Database emulators ar pārlūka VS Code Web IDE un Antigravity AI."),
        "lt": ("Debesų Autonomous DB (ADB) + Web IDE", "Autonomous Database emuliatorius su naršyklės VS Code Web IDE ir Antigravity AI.")
    },
    34: {
        "cat": "webide", "ram": "3-5 GB", "conts": "db-proxy, db-alise, app-ords, web-ide-dev",
        "en": ("🌟 2-Layer Production Stack + Web IDE", "Recommended 2-layer production stack with browser VS Code Web IDE, SQL Developer, SEPS Wallet sync, and AI coding tools."),
        "et": ("🌟 2-Kihiline Tootmisvirn + Web IDE", "Soovituslik 2-kihiline tootmislahendus koos brauseri VS Code Web IDE, SQL Developeri, SEPS Walleti ja AI tööriistadega."),
        "fi": ("🌟 2-Kerroksinen Tuotantopino + Web IDE", "Suositeltu 2-kerroksinen tuotantoratkaisu selainpohjaisella VS Code Web IDE:llä ja SEPS Wallet -synkronoinnilla."),
        "sv": ("🌟 2-Lagers Produktionsstack + Web IDE", "Rekommenderad 2-lagers produktionsstack med webbaserad VS Code Web IDE och SEPS Wallet."),
        "lv": ("🌟 2 Slāņu Ražošanas Steks + Web IDE", "Ieteicamais 2 slāņu ražošanas steks ar pārlūka VS Code Web IDE un SEPS Wallet."),
        "lt": ("🌟 2 Sluoksnių Gamybos Rinkinys + Web IDE", "Rekomenduojamas 2 sluoksnių gamybos rinkinys su naršyklės VS Code Web IDE ir SEPS Wallet.")
    },
    41: {
        "cat": "enterprise", "ram": "4-6 GB", "conts": "db-proxy, app-forms, app-publisher, app-ords, web-ide-dev",
        "en": ("🌟 Ultimate All-in-One Enterprise + Web IDE", "Forms 14c + Publisher + APEX SSO Reverse Proxy + ORDS + Web IDE consolidated on a single 23ai Free DB."),
        "et": ("🌟 Ultimate Kõik-Ühes Ettevõte + Web IDE", "Forms 14c + Publisher + APEX SSO Proxy + ORDS + Web IDE koondatud ühele 23ai Free DB-le."),
        "fi": ("🌟 Ultimate Kaikki-Yhdessä Yritys + Web IDE", "Forms 14c + Publisher + APEX SSO Proxy + ORDS + Web IDE yhdistettynä yhteen 23ai Free DB:hen."),
        "sv": ("🌟 Ultimate Allt-i-ett Enterprise + Web IDE", "Forms 14c + Publisher + APEX SSO Proxy + ORDS + Web IDE samlat i en enda 23ai Free DB."),
        "lv": ("🌟 Ultimate Viss-Vienā Uzņēmums + Web IDE", "Forms 14c + Publisher + APEX SSO Proxy + ORDS + Web IDE apvienots vienā 23ai Free DB."),
        "lt": ("🌟 Ultimate Viskas-Viename Įmonė + Web IDE", "Forms 14c + Publisher + APEX SSO Proxy + ORDS + Web IDE sujungta vienoje 23ai Free DB.")
    },
    42: {
        "cat": "enterprise", "ram": "6-8 GB", "conts": "db-forms, db-publisher, db-proxy, db-alise, app-forms, app-publisher, app-ords, web-ide-dev",
        "en": ("Fully Isolated Enterprise Cloud Lab", "8 isolated containers with dedicated databases for Forms, Publisher, APEX, and Custom applications + Web IDE."),
        "et": ("Täielikult Eraldatud Ettevõtte Pilvelabor", "8 eraldatud konteinerit koos eraldi andmebaasidega Forms, Publisher, APEX ja kohandatud rakenduste jaoks + Web IDE."),
        "fi": ("Täysin Eristetty Yrityspilvilaboratorio", "8 eristettyä konttia erillisillä tietokannoilla Formsille, Publisherille ja APEXille + Web IDE."),
        "sv": ("Fullständigt Isolerat Enterprise Molnlabb", "8 isolerade behållare med dedikerade databaser för Forms, Publisher och APEX + Web IDE."),
        "lv": ("Pilnībā Izolēta Uzņēmuma Mākoņlaboratorija", "8 izolēti konteineri ar atsevišķām datubāzēm Forms, Publisher un APEX + Web IDE."),
        "lt": ("Visiškai Izoliuota Įmonės Debesų Laboratorija", "8 izoliuoti konteineriai su atskiromis duomenų bazėmis Forms, Publisher ir APEX + Web IDE.")
    },
    43: {
        "cat": "enterprise", "ram": "5-7 GB", "conts": "db-proxy, db-publisher, app-forms, app-publisher, app-ords, web-ide-dev",
        "en": ("2-Database Hybrid Enterprise + Web IDE", "APEX/ORDS Proxy DB + Shared Middleware Infra DB (db-publisher) for Forms 14c and Publisher RCU schemas + Web IDE."),
        "et": ("2-Andmebaasi Hübriid Ettevõte + Web IDE", "APEX/ORDS Proxy DB + Ühine Middleware Infra DB (db-publisher) Forms 14c ja Publisher RCU skeemide jaoks + Web IDE."),
        "fi": ("2-Tietokannan Hybridi Yritys + Web IDE", "APEX/ORDS Proxy DB + Jaettu Middleware DB (db-publisher) Forms 14c ja Publisher RCU:lle + Web IDE."),
        "sv": ("2-Databas Hybrid Enterprise + Web IDE", "APEX/ORDS Proxy DB + Delad Middleware DB (db-publisher) för Forms och Publisher RCU + Web IDE."),
        "lv": ("2 Datubāzu Hibrīda Uzņēmums + Web IDE", "APEX/ORDS Proxy DB + Koplietota Middleware DB (db-publisher) Forms un Publisher RCU + Web IDE."),
        "lt": ("2 Duomenų Bazių Hibridinė Įmonė + Web IDE", "APEX/ORDS Proxy DB + Bendra Middleware DB (db-publisher) Forms ir Publisher RCU + Web IDE.")
    }
}

bp_files = sorted(glob.glob(os.path.join(WORKSPACE_DIR, "config/blueprints/.env.*")))
bp_list = []
for bp_file in bp_files:
    b_base = os.path.basename(bp_file)
    m = re.search(r"\.env\.(\d+)", b_base)
    if m:
        b_num = int(m.group(1))
        info = BP_CATALOG.get(b_num)
        if info:
            cat = info["cat"]
            ram = info["ram"]
            conts = info["conts"]
            titles = {lang: info.get(lang, info["en"])[0] for lang in ["en", "et", "fi", "sv", "lv", "lt"]}
            descs = {lang: info.get(lang, info["en"])[1] for lang in ["en", "et", "fi", "sv", "lv", "lt"]}
        else:
            cat = "core"
            ram = "3-4 GB"
            conts = "Active Containers"
            title_def = f"Blueprint #{b_num}"
            desc_def = f"Architecture blueprint configuration #{b_num}."
            titles = {l: title_def for l in ["en", "et", "fi", "sv", "lv", "lt"]}
            descs = {l: desc_def for l in ["en", "et", "fi", "sv", "lv", "lt"]}

        bp_list.append({
            "num": b_num,
            "file": b_base,
            "cat": cat,
            "ram": ram,
            "containers": conts,
            "titles": titles,
            "descs": descs
        })

# 1. Parse active blueprint and active environment
env_path = os.path.join(WORKSPACE_DIR, ".env")
env_vars = {}
active_bp_num = 1

if os.path.exists(env_path):
    with open(env_path, "r", encoding="utf-8") as f:
        for line in f:
            line_str = line.strip()
            if not line_str or line_str.startswith("#"):
                m = re.search(r'(?:STSENAARIUM|BLUEPRINT|Blueprint|Scenario)\s*(\d+)', line_str, re.IGNORECASE)
                if m and active_bp_num == 1:
                    active_bp_num = int(m.group(1))
                m2 = re.search(r'\.env\.(\d+)-', line_str)
                if m2:
                    active_bp_num = int(m2.group(1))
                continue
            if "=" in line_str:
                k, v = line_str.split("=", 1)
                env_vars[k.strip()] = v.strip().strip('"\'')

if "ACTIVE_BP_ID" in env_vars:
    try:
        active_bp_num = int(env_vars["ACTIVE_BP_ID"])
    except ValueError:
        pass

# Also match .env content against blueprint files in config/blueprints/
if os.path.exists(env_path):
    with open(env_path, "r", encoding="utf-8") as f:
        cur_env_txt = f.read()
    for bpf in sorted(glob.glob(os.path.join(WORKSPACE_DIR, "config/blueprints/.env.*"))):
        try:
            with open(bpf, "r", encoding="utf-8") as bf:
                b_txt = bf.read()
                bm = re.search(r'\.env\.(\d+)-', os.path.basename(bpf))
                if bm and (b_txt.strip() == cur_env_txt.strip() or f".env.{bm.group(1)}" in cur_env_txt):
                    active_bp_num = int(bm.group(1))
                    break
        except Exception:
            pass

# Helper to load a YAML profile
def load_yaml_profile(pname):
    pfile = os.path.join(WORKSPACE_DIR, f"config/profiles/databases/{pname}.yaml")
    if not os.path.exists(pfile):
        pfile = os.path.join(WORKSPACE_DIR, f"config/profiles/{pname}.yaml")
    if not os.path.exists(pfile):
        return {}
    try:
        import yaml
        with open(pfile, "r", encoding="utf-8") as f:
            return yaml.safe_load(f) or {}
    except Exception:
        # Fallback simple parser
        data = {"profile": {"id": pname}, "components": {}, "users": []}
        return data

# Collect active DBs
active_db_list = []
for db_k, def_c in [("DB_PROXY", "db-proxy"), ("DB_ALISE", "db-alise"), ("DB_PUBLISHER", "db-publisher"), ("DB_FORMS", "db-forms")]:
    pval = env_vars.get(db_k, "")
    if pval and pval.upper() != "NONE":
        p_data = load_yaml_profile(pval)
        c_short = def_c.replace("db-", "").replace("-", "_").upper()
        pool_name = def_c.replace("db-", "").replace("-", "_")
        ords_conf = p_data.get("components", {}).get("ords", {})
        apex_conf = p_data.get("components", {}).get("apex", {})
        if ords_conf.get("pool_name") and ords_conf.get("pool_name") != "default":
            pool_name = ords_conf.get("pool_name")
        elif ords_conf.get("url_mapping"):
            m_path = ords_conf.get("url_mapping").strip("/").split("/")[-1]
            if m_path:
                pool_name = m_path
        active_db_list.append({
            "key": db_k,
            "c_name": def_c,
            "short": c_short,
            "prof_name": pval,
            "profile": p_data,
            "pool_name": pool_name,
            "ords_enabled": str(ords_conf.get("enabled", "true")).lower() == "true",
            "apex_enabled": str(apex_conf.get("enabled", "false")).lower() == "true",
            "workspace": apex_conf.get("workspace", f"{c_short}_WORKSPACE" if c_short != "PROXY" else "DEV_WS"),
            "port": str(p_data.get("database", {}).get("db_port", "1521")),
            "users": p_data.get("users", [])
        })

# Flags
skip_ords = env_vars.get("SKIP_ORDS", "false").lower() == "true"
skip_pub = env_vars.get("SKIP_PUBLISHER", "true").lower() == "true"
skip_forms = env_vars.get("SKIP_FORMS", "true").lower() == "true"
skip_web_ide = env_vars.get("SKIP_WEB_IDE", "true").lower() == "true"
if active_bp_num in [30, 31, 32, 33, 34, 41, 42, 43]:
    skip_web_ide = False

# Build Dynamic Service Cards
# Helper to query ORDS version dynamically
def get_ords_version():
    try:
        cmd = ["podman", "exec", "-i", "-u", "oracle", "db-alise", "/opt/oracle/product/26ai/dbhomeFree/bin/sqlplus", "-s", "/", "as", "sysdba"]
        sql_input = "SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF\nALTER SESSION SET CONTAINER = FREEPDB1;\nSELECT version FROM ords_version;\nEXIT;\n"
        res = subprocess.run(cmd, input=sql_input, capture_output=True, text=True, timeout=3)
        if res.returncode == 0:
            lines = [l.strip() for l in res.stdout.splitlines() if l.strip() and not l.startswith("Session altered") and not "ERROR" in l]
            if lines:
                return lines[0]
    except Exception:
        pass
    return os.getenv("ORDS_VERSION", "26.2.0")

ords_version = get_ords_version()

cards = []
if not skip_ords:
    cards.append(f"""            <!-- ORDS REST & Landing Portal -->
            <div class=\"card\">
                <div class=\"card-top\">
                    <div class=\"card-header-flex\">
                        <h3>🌐 ORDS REST & Landing Portal</h3>
                        <span class=\"status-pill status-checking\" data-status-url=\"https://localhost:8448/ords/_/landing\">
                            <span class=\"status-dot\"></span>
                            <span class=\"status-text\" data-i18n=\"status_checking\">Checking...</span>
                        </span>
                    </div>
                    <p data-i18n=\"desc_ords\">Oracle REST Data Services gateway, OpenAPI metadata & pool health.</p>
                    <div class=\"card-meta\">Version: <code style=\"color:#38bdf8; font-weight:700;\">{ords_version}</code> | Port: 8448 (HTTPS) / 8088 (HTTP) | Context: <code>/ords/</code></div>
                </div>
                <div class=\"card-action-flex\">
                    <a href=\"https://localhost:8448/ords/_/landing\" target=\"_blank\" class=\"btn btn-secondary\" data-i18n=\"btn_ords\">Open ORDS Portal →</a>
                </div>
            </div>""")

# Helper to retrieve password via get-password.sh
def get_pwd(alias):
    try:
        script = os.path.join(WORKSPACE_DIR, "scripts/get-password.sh")
        res = subprocess.run([script, alias], capture_output=True, text=True, timeout=2)
        clean_out = re.sub(r'\x1b\[[0-9;]*m', '', res.stdout)
        m = re.search(r"Password:\s*(\S+)", clean_out)
        if m:
            return m.group(1).strip()
    except Exception:
        pass
    return ""

# Collect passwords map for localhost prefilling & 1-click copy
passwords_map = {}
for db_info in active_db_list:
    c_short = db_info["short"]
    for a in [f"DB_{c_short}_DEV", f"DB_{c_short}_APEX_ADMIN", f"DB_{c_short}_SYS", f"DB_{c_short}_DBA_ADMIN", f"DB_{c_short}_SCHEMA", f"DB_{c_short}_APP", f"DB_{c_short}_VIEWER"]:
        p = get_pwd(a)
        if p:
            passwords_map[a] = p
    for u in db_info.get("users", []):
        u_name = u.get("username", "")
        u_alias = u.get("wallet_alias", f"DB_{c_short}_{u_name.upper()}")
        p = get_pwd(u_alias)
        if p:
            passwords_map[u_alias] = p

for a in ["DB_PROXY_DEV", "DB_PROXY_APEX_ADMIN", "DB_PROXY_SYS", "DB_ALISE_DEV", "DB_ALISE_APEX_ADMIN", "DB_ALISE_SYS", "DB_PUBLISHER_SYS", "DB_FORMS_SYS"]:
    if a not in passwords_map:
        p = get_pwd(a)
        if p:
            passwords_map[a] = p

for db_info in active_db_list:
    c_short = db_info["short"]
    p_name = db_info["pool_name"]
    ws_name = db_info["workspace"]
    # APEX Workspace Builder
    if db_info["apex_enabled"] and not skip_ords:
        dev_wallet = f"DB_{c_short}_DEV"
        cards.append(f"""            <!-- APEX Workspace Builder ({c_short}) -->
            <div class=\"card\">
                <div class=\"card-top\">
                    <div class=\"card-header-flex\">
                        <h3>🛠️ APEX Workspace Builder ({c_short})</h3>
                        <span class=\"status-pill status-checking\" data-status-url=\"https://localhost:8448/ords/{p_name}/\">
                            <span class=\"status-dot\"></span>
                            <span class=\"status-text\" data-i18n=\"status_checking\">Checking...</span>
                        </span>
                    </div>
                    <p data-i18n=\"desc_apex_ws\">Developer low-code application workspace (APEX 26.1).</p>
                    <div class=\"card-meta\">Workspace: <code onclick=\"copyAndScrollToWallet('{dev_wallet}', this)\" style=\"cursor:pointer; color:#38bdf8;\" title=\"1-Click Copy Password CLI & Scroll\">{ws_name}</code> | User: <code onclick=\"copyAndScrollToWallet('{dev_wallet}', this)\" style=\"cursor:pointer; color:#38bdf8;\" title=\"1-Click Copy Password CLI & Scroll\">DEV</code> (Auto-Prefilled)</div>
                </div>
                <div class=\"card-action-flex\">
                    <a href=\"https://localhost:8448/ords/{p_name}/r/apex/workspace-sign-in/oracle-apex-sign-in?f4550_p1_company={ws_name}&f4550_p1_username=DEV\" onclick=\"openServiceWithCredentials(this.href, '{dev_wallet}', 'DEV', event)\" target=\"_blank\" class=\"btn\" data-i18n=\"btn_apex_ws\" data-i18n-title=\"tip_open_service\" title=\"Opens portal & copies password to clipboard (ready to Paste with Cmd+V / Ctrl+V)\">Open APEX Workspace →</a>
                    <button class=\"btn-pwd-copy\" onclick=\"handleCopyPassword('{dev_wallet}', this);\" data-i18n-title=\"tip_copy_pwd\" title=\"Copy password to clipboard\"><span>🔑</span> <span data-i18n=\"btn_copy_pwd\">Password</span></button>
                </div>
            </div>""")

        admin_wallet = f"DB_{c_short}_APEX_ADMIN"
        cards.append(f"""            <!-- APEX Instance Admin ({c_short}) -->
            <div class=\"card\">
                <div class=\"card-top\">
                    <div class=\"card-header-flex\">
                        <h3>⚙️ APEX Instance Admin ({c_short})</h3>
                        <span class=\"status-pill status-checking\" data-status-url=\"https://localhost:8448/ords/{p_name}/\">
                            <span class=\"status-dot\"></span>
                            <span class=\"status-text\" data-i18n=\"status_checking\">Checking...</span>
                        </span>
                    </div>
                    <p data-i18n=\"desc_apex_admin\">APEX platform & workspace management console (INTERNAL).</p>
                    <div class=\"card-meta\">Workspace: <code onclick=\"copyAndScrollToWallet('{admin_wallet}', this)\" style=\"cursor:pointer; color:#f59e0b;\" title=\"1-Click Copy Password CLI & Scroll\">INTERNAL</code> | User: <code onclick=\"copyAndScrollToWallet('{admin_wallet}', this)\" style=\"cursor:pointer; color:#f59e0b;\" title=\"1-Click Copy Password CLI & Scroll\">ADMIN</code></div>
                </div>
                <div class=\"card-action-flex\">
                    <a href=\"https://localhost:8448/ords/{p_name}/apex_admin\" onclick=\"openServiceWithCredentials(this.href, '{admin_wallet}', 'ADMIN', event)\" target=\"_blank\" class=\"btn btn-secondary\" data-i18n=\"btn_apex_admin\" data-i18n-title=\"tip_open_service\" title=\"Opens portal & copies password to clipboard (ready to Paste with Cmd+V / Ctrl+V)\">Open APEX Admin →</a>
                    <button class=\"btn-pwd-copy\" onclick=\"handleCopyPassword('{admin_wallet}', this);\" data-i18n-title=\"tip_copy_pwd\" title=\"Copy password to clipboard\"><span>🔑</span> <span data-i18n=\"btn_copy_pwd\">Password</span></button>
                </div>
            </div>""")

    # Database Actions (SDW)
    if db_info["ords_enabled"] and not skip_ords:
        dev_wallet = f"DB_{c_short}_DEV"
        cards.append(f"""            <!-- Database Actions (SDW) ({c_short}) -->
            <div class=\"card\">
                <div class=\"card-top\">
                    <div class=\"card-header-flex\">
                        <h3>📊 Database Actions ({c_short})</h3>
                        <span class=\"status-pill status-checking\" data-status-url=\"https://localhost:8448/ords/{p_name}/\">
                            <span class=\"status-dot\"></span>
                            <span class=\"status-text\" data-i18n=\"status_checking\">Checking...</span>
                        </span>
                    </div>
                    <p data-i18n=\"desc_sdw\">Web-based SQL Developer, REST API editor and schema management.</p>
                    <div class=\"card-meta\">Schema: <code onclick=\"copyAndScrollToWallet('{dev_wallet}', this)\" style=\"cursor:pointer; color:#c084fc;\" title=\"1-Click Copy Password CLI & Scroll\">user_developer</code> | User: <code onclick=\"copyAndScrollToWallet('{dev_wallet}', this)\" style=\"cursor:pointer; color:#c084fc;\" title=\"1-Click Copy Password CLI & Scroll\">USER_DEVELOPER</code></div>
                </div>
                <div class=\"card-action-flex\">
                    <a href=\"https://localhost:8448/ords/{p_name}/user_developer/sign-in?username=USER_DEVELOPER&r=_sdw\" onclick=\"openServiceWithCredentials(this.href, '{dev_wallet}', 'USER_DEVELOPER', event)\" target=\"_blank\" class=\"btn btn-purple\" data-i18n=\"btn_sdw\" data-i18n-title=\"tip_open_service\" title=\"Opens portal & copies password to clipboard (ready to Paste with Cmd+V / Ctrl+V)\">Open SQL Developer Web →</a>
                    <button class=\"btn-pwd-copy\" onclick=\"handleCopyPassword('{dev_wallet}', this);\" data-i18n-title=\"tip_copy_pwd\" title=\"Copy password to clipboard\"><span>🔑</span> <span data-i18n=\"btn_copy_pwd\">Password</span></button>
                </div>
            </div>""")

if not skip_pub:
    cards.append("""            <!-- Analytics Publisher -->
            <div class=\"card\">
                <div class=\"card-top\">
                    <div class=\"card-header-flex\">
                        <h3>📑 Analytics Publisher</h3>
                        <span class=\"status-pill status-checking\" data-status-url=\"http://localhost:9502/xmlpserver\">
                            <span class=\"status-dot\"></span>
                            <span class=\"status-text\" data-i18n=\"status_checking\">Checking...</span>
                        </span>
                    </div>
                    <p data-i18n=\"desc_pub\">Pixel-Perfect enterprise PDF/Excel reporting, catalog manager and data models.</p>
                    <div class=\"card-meta\">Domain: <code>BIP_DOMAIN</code> | User: <code onclick=\"copyAndScrollToWallet('DB_PUBLISHER_SYS', this)\" style=\"cursor:pointer; color:#fb923c;\" title=\"1-Click Copy Password CLI & Scroll\">weblogic</code> | Port: 9502</div>
                </div>
                <div class=\"card-action-flex\">
                    <a href=\"http://localhost:9502/xmlpserver\" onclick=\"openServiceWithCredentials(this.href, 'DB_PUBLISHER_SYS', 'weblogic', event)\" target=\"_blank\" class=\"btn btn-orange\" data-i18n=\"btn_pub\" data-i18n-title=\"tip_open_service\" title=\"Opens portal & copies password to clipboard (ready to Paste with Cmd+V / Ctrl+V)\">Open Analytics Publisher →</a>
                    <button class=\"btn-pwd-copy\" onclick=\"handleCopyPassword('DB_PUBLISHER_SYS', this);\" data-i18n-title=\"tip_copy_pwd\" title=\"Copy password to clipboard\"><span>🔑</span> <span data-i18n=\"btn_copy_pwd\">Password</span></button>
                </div>
            </div>""")

if not skip_forms:
    cards.append("""            <!-- Forms 14c Services -->
            <div class=\"card\">
                <div class=\"card-top\">
                    <div class=\"card-header-flex\">
                        <h3>📐 Forms 14c Services</h3>
                        <span class=\"status-pill status-checking\" data-status-url=\"http://localhost:9001/forms/frmservlet?form=test.fmx\">
                            <span class=\"status-dot\"></span>
                            <span class=\"status-text\" data-i18n=\"status_checking\">Checking...</span>
                        </span>
                    </div>
                    <p data-i18n=\"desc_forms\">Oracle Forms 14.1.2 WebLogic runtime servlet and active test form.</p>
                    <div class=\"card-meta\">Runtime: <code>/forms/frmservlet?form=test.fmx</code> | Admin: 7001</div>
                </div>
                <div class=\"card-action-flex\">
                    <a href=\"http://localhost:9001/forms/frmservlet?form=test.fmx\" target=\"_blank\" class=\"btn btn-green\" data-i18n=\"btn_forms\">Open Forms Test Form →</a>
                </div>
            </div>
            <!-- Forms Builder GUI (noVNC) -->
            <div class=\"card\">
                <div class=\"card-top\">
                    <div class=\"card-header-flex\">
                        <h3>🎨 Forms Builder Web GUI</h3>
                        <span class=\"status-pill status-checking\" data-status-url=\"http://localhost:6082/vnc.html\">
                            <span class=\"status-dot\"></span>
                            <span class=\"status-text\" data-i18n=\"status_checking\">Checking...</span>
                        </span>
                    </div>
                    <p data-i18n=\"desc_novnc\">HTML5 browser workspace for visual Oracle Forms & Reports 14c Builder.</p>
                    <div class=\"card-meta\">Port: 6082 | Client: HTML5 noVNC (Zero Install)</div>
                </div>
                <div class=\"card-action-flex\">
                    <a href=\"http://localhost:6082/vnc.html\" target=\"_blank\" class=\"btn btn-secondary\" data-i18n=\"btn_novnc\">Open Forms Builder GUI →</a>
                </div>
            </div>
            <!-- WebLogic Admin Console (Forms / WLS) -->
            <div class=\"card\">
                <div class=\"card-top\">
                    <div class=\"card-header-flex\">
                        <h3>⚙️ WebLogic Admin Console</h3>
                        <span class=\"status-pill status-checking\" data-status-url=\"http://localhost:7001/console\">
                            <span class=\"status-dot\"></span>
                            <span class=\"status-text\" data-i18n=\"status_checking\">Checking...</span>
                        </span>
                    </div>
                    <p data-i18n=\"desc_wls\">Forms / Publisher WebLogic domain, JDBC connection pools & monitoring.</p>
                    <div class=\"card-meta\">Port: 7001 (Forms / WLS) | User: <code onclick=\"copyAndScrollToWallet('DB_FORMS_SYS', this)\" style=\"cursor:pointer; color:#4ade80;\" title=\"1-Click Copy Password CLI & Scroll\">weblogic</code></div>
                </div>
                <div class=\"card-action-flex\">
                    <a href=\"http://localhost:7001/console\" onclick=\"openServiceWithCredentials(this.href, 'DB_FORMS_SYS', 'weblogic', event)\" target=\"_blank\" class=\"btn btn-secondary\" data-i18n=\"btn_wls\" data-i18n-title=\"tip_open_service\" title=\"Opens portal & copies password to clipboard (ready to Paste with Cmd+V / Ctrl+V)\">Open WebLogic Console →</a>
                    <button class=\"btn-pwd-copy\" onclick=\"handleCopyPassword('DB_FORMS_SYS', this);\" data-i18n-title=\"tip_copy_pwd\" title=\"Copy password to clipboard\"><span>🔑</span> <span data-i18n=\"btn_copy_pwd\">Password</span></button>
                </div>
            </div>""")

if not skip_web_ide:
    cards.append("""            <!-- VS Code Web IDE -->
            <div class=\"card\">
                <div class=\"card-top\">
                    <div class=\"card-header-flex\">
                        <h3>💻 VS Code Web IDE</h3>
                        <span class=\"status-pill status-checking\" data-status-url=\"http://localhost:8090\">
                            <span class=\"status-dot\"></span>
                            <span class=\"status-text\" data-i18n=\"status_checking\">Checking...</span>
                        </span>
                    </div>
                    <p data-i18n=\"desc_ide\">Zero-install browser IDE with Oracle SQL Developer & AI coding assistants.</p>
                    <div class=\"card-meta\">Port: 8090 | User: <code>developer</code> (Passwordless)</div>
                </div>
                <div class=\"card-action-flex\">
                    <a href=\"http://localhost:8090/?folder=/workspace\" target=\"_blank\" class=\"btn btn-purple\" data-i18n=\"btn_ide\">Open Web IDE →</a>
                </div>
            </div>""")

services_cards_html = "\n".join(cards)

# Helper for user role/account descriptions
def get_user_desc_key(u_name, u_role, u_alias):
    u_upper = u_name.upper()
    if u_role == "SYSDBA" or u_upper == "SYS":
        return "desc_u_sys"
    elif u_role == "DBA" or "DBA" in u_alias or "DBA" in u_upper:
        return "desc_u_dba"
    elif "DEV" in u_alias or u_upper in ["DEV", "USER_DEVELOPER"]:
        return "desc_u_dev"
    elif "APP" in u_alias or "APP" in u_upper:
        return "desc_u_app"
    elif "VIEWER" in u_alias or "VIEWER" in u_upper or u_role == "VIEWER":
        return "desc_u_viewer"
    return "desc_u_generic"

# Build Dynamic SEPS Wallet Table
table_rows = []
for db_info in active_db_list:
    c_name = db_info["c_name"]
    c_short = db_info["short"]
    db_port = db_info["port"]
    users = db_info["users"]
    
    if db_info["apex_enabled"]:
        admin_alias = f"DB_{c_short}_APEX_ADMIN"
        table_rows.append(f"""                    <tr id=\"row-{admin_alias}\">
                        <td><strong>⚙️ APEX Instance Admin</strong><br/><span style=\"font-size:0.75rem; color:#64748b;\">{c_name} (Port {db_port})</span></td>
                        <td>
                            <span style=\"background:rgba(245,158,11,0.18); color:#f59e0b; padding:3px 8px; border-radius:4px; font-weight:700; font-size:0.95rem; cursor:pointer; display:inline-block; margin-bottom:2px;\" onclick=\"copyUsername('ADMIN', this)\" data-i18n-title=\"tip_copy_user\" title=\"Click to copy username to clipboard\">ADMIN</span><br/>
                            <span style=\"font-size:0.75rem; color:#94a3b8;\" data-i18n=\"desc_u_apex_admin\">APEX Platform Administrator</span>
                        </td>
                        <td><span style=\"background:rgba(56,189,248,0.15); color:#38bdf8; padding:3px 8px; border-radius:4px; font-weight:600; font-size:0.85rem; cursor:pointer;\" onclick=\"copyUsername('INTERNAL', this)\" data-i18n-title=\"tip_copy_ws\" title=\"Click to copy workspace name to clipboard\">INTERNAL</span> <span style=\"font-size:0.75rem; color:#94a3b8;\">(Workspace)</span></td>
                        <td><code style=\"color:#22c55e; cursor:pointer;\" onclick=\"copyBadge(this, '{admin_alias}')\" title=\"Click to copy alias\">{admin_alias}</code></td>
                        <td>
                            <button class=\"copy-btn\" style=\"position:static;\" onclick=\"handleCopyPassword('{admin_alias}', this)\" data-i18n-title=\"tip_copy_pwd\" title=\"Copy password to clipboard\">📋 <span data-i18n=\"btn_copy_pwd\">Password</span></button>
                        </td>
                    </tr>""")

    for u in users:
        u_name = u.get("username", "")
        u_role = u.get("role", "NORMAL")
        u_alias = u.get("wallet_alias", f"DB_{c_short}_{u_name}")
        u_color = u.get("color", "#38bdf8")
        desc_k = get_user_desc_key(u_name, u_role, u_alias)
        
        svc_desc = f"🗄️ {c_name} User"
        if u_role == "SYSDBA": svc_desc = f"🔴 Database SYSDBA ({c_name})"
        elif u_role == "DBA": svc_desc = f"🔵 Database Administrator ({c_name})"
        elif "DEV" in u_alias or u_name.upper() in ["DEV", "USER_DEVELOPER"]:
            svc_desc = f"🛠️ Developer & SDW ({c_name})"

        scope_badge = f"""<span style=\"background:rgba(148,163,184,0.15); color:#cbd5e1; padding:3px 8px; border-radius:4px; font-weight:600; font-size:0.85rem;\">{u_role}</span>"""
        if "DEV" in u_alias or u_name.upper() in ["DEV", "USER_DEVELOPER"]:
            ws_name = db_info.get("workspace", f"{c_short}_WORKSPACE")
            scope_badge = f"""<span style=\"background:rgba(56,189,248,0.15); color:#38bdf8; padding:3px 8px; border-radius:4px; font-weight:600; font-size:0.85rem; cursor:pointer;\" onclick=\"copyUsername('{ws_name}', this)\" data-i18n-title=\"tip_copy_ws\" title=\"Click to copy workspace name to clipboard\">{ws_name}</span> <span style=\"font-size:0.75rem; color:#94a3b8;\">({u_role})</span>"""
        
        table_rows.append(f"""                    <tr id=\"row-{u_alias}\">
                        <td><strong>{svc_desc}</strong><br/><span style=\"font-size:0.75rem; color:#64748b;\">{c_name} (Port {db_port})</span></td>
                        <td>
                            <span style=\"background:rgba(56,189,248,0.18); color:{u_color}; padding:3px 8px; border-radius:4px; font-weight:700; font-size:0.95rem; cursor:pointer; display:inline-block; margin-bottom:2px;\" onclick=\"copyUsername('{u_name}', this)\" data-i18n-title=\"tip_copy_user\" title=\"Click to copy username to clipboard\">{u_name}</span><br/>
                            <span style=\"font-size:0.75rem; color:#94a3b8;\" data-i18n=\"{desc_k}\">User Account</span>
                        </td>
                        <td>{scope_badge}</td>
                        <td><code style=\"color:#22c55e; cursor:pointer;\" onclick=\"copyBadge(this, '{u_alias}')\" title=\"Click to copy alias\">{u_alias}</code></td>
                        <td>
                            <button class=\"copy-btn\" style=\"position:static;\" onclick=\"handleCopyPassword('{u_alias}', this)\" data-i18n-title=\"tip_copy_pwd\" title=\"Copy password to clipboard\">📋 <span data-i18n=\"btn_copy_pwd\">Password</span></button>
                        </td>
                    </tr>""")

wallet_table_rows_html = "\n".join(table_rows)
passwords_map_json = json.dumps(passwords_map)

# Write HTML Template
html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Oracle DevOps Platform — Command Center</title>
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
    <script>
      mermaid.initialize({{ startOnLoad: false, theme: 'dark', securityLevel: 'loose' }});
    </script>
    <style>
        :root {{
            --bg: #090d16;
            --surface: #111827;
            --surface-hover: #1f2937;
            --surface-active: #283548;
            --border: #374151;
            --border-highlight: #4b5563;
            --primary: #38bdf8;
            --primary-hover: #0284c7;
            --primary-glow: rgba(56, 189, 248, 0.25);
            --text-main: #f3f4f6;
            --text-muted: #9ca3af;
            --text-dim: #64748b;
            --success: #22c55e;
            --success-bg: rgba(34, 197, 94, 0.15);
            --warning: #f59e0b;
            --warning-bg: rgba(245, 158, 11, 0.15);
            --danger: #ef4444;
            --code-bg: #030712;
            --radius-lg: 14px;
            --radius-md: 10px;
            --radius-sm: 6px;
        }}
        * {{ box-sizing: border-box; margin: 0; padding: 0; }}
        body {{
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            background: var(--bg);
            color: var(--text-main);
            line-height: 1.5;
            padding: 20px 16px 40px;
        }}
        .container {{ max-width: 1320px; margin: 0 auto; }}
        
        .header {{
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 20px 28px;
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 16px;
            box-shadow: 0 4px 24px rgba(0,0,0,0.35);
        }}
        .header-brand h1 {{
            font-size: 1.35rem;
            color: var(--primary);
            display: flex;
            align-items: center;
            gap: 10px;
        }}
        .header-brand p {{
            font-size: 0.85rem;
            color: var(--text-muted);
            margin-top: 4px;
        }}
        .badge-active {{
            background: var(--primary-glow);
            color: var(--primary);
            border: 1px solid var(--primary);
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }}
        .lang-switcher {{
            display: flex;
            gap: 6px;
            background: #0b1120;
            padding: 4px;
            border-radius: var(--radius-md);
            border: 1px solid var(--border);
        }}
        .lang-btn {{
            background: transparent;
            border: none;
            color: var(--text-muted);
            padding: 6px 12px;
            border-radius: var(--radius-sm);
            cursor: pointer;
            font-size: 0.85rem;
            font-weight: 500;
            transition: all 0.2s ease;
        }}
        .lang-btn:hover {{ color: var(--text-main); background: var(--surface-hover); }}
        .lang-btn.active {{
            background: var(--primary);
            color: #030712;
            font-weight: 700;
        }}

        .persona-bar {{
            display: flex;
            gap: 8px;
            margin-bottom: 16px;
            overflow-x: auto;
            padding-bottom: 4px;
        }}
        .persona-btn {{
            background: var(--surface);
            border: 1px solid var(--border);
            color: var(--text-muted);
            padding: 8px 16px;
            border-radius: var(--radius-md);
            cursor: pointer;
            font-size: 0.85rem;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s ease;
            white-space: nowrap;
        }}
        .persona-btn:hover {{
            background: var(--surface-hover);
            color: var(--text-main);
            border-color: var(--border-highlight);
        }}
        .persona-btn.active {{
            background: var(--surface-active);
            color: var(--primary);
            border-color: var(--primary);
            box-shadow: 0 0 12px var(--primary-glow);
        }}

        .tabs-nav {{
            display: flex;
            gap: 4px;
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 6px;
            margin-bottom: 24px;
            overflow-x: auto;
        }}
        .tab-btn {{
            flex: 1;
            min-width: 140px;
            background: transparent;
            border: none;
            color: var(--text-muted);
            padding: 10px 16px;
            border-radius: var(--radius-md);
            cursor: pointer;
            font-size: 0.88rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            transition: all 0.2s ease;
            white-space: nowrap;
        }}
        .tab-btn:hover {{ color: var(--text-main); background: var(--surface-hover); }}
        .tab-btn.active {{
            background: var(--primary);
            color: #030712;
            box-shadow: 0 2px 8px rgba(56, 189, 248, 0.4);
        }}

        .tab-content {{ display: none; }}
        .tab-content.active {{ display: block; animation: fadeIn 0.25s ease; }}
        @keyframes fadeIn {{ from {{ opacity: 0; transform: translateY(4px); }} to {{ opacity: 1; transform: translateY(0); }} }}

        .grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 20px;
            margin-bottom: 24px;
        }}
        .section-title {{
            font-size: 1.15rem;
            font-weight: 700;
            color: #f1f5f9;
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }}

        .card {{
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 20px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            transition: transform 0.2s ease, border-color 0.2s ease, box-shadow 0.2s ease;
        }}
        .card:hover {{
            transform: translateY(-2px);
            border-color: var(--primary);
            box-shadow: 0 6px 20px rgba(0,0,0,0.3);
        }}
        .card-top {{ margin-bottom: 16px; }}
        .card-header-flex {{
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 8px;
            margin-bottom: 8px;
        }}
        .card h3 {{
            font-size: 1.05rem;
            font-weight: 700;
            color: #f8fafc;
        }}
        .card p {{
            font-size: 0.85rem;
            color: var(--text-muted);
            line-height: 1.4;
            margin-bottom: 12px;
        }}
        .card-meta {{
            font-size: 0.78rem;
            color: var(--text-dim);
            font-family: ui-monospace, monospace;
            background: #0b1120;
            padding: 6px 10px;
            border-radius: var(--radius-sm);
            border: 1px solid rgba(255,255,255,0.05);
            margin-bottom: 10px;
        }}
        .card-spikker {{
            font-size: 0.75rem;
            color: #38bdf8;
            background: rgba(56, 189, 248, 0.08);
            border: 1px dashed rgba(56, 189, 248, 0.3);
            padding: 6px 10px;
            border-radius: var(--radius-sm);
            font-family: ui-monospace, monospace;
        }}

        .status-pill {{
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 3px 8px;
            border-radius: 12px;
            font-size: 0.72rem;
            font-weight: 600;
            letter-spacing: 0.02em;
        }}
        .status-online {{ background: var(--success-bg); color: var(--success); border: 1px solid var(--success); }}
        .status-checking {{ background: rgba(148, 163, 184, 0.15); color: #94a3b8; border: 1px solid #64748b; }}
        .status-init {{ background: var(--warning-bg); color: var(--warning); border: 1px solid var(--warning); }}
        .status-dot {{ width: 6px; height: 6px; border-radius: 50%; background: currentColor; }}

        .btn {{
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            background: var(--primary);
            color: #030712;
            font-weight: 600;
            font-size: 0.85rem;
            padding: 10px 16px;
            border-radius: var(--radius-md);
            text-decoration: none;
            border: none;
            cursor: pointer;
            transition: all 0.2s ease;
            width: 100%;
        }}
        .btn:hover {{ background: var(--primary-hover); color: #fff; }}
        .btn-secondary {{ background: var(--surface-hover); color: var(--text-main); border: 1px solid var(--border); }}
        .btn-secondary:hover {{ background: var(--surface-active); border-color: var(--primary); }}
        .btn-green {{ background: #22c55e; color: #022c22; }}
        .btn-green:hover {{ background: #16a34a; color: #fff; }}
        .btn-orange {{ background: #f97316; color: #431407; }}
        .btn-orange:hover {{ background: #ea580c; color: #fff; }}
        .btn-purple {{ background: #a855f7; color: #3b0764; }}
        .btn-purple:hover {{ background: #9333ea; color: #fff; }}
        .card-action-flex {{
            display: flex;
            gap: 8px;
            align-items: stretch;
            margin-top: 12px;
        }}
        .card-action-flex .btn {{
            flex: 1;
            margin-top: 0;
        }}
        .btn-pwd-copy {{
            background: #0b1120;
            border: 1px solid rgba(56, 189, 248, 0.4);
            color: #38bdf8;
            padding: 8px 12px;
            border-radius: var(--radius-md);
            font-size: 0.8rem;
            font-weight: 600;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            white-space: nowrap;
            transition: all 0.2s ease;
        }}
        .btn-pwd-copy:hover {{
            background: rgba(56, 189, 248, 0.2);
            border-color: #38bdf8;
            color: #fff;
            box-shadow: 0 0 10px rgba(56, 189, 248, 0.3);
        }}

        .table-responsive {{
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            overflow-x: auto;
            margin-bottom: 24px;
        }}
        table {{ width: 100%; border-collapse: collapse; text-align: left; font-size: 0.85rem; }}
        th {{
            background: #0b1120;
            padding: 12px 16px;
            border-bottom: 1px solid var(--border);
            color: var(--text-muted);
            font-weight: 600;
        }}
        td {{
            padding: 12px 16px;
            border-bottom: 1px solid var(--border);
        }}
        tr:last-child td {{ border-bottom: none; }}
        tr:hover td {{ background: var(--surface-hover); }}
        code {{
            font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
            background: var(--code-bg);
            padding: 2px 6px;
            border-radius: 4px;
            color: var(--primary);
            font-size: 0.8rem;
        }}

        .code-box {{
            background: var(--code-bg);
            border: 1px solid var(--border);
            border-radius: var(--radius-md);
            padding: 14px 16px;
            position: relative;
            margin-bottom: 16px;
            font-family: ui-monospace, monospace;
            font-size: 0.85rem;
            color: #38bdf8;
            overflow-x: auto;
        }}
        .copy-btn {{
            position: absolute;
            top: 8px;
            right: 8px;
            background: var(--surface-hover);
            border: 1px solid var(--border);
            color: var(--text-muted);
            padding: 4px 8px;
            border-radius: var(--radius-sm);
            cursor: pointer;
            font-size: 0.75rem;
        }}
        .copy-btn:hover {{ color: var(--text-main); background: var(--surface-active); }}

        .diag-card {{
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 24px;
            margin-bottom: 20px;
        }}
        .diag-card h3 {{
            color: var(--primary);
            font-size: 1.1rem;
            margin-bottom: 16px;
        }}
        .mermaid {{
            background: #030712;
            padding: 16px;
            border-radius: var(--radius-md);
            border: 1px solid var(--border);
            overflow-x: auto;
            min-height: 120px;
        }}

        .docs-container {{
            display: grid;
            grid-template-columns: 300px 1fr;
            gap: 20px;
            min-height: 600px;
        }}
        .docs-sidebar {{
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 16px;
            display: flex;
            flex-direction: column;
            gap: 6px;
            max-height: 800px;
            overflow-y: auto;
        }}
        .docs-nav-item {{
            background: transparent;
            border: none;
            text-align: left;
            padding: 10px 14px;
            border-radius: var(--radius-md);
            color: var(--text-muted);
            font-size: 0.85rem;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.15s ease;
        }}
        .docs-nav-item:hover {{ background: var(--surface-hover); color: var(--text-main); }}
        .docs-nav-item.active {{
            background: var(--surface-active);
            color: var(--primary);
            border-left: 3px solid var(--primary);
            font-weight: 600;
        }}
        .docs-content {{
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 32px;
            max-height: 800px;
            overflow-y: auto;
            color: #e2e8f0;
            line-height: 1.7;
        }}
        .docs-content h1 {{ color: var(--primary); margin-bottom: 16px; font-size: 1.6rem; border-bottom: 1px solid var(--border); padding-bottom: 8px; }}
        .docs-content h2 {{ color: #f8fafc; margin-top: 24px; margin-bottom: 12px; font-size: 1.25rem; }}
        .docs-content h3 {{ color: #93c5fd; margin-top: 18px; margin-bottom: 8px; font-size: 1.05rem; }}
        .docs-content p {{ margin-bottom: 14px; color: #cbd5e1; }}
        .docs-content ul, .docs-content ol {{ margin-left: 24px; margin-bottom: 16px; color: #cbd5e1; }}
        .docs-content li {{ margin-bottom: 6px; }}
        .docs-content pre {{ background: #030712; padding: 14px; border-radius: 8px; border: 1px solid var(--border); overflow-x: auto; margin-bottom: 16px; }}
        .docs-content table {{ margin-bottom: 20px; border: 1px solid var(--border); border-radius: 6px; }}
        .docs-content table th {{ background: #0f172a; padding: 8px 12px; }}
        .docs-content table td {{ padding: 8px 12px; }}

        .bp-filters {{
            display: flex;
            gap: 8px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }}
        .bp-filter-btn {{
            background: var(--surface);
            border: 1px solid var(--border);
            color: var(--text-muted);
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 0.8rem;
            cursor: pointer;
            font-weight: 500;
        }}
        .bp-filter-btn:hover {{ background: var(--surface-hover); color: var(--text-main); }}
        .bp-filter-btn.active {{ background: var(--primary); color: #030712; font-weight: 700; border-color: var(--primary); }}
        
        .bp-card {{
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 18px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }}
        .bp-card.active-bp {{
            border-color: var(--primary);
            box-shadow: 0 0 16px var(--primary-glow);
        }}
        .bp-meta-tags {{
            display: flex;
            gap: 6px;
            flex-wrap: wrap;
            margin-top: 8px;
        }}
        .bp-tag {{
            font-size: 0.7rem;
            background: #0b1120;
            color: #94a3b8;
            padding: 3px 8px;
            border-radius: 4px;
            font-family: ui-monospace, monospace;
        }}
    </style>
</head>
<body>
<div class="container">

    <!-- Header -->
    <header class="header">
        <div class="header-brand">
            <div style="display: flex; align-items: center; gap: 10px; flex-wrap: wrap;">
                <h1>🚀 Oracle DevOps Platform <span class="badge-active">Active: Blueprint #{active_bp_num}</span></h1>
                <span style="background: linear-gradient(135deg, rgba(56, 189, 248, 0.15), rgba(168, 85, 247, 0.15)); border: 1px solid rgba(168, 85, 247, 0.35); color: #c084fc; padding: 3px 10px; border-radius: 12px; font-size: 0.72rem; font-weight: 600; display: inline-flex; align-items: center; gap: 5px;">✨ Antigravity × Gemini 3.7 Flash</span>
            </div>
            <p data-i18n="header_subtitle">Unified Command Center, Real-Time Service Health & Multilingual Architecture Portal</p>
        </div>
        <div class="lang-switcher">
            <button class="lang-btn active" id="btn-en" onclick="setLanguage('en')">🇬🇧 EN</button>
            <button class="lang-btn" id="btn-et" onclick="setLanguage('et')">🇪🇪 ET</button>
            <button class="lang-btn" id="btn-fi" onclick="setLanguage('fi')">🇫🇮 FI</button>
            <button class="lang-btn" id="btn-sv" onclick="setLanguage('sv')">🇸🇪 SV</button>
            <button class="lang-btn" id="btn-lv" onclick="setLanguage('lv')">🇱🇻 LV</button>
            <button class="lang-btn" id="btn-lt" onclick="setLanguage('lt')">🇱🇹 LT</button>
        </div>
    </header>

    <!-- Persona Selector -->
    <div class="persona-bar">
        <button class="persona-btn active" onclick="switchPersona('developer')">👩‍💻 <span data-i18n="persona_dev">Developer Hub</span></button>
        <button class="persona-btn" onclick="switchPersona('security')">🛡️ <span data-i18n="persona_sec">Security & Architect</span></button>
        <button class="persona-btn" onclick="switchPersona('devops')">⚙️ <span data-i18n="persona_ops">DevOps & Admin</span></button>
        <button class="persona-btn" onclick="switchPersona('publisher')">📊 <span data-i18n="persona_pub">Reports & Pixel-Perfect</span></button>
    </div>

    <!-- Navigation Tabs -->
    <nav class="tabs-nav">
        <button class="tab-btn active" onclick="switchTab('tab-services')">🌐 <span data-i18n="tab_services">Services & Status</span></button>
        <button class="tab-btn" onclick="switchTab('tab-architecture')">📐 <span data-i18n="tab_architecture">Architecture & Topology</span></button>
        <button class="tab-btn" onclick="switchTab('tab-blueprints')">📋 <span data-i18n="tab_blueprints">Blueprints Explorer (22+)</span></button>
        <button class="tab-btn" onclick="switchTab('tab-docs')">📚 <span data-i18n="tab_docs">Documentation</span></button>
        <button class="tab-btn" onclick="switchTab('tab-devops')">⚡ <span data-i18n="tab_devops">DevOps Commands</span></button>
        <button class="tab-btn" onclick="switchTab('tab-benchmarks')">📝 <span data-i18n="tab_benchmarks">Logs & Benchmarks</span></button>
    </nav>

    <!-- TAB 1: SERVICES & STATUS -->
    <div id="tab-services" class="tab-content active">
        <div class="section-title">
            <span data-i18n="title_endpoints">🌐 Live Services & Access Portals</span>
            <span style="font-size: 0.8rem; color: #64748b;" data-i18n="auto_refresh_hint">Auto-refreshes every 6 seconds</span>
        </div>
        <div class="grid">
{services_cards_html}
        </div>

        <!-- SEPS Wallet Connections Matrix (Collapsible Accordion) -->
        <div class="wallet-accordion-container" style="margin-top: 32px; background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius-lg); overflow: hidden;">
            <div class="wallet-accordion-header" onclick="toggleWalletMatrix()" style="padding: 16px 20px; cursor: pointer; display: flex; align-items: center; justify-content: space-between; user-select: none; transition: background 0.2s ease;">
                <div style="display: flex; align-items: center; gap: 12px;">
                    <span style="font-size: 1.1rem; font-weight: 700; color: #f8fafc;" data-i18n="title_wallet">🔑 Database SEPS Wallet Credentials & Fast Clipboard Matrix</span>
                </div>
                <div style="display: flex; align-items: center; gap: 8px;">
                    <span class="wallet-toggle-badge" style="font-size: 0.8rem; font-weight: 600; color: #38bdf8; background: rgba(56, 189, 248, 0.12); border: 1px solid rgba(56, 189, 248, 0.25); padding: 4px 12px; border-radius: 20px; display: inline-flex; align-items: center; gap: 6px;">
                        <span id="wallet-toggle-label" data-i18n="toggle_show_matrix">Kuva maatriks</span>
                        <span id="wallet-toggle-icon" style="font-weight: 700; font-size: 0.95rem; transition: transform 0.3s ease;">➕</span>
                    </span>
                </div>
            </div>
            <div id="wallet-matrix-drawer" style="max-height: 0; overflow: hidden; transition: max-height 0.4s cubic-bezier(0.4, 0, 0.2, 1), opacity 0.3s ease; opacity: 0;">
                <div class="table-responsive" style="padding: 0 16px 16px 16px;">
                    <table>
                        <thead>
                            <tr>
                                <th data-i18n="th_db">Service / Database</th>
                                <th data-i18n="th_user">User / Account</th>
                                <th data-i18n="th_scope">Workspace / Role</th>
                                <th data-i18n="th_alias">SEPS Wallet TNS Alias (Click to Copy)</th>
                                <th data-i18n="th_pwd">1-Click Password</th>
                            </tr>
                        </thead>
                        <tbody>
{wallet_table_rows_html}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- TAB 2: ARCHITECTURE & TOPOLOGY -->
    <div id="tab-architecture" class="tab-content">
        <div class="section-title">
            <span data-i18n="title_architecture_sec">📐 Multi-DB Hybrid Architecture & Enterprise Topology</span>
        </div>

        <div class="diag-card">
            <h3 data-i18n="diag_title_1">🏗️ Active Multi-DB & Container Topology</h3>
            <div class="mermaid" id="mermaid-diag-1"></div>
        </div>

        <div class="diag-card">
            <h3 data-i18n="diag_title_2">🔐 Zero-Trust Ingress, TLS & SEPS Wallet Architecture</h3>
            <div class="mermaid" id="mermaid-diag-2"></div>
        </div>

        <div class="diag-card">
            <h3 data-i18n="diag_title_3">🔄 Oracle Forms 14c Modernization Workflow</h3>
            <div class="mermaid" id="mermaid-diag-3"></div>
        </div>
    </div>

    <!-- TAB 3: BLUEPRINTS EXPLORER -->
    <div id="tab-blueprints" class="tab-content">
        <div class="section-title">
            <span data-i18n="title_blueprints">📋 Architecture Blueprints Catalog (22+ Stacks)</span>
        </div>
        
        <div class="bp-filters">
            <button class="bp-filter-btn active" onclick="filterBlueprints('all')" data-i18n="filter_all">🌟 All (23)</button>
            <button class="bp-filter-btn" onclick="filterBlueprints('core')" data-i18n="filter_core">🗄️ Core APEX & DB (1–9)</button>
            <button class="bp-filter-btn" onclick="filterBlueprints('publisher')" data-i18n="filter_pub">📑 Analytics Publisher (10–19)</button>
            <button class="bp-filter-btn" onclick="filterBlueprints('forms')" data-i18n="filter_forms">📐 Oracle Forms 14c (20–29)</button>
            <button class="bp-filter-btn" onclick="filterBlueprints('webide')" data-i18n="filter_webide">💻 Web IDE & CI/CD (30–39)</button>
            <button class="bp-filter-btn" onclick="filterBlueprints('enterprise')" data-i18n="filter_ent">🚀 Enterprise All-in-One (40–49)</button>
        </div>

        <div class="grid" id="blueprints-grid"></div>
    </div>

    <!-- TAB 4: DOCUMENTATION BROWSER -->
    <div id="tab-docs" class="tab-content">
        <div class="docs-layout">
            <nav class="docs-sidebar" id="docs-sidebar-nav"></nav>
            <main class="docs-content" id="docs-markdown-view">
                <p style="color: var(--text-dim);" data-i18n="docs_empty_hint">Select a document from the left navigation menu to view its full formatted guide.</p>
            </main>
        </div>
    </div>

    <!-- TAB 5: DEVOPS & CLI COMMANDS -->
    <div id="tab-devops" class="tab-content">
        <div class="section-title">
            <span data-i18n="title_cheatsheet">⚡ Developer & DevOps Quick Commands</span>
        </div>
        <div class="grid">
            <div class="card">
                <h4 style="color: var(--primary); margin-bottom: 8px;" data-i18n="title_devops_deploy">🚀 Blueprint Deployment & Switching</h4>
                <p data-i18n="desc_devops_deploy">Inspect active environment, test configurations, or switch cleanly between curated blueprints.</p>
                <div class="code-box">
                    <button class="copy-btn" onclick="copySnippet(this)">Copy</button>
                    ./scripts/deploy-blueprint.sh --status<br/>
                    ./scripts/deploy-blueprint.sh -b 3<br/>
                    ./scripts/deploy-blueprint.sh -b 41
                </div>
            </div>
            <div class="card">
                <h4 style="color: var(--primary); margin-bottom: 8px;" data-i18n="title_devops_wallet">🔐 Oracle Wallet Credential Matrix</h4>
                <p data-i18n="desc_devops_wallet">Query or inspect decrypted credentials from SEPS Wallet safely without plaintext leaks.</p>
                <div class="code-box">
                    <button class="copy-btn" onclick="copySnippet(this)">Copy</button>
                    ./scripts/get-password.sh --list<br/>
                    ./scripts/get-password.sh DB_ALISE_SYS -c
                </div>
            </div>
            <div class="card">
                <h4 style="color: var(--primary); margin-bottom: 8px;" data-i18n="title_devops_rotate">🔄 Zero-Downtime Password Rotation</h4>
                <p data-i18n="desc_devops_rotate">Rotate passwords across Database, Podman Secrets, and SEPS Wallet seamlessly.</p>
                <div class="code-box">
                    <button class="copy-btn" onclick="copySnippet(this)">Copy</button>
                    ./scripts/internal/rotate-password.sh db-alise sys<br/>
                    ./scripts/internal/rotate-password.sh db-alise USER_DEVELOPER
                </div>
            </div>
            <div class="card">
                <h4 style="color: var(--primary); margin-bottom: 8px;" data-i18n="title_devops_snapshot">⚡ Instant Snapshot Recovery</h4>
                <p data-i18n="desc_devops_snapshot">Create or restore compressed golden snapshots in ~15 seconds.</p>
                <div class="code-box">
                    <button class="copy-btn" onclick="copySnippet(this)">Copy</button>
                    ./scripts/snapshots/create-golden-snapshots.sh<br/>
                    ./scripts/snapshots/restore-golden-snapshots.sh
                </div>
            </div>
            <div class="card">
                <h4 style="color: var(--primary); margin-bottom: 8px;" data-i18n="title_devops_health">🌐 Service Health Diagnostics</h4>
                <p data-i18n="desc_devops_health">Test active web service HTTP/HTTPS endpoints and SEPS Wallet connections.</p>
                <div class="code-box">
                    <button class="copy-btn" onclick="copySnippet(this)">Copy</button>
                    ./scripts/check-urls.sh<br/>
                    ./scripts/check-wallet.sh
                </div>
            </div>
        </div>
    </div>

    <!-- TAB 6: LOGS & BENCHMARKS -->
    <div id="tab-benchmarks" class="tab-content">
        <div class="section-title">
            <span data-i18n="tab_benchmarks">📝 Performance Metrics & Step Benchmarks</span>
        </div>
        <div id="benchmarks-table-container"></div>
    </div>

    <!-- AI Attribution & Platform Footer -->
    <footer class="hub-footer" style="margin-top: 50px; padding: 24px 0 16px 0; border-top: 1px solid var(--border); display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; gap: 16px; font-size: 0.8rem; color: var(--text-dim);">
        <div style="display: flex; align-items: center; gap: 10px;">
            <span style="background: linear-gradient(135deg, rgba(56, 189, 248, 0.2), rgba(168, 85, 247, 0.2)); border: 1px solid rgba(168, 85, 247, 0.35); color: #c084fc; padding: 4px 10px; border-radius: 20px; font-weight: 600; font-size: 0.78rem; display: inline-flex; align-items: center; gap: 5px;">
                <span>✨</span> <span>AI-Assisted Architecture</span>
            </span>
            <span data-i18n="footer_ai_attribution">Crafted with Antigravity & Google Gemini 3.7 Flash</span>
        </div>
        <div style="display: flex; align-items: center; gap: 8px;">
            <span>© 2026 Oracle DevOps Platform</span>
            <span>•</span>
            <span>Zero-Trust Enterprise Architecture</span>
        </div>
    </footer>

</div>

<script>
const ACTIVE_BP_NUM = {active_bp_num};
const DOCS_DATA = {json.dumps(docs_data, ensure_ascii=False)};
const BLUEPRINTS_DATA = {json.dumps(bp_list, ensure_ascii=False)};

let currentSelectedDocIdx = 0;
let currentActiveFilter = 'all';
let serviceStates = {{}};

const MERMAID_DIAGRAMS = {{
  en: [
`graph TD
    Client["Developer / Web Browser"] -->|HTTP 8088 / HTTPS 8448| ORDS["app-ords (Jetty & ORDS Engine)"]
    Client -->|HTTP 9502| Pub["app-publisher (Analytics Publisher 2025)"]
    Client -->|HTTP 9001 / 7001| Forms["app-forms (Forms 14.1.2 & WebLogic)"]
    Client -->|HTTP 8090| WebIDE["web-ide-dev (VS Code Web IDE)"]

    subgraph DatabaseLayer ["Oracle 23ai Database Tier (SEPS Wallet Secured)"]
        DBProxy[("db-proxy : 1532<br/>APEX Proxy, OIDC & Kafka")]
        DBCustom[("db-alise : 1533<br/>ALISE Schema Engine & Logic")]
        DBPub[("db-publisher : 1535<br/>Publisher RCU Metadata")]
        DBForms[("db-forms : 1536<br/>Forms 14c RCU Metadata")]
    end

    ORDS -->|TCPS / SQLNet| DBProxy
    ORDS -->|TCPS / SQLNet| DBCustom
    Pub -->|JDBC Thin| DBPub
    Forms -->|JDBC Thin| DBForms`,

`sequenceDiagram
    autonumber
    actor Dev as Developer / CLI
    participant W as SEPS Wallet (~/config/tns_admin)
    participant SQLcl as Oracle SQLcl CLI
    participant DB as Oracle 23ai Database

    Dev->>SQLcl: sql /@DB_PROXY_DEV
    SQLcl->>W: Lookup credentials & TLS cert for alias
    W-->>SQLcl: Return auto-login decrypted token
    SQLcl->>DB: Secure TLS Handshake (No plaintext password in ps aux)
    DB-->>SQLcl: Authentication Successful (Session Opened)`,

`flowchart LR
    FMB["Legacy Forms .FMB"] -->|1. compile-form.sh| FMX["Compiled Runtime .FMX"]
    FMB -->|2. convert-to-xml.sh| XML["Git-Trackable Forms .XML"]
    XML -->|3. export-apex-zip.sh| ZIP["APEX Migration Workshop ZIP"]
    ZIP -->|4. Import into APEX 26.1| APEXApp["Modern Cloud APEX Application"]`
  ],

  et: [
`graph TD
    Client["Arendaja / Veebibrauser"] -->|HTTP 8088 / HTTPS 8448| ORDS["app-ords (Jetty & ORDS Mootor)"]
    Client -->|HTTP 9502| Pub["app-publisher (Analytics Publisher 2025)"]
    Client -->|HTTP 9001 / 7001| Forms["app-forms (Forms 14.1.2 & WebLogic)"]
    Client -->|HTTP 8090| WebIDE["web-ide-dev (VS Code Web IDE)"]

    subgraph DatabaseLayer ["Oracle 23ai Andmebaasikiht (SEPS Walletiga Kaitstud)"]
        DBProxy[("db-proxy : 1532<br/>APEX Proxy, OIDC & Kafka")]
        DBCustom[("db-alise : 1533<br/>ALISE Skeemimootor ja Loogika")]
        DBPub[("db-publisher : 1535<br/>Publisher RCU Metaandmed")]
        DBForms[("db-forms : 1536<br/>Forms 14c RCU Metaandmed")]
    end

    ORDS -->|TCPS / SQLNet| DBProxy
    ORDS -->|TCPS / SQLNet| DBCustom
    Pub -->|JDBC Thin| DBPub
    Forms -->|JDBC Thin| DBForms`,

`sequenceDiagram
    autonumber
    actor Dev as Arendaja / Käsirida
    participant W as SEPS Wallet (~/config/tns_admin)
    participant SQLcl as Oracle SQLcl CLI
    participant DB as Oracle 23ai Andmebaas

    Dev->>SQLcl: sql /@DB_PROXY_DEV
    SQLcl->>W: Päri aliasele vastav sertifikaat ja parool
    W-->>SQLcl: Väljasta dekrüpteeritud token
    SQLcl->>DB: Turvaline TLS kätlemine (Zero plaintext parool ps aux-is)
    DB-->>SQLcl: Autentimine õnnestus (Sessioon avatud)`,

`flowchart LR
    FMB["Pärand Forms .FMB"] -->|1. compile-form.sh| FMX["Kompileeritud Runtime .FMX"]
    FMB -->|2. convert-to-xml.sh| XML["Git-Jälgitav Forms .XML"]
    XML -->|3. export-apex-zip.sh| ZIP["APEX Migratsiooni ZIP"]
    ZIP -->|4. Impordi APEX 26.1-e| APEXApp["Moodne Pilve APEX Rakendus"]`
  ],

  fi: [
`graph TD
    Client["Kehittäjä / Verkkoselain"] -->|HTTP 8088 / HTTPS 8448| ORDS["app-ords (Jetty & ORDS-moottori)"]
    Client -->|HTTP 9502| Pub["app-publisher (Analytics Publisher 2025)"]
    Client -->|HTTP 9001 / 7001| Forms["app-forms (Forms 14.1.2 & WebLogic)"]
    Client -->|HTTP 8090| WebIDE["web-ide-dev (VS Code Web IDE)"]

    subgraph DatabaseLayer ["Oracle 23ai -tietokantakerros (SEPS Wallet -suojattu)"]
        DBProxy[("db-proxy : 1532<br/>APEX Proxy, OIDC & Kafka")]
        DBCustom[("db-alise : 1533<br/>ALISE-skeemamoottori ja logiikka")]
        DBPub[("db-publisher : 1535<br/>Publisher RCU -metatiedot")]
        DBForms[("db-forms : 1536<br/>Forms 14c RCU -metatiedot")]
    end

    ORDS -->|TCPS / SQLNet| DBProxy
    ORDS -->|TCPS / SQLNet| DBCustom
    Pub -->|JDBC Thin| DBPub
    Forms -->|JDBC Thin| DBForms`,

`sequenceDiagram
    autonumber
    actor Dev as Kehittäjä / CLI
    participant W as SEPS Wallet (~/config/tns_admin)
    participant SQLcl as Oracle SQLcl CLI
    participant DB as Oracle 23ai -tietokanta

    Dev->>SQLcl: sql /@DB_PROXY_DEV
    SQLcl->>W: Hae tunnistetiedot & TLS-sertifikaatti
    W-->>SQLcl: Palauta automaattikirjautumisen salattu token
    SQLcl->>DB: Suojattu TLS-kättely (Ei selväkielistä salasanaa ps aux -listauksessa)
    DB-->>SQLcl: Autentikointi onnistui (Istunto avattu)`,

`flowchart LR
    FMB["Perinteinen Forms .FMB"] -->|1. compile-form.sh| FMX["Käännetty ajonaikainen .FMX"]
    FMB -->|2. convert-to-xml.sh| XML["Git-seurattava Forms .XML"]
    XML -->|3. export-apex-zip.sh| ZIP["APEX Migration Workshop ZIP"]
    ZIP -->|4. Tuonti APEX 26.1 -ympäristöön| APEXApp["Moderni pilvi-APEX-sovellus"]`
  ],

  sv: [
`graph TD
    Client["Utvecklare / Webbläsare"] -->|HTTP 8088 / HTTPS 8448| ORDS["app-ords (Jetty & ORDS Motor)"]
    Client -->|HTTP 9502| Pub["app-publisher (Analytics Publisher 2025)"]
    Client -->|HTTP 9001 / 7001| Forms["app-forms (Forms 14.1.2 & WebLogic)"]
    Client -->|HTTP 8090| WebIDE["web-ide-dev (VS Code Web IDE)"]

    subgraph DatabaseLayer ["Oracle 23ai Databasskikt (SEPS Wallet Säkrat)"]
        DBProxy[("db-proxy : 1532<br/>APEX Proxy, OIDC & Kafka")]
        DBCustom[("db-alise : 1533<br/>ALISE Schemamotor och Logik")]
        DBPub[("db-publisher : 1535<br/>Publisher RCU Metadata")]
        DBForms[("db-forms : 1536<br/>Forms 14c RCU Metadata")]
    end

    ORDS -->|TCPS / SQLNet| DBProxy
    ORDS -->|TCPS / SQLNet| DBCustom
    Pub -->|JDBC Thin| DBPub
    Forms -->|JDBC Thin| DBForms`,

`sequenceDiagram
    autonumber
    actor Dev as Utvecklare / CLI
    participant W as SEPS Wallet (~/config/tns_admin)
    participant SQLcl as Oracle SQLcl CLI
    participant DB as Oracle 23ai Databas

    Dev->>SQLcl: sql /@DB_PROXY_DEV
    SQLcl->>W: Hämta autentisering och certifikat
    W-->>SQLcl: Returnera dekrypterat token
    SQLcl->>DB: Säker TLS-anslutning (Inget lösenord i ps aux)
    DB-->>SQLcl: Autentisering lyckades (Session öppnad)`,

`flowchart LR
    FMB["Legacy Forms .FMB"] -->|1. compile-form.sh| FMX["Kompilerad Runtime .FMX"]
    FMB -->|2. convert-to-xml.sh| XML["Git-Spårbar Forms .XML"]
    XML -->|3. export-apex-zip.sh| ZIP["APEX Migrerings-ZIP"]
    ZIP -->|4. Importera till APEX 26.1| APEXApp["Modern APEX Applikation"]`
  ],

  lv: [
`graph TD
    Client["Izstrādātājs / Pārlūks"] -->|HTTP 8088 / HTTPS 8448| ORDS["app-ords (Jetty & ORDS Dzinējs)"]
    Client -->|HTTP 9502| Pub["app-publisher (Analytics Publisher 2025)"]
    Client -->|HTTP 9001 / 7001| Forms["app-forms (Forms 14.1.2 & WebLogic)"]
    Client -->|HTTP 8090| WebIDE["web-ide-dev (VS Code Web IDE)"]

    subgraph DatabaseLayer ["Oracle 23ai Datubāzes Slānis (SEPS Wallet Drošs)"]
        DBProxy[("db-proxy : 1532<br/>APEX Proxy, OIDC & Kafka")]
        DBCustom[("db-alise : 1533<br/>ALISE Shēmas Dzinējs")]
        DBPub[("db-publisher : 1535<br/>Publisher RCU Metadati")]
        DBForms[("db-forms : 1536<br/>Forms 14c RCU Metadati")]
    end

    ORDS -->|TCPS / SQLNet| DBProxy
    ORDS -->|TCPS / SQLNet| DBCustom
    Pub -->|JDBC Thin| DBPub
    Forms -->|JDBC Thin| DBForms`,

`sequenceDiagram
    autonumber
    actor Dev as Izstrādātājs / CLI
    participant W as SEPS Wallet (~/config/tns_admin)
    participant SQLcl as Oracle SQLcl CLI
    participant DB as Oracle 23ai Datubāze

    Dev->>SQLcl: sql /@DB_PROXY_DEV
    SQLcl->>W: Iegūt piekļuves datus un sertifikātu
    W-->>SQLcl: Atgriezt atšifrētu marķieri
    SQLcl->>DB: Droša TLS savienojuma izveide
    DB-->>SQLcl: Autentifikācija veiksmīga (Sesija atvērta)`,

`flowchart LR
    FMB["Forms .FMB"] -->|1. compile-form.sh| FMX["Izpildāmais .FMX"]
    FMB -->|2. convert-to-xml.sh| XML["Git Sekojams .XML"]
    XML -->|3. export-apex-zip.sh| ZIP["APEX Migrācijas ZIP"]
    ZIP -->|4. Importēt APEX 26.1| APEXApp["Mūsdienīga APEX Lietotne"]`
  ],

  lt: [
`graph TD
    Client["Kūrėjas / Naršyklė"] -->|HTTP 8088 / HTTPS 8448| ORDS["app-ords (Jetty & ORDS Variklis)"]
    Client -->|HTTP 9502| Pub["app-publisher (Analytics Publisher 2025)"]
    Client -->|HTTP 9001 / 7001| Forms["app-forms (Forms 14.1.2 & WebLogic)"]
    Client -->|HTTP 8090| WebIDE["web-ide-dev (VS Code Web IDE)"]

    subgraph DatabaseLayer ["Oracle 23ai Duomenų Bazių Sluoksnis (SEPS Wallet Apsaugotas)"]
        DBProxy[("db-proxy : 1532<br/>APEX Proxy, OIDC & Kafka")]
        DBCustom[("db-alise : 1533<br/>ALISE Schemų Variklis")]
        DBPub[("db-publisher : 1535<br/>Publisher RCU Metaduomenys")]
        DBForms[("db-forms : 1536<br/>Forms 14c RCU Metaduomenys")]
    end

    ORDS -->|TCPS / SQLNet| DBProxy
    ORDS -->|TCPS / SQLNet| DBCustom
    Pub -->|JDBC Thin| DBPub
    Forms -->|JDBC Thin| DBForms`,

`sequenceDiagram
    autonumber
    actor Dev as Kūrėjas / CLI
    participant W as SEPS Wallet (~/config/tns_admin)
    participant SQLcl as Oracle SQLcl CLI
    participant DB as Oracle 23ai Duomenų Bazė

    Dev->>SQLcl: sql /@DB_PROXY_DEV
    SQLcl->>W: Gauti prisijungimo duomenis ir sertifikatą
    W-->>SQLcl: Grąžinti iššifruotą prieigos raktą
    SQLcl->>DB: Saugus TLS sujungimas
    DB-->>SQLcl: Autentifikacija sėkminga (Sesija atidaryta)`,

`flowchart LR
    FMB["Forms .FMB"] -->|1. compile-form.sh| FMX["Vykdomasis .FMX"]
    FMB -->|2. convert-to-xml.sh| XML["Git Sekamas .XML"]
    XML -->|3. export-apex-zip.sh| ZIP["APEX Migracijos ZIP"]
    ZIP -->|4. Importuoti į APEX 26.1| APEXApp["Šiuolaikinė APEX Programa"]`
  ]
}};

const I18N_DICT = {{
  en: {{
    header_subtitle: "Unified Command Center, Real-Time Service Health & Multilingual Architecture Portal",
    tab_services: "Services & Status",
    tab_architecture: "Architecture & Topology",
    tab_blueprints: "Blueprints Explorer (11 Models)",
    tab_docs: "Documentation",
    tab_devops: "DevOps Commands",
    tab_benchmarks: "Logs & Benchmarks",
    persona_dev: "Developer Hub",
    persona_sec: "Security & Architect",
    persona_ops: "DevOps & Admin",
    persona_pub: "Reports & Pixel-Perfect",
    title_endpoints: "🌐 Live Services & Access Portals",
    auto_refresh_hint: "Auto-refreshes every 6 seconds",
    status_checking: "Checking...",
    status_online: "Online",
    status_init: "Initializing...",
    desc_apex_ws: "Developer low-code application workspace (APEX 26.1).",
    btn_apex_ws: "Open APEX Workspace →",
    desc_apex_admin: "APEX platform & workspace management console (INTERNAL).",
    btn_apex_admin: "Open APEX Admin →",
    desc_sdw: "Web-based SQL Developer, REST API editor and schema management.",
    btn_sdw: "Open SQL Developer Web →",
    desc_ords: "Oracle REST Data Services gateway, OpenAPI metadata & pool health.",
    btn_ords: "Open ORDS Portal →",
    desc_pub: "Pixel-Perfect enterprise PDF/Excel reporting, catalog manager and data models.",
    btn_pub: "Open Analytics Publisher →",
    desc_forms: "Oracle Forms 14.1.2 WebLogic runtime servlet and active test form.",
    btn_forms: "Open Forms Test Form →",
    desc_novnc: "HTML5 browser workspace for visual Oracle Forms & Reports 14c Builder.",
    btn_novnc: "Open Forms Builder GUI →",
    desc_ide: "Zero-install browser IDE with Oracle SQL Developer & AI coding assistants.",
    btn_ide: "Open Web IDE →",
    desc_wls: "Forms / Publisher WebLogic domain, JDBC connection pools & monitoring.",
    btn_wls: "Open WebLogic Console →",
    btn_copy_pwd: "Password",
    tip_copy_pwd: "Copy password to clipboard",
    tip_open_service: "Opens portal & copies password to clipboard (ready to Paste with Cmd+V / Ctrl+V)",
    tip_copy_user: "Click to copy username to clipboard",
    tip_copy_ws: "Click to copy workspace name to clipboard",
    copied_cli: "Copied!",
    copied_pwd: "Password Copied!",
    copied_user: "Username Copied!",
    footer_ai_attribution: "Crafted in collaboration with Antigravity & Google Gemini 3.7 Flash",
    toggle_show_matrix: "Show Matrix",
    toggle_hide_matrix: "Hide Matrix",
    title_wallet: "🔑 Database SEPS Wallet Credentials & Fast Clipboard Matrix",
    th_db: "Service / Database",
    th_user: "User / Account",
    th_scope: "Workspace / Role",
    th_alias: "SEPS Wallet TNS Alias (Click to Copy)",
    th_pwd: "1-Click Password",
    desc_u_apex_admin: "APEX Platform Administrator",
    desc_u_sys: "Root Database Superuser (SYSDBA)",
    desc_u_dba: "Database Administrator & Schema Manager",
    desc_u_dev: "Developer Workspace & SQL Developer Web",
    desc_u_app: "Application Schema & REST Backend Owner",
    desc_u_viewer: "Read-only Reporting & Audit Viewer",
    desc_u_generic: "Database Application Account",
    title_architecture_sec: "📐 Multi-DB Hybrid Architecture & Enterprise Topology",
    diag_title_1: "🏗️ Active Multi-DB & Container Topology",
    diag_title_2: "🔐 Zero-Trust Ingress, TLS & SEPS Wallet Architecture",
    diag_title_3: "🔄 Oracle Forms 14c Modernization Workflow",
    title_blueprints: "📋 Architecture Blueprints Catalog (11 Models)",
    filter_all: "🌟 All (11)",
    filter_core: "🗄️ Core APEX & DB (1–9)",
    filter_pub: "📑 Analytics Publisher (10–19)",
    filter_forms: "📐 Oracle Forms 14c (20–29)",
    filter_webide: "💻 Web IDE & CI/CD (30–39)",
    filter_ent: "🚀 Enterprise All-in-One (40–49)",
    docs_empty_hint: "Select a document from the left navigation menu to view its full formatted guide.",
    title_cheatsheet: "⚡ Developer & DevOps Quick Commands",
    title_devops_deploy: "🚀 Blueprint Deployment & Switching",
    desc_devops_deploy: "Inspect active environment, test configurations, or switch cleanly between curated blueprints.",
    title_devops_wallet: "🔐 Oracle Wallet Credential Matrix",
    desc_devops_wallet: "Query or inspect decrypted credentials from SEPS Wallet safely without plaintext leaks.",
    title_devops_rotate: "🔄 Zero-Downtime Password Rotation",
    desc_devops_rotate: "Rotate passwords across Database, Podman Secrets, and SEPS Wallet seamlessly.",
    title_devops_snapshot: "⚡ Instant Snapshot Recovery",
    desc_devops_snapshot: "Create or restore compressed golden snapshots in ~15 seconds.",
    title_devops_health: "🌐 Service Health Diagnostics",
    desc_devops_health: "Test active web service HTTP/HTTPS endpoints and SEPS Wallet connections.",
    btn_copy_cmd: "📋 Copy Deploy Command",
    bench_th_step: "Setup Step / Subsystem",
    bench_th_duration: "Duration",
    bench_th_status: "Status",
    bench_completed: "✔ Completed",
    bench_step1: "Step 1: Container Images Pull/Check",
    bench_step2: "Step 2: ORDS Software Download",
    bench_step3: "Step 3: APEX Software Packages",
    bench_step4: "Step 4: Database Container Startup",
    bench_step5: "Step 5: Database Health Check Wait",
    bench_step6: "Step 6: APEX Engine Install & Patching",
    bench_step7: "Step 7: DB Objects & Schema Init",
    bench_step8: "Step 8: APEX Apps Deployment",
    bench_step9: "Step 9: Analytics Publisher",
    bench_step10: "Step 10: Golden Snapshots Creation",
    bench_total: "TOTAL SETUP TIME",
    bench_empty: "Benchmarks file metrics/setup_benchmarks.json will be generated after setup-all.sh execution."
  }},
  et: {{
    header_subtitle: "Ühendatud juhtpaneel, reaalajas teenuste monitooring ja mitmekeelne arhitektuuriportaal",
    tab_services: "Teenused ja Staatus",
    tab_architecture: "Arhitektuur ja Topoloogia",
    tab_blueprints: "Kavandite Kataloog (11 Mudelit)",
    tab_docs: "Dokumentatsioon",
    tab_devops: "DevOps Käsud",
    tab_benchmarks: "Logid ja Mõõdikud",
    persona_dev: "Arendaja Vaade",
    persona_sec: "Turvajuht ja Arhitekt",
    persona_ops: "DevOps ja Haldaja",
    persona_pub: "Trükised ja Aruandlus",
    title_endpoints: "🌐 Aktiivsed Teenused ja Veebiliidesed",
    auto_refresh_hint: "Automaatne uuendus iga 6 sekundi järel",
    status_checking: "Kontrollin...",
    status_online: "Töökorras",
    status_init: "Käivitumisel...",
    desc_apex_ws: "Arendaja madala koodiga rakenduste tööruum (APEX 26.1).",
    btn_apex_ws: "Ava APEX Tööruum →",
    desc_apex_admin: "APEX instantsi ja tööruumide keskne haldus (INTERNAL).",
    btn_apex_admin: "Ava APEX Admin →",
    desc_sdw: "Veebipõhine SQL Developer, REST liidesed ja andmebaasi haldus.",
    btn_sdw: "Ava SQL Developer Web →",
    desc_ords: "Oracle REST Data Services lüüs, OpenAPI metaandmed ja basseinid.",
    btn_ords: "Ava ORDS Portaal →",
    desc_pub: "Pixel-Perfect enterprise PDF/Excel aruandlus, kataloog ja andmemudelid.",
    btn_pub: "Ava Analytics Publisher →",
    desc_forms: "Oracle Forms 14.1.2 WebLogic jooksutuskeskkond ja testvorm.",
    btn_forms: "Ava Forms Testvorm →",
    desc_novnc: "HTML5 brauseri töökoht Oracle Forms 14c visuaalseks arenduseks.",
    btn_novnc: "Ava Forms Builder GUI →",
    desc_ide: "Brauseripõhine VS Code töökoht koos SQL Developer ja tehisintellektiga.",
    btn_ide: "Ava Web IDE →",
    desc_wls: "Forms / Publisher WebLogic domeen, JDBC basseinid ja monitooring.",
    btn_wls: "Ava WebLogic Konsool →",
    btn_copy_pwd: "Parool",
    tip_copy_pwd: "Kopeeri parool lõikelauale",
    tip_open_service: "Avab lehe ja kopeerib parooli lõikelauale (kleebi parooliväljale: Cmd+V / Ctrl+V)",
    tip_copy_user: "Kliki kasutajanime kopeerimiseks lõikelauale",
    tip_copy_ws: "Kliki tööruumi nime kopeerimiseks lõikelauale",
    copied_cli: "Kopeeritud!",
    copied_pwd: "Parool kopeeritud!",
    copied_user: "Kasutajanimi kopeeritud!",
    footer_ai_attribution: "Koostatud Antigravity ja Google Gemini 3.7 Flash koostöös",
    toggle_show_matrix: "Kuva maatriks",
    toggle_hide_matrix: "Peida maatriks",
    title_wallet: "🔑 Andmebaasi SEPS Wallet Paroolid ja Kiirkäskude Maatriks",
    th_db: "Teenus / Andmebaas",
    th_user: "Kasutajakonto",
    th_scope: "Tööruum / Roll",
    th_alias: "SEPS Wallet TNS Alias (Kliki Kopeerimiseks)",
    th_pwd: "1-Kliki Parool",
    desc_u_apex_admin: "APEX platvormi administraator",
    desc_u_sys: "Andmebaasi superkasutaja (SYSDBA)",
    desc_u_dba: "Andmebaasi administraator ja skeemihaldur",
    desc_u_dev: "Arendaja tööruum ja SQL Developer Web",
    desc_u_app: "Rakenduse skeem ja REST teenuste omanik",
    desc_u_viewer: "Ainult-lugemisõigusega vaatleja konto",
    desc_u_generic: "Andmebaasi rakenduse kasutaja",
    title_architecture_sec: "📐 Mitme Andmebaasiga Hübriidarhitektuur ja Topoloogia",
    diag_title_1: "🏗️ Aktiivne Mitme DB ja Konteinerite Topoloogia",
    diag_title_2: "🔐 Zero-Trust Ingress, TLS ja SEPS Wallet Arhitektuur",
    diag_title_3: "🔄 Oracle Forms 14c Moderniseerimise Töövoog",
    title_blueprints: "📋 Arhitektuursete Kavandite Kataloog (11 Mudelit)",
    filter_all: "🌟 Kõik (11)",
    filter_core: "🗄️ Core APEX & DB (1–9)",
    filter_pub: "📑 Analytics Publisher (10–19)",
    filter_forms: "📐 Oracle Forms 14c (20–29)",
    filter_webide: "💻 Web IDE & CI/CD (30–39)",
    filter_ent: "🚀 Enterprise Kõik-Ühes (40–49)",
    docs_empty_hint: "Vali vasakpoolsest menüüst dokument, et lugeda täielikku juhendit.",
    title_cheatsheet: "⚡ Arendaja ja DevOps Kiirkäsud",
    title_devops_deploy: "🚀 Blueprintide Juurutamine ja Vahetamine",
    desc_devops_deploy: "Kontrolli aktiivset keskkonda, testi seadistust või vaheta mugavalt kureeritud blueprinte.",
    title_devops_wallet: "🔐 Oracle Wallet Paroolide Maatriks",
    desc_devops_wallet: "Päri või kontrolli dekrüpteeritud paroole SEPS Walletist turvaliselt ilma leketeta.",
    title_devops_rotate: "🔄 Paroolide Katkestusteta Roteerimine",
    desc_devops_rotate: "Roteeri paroole andmebaasis, Podman Secretites ja SEPS Walletis üheaegselt.",
    title_devops_snapshot: "⚡ Hetktõmmistest Taastamine",
    desc_devops_snapshot: "Loo või taasta kokkupakitud kuldseid hetktõmmiseid ~15 sekundiga.",
    title_devops_health: "🌐 Veebiteenuste Diagnostika",
    desc_devops_health: "Kontrolli aktiivseid HTTP/HTTPS veebiteenuseid ja SEPS Walleti ühendusi.",
    btn_copy_cmd: "📋 Kopeeri Juurutamiskäsk",
    bench_th_step: "Paigalduse Samm / Alamsüsteem",
    bench_th_duration: "Kestus",
    bench_th_status: "Staatus",
    bench_completed: "✔ Teostatud",
    bench_step1: "Samm 1: Konteineripiltide tõmbamine/kontroll",
    bench_step2: "Samm 2: ORDS tarkvara allalaadimine",
    bench_step3: "Samm 3: APEX tarkvarapaketid",
    bench_step4: "Samm 4: Andmebaasi konteineri käivitamine",
    bench_step5: "Samm 5: Andmebaasi valmisoleku ootamine",
    bench_step6: "Samm 6: APEX mootori paigaldus ja uuendused",
    bench_step7: "Samm 7: DB objektide ja skeemide initsialiseerimine",
    bench_step8: "Samm 8: APEX rakenduste paigaldus",
    bench_step9: "Samm 9: Analytics Publisher",
    bench_step10: "Samm 10: Kuldsete hetktõmmiste loomine",
    bench_total: "KOGU PAIGALDUSE AEG",
    bench_empty: "Mõõdikute fail metrics/setup_benchmarks.json luuakse pärast setup-all.sh käivitamist."
  }},
  fi: {{
    header_subtitle: "Yhdistetty ohjauspaneeli, reaaliaikainen palveluseuranta ja monikielinen arkkitehtuuriportaali",
    tab_services: "Palvelut ja Tila",
    tab_architecture: "Arkkitehtuuri ja Topologia",
    tab_blueprints: "Blueprint-Luettelo (11 Mallia)",
    tab_docs: "Dokumentaatio",
    tab_devops: "DevOps-Komennot",
    tab_benchmarks: "Lokit ja Suorituskyky",
    persona_dev: "Kehittäjänäkymä",
    persona_sec: "Tietoturva & Arkkitehti",
    persona_ops: "DevOps & Ylläpito",
    persona_pub: "Raportit & Pixel-Perfect",
    title_endpoints: "🌐 Aktiiviset Palvelut ja Pääsyportaalit",
    auto_refresh_hint: "Päivittyy automaattisesti 6 sekunnin välein",
    status_checking: "Tarkistetaan...",
    status_online: "Käytettävissä",
    status_init: "Käynnistyy...",
    desc_apex_ws: "Kehittäjän low-code -sovellustyötila (APEX 26.1).",
    btn_apex_ws: "Avaa APEX-Työtila →",
    desc_apex_admin: "APEX-alustan ja työtilojen keskitetty hallinta (INTERNAL).",
    btn_apex_admin: "Avaa APEX Admin →",
    desc_sdw: "Verkkopohjainen SQL Developer, REST API ja tietokannan hallinta.",
    btn_sdw: "Avaa SQL Developer Web →",
    desc_ords: "Oracle REST Data Services -yhdyskäytävä ja OpenAPI-metatiedot.",
    btn_ords: "Avaa ORDS-Portaali →",
    desc_pub: "Pixel-Perfect yritysraportointi PDF/Excel-viennillä ja tietomalleilla.",
    btn_pub: "Avaa Analytics Publisher →",
    desc_forms: "Oracle Forms 14.1.2 WebLogic -ajonaikainen palvelu ja testilomake.",
    btn_forms: "Avaa Forms-Testilomake →",
    desc_novnc: "HTML5-selaintyötila visuaaliseen Forms 14c Builder -kehitykseen.",
    btn_novnc: "Avaa Forms Builder GUI →",
    desc_ide: "Asennusvapaa selain-IDE Oracle SQL Developerilla ja tekoälyllä.",
    btn_ide: "Avaa Web IDE →",
    desc_wls: "Forms / Publisher WebLogic -toimialue, JDBC-altaat ja valvonta.",
    btn_wls: "Avaa WebLogic-Konsoli →",
    btn_copy_pwd: "Salasana",
    tip_copy_pwd: "Kopioi salasana leikepöydälle",
    tip_open_service: "Avaa sivun ja kopioi salasanan leikepöydälle (liitä: Cmd+V / Ctrl+V)",
    tip_copy_user: "Klikkaa kopioidaksesi käyttäjänimen leikepöydälle",
    tip_copy_ws: "Klikkaa kopioidaksesi työtilan nimen leikepöydälle",
    copied_cli: "Kopioitu!",
    copied_pwd: "Salasana kopioitu!",
    copied_user: "Käyttäjänimi kopioitu!",
    footer_ai_attribution: "Luotu yhteistyössä Antigravityn ja Google Gemini 3.7 Flashin kanssa",
    toggle_show_matrix: "Näytä matriisi",
    toggle_hide_matrix: "Piilota matriisi",
    title_wallet: "🔑 Tietokannan SEPS Wallet -Tunnistetiedot & Pikakomennot",
    th_db: "Palvelu / Tietokanta",
    th_user: "Käyttäjätili",
    th_scope: "Työtila / Rooli",
    th_alias: "SEPS Wallet TNS -Alias (Klikkaa kopioidaksesi)",
    th_pwd: "1-Klikkauksen Salasana",
    desc_u_apex_admin: "APEX-alustan pääkäyttäjä",
    desc_u_sys: "Tietokannan pääkäyttäjä (SYSDBA)",
    desc_u_dba: "Tietokannan ylläpitäjä ja skeeman hallinta",
    desc_u_dev: "Kehittäjän työtila ja SQL Developer Web",
    desc_u_app: "Sovellusskeeman ja REST-taustajärjestelmän omistaja",
    desc_u_viewer: "Vain lukuoikeudella varustettu katselutili",
    desc_u_generic: "Tietokantasovelluksen tili",
    title_architecture_sec: "📐 Monitietokantainen Hybridiarkkitehtuuri ja Topologia",
    diag_title_1: "🏗️ Aktiivinen Multi-DB ja Konttitopologia",
    diag_title_2: "🔐 Zero-Trust Ingress, TLS ja SEPS Wallet -Arkkitehtuuri",
    diag_title_3: "🔄 Oracle Forms 14c Modernisointityönkulku",
    title_blueprints: "📋 Arkkitehtuurin Blueprint-Luettelo (11 Mallia)",
    filter_all: "🌟 Kaikki (11)",
    filter_core: "🗄️ Core APEX & DB (1–9)",
    filter_pub: "📑 Analytics Publisher (10–19)",
    filter_forms: "📐 Oracle Forms 14c (20–29)",
    filter_webide: "💻 Web IDE & CI/CD (30–39)",
    filter_ent: "🚀 Enterprise Kaikki-Yhdessä (40–49)",
    docs_empty_hint: "Valitse asiakirja vasemmasta valikosta nähdäksesi koko oppaan.",
    title_cheatsheet: "⚡ Kehittäjän & DevOps Pikakomennot",
    title_devops_deploy: "🚀 Blueprintien Käyttöönotto ja Vaihto",
    desc_devops_deploy: "Tarkista aktiivinen tila, testaa asetukset tai vaihda kuratoitujen blueprintien välillä.",
    title_devops_wallet: "🔐 Oracle Wallet -Salasanamatriisi",
    desc_devops_wallet: "Hae salatut tunnistetiedot turvallisesti SEPS Walletista ilman vuotoja.",
    title_devops_rotate: "🔄 Salasanan Rotaatio Ilman Katkoksia",
    desc_devops_rotate: "Kierrätä salasanat tietokannassa, Podman-salaisuuksissa ja SEPS Walletissa samanaikaisesti.",
    title_devops_snapshot: "⚡ Välitön Tilannevedosten Palautus",
    desc_devops_snapshot: "Luo tai palauta pakattuja kultaisia tilannevedoksia ~15 sekunnissa.",
    title_devops_health: "🌐 Palveluiden Terveyden Diagnostiikka",
    desc_devops_health: "Testaa aktiiviset HTTP/HTTPS-verkkopalvelut ja SEPS Wallet -yhteydet.",
    btn_copy_cmd: "📋 Kopioi Käyttöönottokomento",
    bench_th_step: "Asennusvaihe / Osajärjestelmä",
    bench_th_duration: "Kesto",
    bench_th_status: "Tila",
    bench_completed: "✔ Suoritettu",
    bench_step1: "Vaihe 1: Konttikuvien lataus/tarkistus",
    bench_step2: "Vaihe 2: ORDS-ohjelmiston lataus",
    bench_step3: "Vaihe 3: APEX-paketit",
    bench_step4: "Vaihe 4: Tietokantakontin käynnistys",
    bench_step5: "Vaihe 5: Tietokannan terveystilan odotus",
    bench_step6: "Vaihe 6: APEX-moottorin asennus & päivitykset",
    bench_step7: "Vaihe 7: DB-objektien ja skeemojen alustus",
    bench_step8: "Vaihe 8: APEX-sovellusten julkaisu",
    bench_step9: "Vaihe 9: Analytics Publisher",
    bench_step10: "Vaihe 10: Kultaisten tilannevedosten luonti",
    bench_total: "ASENNUKSEN KOKONAISKESTO",
    bench_empty: "Mittaritiedosto metrics/setup_benchmarks.json luodaan setup-all.sh -ajon jälkeen."
  }},
  sv: {{
    header_subtitle: "Enhetlig kontrollpanel, realtidsövervakning och flerspråkig arkitekturportal",
    tab_services: "Tjänster och Status",
    tab_architecture: "Arkitektur och Topologi",
    tab_blueprints: "Blueprint Katalogen (11 Modeller)",
    tab_docs: "Dokumentation",
    tab_devops: "DevOps Kommandon",
    tab_benchmarks: "Loggar och Prestanda",
    persona_dev: "Utvecklarhubb",
    persona_sec: "Säkerhet & Arkitekt",
    persona_ops: "DevOps & Drift",
    persona_pub: "Rapporter & Pixel-Perfect",
    title_endpoints: "🌐 Aktiva Tjänster och Portaler",
    auto_refresh_hint: "Uppdateras automatiskt var 6:e sekund",
    status_checking: "Kontrollerar...",
    status_online: "Online",
    status_init: "Startar...",
    desc_apex_ws: "Utvecklarens low-code applikationsarbetsyta (APEX 26.1).",
    btn_apex_ws: "Öppna APEX Arbetsyta →",
    desc_apex_admin: "APEX-instans och arbetsytehantering (INTERNAL).",
    btn_apex_admin: "Öppna APEX Admin →",
    desc_sdw: "Webbaserad SQL Developer, REST API och databashantering.",
    btn_sdw: "Öppna SQL Developer Web →",
    desc_ords: "Oracle REST Data Services gateway och OpenAPI metadata.",
    btn_ords: "Öppna ORDS Portal →",
    desc_pub: "Pixel-Perfect företagsrapportering med PDF/Excel-export.",
    btn_pub: "Öppna Analytics Publisher →",
    desc_forms: "Oracle Forms 14.1.2 WebLogic körtid och aktiv testform.",
    btn_forms: "Öppna Forms Testform →",
    desc_novnc: "HTML5 webbläsare för visuell Forms 14c Builder.",
    btn_novnc: "Öppna Forms Builder GUI →",
    desc_ide: "Webbaserad IDE med Oracle SQL Developer och AI.",
    btn_ide: "Öppna Web IDE →",
    desc_wls: "Forms / Publisher WebLogic-domän och JDBC-pooler.",
    btn_wls: "Öppna WebLogic-konsolen →",
    btn_copy_pwd: "Lösenord",
    tip_copy_pwd: "Kopiera lösenord till urklipp",
    tip_open_service: "Öppnar sidan och kopierar lösenordet till urklipp (klistra in: Cmd+V / Ctrl+V)",
    tip_copy_user: "Klicka för att kopiera användarnamnet till urklipp",
    tip_copy_ws: "Klicka för att kopiera arbetsytans namn till urklipp",
    copied_cli: "Kopierat!",
    copied_pwd: "Lösenord kopierat!",
    copied_user: "Användarnamn kopierat!",
    footer_ai_attribution: "Skapad i samarbete med Antigravity & Google Gemini 3.7 Flash",
    toggle_show_matrix: "Visa matris",
    toggle_hide_matrix: "Dölj matris",
    title_wallet: "🔑 Databas SEPS Wallet Autentisering & Snabbkommandon",
    th_db: "Tjänst / Databas",
    th_user: "Användarkonto",
    th_scope: "Arbetsyta / Roll",
    th_alias: "SEPS Wallet TNS Alias (Klicka för att kopiera)",
    th_pwd: "1-Klick Lösenord",
    desc_u_apex_admin: "APEX-plattformens administratör",
    desc_u_sys: "Databas superanvändare (SYSDBA)",
    desc_u_dba: "Databasadministratör och schemahanterare",
    desc_u_dev: "Utvecklararbetsyta och SQL Developer Web",
    desc_u_app: "Applikationsschema och REST-backendägare",
    desc_u_viewer: "Skrivskyddat rapport- och granskningskonto",
    desc_u_generic: "Databasapplikationskonto",
    title_architecture_sec: "📐 Multi-DB Hybridarkitektur och Topologi",
    diag_title_1: "🏗️ Aktiv Multi-DB och Container Topologi",
    diag_title_2: "🔐 Zero-Trust Ingress, TLS och SEPS Wallet Arkitektur",
    diag_title_3: "🔄 Oracle Forms 14c Moderniseringsarbetsflöde",
    title_blueprints: "📋 Arkitektur Blueprints (11 Modeller)",
    filter_all: "🌟 Alla (11)",
    filter_core: "🗄️ Core APEX & DB (1–9)",
    filter_pub: "📑 Analytics Publisher (10–19)",
    filter_forms: "📐 Oracle Forms 14c (20–29)",
    filter_webide: "💻 Web IDE & CI/CD (30–39)",
    filter_ent: "🚀 Enterprise Allt-i-ett (40–49)",
    docs_empty_hint: "Välj ett dokument i den vänstra menyn för att läsa hela guiden.",
    title_cheatsheet: "⚡ Utvecklare & DevOps Snabbkommandon",
    title_devops_deploy: "🚀 Blueprint Driftsättning och Byte",
    desc_devops_deploy: "Inspektera aktiv miljö, testa konfigurationer eller byt smidigt mellan blueprints.",
    title_devops_wallet: "🔐 Oracle Wallet Lösenordsmatris",
    desc_devops_wallet: "Hämta krypterade autentiseringsuppgifter säkert från SEPS Wallet.",
    title_devops_rotate: "🔄 Lösenordsrotation utan Avbrott",
    desc_devops_rotate: "Rotera lösenord i databasen, Podman Secrets och SEPS Wallet.",
    title_devops_snapshot: "⚡ Ögonblicksbildsåterställning",
    desc_devops_snapshot: "Skapa eller återställ komprimerade ögonblicksbilder på ~15 sekunder.",
    title_devops_health: "🌐 Hälsodiagnostik för Tjänster",
    desc_devops_health: "Testa aktiva HTTP/HTTPS-anslutningar och SEPS Wallet.",
    btn_copy_cmd: "📋 Kopiera Driftsättningskommando",
    bench_th_step: "Installationssteg / Delsystem",
    bench_th_duration: "Varaktighet",
    bench_th_status: "Status",
    bench_completed: "✔ Slutförd",
    bench_step1: "Steg 1: Containeravbildningar",
    bench_step2: "Steg 2: ORDS-nedladdning",
    bench_step3: "Steg 3: APEX-paket",
    bench_step4: "Steg 4: Databasstart",
    bench_step5: "Steg 5: Databashälsokontroll",
    bench_step6: "Steg 6: APEX-installation & patchning",
    bench_step7: "Steg 7: Databasobjekt & scheman",
    bench_step8: "Steg 8: APEX-applikationsdriftsättning",
    bench_step9: "Steg 9: Analytics Publisher",
    bench_step10: "Steg 10: Gyllene ögonblicksbilder",
    bench_total: "TOTAL INSTALLATIONSTID",
    bench_empty: "Mätvärdesfilen metrics/setup_benchmarks.json genereras efter körning av setup-all.sh."
  }},
  lv: {{
    header_subtitle: "Vienots vadības centrs, pakalpojumu uzraudzība un daudzvalodu arhitektūras portāls",
    tab_services: "Pakalpojumi un Statuss",
    tab_architecture: "Arhitektūra un Topoloģija",
    tab_blueprints: "Plānu Katalogs (11 Modeļi)",
    tab_docs: "Dokumentācija",
    tab_devops: "DevOps Komandas",
    tab_benchmarks: "Žurnāli un Veiktspēja",
    persona_dev: "Izstrādātāja Centrs",
    persona_sec: "Drošība un Arhitekts",
    persona_ops: "DevOps un Administrēšana",
    persona_pub: "Atskaites un Pixel-Perfect",
    title_endpoints: "🌐 Aktīvie Pakalpojumi un Portāli",
    auto_refresh_hint: "Automātiski atjaunojas ik pēc 6 sekundēm",
    status_checking: "Pārbauda...",
    status_online: "Tiešsaistē",
    status_init: "Inicializē...",
    desc_apex_ws: "Izstrādātāja lietotņu darbvieta (APEX 26.1).",
    btn_apex_ws: "Atvērt APEX Darbvietu →",
    desc_apex_admin: "APEX instances pārvaldības konsole (INTERNAL).",
    btn_apex_admin: "Atvērt APEX Admin →",
    desc_sdw: "Tīmekļa SQL Developer, REST API un datubāzes pārvaldība.",
    btn_sdw: "Atvērt SQL Developer Web →",
    desc_ords: "Oracle REST Data Services vārteja un metadati.",
    btn_ords: "Atvērt ORDS Portālu →",
    desc_pub: "Pixel-Perfect uzņēmuma PDF/Excel atskaites.",
    btn_pub: "Atvērt Analytics Publisher →",
    desc_forms: "Oracle Forms 14.1.2 izpildlaiks un testa forma.",
    btn_forms: "Atvērt Forms Testa Formu →",
    desc_novnc: "HTML5 pārlūks Forms 14c Builder vizuālai izstrādei.",
    btn_novnc: "Atvērt Forms Builder GUI →",
    desc_ide: "Pārlūka IDE ar Oracle SQL Developer un AI.",
    btn_ide: "Atvērt Web IDE →",
    desc_wls: "Forms / Publisher WebLogic domēns un pārraudzība.",
    btn_wls: "Atvērt WebLogic Konsoli →",
    btn_copy_pwd: "Parole",
    tip_copy_pwd: "Kopēt paroli starpliktuvē",
    tip_open_service: "Atver lapu un nokopē paroli starpliktuvē (ielīmēt: Cmd+V / Ctrl+V)",
    tip_copy_user: "Noklikšķiniet, lai nokopētu lietotājvārdu starpliktuvē",
    tip_copy_ws: "Noklikšķiniet, lai nokopētu darbvietas nosaukumu starpliktuvē",
    copied_cli: "Nokopēts!",
    copied_pwd: "Parole nokopēta!",
    copied_user: "Lietotājvārds nokopēts!",
    footer_ai_attribution: "Izstrādāts sadarbībā ar Antigravity un Google Gemini 3.7 Flash",
    toggle_show_matrix: "Rādīt matricu",
    toggle_hide_matrix: "Paslēpt matricu",
    title_wallet: "🔑 Datubāzes SEPS Wallet Piekļuves Dati un Ātrās Komandas",
    th_db: "Pakalpojums / Datubāze",
    th_user: "Lietotāja Konts",
    th_scope: "Darbvieta / Loma",
    th_alias: "SEPS Wallet TNS Alias (Noklikšķiniet, lai kopētu)",
    th_pwd: "1-Klikšķa Parole",
    desc_u_apex_admin: "APEX platformas administrators",
    desc_u_sys: "Datubāzes superlietotājs (SYSDBA)",
    desc_u_dba: "Datubāzes administrators un shēmu pārvaldnieks",
    desc_u_dev: "Izstrādātāja darbvieta un SQL Developer Web",
    desc_u_app: "Lietojumprogrammas shēma un REST aizmugursistēma",
    desc_u_viewer: "Tikai lasīšanas pārskatu un audita konts",
    desc_u_generic: "Datubāzes lietojumprogrammas konts",
    title_architecture_sec: "📐 Vairāku Datubāzu Hibrīdā Arhitektūra un Topoloģija",
    diag_title_1: "🏗️ Aktīvā Multi-DB un Konteineru Topoloģija",
    diag_title_2: "🔐 Zero-Trust Ingress, TLS un SEPS Wallet Arhitektūra",
    diag_title_3: "🔄 Oracle Forms 14c Modernizācijas Darbplūsma",
    title_blueprints: "📋 Arhitektūras Plānu Katalogs (11 Modeļi)",
    filter_all: "🌟 Visi (11)",
    filter_core: "🗄️ Core APEX & DB (1–9)",
    filter_pub: "📑 Analytics Publisher (10–19)",
    filter_forms: "📐 Oracle Forms 14c (20–29)",
    filter_webide: "💻 Web IDE & CI/CD (30–39)",
    filter_ent: "🚀 Enterprise Viss-Vienā (40–49)",
    docs_empty_hint: "Atlasiet dokumentu kreisajā izvēlnē, lai skatītu pilnu rokasgrāmatu.",
    title_cheatsheet: "⚡ Izstrādātāja & DevOps Ātrās Komandas",
    title_devops_deploy: "🚀 Blueprint Izvēršana un Pārslēgšana",
    desc_devops_deploy: "Pārbaudiet aktīvo vidi, testējiet iestatījumus vai viegli pārslēdzieties starp blueprints.",
    title_devops_wallet: "🔐 Oracle Wallet Paroļu Matrica",
    desc_devops_wallet: "Droši iegūstiet atšifrētos datus no SEPS Wallet.",
    title_devops_rotate: "🔄 Paroļu Rotācija Bez Dīkstāves",
    desc_devops_rotate: "Rotējiet paroles datubāzē, Podman Secrets un SEPS Wallet.",
    title_devops_snapshot: "⚡ Tūlītēja Momentuzņēmumu Atkopšana",
    desc_devops_snapshot: "Izveidojiet vai atjaunojiet momentuzņēmumus ~15 sekundēs.",
    title_devops_health: "🌐 Pakalpojumu Veselības Diagnostika",
    desc_devops_health: "Pārbaudiet aktīvos HTTP/HTTPS savienojumus un SEPS Wallet.",
    btn_copy_cmd: "📋 Kopēt Izvēršanas Komandu",
    bench_th_step: "Uzstādīšanas Solis / Apakšsistēma",
    bench_th_duration: "Ilgums",
    bench_th_status: "Statuss",
    bench_completed: "✔ Pabeigts",
    bench_step1: "1. solis: Konteineru attēli",
    bench_step2: "2. solis: ORDS lejupielāde",
    bench_step3: "3. solis: APEX pakotnes",
    bench_step4: "4. solis: Datubāzes palaišana",
    bench_step5: "5. solis: Veselības pārbaude",
    bench_step6: "6. solis: APEX dzinējs & ielāpi",
    bench_step7: "7. solis: DB objekti & shēmas",
    bench_step8: "8. solis: APEX lietotņu izvietošana",
    bench_step9: "9. solis: Analytics Publisher",
    bench_step10: "10. solis: Zelta momentuzņēmumi",
    bench_total: "KOPĒJAIS UZSTĀDĪŠANAS LAIKS",
    bench_empty: "Metrikas fails metrics/setup_benchmarks.json tiks ģenerēts pēc setup-all.sh palaišanas."
  }},
  lt: {{
    header_subtitle: "Vieningas valdymo centras, paslaugų stebėsena ir daugiakalbis architektūros portalas",
    tab_services: "Paslaugos ir Būsena",
    tab_architecture: "Architektūra ir Topologija",
    tab_blueprints: "Planų Katalogas (11 Modelių)",
    tab_docs: "Dokumentacija",
    tab_devops: "DevOps Komandos",
    tab_benchmarks: "Žurnalai ir Našumas",
    persona_dev: "Kūrėjo Centras",
    persona_sec: "Saugumas ir Architektas",
    persona_ops: "DevOps ir Valdymas",
    persona_pub: "Ataskaitos ir Pixel-Perfect",
    title_endpoints: "🌐 Aktyvios Paslaugos ir Portalai",
    auto_refresh_hint: "Automatiškai atnaujinama kas 6 sekundes",
    status_checking: "Tikrinama...",
    status_online: "Prisijungta",
    status_init: "Inicijuojama...",
    desc_apex_ws: "Kūrėjo programų darbo erdvė (APEX 26.1).",
    btn_apex_ws: "Atidaryti APEX Darbo Erdvę →",
    desc_apex_admin: "APEX instancijos valdymo konsolė (INTERNAL).",
    btn_apex_admin: "Atidaryti APEX Admin →",
    desc_sdw: "Žiniatinklio SQL Developer, REST API ir DB valdymas.",
    btn_sdw: "Atidaryti SQL Developer Web →",
    desc_ords: "Oracle REST Data Services šliuzas ir metaduomenys.",
    btn_ords: "Atidaryti ORDS Portalą →",
    desc_pub: "Pixel-Perfect įmonės PDF/Excel ataskaitos.",
    btn_pub: "Atidaryti Analytics Publisher →",
    desc_forms: "Oracle Forms 14.1.2 vykdymo aplinka ir testinė forma.",
    btn_forms: "Atidaryti Forms Testinę Formą →",
    desc_novnc: "HTML5 naršyklė Forms 14c Builder vizualiam kūrimui.",
    btn_novnc: "Atidaryti Forms Builder GUI →",
    desc_ide: "Naršyklės IDE su Oracle SQL Developer ir AI.",
    btn_ide: "Atidaryti Web IDE →",
    desc_wls: "Forms / Publisher WebLogic domenas ir stebėsena.",
    btn_wls: "Atidaryti WebLogic Konsolę →",
    btn_copy_pwd: "Slaptažodis",
    tip_copy_pwd: "Kopijuoti slaptažodį į mainų sritį",
    tip_open_service: "Atidaro puslapį ir nukopijuoja slaptažodį į mainų sritį (įklijuoti: Cmd+V / Ctrl+V)",
    tip_copy_user: "Spustelėkite, kad nukopijuotumėte vartotojo vardą į mainų sritį",
    tip_copy_ws: "Spustelėkite, kad nukopijuotumėte darbo erdvės pavadinimą į mainų sritį",
    copied_cli: "Nukopijuota!",
    copied_pwd: "Slaptažodis nukopijuotas!",
    copied_user: "Vartotojo vardas nukopijuotas!",
    footer_ai_attribution: "Sukurta bendradarbiaujant su Antigravity ir Google Gemini 3.7 Flash",
    toggle_show_matrix: "Rodyti matricą",
    toggle_hide_matrix: "Slėpti matricą",
    title_wallet: "🔑 Duomenų bazės SEPS Wallet Slaptažodžiai ir Greitosios Komandos",
    th_db: "Paslauga / Duomenų bazė",
    th_user: "Vartotojo Paskyra",
    th_scope: "Darbo Erdvė / Rolė",
    th_alias: "SEPS Wallet TNS Pseudonimas (Spustelėkite kopijavimui)",
    th_pwd: "1-Paspaudimo Slaptažodis",
    desc_u_apex_admin: "APEX platformos administratorius",
    desc_u_sys: "Duomenų bazės supervartotojas (SYSDBA)",
    desc_u_dba: "Duomenų bazės administratorius ir schemų valdytojas",
    desc_u_dev: "Kūrėjo darbo erdvė ir SQL Developer Web",
    desc_u_app: "Programos schema ir REST posistemio savininkas",
    desc_u_viewer: "Tik skaitymo ataskaitų ir audito paskyra",
    desc_u_generic: "Duomenų bazės programos paskyra",
    title_architecture_sec: "📐 Hibridinė Kelių DB Architektūra ir Topologija",
    diag_title_1: "🏗️ Aktyvi Multi-DB ir Konteinerių Topologija",
    diag_title_2: "🔐 Zero-Trust Ingress, TLS ir SEPS Wallet Architektūra",
    diag_title_3: "🔄 Oracle Forms 14c Modernizavimo Eiga",
    title_blueprints: "📋 Architektūros Planų Katalogas (11 Modelių)",
    filter_all: "🌟 Visi (11)",
    filter_core: "🗄️ Core APEX & DB (1–9)",
    filter_pub: "📑 Analytics Publisher (10–19)",
    filter_forms: "📐 Oracle Forms 14c (20–29)",
    filter_webide: "💻 Web IDE & CI/CD (30–39)",
    filter_ent: "🚀 Enterprise Viskas-Viename (40–49)",
    docs_empty_hint: "Pasirinkite dokumentą kairiajame meniu, kad pamatytumėte visą vadovą.",
    title_cheatsheet: "⚡ Kūrėjo & DevOps Greitosios Komandos",
    title_devops_wallet: "🔐 Oracle Wallet Slaptažodžių Matrica",
    desc_devops_wallet: "Saugiai gaukite iššifruotus duomenis iš SEPS Wallet be nutekėjimų.",
    title_devops_rotate: "🔄 Slaptažodžių Keitimas Be Prastovos",
    desc_devops_rotate: "Keiskite slaptažodžius duomenų bazėje, Podman Secrets ir SEPS Wallet.",
    title_devops_snapshot: "⚡ Momentinis Atstatymas iš Momentinių Kopijų",
    desc_devops_snapshot: "Sukurkite arba atstatykite kopijas per ~15 sekundžių.",
    title_devops_health: "🌐 Paslaugų Būklės Diagnostika",
    desc_devops_health: "Tikrinkite aktyvias HTTP/HTTPS paslaugas ir SEPS Wallet ryšius.",
    btn_copy_cmd: "📋 Kopijuoti Paleidimo Komandą",
    bench_th_step: "Diegimo Žingsnis / Posistemė",
    bench_th_duration: "Trukmė",
    bench_th_status: "Būsena",
    bench_completed: "✔ Atlikta",
    bench_step1: "1 žingsnis: Konteinerių atvaizdai",
    bench_step2: "2 žingsnis: ORDS atsisiuntimas",
    bench_step3: "3 žingsnis: APEX paketai",
    bench_step4: "4 žingsnis: DB paleidimas",
    bench_step5: "5 žingsnis: Būklės patikra",
    bench_step6: "6 žingsnis: APEX variklis ir pataisos",
    bench_step7: "7 žingsnis: DB objektai ir schemos",
    bench_step8: "8 žingsnis: APEX programų diegimas",
    bench_step9: "9 žingsnis: Analytics Publisher",
    bench_step10: "10 žingsnis: Kopijų sukūrimas",
    bench_total: "BENDRAS DIEGIMO LAIKAS",
    bench_empty: "Metrikos failas metrics/setup_benchmarks.json bus sukurtas po setup-all.sh paleidimo."
  }}
}};

function switchTab(tabId) {{
  document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
  document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
  
  if (window.event && window.event.currentTarget) {{
    window.event.currentTarget.classList.add('active');
  }}
  const activeContent = document.getElementById(tabId);
  if (activeContent) {{
    activeContent.classList.add('active');
    if (tabId === 'tab-architecture') {{
      const lang = localStorage.getItem('dev_hub_lang') || 'en';
      renderMermaidDiagrams(lang);
    }} else if (tabId === 'tab-docs') {{
      renderDocsNav(currentSelectedDocIdx);
    }} else if (tabId === 'tab-benchmarks') {{
      loadBenchmarksData();
    }}
  }}
}}

function switchPersona(persona) {{
  document.querySelectorAll('.persona-btn').forEach(btn => btn.classList.remove('active'));
  if (window.event && window.event.currentTarget) {{
    window.event.currentTarget.classList.add('active');
  }}
  if (persona === 'developer') switchTab('tab-services');
  else if (persona === 'security') switchTab('tab-architecture');
  else if (persona === 'devops') switchTab('tab-devops');
  else if (persona === 'publisher') switchTab('tab-services');
}}

function renderMermaidDiagrams(lang) {{
  lang = lang || localStorage.getItem('dev_hub_lang') || 'en';
  const diags = MERMAID_DIAGRAMS[lang] || MERMAID_DIAGRAMS['en'];
  
  for (let i = 0; i < diags.length; i++) {{
    const el = document.getElementById('mermaid-diag-' + (i + 1));
    if (el) {{
      el.removeAttribute('data-processed');
      el.innerHTML = diags[i];
    }}
  }}
  mermaid.run({{ querySelector: '.mermaid' }});
}}

function setLanguage(lang) {{
  if (!I18N_DICT[lang]) lang = 'en';
  localStorage.setItem('dev_hub_lang', lang);
  
  document.querySelectorAll('.lang-btn').forEach(btn => btn.classList.remove('active'));
  const activeBtn = document.getElementById('btn-' + lang);
  if (activeBtn) activeBtn.classList.add('active');
  
  document.querySelectorAll('[data-i18n]').forEach(el => {{
    const key = el.getAttribute('data-i18n');
    if (I18N_DICT[lang] && I18N_DICT[lang][key]) {{
      el.textContent = I18N_DICT[lang][key];
    }}
  }});

  document.querySelectorAll('[data-i18n-title]').forEach(el => {{
    const key = el.getAttribute('data-i18n-title');
    if (I18N_DICT[lang] && I18N_DICT[lang][key]) {{
      el.setAttribute('title', I18N_DICT[lang][key]);
    }}
  }});

  const drawer = document.getElementById('wallet-matrix-drawer');
  const label = document.getElementById('wallet-toggle-label');
  if (drawer && label) {{
    const isOpen = drawer.style.maxHeight !== '0px' && drawer.style.maxHeight !== '';
    label.textContent = I18N_DICT[lang] ? (isOpen ? I18N_DICT[lang]['toggle_hide_matrix'] : I18N_DICT[lang]['toggle_show_matrix']) : 'Show Matrix';
  }}

  renderBlueprints(currentActiveFilter);
  renderDocsNav(currentSelectedDocIdx);
  renderMermaidDiagrams(lang);
  loadBenchmarksData();

  document.querySelectorAll('.status-pill').forEach(pill => {{
    const url = pill.getAttribute('data-status-url');
    if (url && serviceStates[url]) {{
      applyPillState(pill, serviceStates[url], lang);
    }}
  }});
}}

function applyPillState(pill, state, lang) {{
  lang = lang || localStorage.getItem('dev_hub_lang') || 'en';
  pill.classList.remove('status-checking', 'status-online', 'status-init');
  const textEl = pill.querySelector('.status-text');
  
  if (state === 'online') {{
    pill.classList.add('status-online');
    if (textEl) textEl.textContent = (I18N_DICT[lang] && I18N_DICT[lang]['status_online']) || 'Online';
  }} else if (state === 'init') {{
    pill.classList.add('status-init');
    if (textEl) textEl.textContent = (I18N_DICT[lang] && I18N_DICT[lang]['status_init']) || 'Initializing...';
  }} else {{
    pill.classList.add('status-checking');
    if (textEl) textEl.textContent = (I18N_DICT[lang] && I18N_DICT[lang]['status_checking']) || 'Checking...';
  }}
}}

async function checkServiceHealth() {{
  const pills = document.querySelectorAll('.status-pill');
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  
  pills.forEach(async (pill) => {{
    const url = pill.getAttribute('data-status-url');
    if (!url) return;
    
    try {{
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 2500);
      
      await fetch(url, {{ method: 'GET', mode: 'no-cors', cache: 'no-cache', credentials: 'omit', signal: controller.signal }});
      clearTimeout(timeoutId);
      serviceStates[url] = 'online';
      applyPillState(pill, 'online', currentLang);
    }} catch (err) {{
      serviceStates[url] = 'init';
      applyPillState(pill, 'init', currentLang);
    }}
  }});
}}

function renderBlueprints(filter) {{
  const grid = document.getElementById('blueprints-grid');
  if (!grid) return;
  currentActiveFilter = filter || 'all';
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  
  grid.innerHTML = '';
  const list = (filter === 'all') ? BLUEPRINTS_DATA : BLUEPRINTS_DATA.filter(b => b.cat === filter);
  
  list.forEach(b => {{
    const isActive = (b.num === ACTIVE_BP_NUM);
    const card = document.createElement('div');
    card.className = 'bp-card' + (isActive ? ' active-bp' : '');
    
    const title = (b.titles && b.titles[currentLang]) || (b.titles && b.titles['en']) || `Blueprint #${{b.num}}`;
    const desc = (b.descs && b.descs[currentLang]) || (b.descs && b.descs['en']) || b.file;
    const copyLabel = (I18N_DICT[currentLang] && I18N_DICT[currentLang]['btn_copy_cmd']) || '📋 Copy Launch Command';
    
    card.innerHTML = `
      <div>
        <div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 8px;">
          <h4 style="color: var(--primary); font-size: 1.05rem;">Blueprint #${{b.num}}</h4>
          ${{isActive ? '<span class="badge-active" style="padding: 2px 8px; font-size: 0.7rem;">CURRENT ACTIVE</span>' : ''}}
        </div>
        <p style="font-weight: 600; color: #f1f5f9; margin-top: 4px; font-size: 0.9rem;">${{title}}</p>
        <p style="color: var(--text-muted); font-size: 0.8rem; margin-top: 6px; line-height: 1.4;">${{desc}}</p>
        <div class="bp-meta-tags">
          <span class="bp-tag">📦 ${{b.containers || 'Standalone'}}</span>
          <span class="bp-tag">⚡ RAM: ${{b.ram}}</span>
        </div>
      </div>
      <div style="display: flex; gap: 8px; margin-top: 8px;">
        <button class="btn btn-secondary" style="padding: 6px 10px; font-size: 0.75rem;" onclick="copyText('./scripts/deploy-blueprint.sh -b ${{b.num}} --lang ${{currentLang}}')">${{copyLabel}}</button>
      </div>
    `;
    grid.appendChild(card);
  }});
}}

function filterBlueprints(cat) {{
  document.querySelectorAll('.bp-filter-btn').forEach(btn => btn.classList.remove('active'));
  if (window.event && window.event.target) window.event.target.classList.add('active');
  renderBlueprints(cat);
}}

function renderDocsNav(selectedIdx) {{
  const sidebar = document.getElementById('docs-sidebar-nav');
  if (!sidebar) return;
  sidebar.innerHTML = '';
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  currentSelectedDocIdx = selectedIdx || 0;
  
  DOCS_DATA.forEach((doc, idx) => {{
    const btn = document.createElement('button');
    btn.className = 'docs-nav-item' + (idx === currentSelectedDocIdx ? ' active' : '');
    btn.textContent = (doc.titles && doc.titles[currentLang]) || (doc.titles && doc.titles['en']) || doc.rel;
    btn.onclick = () => loadDocContent(idx, btn);
    sidebar.appendChild(btn);
  }});
  
  if (DOCS_DATA.length > 0) {{
    loadDocContent(currentSelectedDocIdx, sidebar.children[currentSelectedDocIdx]);
  }}
}}

function loadDocContent(idx, activeBtn) {{
  currentSelectedDocIdx = idx;
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  
  if (activeBtn) {{
    document.querySelectorAll('.docs-nav-item').forEach(b => b.classList.remove('active'));
    activeBtn.classList.add('active');
  }}
  
  const view = document.getElementById('docs-markdown-view');
  if (!view) return;
  
  const doc = DOCS_DATA[idx];
  if (doc && doc.contents) {{
    const text = doc.contents[currentLang] || doc.contents['en'] || '';
    if (text) {{
      view.innerHTML = marked.parse(text);
      return;
    }}
  }}
  
  view.innerHTML = `
    <div style="background: #1e293b; padding: 24px; border-radius: 8px; border: 1px solid var(--border);">
      <h3 style="color: var(--primary); margin-bottom: 8px;">📄 Repository Documentation: <code>${{doc.rel}}</code></h3>
      <p style="color: var(--text-muted); margin-bottom: 16px;">This markdown guide is located directly in the project repository workspace at: <code>${{doc.rel}}</code></p>
      <pre><code>cat ${{doc.rel}}</code></pre>
    </div>
  `;
}}

async function loadBenchmarksData() {{
  const container = document.getElementById('benchmarks-table-container');
  if (!container) return;
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
  
  try {{
    const res = await fetch('metrics/setup_benchmarks.json');
    if (!res.ok) throw new Error('Metrics not found');
    const data = await res.json();
    
    let html = `
      <div class="table-responsive">
        <table>
          <thead>
            <tr>
              <th>${{dict.bench_th_step}}</th>
              <th>${{dict.bench_th_duration}}</th>
              <th>${{dict.bench_th_status}}</th>
            </tr>
          </thead>
          <tbody>
    `;
    
    const steps = [
      {{ name: dict.bench_step1, val: data.step1_pull_secs }},
      {{ name: dict.bench_step2, val: data.step2_ords_download_secs }},
      {{ name: dict.bench_step3, val: data.step3_apex_download_secs }},
      {{ name: dict.bench_step4, val: data.step4_container_startup_secs }},
      {{ name: dict.bench_step5, val: data.step5_db_health_wait_secs }},
      {{ name: dict.bench_step6, val: data.step6_apex_install_secs }},
      {{ name: dict.bench_step7, val: data.step7_schema_init_secs }},
      {{ name: dict.bench_step8, val: data.step8_apex_app_deploy_secs }},
      {{ name: dict.bench_step9, val: data.step9_publisher_install_secs }},
      {{ name: dict.bench_step10, val: data.step10_snapshots_secs }},
      {{ name: dict.bench_total, val: data.total_setup_secs, bold: true }}
    ];
    
    steps.forEach(s => {{
      if (s.val !== undefined) {{
        const dur = (s.val >= 60) ? Math.floor(s.val/60) + 'm ' + (s.val%60) + 's' : s.val + 's';
        html += `
          <tr ${{s.bold ? 'style="font-weight: bold; background: rgba(56, 189, 248, 0.08);"' : ''}}>
            <td>${{s.name}}</td>
            <td style="color: var(--primary); font-family: ui-monospace, monospace;">${{dur}}</td>
            <td><span style="color: var(--success); font-weight: 600;">${{dict.bench_completed}}</span></td>
          </tr>
        `;
      }}
    }});
    
    html += '</tbody></table></div>';
    container.innerHTML = html;
  }} catch (err) {{
    container.innerHTML = `
      <p style="color: #94a3b8;">${{dict.bench_empty}}</p>
    `;
  }}
}}

function copySnippet(btn) {{
  const codeBox = btn.closest('.code-box');
  if (!codeBox) return;
  const clone = codeBox.cloneNode(true);
  const copyBtn = clone.querySelector('.copy-btn');
  if (copyBtn) copyBtn.remove();
  
  navigator.clipboard.writeText(clone.textContent.trim()).then(() => {{
    btn.textContent = '✅ Copied!';
    setTimeout(() => {{ btn.textContent = 'Copy'; }}, 2000);
  }});
}}

const LOCAL_PASSWORDS = {passwords_map_json};

function isLocalhostHost() {{
  return window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1' || window.location.hostname === '::1';
}}

function openServiceWithCredentials(targetUrl, alias, user, evt) {{
  if (evt) evt.preventDefault();
  let finalUrl = targetUrl;
  const isLocal = isLocalhostHost();
  const pwd = (isLocal && LOCAL_PASSWORDS && LOCAL_PASSWORDS[alias]) ? LOCAL_PASSWORDS[alias] : '';

  if (isLocal && pwd) {{
    // 1. Copy real password directly to clipboard (Zero-Trust: NEVER pass password as URL query parameter)
    if (navigator.clipboard) {{
      navigator.clipboard.writeText(pwd).then(() => {{
        showToast('🔑 Password for ' + (user || alias) + ' copied to clipboard! (Cmd+V / Ctrl+V to paste)');
      }}).catch(() => {{}});
    }}
  }}

  // Clean redirection for apex_admin to administration-sign-in with ADMIN username prefilled (no password)
  if (finalUrl.includes('/apex_admin')) {{
    finalUrl = finalUrl.replace('/apex_admin', '/r/apex/workspace-sign-in/administration-sign-in?p10_username=ADMIN');
  }}

  window.open(finalUrl, '_blank');
}}

function copyUsername(name, el) {{
  navigator.clipboard.writeText(name).then(() => {{
    const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
    const msg = (I18N_DICT[currentLang] && I18N_DICT[currentLang]['copied_user']) || 'Username Copied!';
    if (el) {{
      const origHtml = el.innerHTML;
      el.innerHTML = '<span style="color:#22c55e;">✅ ' + name + '</span>';
      setTimeout(() => {{ el.innerHTML = origHtml; }}, 1800);
    }}
    showToast('👤 ' + name + ': ' + msg);
  }});
}}

function handleCopyPassword(alias, btn) {{
  const isLocal = isLocalhostHost();
  const pwd = (isLocal && LOCAL_PASSWORDS && LOCAL_PASSWORDS[alias]) ? LOCAL_PASSWORDS[alias] : '';
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const msg = (I18N_DICT[currentLang] && I18N_DICT[currentLang]['copied_pwd']) || 'Password Copied!';

  if (isLocal && pwd) {{
    navigator.clipboard.writeText(pwd).then(() => {{
      if (btn) {{
        const orig = btn.innerHTML;
        btn.innerHTML = '<span>🔑</span> <span>' + msg + '</span>';
        showToast('🔑 ' + alias + ': ' + msg);
        setTimeout(() => {{ btn.innerHTML = orig; }}, 2000);
      }}
    }});
  }} else {{
    // Remote or non-localhost fallback: copy CLI command
    copyText('./scripts/get-password.sh ' + alias + ' -c', btn);
  }}
}}

function showToast(msg) {{
  let t = document.getElementById('dev-hub-toast');
  if (!t) {{
    t = document.createElement('div');
    t.id = 'dev-hub-toast';
    t.style.cssText = 'position:fixed; bottom:24px; right:24px; background:#0f172a; color:#f8fafc; padding:12px 20px; border-radius:8px; border:1px solid #38bdf8; box-shadow:0 10px 25px rgba(0,0,0,0.5); z-index:9999; font-size:0.875rem; font-weight:500; transition:all 0.3s ease; opacity:0; pointer-events:none; display:flex; align-items:center; gap:8px;';
    document.body.appendChild(t);
  }}
  t.innerHTML = msg;
  t.style.opacity = '1';
  t.style.transform = 'translateY(0)';
  clearTimeout(t._timeout);
  t._timeout = setTimeout(() => {{
    t.style.opacity = '0';
    t.style.transform = 'translateY(10px)';
  }}, 3000);
}}

function copyBadge(el, txt) {{
  navigator.clipboard.writeText(txt).then(() => {{
    const orig = el.textContent;
    el.textContent = '✅ Copied!';
    setTimeout(() => {{ el.textContent = orig; }}, 1800);
  }});
}}

function copyText(txt, btn) {{
  navigator.clipboard.writeText(txt).then(() => {{
    if (btn) {{
      const orig = btn.innerHTML;
      const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
      const msg = (I18N_DICT[currentLang] && I18N_DICT[currentLang]['copied_cli']) || 'Copied CLI!';
      btn.innerHTML = '<span>✅</span> <span>' + msg + '</span>';
      setTimeout(() => {{ btn.innerHTML = orig; }}, 1800);
    }}
  }});
}}

function toggleWalletMatrix(forceOpen) {{
  const drawer = document.getElementById('wallet-matrix-drawer');
  const label = document.getElementById('wallet-toggle-label');
  const icon = document.getElementById('wallet-toggle-icon');
  if (!drawer) return;
  
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const isOpen = (forceOpen !== undefined) ? !forceOpen : (drawer.style.maxHeight !== '0px' && drawer.style.maxHeight !== '');
  
  if (isOpen) {{
    drawer.style.maxHeight = '0px';
    drawer.style.opacity = '0';
    if (icon) icon.textContent = '➕';
    if (label) label.textContent = (I18N_DICT[currentLang] && I18N_DICT[currentLang]['toggle_show_matrix']) || 'Show Matrix';
    localStorage.setItem('dev_hub_wallet_open', 'false');
  }} else {{
    drawer.style.maxHeight = '2500px';
    drawer.style.opacity = '1';
    if (icon) icon.textContent = '➖';
    if (label) label.textContent = (I18N_DICT[currentLang] && I18N_DICT[currentLang]['toggle_hide_matrix']) || 'Hide Matrix';
    localStorage.setItem('dev_hub_wallet_open', 'true');
  }}
}}

function copyAndScrollToWallet(alias, el, cmd) {{
  const isLocal = isLocalhostHost();
  const pwd = (isLocal && LOCAL_PASSWORDS && LOCAL_PASSWORDS[alias]) ? LOCAL_PASSWORDS[alias] : '';
  const toCopy = (isLocal && pwd) ? pwd : (cmd || ('./scripts/get-password.sh ' + alias + ' -c'));
  
  navigator.clipboard.writeText(toCopy).then(() => {{
    if (el) {{
      const origHtml = el.innerHTML;
      el.innerHTML = '<span style="color:#22c55e; font-weight:700;">✅ Copied!</span>';
      showToast('🔑 ' + (isLocal && pwd ? 'Password' : 'CLI Command') + ' for ' + alias + ' copied!');
      setTimeout(() => {{ el.innerHTML = origHtml; }}, 1800);
    }}
  }});

  // Automatically expand wallet matrix drawer if collapsed
  toggleWalletMatrix(true);

  setTimeout(() => {{
    const row = document.getElementById('row-' + alias);
    if (row) {{
      row.scrollIntoView({{ behavior: 'smooth', block: 'center' }});
      const origBg = row.style.backgroundColor;
      row.style.backgroundColor = 'rgba(56, 189, 248, 0.35)';
      setTimeout(() => {{
        row.style.backgroundColor = origBg;
      }}, 2000);
    }}
  }}, 150);
}}

function scrollToWallet(alias, el) {{
  copyAndScrollToWallet(alias, el);
}}

document.addEventListener('DOMContentLoaded', () => {{
  const saved = localStorage.getItem('dev_hub_lang') || 'en';
  setLanguage(saved);
  
  // Initialize wallet matrix collapse state
  const isWalletOpen = localStorage.getItem('dev_hub_wallet_open') === 'true';
  if (isWalletOpen) {{
    toggleWalletMatrix(true);
  }}

  checkServiceHealth();
  setInterval(checkServiceHealth, 6000);
}});
</script>
</body>
</html>
"""

os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)
with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
    f.write(html_content)

print(f"✅ Developer Hub HTML generated to: {OUTPUT_FILE}")
