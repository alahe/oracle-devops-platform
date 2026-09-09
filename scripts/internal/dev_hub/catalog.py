"""
Oracle DevOps Platform - Developer Hub Catalog & Metadata
Defines documentation files (DOC_SPECS), Blueprint metadata (BP_CATALOG),
theme colors (BP_COLOR_THEMES), and 8-slide presentation deck (SLIDES_CONTENT).
"""

DOC_SPECS = [
    {
        "id": "readme",
        "rel": "README.md",
        "titles": {
            "en": "📖 Quick Start & Platform Overview",
            "et": "📖 Kiiralustus ja platvormi ülevaade",
            "fi": "📖 Pika-aloitus ja alustan yleiskatsaus",
            "sv": "📖 Snabbstart & plattformöversikt",
            "lv": "📖 Ātrā darba sākšana & pārskats",
            "lt": "📖 Greitas pradžiamokslis ir apžvalga"
        },
        "files": {
            "en": "README.md",
            "et": "docs/et/README.md",
            "fi": "docs/fi/README.md",
            "sv": "docs/sv/README.md",
            "lv": "docs/lv/README.md",
            "lt": "docs/lt/README.md"
        }
    },
    {
        "id": "getting-started",
        "rel": "docs/getting-started-from-scratch.md",
        "titles": {
            "en": "🚀 Zero-to-Hero Quickstart (From Scratch)",
            "et": "🚀 Kiirstardi juhend (nullist alustamine)",
            "fi": "🚀 Pikaopas (alusta alkaen)",
            "sv": "🚀 Snabbstart (från grunden)",
            "lv": "🚀 Ātrā sākšana (no nulles)",
            "lt": "🚀 Greita pradžia (nuo nulio)"
        },
        "files": {
            "en": "docs/getting-started-from-scratch.md",
            "et": "docs/et/getting-started-from-scratch.md",
            "fi": "docs/getting-started-from-scratch.md",
            "sv": "docs/getting-started-from-scratch.md",
            "lv": "docs/getting-started-from-scratch.md",
            "lt": "docs/getting-started-from-scratch.md"
        }
    },
    {
        "id": "quick-login",
        "rel": "docs/quick-login-guide.md",
        "titles": {
            "en": "🚀 Quick Login & Clipboard Guide",
            "et": "🚀 Kiirjuhend sisselogimiseks",
            "fi": "🚀 Pikaopas kirjautumiseen",
            "sv": "🚀 Snabbguide för inloggning",
            "lv": "🚀 Ātrās pieteikšanās rokasgrāmata",
            "lt": "🚀 Greito prisijungimo gidas"
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
        "id": "testing-framework",
        "rel": "docs/testing-framework-and-devhub.md",
        "titles": {
            "en": "🧪 Automated Testing Framework & Dev Hub",
            "et": "🧪 Automaattestimise raamistik & Dev Hub",
            "fi": "🧪 Automaattitestauskehys & Dev Hub",
            "sv": "🧪 Automatiserat testramverk & Dev Hub",
            "lv": "🧪 Automatizētās testēšanas ietvars & Dev Hub",
            "lt": "🧪 Automatizuoto testavimo sistema & Dev Hub"
        },
        "files": {
            "en": "docs/testing-framework-and-devhub.md",
            "et": "docs/et/testing-framework-and-devhub.md",
            "fi": "docs/fi/testing-framework-and-devhub.md",
            "sv": "docs/sv/testing-framework-and-devhub.md",
            "lv": "docs/lv/testing-framework-and-devhub.md",
            "lt": "docs/lt/testing-framework-and-devhub.md"
        }
    },
    {
        "id": "db-topology",
        "rel": "docs/db-profiles-and-topology.md",
        "titles": {
            "en": "🏗️ Database Profiles & Topology",
            "et": "🏗️ Andmebaasi profiilid ja topoloogia",
            "fi": "🏗️ Tietokantaprofiilit ja topologia",
            "sv": "🏗️ Databasprofiler och topologi",
            "lv": "🏗️ Datubāzu profili un topoloģija",
            "lt": "🏗️ Duomenų bazių profiliai ir topologija"
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
            "et": "📄 Oracle Forms 14c ja moderniseerimine",
            "fi": "📄 Oracle Forms 14c & modernisointi",
            "sv": "📄 Oracle Forms 14c & modernisering",
            "lv": "📄 Oracle Forms 14c un modernizācija",
            "lt": "📄 Oracle Forms 14c ir modernizavimas"
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
            "et": "📊 Analytics Publisher aruandlus",
            "fi": "📊 Analytics Publisher raportointi",
            "sv": "📊 Analytics Publisher rapportering",
            "lv": "📊 Analytics Publisher atskaites",
            "lt": "📊 Analytics Publisher ataskaitos"
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
        "id": "publisher-template-builder",
        "rel": "docs/publisher-template-builder-guide.md",
        "titles": {
            "en": "🎨 Publisher Template Builder & Accessibility Guide",
            "et": "🎨 Publisher malli kujundaja ja ligipääsetavuse juhend",
            "fi": "🎨 Publisher-mallinrakentaja & saavutettavuusopas",
            "sv": "🎨 Publisher mallbyggare & tillgänglighetsguide",
            "lv": "🎨 Publisher veidņu veidotājs & piekļūstamības rokasgrāmata",
            "lt": "🎨 Publisher šablonų kūrėjas ir prieinamumo gidas"
        },
        "files": {
            "en": "docs/publisher-template-builder-guide.md",
            "et": "docs/et/publisher-template-builder-guide.md",
            "fi": "docs/fi/publisher-template-builder-guide.md",
            "sv": "docs/sv/publisher-template-builder-guide.md",
            "lv": "docs/lv/publisher-template-builder-guide.md",
            "lt": "docs/lt/publisher-template-builder-guide.md"
        }
    },
    {
        "id": "security",
        "rel": "docs/security.md",
        "titles": {
            "en": "🔐 Security, TLS & SEPS Wallet",
            "et": "🔐 Turvalisus, TLS ja SEPS Wallet",
            "fi": "🔐 Tietoturva, TLS ja SEPS Wallet",
            "sv": "🔐 Säkerhet, TLS och SEPS Wallet",
            "lv": "🔐 Drošība, TLS un SEPS Wallet",
            "lt": "🔐 Saugumas, TLS ir SEPS Wallet"
        },
        "files": {
            "en": "docs/security.md",
            "et": "docs/et/security.md",
            "fi": "docs/fi/security.md",
            "sv": "docs/sv/security.md",
            "lv": "docs/lv/security.md",
            "lt": "docs/lt/security.md"
        }
    },
    {
        "id": "web-ide",
        "rel": "docs/web-ide-artifactory.md",
        "titles": {
            "en": "💻 Web IDE & Artifactory Setup",
            "et": "💻 Web IDE ja Artifactory seadistus",
            "fi": "💻 Web IDE & Artifactory -asennus",
            "sv": "💻 Web IDE och Artifactory",
            "lv": "💻 Web IDE un Artifactory",
            "lt": "💻 Web IDE ir Artifactory"
        },
        "files": {
            "en": "docs/web-ide-artifactory.md",
            "et": "docs/et/web-ide-artifactory.md",
            "fi": "docs/fi/web-ide-artifactory.md",
            "sv": "docs/sv/web-ide-artifactory.md",
            "lv": "docs/lv/web-ide-artifactory.md",
            "lt": "docs/lt/web-ide-artifactory.md"
        }
    },
    {
        "id": "apex-deploy",
        "rel": "docs/apex-apps-deployment.md",
        "titles": {
            "en": "📦 APEX Application CI/CD Deployment",
            "et": "📦 APEX rakenduste CI/CD tarne",
            "fi": "📦 APEX-sovellusten CI/CD -julkaisu",
            "sv": "📦 APEX applikation CI/CD deployment",
            "lv": "📦 APEX lietotņu CI/CD piegāde",
            "lt": "📦 APEX programų CI/CD diegimas"
        },
        "files": {
            "en": "docs/apex-apps-deployment.md",
            "et": "docs/et/apex-apps-deployment.md",
            "fi": "docs/fi/apex-apps-deployment.md",
            "sv": "docs/sv/apex-apps-deployment.md",
            "lv": "docs/lv/apex-apps-deployment.md",
            "lt": "docs/lt/apex-apps-deployment.md"
        }
    },
    {
        "id": "setup-workflow",
        "rel": "docs/setup-all-workflow.md",
        "titles": {
            "en": "⚡ Setup-All Architecture & Metrics",
            "et": "⚡ Setup-All arhitektuur ja mõõdikud",
            "fi": "⚡ Setup-All arkkitehtuuri ja mittarit",
            "sv": "⚡ Setup-All arkitektur och mätvärden",
            "lv": "⚡ Setup-All arhitektūra un metrika",
            "lt": "⚡ Setup-All architektūra ir metrika"
        },
        "files": {
            "en": "docs/setup-all-workflow.md",
            "et": "docs/et/setup-all-workflow.md",
            "fi": "docs/fi/setup-all-workflow.md",
            "sv": "docs/sv/setup-all-workflow.md",
            "lv": "docs/lv/setup-all-workflow.md",
            "lt": "docs/lt/setup-all-workflow.md"
        }
    },
    {
        "id": "future-plans",
        "rel": "docs/future-plans.md",
        "titles": {
            "en": "🚀 Future Architecture Roadmap",
            "et": "🚀 Tuleviku arhitektuurne teekaart",
            "fi": "🚀 Tulevaisuuden arkkitehtuurin tiekartta",
            "sv": "🚀 Framtida arkitektur färdplan",
            "lv": "🚀 Nākotnes arhitektūras ceļvedis",
            "lt": "🚀 Ateities architektūros gairės"
        },
        "files": {
            "en": "docs/future-plans.md",
            "et": "docs/et/future-plans.md",
            "fi": "docs/fi/future-plans.md",
            "sv": "docs/sv/future-plans.md",
            "lv": "docs/lv/future-plans.md",
            "lt": "docs/lt/future-plans.md"
        }
    },
    {
        "id": "forms-to-apex",
        "rel": "docs/forms-to-apex-migration-guide.md",
        "titles": {
            "en": "🚀 Forms-to-APEX Modernization Guide",
            "et": "🚀 Forms -> APEX moderniseerimise juhend",
            "fi": "🚀 Forms -> APEX modernisointiopas",
            "sv": "🚀 Forms -> APEX moderniseringsguide",
            "lv": "🚀 Forms -> APEX modernizācijas rokasgrāmata",
            "lt": "🚀 Forms -> APEX modernizavimo vadovas"
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
            "et": "📋 Arhitektuursete kavandite maatriks",
            "fi": "📋 Arkkitehtuurin blueprint-matriisi",
            "sv": "📋 Arkitektur blueprints matris",
            "lv": "📋 Arhitektūras plānu matrica",
            "lt": "📋 Architektūros planų matrica"
        },
        "files": {
            "en": "config/blueprints/README.md",
            "et": "config/blueprints/README.et.md",
            "fi": "config/blueprints/README.fi.md",
            "sv": "config/blueprints/README.sv.md",
            "lv": "config/blueprints/README.lv.md",
            "lt": "config/blueprints/README.lt.md"
        }
    },
    {
        "id": "devops-lifecycle",
        "rel": "docs/devops-lifecycle-guide.md",
        "titles": {
            "en": "🔄 3-Tier Lifecycle (Images, Snapshots, Backups)",
            "et": "🔄 3-tasemeline elutsükkel (pildid, hetktõmmised, varukoopiad)",
            "fi": "🔄 3-tasoinen elinkaari (kuvat, tilannekuvat, varmuuskopiot)",
            "sv": "🔄 3-nivåers livscykel (avbilder, ögonblicksbilder, säkerhetskopior)",
            "lv": "🔄 3 līmeņu dzīvescikls (attēli, momentuzņēmumi, dublējumi)",
            "lt": "🔄 3 lygmenų gyvavimo ciklas (atvaizdai, momentinės kopijos, atsarginės kopijos)"
        },
        "files": {
            "en": "docs/devops-lifecycle-guide.md",
            "et": "docs/et/devops-lifecycle-guide.md",
            "fi": "docs/fi/devops-lifecycle-guide.md",
            "sv": "docs/sv/devops-lifecycle-guide.md",
            "lv": "docs/lv/devops-lifecycle-guide.md",
            "lt": "docs/lt/devops-lifecycle-guide.md"
        }
    },
    {
        "id": "image-switching",
        "rel": "docs/database-image-switching-guide.md",
        "titles": {
            "en": "🔄 Database Image Switching & Multi-Vendor Guide",
            "et": "🔄 Andmebaasi konteineripiltide vahetamine & tarnijad",
            "fi": "🔄 Tietokantakonttikuvien vaihto ja monitoimittajaopas",
            "sv": "🔄 Byte av databascontaineravbilder och flerleverantörsguide",
            "lv": "🔄 Datubāzes konteineru attēlu pārslēgšanas ceļvedis",
            "lt": "🔄 Duomenų bazės konteinerių paveikslėlių keitimo vadovas"
        },
        "files": {
            "en": "docs/database-image-switching-guide.md",
            "et": "docs/et/database-image-switching-guide.md",
            "fi": "docs/fi/database-image-switching-guide.md",
            "sv": "docs/sv/database-image-switching-guide.md",
            "lv": "docs/lv/database-image-switching-guide.md",
            "lt": "docs/lt/database-image-switching-guide.md"
        }
    },
    {
        "id": "security-audit",
        "rel": "docs/security-audit-report.md",
        "titles": {
            "en": "🛡️ Enterprise Security Audit & Hardening Report",
            "et": "🛡️ Ettevõtteklassi turvaauditi aruanne & hardening",
            "fi": "🛡️ Yritystason tietoturva-auditin raportti",
            "sv": "🛡️ Företagsklassad säkerhetsrevisionsrapport",
            "lv": "🛡️ Uzņēmuma drošības audita ziņojums",
            "lt": "🛡️ Įmonių saugumo audito ataskaita"
        },
        "files": {
            "en": "docs/security-audit-report.md",
            "et": "docs/et/security-audit-report.md",
            "fi": "docs/fi/security-audit-report.md",
            "sv": "docs/sv/security-audit-report.md",
            "lv": "docs/lv/security-audit-report.md",
            "lt": "docs/lt/security-audit-report.md"
        }
    },
    {
        "id": "enterprise-architecture",
        "rel": "docs/enterprise-distributed-architecture.md",
        "titles": {
            "en": "🏛️ Enterprise Distributed 4-Host Architecture & HA",
            "et": "🏛️ Ettevõtteklassi hajutatud 4-serveriline arhitektuur",
            "fi": "🏛️ Yritystason hajautettu 4-palvelimen arkkitehtuuri",
            "sv": "🏛️ Företagsklassad distribuerad 4-server arkitektur",
            "lv": "🏛️ Sadalītā 4 resursdatoru arhitektūra & HA",
            "lt": "🏛️ Įmonių paskirstyta 4 mazgų architektūra & HA"
        },
        "files": {
            "en": "docs/enterprise-distributed-architecture.md",
            "et": "docs/et/enterprise-distributed-architecture.md",
            "fi": "docs/fi/enterprise-distributed-architecture.md",
            "sv": "docs/sv/enterprise-distributed-architecture.md",
            "lv": "docs/lv/enterprise-distributed-architecture.md",
            "lt": "docs/lt/enterprise-distributed-architecture.md"
        }
    },
    {
        "id": "glossary",
        "rel": "docs/glossary.md",
        "titles": {
            "en": "📖 Architecture Glossary & Acronyms",
            "et": "📖 Arhitektuurne sõnastik ja akronüümid",
            "fi": "📖 Arkkitehtuurisanasto ja akronyymit",
            "sv": "📖 Arkitekturordlista och akronymer",
            "lv": "📖 Arhitektūras vārdnīca un akronīmi",
            "lt": "📖 Architektūros žodynas ir akronimai"
        },
        "files": {
            "en": "docs/glossary.md",
            "et": "docs/et/glossary.md",
            "fi": "docs/fi/glossary.md",
            "sv": "docs/sv/glossary.md",
            "lv": "docs/lv/glossary.md",
            "lt": "docs/lt/glossary.md"
        }
    },
    {
        "id": "faq",
        "rel": "docs/faq.md",
        "titles": {
            "en": "❓ Frequently Asked Questions (FAQ)",
            "et": "❓ Korduma kippuvad küsimused (KKK)",
            "fi": "❓ Usein kysytyt kysymykset (UKK)",
            "sv": "❓ Vanliga frågor och svar (FAQ)",
            "lv": "❓ Biežāk uzdotie jautājumi (BUJ)",
            "lt": "❓ Dažniausiai užduodami klausimai (DUK)"
        },
        "files": {
            "en": "docs/faq.md",
            "et": "docs/et/faq.md",
            "fi": "docs/fi/faq.md",
            "sv": "docs/sv/faq.md",
            "lv": "docs/lv/faq.md",
            "lt": "docs/lt/faq.md"
        }
    },
    {
        "id": "oracle-resources",
        "rel": "docs/oracle-resources-and-downloads.md",
        "titles": {
            "en": "🏛️ Oracle Resources & Container Images",
            "et": "🏛️ Oracle ressursid ja konteineritõmmised",
            "fi": "🏛️ Oracle-resurssit ja konttikuvat",
            "sv": "🏛️ Oracle-resurser och containeravbildningar",
            "lv": "🏛️ Oracle resursi un konteineru attēli",
            "lt": "🏛️ Oracle ištekliai ir konteinerių atvaizdai"
        },
        "files": {
            "en": "docs/oracle-resources-and-downloads.md",
            "et": "docs/et/oracle-resources-and-downloads.md",
            "fi": "docs/fi/oracle-resources-and-downloads.md",
            "sv": "docs/sv/oracle-resources-and-downloads.md",
            "lv": "docs/lv/oracle-resources-and-downloads.md",
            "lt": "docs/lt/oracle-resources-and-downloads.md"
        }
    }
]

# 2. Blueprints Catalog with Multilingual Metadata (12 Canonical Models 0..11)

BP_CATALOG = {
    0: {
        "cat": "core", "ram": "2-3 GB", "conts": "db-proxy, ords/proxy",
        "en": ("Default Proxy DB & ORDS Gateway", "Canonical system default: dedicated Proxy DB 23ai Free on port 1532 with ORDS REST gateway on port 8448/8088."),
        "et": ("Vaikimisi Proxy DB & ORDS lüüs", "Süsteemi kanooniline vaikekonfiguratsioon: pühendatud Proxy DB 23ai Free pordil 1532 ja ORDS lüüs pordil 8448/8088."),
        "fi": ("Oletus-Proxy DB & ORDS -yhdyskäytävä", "Järjestelmän oletusarkkitehtuuri: Proxy DB 23ai Free portissa 1532 ja ORDS portissa 8448/8088."),
        "sv": ("Standard Proxy DB & ORDS gateway", "Systemets standardkonfiguration: dedikerad Proxy DB 23ai Free på port 1532 med ORDS på port 8448/8088."),
        "lv": ("Noklusējuma Proxy DB & ORDS vārteja", "Sistēmas noklusējuma arhitektūra: Proxy DB 23ai Free portā 1532 un ORDS portā 8448/8088."),
        "lt": ("Numatytoji Proxy DB & ORDS šliuzas", "Sistemos numatytoji architektūra: Proxy DB 23ai Free prievade 1532 ir ORDS prievade 8448/8088.")
    },
    1: {
        "cat": "database", "ram": "2-3 GB", "conts": "db-alise, ords/alise",
        "en": ("Standalone ALISE Business Database", "Dedicated custom application database holding business schemas, PL/SQL code, DDL/DML, and internal APEX/ORDS on port 1533."),
        "et": ("Eraldiseisev ALISE äriandmebaas", "Äriandmete, kohandatud skeemide, PL/SQL koodi ja DDL/DML andmebaas pordil 1533 koos sisemise APEX & ORDS toega."),
        "fi": ("Erillinen ALISE-liiketoimintatietokanta", "Erillinen sovellustietokanta liiketoimintaskeemoille ja PL/SQL-koodille portissa 1533 sisäisellä APEX/ORDS:lla."),
        "sv": ("Fristående ALISE affärsdatabas", "Dedikerad applikationsdatabas för affärsscheman och PL/SQL-kod på port 1533 med intern APEX/ORDS."),
        "lv": ("Atsevišķa ALISE biznesa datubāze", "Pielāgota lietojumprogrammu datubāze biznesa shēmām un PL/SQL kodam portā 1533 ar iekšējo APEX/ORDS."),
        "lt": ("Atskira ALISE verslo duomenų bazė", "Skirta taikomoji duomenų bazė verslo schemoms ir PL/SQL kodui prievade 1533 su vidiniu APEX/ORDS.")
    },
    2: {
        "cat": "database", "ram": "2-3 GB", "conts": "db-proxy-standalone, ords/proxy_standalone",
        "en": ("Standalone APEX Proxy DB & SSO Gateway", "APEX Proxy database on isolated port 1537 acting as external security gateway (REST API, Azure Entra ID, Kafka) with ORDS."),
        "et": ("Eraldiseisev Proxy DB & APEX SSO", "Isoleeritud pordil 1537 töötav APEX Proxy andmebaas, mis toimib välisühenduste ja autentimise turvaväravana koos ORDS-iga."),
        "fi": ("Erillinen Proxy DB & APEX SSO", "Eristetyssä portissa 1537 toimiva APEX Proxy -tietokanta, joka toimii ulkoisena tietoturvayhdyskäytävänä ORDS:n kera."),
        "sv": ("Fristående Proxy DB & APEX SSO", "APEX Proxy-databas på isolerad port 1537 som fungerar som extern säkerhetsgateway med ORDS."),
        "lv": ("Atsevišķa Proxy DB & APEX SSO", "APEX Proxy datubāze izolētā portā 1537, kas darbojas kā ārējā drošības vārteja ar ORDS."),
        "lt": ("Atskira Proxy DB & APEX SSO", "APEX Proxy duomenų bazė izoliuotame prievade 1537, veikianti kaip išorinis saugumo šliuzas su ORDS.")
    },
    3: {
        "cat": "database", "ram": "2-3 GB", "conts": "db-gvenzl, ords/gvenzl",
        "en": ("Standalone Community Vendor DB (gvenzl)", "Standalone APEX & ORDS database on Docker Hub community container image (gvenzl/oracle-free) on port 1535 for performance and patch benchmarking."),
        "et": ("Alternatiivne kogukonna baas (gvenzl)", "APEX ja ORDS andmebaas Docker Hubi kogukonnapildi (gvenzl/oracle-free) baasil pordil 1535 kiiruse ja turvapaikade võrdlemiseks."),
        "fi": ("Vaihtoehtoinen yhteisötietokanta (gvenzl)", "APEX- ja ORDS-tietokanta Docker Hubin yhteisökuvalla (gvenzl/oracle-free) portissa 1535 suorituskyvyn vertailuun."),
        "sv": ("Alternativ community-databas (gvenzl)", "Fristående APEX & ORDS-databas på Docker Hub community-avbild (gvenzl/oracle-free) på port 1535 för prestandajämförelse."),
        "lv": ("Alternatīva kopienas datubāze (gvenzl)", "Atsevišķa APEX un ORDS datubāze uz Docker Hub kopienas attēla (gvenzl/oracle-free) portā 1535 veiktspējas salīdzināšanai."),
        "lt": ("Alternatyvi bendruomenės DB (gvenzl)", "Atskira APEX ir ORDS duomenų bazė Docker Hub bendruomenės atvaizde (gvenzl/oracle-free) prievade 1535 našumo palyginimui.")
    },
    4: {
        "cat": "database", "ram": "1-2 GB", "conts": "db-adb, ords/adb",
        "en": ("Oracle Autonomous Database Cloud (ADB)", "Autonomous Database Cloud connectivity on simulated port 1536 leveraging encrypted mTLS SEPS client wallets."),
        "et": ("Autonoomne pilvebaas (Oracle ADB)", "Oracle Autonomous Database pilveühendus pordil 1536 krüpteeritud mTLS kliendi SEPS Walletiga."),
        "fi": ("Autonominen pilvitietokanta (Oracle ADB)", "Oracle Autonomous Database -pilviyhteys portissa 1536 salatulla mTLS SEPS Walletilla."),
        "sv": ("Autonom molndatabas (Oracle ADB)", "Oracle Autonomous Database molnanslutning på port 1536 med krypterad mTLS SEPS Wallet."),
        "lv": ("Autonoma mākoņdatubāze (Oracle ADB)", "Oracle Autonomous Database mākoņa savienojums portā 1536 ar šifrētu mTLS SEPS maku."),
        "lt": ("Autonominė debesų DB (Oracle ADB)", "Oracle Autonomous Database debesų ryšys prievade 1536 su šifruota mTLS SEPS pinigine.")
    },
    5: {
        "cat": "middleware", "ram": "3-5 GB", "conts": "db-publisher, app-publisher",
        "en": ("Standalone Analytics Publisher", "Oracle Analytics Publisher (Pixel-Perfect) on port 9502 with dedicated RCU infrastructure database on port 1531."),
        "et": ("Eraldiseisev Analytics Publisher", "Oracle Analytics Publisher (Pixel-Perfect) pordil 9502 koos spetsiaalse RCU taristu andmebaasiga pordil 1531."),
        "fi": ("Erillinen Analytics Publisher", "Oracle Analytics Publisher (Pixel-Perfect) portissa 9502 erillisellä RCU-tietokannalla portissa 1531."),
        "sv": ("Fristående Analytics Publisher", "Oracle Analytics Publisher (Pixel-Perfect) på port 9502 med dedikerad RCU-databas på port 1531."),
        "lv": ("Atsevišķs Analytics Publisher", "Oracle Analytics Publisher (Pixel-Perfect) portā 9502 ar atsevišķu RCU datubāzi portā 1531."),
        "lt": ("Atskirasis Analytics Publisher", "Oracle Analytics Publisher (Pixel-Perfect) prievade 9502 su atskira RCU duomenų baze prievade 1531.")
    },
    6: {
        "cat": "middleware", "ram": "3-5 GB", "conts": "db-forms, app-forms",
        "en": ("Standalone Oracle Forms 14c", "Oracle Forms 14c WebLogic runtime (port 9001) and HTML5 noVNC Forms Builder GUI (port 6082) with dedicated Forms RCU database on port 1534."),
        "et": ("Eraldiseisev Oracle Forms 14c", "Oracle Forms 14c WebLogic käituskeskkond (port 9001) ja HTML5 noVNC Forms Builder (port 6082) koos Forms RCU baasiga pordil 1534."),
        "fi": ("Erillinen Oracle Forms 14c", "Oracle Forms 14c WebLogic -palvelu (portti 9001) ja HTML5 noVNC Forms Builder (portti 6082) Forms RCU -tietokannalla portissa 1534."),
        "sv": ("Fristående Oracle Forms 14c", "Oracle Forms 14c WebLogic runtime (port 9001) och HTML5 noVNC Forms Builder (port 6082) med Forms RCU-databas på port 1534."),
        "lv": ("Atsevišķs Oracle Forms 14c", "Oracle Forms 14c WebLogic izpildvide (ports 9001) un HTML5 noVNC Forms Builder (ports 6082) ar Forms RCU datubāzi portā 1534."),
        "lt": ("Atskirasis Oracle Forms 14c", "Oracle Forms 14c WebLogic vykdymo aplinka (prievadas 9001) ir HTML5 noVNC Forms Builder (prievadas 6082) su Forms RCU duomenų baze prievade 1534.")
    },
    7: {
        "cat": "middleware", "ram": "4-5 GB", "conts": "db-forms-publisher, app-forms-publisher",
        "en": ("Consolidated Forms 14c + Publisher FMW", "Forms 14c and Analytics Publisher combined inside a unified WebLogic domain with shared 23ai DB (db-forms-publisher :1538), saving ~2.5 GB RAM."),
        "et": ("Konsolideeritud Forms + Publisher FMW", "Forms 14c ja Analytics Publisher ühendatud ühte WebLogic domeeni koos ühise 23ai andmebaasiga (db-forms-publisher :1538), säästes ~2.5 GB RAM-i."),
        "fi": ("Yhdistetty Forms + Publisher FMW", "Forms 14c ja Analytics Publisher yhdistettynä yhteen WebLogic-toimialueeseen yhteisellä 23ai-tietokannalla (db-forms-publisher :1538) (~2.5 GB RAM-säästö)."),
        "sv": ("Konsoliderad Forms + Publisher FMW", "Forms 14c och Analytics Publisher samlat i en gemensam WebLogic-domän med delad 23ai DB (db-forms-publisher :1538) (sparar ~2.5 GB RAM)."),
        "lv": ("Konsolidēts Forms + Publisher FMW", "Forms 14c un Analytics Publisher apvienoti vienā WebLogic domēnā ar kopēju 23ai DB (db-forms-publisher :1538) (ietaupa ~2.5 GB RAM)."),
        "lt": ("Konsoliduotas Forms + Publisher FMW", "Forms 14c ir Analytics Publisher sujungti į bendrą WebLogic domeną su bendra 23ai DB (db-forms-publisher :1538) (sutaupo ~2.5 GB RAM).")
    },
    8: {
        "cat": "developer", "ram": "1-2 GB", "conts": "web-ide-dev", "testing": False,
        "en": ("Standalone Web-IDE Workstation", "VS Code server & Oracle SQL Developer for VS Code are fully functional on port 8090."),
        "et": ("Iseseisev Web-IDE arendustöökoht", "VS Code veebiserver ja Oracle SQL Developer laiendus töötavad pordil 8090."),
        "fi": ("Erillinen Web-IDE -kehitystyöasema", "VS Code -verkkopalvelin ja Oracle SQL Developer -laajennus toimivat portissa 8090."),
        "sv": ("Fristående Web-IDE arbetsstation", "VS Code webbserver och Oracle SQL Developer-tillägget fungerar på port 8090."),
        "lv": ("Atsevišķa Web-IDE izstrādes darbstacija", "VS Code tīmekļa serveris un Oracle SQL Developer paplašinājums darbojas portā 8090."),
        "lt": ("Atskira Web-IDE kūrimo darbo vieta", "VS Code žiniatinklio serveris ir Oracle SQL Developer plėtinys veikia prievade 8090.")
    },
    9: {
        "cat": "developer", "ram": "1-2 GB", "conts": "app-publisher-designer", "testing": False,
        "en": ("Standalone Publisher Template Designer", "HTML5 noVNC desktop container on port 6083 with LibreOffice Writer 3-Pane Studio (Primary SSoT), Evince live PDF viewer & XML Field Inspector. Optional: MS Word & BIP Add-In via Wine."),
        "et": ("Publisher malli kujundaja", "HTML5 noVNC töölaua konteiner pordil 6083: LibreOffice Writer 3-aknaga stuudio (esmane SSoT), Evince live PDF vaatur ja XML inspektor. Valikuline: MS Word ja BIP lisandmoodul Wine'i kaudu."),
        "fi": ("Publisher-mallisuunnittelija", "HTML5 noVNC -työpöytäkontti portissa 6083: LibreOffice Writer 3-ikkunainen studio (ensisijainen SSoT), Evince live PDF -katselin ja XML-kenttäinspektori. Valinnainen: MS Word Wine-tilassa."),
        "sv": ("Publisher mallbyggare", "HTML5 noVNC-skrivbordsbehållare på port 6083: LibreOffice Writer 3-Pane Studio (primär SSoT), Evince live PDF-läsare och XML-inspektör. Valfritt: MS Word & BIP via Wine."),
        "lv": ("Publisher veidņu veidotājs", "HTML5 noVNC darbvirsmas konteiners portā 6083: LibreOffice Writer 3 logu studija (primārais SSoT), Evince live PDF skatītājs un XML lauku inspektors. Neobligāti: MS Word caur Wine."),
        "lt": ("Publisher šablonų kūrėjas", "HTML5 noVNC darbalaukio konteineris prievade 6083: LibreOffice Writer 3 langų studija (pirminis SSoT), Evince live PDF peržiūra ir XML inspektorius. Pasirinktinai: MS Word per Wine.")
    },
    10: {
        "cat": "gateway", "ram": "1 GB", "conts": "app-ords", "testing": True,
        "en": ("Remote ORDS Gateway & Edge Proxy (Testing / In Progress)", "Standalone ORDS HTTP/HTTPS gateway container boots on port 8088/8448. Note: In testing & refinement — edge proxy routing and live connectivity to remote cloud/enterprise databases is under active development."),
        "et": ("Kaughaldus ORDS lüüs & edge proxy (testimisel / täiustamisel)", "Iseseisev ORDS HTTP/HTTPS konteiner käivitub pordil 8088/8448. Märkus: Testimisel ja täiustamisel — väline lüüs ja ühendus kauge pilve- või serveriandmebaasidega on aktiivses arenduses ja kontrollimisel."),
        "fi": ("Etä-ORDS-yhdyskäytävä & edge proxy (testauksessa / kehitteillä)", "Erillinen ORDS HTTP/HTTPS -kontti käynnistyy portissa 8088/8448. Huomautus: Testauksessa ja kehitteillä — yhdyskäytävän reititys etätietokantoihin on aktiivisessa kehityksessä."),
        "sv": ("Fjärr-ORDS gateway & edge proxy (under testning / utveckling)", "Fristående ORDS HTTP/HTTPS-behållare startar på port 8088/8448. Obs: Under testning och utveckling — gateway-dirigering mot fjärr- och molndatabaser är under aktiv utveckling."),
        "lv": ("Attālā ORDS vārteja & edge proxy (testēšanā / izstrādē)", "Atsevišķs ORDS HTTP/HTTPS konteiners startējas portā 8088/8448. Piezīme: Testēšanā un izstrādē — vārtejas maršrutēšana uz attālajām datubāzēm tiek aktīvi pilnveidota."),
        "lt": ("Nuotolinis ORDS šliuzas & edge proxy (testuojama / tobulinama)", "Atskiras ORDS HTTP/HTTPS konteineris pasileidžia prievade 8088/8448. Pastaba: Testuojama ir tobulinama — šliuzo maršrutizavimas į nuotolines duomenų bazes yra tobulinamas.")
    },
    11: {
        "cat": "gateway", "ram": "3-4 GB", "conts": "app-publisher", "testing": True,
        "en": ("Remote Analytics Publisher Server (Testing / In Progress)", "Analytics Publisher container boots on port 9502. Note: In testing & refinement — document report generation against remote enterprise databases without local DB is under active development."),
        "et": ("Kaughaldus Analytics Publisher server (testimisel / täiustamisel)", "Analytics Publisher konteiner käivitub pordil 9502. Märkus: Testimisel ja täiustamisel — aruannete genereerimine kaugete ettevõtte andmebaaside vastu ilma kohaliku baasita on aktiivses arenduses ja kontrollimisel."),
        "fi": ("Etä-Analytics Publisher -palvelin (testauksessa / kehitteillä)", "Analytics Publisher -kontti käynnistyy portissa 9502. Huomautus: Testauksessa ja kehitteillä — raporttien generointi etätietokantoja vasten ilman paikallista DB:tä on kehitteillä."),
        "sv": ("Fjärr-Analytics Publisher server (under testning / utveckling)", "Analytics Publisher-behållaren startar på port 9502. Obs: Under testning och utveckling — rapportgenerering mot fjärrdatabaser utan lokal databas är under aktiv utveckling."),
        "lv": ("Attālais Analytics Publisher serveris (testēšanā / izstrādē)", "Analytics Publisher konteiners startējas portā 9502. Piezīme: Testēšanā un izstrādē — atskaišu ģenerēšana attālām datubāzēm bez lokālas DB tiek aktīvi pilnveidota."),
        "lt": ("Nuotolinis Analytics Publisher serveris (testuojama / tobulinama)", "Analytics Publisher konteineris pasileidžia prievade 9502. Pastaba: Testuojama ir tobulinama — ataskaitų generavimas nuotolinėms duomenų bazėms be vietinės DB yra tobulinamas.")
    }
}

try:
    from .bp_metadata import BP_EXT_METADATA
except (ImportError, ValueError):
    try:
        from dev_hub.bp_metadata import BP_EXT_METADATA
    except (ImportError, ValueError):
        import sys, os
        _cur_dir = os.path.dirname(os.path.abspath(__file__))
        if _cur_dir not in sys.path:
            sys.path.insert(0, _cur_dir)
        from bp_metadata import BP_EXT_METADATA

for _bnum, _ext in BP_EXT_METADATA.items():
    if _bnum in BP_CATALOG:
        BP_CATALOG[_bnum].update(_ext)

# Helper to load a YAML profile from any subfolder and return dict + rel_path

BP_COLOR_THEMES = {
    0: {"icon": "🛡️", "color": "#38bdf8", "border": "rgba(56,189,248,0.4)"},
    1: {"icon": "🏢", "color": "#22c55e", "border": "rgba(34,197,94,0.4)"},
    2: {"icon": "🔐", "color": "#818cf8", "border": "rgba(129,140,248,0.4)"},
    3: {"icon": "🐬", "color": "#0284c7", "border": "rgba(2,132,199,0.4)"},
    4: {"icon": "☁️", "color": "#f59e0b", "border": "rgba(245,158,11,0.4)"},
    5: {"icon": "📑", "color": "#fb923c", "border": "rgba(251,146,60,0.4)"},
    6: {"icon": "📐", "color": "#10b981", "border": "rgba(16,185,129,0.4)"},
    7: {"icon": "🏛️", "color": "#c084fc", "border": "rgba(192,132,252,0.4)"},
    8: {"icon": "💻", "color": "#a855f7", "border": "rgba(168,85,247,0.4)"},
    9: {"icon": "🎨", "color": "#f472b6", "border": "rgba(244,114,182,0.4)"},
    10: {"icon": "🌐", "color": "#06b6d4", "border": "rgba(6,182,212,0.4)"},
    11: {"icon": "📡", "color": "#f87171", "border": "rgba(248,113,113,0.4)"}
}

SLIDES_CONTENT = {   1: {   'badge': {   'en': '🌟 SLIDE 1 / 13 • VISION &amp; STRATEGY',
                        'et': '🌟 SLAID 1 / 13 • VISIOON JA STRATEEGIA',
                        'fi': '🌟 DIA 1 / 13 • VISIO &amp; STRATEGIA',
                        'sv': '🌟 BILD 1 / 13 • VISION &amp; STRATEGI',
                        'lv': '🌟 SLAIDS 1 / 13 • VĪZIJA &amp; STRATĒĢIJA',
                        'lt': '🌟 SKAIDRĖ 1 / 13 • VIZIJA IR STRATEGIJA'},
           'title': {   'en': 'Oracle DevOps Platform for Local &amp; Remote Environments',
                        'et': 'Oracle DevOps platvorm lokaalsetele ja serverkeskkondadele',
                        'fi': 'Oracle DevOps -alusta paikallisille ja palvelinympäristöille',
                        'sv': 'Oracle DevOps-plattform för lokala och fjärrmiljöer',
                        'lv': 'Oracle DevOps platforma lokālajām un attālajām vidēm',
                        'lt': 'Oracle DevOps platforma vietinėms ir nuotolinėms aplinkoms'},
           'lead': {   'en': 'Modern, cost-effective, and enterprise-grade Oracle ecosystem with visual GUI management '
                             'and complete offline autonomy.',
                       'et': 'Tänapäevane, kulusäästlik ja enterprise-tasemel Oracle ökosüsteem koos visuaalse '
                             'juhtpaneeli ja täieliku võrguühenduseta tööga.',
                       'fi': 'Nykyaikainen, kustannustehokas ja yritystason Oracle-ekosysteemi visuaalisella '
                             'hallinnalla ja täydellä offline-työllä.',
                       'sv': 'Ett modernt, kostnadseffektivt och företagsklassat Oracle-ekosystem med grafisk '
                             'hantering och full offline-autonomi.',
                       'lv': 'Mūsdienīga, rentabla un uzņēmuma līmeņa Oracle ekosistēma ar vizuālu vadības paneli un '
                             'pilnīgu bezsaistes autonomiju.',
                       'lt': 'Šiuolaikiška, ekonomiška ir įmonės lygio Oracle ekosistema su vizualiu valdymo skydeliu '
                             'ir visišku darbu neprisijungus.'},
           'cards': [   {   'icon': '⚡',
                            'kpi': '1 KÄSK / 0€',
                            'title': {   'en': '1-Click Launch &amp; GUI Management',
                                         'et': '1-klikiga käivitus ja graafiline haldus',
                                         'fi': '1-klikkauksen käynnistys ja hallinta',
                                         'sv': '1-klicks start och grafisk hantering',
                                         'lv': '1-klikšķa palaišana un vadība',
                                         'lt': '1-paspaudimo paleidimas ir valdymas'},
                            'desc': {   'en': 'Single command (<code>./scripts/setup-all.sh</code>) or web UI '
                                              'configures Oracle 23ai databases, APEX 26.1, ORDS, and SEPS Wallet.',
                                        'et': 'Üksainus käsk (<code>./scripts/setup-all.sh</code>) või graafiline Dev '
                                              'Hub seadistab Oracle 23ai baasid, APEX 26.1, ORDS-i ja SEPS Walleti.',
                                        'fi': 'Yksi komento (<code>./scripts/setup-all.sh</code>) tai Dev Hub asentaa '
                                              'automaattisesti Oracle 23ai -kannat, APEX 26.1:n ja ORDS:n.',
                                        'sv': 'Ett enda kommando (<code>./scripts/setup-all.sh</code>) eller Dev Hub '
                                              'konfigurerar Oracle 23ai-databaser, APEX 26.1 och ORDS.',
                                        'lv': 'Viena komanda (<code>./scripts/setup-all.sh</code>) vai Dev Hub iestata '
                                              'Oracle 23ai datubāzes, APEX 26.1, ORDS un maku.',
                                        'lt': 'Viena komanda (<code>./scripts/setup-all.sh</code>) arba Dev Hub '
                                              'sukonfigūruoja Oracle 23ai duomenų bazes, APEX 26.1 ir ORDS.'},
                            'command': './scripts/setup-all.sh'},
                        {   'icon': '🎯',
                            'kpi': '100% OFFLINE',
                            'title': {   'en': 'Convenient, Flexible &amp; Offline',
                                         'et': 'Mugav, paindlik ja võrguühenduseta',
                                         'fi': 'Kätevä, joustava ja offline-valmis',
                                         'sv': 'Bekväm, flexibel och offline-redo',
                                         'lv': 'Ērta, elastīga un bezsaistē gatava',
                                         'lt': 'Patogi, lanksti ir pritaikyta darbui be interneto'},
                            'desc': {   'en': 'Full GUI management via Dev Hub. Operates locally without corporate VPN '
                                              'on laptops, airplanes, and remote servers.',
                                        'et': 'Käivitamiseks ja haldamiseks on graafiline liides (Dev Hub). Töötab '
                                              'lokaalses arvutis ka 100% võrguühenduseta ilma VPN-ita.',
                                        'fi': 'Graafinen hallintaliittymä Dev Hubilla. Toimii paikallisesti täysin '
                                              'ilman yrityksen VPN-yhteyttä myös matkoilla.',
                                        'sv': 'Grafiskt gränssnitt via Dev Hub. Fungerar lokalt helt utan företags-VPN '
                                              'på bärbara datorer och servrar.',
                                        'lv': 'Grafiskais vadības panelis Dev Hub. Darbojas lokāli pilnīgi bez '
                                              'uzņēmuma VPN datoros un serveros.',
                                        'lt': 'Grafinė sąsaja per Dev Hub. Veikia vietiškai visiškai be įmonės VPN '
                                              'kompiuteriuose ir serveriuose.'}},
                        {   'icon': '🛡️',
                            'kpi': 'ZERO-TRUST',
                            'title': {   'en': 'Resilient, Zero-Trust &amp; Production-Ready',
                                         'et': 'Töökindel, turvaline ja toodanguvalmis',
                                         'fi': 'Luotettava, turvallinen ja tuotantovalmis',
                                         'sv': 'Pålitlig, säker och produktionsredo',
                                         'lv': 'Uzticama, droša un gatava ražošanai',
                                         'lt': 'Patikima, saugi ir paruošta gamybai'},
                            'desc': {   'en': 'Zero-Trust architecture: SEPS Auto-Login Wallet, Podman Secrets, and '
                                              'HTTPS/TLS. Security practiced early; enables Free DB in production for '
                                              'non-critical tools.',
                                        'et': 'Zero-Trust: SEPS Wallet, Podman Secrets ja HTTPS/TLS. Turvalisus veres '
                                              'juba maast madalast; võimaldab Free DB-d kasutada toodangus '
                                              'mittekriitilistele rakendustele.',
                                        'fi': 'Zero-Trust: SEPS Wallet, Podman Secrets ja HTTPS/TLS. Tietoturva '
                                              'selkärangassa alusta alkaen; mahdollistaa Free DB:n tuotannossa '
                                              'sisäisille työkaluille.',
                                        'sv': 'Zero-Trust: SEPS Wallet, Podman Secrets och HTTPS/TLS. Säkerhet från '
                                              'grunden; möjliggör Free DB i produktion för icke-kritiska interna '
                                              'verktyg.',
                                        'lv': 'Zero-Trust: SEPS Wallet, Podman Secrets un HTTPS/TLS. Drošība asinīs '
                                              'jau no paša sākuma; ļauj izmantot Free DB ražošanā iekšējām lietotnēm.',
                                        'lt': 'Zero-Trust: SEPS Wallet, Podman Secrets ir HTTPS/TLS. Saugumas nuo pat '
                                              'pradžių; leidžia naudoti Free DB gamyboje nekritinėms vidinėms '
                                              'programoms.'}}],
           'speaker_notes': {   'en': '🎯 Core Takeaway: Instant developer productivity with enterprise-grade security '
                                      'from day one without licensing friction.<br/>💡 Talking Points: Emphasize that '
                                      'Dev Hub provides a full GUI to manage containers and credentials. Point out '
                                      'that developers can work completely offline on airplanes or travel without '
                                      'VPN.<br/>⚠️ Key Emphasis: Highlight that security is practiced early so it '
                                      'becomes second nature; this minimizes risks and even allows running small '
                                      'non-critical production workloads on Free DB.',
                                'et': '🎯 Peamine sõnum: Kohene arendusvalmidus enterprise-turvalisusega esimesest '
                                      'minutist ilma litsentsibarjäärideta.<br/>💡 Esitaja rääkimispunktid: Rõhuta, et '
                                      'Dev Hub pakub täielikku graafilist liidest konteinerite ja paroolide '
                                      "haldamiseks. Töötab 100% offline'is lennukis või reisil ilma VPN-ita.<br/>⚠️ "
                                      'Mida rõhutada: Turvalisus peab olema veres juba maast madalast. Harjutades '
                                      'Zero-Trusti kohapeal, on toodangusse viimine sujuv ja Free DB sobib ka '
                                      'mittekriitilisteks siserakendusteks.',
                                'fi': '🎯 Pääviesti: Välitön kehittäjän tuottavuus yritystason tietoturvalla heti '
                                      'alusta alkaen ilman lisenssikuluja.<br/>💡 Puhujan muistiinpanot: Korosta, että '
                                      'Dev Hub tarjoaa visuaalisen käyttöliittymän konttien hallintaan. Kehittäjät '
                                      'voivat työskennellä täysin offline-tilassa ilman VPN-yhteyttä.<br/>⚠️ Tärkeä '
                                      'painotus: Tietoturva opitaan alusta alkaen; tämä minimoi riskit ja mahdollistaa '
                                      'Free DB:n hyödyntämisen tuotannossa kevyille sisäisille sovelluksille.',
                                'sv': '🎯 Huvudbudskap: Omedelbar produktivitet med företagssäkerhet från dag ett utan '
                                      'licenshinder.<br/>💡 Talarpunkter: Betona att Dev Hub erbjuder ett komplett '
                                      'grafiskt gränssnitt för att hantera containrar. Utvecklare kan arbeta offline '
                                      'på flyg utan VPN.<br/>⚠️ Vad som bör betonas: Säkerhet sitter i ryggmärgen från '
                                      'början; minimerar risker och gör det möjligt att köra icke-kritiska interna '
                                      'verktyg på Free DB i produktion.',
                                'lv': '🎯 Galvenais vēstījums: Tūlītēja izstrādātāja produktivitāte ar uzņēmuma līmeņa '
                                      'drošību bez licenču šķēršļiem.<br/>💡 Runātāja piezīmes: Uzsveriet, ka Dev Hub '
                                      'nodrošina pilnu grafisko saskarni. Izstrādātāji var strādāt bezsaistē bez '
                                      'uzņēmuma VPN.<br/>⚠️ Ko uzsvērt: Drošība tiek praktizēta jau izstrādē; tas '
                                      'novērš riskus un ļauj izmantot Free DB ražošanā iekšējiem rīkiem.',
                                'lt': '🎯 Pagrindinė žinutė: Momentinis programuotojų produktyvumas su įmonės lygio '
                                      'saugumu be licencijavimo kliūčių.<br/>💡 Pranešėjo pastabos: Pabrėžkite, kad Dev '
                                      'Hub suteikia pilną grafinę sąsają. Kūrėjai gali dirbti visiškai neprisijungę be '
                                      'įmonės VPN.<br/>⚠️ Ką akcentuoti: Saugumas įvaldomas nuo pat pradžių; tai '
                                      'sumažina rizikas ir leidžia naudoti Free DB gamyboje vidiniams įrankiams.'}},
    2: {   'badge': {   'en': '🛑 SLIDE 2 / 13 • PROBLEMS &amp; PAIN POINTS',
                        'et': '🛑 SLAID 2 / 13 • VALUPUNKTID JA PROBLEEMID',
                        'fi': '🛑 DIA 2 / 13 • KIPUPISTEET &amp; HAASTEET',
                        'sv': '🛑 BILD 2 / 13 • PROBLEM &amp; UTMANINGAR',
                        'lv': '🛑 SLAIDS 2 / 13 • PROBLĒMAS &amp; IZAICINĀJUMI',
                        'lt': '🛑 SKAIDRĖ 2 / 13 • PROBLEMOS IR IŠŠŪKIAI'},
           'title': {   'en': 'What Problems Are We Solving?',
                        'et': 'Millist probleemi me lahendame?',
                        'fi': 'Mitä ongelmia ratkaisemme?',
                        'sv': 'Vilka problem löser vi?',
                        'lv': 'Kādas problēmas mēs risinām?',
                        'lt': 'Kokias problemas sprendžiame?'},
           'lead': {   'en': 'Traditional Oracle dev and test environments are slow, fragile, costly, and bottlenecked '
                             'by inter-team tickets.',
                       'et': 'Traditsiooniline Oracle arendus- ja testkeskkondade haldus on aeglane, kallis ja tekitab '
                             'tiimide vahel pudelikaelu.',
                       'fi': 'Perinteinen Oracle-kehitysympäristöjen hallinta on hidasta, kallista ja tiimien välisten '
                             'riippuvuuksien tukkimaa.',
                       'sv': 'Traditionell Oracle-utveckling är långsam, ömtålig, kostsam och blockerad av beroenden '
                             'mellan team.',
                       'lv': 'Tradicionālā Oracle izstrādes un testa vide ir lēna, dārga un pakļauta komandu '
                             'savstarpējām atkarībām.',
                       'lt': 'Tradicinis Oracle kūrimo ir testavimo aplinkų valdymas yra lėtas, brangus ir ribojamas '
                             'komandų priklausomybių.'},
           'comparison_diagram': {   'bad': {   'label': {   'en': '❌ TRADITIONAL APPROACH (SLOW & FRAGILE)',
                                                             'et': '❌ VANA MUDEL (AEGLANE JA HAAVATAV)',
                                                             'fi': '❌ PERINTEINEN MALLI (HIDAS JA HAURAS)',
                                                             'sv': '❌ TRADITIONELL METOD (LÅNGSAM OCH ÖMTÅLIG)',
                                                             'lv': '❌ VECO LAIKU PIEEJA (LĒNA UN NESTABILA)',
                                                             'lt': '❌ TRADICINIS METODAS (LĖTAS IR NESTABILUS)'},
                                                'nodes': [   {   'icon': '🎫',
                                                                 'title': {   'en': 'Ticket to Service Provider',
                                                                              'et': 'Pilet teenuse pakkujale',
                                                                              'fi': 'Palvelupyyntö toimittajalle',
                                                                              'sv': 'Ärende till tjänsteleverantör',
                                                                              'lv': 'Pieteikums pakalpojumu sniedzējam',
                                                                              'lt': 'Užklausa paslaugų teikėjui'},
                                                                 'sub': {   'en': 'Waiting queue',
                                                                            'et': 'Ootejärjekord',
                                                                            'fi': 'Jonotus',
                                                                            'sv': 'Väntetid',
                                                                            'lv': 'Gaidīšanas rinda',
                                                                            'lt': 'Laukimo eilė'}},
                                                             {   'icon': '⏳',
                                                                 'title': {   'en': 'Wait Hours – Days',
                                                                              'et': 'Oota tunde – päevi',
                                                                              'fi': 'Odota tunteja – päiviä',
                                                                              'sv': 'Vänta timmar – dagar',
                                                                              'lv': 'Gaidi stundas – dienas',
                                                                              'lt': 'Laukite valandas – dienas'},
                                                                 'sub': {   'en': 'Blocked sprints',
                                                                            'et': 'Sprintid seisavad',
                                                                            'fi': 'Kehitys jumissa',
                                                                            'sv': 'Stoppade sprintar',
                                                                            'lv': 'Darbs apstājies',
                                                                            'lt': 'Sprintai sustoja'}},
                                                             {   'icon': '💥',
                                                                 'title': {   'en': 'Shared Crash',
                                                                              'et': 'Server maas',
                                                                              'fi': 'Kanta kaatunut',
                                                                              'sv': 'Kraschad server',
                                                                              'lv': 'Serveris avarē',
                                                                              'lt': 'Serveris užstrigo'},
                                                                 'sub': {   'en': 'Affects 10 devs',
                                                                            'et': 'Mõjutab 10 arendajat',
                                                                            'fi': 'Estää tiimin työn',
                                                                            'sv': 'Alla blockeras',
                                                                            'lv': 'Ietekmē 10 devus',
                                                                            'lt': 'Kliūtis visiems'}},
                                                             {   'icon': '🚫',
                                                                 'title': {   'en': 'Downtime',
                                                                              'et': 'Seisak',
                                                                              'fi': 'Kallista dynaamikaa',
                                                                              'sv': 'Driftstopp',
                                                                              'lv': 'Dīkstāve',
                                                                              'lt': 'Prastova'},
                                                                 'sub': {   'en': 'High TCO & delays',
                                                                            'et': 'Kõrge kulu ja viivitus',
                                                                            'fi': 'Korkeat kulut',
                                                                            'sv': 'Höga kostnader',
                                                                            'lv': 'Lieli zaudējumi',
                                                                            'lt': 'Didelės išlaidos'}},
                                                              {   'icon': '🤖',
                                                                  'title': {   'en': 'AI &amp; Agents Blocked',
                                                                               'et': 'AI ja agendid blokeeritud',
                                                                               'fi': 'Tekoäly ja agentit estetty',
                                                                               'sv': 'AI och agenter blockerade',
                                                                               'lv': 'AI un aģenti bloķēti',
                                                                               'lt': 'AI ir agentai blokuojami'},
                                                                  'sub': {   'en': 'No test sandbox',
                                                                             'et': 'Puudub testliivakast',
                                                                             'fi': 'Ei testiympäristöä',
                                                                             'sv': 'Ingen testmiljö',
                                                                             'lv': 'Nav testa smilškastes',
                                                                             'lt': 'Nėra testų bazės'}}]},
                                     'good': {   'label': {   'en': '✅ ORACLE DEVOPS PLATFORM (INSTANT & AUTONOMOUS)',
                                                              'et': '✅ UUS PLATVORM (KOHENE JA AUTONOOMNE)',
                                                              'fi': '✅ UUSI ALUSTA (VÄLITÖN JA AUTONOMINEN)',
                                                              'sv': '✅ NY PLATTFORM (OMEDELBAR OCH AUTONOM)',
                                                              'lv': '✅ JAUNĀ PLATFORMA (TŪLĪTĒJA UN AUTONOMA)',
                                                              'lt': '✅ NAUJA PLATFORMA (MOMENTINĖ IR AUTONOMIŠKA)'},
                                                 'nodes': [   {   'icon': '💻',
                                                                  'title': {   'en': 'Local Dev Hub',
                                                                               'et': 'Lokaalne Dev Hub',
                                                                               'fi': 'Paikallinen Dev Hub',
                                                                               'sv': 'Lokal Dev Hub',
                                                                               'lv': 'Lokālais Dev Hub',
                                                                               'lt': 'Vietinis Dev Hub'},
                                                                  'sub': {   'en': 'Full Web GUI',
                                                                             'et': 'Graafiline juhtpaneel',
                                                                             'fi': 'Visuaalinen hallinta',
                                                                             'sv': 'Fullständigt GUI',
                                                                             'lv': 'Pilna grafiskā vide',
                                                                             'lt': 'Pilna grafinė sąsaja'}},
                                                              {   'icon': '⚡',
                                                                  'title': {   'en': '1-Click Launch',
                                                                               'et': '1-klikk käivitus',
                                                                               'fi': '1-klikkauksen startti',
                                                                               'sv': '1-klicks start',
                                                                               'lv': '1-klikšķa starts',
                                                                               'lt': '1-paspaudimo startas'},
                                                                  'sub': {   'en': 'Minutes to run',
                                                                             'et': 'Valmis minutitega',
                                                                             'fi': 'Valmis minuuteissa',
                                                                             'sv': 'Klar på minuter',
                                                                             'lv': 'Gatavs minūtēs',
                                                                             'lt': 'Paruošta per min.'}},
                                                              {   'icon': '🔄',
                                                                  'title': {   'en': '1–2 Min Recovery',
                                                                               'et': '1–2 min taaste',
                                                                               'fi': '1–2 min palautus',
                                                                               'sv': '1–2 min återställning',
                                                                               'lv': '1–2 min atjaunošana',
                                                                               'lt': '1–2 min atkūrimas'},
                                                                  'sub': {   'en': 'Golden Snapshot',
                                                                             'et': 'Puhas algseis',
                                                                             'fi': 'Golden Snapshot',
                                                                             'sv': 'Golden Snapshot',
                                                                             'lv': 'Golden Snapshot',
                                                                             'lt': 'Golden Snapshot'}},
                                                              {   'icon': '🎯',
                                                                  'title': {   'en': '100% Autonomy',
                                                                               'et': '100% autonoomia',
                                                                               'fi': '100% autonomia',
                                                                               'sv': '100% autonomi',
                                                                               'lv': '100% autonomija',
                                                                               'lt': '100% autonomija'},
                                                                  'sub': {   'en': 'Zero tickets',
                                                                             'et': 'Piletivaba töö',
                                                                             'fi': 'Ilman lippuja',
                                                                             'sv': 'Inga ärenden',
                                                                             'lv': 'Bez pieteikumiem',
                                                                             'lt': 'Be bilietų'}},
                                                              {   'icon': '🤖',
                                                                  'title': {   'en': 'VS Code &amp; AI Sandbox',
                                                                               'et': 'VS Code ja AI liivakast',
                                                                               'fi': 'VS Code ja tekoäly-sandbox',
                                                                               'sv': 'VS Code &amp; AI Sandbox',
                                                                               'lv': 'VS Code un AI smilškaste',
                                                                               'lt': 'VS Code ir AI smėliadėžė'},
                                                                  'sub': {   'en': 'Automated agent tests',
                                                                             'et': 'Automaattestid agentidele',
                                                                             'fi': 'Automaattitestaus agenteille',
                                                                             'sv': 'Automatiserad agenttestning',
                                                                             'lv': 'Automatizēti aģentu testi',
                                                                             'lt': 'Automatiniai agentų testai'}}]}},
           'cards': [   {   'icon': '💥',
                            'kpi': '-85% SEISAKUID',
                            'title': {   'en': 'Fragile Shared Dev Databases',
                                         'et': 'Ebastabiilsed arenduskeskkonnad ja seisakud',
                                         'fi': 'Epävakaat jaetut kehitysympäristöt',
                                         'sv': 'Instabila delade utvecklingsdatabaser',
                                         'lv': 'Nestabilas koplietotās izstrādes datubāzes',
                                         'lt': 'Nestabilios bendros kūrimo duomenų bazės'},
                            'desc': {   'en': 'Shared central servers crash often, get locked by other developers, or '
                                              'require repetitive manual DBA recovery.',
                                        'et': 'Jagatud tsentraalsed serverid jooksevad tihti kokku, on teiste '
                                              'arendajate poolt lukustatud või vajavad käsitsi parandamist.',
                                        'fi': 'Jaetut palvelimet kaatuvat usein, ovat toisten lukitsemia tai vaativat '
                                              'jatkuvaa manuaalista DBA-korjausta.',
                                        'sv': 'Delade servrar kraschar ofta, låses av andra utvecklare eller kräver '
                                              'ständig manuell administration.',
                                        'lv': 'Koplietotie serveri bieži avarē, ir bloķēti vai prasa pastāvīgu manuālu '
                                              'administrēšanu.',
                                        'lt': 'Bendri serveriai dažnai stringa, yra užblokuoti kitų kūrėjų arba '
                                              'reikalauja nuolatinio rankinio taisymo.'}},
                        {   'icon': '📦',
                            'kpi': '1 KÄSK',
                            'title': {   'en': 'Publisher &amp; Forms Delivery Overhead',
                                         'et': 'Publisheri ja Formsi tarnimise keerukus',
                                         'fi': 'Publisherin ja Formsin toimitushaasteet',
                                         'sv': 'Komplexitet vid leverans av Publisher och Forms',
                                         'lv': 'Publisher un Forms piegādes sarežģītība',
                                         'lt': 'Publisher ir Forms diegimo sudėtingumas'},
                            'desc': {   'en': 'Installing, patching, and maintaining WebLogic, Publisher, and Forms '
                                              '14c in remote environments is painful.',
                                        'et': 'Analytics Publisheri ja Oracle Formsi paigaldamine, patchimine ja '
                                              'kataloogide haldamine remote keskkondades on äärmiselt töömahukas.',
                                        'fi': 'Analytics Publisherin ja Oracle Formsin asentaminen ja ylläpito '
                                              'etäpalvelimilla on erittäin työlästä.',
                                        'sv': 'Att installera, patcha och underhålla WebLogic, Publisher och Forms 14c '
                                              'i fjärrmiljöer är mycket tidskrävande.',
                                        'lv': 'Analytics Publisher un Oracle Forms uzstādīšana un uzturēšana attālās '
                                              'vidēs ir ļoti sarežģīta.',
                                        'lt': 'Analytics Publisher ir Oracle Forms diegimas bei priežiūra nuotolinėse '
                                              'aplinkose reikalauja daug pastangų.'}},
                        {   'icon': '✈️',
                            'kpi': '0 VPN SÕLTUVUS',
                            'title': {   'en': 'Requirement for Offline Autonomy',
                                         'et': 'Soov töötada võrguühenduseta (offline)',
                                         'fi': 'Tarve työskennellä ilman verkkoyhteyttä',
                                         'sv': 'Behov av att arbeta offline',
                                         'lv': 'Vēlme strādāt bezsaistē bez VPN',
                                         'lt': 'Poreikis dirbti neprisijungus be VPN'},
                            'desc': {   'en': 'Developing and testing on flights, trains, or without corporate VPN is '
                                              'impossible with central databases.',
                                        'et': 'Vajadus arendada ja testida lennukis, reisil või ilma ettevõtte '
                                              'sisevõrgu ja VPN-ita ei ole tsentraalsete baasidega võimalik.',
                                        'fi': 'Kehittäminen ja testaaminen matkoilla tai ilman yrityksen VPN-yhteyttä '
                                              'on mahdotonta jaetuilla kannoilla.',
                                        'sv': 'Att utveckla och testa på resor eller utan företags-VPN är omöjligt med '
                                              'centrala databaser.',
                                        'lv': 'Izstrāde un testēšana ceļojuma laikā vai bez uzņēmuma VPN nav iespējama '
                                              'ar centrālajām bāzēm.',
                                        'lt': 'Kūrimas ir testavimas kelionėse arba be įmonės VPN yra neįmanomas '
                                              'naudojant tik centrines bazes.'}},
                        {   'icon': '🔒',
                            'kpi': '0 PILETIT',
                            'title': {   'en': 'Inflexibility &amp; Inter-Team Dependencies',
                                         'et': 'Paindumatus ja tiimide vahelised sõltuvused',
                                         'fi': 'Joustamattomuus ja tiimien väliset riippuvuudet',
                                         'sv': 'Oelastiska beroenden mellan team',
                                         'lv': 'Neelastība un atkarība no pieteikumiem',
                                         'lt': 'Nelankstumas ir priklausomybė nuo užduočių'},
                            'desc': {   'en': 'Developers cannot choose custom Oracle DB / APEX versions without long '
                                              'ticketing delays across DBA/Ops teams.',
                                        'et': 'Ei saa valida erinevaid Oracle DB / APEX / ORDS versioone; pikk ooteaeg '
                                              'piletisüsteemides (DBA, võrk, storage).',
                                        'fi': 'Eri Oracle DB/APEX -versioiden tilaaminen kestää kauan '
                                              'lippujärjestelmissä (DBA-, verkko- ja tallennustiimit).',
                                        'sv': 'Kan inte välja anpassade versioner utan långa väntetider i '
                                              'ärendehanteringssystem.',
                                        'lv': 'Nevar izvēlēties versijas bez ilgām gaidīšanas rindām IT pieteikumu '
                                              'sistēmās.',
                                        'lt': 'Negalima laisvai pasirinkti versijų be ilgų laukimo eilių bilietų '
                                              'sistemose.'}},
                         {   'icon': '🤖',
                             'kpi': '100% ISOLATSIOON',
                             'title': {   'en': 'Isolated Sandbox for VS Code, AI &amp; Autonomous Agents',
                                          'et': 'VS Code, AI ja Agentide Isoleeritud Sandbox',
                                          'fi': 'Eristetty Sandbox VS Code-, Tekoäly- ja Agenttitestaukseen',
                                          'sv': 'Isolerad Sandbox för VS Code, AI &amp; Autonoma Agenter',
                                          'lv': 'Izolēta smilškaste VS Code, AI un autonomiem aģentiem',
                                          'lt': 'Izoliuota smėliadėžė VS Code, AI ir autonominiams agentams'},
                             'desc': {   'en': 'AI coding agents (Claude, Cursor, Copilot, Devin) and automated test suites require a private, clean Oracle DB. The platform provisions an isolated local sandbox with ~15s rollback, enabling autonomous agents to run SQLcl migrations and tests without touching shared databases.',
                                         'et': 'AI koodiassistentidel (Claude, Cursor, Copilot, Devin) ja autonoomsetel agentidel puudub ligipääs puhtale Oracle baasile. Platvorm tagab eraldatud lokaalse liivakasti ja ~15s kiirtaaste, võimaldades agentidel käivitada SQLcl migratsioone ja automaatteste teisi segamata.',
                                         'fi': 'Tekoälyavustajat (Claude, Cursor, Copilot, Devin) ja autonomiset agentit tarvitsevat puhtaan Oracle-kannan. Alusta tarjoaa eristetyn paikallisen hiekkalaatikon ja ~15s palautuksen, jotta agentit voivat ajaa SQLcl-migraatioita ja testejä häiritsemättä muita.',
                                         'sv': 'AI-assistenter (Claude, Cursor, Copilot, Devin) och autonoma agenter behöver en ren Oracle-databas. Plattformen tillhandahåller en isolerad lokal sandlåda och ~15s återställning så att agenter kan köra SQLcl-migreringar och automatiserade tester riskfritt.',
                                         'lv': 'AI asistentiem (Claude, Cursor, Copilot, Devin) un autonomiem aģentiem nepieciešama tīra Oracle datubāze. Platforma nodrošina izolētu lokālu smilškasti un ~15s atjaunošanu, ļaujot aģentiem izpildīt SQLcl migrācijas un testus, netraucējot citus.',
                                         'lt': 'AI asistentams (Claude, Cursor, Copilot, Devin) ir autonominiams agentams reikalinga švari Oracle duomenų bazė. Platforma suteikia izoliuotą vietinę smėliadėžę su ~15s atstatymu, leidžiančią agentams vykdyti SQLcl migracijas ir testus netrukdant kitiems.'}}],
           'speaker_notes': {   'en': '🎯 Core Takeaway: Bottlenecks in shared environments cost companies thousands of '
                                      'engineering hours every month.<br/>💡 Talking Points: Contrast the pain of '
                                      'shared central instances with personal isolated containers. Mention how a '
                                      'single broken migration on a shared DB halts 10 developers.<br/>⚠️ Key '
                                      'Emphasis: Emphasize that removing ticket dependencies directly multiplies '
                                      'release frequency and developer satisfaction.',
                                'et': '🎯 Peamine sõnum: Jagatud andmebaaside pudelikaelad ja piletisüsteemid maksavad '
                                      'ettevõtetele tuhandeid arendustunde kuus.<br/>💡 Esitaja rääkimispunktid: Too '
                                      'esile kontrast jagatud tsentraalse serveri ja personaalse isoleeritud '
                                      'konteineri vahel. Kui üks arendaja teeb vea, seisab 10 inimese töö.<br/>⚠️ Mida '
                                      'rõhutada: Piletivaba autonoomia tõstab otseselt meeskonna tarnekiirust ja '
                                      'töörahulolu.',
                                'fi': '🎯 Pääviesti: Jaettujen ympäristöjen pullonkaulat maksavat yrityksille tuhansia '
                                      'työtunteja kuukaudessa.<br/>💡 Puhujan muistiinpanot: Vertaa jaettua kantaa '
                                      'henkilökohtaiseen eristettyyn konttiin. Yksi virhe jaetussa kannassa estää '
                                      'kymmenen ihmisen työn.<br/>⚠️ Tärkeä painotus: Lippujärjestelmien riippuvuuden '
                                      'poistaminen nopeuttaa suoraan julkaisusykliä.',
                                'sv': '🎯 Huvudbudskap: Flaskhalsar i delade miljöer kostar företag tusentals '
                                      'utvecklingstimmar varje månad.<br/>💡 Talarpunkter: Jämför smärtan med delade '
                                      'servrar mot personliga isolerade containrar. Om en gör fel stoppas tio '
                                      'utvecklare.<br/>⚠️ Vad som bör betonas: Att ta bort ärendeleder ökar '
                                      'leveranshastigheten och arbetsglädjen direkt.',
                                'lv': '🎯 Galvenais vēstījums: Koplietoto datubāzu pudeles kakli un pieteikumu '
                                      'gaidīšana maksā tūkstošiem stundu mēnesī.<br/>💡 Runātāja piezīmes: Salīdziniet '
                                      'koplietotu serveri ar personīgu konteineru. Viena kļūda aptur visas komandas '
                                      'darbu.<br/>⚠️ Ko uzsvērt: Atkarību likvidēšana paātrina izstrādes ciklu un '
                                      'piegādes ātrumu.',
                                'lt': '🎯 Pagrindinė žinutė: Bendrų duomenų bazių trikdžiai ir bilietų laukimas '
                                      'kainuoja tūkstančius inžinierių valandų kas mėnesį.<br/>💡 Pranešėjo pastabos: '
                                      'Palyginkite bendrus serverius su izoliuotais konteineriais. Viena klaida '
                                      'sustabdo visos komandos darbą.<br/>⚠️ Ką akcentuoti: Priklausomybių pašalinimas '
                                      'tiesiogiai padidina pristatymo greitį.'}},
    3: {   'badge': {   'en': '💼 SLIDE 3 / 13 • BUSINESS LEADER &amp; CIO',
                        'et': '💼 SLAID 3 / 13 • ÄRIJUHT JA CIO',
                        'fi': '💼 DIA 3 / 13 • LIIKETOIMINTAJOHTAJA &amp; CIO',
                        'sv': '💼 BILD 3 / 13 • VERKSAMHETSLEDARE &amp; CIO',
                        'lv': '💼 SLAIDS 3 / 13 • BIZNESA VADĪTĀJS UN CIO',
                        'lt': '💼 SKAIDRĖ 3 / 13 • VERSLO VADOVAS IR CIO'},
           'title': {   'en': '0€ Dev Licenses, Faster Time-to-Market &amp; Lower TCO',
                        'et': '0€ arenduslitsentsid, kiirem turulejõudmine ja madalam TCO',
                        'fi': '0€ kehityslisenssit, nopeampi markkinoilletulo ja alhaisempi TCO',
                        'sv': '0€ dev-licenser, snabbare time-to-market och lägre TCO',
                        'lv': '0€ izstrādes licences, ātrāka nonākšana tirgū un zemāks TCO',
                        'lt': '0€ kūrimo licencijos, greitesnis patekimas į rinką ir mažesnis TCO'},
           'lead': {   'en': 'Dramatic infrastructure cost savings, rapid developer onboarding, and agility to deploy '
                             'lightweight tools directly to production.',
                       'et': 'Märkimisväärne taristukulude kokkuhoid, kiire arendajate sisseelamine ja võimalus '
                             'kasutada Free DB-d siserakendustes.',
                       'fi': 'Merkittävät infrastruktuurin kustannussäästöt, nopea perehdytys ja ketteryys ajaa '
                             'kevyitä sovelluksia tuotannossa.',
                       'sv': 'Betydande kostnadsbesparingar, snabbare onboarding och smidighet att köra interna '
                             'verktyg i produktion.',
                       'lv': 'Ievērojams infrastruktūras izmaksu ietaupījums, ātra jauno darbinieku ievadīšana un '
                             'iespēja izmantot Free DB ražošanā.',
                       'lt': 'Reikšmingas infrastruktūros išlaidų taupymas, greitas naujų darbuotojų įvedimas ir '
                             'galimybė naudoti Free DB gamyboje.'},
           'diagram': {   'label': {   'en': '💼 BUSINESS IMPACT &amp; ROI ACCELERATION',
                                       'et': '💼 ÄRIMÕJU JA INVESTEERINGU TASUVUSE (ROI) SKEEM',
                                       'fi': '💼 LIIKETOIMINTAVAIKUTUS JA ROI-KIIHDYTYS',
                                       'sv': '💼 AFFÄRSNYTTA OCH ROI-ACCELERATION',
                                       'lv': '💼 BIZNESA IETEKME UN ROI PAAIKSTINĀŠANA',
                                       'lt': '💼 VERSLO POVEIKIS IR ROI PAGREITINIMAS'},
                          'nodes': [   {   'icon': '💰',
                                           'title': {   'en': '0€ Dev License',
                                                        'et': '0€ litsentsikulu',
                                                        'fi': '0€ lisenssikulu',
                                                        'sv': '0€ licenskostnad',
                                                        'lv': '0€ licenču maksa',
                                                        'lt': '0€ licencijų kaina'},
                                           'sub': {   'en': 'Oracle 23ai Free DB',
                                                      'et': 'Oracle 23ai Free DB',
                                                      'fi': 'Oracle 23ai Free DB',
                                                      'sv': 'Oracle 23ai Free DB',
                                                      'lv': 'Oracle 23ai Free DB',
                                                      'lt': 'Oracle 23ai Free DB'},
                                           'type': 'default'},
                                       {   'icon': '⏱️',
                                           'title': {   'en': '-70% Onboarding',
                                                        'et': '-70% kiirem start',
                                                        'fi': '-70% perehdytys',
                                                        'sv': '-70% onboarding',
                                                        'lv': '-70% ievadīšana',
                                                        'lt': '-70% įvedimas'},
                                           'sub': {   'en': 'Ready in minutes',
                                                      'et': 'Valmis minutitega',
                                                      'fi': 'Valmis heti',
                                                      'sv': 'Klar på minuter',
                                                      'lv': 'Gatavs minūtēs',
                                                      'lt': 'Paruošta per min.'},
                                           'type': 'active'},
                                       {   'icon': '🚀',
                                           'title': {   'en': 'Rapid Innovation',
                                                        'et': 'Suur tarnekiirus',
                                                        'fi': 'Ketterä innovointi',
                                                        'sv': 'Snabb innovation',
                                                        'lv': 'Ātras inovācijas',
                                                        'lt': 'Greitos inovacijos'},
                                           'sub': {   'en': 'Lightweight prod apps',
                                                      'et': 'Free DB siserakendused',
                                                      'fi': 'Kevyet tuotantosovellukset',
                                                      'sv': 'Interna verktyg',
                                                      'lv': 'Iekšējās lietotnes',
                                                      'lt': 'Vidinės programos'},
                                           'type': 'accent'},
                                       {   'icon': '📈',
                                           'title': {   'en': 'Lowest TCO',
                                                        'et': 'Madalaim TCO',
                                                        'fi': 'Alhaisin TCO',
                                                        'sv': 'Lägsta TCO',
                                                        'lv': 'Zemākais TCO',
                                                        'lt': 'Mažiausias TCO'},
                                           'sub': {   'en': 'Immediate ROI',
                                                      'et': 'Kohene investeeringu tulu',
                                                      'fi': 'Välitön ROI',
                                                      'sv': 'Snabb ROI',
                                                      'lv': 'Ātra atdeve',
                                                      'lt': 'Greita grąža'},
                                           'type': 'success'}],
                          'title': {   'en': 'GitOps & Liquibase Automated Pipeline',
                                       'et': 'GitOps & Liquibase automatiseeritud tarnekonveier',
                                       'fi': 'Automatisoitu GitOps & Liquibase -toimitusputki',
                                       'sv': 'Automatiserad pipeline för GitOps och Liquibase',
                                       'lv': 'GitOps un Liquibase automatizētais konveijers',
                                       'lt': 'Automatizuotas GitOps ir Liquibase konvejeris'}},
           'cards': [   {   'icon': '💰',
                            'kpi': '0€ LITSENTS',
                            'title': {   'en': '0€ Dev &amp; Test Licensing',
                                         'et': '0€ arenduse ja testi litsentsikulu',
                                         'fi': '0€ kehitys- ja testilisenssit',
                                         'sv': '0€ dev- och testlicenskostnader',
                                         'lv': '0€ izstrādes un testēšanas licences',
                                         'lt': '0€ kūrimo ir testavimo licencijos'},
                            'desc': {   'en': 'Harness full enterprise features of Oracle 23ai Free DB without paying '
                                              'expensive per-core developer seat licenses.',
                                        'et': 'Kasuta Oracle 23ai Free DB kõiki enterprise-võimalusi ilma kulukate '
                                              'arendaja töökoha- või tuumalitsentsideta.',
                                        'fi': 'Hyödynnä Oracle 23ai Free DB:n yritystason ominaisuuksia ilman kalliita '
                                              'kehittäjäkohtaisia lisenssejä.',
                                        'sv': 'Använd enterprise-funktionerna i Oracle 23ai Free DB utan dyra licenser '
                                              'per kärna eller användare.',
                                        'lv': 'Izmantojiet Oracle 23ai Free DB iespējas bez dārgām licenču maksām par '
                                              'procesora kodoliem.',
                                        'lt': 'Naudokitės visomis Oracle 23ai Free DB įmonių lygio galimybėmis be '
                                              'brangių branduolių licencijų.'}},
                        {   'icon': '⚡',
                            'kpi': '-70% AEG',
                            'title': {   'en': 'Accelerated Onboarding &amp; TTM',
                                         'et': 'Kiirem sisseelamine ja turulejõudmine',
                                         'fi': 'Nopeampi perehdytys ja markkinoilletulo',
                                         'sv': 'Snabbare onboarding och kortare ledtider',
                                         'lv': 'Ātrāka uzsākšana un nokļūšana tirgū',
                                         'lt': 'Greitesnis įvedimas ir patekimas į rinką'},
                            'desc': {   'en': 'New hires spin up a fully functioning Oracle environment in minutes, '
                                              'shortening sprint cycles by weeks.',
                                        'et': 'Uus arendaja saab töötava keskkonna minutitega, lühendades projektide '
                                              'käivitamise ja tarneaegu nädalate võrra.',
                                        'fi': 'Uusi kehittäjä saa toimivan ympäristön minuuteissa, mikä lyhentää '
                                              'projektien läpimenoaikaa viikoilla.',
                                        'sv': 'Nyanställda startar en fullt fungerande miljö på några minuter, vilket '
                                              'förkortar leveranstiderna avsevärt.',
                                        'lv': 'Jauns programmētājs iegūst darba vidi minūtēs, saīsinot piegādes laiku '
                                              'par vairākām nedēļām.',
                                        'lt': 'Naujas darbuotojas paruošia aplinką per kelias minutes, sutrumpindamas '
                                              'sprinto ciklus savaitėmis.'}},
                        {   'icon': '🚀',
                            'kpi': 'INNOVATSIOON',
                            'title': {   'en': 'Free DB for Internal Production Apps',
                                         'et': 'Free DB mittekriitilisteks siserakendusteks',
                                         'fi': 'Free DB kevyille sisäisille tuotantosovelluksille',
                                         'sv': 'Free DB för interna produktionsapplikationer',
                                         'lv': 'Free DB iekšējām ražošanas lietotnēm',
                                         'lt': 'Free DB vidinėms gamybinėms programoms'},
                            'desc': {   'en': 'Zero-Trust architecture enables running isolated internal tools, '
                                              'dashboards, and POCs directly in production containers.',
                                        'et': 'Zero-Trust turvalisus võimaldab väikseid siserakendusi, juhtimispaneele '
                                              'ja prototüüpe turvaliselt toodangus jooksutada.',
                                        'fi': 'Zero-Trust mahdollistaa keveiden sisäisten työkalujen ja kojelautojen '
                                              'turvallisen ajon tuotantokonteissa.',
                                        'sv': 'Zero-Trust möjliggör säker körning av interna verktyg, dashboards och '
                                              'prototyper direkt i produktion.',
                                        'lv': 'Zero-Trust drošība ļauj droši darbināt iekšējos rīkus un informācijas '
                                              'paneļus ražošanas konteineros.',
                                        'lt': 'Zero-Trust saugumas leidžia saugiai leisti vidines programas ir valdymo '
                                              'skydelius gamybiniuose konteineriuose.'}}],
           'speaker_notes': {   'en': '🎯 Core Takeaway: Drastic reduction in Total Cost of Ownership (TCO) while '
                                      'accelerating delivery cycles.<br/>💡 Talking Points: Emphasize that dev/test '
                                      'licenses can cost up to 40% of total Oracle infrastructure budgets. Free DB '
                                      'eliminates this overhead completely.<br/>⚠️ Key Emphasis: Reiterate that teams '
                                      'can validate prototypes and small internal operational tools in production '
                                      'without triggering massive licensing commitments.',
                                'et': '🎯 Peamine sõnum: Märkimisväärne omamiskulude (TCO) vähenemine koos '
                                      'arendustsükli olulise kiirenemisega.<br/>💡 Esitaja rääkimispunktid: Arendus- ja '
                                      'testlitsentsid võivad moodustada kuni 40% kogu Oracle eelarvest. Free DB kaotab '
                                      'selle kulu täielikult.<br/>⚠️ Mida rõhutada: Prototüüpe ja väikeseid '
                                      'sisekasutuse rakendusi saab viia toodangusse ilma hiiglaslike '
                                      'litsentsikohustusteta.',
                                'fi': '🎯 Pääviesti: Omistamisen kokonaiskustannusten (TCO) jyrkkä lasku ja '
                                      'toimitusaikojen nopeutuminen.<br/>💡 Puhujan muistiinpanot: Kehitys- ja '
                                      'testilisenssit voivat viedä jopa 40% Oracle-budjetista. Free DB poistaa nämä '
                                      'kulut kokonaan.<br/>⚠️ Tärkeä painotus: Prototyypit ja sisäiset työkalut '
                                      'voidaan viedä tuotantoon ilman valtavia lisenssisitoumuksia.',
                                'sv': '🎯 Huvudbudskap: Drastisk minskning av Total Cost of Ownership (TCO) och '
                                      'snabbare leveranscykler.<br/>💡 Talarpunkter: Utvecklingslicenser kan kosta upp '
                                      'till 40% av Oracle-budgeten. Free DB eliminerar denna kostnad helt.<br/>⚠️ Vad '
                                      'som bör betonas: Prototyper och interna verktyg kan tas i drift utan massiva '
                                      'licensinvesteringar.',
                                'lv': '🎯 Galvenais vēstījums: Būtiska kopējo īpašumtiesību izmaksu (TCO) samazināšana '
                                      'un izstrādes paātrināšana.<br/>💡 Runātāja piezīmes: Izstrādes licences var '
                                      'veidot līdz pat 40% no budžeta. Free DB pilnībā likvidē šos izdevumus.<br/>⚠️ '
                                      'Ko uzsvērt: Prototipus un iekšējos rīkus var ieviest ražošanā bez milzīgām '
                                      'licenču saistībām.',
                                'lt': '🎯 Pagrindinė žinutė: Reikšmingas bendrųjų nuosavybės kaštų (TCO) sumažinimas ir '
                                      'pristatymo pagreitinimas.<br/>💡 Pranešėjo pastabos: Kūrimo licencijos gali '
                                      'sudaryti iki 40% Oracle biudžeto. Free DB visiškai panaikina šias '
                                      'išlaidas.<br/>⚠️ Ką akcentuoti: Prototipai ir vidiniai įrankiai gali būti '
                                      'paleidžiami gamyboje be didelių finansinių įsipareigojimų.'}},
    4: {   'badge': {   'en': '👨\u200d💻 SLIDE 4 / 13 • SOFTWARE DEVELOPER',
                        'et': '👨\u200d💻 SLAID 4 / 13 • TARKVARAARENDAJA JA ARHITEKT',
                        'fi': '👨\u200d💻 DIA 4 / 13 • OHJELMISTOKEHTTÄJÄ &amp; ARKKITEHTI',
                        'sv': '👨\u200d💻 BILD 4 / 13 • PROGRAMVARUUTVECKLARE &amp; ARKITEKT',
                        'lv': '👨\u200d💻 SLAIDS 4 / 13 • PROGRAMMATŪRAS IZSTRĀDĀTĀJS',
                        'lt': '👨\u200d💻 SKAIDRĖ 4 / 13 • PROGRAMINĖS ĮRANGOS KŪRĖJAS'},
           'title': {   'en': 'Developer Autonomy, Speed &amp; Declarative APEXlang',
                        'et': 'Arendaja autonoomia, kiirus ja deklaratiivne APEXlang',
                        'fi': 'Kehittäjän autonomia, nopeus ja deklaratiivinen APEXlang',
                        'sv': 'Utvecklarautonomi, snabbhet och deklarativ APEXlang',
                        'lv': 'Izstrādātāja autonomija, ātrums un deklaratīvais APEXlang',
                        'lt': 'Kūrėjo autonomija, greitis ir deklaratyvus APEXlang'},
           'lead': {   'en': 'Total freedom to innovate and experiment without fear of breaking shared systems or '
                             'waiting on DBA tickets.',
                       'et': 'Täielik vabadus eksperimenteerida ja eksida ilma teisi segamata või piletijärjekordades '
                             'ootamata.',
                       'fi': 'Täysi vapaus kokeilla ja epäonnistua sotkematta muiden työtä tai odottamatta '
                             'DBA-lippuja.',
                       'sv': 'Full frihet att experimentera utan rädsla för att förstöra delade system eller vänta på '
                             'DBA-ärenden.',
                       'lv': 'Pilnīga brīvība eksperimentēt un kļūdīties, netraucējot citiem un negaidot DBA '
                             'apstiprinājumus.',
                       'lt': 'Visiška laisvė eksperimentuoti ir klysti nesugadinant bendrų sistemų ir nelaukiant DBA '
                             'bilietų.'},
           'diagram': {   'label': {   'en': '💻 DEVELOPER INNER LOOP &amp; RESTORE WORKFLOW',
                                       'et': '💻 ARENDAJA TÖÖVOOG JA KIIRTAASTE SKEEM',
                                       'fi': '💻 KEHITTÄJÄN TYÖNKULKU JA PIKAPALAUTUS',
                                       'sv': '💻 UTVECKLARENS ARBETSFLÖDE OCH ÅTERSTÄLLNING',
                                       'lv': '💻 IZSTRĀDĀTĀJA DARBA CIKLS UN ATJAUNOŠANA',
                                       'lt': '💻 KŪRĖJO DARBO CIKLAS IR ATKŪRIMAS'},
                          'nodes': [   {   'icon': '💻',
                                           'title': {   'en': 'APEXlang Code',
                                                        'et': 'APEXlang kood',
                                                        'fi': 'APEXlang-koodi',
                                                        'sv': 'APEXlang-kod',
                                                        'lv': 'APEXlang kods',
                                                        'lt': 'APEXlang kodas'},
                                           'sub': {   'en': 'Git declarative .apx',
                                                      'et': 'Git deklaratiivne .apx',
                                                      'fi': 'Git deklaratiivinen .apx',
                                                      'sv': 'Git deklarativ .apx',
                                                      'lv': 'Git deklaratīvs .apx',
                                                      'lt': 'Git deklaratyvus .apx'},
                                           'type': 'default'},
                                       {   'icon': '⚡',
                                           'title': {   'en': 'SQLcl Apply',
                                                        'et': 'SQLcl rakendamine',
                                                        'fi': 'SQLcl-ajo',
                                                        'sv': 'SQLcl-körning',
                                                        'lv': 'SQLcl izpilde',
                                                        'lt': 'SQLcl taikymas'},
                                           'sub': {   'en': 'Instant deployment',
                                                      'et': 'Kohene paigaldus',
                                                      'fi': 'Välitön asennus',
                                                      'sv': 'Snabb distribution',
                                                      'lv': 'Tūlītējs izvietojums',
                                                      'lt': 'Greitas diegimas'},
                                           'type': 'active'},
                                       {   'icon': '🧪',
                                           'title': {   'en': 'Risky Test',
                                                        'et': 'Julge katsetus',
                                                        'fi': 'Rohkea testi',
                                                        'sv': 'Riskabelt test',
                                                        'lv': 'Drosmīgs tests',
                                                        'lt': 'Drąsus testas'},
                                           'sub': {   'en': 'Schema & PL/SQL',
                                                      'et': 'Skeem & PL/SQL',
                                                      'fi': 'Skeemat & PL/SQL',
                                                      'sv': 'Schema & PL/SQL',
                                                      'lv': 'Shēma & PL/SQL',
                                                      'lt': 'Schema ir PL/SQL'},
                                           'type': 'accent'},
                                       {   'icon': '↩️',
                                           'title': {   'en': '1–2 Min Undo',
                                                        'et': '1–2 min Undo',
                                                        'fi': '1–2 min Kumoa',
                                                        'sv': '1–2 min Ångra',
                                                        'lv': '1–2 min Atcelt',
                                                        'lt': '1–2 min Atšaukti'},
                                           'sub': {   'en': 'Pristine rollback',
                                                      'et': 'Puhas algseis',
                                                      'fi': 'Puhdas palautus',
                                                      'sv': 'Ren återställning',
                                                      'lv': 'Tīrs stāvoklis',
                                                      'lt': 'Švarus atkūrimas'},
                                           'type': 'success'}],
                          'title': {   'en': 'Golden Snapshot Instant Recovery Timeline',
                                       'et': 'Golden Snapshot kiirtaaste ajajoon',
                                       'fi': 'Golden Snapshot -pikapalautuksen aikajana',
                                       'sv': 'Tidslinje för snabbåterställning med Golden Snapshot',
                                       'lv': 'Golden Snapshot ātrās atjaunošanas laika skala',
                                       'lt': 'Golden Snapshot greito atkūrimo laiko juosta'}},
           'cards': [   {   'icon': '🧪',
                            'kpi': '1–2 MIN',
                            'title': {   'en': 'Freedom to Fail &amp; Rapid Recovery',
                                         'et': 'Vabadus eksida ja kiirtaaste',
                                         'fi': 'Vapaus kokeilla ja nopea palautus',
                                         'sv': 'Frihet att experimentera och snabb återställning',
                                         'lv': 'Brīvība kļūdīties un ātra atjaunošana',
                                         'lt': 'Laisvė klysti ir greitas atkūrimas'},
                            'desc': {   'en': 'Test risky schema migrations or PL/SQL refactoring freely. Roll back '
                                              'the entire database to a clean baseline in 1–2 minutes.',
                                        'et': 'Katseta julgelt keerulisi skeemimuudatusi ja PL/SQL koodi. Taasta kogu '
                                              'andmebaas puhtasse algseisu vaid 1–2 minutiga.',
                                        'fi': 'Kokeile rohkeasti skeemamuutoksia ja PL/SQL-koodia. Palauta koko '
                                              'tietokanta alkutilaan 1–2 minuutissa.',
                                        'sv': 'Testa riskabla schemamigreringar och PL/SQL fritt. Återställ hela '
                                              'databasen till rent utgångsläge på 1–2 minuter.',
                                        'lv': 'Eksperimentējiet ar shēmu migrācijām un PL/SQL. Atjaunojiet visu '
                                              'datubāzi tīrā sākumstāvoklī 1–2 minūtēs.',
                                        'lt': 'Drąsiai bandykite schemų migracijas ir PL/SQL. Atkurkite visą duomenų '
                                              'bazę į švarią būseną per 1–2 minutes.'}},
                        {   'icon': '✈️',
                            'kpi': '100% OFFLINE',
                            'title': {   'en': 'True Offline Autonomy',
                                         'et': 'Täielik võrguühenduseta töö',
                                         'fi': 'Täysi offline-autonomia',
                                         'sv': 'Full offline-autonomi',
                                         'lv': 'Pilnīga bezsaistes autonomija',
                                         'lt': 'Visiška autonomija be interneto'},
                            'desc': {   'en': 'Code, query, and test on flights, trains, or offsite without requiring '
                                              'corporate VPN or constant connectivity.',
                                        'et': 'Arenda ja testi lennukis, rongis või suvilas ilma ettevõtte VPN-i või '
                                              'stabiilse internetiühenduseta.',
                                        'fi': 'Kehitä ja testaa lentokoneessa, junassa tai etänä ilman yrityksen '
                                              'VPN-yhteyttä.',
                                        'sv': 'Koda och testa på flyg, tåg eller distans utan företags-VPN eller '
                                              'ständig uppkoppling.',
                                        'lv': 'Izstrādājiet un testējiet lidmašīnā, vilcienā vai bezsaistē bez '
                                              'uzņēmuma VPN.',
                                        'lt': 'Programuokite ir testuokite lėktuve, traukinyje ar gamtoje be įmonės '
                                              'VPN.'}},
                        {   'icon': '🪄',
                            'kpi': '10x SPEED',
                            'title': {   'en': 'APEX 26.1 &amp; Declarative APEXlang',
                                         'et': 'APEX 26.1 ja deklaratiivne APEXlang',
                                         'fi': 'APEX 26.1 ja deklaratiivinen APEXlang',
                                         'sv': 'APEX 26.1 och deklarativ APEXlang',
                                         'lv': 'APEX 26.1 un deklaratīvais APEXlang',
                                         'lt': 'APEX 26.1 ir deklaratyvus APEXlang'},
                            'desc': {   'en': '10x faster UI delivery with low-code APEX and official SQLcl 26.2 '
                                              'declarative <code>.apx</code> code in Git.',
                                        'et': '10x kiirem kasutajaliideste tarne APEX low-code abil ning ametlik SQLcl '
                                              '26.2 deklaratiivne <code>.apx</code> kood Gitis.',
                                        'fi': '10x nopeampi käyttöliittymien toimitus APEX low-codella ja virallinen '
                                              'SQLcl 26.2 APEXlang <code>.apx</code> Gitissä.',
                                        'sv': '10x snabbare leverans med APEX low-code och officiell SQLcl 26.2 '
                                              'deklarativ <code>.apx</code> i Git.',
                                        'lv': '10x ātrāka saskarņu izstrāde ar APEX low-code un oficiālo SQLcl 26.2 '
                                              'deklaratīvo <code>.apx</code> Gitā.',
                                        'lt': '10x greitesnis sąsajų kūrimas su APEX low-code ir oficialiu SQLcl 26.2 '
                                              'deklaratyviu <code>.apx</code> Gite.'}}],
           'speaker_notes': {   'en': '🎯 Core Takeaway: Developers move with 10x velocity when they are not afraid of '
                                      'breaking things.<br/>💡 Talking Points: Emphasize that when a database can be '
                                      'reset in 1–2 minutes, developers take bolder technical decisions. Highlight the '
                                      'power of APEXlang in Git.<br/>⚠️ Key Emphasis: Point out that offline '
                                      'capability means zero productivity loss during commutes or remote work.',
                                'et': '🎯 Peamine sõnum: Arendaja liigub 10x kiiremini, kui tal puudub hirm süsteemi '
                                      'lõhkumise ees.<br/>💡 Esitaja rääkimispunktid: Kui andmebaasi saab 1–2 minutiga '
                                      'algseisu taastada, julgevad arendajad teha julgemaid optimeerimisi. Too välja '
                                      'APEXlangi koodipõhisus Gitis.<br/>⚠️ Mida rõhutada: Täielik võrguühenduseta töö '
                                      'välistab seisakud reisidel või VPN-i tõrgete korral.',
                                'fi': '🎯 Pääviesti: Kehittäjät etenevät 10x nopeammin, kun heidän ei tarvitse pelätä '
                                      'järjestelmän rikkomista.<br/>💡 Puhujan muistiinpanot: Kun tietokanta palautuu '
                                      '1–2 minuutissa, tiimi uskaltaa kokeilla ja optimoida rohkeammin. APEXlang tuo '
                                      'APEXin suoraan Git-maailmaan.<br/>⚠️ Tärkeä painotus: Offline-kyky takaa '
                                      'katkeamattoman tuottavuuden missä tahansa.',
                                'sv': '🎯 Huvudbudskap: Utvecklare rör sig 10x snabbare när de inte är rädda för att '
                                      'göra fel.<br/>💡 Talarpunkter: När databasen kan återställas på 1–2 minuter '
                                      'vågar teamet göra modigare förändringar. Lyft fram APEXlang i Git.<br/>⚠️ Vad '
                                      'som bör betonas: Full offline-kapacitet gör att arbetet aldrig stannar upp på '
                                      'grund av nätverksproblem.',
                                'lv': '🎯 Galvenais vēstījums: Izstrādātāji strādā 10x ātrāk, ja nav baiļu sabojāt '
                                      'kopējo sistēmu.<br/>💡 Runātāja piezīmes: Ja datubāzi var atjaunot 1–2 minūtēs, '
                                      'komanda pieņem drosmīgākus lēmumus. Uzsveriet APEXlang lomu Gitā.<br/>⚠️ Ko '
                                      'uzsvērt: Bezsaistes darbs novērš dīkstāves ceļojumos un VPN kļūmju gadījumos.',
                                'lt': '🎯 Pagrindinė žinutė: Kūrėjai juda 10x greičiau, kai nebijo suklysti ar '
                                      'sugadinti sistemos.<br/>💡 Pranešėjo pastabos: Kai DB atkuriama per 1–2 minutes, '
                                      'programuotojai priima drąsesnius sprendimus. Pabrėžkite APEXlang Gite.<br/>⚠️ '
                                      'Ką akcentuoti: Darbas be interneto užtikrina nepertraukiamą produktyvumą bet '
                                      'kokiomis sąlygomis.'}},
    5: {   'badge': {   'en': '🚀 SLIDE 5 / 13 • DEVOPS &amp; CI/CD',
                        'et': '🚀 SLAID 5 / 13 • DEVOPS JA CI/CD INSENER',
                        'fi': '🚀 DIA 5 / 13 • DEVOPS &amp; CI/CD -INSINÖÖRI',
                        'sv': '🚀 BILD 5 / 13 • DEVOPS &amp; CI/CD-INGENJÖR',
                        'lv': '🚀 SLAIDS 5 / 13 • DEVOPS UN CI/CD INŽENIERIS',
                        'lt': '🚀 SKAIDRĖ 5 / 13 • DEVOPS IR CI/CD INŽINIERIUS'},
           'title': {   'en': 'Everything-as-Code &amp; Predictable CI/CD Pipelines',
                        'et': 'Kõik on kood (Git) ja etteaimatavad CI/CD torud',
                        'fi': 'Kaikki koodina (Git) ja ennustettavat CI/CD-putket',
                        'sv': 'Allt som kod (Git) och förutsägbara CI/CD-pipelines',
                        'lv': 'Viss kā kods (Git) un paredzami CI/CD konveijeri',
                        'lt': 'Viskas kaip kodas (Git) ir nuspėjami CI/CD konvejeriai'},
           'lead': {   'en': '100% parity between local developer laptops and central CI/CD runners with reproducible '
                             'container stacks.',
                       'et': '100% identne käitumine arendaja arvutis ja tsentraalses CI serveris tänu '
                             'reprodutseeritavatele konteineritele.',
                       'fi': '100% identtinen toiminta kehittäjän kannettavalla ja CI-palvelimella toistettavien '
                             'konttien ansiosta.',
                       'sv': '100% paritet mellan utvecklarens dator och central CI-server tack vare reproducerbara '
                             'containrar.',
                       'lv': '100% identiska darbība izstrādātāja datorā un CI serverī, pateicoties atkārtojamiem '
                             'konteineriem.',
                       'lt': '100% identiškas veikimas programuotojo kompiuteryje ir CI serveryje dėka atkuriamų '
                             'konteinerių.'},
           'cards': [   {   'icon': '📜',
                            'kpi': '100% GIT',
                            'title': {   'en': 'Declarative Migrations',
                                         'et': 'Deklaratiivsed migratsioonid',
                                         'fi': 'Deklaratiiviset migraatiot',
                                         'sv': 'Deklarativa migreringar',
                                         'lv': 'Deklaratīvās migrācijas',
                                         'lt': 'Deklaratyvios migracijos'},
                            'desc': {   'en': 'Automated schema diffs, changelog validation, and AST quality gating '
                                              'via SQLcl and Liquibase in Git.',
                                        'et': 'Automaatsed skeemide võrdlused, muudatuslogid ja AST kvaliteedikontroll '
                                              'SQLcl ja Liquibase abil Gitis.',
                                        'fi': 'Automaattiset skeemaerot, muutoslokit ja AST-laaduntarkistus SQLcl:n ja '
                                              'Liquibasen avulla Gitissä.',
                                        'sv': 'Automatiserade schemadiffar, ändringsloggar och AST-kvalitetsgranskning '
                                              'med SQLcl och Liquibase i Git.',
                                        'lv': 'Automatizēti shēmu salīdzinājumi, izmaiņu žurnāli un AST kvalitātes '
                                              'vārteja ar SQLcl un Liquibase Gitā.',
                                        'lt': 'Automatizuoti schemų palyginimai, pakeitimų žurnalai ir AST kokybės '
                                              'patikra su SQLcl ir Liquibase Gite.'}},
                        {   'icon': '🔄',
                            'kpi': 'PARITEET',
                            'title': {   'en': 'Local &amp; CI Container Parity',
                                         'et': 'Lokaalse ja CI konteineri identsus',
                                         'fi': 'Paikallisen ja CI-kontin pariteetti',
                                         'sv': 'Paritet mellan lokal miljö och CI',
                                         'lv': 'Lokālās un CI vides identitāte',
                                         'lt': 'Vietinės ir CI aplinkos paritetas'},
                            'desc': {   'en': 'Same compose blueprints run in GitHub Actions, GitLab CI, or developer '
                                              'laptops with ephemeral <code>--rm</code> cleanup.',
                                        'et': 'Samad blueprintid jooksevad GitHub Actionsis, GitLab CI-s või '
                                              'sülearvutis koos ephemeral <code>--rm</code> puhastusega.',
                                        'fi': 'Samat mallit ajetaan GitHub Actionsissa, GitLab CI:ssä tai '
                                              'kannettavalla efemeerisellä <code>--rm</code>-siivouksella.',
                                        'sv': 'Samma ritningar körs i GitHub Actions, GitLab CI eller på bärbar dator '
                                              'med efemer <code>--rm</code>-rensning.',
                                        'lv': 'Vienādi rasējumi darbojas GitHub Actions, GitLab CI vai datorā ar '
                                              'efemēru <code>--rm</code> tīrīšanu.',
                                        'lt': 'Tie patys brėžiniai veikia GitHub Actions, GitLab CI arba kompiuteryje '
                                              'su efemeriniu <code>--rm</code> išvalymu.'}},
                        {   'icon': '🎯',
                            'kpi': '0 SAASTUMIST',
                            'title': {   'en': 'Zero Test Cross-Contamination',
                                         'et': 'Null testisaastumist',
                                         'fi': 'Nolla testien ristiinsaastumista',
                                         'sv': 'Noll korskontaminering i tester',
                                         'lv': 'Nulle testu savstarpēja piesārņojuma',
                                         'lt': 'Nulis testų tarpusavio užterštumo'},
                            'desc': {   'en': 'Each automated test suite runs against a deterministic baseline '
                                              'snapshot, ensuring 100% test repeatability.',
                                        'et': 'Iga automaattest alustab garanteeritult samast deterministlikust '
                                              'algseisust ilma eelmiste testide jääkideta.',
                                        'fi': 'Jokainen automatisoitu testi alkaa taatusti samasta deterministisestä '
                                              'tilasta ilman edellisten testien jäämiä.',
                                        'sv': 'Varje automatiserat test körs mot ett deterministiskt utgångsläge utan '
                                              'spår av tidigare tester.',
                                        'lv': 'Katra testa izpilde sākas no garantēta identiska stāvokļa bez '
                                              'iepriekšējo testu atlikumiem.',
                                        'lt': 'Kiekvienas automatizuotas testas prasideda nuo garantuotos pradinės '
                                              'būsenos be ankstesnių testų pėdsakų.'}}],
           'speaker_notes': {   'en': '🎯 Core Takeaway: Eliminates the infamous "works on my machine" dispute between '
                                      'developers and operations.<br/>💡 Talking Points: Explain the ephemeral '
                                      'container pattern (--rm) which destroys test containers and memory buffers '
                                      'automatically upon exit, leaving zero state.<br/>⚠️ Key Emphasis: Mention that '
                                      'SQLcl Liquibase automates changelog generation, catching breaking changes '
                                      'before they reach main branches.',
                                'et': '🎯 Peamine sõnum: Kaotab lõplikult klassikalise vaidluse "aga minu masinas see '
                                      'ju töötas".<br/>💡 Esitaja rääkimispunktid: Selgita ephemeral konteinerite '
                                      'mustrit (--rm), mis hävitab testkonteinerid ja mälupuhvrid väljumisel, jätmata '
                                      'mingit jääkolekut.<br/>⚠️ Mida rõhutada: SQLcl Liquibase automatiseerib '
                                      'muudatuste kontrolli, püüdes lõhkuvad skeemimuudatused kinni enne peaharudesse '
                                      'jõudmist.',
                                'fi': '🎯 Pääviesti: Poistaa lopullisesti "toimii minun koneellani" -ristiriidat '
                                      'kehittäjien ja ylläpidon väliltä.<br/>💡 Puhujan muistiinpanot: Selitä '
                                      'efemeeristen konttien malli (--rm), joka tuhoaa testikontit ja muistipuskurit '
                                      'automaattisesti testin päätyttyä.<br/>⚠️ Tärkeä painotus: SQLcl Liquibase '
                                      'automatisoi muutoslokien tarkistuksen ja estää rikkovat muutokset ennen '
                                      'päähaaraa.',
                                'sv': '🎯 Huvudbudskap: Eliminerar slutgiltigt diskussionen "men det fungerar på min '
                                      'maskin".<br/>💡 Talarpunkter: Förklara mönstret med efemära containrar (--rm) '
                                      'som automatiskt raderar testmiljön och minnesbuffertar vid avslut.<br/>⚠️ Vad '
                                      'som bör betonas: SQLcl Liquibase automatiserar ändringskontroll och fångar '
                                      'felaktiga scheman före merge till main.',
                                'lv': '🎯 Galvenais vēstījums: Novērš mūžīgo strīdu "bet manā datorā tas '
                                      'darbojās".<br/>💡 Runātāja piezīmes: Paskaidrojiet efemēro konteineru modeli '
                                      '(--rm), kas pēc testa automātiski iznīcina vidi un atmiņas buferus.<br/>⚠️ Ko '
                                      'uzsvērt: SQLcl Liquibase automatizē izmaiņu validāciju, apturot kļūdainas '
                                      'shēmas pirms nonākšanas galvenajā zarā.',
                                'lt': '🎯 Pagrindinė žinutė: Galutinai panaikina konfliktą "pas mane kompiuteryje '
                                      'veikė".<br/>💡 Pranešėjo pastabos: Paaiškinkite efemerinių konteinerių modelį '
                                      '(--rm), kuris automatiškai sunaikina testų konteinerius ir atmintį baigus '
                                      'darbą.<br/>⚠️ Ką akcentuoti: SQLcl Liquibase automatizuoja pakeitimų patikrą ir '
                                      'sulaiko klaidingas schemas prieš merge į pagrindinę šaką.'}},
    6: {   'badge': {   'en': '🛡️ SLIDE 6 / 13 • DBA &amp; SECURITY OFFICER',
                        'et': '🛡️ SLAID 6 / 13 • DBA JA TURVAJUHT',
                        'fi': '🛡️ DIA 6 / 13 • DBA &amp; TIETOTURVAJOHTAJA',
                        'sv': '🛡️ BILD 6 / 13 • DBA &amp; SÄKERHETSANSVARIG',
                        'lv': '🛡️ SLAIDS 6 / 13 • DBA UN DROŠĪBAS VADĪTĀJS',
                        'lt': '🛡️ SKAIDRĖ 6 / 13 • DBA IR SAUGUMO VADOVAS'},
           'title': {   'en': 'Zero-Trust Hardening, SEPS Wallet &amp; Production Parity',
                        'et': 'Zero-Trust turvalisus, SEPS Wallet ja toodangupariteet',
                        'fi': 'Zero-Trust-tietoturva, SEPS Wallet ja tuotantopariteetti',
                        'sv': 'Zero-Trust-säkerhet, SEPS Wallet och produktionsparitet',
                        'lv': 'Zero-Trust drošība, SEPS Wallet un ražošanas paritāte',
                        'lt': 'Zero-Trust saugumas, SEPS Wallet ir gamybos paritetas'},
           'lead': {   'en': 'Eliminate plaintext credentials completely while maintaining full architectural '
                             'governance and audit compliance.',
                       'et': 'Välista täielikult paroolid tekstifailides, tagades range arhitektuurse kontrolli ja '
                             'vastavuse turvastandarditele.',
                       'fi': 'Poista selkokieliset salasanat kokonaan säilyttäen samalla arkkitehtuurisen hallinnan ja '
                             'auditoitavuuden.',
                       'sv': 'Eliminera klartextlösenord helt med bibehållen arkitekturkontroll och revisionskrav.',
                       'lv': 'Pilnībā novērsiet atklāta teksta paroles, nodrošinot stingru arhitektūras kontroli un '
                             'atbilstību auditiem.',
                       'lt': 'Visiškai pašalinkite atviro teksto slaptažodžius, išlaikydami griežtą architektūros '
                             'kontrolę ir auditą.'},
           'cards': [   {   'icon': '🔐',
                            'kpi': 'AES-256',
                            'title': {   'en': 'SEPS Auto-Login Wallet',
                                         'et': 'SEPS paroolivaba Wallet',
                                         'fi': 'SEPS Auto-Login Wallet',
                                         'sv': 'SEPS Auto-Login Wallet',
                                         'lv': 'SEPS bezparoļu maks',
                                         'lt': 'SEPS beslaptažodė piniginė'},
                            'desc': {   'en': 'Secrets encrypted at rest with AES-256 in <code>cwallet.sso</code>. '
                                              'In-memory decryption only; zero plaintext on disk.',
                                        'et': 'Saladused krüpteeritud AES-256-ga <code>cwallet.sso</code> failis. '
                                              'Dekrüpteerimine toimub ainult mälus, mitte kunagi kettal.',
                                        'fi': 'Salaisuudet tallennetaan AES-256-salattuina '
                                              '<code>cwallet.sso</code>-tiedostoon. Purkaminen tapahtuu vain '
                                              'muistissa.',
                                        'sv': 'Hemligheter lagras krypterade med AES-256 i <code>cwallet.sso</code>. '
                                              'Dekryptering sker enbart i minnet.',
                                        'lv': 'Noslēpumi šifrēti ar AES-256 failā <code>cwallet.sso</code>. '
                                              'Atšifrēšana notiek tikai operatīvajā atmiņā.',
                                        'lt': 'Paslaptys šifruojamos AES-256 faile <code>cwallet.sso</code>. '
                                              'Iššifravimas atliekamas tik atmintyje.'}},
                        {   'icon': '🧠',
                            'kpi': 'RAM TMPFS',
                            'title': {   'en': 'RAM-Mounted Secrets',
                                         'et': 'Mälupõhine hoidla (tmpfs)',
                                         'fi': 'Muistipohjainen tmpfs-tallennus',
                                         'sv': 'Minnesbaserad tmpfs-lagring',
                                         'lv': 'Atmiņas tmpfs krātuve',
                                         'lt': 'Atmintyje esanti tmpfs saugykla'},
                            'desc': {   'en': 'Container administrator passwords injected dynamically into RAM tmpfs '
                                              'mounts, never written to disk or image layers.',
                                        'et': 'Konteinerite paroolid süstitakse käivitamisel RAM-põhisesse tmpfs '
                                              'hoidlasse, mitte püsikettale ega tõmmise kihtidesse.',
                                        'fi': 'Konttien salasanat syötetään käynnistyksessä suoraan muistin '
                                              'tmpfs-liitokseen, ei koskaan levylle tai levykuviin.',
                                        'sv': 'Lösenord matas in vid start direkt till minnets tmpfs, aldrig till disk '
                                              'eller containerlager.',
                                        'lv': 'Paroles tiek ievadītas konteineru startēšanā tieši atmiņas tmpfs '
                                              'krātuvē, nevis diska slāņos.',
                                        'lt': 'Slaptažodžiai įterpiami paleidžiant tiesiai į atminties tmpfs, niekada '
                                              'neįrašomi į diską ar atvaizdą.'}},
                        {   'icon': '🔄',
                            'kpi': '1-KLIKK',
                            'title': {   'en': '1-Click Credential Rotation',
                                         'et': '1-klikiga paroolide rotatsioon',
                                         'fi': '1-klikkauksen salasanarotaatio',
                                         'sv': '1-klicks lösenordsrotation',
                                         'lv': '1-klikšķa paroļu rotācija',
                                         'lt': '1-paspaudimo slaptažodžių rotacija'},
                            'desc': {   'en': 'Execute <code>./scripts/rotate-password.sh</code> to automatically '
                                              'update database and wallet credentials in lockstep.',
                                        'et': 'Käsk <code>./scripts/rotate-password.sh</code> uuendab sünkroonis nii '
                                              'andmebaasi kui ka Walleti paroolid ilma seisakuta.',
                                        'fi': 'Komento <code>./scripts/rotate-password.sh</code> päivittää sekä '
                                              'tietokannan että Walletin salasanat ilman katkoa.',
                                        'sv': 'Kör <code>./scripts/rotate-password.sh</code> för att uppdatera databas '
                                              'och wallet i ett enda steg.',
                                        'lv': 'Komanda <code>./scripts/rotate-password.sh</code> sinhroni atjaunina '
                                              'paroles datubāzē un makā bez dīkstāves.',
                                        'lt': 'Komanda <code>./scripts/rotate-password.sh</code> atnaujina '
                                              'slaptažodžius DB ir piniginėje be prastovos.'},
                            'command': './scripts/rotate-password.sh'}],
           'speaker_notes': {   'en': '🎯 Core Takeaway: DBAs retain strict architectural and security standards while '
                                      'liberating developers to move fast.<br/>💡 Talking Points: Point out that '
                                      'plaintext passwords on laptops are a massive enterprise audit liability. SEPS '
                                      'Wallet enforces production security in local environments.<br/>⚠️ Key Emphasis: '
                                      'Emphasize that rotating passwords requires zero downtime and zero code '
                                      'modifications because apps connect via TNS aliases.',
                                'et': '🎯 Peamine sõnum: DBA säilitab täieliku kontrolli turvastandardite üle, '
                                      'vabastades samal ajal arendajad administratiivsest koormusest.<br/>💡 Esitaja '
                                      'rääkimispunktid: Paroolide hoidmine tekstifailides või .env failides on '
                                      'ettevõtte auditile suur risk. SEPS Wallet toob toodangutasemel turvalisuse juba '
                                      'lokaalsesse masinasse.<br/>⚠️ Mida rõhutada: Paroolide rotatsioon toimub ilma '
                                      'seisakuta ja koodi muutmata, sest kõik ühendused kasutavad TNS aliaseid.',
                                'fi': '🎯 Pääviesti: DBA säilyttää tiukat arkkitehtuuri- ja tietoturvastandardit antaen '
                                      'kehittäjille vapauden toimia nopeasti.<br/>💡 Puhujan muistiinpanot: '
                                      'Selkokieliset salasanat tiedostoissa ovat merkittävä auditointiriski. SEPS '
                                      'Wallet tuo tuotantoturvallisuuden paikalliseen kehitykseen.<br/>⚠️ Tärkeä '
                                      'painotus: Salasanarotaatio tapahtuu ilman katkoja ja ilman koodimuutoksia '
                                      'TNS-aliasten ansiosta.',
                                'sv': '🎯 Huvudbudskap: DBA behåller full arkitektur- och säkerhetskontroll samtidigt '
                                      'som utvecklarna kan agera snabbt.<br/>💡 Talarpunkter: Klartextlösenord på '
                                      'utvecklardatorer är en stor revisionsrisk. SEPS Wallet tillämpar samma säkerhet '
                                      'lokalt som i produktion.<br/>⚠️ Vad som bör betonas: Lösenordsrotation sker '
                                      'utan driftstopp och utan kodändringar tack vare TNS-alias.',
                                'lv': '🎯 Galvenais vēstījums: DBA saglabā pilnu drošības kontroli, vienlaikus '
                                      'atbrīvojot izstrādātājus no administratīvā sloga.<br/>💡 Runātāja piezīmes: '
                                      'Atklāta teksta paroles datoros ir liels drošības risks. SEPS Wallet ievieš '
                                      'ražošanas līmeņa drošību jau lokāli.<br/>⚠️ Ko uzsvērt: Paroļu rotācija notiek '
                                      'bez dīkstāves un bez koda labošanas, jo tiek izmantoti TNS aizstājējvārdi.',
                                'lt': '🎯 Pagrindinė žinutė: DBA išlaiko pilną saugumo kontrolę, suteikdamas kūrėjams '
                                      'laisvę veikti greitai.<br/>💡 Pranešėjo pastabos: Tekstiniai slaptažodžiai '
                                      'kompiuteriuose kelia didelę audito riziką. SEPS Wallet suteikia gamybos lygio '
                                      'saugumą vietiškai.<br/>⚠️ Ką akcentuoti: Slaptažodžių rotacija vyksta be '
                                      'prastovų ir be kodo keitimo, nes visur naudojami TNS aliasai.'}},
    7: {   'badge': {   'en': '🧩 SLIDE 7 / 13 • MODULAR SERVICES',
                        'et': '🧩 SLAID 7 / 13 • MODULAARSED TEENUSED',
                        'fi': '🧩 DIA 7 / 13 • MODULAARISET PALVELUT',
                        'sv': '🧩 BILD 7 / 13 • MODULÄRA TJÄNSTER',
                        'lv': '🧩 SLAIDS 7 / 13 • MODULĀRI PAKALPOJUMI',
                        'lt': '🧩 SKAIDRĖ 7 / 13 • MODULINĖS PASLAUGOS'},
           'title': {   'en': '8 Modular Services Across 4 Architecture Tiers',
                        'et': '8 modulaarset teenust neljas arhitektuurikihis',
                        'fi': '8 modulaarista palvelua neljässä arkkitehtuurikerroksessa',
                        'sv': '8 modulära tjänster över 4 arkitekturnivåer',
                        'lv': '8 modulāri pakalpojumi 4 arhitektūras slāņos',
                        'lt': '8 modulinės paslaugos 4 architektūros lygmenyse'},
           'lead': {   'en': 'Decoupled architecture separating proxy infrastructure, business data, reporting, and '
                             'browser workplaces.',
                       'et': 'Lahtisidestatud arhitektuur, mis eraldab proxy-taristu, äriandmed, aruandluse ja '
                             'brauseritöökohad.',
                       'fi': 'Hajautettu arkkitehtuuri, joka erottaa proxy-infrastruktuurin, liiketoimintadatan, '
                             'raportoinnin ja työpisteet.',
                       'sv': 'Frånkopplad arkitektur som separerar proxyinfrastruktur, affärsdata, rapportering och '
                             'webbarbetsplatser.',
                       'lv': 'Sadalīta arhitektūra, kas nodala proxy infrastruktūru, biznesa datus, atskaites un '
                             'pārlūka darba vietas.',
                       'lt': 'Atskirta architektūra, atskirianti proxy infrastruktūrą, verslo duomenis, ataskaitas ir '
                             'naršyklės darbo vietas.'},
           'cards': [   {   'icon': '🏛️',
                            'kpi': 'KIHT 1: ANDMED',
                            'title': {   'en': 'Tier 1: Proxy DB &amp; Business DB (Alise)',
                                         'et': 'Kiht 1: Proxy andmebaas ja Äribaas (Alise)',
                                         'fi': 'Kerros 1: Proxy-tietokanta &amp; Alise-liiketoimintakanta',
                                         'sv': 'Nivå 1: Proxy-databas &amp; Alise affärsdatabas',
                                         'lv': 'Slānis 1: Proxy datubāze un Alise biznesa bāze',
                                         'lt': 'Lygmuo 1: Proxy duomenų bazė ir Alise verslo DB'},
                            'desc': {   'en': '<b>Proxy DB:</b> Houses APEX &amp; ORDS without business '
                                              'data.<br/><b>Business DB (Alise):</b> Dedicated schema instance, '
                                              'keeping Free DB limits (2GB RAM / 12GB disk) strictly optimized.',
                                        'et': '<b>Proxy DB:</b> Hoiab APEX mootorit ja ORDS väravaid ilma '
                                              'äriandmeteta.<br/><b>Äribaas (Alise):</b> Eraldi andmebaas '
                                              'äriandmetele, optimeerides Free DB ressursse (2GB RAM / 12GB ketas).',
                                        'fi': '<b>Proxy DB:</b> Sisältää APEXin ja ORDS:n ilman '
                                              'liiketoimintadataa.<br/><b>Alise DB:</b> Erillinen kanta älykkäästi '
                                              'mitoitettuna Free DB:n rajoille (2GB/12GB).',
                                        'sv': '<b>Proxy DB:</b> Kör APEX och ORDS utan affärsdata.<br/><b>Alise '
                                              'DB:</b> Dedikerad schemainstans optimerad för Free DB-resurserna '
                                              '(2GB/12GB).',
                                        'lv': '<b>Proxy DB:</b> Satur APEX un ORDS bez biznesa datiem.<br/><b>Alise '
                                              'DB:</b> Atsevišķa datubāze, optimizējot Free DB resursus (2GB RAM / '
                                              '12GB disks).',
                                        'lt': '<b>Proxy DB:</b> Talpina APEX ir ORDS be verslo duomenų.<br/><b>Alise '
                                              'DB:</b> Atskira instancija, optimizuota Free DB riboms (2GB RAM / 12GB '
                                              'diskas).'}},
                        {   'icon': '📊',
                            'kpi': 'KIHT 2: SERVERID',
                            'title': {   'en': 'Tier 2: Standalone ORDS &amp; Analytics Publisher',
                                         'et': 'Kiht 2: Eraldi ORDS server ja Analytics Publisher',
                                         'fi': 'Kerros 2: Itsenäinen ORDS &amp; Analytics Publisher',
                                         'sv': 'Nivå 2: Fristående ORDS &amp; Analytics Publisher',
                                         'lv': 'Slānis 2: Atsevišķs ORDS un Analytics Publisher',
                                         'lt': 'Lygmuo 2: Atskiras ORDS ir Analytics Publisher'},
                            'desc': {   'en': '<b>Standalone ORDS:</b> Dedicated REST API application tier without DB '
                                              'compute overhead.<br/><b>Analytics Publisher:</b> Enterprise '
                                              'pixel-perfect PDF/Excel document generation engine.',
                                        'et': '<b>Eraldi ORDS:</b> Iseseisev REST kiht koormuse hajutamiseks ilma '
                                              'baasi koormamata.<br/><b>Analytics Publisher:</b> Pixel-perfect '
                                              'PDF/Excel aruandlus- ja trükimootor.',
                                        'fi': '<b>Itsenäinen ORDS:</b> Dedikoitu REST API -kerros ilman tietokannan '
                                              'kuormitusta.<br/><b>Analytics Publisher:</b> Yritystason pikselintarkka '
                                              'PDF/Excel -raportointimoottori.',
                                        'sv': '<b>Fristående ORDS:</b> Dedikerat REST API-lager utan belastning på '
                                              'databasen.<br/><b>Analytics Publisher:</b> Pixel-perfect '
                                              'PDF/Excel-rapportmotor för företag.',
                                        'lv': '<b>Atsevišķs ORDS:</b> Dedicēts REST API slānis bez datubāzes '
                                              'noslodzes.<br/><b>Analytics Publisher:</b> Uzņēmuma līmeņa PDF/Excel '
                                              'atskaišu ģenerators.',
                                        'lt': '<b>Atskiras ORDS:</b> Dedikuotas REST API sluoksnis be DB '
                                              'apkrovos.<br/><b>Analytics Publisher:</b> Įmonės lygio pikselių '
                                              'tikslumo PDF/Excel ataskaitų variklis.'}},
                        {   'icon': '🎨',
                            'kpi': 'KIHT 3: DISAIN',
                            'title': {   'en': 'Tier 3: Forms 14c Runtime &amp; Publisher Designer',
                                         'et': 'Kiht 3: Oracle Forms 14c ja Publisher Designer',
                                         'fi': 'Kerros 3: Forms 14c Runtime &amp; Publisher Designer',
                                         'sv': 'Nivå 3: Forms 14c Runtime &amp; Publisher Designer',
                                         'lv': 'Slānis 3: Forms 14c Runtime un Publisher Designer',
                                         'lt': 'Lygmuo 3: Forms 14c Runtime ir Publisher Designer'},
                            'desc': {   'en': '<b>Oracle Forms 14c:</b> Modernized runtime for running existing '
                                              'enterprise forms (excl. builder).<br/><b>Publisher Designer:</b> '
                                              'Desktop template visual designer in browser.',
                                        'et': '<b>Oracle Forms 14c:</b> Moderniseeritud käituskeskkond olemasolevatele '
                                              'vormidele (v.a builder).<br/><b>Publisher Designer:</b> Töölaua '
                                              'aruandemallide kujundaja veebis.',
                                        'fi': '<b>Oracle Forms 14c:</b> Modernisoitu ajoympäristö olemassa oleville '
                                              'lomakkeille.<br/><b>Publisher Designer:</b> Työpöytäraporttien '
                                              'visuaalinen suunnittelu selaimessa.',
                                        'sv': '<b>Oracle Forms 14c:</b> Moderniserad körmiljö för befintliga '
                                              'formulär.<br/><b>Publisher Designer:</b> Visuell mallredigerare direkt '
                                              'i webbläsaren.',
                                        'lv': '<b>Oracle Forms 14c:</b> Modernizēta izpildes vide esošajām formām (bez '
                                              'builder).<br/><b>Publisher Designer:</b> Pārskatu veidņu vizuālais '
                                              'redaktors pārlūkā.',
                                        'lt': '<b>Oracle Forms 14c:</b> Modernizuota vykdymo aplinka esamoms formoms '
                                              '(be builder).<br/><b>Publisher Designer:</b> Ataskaitų šablonų vizualus '
                                              'redaktorius naršyklėje.'}},
                        {   'icon': '💻',
                            'kpi': 'KIHT 4: TÖÖKOHT',
                            'title': {   'en': 'Tier 4: Web-IDE &amp; Remote DB Gateways',
                                         'et': 'Kiht 4: Web-IDE ja kaugväravad / OCI sild',
                                         'fi': 'Kerros 4: Web-IDE &amp; etäyhdyskäytävät (OCI)',
                                         'sv': 'Nivå 4: Web-IDE &amp; fjärrgateways (OCI)',
                                         'lv': 'Slānis 4: Web-IDE un attālās vārtejas / OCI tilts',
                                         'lt': 'Lygmuo 4: Web-IDE ir nuotoliniai vartai / OCI tiltas'},
                            'desc': {   'en': '<b>Web-IDE:</b> VS Code, Python, Antigravity AI, local CI '
                                              'emulation for locked-down corporate PCs.<br/><b>Remote Gateways:</b> '
                                              'Direct mTLS bridge to OCI Autonomous Database.',
                                        'et': '<b>Web-IDE:</b> VS Code, Python, Antigravity AI ja CI '
                                              'emulatsioon rangetele töökohapoliitikatele.<br/><b>Kaugväravad:</b> '
                                              'Turvaline mTLS sild OCI Autonomous Database pilve.',
                                        'fi': '<b>Web-IDE:</b> VS Code, Python, Antigravity AI ja CI-emulaatio '
                                              'tiukkoihin työpaikkakäytäntöihin.<br/><b>Etäyhdyskäytävät:</b> Suora '
                                              'mTLS-silta OCI Autonomous Database -pilveen.',
                                        'sv': '<b>Web-IDE:</b> VS Code, Python, Antigravity AI och lokal CI-emulering '
                                              'för låsta datorer.<br/><b>Fjärrgateways:</b> Direkt mTLS-brygga till '
                                              'OCI Autonomous Database i molnet.',
                                        'lv': '<b>Web-IDE:</b> VS Code, Python, Antigravity AI un CI emulācija stingri '
                                              'aizsargātiem datoriem.<br/><b>Attālās vārtejas:</b> Drošs mTLS tilts uz '
                                              'OCI Autonomous Database mākoni.',
                                        'lt': '<b>Web-IDE:</b> VS Code, Python, Antigravity AI ir CI emuliacija '
                                              'ribojamiems įmonės kompiuteriams.<br/><b>Nuotoliniai vartai:</b> Saugus '
                                              'mTLS tiltas į OCI Autonomous Database debesį.'}}],
           'speaker_notes': {   'en': '🎯 Core Takeaway: Decoupling architecture into 4 tiers solves the Free DB '
                                      'resource constraint (2GB RAM) and enterprise policy barriers.<br/>💡 Talking '
                                      'Points: Explain why Proxy DB holds APEX/ORDS while Business DB (Alise) holds '
                                      'actual application schemas. Mention Web-IDE as the solution when corporate '
                                      'policies forbid installing Podman on work laptops.<br/>⚠️ Key Emphasis: '
                                      'Highlight that Publisher Designer and Antigravity AI are currently in pilot '
                                      'testing, showing active continuous platform evolution.',
                                'et': '🎯 Peamine sõnum: Arhitektuuri jagamine 4 kihiks lahendab Free DB '
                                      'ressursipiirangu (2GB RAM) ja rangete töökohapoliitikate tõkked.<br/>💡 Esitaja '
                                      'rääkimispunktid: Selgita, miks Proxy andmebaas hoiab APEX/ORDS-i ning Äribaas '
                                      '(Alise) hoiab tegelikke äriandmeid. Web-IDE on elupäästja, kui turvapoliitika '
                                      'keelab Dockeri paigaldamise tööarvutisse.<br/>⚠️ Mida rõhutada: Märgi ära, et '
                                      'Publisher Designer ja Antigravity AI on aktiivses piloteerimisfaasis, näidates '
                                      'platvormi pidevat uuenemist.',
                                'fi': '🎯 Pääviesti: Arkkitehtuurin jakaminen 4 kerrokseen ratkaisee Free DB:n '
                                      'muistirajoitukset (2GB RAM) ja yritysten IT-rajoitteet.<br/>💡 Puhujan '
                                      'muistiinpanot: Selitä, miksi Proxy DB erotetaan Alise-liiketoimintakannasta. '
                                      'Web-IDE on erinomainen ratkaisu, jos paikallinen asennus on kielletty.<br/>⚠️ '
                                      'Tärkeä painotus: Mainitse, että Publisher Designer ja Antigravity AI ovat tällä '
                                      'hetkellä pilottivaiheessa.',
                                'sv': '🎯 Huvudbudskap: Att dela upp arkitekturen i 4 nivåer löser resursbegränsningen '
                                      'i Free DB (2GB RAM) och företagens IT-policys.<br/>💡 Talarpunkter: Förklara '
                                      'varför Proxy DB kör APEX/ORDS medan affärsdatabasen (Alise) körs separat. '
                                      'Web-IDE löser problemet när låsta datorer hindrar lokal '
                                      'containerkörning.<br/>⚠️ Vad som bör betonas: Notera att Publisher Designer och '
                                      'Antigravity AI pilottestas för närvarande.',
                                'lv': '🎯 Galvenais vēstījums: Arhitektūras sadalīšana 4 slāņos atrisina Free DB '
                                      'resursu ierobežojumus (2GB RAM) un drošības politikas.<br/>💡 Runātāja piezīmes: '
                                      'Paskaidrojiet Proxy DB un Alise biznesa bāzes nodalīšanu. Web-IDE ir risinājums '
                                      'slēgtām korporatīvajām darbstacijām.<br/>⚠️ Ko uzsvērt: Norādiet, ka Publisher '
                                      'Designer un Antigravity AI pašlaik ir pilotēšanas stadijā.',
                                'lt': '🎯 Pagrindinė žinutė: Architektūros padalijimas į 4 sluoksnius išsprendžia Free '
                                      'DB resursų ribas (2GB RAM) ir IT politikos barjerus.<br/>💡 Pranešėjo pastabos: '
                                      'Paaiškinkite Proxy DB ir Alise verslo DB atskyrimą. Web-IDE išsprendžia '
                                      'problemą, kai įmonės kompiuteriuose draudžiama diegti programas.<br/>⚠️ Ką '
                                      'akcentuoti: Paminėkite, kad Publisher Designer ir Antigravity AI šiuo metu yra '
                                      'bandomojoje fazėje.'}},
    8: {   'badge': {   'en': '🐳 SLIDE 8 / 13 • PODMAN &amp; HYBRID CLOUD',
                        'et': '🐳 SLAID 8 / 13 • PODMAN JA HÜBRIIDPILV',
                        'fi': '🐳 DIA 8 / 13 • PODMAN &amp; HYBRIDI-PILVI',
                        'sv': '🐳 BILD 8 / 13 • PODMAN &amp; HYBRIDMOLN',
                        'lv': '🐳 SLAIDS 8 / 13 • PODMAN UN HIBRĪDA MĀKONIS',
                        'lt': '🐳 SKAIDRĖ 8 / 13 • PODMAN IR HIBRIDINIS DEBESIS'},
           'title': {   'en': 'Podman Infrastructure Cockpit &amp; Hybrid Cloud Migration',
                        'et': 'Podman taristu juhtimine ja hübriidne pilvemigratsioon',
                        'fi': 'Podman-infrastruktuurin hallinta ja hybridi-pilvimigraatio',
                        'sv': 'Podman infrastrukturhantering och hybridmolnmigrering',
                        'lv': 'Podman infrastruktūras vadība un hibrīda mākoņa migrācija',
                        'lt': 'Podman infrastruktūros valdymas ir hibridinė debesų migracija'},
           'lead': {   'en': 'Deep operational visibility into containers, storage, and networking with a frictionless '
                             'path to OCI Autonomous Database.',
                       'et': 'Täielik ülevaade konteineritest, andmemahtudest ja võrkudest ning sujuv teekond OCI '
                             'Autonomous Database pilve.',
                       'fi': 'Syvällinen näkyvyys kontteihin, levyihin ja verkkoihin sekä saumaton polku OCI '
                             'Autonomous Database -pilveen.',
                       'sv': 'Djup operativ insyn i containrar, lagring och nätverk med en friktionsfri väg till OCI '
                             'Autonomous Database.',
                       'lv': 'Pilnīga pārskatāmība par konteineriem, krātuvēm un tīkliem ar ērtu ceļu uz OCI '
                             'Autonomous Database mākoni.',
                       'lt': 'Išsamus matomumas į konteinerius, saugyklas ir tinklus su sklandžiu keliu į OCI '
                             'Autonomous Database debesį.'},
           'cards': [   {   'icon': '📊',
                            'kpi': '4 VAADET',
                            'title': {   'en': '4-Pillar Podman Cockpit',
                                         'et': 'Podman 4-vaateline juhtpaneel',
                                         'fi': 'Podmanin 4-pilarinen ohjaamo',
                                         'sv': 'Podman 4-pelarpanel i Dev Hub',
                                         'lv': 'Podman 4-skatu vadības panelis',
                                         'lt': 'Podman 4-sričių valdymo skydelis'},
                            'desc': {   'en': 'Real-time inspection of Containers, Volumes, Networks, and Images '
                                              'directly in Dev Hub without terminal context switches.',
                                        'et': 'Konteinerite, andmemahtude, võrkude ja tõmmiste reaalajas monitooring '
                                              'ja haldus otse Dev Hubis ilma terminalita.',
                                        'fi': 'Konttien, levyjen, verkkojen ja levykuvien reaaliaikainen hallinta '
                                              'suoraan Dev Hubissa ilman komentorivikikkailua.',
                                        'sv': 'Realtidsinsyn i containrar, volymer, nätverk och images direkt i Dev '
                                              'Hub utan terminalhopp.',
                                        'lv': 'Konteineru, sējumu, tīklu un attēlu reāllaika pārraudzība tieši Dev Hub '
                                              'bez komandrindas pārslēgšanas.',
                                        'lt': 'Konteinerių, tomų, tinklų ir atvaizdų stebėsena realiuoju laiku tiesiai '
                                              'Dev Hub be terminalo perjungimo.'}},
                        {   'icon': '🛡️',
                            'kpi': 'ROOTLESS',
                            'title': {   'en': 'Rootless Security &amp; No Daemons',
                                         'et': 'Rootless turvalisus ilma deemonita',
                                         'fi': 'Rootless-turvallisuus ilman daemonia',
                                         'sv': 'Rootless-säkerhet utan bakgrundsdaemon',
                                         'lv': 'Rootless drošība bez fona dēmona',
                                         'lt': 'Rootless saugumas be foninio proceso'},
                            'desc': {   'en': 'Podman eliminates centralized Docker daemon vulnerabilities, running '
                                              'unprivileged containers compliant with enterprise policies.',
                                        'et': 'Podman välistab dockerd deemoni turvariskid, käitades rootless '
                                              'konteinereid vastavalt rangetele sisekorraeeskirjadele.',
                                        'fi': 'Podman poistaa Docker-daemonin haavoittuvuudet ja ajaa etuoikeudettomia '
                                              'kontteja yrityspolitiikkojen mukaisesti.',
                                        'sv': 'Podman eliminerar sårbarheter med Docker-daemons genom att köra '
                                              'oprivilegierade containrar enligt IT-krav.',
                                        'lv': 'Podman novērš Docker dēmona ievainojamības, darbinot ne-root '
                                              'konteinerus atbilstoši uzņēmuma prasībām.',
                                        'lt': 'Podman pašalina Docker proceso rizikas, paleisdamas neprivilegijuotus '
                                              'konteinerius pagal įmonės taisykles.'}},
                        {   'icon': '☁️',
                            'kpi': 'HÜBRIIDNE',
                            'title': {   'en': 'Frictionless OCI &amp; On-Premises Migration',
                                         'et': 'Hübriidne pilve- ja serverimigratsioon',
                                         'fi': 'Saumaton OCI- ja on-premises -migraatio',
                                         'sv': 'Friktionsfri migrering till OCI och On-Prem',
                                         'lv': 'Hibrīda mākoņa un lokālā servera migrācija',
                                         'lt': 'Sklandi OCI ir vietinės infrastruktūros migracija'},
                            'desc': {   'en': 'Develop locally in 23ai Free DB; deploy effortlessly to OCI Autonomous '
                                              'Database or Enterprise On-Premises via standard SQLcl &amp; Git.',
                                        'et': 'Arenda lokaalselt Free DB-s ning vii toodangusse OCI Autonomous '
                                              "Database'i või oma serverisse sama Git CI/CD abil.",
                                        'fi': 'Kehitä paikallisesti Free DB:llä ja siirrä tuotantoon OCI Autonomous '
                                              'Databaseen tai omaan palvelimeen Gitillä.',
                                        'sv': 'Utveckla lokalt i Free DB och distribuera enkelt till OCI Autonomous '
                                              'Database eller On-Premises via Git.',
                                        'lv': 'Izstrādājiet lokāli Free DB un piegādājiet OCI Autonomous Database '
                                              'mākonī vai serverī ar vienotu Git CI/CD.',
                                        'lt': 'Kurkite vietiškai Free DB ir perkelkite į OCI Autonomous Database ar '
                                              'serverius su bendru Git CI/CD.'}}],
           'speaker_notes': {   'en': '🎯 Core Takeaway: Developers build locally with zero cloud costs, but workloads '
                                      'seamlessly scale to enterprise clouds when ready.<br/>💡 Talking Points: '
                                      'Highlight the newly added Podman tab in Dev Hub that lets non-technical users '
                                      'inspect containers and networks with zero CLI knowledge.<br/>⚠️ Key Emphasis: '
                                      'Emphasize rootless container execution, which satisfies strict enterprise '
                                      'security requirements where Docker daemon is forbidden.',
                                'et': '🎯 Peamine sõnum: Arendajad ehitavad lokaalselt null pilvekuluga, kuid '
                                      'lahendused skaleeruvad sujuvalt ettevõtte pilve, kui need on valmis.<br/>💡 '
                                      'Esitaja rääkimispunktid: Too esile värskelt lisatud Podmani vahekaart Dev '
                                      'Hubis, mis annab täieliku ülevaate konteineritest ja võrkudest ilma käsurida '
                                      'puutumata.<br/>⚠️ Mida rõhutada: Rõhuta rootless konteinerite turvalisust – '
                                      'Podman töötab ilma priviligeeritud deemoni õigusteta.',
                                'fi': '🎯 Pääviesti: Kehitys tapahtuu paikallisesti nollakuluilla, mutta sovellukset '
                                      'skaalautuvat saumattomasti pilveen, kun ne ovat valmiita.<br/>💡 Puhujan '
                                      'muistiinpanot: Korosta Dev Hubin uutta Podman-välilehteä, joka antaa selkeän '
                                      'graafisen kuvan konteista ja verkosta ilman CLI-osaamista.<br/>⚠️ Tärkeä '
                                      'painotus: Rootless-kontit täyttävät yritysten tiukat turvavaatimukset, joissa '
                                      'Docker-daemon on kielletty.',
                                'sv': '🎯 Huvudbudskap: Utvecklare bygger lokalt utan molnkostnader, men lösningen '
                                      'skalar sömlöst till OCI när den är redo.<br/>💡 Talarpunkter: Visa den nya '
                                      'Podman-fliken i Dev Hub som ger full insyn i containrar och nätverk utan '
                                      'terminalkommandon.<br/>⚠️ Vad som bör betonas: Betona rootless-körning som '
                                      'uppfyller säkerhetskrav där Docker-daemons inte är tillåtna.',
                                'lv': '🎯 Galvenais vēstījums: Izstrāde notiek lokāli bez mākoņa izmaksām, bet darba '
                                      'slodzes vienkārši pārvietojas uz mākoni.<br/>💡 Runātāja piezīmes: Pievērsiet '
                                      'uzmanību jaunajai Podman sadaļai Dev Hub, kas ļauj pārskatīt resursus bez '
                                      'komandrindas.<br/>⚠️ Ko uzsvērt: Rootless konteineru drošība atbilst stingrām '
                                      'korporatīvajām prasībām.',
                                'lt': '🎯 Pagrindinė žinutė: Kūrimas vyksta vietiškai be debesų išlaidų, tačiau '
                                      'sprendimai sklandžiai perkeliami į OCI debesį.<br/>💡 Pranešėjo pastabos: '
                                      'Pabrėžkite naują Podman skiltį Dev Hub, kuri leidžia valdyti konteinerius be '
                                      'komandinės eilutės.<br/>⚠️ Ką akcentuoti: Rootless konteineriai atitinka '
                                      'griežčiausius saugumo reikalavimus, kur Docker daemon yra draudžiamas.'}},
    9: {   'badge': {   'en': '🔐 SLIDE 9 / 13 • ZERO-TRUST ARCHITECTURE',
                        'et': '🔐 SLAID 9 / 13 • ZERO-TRUST ARHITEKTUUR',
                        'fi': '🔐 DIA 9 / 13 • ZERO-TRUST -ARKKITEHTUURI',
                        'sv': '🔐 BILD 9 / 13 • ZERO-TRUST-ARKITEKTUR',
                        'lv': '🔐 SLAIDS 9 / 13 • ZERO-TRUST ARHITEKTŪRA',
                        'lt': '🔐 SKAIDRĖ 9 / 13 • ZERO-TRUST ARCHITEKTŪRA'},
           'title': {   'en': 'Oracle SEPS Wallet &amp; Passwordless Connectivity',
                        'et': 'Oracle SEPS Wallet ja paroolivaba autentimine',
                        'fi': 'Oracle SEPS Wallet ja salasanaton yhteys',
                        'sv': 'Oracle SEPS Wallet och lösenordsfri anslutning',
                        'lv': 'Oracle SEPS Wallet un bezparoļu autentifikācija',
                        'lt': 'Oracle SEPS Wallet ir beslaptažodis prisijungimas'},
           'lead': {   'en': 'Hardware-grade credential isolation: AES-256 encrypted auto-login wallet with zero '
                             'plaintext on disk.',
                       'et': 'Paroolivaba autentimine: AES-256 krüpteeritud auto-login wallet ja null parooli failides '
                             'või koodis.',
                       'fi': 'Yritystason salasanasuojaus: AES-256-salattu auto-login wallet ilman selkokielisiä '
                             'salasanoja levyllä.',
                       'sv': 'Hårdvaruklassad isolering av autentiseringsuppgifter: AES-256-krypterad auto-login '
                             'wallet utan klartext på disk.',
                       'lv': 'Augstākā līmeņa noslēpumu izolācija: AES-256 šifrēts auto-login maks bez atklāta teksta '
                             'failiem diskā.',
                       'lt': 'Aukščiausio lygio duomenų izoliacija: AES-256 šifruota auto-login piniginė be atviro '
                             'teksto diske.'},
           'cards': [   {   'icon': '🛡️',
                            'kpi': 'AES-256',
                            'title': {   'en': 'Auto-Login Wallet (cwallet.sso)',
                                         'et': 'Auto-Login Wallet (cwallet.sso)',
                                         'fi': 'Auto-Login Wallet (cwallet.sso)',
                                         'sv': 'Auto-Login Wallet (cwallet.sso)',
                                         'lv': 'Auto-Login maks (cwallet.sso)',
                                         'lt': 'Auto-Login piniginė (cwallet.sso)'},
                            'desc': {   'en': 'CLI and apps connect securely using TNS alias: <code>sql '
                                              '/@DB_ALISE_DEV</code>. Just-In-Time AES-256 in-memory decryption only.',
                                        'et': 'Kõik tööriistad kasutavad TNS aliast: <code>sql /@DB_ALISE_DEV</code>. '
                                              'Parool dekrüpteeritakse automaatselt ainult mälus.',
                                        'fi': 'Yhteydet muodostetaan suojatusti TNS-aliaksella: <code>sql '
                                              '/@DB_ALISE_DEV</code>. Vain muistissa tapahtuva AES-256-purku.',
                                        'sv': 'Verktyg ansluter säkert via TNS-alias: <code>sql /@DB_ALISE_DEV</code>. '
                                              'AES-256-dekryptering sker enbart i RAM.',
                                        'lv': 'Rīki pieslēdzas droši ar TNS aizstājējvārdu: <code>sql '
                                              '/@DB_ALISE_DEV</code>. AES-256 atšifrēšana notiek tikai operatīvajā '
                                              'atmiņā.',
                                        'lt': 'Įrankiai jungiasi saugiai naudodami TNS aliasą: <code>sql '
                                              '/@DB_ALISE_DEV</code>. AES-256 iššifravimas atliekamas tik RAM '
                                              'atmintyje.'}},
                        {   'icon': '🧠',
                            'kpi': '0 PLAIN DISK',
                            'title': {   'en': 'RAM-Only Secret Storage',
                                         'et': 'Mälupõhine saladuste hoidla (tmpfs)',
                                         'fi': 'Vain muistissa säilytettävät salaisuudet',
                                         'sv': 'Endast i RAM-minne (tmpfs)',
                                         'lv': 'Tikai atmiņā glabāti noslēpumi',
                                         'lt': 'Tik atmintyje saugomos paslaptys'},
                            'desc': {   'en': 'Administrator credentials mounted via Podman Secrets directly into '
                                              'container tmpfs memory; never written to storage.',
                                        'et': 'Administraatorite paroolid süstitakse Podman Secrets kaudu otse '
                                              'konteineri mällu (tmpfs), mitte kunagi failina kettale.',
                                        'fi': 'Ylläpitäjän salasanat liitetään Podman Secretsin kautta suoraan kontin '
                                              'tmpfs-muistiin, ei koskaan levylle.',
                                        'sv': 'Administratörsuppgifter monteras via Podman Secrets direkt i '
                                              'containerns tmpfs-minne, aldrig till disk.',
                                        'lv': 'Paroles tiek ievadītas ar Podman Secrets tieši konteinera tmpfs atmiņā, '
                                              'nekad diskā.',
                                        'lt': 'Administratoriaus slaptažodžiai perduodami per Podman Secrets tiesiai į '
                                              'tmpfs atmintį, niekada ne į diską.'}},
                        {   'icon': '🔄',
                            'kpi': 'ZERO DOWNTIME',
                            'title': {   'en': 'Zero-Downtime Credential Rotation',
                                         'et': 'Paroolide rotatsioon ilma seisakuta',
                                         'fi': 'Katkoton salasanarotaatio',
                                         'sv': 'Lösenordsrotation utan avbrott',
                                         'lv': 'Paroļu rotācija bez dīkstāves',
                                         'lt': 'Slaptažodžių rotacija be prastovų'},
                            'desc': {   'en': 'Rotate passwords across database and SEPS Wallet simultaneously with '
                                              '<code>./scripts/rotate-password.sh</code>.',
                                        'et': 'Uuenda andmebaasi ja Walleti paroole samaaegselt ühe käsuga '
                                              '<code>./scripts/rotate-password.sh</code>.',
                                        'fi': 'Päivitä salasanat tietokantaan ja SEPS Walletiin samanaikaisesti '
                                              'komennolla <code>./scripts/rotate-password.sh</code>.',
                                        'sv': 'Rotera lösenord i databas och SEPS Wallet synkront med '
                                              '<code>./scripts/rotate-password.sh</code>.',
                                        'lv': 'Atjauniniet paroles datubāzē un makā reizē ar '
                                              '<code>./scripts/rotate-password.sh</code>.',
                                        'lt': 'Atnaujinkite slaptažodžius DB ir SEPS Wallet vienu metu su '
                                              '<code>./scripts/rotate-password.sh</code>.'}}],
           'speaker_notes': {   'en': '🎯 Core Takeaway: Zero passwords in source code, scripts, environment variables, '
                                      'or disk files — period.<br/>💡 Talking Points: Walk through the 4-step diagram: '
                                      'the developer never knows or types the password; SQLcl queries cwallet.sso '
                                      'directly into RAM.<br/>⚠️ Key Emphasis: Mention that if an attacker copies the '
                                      'code repository or gains terminal access, there are no plaintext passwords to '
                                      'steal.',
                                'et': '🎯 Peamine sõnum: Null parooli lähtekoodis, skriptides, keskkonnamuutujates ega '
                                      'kettal – eranditeta.<br/>💡 Esitaja rääkimispunktid: Selgita 4-sammulist '
                                      'diagrammi: arendaja ei pea teadma ega sisestama salasõna; SQLcl loeb '
                                      'cwallet.sso-st andmed otse RAM-i.<br/>⚠️ Mida rõhutada: Isegi kui keegi '
                                      'kopeerib koodirepo või saab ligipääsu kettale, pole seal ühtegi parooli, mida '
                                      'varastada.',
                                'fi': '🎯 Pääviesti: Nolla salasanaa lähdekoodissa, skripteissä tai levyllä – '
                                      'poikkeuksetta.<br/>💡 Puhujan muistiinpanot: Käy läpi 4-vaiheinen kaavio: '
                                      'kehittäjän ei tarvitse tietää salasanoja; SQLcl lukee tiedot suoraan '
                                      'RAM-muistiin.<br/>⚠️ Tärkeä painotus: Vaikka repositorio vuotaisi, koodissa ei '
                                      'ole ainoatakaan selkokielistä salasanaa.',
                                'sv': '🎯 Huvudbudskap: Noll lösenord i källkod, skript eller filer på disk – utan '
                                      'undantag.<br/>💡 Talarpunkter: Gå igenom 4-stegsdiagrammet: utvecklaren behöver '
                                      'aldrig skriva lösenord; SQLcl hämtar uppgifterna direkt till RAM.<br/>⚠️ Vad '
                                      'som bör betonas: Även om källkod eller filer kopieras finns det inga '
                                      'klartextlösenord att stjäla.',
                                'lv': '🎯 Galvenais vēstījums: Nulle paroļu kodā, skriptos vai diska failos – bez '
                                      'izņēmumiem.<br/>💡 Runātāja piezīmes: Paskaidrojiet 4 soļu diagrammu: '
                                      'programmētājs nezina paroles; SQLcl tās nolasa tieši operatīvajā atmiņā.<br/>⚠️ '
                                      'Ko uzsvērt: Pat ja koda repozitorijs tiek nokopēts, tajā nav nevienas atklāta '
                                      'teksta paroles.',
                                'lt': '🎯 Pagrindinė žinutė: Jokių slaptažodžių kode, skriptuose ar diske – be jokių '
                                      'išimčių.<br/>💡 Pranešėjo pastabos: Paaiškinkite 4 žingsnių diagramą: '
                                      'programuotojas neveda slaptažodžio; SQLcl jį nuskaito tiesiai į RAM.<br/>⚠️ Ką '
                                      'akcentuoti: Net jei repozitorija būtų nukopijuota, joje nėra jokių atviro '
                                      'teksto slaptažodžių.'}},
    10: {   'badge': {   'en': '⚡ SLIDE 10 / 13 • DISASTER RECOVERY',
                         'et': '⚡ SLAID 10 / 13 • KIIRTAASTE JA TURVALISUS',
                         'fi': '⚡ DIA 10 / 13 • KATASTROFIPALAUTUS',
                         'sv': '⚡ BILD 10 / 13 • KATASTROFÅTERSTÄLLNING',
                         'lv': '⚡ SLAIDS 10 / 13 • AVĀRIJAS ATJAUNOŠANA',
                         'lt': '⚡ SKAIDRĖ 10 / 13 • AVARINIS ATKŪRIMAS'},
            'title': {   'en': 'Golden Snapshots: Deterministic 1–2 Min Recovery',
                         'et': 'Golden Snapshots: deterministlik 1–2 minuti kiirtaaste',
                         'fi': 'Golden Snapshots: deterministinen 1–2 minuutin pikapalautus',
                         'sv': 'Golden Snapshots: deterministisk återställning på 1–2 minuter',
                         'lv': 'Golden Snapshots: deterministiska 1–2 minūšu ātrā atjaunošana',
                         'lt': 'Golden Snapshots: deterministinis 1–2 minučių greitas atkūrimas'},
            'lead': {   'en': 'Deterministic database and configuration rollback with byte-for-byte exactness.',
                        'et': 'Täielik deterministlik andmemahu ja konfiguratsiooni taastamine bitt-bitilt algseisu.',
                        'fi': 'Deterministinen tietokannan ja konfiguraation palautus bitti bitiltä puhtaaseen tilaan.',
                        'sv': 'Deterministisk databas- och konfigurationsåterställning med bit-för-bit-precision.',
                        'lv': 'Deterministiska datubāzes un konfigurācijas atjaunošana ar baitu precizitāti.',
                        'lt': 'Deterministinis duomenų bazės ir konfigūracijos atkūrimas baitas į baitą.'},
            'diagram': {   'label': {   'en': '⚡ INSTANT DISASTER RECOVERY &amp; ROLLBACK TIMELINE',
                                        'et': '⚡ KIIRTAASTE JA ROLLBACKI AJAJOONE SKEEM',
                                        'fi': '⚡ PIKAPALAUTUKSEN JA ROLLBACKIN AIKAJANA',
                                        'sv': '⚡ TIDSFLÖDE FÖR SNABBÅTERSTÄLLNING OCH ROLLBACK',
                                        'lv': '⚡ ĀTRĀS ATJAUNOŠANAS UN ROLLBACK LAIKA LĪNIJA',
                                        'lt': '⚡ GREITO ATKŪRIMO IR ROLLBACK LAIKO JUOSTA'},
                           'nodes': [   {   'icon': '📸',
                                            'title': {   'en': 'Golden Baseline',
                                                         'et': 'Golden baasseis',
                                                         'fi': 'Golden-perustila',
                                                         'sv': 'Golden-utgångsläge',
                                                         'lv': 'Golden bāzes stāvoklis',
                                                         'lt': 'Golden pradinė būsena'},
                                            'sub': {   'en': 'Pristine snapshot',
                                                       'et': 'Puhas hetktõmmis',
                                                       'fi': 'Puhdas tilannevedos',
                                                       'sv': 'Ren snapshot',
                                                       'lv': 'Tīrs uzņēmums',
                                                       'lt': 'Švarus momentas'},
                                            'type': 'default'},
                                        {   'icon': '💥',
                                            'title': {   'en': 'Schema Disaster',
                                                         'et': 'Kriitiline viga',
                                                         'fi': 'Rikkova skeemavirhe',
                                                         'sv': 'Kritiskt schemafel',
                                                         'lv': 'Shēmas kļūda',
                                                         'lt': 'Kritinė klaida'},
                                            'sub': {   'en': 'Corrupted data / DDL',
                                                       'et': 'Rikutud andmed / DDL',
                                                       'fi': 'Vioittunut data / DDL',
                                                       'sv': 'Skadad data / DDL',
                                                       'lv': 'Bojāti dati / DDL',
                                                       'lt': 'Sugadinti duomenys'},
                                            'type': 'accent'},
                                        {   'icon': '⚡',
                                            'title': {   'en': 'restore-golden.sh',
                                                         'et': 'restore-golden.sh',
                                                         'fi': 'restore-golden.sh',
                                                         'sv': 'restore-golden.sh',
                                                         'lv': 'restore-golden.sh',
                                                         'lt': 'restore-golden.sh'},
                                            'sub': {   'en': '1–2 min automated reset',
                                                       'et': '1–2 min taastekäsk',
                                                       'fi': '1–2 min automaattipalautus',
                                                       'sv': '1–2 min återställning',
                                                       'lv': '1–2 min atjaunošana',
                                                       'lt': '1–2 min atkūrimas'},
                                            'type': 'active'},
                                        {   'icon': '✨',
                                            'title': {   'en': '100% Restored',
                                                         'et': 'Puhas algseis tagasi',
                                                         'fi': '100% palautettu',
                                                         'sv': '100% återställd',
                                                         'lv': '100% atjaunots',
                                                         'lt': '100% atkurta'},
                                            'sub': {   'en': 'Zero artifact traces',
                                                       'et': 'Null saastejääki',
                                                       'fi': 'Nolla jäännettä',
                                                       'sv': 'Noll spår av fel',
                                                       'lv': 'Nulle kļūdu pēdu',
                                                       'lt': 'Nulis klaidų pėdsakų'},
                                            'type': 'success'}],
                           'title': {   'en': 'Single-Command Platform Deployment Steps',
                                        'et': 'Ühe-käsuga platvormi paigaldusetapid',
                                        'fi': 'Alustan asennusvaiheet yhdellä komennolla',
                                        'sv': 'Distributionssteg med ett enda kommando',
                                        'lv': 'Platformas izvietošanas posmi ar vienu komandu',
                                        'lt': 'Platformos diegimo etapai viena komanda'}},
            'cards': [   {   'icon': '📸',
                             'kpi': '1–2 MIN',
                             'title': {   'en': '1-Command Instant Rollback',
                                          'et': '1 käsk: taasta algseis',
                                          'fi': '1 komento: palauta alkutila',
                                          'sv': '1 kommando: återställ läge',
                                          'lv': '1 komanda: atjaunot sākumstāvokli',
                                          'lt': '1 komanda: atkurti pradinę būseną'},
                             'desc': {   'en': '<code>./scripts/snapshots/restore-golden-snapshots.sh --auto -b '
                                               '0</code> resets the entire environment in 1–2 minutes.',
                                         'et': '<code>./scripts/snapshots/restore-golden-snapshots.sh --auto -b '
                                               '0</code> taastab puhta algseisu vaid 1–2 minutiga.',
                                         'fi': '<code>./scripts/snapshots/restore-golden-snapshots.sh --auto -b '
                                               '0</code> palauttaa puhtaan alkutilan 1–2 minuutissa.',
                                         'sv': '<code>./scripts/snapshots/restore-golden-snapshots.sh --auto -b '
                                               '0</code> återställer ren miljö på 1–2 minuter.',
                                         'lv': '<code>./scripts/snapshots/restore-golden-snapshots.sh --auto -b '
                                               '0</code> atjauno tīru stāvokli 1–2 minūtēs.',
                                         'lt': '<code>./scripts/snapshots/restore-golden-snapshots.sh --auto -b '
                                               '0</code> atkuria švarią būseną per 1–2 minutes.'},
                             'command': './scripts/snapshots/restore-golden-snapshots.sh --auto -b 0'},
                         {   'icon': '🎯',
                             'kpi': '100% PUHAS',
                             'title': {   'en': 'Pristine Test Isolation',
                                          'et': 'Puhas testide isolatsioon',
                                          'fi': 'Puhdas testieristys',
                                          'sv': 'Ren testisolering',
                                          'lv': 'Tīra testu izolācija',
                                          'lt': 'Švari testų izoliacija'},
                             'desc': {   'en': 'Every automated test execution starts from a guaranteed identical '
                                               'baseline state with zero artifact contamination.',
                                         'et': 'Iga testijooks alustab garanteeritult samast identsest baasseisust '
                                               'ilma eelmiste testide jääkideta.',
                                         'fi': 'Jokainen automatisoitu testi alkaa taatusti samasta alkutilasta ilman '
                                               'aiempien testien sivuvaikutuksia.',
                                         'sv': 'Varje testkörning startar från ett garanterat identiskt utgångsläge '
                                               'utan artefaktspår.',
                                         'lv': 'Katra testa izpilde sākas no garantēta identiska stāvokļa bez '
                                               'iepriekšējo testu piesārņojuma.',
                                         'lt': 'Kiekvienas testas prasideda nuo garantuotos identiškos būsenos be '
                                               'ankstesnių testų likučių.'}},
                         {   'icon': '⏱️',
                             'kpi': '-95% AEG',
                             'title': {   'en': 'Massive Developer Time Savings',
                                          'et': 'Tohutu ajavõit arenduses',
                                          'fi': 'Valtava ajansäästö kehityksessä',
                                          'sv': 'Enorm tidsbesparing för teamet',
                                          'lv': 'Milzīgs laika ietaupījums komandai',
                                          'lt': 'Didžiulis laiko taupymas komandai'},
                             'desc': {   'en': 'Standard database reinstallations take 20–45 minutes; Golden Snapshot '
                                               'reduces this to seconds or 1–2 minutes.',
                                         'et': 'Tavapärane andmebaasi taaspaigaldus võtab 20–45 minutit; snapshot '
                                               'taastab süsteemi 1–2 minutiga.',
                                         'fi': 'Tavanomainen uudelleenasennus kestää 20–45 minuuttia; snapshot hoitaa '
                                               'sen 1–2 minuutissa.',
                                         'sv': 'Standardominstallation tar 20–45 minuter; snapshot återställer allt på '
                                               '1–2 minuter.',
                                         'lv': 'Parastā pārinstalēšana aizņem 20–45 minūtes; snapshot to paveic 1–2 '
                                               'minūtēs.',
                                         'lt': 'Įprastas diegimas iš naujo trunka 20–45 minutes; snapshot tai atlieka '
                                               'per 1–2 minutes.'}}],
            'speaker_notes': {   'en': '🎯 Core Takeaway: Golden Snapshots give developers an instant undo button for '
                                       'complex database states.<br/>💡 Talking Points: Clarify that while some '
                                       'micro-resets take 15 seconds, a full container stop, volume restore, and '
                                       'database restart realistically takes 1–2 minutes.<br/>⚠️ Key Emphasis: '
                                       'Emphasize that automated CI/CD pipelines use this exact mechanism before every '
                                       'test run, guaranteeing 100% reproducibility.',
                                 'et': '🎯 Peamine sõnum: Golden Snapshots annab arendajatele kohese "undo" nupu mis '
                                       'tahes keerulise andmebaasi seisu jaoks.<br/>💡 Esitaja rääkimispunktid: '
                                       'Selgita, et kuigi mikroliigutused võivad võtta sekundeid, võtab kogu '
                                       'konteinerite peatamine, ketta taastamine ja DB käivitus reaalselt 1–2 '
                                       'minutit.<br/>⚠️ Mida rõhutada: Sama mehhanismi kasutab CI/CD enne igat '
                                       'testijooksu, tagades täieliku korratavuse.',
                                 'fi': '🎯 Pääviesti: Golden Snapshots antaa kehittäjille välittömän "kumoa"-napin '
                                       'monimutkaisiin tietokantatiloihin.<br/>💡 Puhujan muistiinpanot: Selvennä, että '
                                       'täysi volyymin palautus ja tietokannan uudelleenkäynnistys kestää '
                                       'realistisesti 1–2 minuuttia.<br/>⚠️ Tärkeä painotus: CI/CD käyttää samaa '
                                       'mekanismia ennen jokaista testiajoa taaten 100% toistettavuuden.',
                                 'sv': '🎯 Huvudbudskap: Golden Snapshots ger utvecklarna en direkt "ångra"-knapp för '
                                       'komplexa databastillstånd.<br/>💡 Talarpunkter: Förklara att en fullständig '
                                       'återställning och omstart tar realistiskt 1–2 minuter.<br/>⚠️ Vad som bör '
                                       'betonas: CI/CD-pipelinen använder exakt samma mekanism före varje testkörning.',
                                 'lv': '🎯 Galvenais vēstījums: Golden Snapshots sniedz tūlītēju "atcelt" pogu jebkuram '
                                       'sarežģītam stāvoklim.<br/>💡 Runātāja piezīmes: Paskaidrojiet, ka pilna '
                                       'konteineru apturēšana, sējumu atjaunošana un DB starts prasa 1–2 '
                                       'minūtes.<br/>⚠️ Ko uzsvērt: CI/CD konveijers izmanto šo pašu mehānismu pirms '
                                       'katra testa.',
                                 'lt': '🎯 Pagrindinė žinutė: Golden Snapshots suteikia kūrėjams momentinį "atšaukti" '
                                       'mygtuką bet kokiai DB būsenai.<br/>💡 Pranešėjo pastabos: Paaiškinkite, kad '
                                       'pilnas konteinerių sustabdymas, tomo atkūrimas ir DB paleidimas trunka 1–2 '
                                       'minutes.<br/>⚠️ Ką akcentuoti: CI/CD sistema naudoja šį mechanizmą prieš '
                                       'kiekvieną testą, garantuodama 100% atkuriamumą.'}},
    11: {   'badge': {   'en': '💎 SLIDE 11 / 13 • LOW-CODE AS CODE &amp; APEXLANG',
                         'et': '💎 SLAID 11 / 13 • LOW-CODE KOODINA JA APEXLANG',
                         'fi': '💎 DIA 11 / 13 • LOW-CODE KOODINA &amp; APEXLANG',
                         'sv': '💎 BILD 11 / 13 • LÅGKOD SOM KOD &amp; APEXLANG',
                         'lv': '💎 SLAIDS 11 / 13 • LOW-CODE KĀ KODS &amp; APEXLANG',
                         'lt': '💎 SKAIDRĖ 11 / 13 • LOW-CODE KAIP KODAS IR APEXLANG'},
            'title': {   'en': 'Application Intent vs. Imperative Code: Eliminating Code Ownership Burden',
                         'et': 'Rakenduse kavatsus vs toorkood: Koodi omamise koormuse välistamine',
                         'fi': 'Sovelluksen tarkoitus vs raakakoodi: Koodin omistustaakan poistaminen',
                         'sv': 'Applikationsavsikt vs råkod: Eliminera förvaltningsbördan för kod',
                         'lv': 'Lietotnes nolūks vs neapstrādāts kods: Koda pārvaldības sloga novēršana',
                         'lt': 'Programos ketinimas vs neapdorotas kodas: Kodo atsakomybės naštos panaikinimas'},
            'lead': {   'en': 'Why generating 10,000s of lines of raw imperative glue code creates a maintenance trap, '
                              'and how declarative APEX blueprints deliver faster, safer systems.',
                        'et': 'Miks 10 000+ rea imperatiivse toorkoodi genereerimine on hoolduslõks ja kuidas '
                              'deklaratiivne APEX blueprint tagab kiirema ja turvalisema tarne.',
                        'fi': 'Miksi 10 000+ rivin liimakoodin generointi luo ylläpitoansan ja miten deklaratiiviset '
                              'APEX-blueprintit takaavat nopeamman ja turvallisemman toimituksen.',
                        'sv': 'Varför generering av 10 000+ rader imperativ limkod skapar en underhållsfälla och hur '
                              'deklarativa APEX-ritningar ger snabbare och säkrare leverans.',
                        'lv': 'Kāpēc 10 000+ rindu savienojuma koda ģenerēšana rada uzturēšanas slazdu un kā '
                              'deklaratīvi APEX rasējumi nodrošina ātrāku un drošāku piegādi.',
                        'lt': 'Kodėl 10 000+ eilučių klijavimo kodo generavimas sukuria priežiūros spąstus ir kaip '
                              'deklaratyvūs APEX brėžiniai užtikrina greitesnį bei saugesnį diegimą.'},
            'comparison_diagram': {   'title': {   'en': 'Imperative Code Generation vs. Declarative APEXlang '
                                                         'Specification',
                                                   'et': 'Toorkoodi genereerimine vs Deklaratiivne APEXlang '
                                                         'spetsifikatsioon',
                                                   'fi': 'Raakakoodin generointi vs Deklaratiivinen '
                                                         'APEXlang-spesifikaatio',
                                                   'sv': 'Generering av råkod vs Deklarativ APEXlang-specifikation',
                                                   'lv': 'Neapstrādāta koda ģenerēšana vs Deklaratīva APEXlang '
                                                         'specifikācija',
                                                   'lt': 'Neapdoroto kodo generavimas vs Deklaratyvi APEXlang '
                                                         'specifikacija'},
                                      'bad': {   'label': {   'en': '❌ RAW CODE GENERATION (10,000+ LINES &amp; DAY-2 '
                                                                    'ROT)',
                                                              'et': '❌ TOORKOODI GENEREERIMINE (10 000+ RIDA JA '
                                                                    'HOOLDUSLÕKS)',
                                                              'fi': '❌ RAAKAKOODIN GENEROINTI (10 000+ RIVIÄ &amp; '
                                                                    'YLLÄPITOTAACCA)',
                                                              'sv': '❌ RÅKODSGENERERING (10 000+ RADER &amp; '
                                                                    'FÖRVALTNINGSBÖRDA)',
                                                              'lv': '❌ KODA ĢENERĒŠANA (10 000+ RINDU &amp; '
                                                                    'PĀRVALDĪBAS SLOGS)',
                                                              'lt': '❌ KODO GENERAVIMAS (10 000+ EILUČIŲ IR PRIEŽIŪROS '
                                                                    'NAŠTA)'},
                                                 'nodes': [   {   'icon': '📜',
                                                                  'title': {   'en': '10,000+ Lines Glue',
                                                                               'et': '10 000+ rida toorkoodi',
                                                                               'fi': '10 000+ riviä liimakoodia',
                                                                               'sv': '10 000+ rader limkod',
                                                                               'lv': '10 000+ rindu savienojuma koda',
                                                                               'lt': '10 000+ eilučių klijavimo kodo'},
                                                                  'sub': {   'en': 'React, Node, HTML boilerplate',
                                                                             'et': 'React, Node, HTML šabloonid',
                                                                             'fi': 'React, Node, HTML-mallit',
                                                                             'sv': 'React, Node, HTML-mallar',
                                                                             'lv': 'React, Node, HTML veidnes',
                                                                             'lt': 'React, Node, HTML šablonai'}},
                                                              {   'icon': '🔓',
                                                                  'title': {   'en': 'Hand-Rolled Auth',
                                                                               'et': 'Käsitsi turvalisus',
                                                                               'fi': 'Käsintehty tietoturva',
                                                                               'sv': 'Egendesignad säkerhet',
                                                                               'lv': 'Manuāla drošība',
                                                                               'lt': 'Rankinė apsauga'},
                                                                  'sub': {   'en': 'JWT bugs, N+1 query latency',
                                                                             'et': 'JWT vead, N+1 võrgulatents',
                                                                             'fi': 'JWT-aukot, N+1 verkkoviive',
                                                                             'sv': 'JWT-brister, N+1 latens',
                                                                             'lv': 'JWT kļūdas, N+1 aizture',
                                                                             'lt': 'JWT klaidos, N+1 delsa'}},
                                                              {   'icon': '🍂',
                                                                  'title': {   'en': 'Dependency Rot',
                                                                               'et': 'Teekide aegumine',
                                                                               'fi': 'Riippuvuuksien vanheneminen',
                                                                               'sv': 'Beroenderöta (npm)',
                                                                               'lv': 'Pakotņu novecošanās',
                                                                               'lt': 'Priklausomybių pasenimas'},
                                                                  'sub': {   'en': 'CVE patches, breaking npm APIs',
                                                                             'et': 'npm CVE-d, purunevad API-d',
                                                                             'fi': 'npm CVE:t, muuttuvat API:t',
                                                                             'sv': 'npm CVE, brutna API:er',
                                                                             'lv': 'npm CVE, bojāti API',
                                                                             'lt': 'npm CVE, kintantys API'}},
                                                              {   'icon': '🪤',
                                                                  'title': {   'en': 'Ownership Trap',
                                                                               'et': 'Hoolduslõks',
                                                                               'fi': 'Omistusansa',
                                                                               'sv': 'Förvaltningsfälla',
                                                                               'lv': 'Uzturēšanas slazds',
                                                                               'lt': 'Priežiūros spąstai'},
                                                                  'sub': {   'en': 'Developers maintain AI debt',
                                                                             'et': 'Tiim parandab AI koodi',
                                                                             'fi': 'Tiimi korjaa tekoälyn koodia',
                                                                             'sv': 'Teamet underhåller AI-skuld',
                                                                             'lv': 'Komanda uztur MI parādu',
                                                                             'lt': 'Komanda taiso DI skolą'}}]},
                                      'good': {   'label': {   'en': '✅ DECLARATIVE APEXLANG SPECIFICATION '
                                                                     '(INTENT-DRIVEN)',
                                                               'et': '✅ DEKLARATIIVNE APEXLANG SPETSIFIKATSIOON '
                                                                     '(KAVATSUSPÕHINE)',
                                                               'fi': '✅ DEKLARATIIVINEN APEXLANG-SPESIFIKAATIO '
                                                                     '(TARKOITUSPOHJAINEN)',
                                                               'sv': '✅ DEKLARATIV APEXLANG-SPECIFIKATION '
                                                                     '(AVSIKTSBASERAD)',
                                                               'lv': '✅ DEKLARATĪVA APEXLANG SPECIFIKĀCIJA (NOLŪKĀ '
                                                                     'BALSTĪTA)',
                                                               'lt': '✅ DEKLARATYVI APEXLANG SPECIFIKACIJA (KETINIMU '
                                                                     'GRĮSTA)'},
                                                  'nodes': [   {   'icon': '🎯',
                                                                   'title': {   'en': '30 Lines of Intent',
                                                                                'et': '30 rida kavatsust',
                                                                                'fi': '30 riviä tarkoitusta',
                                                                                'sv': '30 rader avsikt',
                                                                                'lv': '30 rindiņas nolūka',
                                                                                'lt': '30 eilučių ketinimo'},
                                                                   'sub': {   'en': 'Declarative .apx specification',
                                                                              'et': 'Deklaratiivne .apx '
                                                                                    'spetsifikatsioon',
                                                                              'fi': 'Deklaratiivinen '
                                                                                    '.apx-spesifikaatio',
                                                                              'sv': 'Deklarativ .apx-specifikation',
                                                                              'lv': 'Deklaratīva .apx specifikācija',
                                                                              'lt': 'Deklaratyvi .apx specifikacija'}},
                                                               {   'icon': '🛡️',
                                                                   'title': {   'en': 'Built-in Security',
                                                                                'et': 'Tuumataseme turvalisus',
                                                                                'fi': 'Ydintason tietoturva',
                                                                                'sv': 'Kärnsäkerhet',
                                                                                'lv': 'Kodola drošība',
                                                                                'lt': 'Branduolio apsauga'},
                                                                   'sub': {   'en': 'Bind vars, CSRF, RLS in kernel',
                                                                              'et': 'Sidusmuutujad, CSRF, RLS baasis',
                                                                              'fi': 'Sidosmuuttujat, CSRF, RLS '
                                                                                    'kannassa',
                                                                              'sv': 'Bindvariabler, CSRF, RLS i motorn',
                                                                              'lv': 'Piesaistes mainīgie, CSRF, RLS',
                                                                              'lt': 'Susiejimo kintamieji, CSRF, RLS'}},
                                                               {   'icon': '⚡',
                                                                   'title': {   'en': '0ms Network Latency',
                                                                                'et': '0ms võrgulatentsus',
                                                                                'fi': '0ms verkkoviive',
                                                                                'sv': '0ms nätverkslatens',
                                                                                'lv': '0ms tīkla aizture',
                                                                                'lt': '0ms tinklo delsa'},
                                                                   'sub': {   'en': 'Runs natively inside SQL engine',
                                                                              'et': 'Töötab otse andmebaasi tuumas',
                                                                              'fi': 'Toimii suoraan SQL-ytimessä',
                                                                              'sv': 'Körs i databasmotorn',
                                                                              'lv': 'Darbojas SQL kodolā',
                                                                              'lt': 'Veikia SQL branduolyje'}},
                                                               {   'icon': '✨',
                                                                   'title': {   'en': 'Zero Technical Debt',
                                                                                'et': 'Null tehnilist võlga',
                                                                                'fi': 'Nolla teknistä velkaa',
                                                                                'sv': 'Noll teknisk skuld',
                                                                                'lv': 'Nulle tehniskā parāda',
                                                                                'lt': 'Nulis techninės skolos'},
                                                                   'sub': {   'en': 'Auto-upgrades with APEX engine',
                                                                              'et': 'Automaatsed mootori uuendused',
                                                                              'fi': 'Automaattiset moottoripäivitykset',
                                                                              'sv': 'Automatiska motoruppgraderingar',
                                                                              'lv': 'Automātiski dzinēja jauninājumi',
                                                                              'lt': 'Automatiniai variklio '
                                                                                    'atnaujinimai'}}]}},
            'cards': [   {   'icon': '📦',
                             'kpi': 'KOORMUS / DEBT',
                             'title': {   'en': 'The Code Ownership Burden: Generate What You Want to Own',
                                          'et': 'Koodi omamise koormus: Oma seda, mida genereerid',
                                          'fi': 'Koodin omistustaakka: Omista se mitä generoita',
                                          'sv': 'Förvaltningsbördan: Äg det du genererar',
                                          'lv': 'Koda pārvaldības slogs: Pārvaldi to, ko ģenerē',
                                          'lt': 'Kodo atsakomybės našta: Valdykite tai, ką generuojate'},
                             'desc': {   'en': 'Every line of generated React/Node glue code must be reviewed, '
                                               'secured, and maintained by your developers when npm packages deprecate '
                                               'or security CVEs emerge.',
                                         'et': 'Iga AI genereeritud toorkoodi rida nõuab arendustiimi pidevat '
                                               'ülevaatust, turvaaukude paikamist ja refaktoreerimist, kui npm teegid '
                                               'aeguvad.',
                                         'fi': 'Jokainen tekoälyn luoma raakakoodirivi vaatii kehittäjiltä jatkuvaa '
                                               'katselmointia, tietoturvapaikkausta ja refaktorointia kirjastojen '
                                               'vanhentuessa.',
                                         'sv': 'Varje rad AI-genererad limkod måste granskas, säkras och underhållas '
                                               'av teamet när npm-paket föråldras eller säkerhetsbrister uppstår.',
                                         'lv': 'Katra MI ģenerētā koda rinda prasa pastāvīgu pārskatīšanu, drošības '
                                               'ielāpus un uzturēšanu, kad noveco npm pakotnes.',
                                         'lt': 'Kiekviena DI sugeneruota kodo eilutė reikalauja nuolatinės peržiūros, '
                                               'saugumo spragų lopymo ir priežiūros pasenus npm bibliotekoms.'}},
                         {   'icon': '🛡️',
                             'kpi': '0ms / BY DESIGN',
                             'title': {   'en': 'In-Database Execution & Automatic Platform Security',
                                          'et': 'Andmebaasisüsteemi kiirus ja sisseehitatud turvalisus',
                                          'fi': 'Tietokannan sisäinen suoritus ja alustan tietoturva',
                                          'sv': 'Körning i databasen och inbyggd plattformssäkerhet',
                                          'lv': 'Izpilde datubāzē un iebūvēta platformas drošība',
                                          'lt': 'Vykdymas duomenų bazėje ir integruota sauga'},
                             'desc': {   'en': 'APEX executes directly in the SQL/PLSQL kernel with 0ms network '
                                               'latency. Session state protection, CSRF/XSS escaping, and row-level '
                                               'security (RLS) are enforced by design.',
                                         'et': 'APEX töötab otse andmebaasis 0ms lisalatentsusega. Seansikaitse, '
                                               'CSRF/XSS varjestamine ja reataseme turvalisus (RLS) on mootorisse '
                                               'sisse ehitatud.',
                                         'fi': 'APEX suoritetaan suoraan SQL/PLSQL-ytimessä 0ms verkkoviiveellä. '
                                               'Istunnon suojaus, CSRF/XSS-käsittely ja rivitason suojaus (RLS) '
                                               'toimivat oletuksena.',
                                         'sv': 'APEX körs direkt i SQL/PLSQL-kärnan med 0ms latens. Sessionsskydd, '
                                               'CSRF/XSS-hantering och radnivåsäkerhet (RLS) är inbyggda i motorn.',
                                         'lv': 'APEX izpildās tieši SQL/PLSQL kodolā ar 0ms aizturi. Sesiju '
                                               'aizsardzība, CSRF/XSS novēršana un rindu līmeņa drošība (RLS) ir '
                                               'iebūvēta pēc noklusējuma.',
                                         'lt': 'APEX veikia tiesiogiai SQL/PLSQL branduolyje su 0ms delsa. Sesijų '
                                               'apsauga, CSRF/XSS valdymas ir eilučių lygio sauga (RLS) yra integruoti '
                                               'standartiškai.'}},
                         {   'icon': '⚡',
                             'kpi': '0 ROT / SPEC',
                             'title': {   'en': 'Declarative Blueprints: Zero Day-2 Maintenance Debt',
                                          'et': 'Deklaratiivne blueprint: Null tehnilist võlga uuendustel',
                                          'fi': 'Deklaratiivinen blueprint: Nolla päivän 2 ylläpitovelkaa',
                                          'sv': 'Deklarativ ritning: Noll teknisk skuld vid uppgradering',
                                          'lv': 'Deklaratīvs rasējums: Nulle tehniskā parāda jauninājumos',
                                          'lt': 'Deklaratyvus brėžinys: Nulis techninės skolos atnaujinant'},
                             'desc': {   'en': 'APEXlang (.apx) expresses high-level intent, not procedural plumbing. '
                                               'As Oracle upgrades APEX, applications inherit WCAG accessibility and '
                                               'modern UX with zero code refactoring.',
                                         'et': 'APEXlang (.apx) kirjeldab ärilist kavatsust, mitte tehnilist '
                                               'torustikku. APEXi versiooniuuendused kaasajastavad rakendused '
                                               'automaatselt ilma koodi ümberkirjutamata.',
                                         'fi': 'APEXlang (.apx) ilmaisee sovelluksen tarkoituksen, ei teknistä '
                                               'putkitusta. APEX-moottorin päivitykset uudistavat sovellukset ilman '
                                               'koodin uudelleenkirjoitusta.',
                                         'sv': 'APEXlang (.apx) beskriver syftet och avsikten. '
                                               'APEX-motoruppgraderingar moderniserar applikationen automatiskt utan '
                                               'att skriva om en enda rad kod.',
                                         'lv': 'APEXlang (.apx) izsaka augsta līmeņa nolūku. APEX dzinēja jauninājumi '
                                               'automātiski atjauno lietotni bez nepieciešamības pārrakstīt kodu.',
                                         'lt': 'APEXlang (.apx) išreiškia verslo ketinimą. APEX variklio atnaujinimai '
                                               'automatiškai modernizuoja taikomąją programą be kodo perrašymo.'}}],
            'speaker_notes': {   'en': '🎯 Core Takeaway: Enterprise leaders prioritize solutions that eliminate code '
                                       'maintenance debt. APEX replaces massive raw code generation with concise, '
                                       'declarative blueprints.<br/>💡 Talking Points: Emphasize the "code ownership '
                                       'burden" — generating 10,000s of lines of imperative React/Node/glue code '
                                       'forces your team to audit, debug, and maintain every single line. In APEX, '
                                       'blueprints act as a high-level specification language (APEXlang), leaving '
                                       'session state, CSRF/XSS protection, and execution to the battle-tested '
                                       "database engine.<br/>⚠️ Key Emphasis: Mention Justin Miller and Marc Sewtz's "
                                       '"Low-Code as Code" vision: applications defined as diffable, '
                                       'version-controlled .apx metadata in Git, giving teams complete DevOps velocity '
                                       'without the ongoing maintenance nightmare of unowned generated code.',
                                 'et': '🎯 Peamine sõnum: Ettevõtte IT-juhid väärtustavad lahendusi, mis välistavad '
                                       'tehnilise hooldusvõla. APEX asendab toorkoodi massilise genereerimise '
                                       'kompaktse deklaratiivse blueprintiga.<br/>💡 Esitaja rääkimispunktid: Rõhuta '
                                       '"koodi omamise koormust" (code ownership burden) — 10 000+ rea Reacti/Node '
                                       'liimkoodi genereerimine sunnib oma meeskonda vastutama iga üksiku rea '
                                       'turvalisuse ja hoolduse eest. APEXis toimib blueprint kui deklaratiivne '
                                       'spetsifikatsioonikeel (APEXlang), kus turvalisus ja sessioonihaldus on '
                                       'garanteeritud andmebaasimootori poolt.<br/>⚠️ Mida rõhutada: Oracle juhtkonna '
                                       '(Marc Sewtz, Justin Miller) "Low-Code as Code" visioon: rakenduse kavatsus '
                                       'salvestatakse versioonitava .apx tekstina Gitis, tagades täieliku CI/CD '
                                       'kiiruse ilma toorkoodi roiskumiseta.',
                                 'fi': '🎯 Pääviesti: Yritysjohdolle tärkeintä on teknisen ylläpitovelan eliminointi. '
                                       'APEX korvaa koodin massageneroinnin tiiviillä deklaratiivisella '
                                       'blueprintillä.<br/>💡 Puhujan muistiinpanot: Korosta koodin omistustaakkaa '
                                       '(code ownership burden) — 10 000+ rivin liimakoodin generointi siirtää kaiken '
                                       'ylläpito- ja tietoturvavastuun omalle tiimille. APEXissa blueprint toimii '
                                       'korkean tason spesifikaationa (APEXlang).<br/>⚠️ Tärkeä painotus: '
                                       'Oracle-johdon (Marc Sewtz, Justin Miller) "Low-Code as Code" -visio: '
                                       'sovellukset versioidaan .apx-tiedostoina Gitiin.',
                                 'sv': '🎯 Huvudbudskap: Verksamhetsledare prioriterar lösningar som eliminerar '
                                       'förvaltningsskuld. APEX ersätter massiv kodgenerering med koncisa deklarativa '
                                       'ritningar.<br/>💡 Talarpunkter: Betona förvaltningsbördan (code ownership '
                                       'burden) — att generera 10 000-tals rader råkod tvingar det egna teamet att '
                                       'underhålla varje rad. Med APEX fungerar ritningen som en specifikation '
                                       '(APEXlang).<br/>⚠️ Vad som bör betonas: Marc Sewtz och Justin Millers vision '
                                       '"Low-Code as Code": .apx-specifikation i Git ger full DevOps-hastighet utan '
                                       'kodförfall.',
                                 'lv': '🎯 Galvenais vēstījums: Uzņēmumu vadītāji augstu vērtē risinājumus, kas novērš '
                                       'uzturēšanas parādu. APEX aizstāj masveida koda ģenerēšanu ar deklaratīvu '
                                       'rasējumu.<br/>💡 Runātāja piezīmes: Uzsveriet koda pārvaldības slogu (code '
                                       'ownership burden) — ģenerējot 10 000+ rindu savienojuma koda, komanda uzņemas '
                                       'visu atbildību par uzturēšanu. APEXā rasējums kalpo kā specifikācija '
                                       '(APEXlang).<br/>⚠️ Ko uzsvērt: Oracle vadības "Low-Code as Code" pieeja: .apx '
                                       'specifikācija Gitā novērš neapstrādāta koda novecošanos.',
                                 'lt': '🎯 Pagrindinė žinutė: Įmonių vadovai vertina sprendimus, kurie panaikina '
                                       'techninę priežiūros skolą. APEX pakeičia masinį kodo generavimą deklaratyviais '
                                       'brėžiniais.<br/>💡 Pranešėjo pastabos: Pabrėžkite kodo atsakomybės naštą (code '
                                       'ownership burden) — sugeneravus 10 000+ eilučių kodo, visa priežiūros '
                                       'atsakomybė tenka komandai. APEX brėžinys veikia kaip specifikacija '
                                       '(APEXlang).<br/>⚠️ Ką akcentuoti: Marc Sewtz ir Justin Miller "Low-Code as '
                                       'Code" vizija: .apx specifikacija Gite užtikrina DevOps greitį be kodo gedimo '
                                       'rizikos.'}},
    12: {   'badge': {   'en': '🎯 SLIDE 12 / 13 • ARCHITECT &amp; DBA Q&amp;A',
                         'et': '🎯 SLAID 12 / 13 • KRIITILISED K&amp;V ARHITEKTILT JA DBA-LT',
                         'fi': '🎯 DIA 12 / 13 • ARKKITEHDIN &amp; DBA:N K&amp;V',
                         'sv': '🎯 BILD 12 / 13 • ARKITEKT- OCH DBA-FRÅGOR',
                         'lv': '🎯 SLAIDS 12 / 13 • ARHITEKTA UN DBA J&amp;A',
                         'lt': '🎯 SKAIDRĖ 12 / 13 • ARCHITEKTO IR DBA K&amp;A'},
            'title': {   'en': 'Critical Architect &amp; DBA Questions Answered',
                         'et': 'Vastused arhitektide ja DBA-de kriitilistele küsimustele',
                         'fi': 'Vastaukset arkkitehdin ja DBA:n kriittisiin kysymyksiin',
                         'sv': 'Svar på kritiska arkitekt- och DBA-frågor',
                         'lv': 'Atbildes uz arhitektu un DBA sarežģītajiem jautājumiem',
                         'lt': 'Atsakymai į svarbius architekto ir DBA klausimus'},
            'lead': {   'en': 'Hard questions enterprise teams ask about low-code, database resource constraints, and '
                              'CI/CD version control.',
                        'et': 'Vastused teravatele küsimustele seoses APEXi, ressursipiirangute ja koodipõhise '
                              'versioonihaldusega.',
                        'fi': 'Vastauksia tiukkoihin kysymyksiin low-codesta, tietokannan resursseista ja '
                              'CI/CD-versionhallinnasta.',
                        'sv': 'Svar på tuffa frågor om low-code, resursbegränsningar och CI/CD-versionshantering.',
                        'lv': 'Atbildes uz jautājumiem par low-code, resursu ierobežojumiem un CI/CD versiju kontroli.',
                        'lt': 'Atsakymai į griežtus klausimus apie low-code, DB resursų ribas ir CI/CD versijų '
                              'valdymą.'},
            'cards': [   {   'icon': '⚡',
                             'kpi': 'SPETSIFIKATSIOON',
                             'title': {   'en': 'Q: Why APEX instead of React/Node or code generation?',
                                          'et': 'K: Miks APEX, mitte React/Node või koodi genereerimine?',
                                          'fi': 'K: Miksi APEX eikä React/Node tai koodigenerointi?',
                                          'sv': 'F: Varför APEX istället för React/Node eller kodgenerering?',
                                          'lv': 'J: Kāpēc APEX, nevis React/Node vai koda ģenerēšana?',
                                          'lt': 'K: Kodėl APEX, o ne React/Node ar kodo generavimas?'},
                             'desc': {   'en': 'A: Faster, safer delivery via built-in security, 0ms latency, and '
                                               'blueprints instead of code generation. Eliminates the burden of owning '
                                               'and maintaining 10,000+ lines of generated code.',
                                         'et': 'V: Kiirem ja turvalisem tarne: 0ms latents, sisseehitatud kaitse ning '
                                               'koodi genereerimise asemel blueprint-spetsifikatsioon. Välistab 10 '
                                               '000+ rea genereeritud koodi omamise koormuse.',
                                         'fi': 'V: Nopeampi ja turvallisempi toimitus: 0ms viive, sisäänrakennettu '
                                               'suoja ja blueprint koodigeneroinnin sijaan. Poistaa 10 000+ rivin '
                                               'generoidun koodin omistus- ja ylläpitotaakan.',
                                         'sv': 'S: Snabbare, säkrare leverans: 0ms latens, inbyggt skydd och '
                                               'blueprints istället för kodgenerering. Eliminerar förvaltningsbördan '
                                               'att äga och underhålla 10 000+ rader genererad kod.',
                                         'lv': 'A: Ātrāka, drošāka piegāde: 0ms aizture, iebūvēta aizsardzība un '
                                               'deklaratīvi plāni koda ģenerēšanas vietā. Novērš slogu uzturēt un '
                                               'pārvaldīt 10 000+ rindu ģenerēta koda.',
                                         'lt': 'A: Greitesnis, saugesnis diegimas: 0ms delsa, integruota apsauga ir '
                                               'deklaratyvūs planai vietoje kodo generavimo. Panaikina 10 000+ eilučių '
                                               'sugeneruoto kodo priežiūros ir atsakomybės naštą.'}},
                         {   'icon': '💾',
                             'kpi': '2GB / 12GB',
                             'title': {   'en': 'Q: Are Free DB limits (2GB RAM / 12GB disk) sufficient?',
                                          'et': 'K: Kas Free DB mahud (2GB/12GB) ei jää väheseks?',
                                          'fi': 'K: Riittävätkö Free DB:n rajat (2GB RAM / 12GB levy)?',
                                          'sv': 'F: Räcker begränsningarna i Free DB (2GB RAM / 12GB disk)?',
                                          'lv': 'J: Vai Free DB resursi (2GB RAM / 12GB disks) ir pietiekami?',
                                          'lt': 'K: Ar pakanka Free DB ribų (2GB RAM / 12GB disko)?'},
                             'desc': {   'en': 'A: Yes. Decoupled tiers (Proxy vs Business DB) and zero-footprint REST '
                                               'streaming keep DB storage clean and fast.',
                                         'et': 'V: Ei jää. Proxy andmebaasi eraldamine äribaasist ja null-jalajäljega '
                                               'REST sild hoiavad andmebaasi kettamahu minimaalsena.',
                                         'fi': 'V: Riittävät erinomaisesti. Proxy-kannan ja liiketoimintakannan '
                                               'erottaminen pitää levynkäytön minimaalisena.',
                                         'sv': 'S: Ja, absolut. Separeringen av Proxy och Affärs-DB samt '
                                               'REST-strömning minimerar lagringsbehovet.',
                                         'lv': 'A: Pilnīgi pietiek. Proxy un biznesa bāzes nodalīšana un REST '
                                               'straumēšana uztur minimālu diska noslodzi.',
                                         'lt': 'A: Taip. Proxy ir verslo DB atskyrimas bei REST perdavimas užtikrina '
                                               'minimalų disko naudojimą.'}},
                         {   'icon': '📜',
                             'kpi': 'APEXLANG',
                             'title': {   'en': 'Q: How are version control &amp; zero-trust CI/CD verified?',
                                          'et': 'K: Kuidas tagatakse versioonihaldus ja CI/CD?',
                                          'fi': 'K: Miten versionhallinta ja turvallinen CI/CD taataan?',
                                          'sv': 'F: Hur säkerställs versionshantering och säker CI/CD?',
                                          'lv': 'J: Kā tiek nodrošināta versiju kontrole un droša CI/CD?',
                                          'lt': 'K: Kaip užtikrinamas versijų valdymas ir saugi CI/CD?'},
                             'desc': {   'en': 'A: Official SQLcl 26.2 APEXlang DSL (<code>.apx</code>), automated AST '
                                               'quality checks, Liquibase, and SEPS Wallet without plaintext.',
                                         'et': 'V: Ametlik SQLcl 26.2 APEXlang DSL (<code>.apx</code>), AST '
                                               'kvaliteedikontroll, Liquibase ja SEPS Wallet ilma paroolideta koodis.',
                                         'fi': 'V: Virallinen SQLcl 26.2 APEXlang DSL (<code>.apx</code>), '
                                               'automaattinen AST-tarkistus, Liquibase ja SEPS Wallet.',
                                         'sv': 'S: Officiell SQLcl 26.2 APEXlang DSL (<code>.apx</code>), '
                                               'automatiserad AST-granskning och lösenordsfri SEPS Wallet.',
                                         'lv': 'A: Oficiālais SQLcl 26.2 APEXlang DSL (<code>.apx</code>), AST '
                                               'pārbaudes, Liquibase un bezparoļu SEPS Wallet.',
                                         'lt': 'A: Oficialus SQLcl 26.2 APEXlang DSL (<code>.apx</code>), AST patikra, '
                                               'Liquibase ir beslaptažodis SEPS Wallet.'}}],
            'speaker_notes': {   'en': '🎯 Core Takeaway: Enterprise architects value solutions that eliminate code '
                                       'maintenance debt. APEX replaces massive raw code generation with concise, '
                                       'declarative blueprints.<br/>💡 Talking Points: Emphasize the "code ownership '
                                       'burden" — generating 10,000s of lines of imperative React/Node/glue code '
                                       'forces your team to audit, debug, and maintain every single line. In APEX, '
                                       'blueprints act as a high-level specification language (APEXlang), leaving '
                                       'session state, CSRF/XSS protection, and execution to the battle-tested '
                                       'database engine.<br/>⚠️ Key Emphasis: Free DB provides a zero-latency, '
                                       'full-featured development sandbox; production workloads scale seamlessly to '
                                       'Autonomous Database without refactoring.',
                                 'et': '🎯 Peamine sõnum: Ettevõtte arhitektid väärtustavad lahendusi, mis välistavad '
                                       'koodi hooldusvõla. APEX asendab toorkoodi massilise genereerimise '
                                       'deklaratiivsete blueprint-kavanditega.<br/>💡 Esitaja rääkimispunktid: Selgita '
                                       '"koodi omamise koormust" (code ownership burden) — 10 000+ rea '
                                       'React/Node/liimkoodi genereerimisel peab meeskond seda kõike pikaajaliselt '
                                       'auditeerima, siluma ja hooldama. APEXis on blueprint nagu '
                                       'spetsifikatsioonikeel (APEXlang), kus turvalisuse, sessioonihalduse ja käituse '
                                       'tagab automaatselt sertifitseeritud platvormimootor.<br/>⚠️ Mida rõhutada: '
                                       'Free DB pakub 0ms latentsusega ja sisseehitatud turvalisusega '
                                       "arenduskeskkonda; toodangumahud liiguvad sujuvalt Autonomous Database'i ilma "
                                       'koodi ümber kirjutamata.',
                                 'fi': '🎯 Pääviesti: Yritysarkkitehdit arvostavat ratkaisuja, jotka poistavat koodin '
                                       'ylläpitovelan. APEX korvaa raakakoodin massageneroinnin deklaratiivisilla '
                                       'blueprinteillä.<br/>💡 Puhujan muistiinpanot: Korosta "koodin '
                                       'omistajuustaakkaa" (code ownership burden) — 10 000+ riviä '
                                       'React/Node-liimakoodia vaatii jatkuvaa auditointia, virheenkorjausta ja '
                                       'ylläpitoa. APEXissa blueprint toimii määrittelykielenä (APEXlang), jolloin '
                                       'tietoturva ja istunnonhallinta ovat alustaan sisäänrakennettuja.<br/>⚠️ Tärkeä '
                                       'painotus: Free DB tarjoaa nollaviiveisen kehitysympäristön; tuotantokuormat '
                                       'skaalautuvat saumattomasti OCI Autonomous Databaseen ilman koodimuutoksia.',
                                 'sv': '🎯 Huvudbudskap: Företagsarkitekter uppskattar lösningar som eliminerar '
                                       'underhållsskulden för kod. APEX ersätter massiv kodgenerering med deklarativa '
                                       'blueprints.<br/>💡 Talarpunkter: Betona "kodägandets börda" (code ownership '
                                       'burden) — 10 000+ rader genererad React/Node-kod måste granskas, felsökas och '
                                       'förvaltas av teamet. I APEX fungerar blueprint som ett specifikationsspråk '
                                       '(APEXlang), medan säkerhet och sessionshantering sköts direkt av '
                                       'motorn.<br/>⚠️ Vad som bör betonas: Free DB ger en säker utvecklingsmiljö med '
                                       '0ms latens; produktionslaster flyttas sömlöst till Autonomous Database utan '
                                       'omskrivning.',
                                 'lv': '🎯 Galvenais vēstījums: Uzņēmuma arhitekti novērtē risinājumus, kas novērš koda '
                                       'uzturēšanas parādu. APEX aizstāj masveida koda ģenerēšanu ar deklaratīviem '
                                       'plāniem (blueprints).<br/>💡 Runātāja piezīmes: Uzsveriet "koda īpašumtiesību '
                                       'slogu" — 10 000+ rindu ģenerēta React/Node koda prasa nepārtrauktu auditu un '
                                       'uzturēšanu. APEX gadījumā blueprint darbojas kā specifikācijas valoda '
                                       '(APEXlang), kur drošība un sesiju pārvaldība ir iebūvēta dzinējā.<br/>⚠️ Ko '
                                       'uzsvērt: Free DB nodrošina 0ms aiztures izstrādes vidi; ražošanas slodzes '
                                       'migrē uz Autonomous Database bez koda maiņas.',
                                 'lt': '🎯 Pagrindinė žinutė: Įmonių architektai vertina sprendimus, kurie panaikina '
                                       'kodo priežiūros skolą. APEX pakeičia kodo generavimą deklaratyviais planais '
                                       '(blueprints).<br/>💡 Pranešėjo pastabos: Pabrėžkite "kodo atsakomybės naštą" — '
                                       '10 000+ eilučių React/Node kodo reikalauja nuolatinio audito, derinimo ir '
                                       'palaikymo. APEX atveju blueprint veikia kaip specifikacijos kalba (APEXlang), '
                                       'o saugumas ir sesijų valdymas yra integruoti tiesiogiai į branduolį.<br/>⚠️ Ką '
                                       'akcentuoti: Free DB suteikia 0ms delsos aplinką; gamybinės apkrovos sklandžiai '
                                       'perkeliamos į Autonomous Database be kodo perdarymo.'}},
    13: {   'badge': {   'en': '🚀 SLIDE 13 / 13 • GET STARTED &amp; LINKS',
                         'et': '🚀 SLAID 13 / 13 • ALUSTAMINE JA LINGID',
                         'fi': '🚀 DIA 13 / 13 • ALOITUS &amp; LINKIT',
                         'sv': '🚀 BILD 13 / 13 • KOM IGÅNG &amp; LÄNKAR',
                         'lv': '🚀 SLAIDS 13 / 13 • SĀKUMS UN SAITES',
                         'lt': '🚀 SKAIDRĖ 13 / 13 • PRADŽIA IR NUORODOS'},
            'title': {   'en': 'How to Get Started Immediately',
                         'et': 'Kuidas kohe alustada',
                         'fi': 'Miten aloittaa heti',
                         'sv': 'Hur du kommer igång direkt',
                         'lv': 'Kā nekavējoties sākt darbu',
                         'lt': 'Kaip pradėti nedelsiant'},
            'lead': {   'en': '3 interactive execution steps, quick navigation to Dev Hub tools, and official Oracle '
                              'documentation resources.',
                        'et': '3 interaktiivset sammu, kiirnupud Dev Hubi sektsioonidesse ja ametlikud Oracle '
                              'dokumentatsiooni veebilingid.',
                        'fi': '3 interaktiivista vaihetta, pikanäppäimet Dev Hubiin ja viralliset '
                              'Oracle-dokumentaatiolinkit.',
                        'sv': '3 interaktiva steg, snabbnavigering till Dev Hub och officiella '
                              'Oracle-dokumentationsresurser.',
                        'lv': '3 interaktīvi soļi, ātrās saites uz Dev Hub rīkiem un oficiālās Oracle dokumentācijas '
                              'saites.',
                        'lt': '3 interaktyvūs žingsniai, greitas perėjimas į Dev Hub ir oficialios Oracle '
                              'dokumentacijos nuorodos.'},
            'diagram': {   'label': {   'en': '🚀 3-STEP INSTANT ONBOARDING ROADMAP',
                                        'et': '🚀 3-SAMMULINE KIIRE KÄIVITUSTEEKOND',
                                        'fi': '🚀 3-VAIHEINEN NOPEA KÄYNNISTYSKAAVIO',
                                        'sv': '🚀 3-STEGS SNABBSTARTKARTA',
                                        'lv': '🚀 3-SOĻU ĀTRĀS PALAIŠANAS CEĻVEDIS',
                                        'lt': '🚀 3-ŽINGSNIŲ GREITO PALEIDIMO ŽEMĖLAPIS'},
                           'nodes': [   {   'icon': '1️⃣',
                                            'title': {   'en': '1. Launch Core',
                                                         'et': '1. Käivita virn',
                                                         'fi': '1. Käynnistä pino',
                                                         'sv': '1. Starta stacken',
                                                         'lv': '1. Palaist steku',
                                                         'lt': '1. Paleisti sistemą'},
                                            'sub': {   'en': './scripts/setup-all.sh',
                                                       'et': './scripts/setup-all.sh',
                                                       'fi': './scripts/setup-all.sh',
                                                       'sv': './scripts/setup-all.sh',
                                                       'lv': './scripts/setup-all.sh',
                                                       'lt': './scripts/setup-all.sh'},
                                            'type': 'default'},
                                        {   'icon': '2️⃣',
                                            'title': {   'en': '2. Toggle BP',
                                                         'et': '2. Vali blueprint',
                                                         'fi': '2. Valitse malli',
                                                         'sv': '2. Byt ritning',
                                                         'lv': '2. Pārslēgt rasējumu',
                                                         'lt': '2. Pasirinkti brėžinį'},
                                            'sub': {   'en': './scripts/module-toggle.sh',
                                                       'et': './scripts/module-toggle.sh',
                                                       'fi': './scripts/module-toggle.sh',
                                                       'sv': './scripts/module-toggle.sh',
                                                       'lv': './scripts/module-toggle.sh',
                                                       'lt': './scripts/module-toggle.sh'},
                                            'type': 'active'},
                                        {   'icon': '3️⃣',
                                            'title': {   'en': '3. Test Suite',
                                                         'et': '3. Käivita testid',
                                                         'fi': '3. Suorita testit',
                                                         'sv': '3. Kör testsvit',
                                                         'lv': '3. Palaist testus',
                                                         'lt': '3. Paleisti testus'},
                                            'sub': {   'en': './scripts/test-apex-suite.sh',
                                                       'et': './scripts/test-apex-suite.sh',
                                                       'fi': './scripts/test-apex-suite.sh',
                                                       'sv': './scripts/test-apex-suite.sh',
                                                       'lv': './scripts/test-apex-suite.sh',
                                                       'lt': './scripts/test-apex-suite.sh'},
                                            'type': 'accent'},
                                        {   'icon': '🎉',
                                            'title': {   'en': 'Ready to Build',
                                                         'et': 'Valmis arenduseks',
                                                         'fi': 'Valmis kehitykseen',
                                                         'sv': 'Redo för utveckling',
                                                         'lv': 'Gatavs darbam',
                                                         'lt': 'Paruošta kūrimui'},
                                            'sub': {   'en': 'Dev Hub at :8088',
                                                       'et': 'Dev Hub pordil :8088',
                                                       'fi': 'Dev Hub portissa :8088',
                                                       'sv': 'Dev Hub på :8088',
                                                       'lv': 'Dev Hub portā :8088',
                                                       'lt': 'Dev Hub porte :8088'},
                                            'type': 'success'}],
                           'title': {   'en': 'Developer Quick-Start Milestones',
                                        'et': 'Arendaja kiirstardi verstapostid',
                                        'fi': 'Kehittäjän pikastartin virstanpylväät',
                                        'sv': 'Milstolpar för snabbstart för utvecklare',
                                        'lv': 'Izstrādātāja ātrā starta atskaites punkti',
                                        'lt': 'Kūrėjo greito starto etapai'}},
            'cards': [   {   'icon': '1️⃣',
                             'kpi': 'SAMM 1',
                             'title': {   'en': '1. Launch Core Stack',
                                          'et': '1. Käivita keskkond',
                                          'fi': '1. Käynnistä ympäristö',
                                          'sv': '1. Starta miljön',
                                          'lv': '1. Palaist vidi',
                                          'lt': '1. Paleisti aplinką'},
                             'desc': {   'en': 'Deploy core database &amp; ORDS:<br/><code '
                                               'style="color:#38bdf8;">./scripts/setup-all.sh</code>',
                                         'et': 'Paigalda andmebaas ja teenused:<br/><code '
                                               'style="color:#38bdf8;">./scripts/setup-all.sh</code>',
                                         'fi': 'Asenna tietokanta ja palvelut:<br/><code '
                                               'style="color:#38bdf8;">./scripts/setup-all.sh</code>',
                                         'sv': 'Installera databas och tjänster:<br/><code '
                                               'style="color:#38bdf8;">./scripts/setup-all.sh</code>',
                                         'lv': 'Uzstādīt datubāzi un pakalpojumus:<br/><code '
                                               'style="color:#38bdf8;">./scripts/setup-all.sh</code>',
                                         'lt': 'Įdiegti duomenų bazę ir paslaugas:<br/><code '
                                               'style="color:#38bdf8;">./scripts/setup-all.sh</code>'},
                             'command': './scripts/setup-all.sh'},
                         {   'icon': '2️⃣',
                             'kpi': 'SAMM 2',
                             'title': {   'en': '2. Toggle Blueprint',
                                          'et': '2. Vali blueprint',
                                          'fi': '2. Valitse arkkitehtuurimalli',
                                          'sv': '2. Byt arkitekturritning',
                                          'lv': '2. Pārslēgt rasējumu',
                                          'lt': '2. Pasirinkti brėžinį'},
                             'desc': {   'en': 'Switch architecture stack:<br/><code '
                                               'style="color:#38bdf8;">./scripts/module-toggle.sh</code>',
                                         'et': 'Vali sobiv arhitektuuripinu:<br/><code '
                                               'style="color:#38bdf8;">./scripts/module-toggle.sh</code>',
                                         'fi': 'Vaihda kokoonpanoa:<br/><code '
                                               'style="color:#38bdf8;">./scripts/module-toggle.sh</code>',
                                         'sv': 'Växla konfiguration:<br/><code '
                                               'style="color:#38bdf8;">./scripts/module-toggle.sh</code>',
                                         'lv': 'Mainīt profilu:<br/><code '
                                               'style="color:#38bdf8;">./scripts/module-toggle.sh</code>',
                                         'lt': 'Pakeisti profilį:<br/><code '
                                               'style="color:#38bdf8;">./scripts/module-toggle.sh</code>'},
                             'command': './scripts/module-toggle.sh'},
                         {   'icon': '3️⃣',
                             'kpi': 'SAMM 3',
                             'title': {   'en': '3. Run Automated Tests',
                                          'et': '3. Käivita testid',
                                          'fi': '3. Suorita testit',
                                          'sv': '3. Kör testsvit',
                                          'lv': '3. Palaist testus',
                                          'lt': '3. Paleisti testus'},
                             'desc': {   'en': 'Automated end-to-end verification:<br/><code '
                                               'style="color:#38bdf8;">./scripts/test-apex-suite.sh</code>',
                                         'et': 'Täisautomaatne testimine:<br/><code '
                                               'style="color:#38bdf8;">./scripts/test-apex-suite.sh</code>',
                                         'fi': 'Täysautomaattinen testaus:<br/><code '
                                               'style="color:#38bdf8;">./scripts/test-apex-suite.sh</code>',
                                         'sv': 'Automatiserad verifiering:<br/><code '
                                               'style="color:#38bdf8;">./scripts/test-apex-suite.sh</code>',
                                         'lv': 'Automatizēta pārbaude:<br/><code '
                                               'style="color:#38bdf8;">./scripts/test-apex-suite.sh</code>',
                                         'lt': 'Automatizuotas testavimas:<br/><code '
                                               'style="color:#38bdf8;">./scripts/test-apex-suite.sh</code>'},
                             'command': './scripts/test-apex-suite.sh'}],
            'oracle_links': [   {'title': 'Oracle 23ai Free DB', 'url': 'https://www.oracle.com/database/free/'},
                                {   'title': 'Oracle APEX 26.1 & APEXlang',
                                    'url': 'https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/'},
                                {   'title': 'Oracle REST Data Services (ORDS)',
                                    'url': 'https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/'},
                                {   'title': 'Oracle SQLcl & Liquibase',
                                    'url': 'https://docs.oracle.com/en/database/oracle/sql-developer-command-line/'},
                                {   'title': 'Oracle Autonomous Database',
                                    'url': 'https://docs.oracle.com/en/cloud/paas/autonomous-database/'},
                                {   'title': 'Analytics Publisher & Forms',
                                    'url': 'https://docs.oracle.com/en/middleware/'}],
            'speaker_notes': {   'en': '🎯 Core Takeaway: Starting is completely frictionless: run setup-all.sh and you '
                                       'have a production-grade stack running in minutes.<br/>💡 Talking Points: '
                                       'Demonstrate the 1-click copy buttons. Invite audience to explore the Live '
                                       'Services, Blueprints, and DevOps tabs right here in Dev Hub.<br/>⚠️ Key '
                                       'Emphasis: Point out the curated official Oracle documentation links for teams '
                                       'wanting to deep-dive into APEXlang, ORDS, or Autonomous Database.',
                                 'et': '🎯 Peamine sõnum: Alustamine on täiesti vaevatu: käivita setup-all.sh ja '
                                       'enterprise-tasemel virn töötab minutitega.<br/>💡 Esitaja rääkimispunktid: '
                                       'Demonstreeri 1-klikiga kopeeritavaid käske. Kutsu kuulajaid avama Teenuste, '
                                       'Blueprintide ja DevOps vahekaarte otse siinsamas Dev Hubis.<br/>⚠️ Mida '
                                       'rõhutada: Too välja ametlikud Oracle dokumentatsiooni veebilingid neile, kes '
                                       'soovivad süveneda APEXlangi, ORDS-i või Autonomous Database võimalustesse.',
                                 'fi': '🎯 Pääviesti: Aloittaminen on vaivatonta: aja setup-all.sh ja yritystason pino '
                                       'on pystyssä minuuteissa.<br/>💡 Puhujan muistiinpanot: Näytä komentojen '
                                       '1-klikkauksen kopiointi. Ohjaa yleisö tutustumaan Palvelut- ja '
                                       'Mallit-välilehtiin suoraan Dev Hubissa.<br/>⚠️ Tärkeä painotus: Korosta '
                                       'virallisia Oracle-dokumentaatiolinkkejä niille, jotka haluavat perehtyä '
                                       'APEXlangiin ja ORDS:iin tarkemmin.',
                                 'sv': '🎯 Huvudbudskap: Att komma igång är helt friktionsfritt: kör setup-all.sh och '
                                       'du har en enterprise-stack på några minuter.<br/>💡 Talarpunkter: Demonstrera '
                                       'snabbkopiering av kommandon. Bjud in åhörarna att utforska Tjänster, Ritningar '
                                       'och DevOps-flikarna i Dev Hub.<br/>⚠️ Vad som bör betonas: Hänvisa till de '
                                       'officiella Oracle-dokumentationslänkarna för fördjupning i APEXlang och ORDS.',
                                 'lv': '🎯 Galvenais vēstījums: Sākt ir ļoti vienkārši: palaidiet setup-all.sh un '
                                       'uzņēmuma līmeņa steks darbojas minūtēs.<br/>💡 Runātāja piezīmes: Demonstrējiet '
                                       'komandu kopēšanu ar vienu klikšķi. Aiciniet apskatīt Pakalpojumu un Rasējumu '
                                       'sadaļas Dev Hub.<br/>⚠️ Ko uzsvērt: Norādiet uz oficiālajām Oracle '
                                       'dokumentācijas saitēm tālākai APEXlang un ORDS apguvei.',
                                 'lt': '🎯 Pagrindinė žinutė: Pradėti yra itin paprasta: paleiskite setup-all.sh ir '
                                       'įmonės lygio sistema veikia per kelias minutes.<br/>💡 Pranešėjo pastabos: '
                                       'Pademonstruokite komandų kopijavimą vienu paspaudimu. Pakvieskite išbandyti '
                                       'Paslaugų ir Brėžinių skiltis Dev Hub.<br/>⚠️ Ką akcentuoti: Nukreipkite į '
                                       'oficialias Oracle dokumentacijos nuorodas išsamiam APEXlang ir ORDS '
                                       'tyrinėjimui.'}}}
