"""
Oracle DevOps Platform - Blueprint Guides, Workflows & Test Suites Metadata
Provides universal schema for all 12 Blueprints in 6 languages (EN, ET, FI, SV, LV, LT).
"""

BP_EXT_METADATA = {
    9: {
        "guide_id": "publisher-template-builder",
        "quickstart": {
            "en": [
                {
                    "step": 1,
                    "title": "Launch Designer Desktop",
                    "desc": "Deploy and start HTML5 noVNC desktop container on port 6083: <code>./scripts/deploy-blueprint.sh -b 9</code>",
                    "action": "setup",
                    "btn_text": "Start Stack"
                },
                {
                    "step": 2,
                    "title": "Open Desktop in Browser",
                    "desc": "Connect via <code>http://localhost:6083/vnc.html</code> to access Microsoft Word with pre-configured BIP Template Builder.",
                    "url": "http://localhost:6083/vnc.html",
                    "btn_text": "Open noVNC Desktop ↗️"
                },
                {
                    "step": 3,
                    "title": "Design Accessible RTF Template",
                    "desc": "Load <code>sample_data.xml</code>, format repeatable table headers, add image alt-text, embed company logo, and preview PDF.",
                    "action": "docs"
                },
                {
                    "step": 4,
                    "title": "Run Automated Accessibility Tests",
                    "desc": "Execute the 100% automated PDF/UA-1, WCAG 2.1 AA, and RTF linting test suites from the Testing tab below.",
                    "action": "tab-diag",
                    "btn_text": "Go to Tests 🧪"
                }
            ],
            "et": [
                {
                    "step": 1,
                    "title": "Käivita töölaua konteiner",
                    "desc": "Käivita HTML5 noVNC töölaua konteiner pordil 6083 käsuga <code>./scripts/deploy-blueprint.sh -b 9</code>",
                    "action": "setup",
                    "btn_text": "Käivita virn"
                },
                {
                    "step": 2,
                    "title": "Ava töölaud brauseris",
                    "desc": "Ava brauseris <code>http://localhost:6083/vnc.html</code>, et kasutada MS Wordi ja eelpaigaldatud BIP Template Builderit.",
                    "url": "http://localhost:6083/vnc.html",
                    "btn_text": "Ava noVNC töölaud ↗️"
                },
                {
                    "step": 3,
                    "title": "Kujunda ligipääsetav RTF mall",
                    "desc": "Laadi <code>sample_data.xml</code>, kujunda korduvad tabelipäised, lisa pildi alt-tekst ja tsentraalne logo ning kontrolli PDF eelvaadet.",
                    "action": "docs"
                },
                {
                    "step": 4,
                    "title": "Käivita ligipääsetavuse testid",
                    "desc": "Käivita täisautomaatne PDF/UA-1, WCAG 2.1 AA ja RTF linteri testikomplekt otse allolevalt Testimise vahekaardilt.",
                    "action": "tab-diag",
                    "btn_text": "Mine testide juurde 🧪"
                }
            ],
            "fi": [
                {
                    "step": 1,
                    "title": "Käynnistä työpöytäkontti",
                    "desc": "Käynnistä HTML5 noVNC -työpöytäkontti portissa 6083 komennolla <code>./scripts/deploy-blueprint.sh -b 9</code>",
                    "action": "setup",
                    "btn_text": "Käynnistä pino"
                },
                {
                    "step": 2,
                    "title": "Avaa työpöytä selaimessa",
                    "desc": "Yhdistä osoitteeseen <code>http://localhost:6083/vnc.html</code> käyttääksesi MS Wordia ja BIP Template Builder -työkalua.",
                    "url": "http://localhost:6083/vnc.html",
                    "btn_text": "Avaa noVNC ↗️"
                },
                {
                    "step": 3,
                    "title": "Suunnittele saavutettava RTF-malli",
                    "desc": "Lataa <code>sample_data.xml</code>, muotoile toistuvat otsikot, lisää alt-tekstit ja logo sekä tarkista PDF.",
                    "action": "docs"
                },
                {
                    "step": 4,
                    "title": "Suorita automaattitestit",
                    "desc": "Suorita täysautomaattiset PDF/UA-1 ja WCAG -saavutettavuustestit suoraan Testaus-välilehdeltä.",
                    "action": "tab-diag",
                    "btn_text": "Testauksen välilehti 🧪"
                }
            ],
            "sv": [
                {
                    "step": 1,
                    "title": "Starta skrivbordsbehållaren",
                    "desc": "Starta HTML5 noVNC skrivbord på port 6083 med <code>./scripts/deploy-blueprint.sh -b 9</code>",
                    "action": "setup",
                    "btn_text": "Starta stack"
                },
                {
                    "step": 2,
                    "title": "Öppna skrivbordet i webbläsaren",
                    "desc": "Anslut via <code>http://localhost:6083/vnc.html</code> till MS Word och BIP Template Builder.",
                    "url": "http://localhost:6083/vnc.html",
                    "btn_text": "Öppna noVNC ↗️"
                },
                {
                    "step": 3,
                    "title": "Designa tillgänglig RTF-mall",
                    "desc": "Läs in <code>sample_data.xml</code>, formatera tabellrubriker, bildens alt-text och logotyp.",
                    "action": "docs"
                },
                {
                    "step": 4,
                    "title": "Kör automatiserade tillgänglighetstester",
                    "desc": "Kör PDF/UA-1 och WCAG-testsviten direkt från Test-fliken nedan.",
                    "action": "tab-diag",
                    "btn_text": "Gå till tester 🧪"
                }
            ],
            "lv": [
                {
                    "step": 1,
                    "title": "Palaist darbvirsmas konteineru",
                    "desc": "Palaidiet HTML5 noVNC konteineru portā 6083: <code>./scripts/deploy-blueprint.sh -b 9</code>",
                    "action": "setup",
                    "btn_text": "Palaist steku"
                },
                {
                    "step": 2,
                    "title": "Atvērt darbvirsmu pārlūkā",
                    "desc": "Atveriet <code>http://localhost:6083/vnc.html</code> darbam ar MS Word un BIP Template Builder.",
                    "url": "http://localhost:6083/vnc.html",
                    "btn_text": "Atvērt noVNC ↗️"
                },
                {
                    "step": 3,
                    "title": "Izstrādāt piekļūstamu RTF veidni",
                    "desc": "Ielādējiet <code>sample_data.xml</code>, formatējiet galvenes, alt-tekstus un uzņēmuma logo.",
                    "action": "docs"
                },
                {
                    "step": 4,
                    "title": "Palaist piekļūstamības testus",
                    "desc": "Izpildiet PDF/UA-1 un WCAG testus tieši no Testēšanas cilnes.",
                    "action": "tab-diag",
                    "btn_text": "Uz testiem 🧪"
                }
            ],
            "lt": [
                {
                    "step": 1,
                    "title": "Paleisti darbalaukio konteinerį",
                    "desc": "Paleiskite HTML5 noVNC konteinerį prievade 6083: <code>./scripts/deploy-blueprint.sh -b 9</code>",
                    "action": "setup",
                    "btn_text": "Paleisti kaminą"
                },
                {
                    "step": 2,
                    "title": "Atidaryti darbalaukį naršyklėje",
                    "desc": "Prisijunkite per <code>http://localhost:6083/vnc.html</code> prie MS Word ir BIP Template Builder.",
                    "url": "http://localhost:6083/vnc.html",
                    "btn_text": "Atidaryti noVNC ↗️"
                },
                {
                    "step": 3,
                    "title": "Kurti prieinamą RTF šabloną",
                    "desc": "Įkelkite <code>sample_data.xml</code>, suformatuokite antraštes, alt-tekstus ir įterpkite logotipą.",
                    "action": "docs"
                },
                {
                    "step": 4,
                    "title": "Paleisti prieinamumo testus",
                    "desc": "Vykdykite PDF/UA-1 ir WCAG testus tiesiai iš Testavimo skirtuko.",
                    "action": "tab-diag",
                    "btn_text": "Į testus 🧪"
                }
            ]
        },
        "workflow_diagram": {
            "en": 'flowchart TB\\n    A["📄 XML Data Source<br/>(sample_data.xml)"] --> B["🎨 MS Word & BIP Builder<br/>(noVNC Desktop :6083)"]\\n    B --> C["📝 RTF Template Design<br/>(Headers, Tables, Logo)"]\\n    C --> D{"Does template pass<br/>PDF/UA-1 & WCAG<br/>compliance?"}\\n    D -->|YES / Compliant| E["🧪 Auto Tests & Lint<br/>(PDF/UA-1, XLF, Linter)"]\\n    D -->|NO / Issues| B\\n    E --> F["🚀 Deploy to Server<br/>(Analytics Publisher :9502)"]',
            "et": 'flowchart TB\\n    A["📄 XML Lähteandmed<br/>(sample_data.xml)"] --> B["🎨 MS Word & BIP Builder<br/>(noVNC Töölaud :6083)"]\\n    B --> C["📝 RTF Malli Kujundus<br/>(Päised, Tabelid, Logo)"]\\n    C --> D{"Kas mall vastab<br/>PDF/UA-1 ja WCAG<br/>nõuetele?"}\\n    D -->|JAH / Kehtiv| E["🧪 Automaattestid & Lint<br/>(PDF/UA-1, XLF, Linter)"]\\n    D -->|EI / Puudulik| B\\n    E --> F["🚀 Juurutus Serverisse<br/>(Analytics Publisher :9502)"]',
            "fi": 'flowchart TB\\n    A["📄 XML-lähtötiedot<br/>(sample_data.xml)"] --> B["🎨 MS Word & BIP Builder<br/>(noVNC-työpöytä :6083)"]\\n    B --> C["📝 RTF-mallin muotoilu<br/>(Otsikot, Taulukot, Logo)"]\\n    C --> D{"Täyttääkö malli<br/>PDF/UA-1 ja WCAG<br/>vaatimukset?"}\\n    D -->|KYLLÄ / Pätevä| E["🧪 Automaattitestit & Lint<br/>(PDF/UA-1, XLF, Linter)"]\\n    D -->|EI / Korjattavaa| B\\n    E --> F["🚀 Käyttöönotto palvelimelle<br/>(Analytics Publisher :9502)"]',
            "sv": 'flowchart TB\\n    A["📄 XML-källdata<br/>(sample_data.xml)"] --> B["🎨 MS Word & BIP Builder<br/>(noVNC-skrivbord :6083)"]\\n    B --> C["📝 RTF-malldesign<br/>(Rubriker, Tabeller, Logo)"]\\n    C --> D{"Uppfyller mallen<br/>PDF/UA-1 och WCAG<br/>kraven?"}\\n    D -->|JA / Godkänd| E["🧪 Automattest & Lint<br/>(PDF/UA-1, XLF, Linter)"]\\n    D -->|NEJ / Åtgärda| B\\n    E --> F["🚀 Driftsätt till server<br/>(Analytics Publisher :9502)"]',
            "lv": 'flowchart TB\\n    A["📄 XML Pamatdati<br/>(sample_data.xml)"] --> B["🎨 MS Word & BIP Builder<br/>(noVNC Darbvirsma :6083)"]\\n    B --> C["📝 RTF Veidnes Izveide<br/>(Galvenes, Tabulas, Logo)"]\\n    C --> D{"Vai veidne atbilst<br/>PDF/UA-1 un WCAG<br/>prasībām?"}\\n    D -->|JĀ / Atbilstošs| E["🧪 Automātiskie Testi & Lint<br/>(PDF/UA-1, XLF, Linter)"]\\n    D -->|NĒ / Nepietiekams| B\\n    E --> F["🚀 Izvietošana Serverī<br/>(Analytics Publisher :9502)"]',
            "lt": 'flowchart TB\\n    A["📄 XML Pradiniai Duomenys<br/>(sample_data.xml)"] --> B["🎨 MS Word ir BIP Builder<br/>(noVNC Darbalaukis :6083)"]\\n    B --> C["📝 RTF Šablono Dizainas<br/>(Antraštės, Lentelės, Logo)"]\\n    C --> D{"Ar šablonas atitinka<br/>PDF/UA-1 ir WCAG<br/>reikalavimus?"}\\n    D -->|TAIP / Tinkamas| E["🧪 Automatiniai Testai & Lint<br/>(PDF/UA-1, XLF, Linter)"]\\n    D -->|NE / Trūkumai| B\\n    E --> F["🚀 Diegimas į Serverį<br/>(Analytics Publisher :9502)"]'
        },
        "tests": [
            {
                "key": "test-publisher-a11y",
                "title": {
                    "en": "♿ PDF/UA-1 & WCAG Accessibility Suite",
                    "et": "♿ PDF/UA-1 & WCAG Ligipääsetavuse Test",
                    "fi": "♿ PDF/UA-1 & WCAG Saavutettavuustestit",
                    "sv": "♿ PDF/UA-1 & WCAG Tillgänglighetssvit",
                    "lv": "♿ PDF/UA-1 & WCAG Piekļūstamības tests",
                    "lt": "♿ PDF/UA-1 & WCAG Prieinamumo testas"
                },
                "desc": {
                    "en": "Validates Section 508, WCAG 2.1 AA, and PDF/UA-1 compliance with zero visual clipping.",
                    "et": "Valideerib Section 508, WCAG 2.1 AA ja PDF/UA-1 vastavust ning tagab korrektse struktuuri.",
                    "fi": "Valatoi Section 508, WCAG 2.1 AA ja PDF/UA-1 vaatimustenmukaisuuden.",
                    "sv": "Validerar Section 508, WCAG 2.1 AA och PDF/UA-1 efterlevnad.",
                    "lv": "Validē Section 508, WCAG 2.1 AA un PDF/UA-1 atbilstību.",
                    "lt": "Patikrina Section 508, WCAG 2.1 AA ir PDF/UA-1 atitiktį."
                },
                "cmd": "./tests/integration/test-publisher-accessibility-suite.sh",
                "color": "#22c55e",
                "icon": "♿"
            },
            {
                "key": "test-publisher-designer-e2e",
                "title": {
                    "en": "🖥️ Designer Desktop E2E Healthcheck",
                    "et": "🖥️ Kujundaja töölaua E2E tervisekontroll",
                    "fi": "🖥️ Suunnittelijan työpöydän E2E-tarkistus",
                    "sv": "🖥️ Skrivbordsdesignerns E2E-hälsokontroll",
                    "lv": "🖥️ Darbvirsmas veidotāja E2E veselības pārbaude",
                    "lt": "🖥️ Darbalaukio kūrėjo E2E būsenos patikra"
                },
                "desc": {
                    "en": "Verifies container boot, noVNC port 6083, desktop binaries, and sample assets.",
                    "et": "Kontrollib konteineri käivitust, noVNC porti 6083, töölaua binaare ja näidisfaile.",
                    "fi": "Tarkistaa kontin käynnistyksen, noVNC-portin 6083 ja työpöydän toiminnan.",
                    "sv": "Verifierar behållarstart, noVNC-port 6083 och skrivbordsfiler.",
                    "lv": "Pārbauda konteinera startu, noVNC portu 6083 un darbvirsmas darbību.",
                    "lt": "Patikrina konteinerio paleidimą, noVNC prievadą 6083 ir darbalaukio failus."
                },
                "cmd": "./tests/integration/test-publisher-designer-e2e.sh",
                "color": "#38bdf8",
                "icon": "🖥️"
            },
            {
                "key": "rtf-lint",
                "title": {
                    "en": "🔍 RTF Template Accessibility Linter",
                    "et": "🔍 RTF malli reeglite & ligipääsetavuse linter",
                    "fi": "🔍 RTF-mallin sääntö- ja saavutettavuuslinter",
                    "sv": "🔍 RTF mall linter för tillgänglighet",
                    "lv": "🔍 RTF veidnes piekļūstamības linteris",
                    "lt": "🔍 RTF šablono prieinamumo linteris"
                },
                "desc": {
                    "en": "Static analysis for repeated table headers, alt-text, binary logos, and contrast.",
                    "et": "Staatiline analüüs: korduvad tabelipäised, pildi alt-tekst, binaarne logo ja kontrast.",
                    "fi": "Staattinen analyysi: taulukon otsikot, kuvien alt-tekstit ja kontrastit.",
                    "sv": "Statisk analys: tabellrubriker, alt-text och logotyper.",
                    "lv": "Statiskā analīze: tabulu galvenes, alt-teksti un logotipi.",
                    "lt": "Statinė analizė: lentelių antraštės, alt-tekstai ir logotipai."
                },
                "cmd": "./scripts/publisher/validate-rtf-accessibility.sh",
                "color": "#fbbf24",
                "icon": "🔍"
            },
            {
                "key": "pdf-a11y-validate",
                "title": {
                    "en": "📄 PDF/UA-1 Accessibility Document Validator",
                    "et": "📄 PDF/UA-1 ligipääsetavuse dokumendi validaator",
                    "fi": "📄 PDF/UA-1 saavutettavuuden asiakirjavalidoija",
                    "sv": "📄 PDF/UA-1 tillgänglighetsdokumentvaliderare",
                    "lv": "📄 PDF/UA-1 piekļūstamības dokumentu validētājs",
                    "lt": "📄 PDF/UA-1 prieinamumo dokumentų tikrintuvas"
                },
                "desc": {
                    "en": "Validates Tagged PDF (/StructTreeRoot, /MarkInfo), metadata titles, and table semantics.",
                    "et": "Valideerib märgistatud PDF-i (/StructTreeRoot, /MarkInfo), metaandmeid ja tabelite semantikat.",
                    "fi": "Tarkistaa Tagged PDF -rakenteen, metatiedot ja taulukon semantiikan.",
                    "sv": "Validerar taggad PDF, metadata och tabellsemantik.",
                    "lv": "Pārbauda iezīmēto PDF, metadatus un tabulu semantiku.",
                    "lt": "Patikrina pažymėtą PDF, metaduomenis ir lentelių semantiką."
                },
                "cmd": "./scripts/publisher/validate-pdf-accessibility.sh templates/publisher/accessibility_suite/01-standard-invoice/output_accessible.pdf",
                "color": "#c084fc",
                "icon": "📄"
            },
            {
                "key": "test-publisher-multilingual",
                "title": {
                    "en": "🌐 XLF Multi-Language Translation Test",
                    "et": "🌐 XLF mitmekeelse tõlke test",
                    "fi": "🌐 XLF-monikielisyyskäännöstesti",
                    "sv": "🌐 XLF flerspråkig översättningstest",
                    "lv": "🌐 XLF daudzvalodu tulkošanas tests",
                    "lt": "🌐 XLF daugiakalbio vertimo testas"
                },
                "desc": {
                    "en": "Validates XLIFF translation extraction across all 6 languages (EN, ET, FI, SV, LV, LT).",
                    "et": "Valideerib XLIFF tõlkefailide genereerimist ja sünkroonsust kõigis 6 keeles.",
                    "fi": "Valatoi XLIFF-käännöstiedostojen toiminnan kaikilla 6 kielellä.",
                    "sv": "Validerar XLIFF-översättningsfiler på alla 6 språk.",
                    "lv": "Validē XLIFF tulkošanas failus visās 6 valodās.",
                    "lt": "Patikrina XLIFF vertimo failus visomis 6 kalbomis."
                },
                "cmd": "./tests/integration/test-publisher-multilingual.sh",
                "color": "#f472b6",
                "icon": "🌐"
            }
        ]
    },
    1: {
        "guide_id": "getting-started",
        "quickstart": {
            "en": [
                {"step": 1, "title": "Deploy ALISE Database", "desc": "Start dedicated business database container on port 1533: <code>./scripts/setup-all.sh -b 1</code>", "action": "setup", "btn_text": "Start Stack"},
                {"step": 2, "title": "Connect via SEPS Wallet", "desc": "Login passwordlessly to ALISE container with SQLcl: <code>sql /@ALISE_DEV</code> or <code>sql /@ALISE_SYS</code>", "action": "wallet"},
                {"step": 3, "title": "Run Liquibase Schema Migrations", "desc": "Apply declarative database changelogs and schema updates: <code>./scripts/sqlcl.sh /@ALISE_DEV lb update</code>", "action": "cli"},
                {"step": 4, "title": "Access APEX & Database Actions", "desc": "Open Oracle APEX Builder and ORDS Database Actions console at <code>https://localhost:8448/ords/alise/</code>", "url": "https://localhost:8448/ords/alise/", "btn_text": "Open ORDS Portal ↗️"}
            ],
            "et": [
                {"step": 1, "title": "Käivita ALISE andmebaas", "desc": "Käivita äriandmebaasi konteiner pordil 1533: <code>./scripts/setup-all.sh -b 1</code>", "action": "setup", "btn_text": "Käivita virn"},
                {"step": 2, "title": "Ühendu SEPS Walleti kaudu", "desc": "Logi SQLcl-iga paroolivabalt ALISE baasi: <code>sql /@ALISE_DEV</code> või <code>sql /@ALISE_SYS</code>", "action": "wallet"},
                {"step": 3, "title": "Rakenda Liquibase migratsioonid", "desc": "Käivita deklaratiivsed andmemudeli uuendused: <code>./scripts/sqlcl.sh /@ALISE_DEV lb update</code>", "action": "cli"},
                {"step": 4, "title": "Ava APEX ja Database Actions", "desc": "Ava APEX Builder ja ORDS Database Actions aadressil <code>https://localhost:8448/ords/alise/</code>", "url": "https://localhost:8448/ords/alise/", "btn_text": "Ava ORDS Portaal ↗️"}
            ],
            "fi": [
                {"step": 1, "title": "Käynnistä ALISE-tietokanta", "desc": "Käynnistä tietokantakontti portissa 1533: <code>./scripts/setup-all.sh -b 1</code>", "action": "setup"},
                {"step": 2, "title": "Yhdistä SEPS Walletilla", "desc": "Kirjaudu SQLcl:llä ilman salasanaa: <code>sql /@ALISE_DEV</code>", "action": "wallet"},
                {"step": 3, "title": "Suorita Liquibase-migraatiot", "desc": "Päivitä skeemat: <code>./scripts/sqlcl.sh /@ALISE_DEV lb update</code>", "action": "cli"},
                {"step": 4, "title": "Avaa APEX ja ORDS", "desc": "Avaa portaali: <code>https://localhost:8448/ords/alise/</code>", "url": "https://localhost:8448/ords/alise/"}
            ],
            "sv": [
                {"step": 1, "title": "Driftsätt ALISE-databas", "desc": "Starta applikationsdatabas på port 1533: <code>./scripts/setup-all.sh -b 1</code>", "action": "setup"},
                {"step": 2, "title": "Anslut via SEPS Wallet", "desc": "Lösenordslös inloggning: <code>sql /@ALISE_DEV</code>", "action": "wallet"},
                {"step": 3, "title": "Kör Liquibase-migreringar", "desc": "Uppdatera scheman: <code>./scripts/sqlcl.sh /@ALISE_DEV lb update</code>", "action": "cli"},
                {"step": 4, "title": "Öppna APEX och ORDS", "desc": "Öppna portalen: <code>https://localhost:8448/ords/alise/</code>", "url": "https://localhost:8448/ords/alise/"}
            ],
            "lv": [
                {"step": 1, "title": "Izvietot ALISE datubāzi", "desc": "Startējiet datubāzi portā 1533: <code>./scripts/setup-all.sh -b 1</code>", "action": "setup"},
                {"step": 2, "title": "Pieslēgties ar SEPS maku", "desc": "Pieteikšanās bez paroles: <code>sql /@ALISE_DEV</code>", "action": "wallet"},
                {"step": 3, "title": "Palaist Liquibase migrācijas", "desc": "Atjauniniet shēmas: <code>./scripts/sqlcl.sh /@ALISE_DEV lb update</code>", "action": "cli"},
                {"step": 4, "title": "Atvērt APEX un ORDS", "desc": "Atveriet portālu: <code>https://localhost:8448/ords/alise/</code>", "url": "https://localhost:8448/ords/alise/"}
            ],
            "lt": [
                {"step": 1, "title": "Diegti ALISE duomenų bazę", "desc": "Paleiskite duomenų bazę prievade 1533: <code>./scripts/setup-all.sh -b 1</code>", "action": "setup"},
                {"step": 2, "title": "Prisijungti per SEPS piniginę", "desc": "Prisijungimas be slaptažodžio: <code>sql /@ALISE_DEV</code>", "action": "wallet"},
                {"step": 3, "title": "Vykdyti Liquibase migracijas", "desc": "Atnaujinkite schemas: <code>./scripts/sqlcl.sh /@ALISE_DEV lb update</code>", "action": "cli"},
                {"step": 4, "title": "Atidaryti APEX ir ORDS", "desc": "Atidarykite portalą: <code>https://localhost:8448/ords/alise/</code>", "url": "https://localhost:8448/ords/alise/"}
            ]
        },
        "workflow_diagram": {
            "en": 'flowchart TB\\n    A["⚙️ Configuration<br/>(.env.1-db-alise)"] --> B["🚀 Deploy Stack<br/>(db-alise :1533)"]\\n    B --> C["🔑 SEPS Wallet<br/>(/@ALISE_DEV)"]\\n    C --> D{"Is database online<br/>and healthy?"}\\n    D -->|YES / Online| E["📦 Liquibase DDL & DML<br/>(Declarative migrations)"]\\n    D -->|NO / Starting| B\\n    E --> F["🌐 APEX & REST Services<br/>(Business Applications)"]',
            "et": 'flowchart TB\\n    A["⚙️ Konfiguratsioon<br/>(.env.1-db-alise)"] --> B["🚀 Käivita virn<br/>(db-alise :1533)"]\\n    B --> C["🔑 SEPS Wallet<br/>(/@ALISE_DEV)"]\\n    C --> D{"Kas andmebaas töötab<br/>ja on terve?"}\\n    D -->|JAH / Terve| E["📦 Liquibase DDL & DML<br/>(Skeemide migratsioonid)"]\\n    D -->|EI / Käivitub| B\\n    E --> F["🌐 APEX & REST Teenused<br/>(Ärirakenduste käitus)"]',
            "fi": 'flowchart TB\\n    A["⚙️ Konfiguraatio<br/>(.env.1-db-alise)"] --> B["🚀 Käynnistä pino<br/>(db-alise :1533)"]\\n    B --> C["🔑 SEPS Wallet<br/>(/@ALISE_DEV)"]\\n    C --> D{"Onko tietokanta<br/>kunnossa?"}\\n    D -->|KYLLÄ / Healthy| E["📦 Liquibase DDL & DML<br/>(Skeemamigraatiot)"]\\n    D -->|EI / Käynnistyy| B\\n    E --> F["🌐 APEX & REST<br/>(Sovelluspalvelut)"]',
            "sv": 'flowchart TB\\n    A["⚙️ Konfiguration<br/>(.env.1-db-alise)"] --> B["🚀 Starta stack<br/>(db-alise :1533)"]\\n    B --> C["🔑 SEPS Wallet<br/>(/@ALISE_DEV)"]\\n    C --> D{"Är databasen<br/>online och felfri?"}\\n    D -->|JA / Online| E["📦 Liquibase DDL & DML<br/>(Schemamigreringar)"]\\n    D -->|NEJ / Startar| B\\n    E --> F["🌐 APEX & REST<br/>(Affärsapplikationer)"]',
            "lv": 'flowchart TB\\n    A["⚙️ Konfigurācija<br/>(.env.1-db-alise)"] --> B["🚀 Startēt steku<br/>(db-alise :1533)"]\\n    B --> C["🔑 SEPS maks<br/>(/@ALISE_DEV)"]\\n    C --> D{"Vai datubāze<br/>ir vesela?"}\\n    D -->|JĀ / Vesela| E["📦 Liquibase DDL & DML<br/>(Shēmu migrācijas)"]\\n    D -->|NĒ / Startējas| B\\n    E --> F["🌐 APEX & REST<br/>(Biznesa lietotnes)"]',
            "lt": 'flowchart TB\\n    A["⚙️ Konfigūracija<br/>(.env.1-db-alise)"] --> B["🚀 Paleisti kaminą<br/>(db-alise :1533)"]\\n    B --> C["🔑 SEPS piniginė<br/>(/@ALISE_DEV)"]\\n    C --> D{"Ar duomenų bazė<br/>veikia tinkamai?"}\\n    D -->|TAIP / Veikia| E["📦 Liquibase DDL & DML<br/>(Schemų migracijos)"]\\n    D -->|NE / Startuoja| B\\n    E --> F["🌐 APEX ir REST<br/>(Verslo programos)"]'
        },
        "tests": [
            {
                "key": "test-db-profiles",
                "title": {"en": "🏗️ Database Profiles & Port Topology", "et": "🏗️ Andmebaasi profiilide ja portide test", "fi": "🏗️ Tietokantaprofiilien ja porttien testaus", "sv": "🏗️ Databasprofiler och porttopologi", "lv": "🏗️ Datubāzu profilu un portu tests", "lt": "🏗️ Duomenų bazių profilių ir prievadų testas"},
                "desc": {"en": "Verifies dynamic port resolution, YAML profile parsing, and isolation across multi-DB topologies.", "et": "Kontrollib dünaamilist pordihaldust, YAML profiilide parsimist ja isolatsiooni mitme baasi puhul.", "fi": "Tarkistaa dynaamisen porttierottelun ja YAML-profiilit.", "sv": "Verifierar dynamisk porthantering och YAML-profiler.", "lv": "Pārbauda dinamisko portu pārvaldību un YAML profilus.", "lt": "Patikrina dinaminį prievadų valdymą ir YAML profilius."},
                "cmd": "./tests/integration/test-db-profiles-and-topology.sh",
                "color": "#22c55e",
                "icon": "🏗️"
            },
            {
                "key": "test-sqlcl-wallet",
                "title": {"en": "🔐 SEPS Wallet Passwordless Login", "et": "🔐 SEPS Walleti paroolivaba ühenduvus", "fi": "🔐 SEPS Wallet -salasanaton kirjautuminen", "sv": "🔐 SEPS Wallet lösenordslös inloggning", "lv": "🔐 SEPS maka pieteikšanās bez paroles", "lt": "🔐 SEPS piniginės prisijungimas be slaptažodžio"},
                "desc": {"en": "Tests instant passwordless DB connection via cwallet.sso across DBA and developer accounts.", "et": "Testib paroolivaba andmebaasiühendust cwallet.sso kaudu nii DBA kui DEV kasutajatega.", "fi": "Testaa salasanatonta tietokantayhteyttä cwallet.sso-tiedostolla.", "sv": "Testar lösenordslös databasanslutning via cwallet.sso.", "lv": "Testē pieslēgšanos datubāzei bez paroles ar cwallet.sso.", "lt": "Testuoja prisijungimą prie duomenų bazės be slaptažodžio su cwallet.sso."},
                "cmd": "./tests/integration/test-sqlcl-passwordless-connections.sh",
                "color": "#38bdf8",
                "icon": "🔐"
            },
            {
                "key": "check-wallet",
                "title": {"en": "🔑 Check Wallet Connections", "et": "🔑 Kontrolli SEPS Walleti ühendusi", "fi": "🔑 Tarkista SEPS Wallet -yhteydet", "sv": "🔑 Kontrollera SEPS Wallet-anslutningar", "lv": "🔑 Pārbaudīt SEPS maka savienojumus", "lt": "🔑 Patikrinti SEPS piniginės ryšius"},
                "desc": {"en": "Verifies all TNS aliases in the local auto-login wallet against running database instances.", "et": "Kontrollib kõiki lokaalse Walleti TNS aliaseid töötavate andmebaaside vastu.", "fi": "Tarkistaa kaikki paikallisen lompakon TNS-aliakset.", "sv": "Kontrollerar alla TNS-alias i den lokala plånboken.", "lv": "Pārbauda visus TNS aizstājvārdus vietējā makā.", "lt": "Patikrina visus TNS sinonimus vietinėje piniginėje."},
                "cmd": "./scripts/check-wallet.sh",
                "color": "#4ade80",
                "icon": "🔑"
            }
        ]
    },
    8: {
        "guide_id": "web-ide",
        "quickstart": {
            "en": [
                {"step": 1, "title": "Launch Web-IDE Container", "desc": "Start VS Code server and developer workspace container on port 8090: <code>./scripts/deploy-blueprint.sh -b 8</code>", "action": "setup", "btn_text": "Start Stack"},
                {"step": 2, "title": "Open VS Code in Browser", "desc": "Connect directly via <code>http://localhost:8090/</code> to access web VS Code with pre-installed Oracle extension.", "url": "http://localhost:8090/", "btn_text": "Open Web-IDE ↗️"},
                {"step": 3, "title": "Connect to Database", "desc": "Use Oracle SQL Developer extension inside the editor to connect to any local or cloud Oracle DB.", "action": "docs"},
                {"step": 4, "title": "Run Web-IDE Healthcheck", "desc": "Validate Web-IDE container responsiveness, permissions, and extensions via the Testing tab.", "action": "tab-diag", "btn_text": "Run Healthcheck 🧪"}
            ],
            "et": [
                {"step": 1, "title": "Käivita Web-IDE konteiner", "desc": "Käivita VS Code server ja arendaja tööruum pordil 8090 käsuga <code>./scripts/deploy-blueprint.sh -b 8</code>", "action": "setup", "btn_text": "Käivita virn"},
                {"step": 2, "title": "Ava VS Code brauseris", "desc": "Ava veebibrauseris <code>http://localhost:8090/</code> täielikuks VS Code redaktoriks koos Oracle laiendusega.", "url": "http://localhost:8090/", "btn_text": "Ava Web-IDE ↗️"},
                {"step": 3, "title": "Ühendu andmebaasiga", "desc": "Kasuta Oracle SQL Developer laiendust redaktori sees, et hallata kohalikke või pilvebaase.", "action": "docs"},
                {"step": 4, "title": "Kontrolli Web-IDE tervist", "desc": "Käivita konteineri tervislikkuse ja õiguste test otse allolevalt Testimise vahekaardilt.", "action": "tab-diag", "btn_text": "Kontrolli tervist 🧪"}
            ],
            "fi": [
                {"step": 1, "title": "Käynnistä Web-IDE", "desc": "Käynnistä VS Code -palvelin portissa 8090: <code>./scripts/deploy-blueprint.sh -b 8</code>", "action": "setup"},
                {"step": 2, "title": "Avaa VS Code selaimessa", "desc": "Yhdistä osoitteeseen <code>http://localhost:8090/</code>.", "url": "http://localhost:8090/"},
                {"step": 3, "title": "Yhdistä tietokantaan", "desc": "Käytä Oracle SQL Developer -laajennusta editorin sisällä.", "action": "docs"},
                {"step": 4, "title": "Tarkista Web-IDE", "desc": "Suorita terveystarkastus Testaus-välilehdeltä.", "action": "tab-diag"}
            ],
            "sv": [
                {"step": 1, "title": "Starta Web-IDE", "desc": "Starta VS Code på port 8090: <code>./scripts/deploy-blueprint.sh -b 8</code>", "action": "setup"},
                {"step": 2, "title": "Öppna VS Code i webbläsaren", "desc": "Anslut via <code>http://localhost:8090/</code>.", "url": "http://localhost:8090/"},
                {"step": 3, "title": "Anslut till databasen", "desc": "Använd Oracle SQL Developer-tillägget inuti editorn.", "action": "docs"},
                {"step": 4, "title": "Kör Web-IDE hälsokontroll", "desc": "Validera containerhälsan från Test-fliken.", "action": "tab-diag"}
            ],
            "lv": [
                {"step": 1, "title": "Palaist Web-IDE", "desc": "Startējiet VS Code portā 8090: <code>./scripts/deploy-blueprint.sh -b 8</code>", "action": "setup"},
                {"step": 2, "title": "Atvērt VS Code pārlūkā", "desc": "Atveriet <code>http://localhost:8090/</code>.", "url": "http://localhost:8090/"},
                {"step": 3, "title": "Pieslēgties datubāzei", "desc": "Izmantojiet Oracle SQL Developer paplašinājumu.", "action": "docs"},
                {"step": 4, "title": "Pārbaudīt Web-IDE", "desc": "Palaidiet veselības pārbaudi no Testēšanas cilnes.", "action": "tab-diag"}
            ],
            "lt": [
                {"step": 1, "title": "Paleisti Web-IDE", "desc": "Paleiskite VS Code prievade 8090: <code>./scripts/deploy-blueprint.sh -b 8</code>", "action": "setup"},
                {"step": 2, "title": "Atidaryti VS Code naršyklėje", "desc": "Prisijunkite per <code>http://localhost:8090/</code>.", "url": "http://localhost:8090/"},
                {"step": 3, "title": "Prisijungti prie DB", "desc": "Naudokite Oracle SQL Developer plėtinį.", "action": "docs"},
                {"step": 4, "title": "Patikrinti Web-IDE būseną", "desc": "Vykdykite patikrą iš Testavimo skirtuko.", "action": "tab-diag"}
            ]
        },
        "workflow_diagram": {
            "en": 'flowchart TB\\n    A["⚙️ Configuration<br/>(.env.8-web-ide)"] --> B["🚀 Deploy Web-IDE<br/>(web-ide-dev :8090)"]\\n    B --> C["🖥️ Browser VS Code<br/>(http://localhost:8090)"]\\n    C --> D{"Are tools & Oracle<br/>extension loaded?"}\\n    D -->|YES / Ready| E["💻 SQL Dev & Git Flow<br/>(Source code & migrations)"]\\n    D -->|NO / Booting| B\\n    E --> F["🚀 Local CI & Deploy<br/>(Commit & test)"]',
            "et": 'flowchart TB\\n    A["⚙️ Konfiguratsioon<br/>(.env.8-web-ide)"] --> B["🚀 Käivita Web-IDE<br/>(web-ide-dev :8090)"]\\n    B --> C["🖥️ Brauseri VS Code<br/>(http://localhost:8090)"]\\n    C --> D{"Kas tööriistad & DB<br/>laiendus olemas?"}\\n    D -->|JAH / Valmis| E["💻 SQL Dev & Git Töövoog<br/>(Kood & migratsioonid)"]\\n    D -->|EI / Laeb| B\\n    E --> F["🚀 Lokaalne CI & Test<br/>(Commit & deploy)"]',
            "fi": 'flowchart TB\\n    A["⚙️ Konfiguraatio<br/>(.env.8-web-ide)"] --> B["🚀 Käynnistä Web-IDE<br/>(web-ide-dev :8090)"]\\n    B --> C["🖥️ Selaimen VS Code<br/>(http://localhost:8090)"]\\n    C --> D{"Ovatko työkalut<br/>valmiina?"}\\n    D -->|KYLLÄ / Valmis| E["💻 SQL Dev & Git<br/>(Koodi ja migraatiot)"]\\n    D -->|EI / Latautuu| B\\n    E --> F["🚀 Testaus ja Deploy<br/>(Commit & test)"]',
            "sv": 'flowchart TB\\n    A["⚙️ Konfiguration<br/>(.env.8-web-ide)"] --> B["🚀 Starta Web-IDE<br/>(web-ide-dev :8090)"]\\n    B --> C["🖥️ Webbläsare VS Code<br/>(http://localhost:8090)"]\\n    C --> D{"Är verktygen och<br/>tilläggen laddade?"}\\n    D -->|JA / Redo| E["💻 SQL Dev & Git<br/>(Källkod & migreringar)"]\\n    D -->|NEJ / Startar| B\\n    E --> F["🚀 Lokal CI & Deploy<br/>(Commit & test)"]',
            "lv": 'flowchart TB\\n    A["⚙️ Konfigurācija<br/>(.env.8-web-ide)"] --> B["🚀 Startēt Web-IDE<br/>(web-ide-dev :8090)"]\\n    B --> C["🖥️ Pārlūka VS Code<br/>(http://localhost:8090)"]\\n    C --> D{"Vai rīki un paplašinājumi<br/>ir ielādēti?"}\\n    D -->|JĀ / Gatavs| E["💻 SQL Dev un Git<br/>(Kods un migrācijas)"]\\n    D -->|NĒ / Ielādējas| B\\n    E --> F["🚀 Vietējais CI & Deploy<br/>(Commit & test)"]',
            "lt": 'flowchart TB\\n    A["⚙️ Konfigūracija<br/>(.env.8-web-ide)"] --> B["🚀 Paleisti Web-IDE<br/>(web-ide-dev :8090)"]\\n    B --> C["🖥️ Naršyklės VS Code<br/>(http://localhost:8090)"]\\n    C --> D{"Ar įrankiai ir<br/>plėtiniai paruošti?"}\\n    D -->|TAIP / Paruošta| E["💻 SQL Dev ir Git<br/>(Kodas ir migracijos)"]\\n    D -->|NE / Kraunasi| B\\n    E --> F["🚀 Vietinis CI & Deploy<br/>(Commit & test)"]'
        },
        "tests": [
            {
                "key": "test-web-ide",
                "title": {"en": "💻 Web-IDE Container Healthcheck", "et": "💻 Web-IDE konteineri tervisekontroll", "fi": "💻 Web-IDE-kontin terveystarkastus", "sv": "💻 Web-IDE hälsokontroll", "lv": "💻 Web-IDE konteinera veselības pārbaude", "lt": "💻 Web-IDE konteinerio sveikatos patikra"},
                "desc": {"en": "Inspects VS Code server status on port 8090, filesystem permissions, and Oracle extension readiness.", "et": "Kontrollib VS Code serverit pordil 8090, failisüsteemi õigusi ja Oracle laienduse olemasolu.", "fi": "Tarkistaa VS Code -palvelimen portissa 8090 ja laajennukset.", "sv": "Kontrollerar VS Code-server på port 8090 och tillägg.", "lv": "Pārbauda VS Code serveri portā 8090 un paplašinājumus.", "lt": "Patikrina VS Code serverį prievade 8090 ir plėtinius."},
                "cmd": "./tests/integration/test-web-ide-container.sh",
                "color": "#a855f7",
                "icon": "💻"
            }
        ]
    }
}

# Standard default templates for all remaining blueprints (0, 2, 3, 4, 5, 6, 7, 10, 11)
DEFAULTS = {
    0: {"guide_id": "readme", "name": "Default Proxy DB & ORDS Gateway", "port": "1532, 8448"},
    2: {"guide_id": "security", "name": "Standalone APEX Proxy DB & SSO Gateway", "port": "1537, 8448"},
    3: {"guide_id": "image-switching", "name": "Community Vendor DB (gvenzl)", "port": "1535, 8448"},
    4: {"guide_id": "cloud-remote-deployment", "name": "Oracle Autonomous Database Cloud (ADB)", "port": "1536, 8448"},
    5: {"guide_id": "publisher-setup", "name": "Standalone Analytics Publisher", "port": "1531, 9502"},
    6: {"guide_id": "forms-setup", "name": "Standalone Oracle Forms 14c", "port": "1534, 9001, 6082"},
    7: {"guide_id": "forms-setup", "name": "Consolidated Forms 14c + Publisher FMW", "port": "1538, 9001, 9502"},
    10: {"guide_id": "devops-lifecycle", "name": "Remote ORDS Gateway & Edge Proxy", "port": "8088, 8448"},
    11: {"guide_id": "publisher-setup", "name": "Remote Analytics Publisher Server", "port": "9502"}
}

for b_id, d in DEFAULTS.items():
    if b_id not in BP_EXT_METADATA:
        g_id = d["guide_id"]
        b_name = d["name"]
        p_str = d["port"]
        BP_EXT_METADATA[b_id] = {
            "guide_id": g_id,
            "quickstart": {
                "en": [
                    {"step": 1, "title": "Deploy Blueprint Stack", "desc": f"Start containers with <code>./scripts/deploy-blueprint.sh -b {b_id}</code>", "action": "setup", "btn_text": "Start Stack"},
                    {"step": 2, "title": "Verify Services & Ports", "desc": f"Check network endpoints ({p_str}) and container health in the Architecture tab.", "action": "tab-arch"},
                    {"step": 3, "title": "Run Platform Diagnostics", "desc": "Execute health checks and connectivity tests from the Testing tab.", "action": "tab-diag", "btn_text": "Go to Tests 🧪"}
                ],
                "et": [
                    {"step": 1, "title": "Käivita Blueprinti virn", "desc": f"Käivita vajalikud konteinerid käsuga <code>./scripts/deploy-blueprint.sh -b {b_id}</code>", "action": "setup", "btn_text": "Käivita virn"},
                    {"step": 2, "title": "Kontrolli teenuseid & porte", "desc": f"Veendu, et võrgupordid ({p_str}) ja konteinerid on aktiivsed Arhitektuuri vahekaardil.", "action": "tab-arch"},
                    {"step": 3, "title": "Käivita diagnostika", "desc": "Käivita tervisekontrollid ja valideerimine Testimise vahekaardilt.", "action": "tab-diag", "btn_text": "Mine testide juurde 🧪"}
                ],
                "fi": [
                    {"step": 1, "title": "Käynnistä pino", "desc": f"Käynnistä kontit: <code>./scripts/deploy-blueprint.sh -b {b_id}</code>", "action": "setup"},
                    {"step": 2, "title": "Tarkista portit", "desc": f"Varmista portit ({p_str}) Arkkitehtuuri-välilehdeltä.", "action": "tab-arch"},
                    {"step": 3, "title": "Suorita diagnostiikka", "desc": "Suorita testit Testaus-välilehdeltä.", "action": "tab-diag"}
                ],
                "sv": [
                    {"step": 1, "title": "Starta stacken", "desc": f"Starta containrar: <code>./scripts/deploy-blueprint.sh -b {b_id}</code>", "action": "setup"},
                    {"step": 2, "title": "Kontrollera portar", "desc": f"Verifiera portar ({p_str}) i Arkitektur-fliken.", "action": "tab-arch"},
                    {"step": 3, "title": "Kör diagnostik", "desc": "Kör hälsotester från Test-fliken.", "action": "tab-diag"}
                ],
                "lv": [
                    {"step": 1, "title": "Startēt steku", "desc": f"Palaidiet konteinerus: <code>./scripts/deploy-blueprint.sh -b {b_id}</code>", "action": "setup"},
                    {"step": 2, "title": "Pārbaudīt portus", "desc": f"Pārbaudiet portus ({p_str}) Arhitektūras cilnē.", "action": "tab-arch"},
                    {"step": 3, "title": "Palaist diagnostiku", "desc": "Izpildiet testus Testēšanas cilnē.", "action": "tab-diag"}
                ],
                "lt": [
                    {"step": 1, "title": "Paleisti kaminą", "desc": f"Paleiskite konteinerius: <code>./scripts/deploy-blueprint.sh -b {b_id}</code>", "action": "setup"},
                    {"step": 2, "title": "Patikrinti prievadus", "desc": f"Patikrinkite prievadus ({p_str}) Architektūros skirtuke.", "action": "tab-arch"},
                    {"step": 3, "title": "Vykdyti diagnostiką", "desc": "Paleiskite testus Testavimo skirtuke.", "action": "tab-diag"}
                ]
            },
            "workflow_diagram": {
                "en": f'flowchart TB\\n    A["⚙️ Config (.env.{b_id})"] --> B["🚀 Deploy Stack<br/>({b_name})"]\\n    B --> C{{"Are containers &<br/>ports responsive?"}}\\n    C -->|YES / Healthy| D["✅ Operational Ready<br/>(Port: {p_str})"]\\n    C -->|NO / Starting| B',
                "et": f'flowchart TB\\n    A["⚙️ Seadistus (.env.{b_id})"] --> B["🚀 Käivita virn<br/>({b_name})"]\\n    B --> C{{"Kas konteinerid &<br/>pordid vastavad?"}}\\n    C -->|JAH / Korras| D["✅ Töövalmis<br/>(Pordid: {p_str})"]\\n    C -->|EI / Käivitub| B',
                "fi": f'flowchart TB\\n    A["⚙️ Asetukset (.env.{b_id})"] --> B["🚀 Käynnistä pino<br/>({b_name})"]\\n    B --> C{{"Toimivatko kontit ja<br/>portit?"}}\\n    C -->|KYLLÄ / Kunnossa| D["✅ Käyttövalmis<br/>(Portit: {p_str})"]\\n    C -->|EI / Käynnistyy| B',
                "sv": f'flowchart TB\\n    A["⚙️ Konfig (.env.{b_id})"] --> B["🚀 Starta stack<br/>({b_name})"]\\n    B --> C{{"Svarar containrar och<br/>portar?"}}\\n    C -->|JA / Felfri| D["✅ Driftklar<br/>(Portar: {p_str})"]\\n    C -->|NEJ / Startar| B',
                "lv": f'flowchart TB\\n    A["⚙️ Konfig (.env.{b_id})"] --> B["🚀 Startēt steku<br/>({b_name})"]\\n    B --> C{{"Vai konteineri un<br/>porti atbild?"}}\\n    C -->|JĀ / Kārtībā| D["✅ Gatavs darbam<br/>(Porti: {p_str})"]\\n    C -->|NĒ / Startējas| B',
                "lt": f'flowchart TB\\n    A["⚙️ Konfig (.env.{b_id})"] --> B["🚀 Paleisti kaminą<br/>({b_name})"]\\n    B --> C{{"Ar konteineriai ir<br/>prievadai atsako?"}}\\n    C -->|TAIP / Tvarkinga| D["✅ Paruošta darbui<br/>(Prievadai: {p_str})"]\\n    C -->|NE / Startuoja| B'
            },
            "tests": []
        }
