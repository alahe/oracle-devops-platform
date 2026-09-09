#!/usr/bin/env python3
"""
Oracle DevOps Platform — AI Skills Catalog & Relationships Engine (skills.py)
Dynamically scans .agents/skills/*/SKILL.md, parses YAML frontmatter,
maps inter-skill dependencies (Tiers 0..4), task-to-skill matrix,
and generates Rule 10-compliant Mermaid relationship diagrams.
"""

import os
import re
import glob

# Tier definitions & metadata
TIER_METADATA = {
    0: {
        "key": "tier_0",
        "name": "Tier 0: Master Navigator & Router",
        "name_et": "Tase 0: Peanavigaator ja Ruuter",
        "icon": "🧭",
        "color": "#f59e0b",
        "bg": "rgba(245, 158, 11, 0.12)",
        "border": "rgba(245, 158, 11, 0.35)",
    },
    1: {
        "key": "tier_1",
        "name": "Tier 1: Core Foundations & Lifecycle",
        "name_et": "Tase 1: Tuumik, Elutsükkel & DB Alused",
        "icon": "🏗️",
        "color": "#38bdf8",
        "bg": "rgba(56, 189, 248, 0.12)",
        "border": "rgba(56, 189, 248, 0.35)",
    },
    2: {
        "key": "tier_2",
        "name": "Tier 2: Enterprise OS & Portability",
        "name_et": "Tase 2: Enterprise Keskkonnad & Portatiivsus",
        "icon": "💻",
        "color": "#a855f7",
        "bg": "rgba(168, 85, 247, 0.12)",
        "border": "rgba(168, 85, 247, 0.35)",
    },
    3: {
        "key": "tier_3",
        "name": "Tier 3: Database Development & APEX",
        "name_et": "Tase 3: Andmebaasi Arendus, APEX & Tööriistad",
        "icon": "⚡",
        "color": "#10b981",
        "bg": "rgba(168, 85, 247, 0.12)",
        "border": "rgba(16, 185, 129, 0.35)",
    },
    4: {
        "key": "tier_4",
        "name": "Tier 4: Enterprise UI, Analytics & Visuals",
        "name_et": "Tase 4: UI Moderniseerimine, Raportid & Kujundus",
        "icon": "📊",
        "color": "#ec4899",
        "bg": "rgba(236, 72, 153, 0.12)",
        "border": "rgba(236, 72, 153, 0.35)",
    },
}

# Domain metadata map for the 18 known skills
SKILL_SPECS = {
    "repo_codebase_navigator": {
        "tier": 0,
        "icon": "🧭",
        "category": "navigator",
        "title_et": "Koodibaasi Peanavigaator ja Ruuter",
        "dependencies": [],
        "used_by": [
            "blueprints_and_topology", "testing_and_ci_framework", "setup_orchestration",
            "oracle_containers", "wallet_security_rotation", "windows_enterprise_devops",
            "devhub_architecture"
        ],
        "related": ["blueprints_and_topology", "testing_and_ci_framework", "devhub_architecture", "mermaid_diagram_design"]
    },
    "blueprints_and_topology": {
        "tier": 1,
        "icon": "📐",
        "category": "core_foundations",
        "title_et": "12 Kanoonilist Blueprinti ja Topoloogia",
        "dependencies": ["repo_codebase_navigator"],
        "used_by": ["setup_orchestration", "oracle_containers", "devhub_architecture", "vscode_sql_developer"],
        "related": ["oracle_containers", "setup_orchestration", "wallet_security_rotation", "devhub_architecture"]
    },
    "setup_orchestration": {
        "tier": 1,
        "icon": "⚙️",
        "category": "core_foundations",
        "title_et": "Paigalduse ja Lähtestuse Orkestreerimine",
        "dependencies": ["blueprints_and_topology"],
        "used_by": ["golden_snapshots_dr", "testing_and_ci_framework"],
        "related": ["oracle_containers", "wallet_security_rotation", "golden_snapshots_dr", "testing_and_ci_framework"]
    },
    "oracle_containers": {
        "tier": 1,
        "icon": "🐳",
        "category": "core_foundations",
        "title_et": "Oracle 23ai Free DB Konteinerid & FastStart",
        "dependencies": ["blueprints_and_topology"],
        "used_by": ["setup_orchestration", "golden_snapshots_dr", "oracle_forms_devops"],
        "related": ["setup_orchestration", "wallet_security_rotation", "golden_snapshots_dr"]
    },
    "wallet_security_rotation": {
        "tier": 1,
        "icon": "🔒",
        "category": "core_foundations",
        "title_et": "SEPS Wallet, Zero-Trust ja Paroolide Rotatsioon",
        "dependencies": ["blueprints_and_topology"],
        "used_by": ["sqlcl_project", "vscode_sql_developer", "devhub_architecture", "setup_orchestration", "apex_dev", "oracle_publisher"],
        "related": ["sqlcl_project", "vscode_sql_developer", "devhub_architecture"]
    },
    "testing_and_ci_framework": {
        "tier": 1,
        "icon": "🧪",
        "category": "core_foundations",
        "title_et": "Testiraamistik (172 testi) ja Kohalik CI/CD",
        "dependencies": ["setup_orchestration", "cross_platform_portability"],
        "used_by": ["devhub_architecture"],
        "related": ["cross_platform_portability", "sqlcl_project", "devhub_architecture"]
    },
    "golden_snapshots_dr": {
        "tier": 1,
        "icon": "📸",
        "category": "core_foundations",
        "title_et": "Kuldsed Snapshotid ja ~15s Kiirtaastus",
        "dependencies": ["oracle_containers", "setup_orchestration"],
        "used_by": [],
        "related": ["oracle_containers", "blueprints_and_topology", "setup_orchestration"]
    },
    "windows_enterprise_devops": {
        "tier": 2,
        "icon": "💻",
        "category": "enterprise",
        "title_et": "Windows Ettevõttekeskkond, WSL2, Proxy & VPN",
        "dependencies": ["cross_platform_portability"],
        "used_by": ["setup_orchestration"],
        "related": ["cross_platform_portability", "blueprints_and_topology"]
    },
    "cross_platform_portability": {
        "tier": 2,
        "icon": "🌐",
        "category": "enterprise",
        "title_et": "Ristplatvormne Faili- ja Teeportatiivsus (Reegel 13)",
        "dependencies": [],
        "used_by": ["windows_enterprise_devops", "testing_and_ci_framework"],
        "related": ["windows_enterprise_devops", "testing_and_ci_framework"]
    },
    "sqlcl_project": {
        "tier": 3,
        "icon": "⚡",
        "category": "database_apps",
        "title_et": "SQLcl Projektid, Liquibase ja Git CI/CD",
        "dependencies": ["wallet_security_rotation"],
        "used_by": ["apex_dev", "apexlang_app_generation"],
        "related": ["wallet_security_rotation", "vscode_sql_developer", "apex_dev"]
    },
    "vscode_sql_developer": {
        "tier": 3,
        "icon": "🔌",
        "category": "database_apps",
        "title_et": "VS Code Oracle SQL Developer Ühenduste Registreerimine",
        "dependencies": ["wallet_security_rotation", "blueprints_and_topology"],
        "used_by": [],
        "related": ["wallet_security_rotation", "sqlcl_project"]
    },
    "apex_dev": {
        "tier": 3,
        "icon": "🚀",
        "category": "database_apps",
        "title_et": "APEX Arendaja Provisioning, SSO & APEX_LANG",
        "dependencies": ["sqlcl_project", "wallet_security_rotation"],
        "used_by": ["apexlang", "apexlang_app_generation", "oracle_forms_devops"],
        "related": ["apexlang", "apexlang_app_generation", "sqlcl_project"]
    },
    "apexlang": {
        "tier": 3,
        "icon": "📜",
        "category": "database_apps",
        "title_et": "APEXlang Deklaratiivne DSL Ruuter ja Lepingud",
        "dependencies": ["apex_dev"],
        "used_by": ["apexlang_app_generation"],
        "related": ["apexlang_app_generation", "apex_dev"]
    },
    "apexlang_app_generation": {
        "tier": 3,
        "icon": "🏗️",
        "category": "database_apps",
        "title_et": "APEX Rakenduste Genereerimine .apx DSL-ist",
        "dependencies": ["apexlang", "apex_dev"],
        "used_by": [],
        "related": ["apexlang", "apex_dev", "sqlcl_project"]
    },
    "oracle_publisher": {
        "tier": 4,
        "icon": "📊",
        "category": "ui_reporting",
        "title_et": "Oracle Analytics Publisher (BIP) ja REST Raportid",
        "dependencies": ["blueprints_and_topology", "wallet_security_rotation"],
        "used_by": ["devhub_architecture", "oracle_publisher_accessibility"],
        "related": ["devhub_architecture", "blueprints_and_topology", "oracle_publisher_accessibility"]
    },
    "oracle_publisher_accessibility": {
        "tier": 4,
        "icon": "♿",
        "category": "ui_reporting",
        "title_et": "Publisher Ligipääsetavus (PDF/UA-1, WCAG AA & Sec 508)",
        "dependencies": ["oracle_publisher", "testing_and_ci_framework"],
        "used_by": ["testing_and_ci_framework"],
        "related": ["oracle_publisher", "testing_and_ci_framework", "cross_platform_portability"]
    },
    "oracle_forms_devops": {
        "tier": 4,
        "icon": "🖼️",
        "category": "ui_reporting",
        "title_et": "Oracle Forms 14c noVNC GUI ja APEX Migratsioon",
        "dependencies": ["oracle_containers", "apex_dev"],
        "used_by": [],
        "related": ["apex_dev", "blueprints_and_topology"]
    },
    "devhub_architecture": {
        "tier": 4,
        "icon": "🌐",
        "category": "ui_reporting",
        "title_et": "Developer Hub SPA Arhitektuur ja Kompilaator",
        "dependencies": ["blueprints_and_topology", "wallet_security_rotation", "mermaid_diagram_design"],
        "used_by": [],
        "related": ["mermaid_diagram_design", "testing_and_ci_framework", "blueprints_and_topology"]
    },
    "mermaid_diagram_design": {
        "tier": 4,
        "icon": "🎨",
        "category": "ui_reporting",
        "title_et": "Reageerivad Mermaid Diagrammid ja Reegel 10",
        "dependencies": [],
        "used_by": ["devhub_architecture", "repo_codebase_navigator"],
        "related": ["devhub_architecture", "repo_codebase_navigator"]
    }
}

# 16 Practical Developer Tasks mapped to skills
TASK_MATRIX = [
    {
        "id": "task_navigate_repo",
        "task": {
            "en": "Explore repository mental model, directory atlas and locate code",
            "et": "Koodibaasis orienteerumine, kataloogipuu ja funktsioonide asukohtade leidmine",
            "fi": "Koodikannan hahmottaminen, hakemistorakenne ja tiedostojen paikantaminen",
            "sv": "Utforska kodbasens struktur, katalogträd och hitta rätt filer",
            "lv": "Repozitorija struktūras izpēte, direktoriju koks un koda atrašana",
            "lt": "Kodo bazės struktūros tyrimas, katalogų medis ir failų radimas"
        },
        "primary_skill": "repo_codebase_navigator",
        "secondary_skills": ["blueprints_and_topology", "testing_and_ci_framework"],
        "cli_hint": "grep / find / .agents/skills/repo_codebase_navigator/SKILL.md"
    },
    {
        "id": "task_add_db_service",
        "task": {
            "en": "Add a new database profile, PDB or custom container service",
            "et": "Uue andmebaasi profiili, PDB või konteinerteenuse lisamine",
            "fi": "Uuden tietokantaprofiilin, PDB:n tai konttipalvelun lisääminen",
            "sv": "Lägg till en ny databasprofil, PDB eller containertjänst",
            "lv": "Pievienot jaunu datubāzes profilu, PDB vai konteinera pakalpojumu",
            "lt": "Pridėti naują duomenų bazės profilį, PDB ar konteinerio paslaugą"
        },
        "primary_skill": "blueprints_and_topology",
        "secondary_skills": ["oracle_containers", "wallet_security_rotation"],
        "cli_hint": "config/blueprints/.env.<N> & config/profiles/databases/*.yaml"
    },
    {
        "id": "task_orchestrate_setup",
        "task": {
            "en": "Deploy full environment or reset containers cleanly (setup/reset)",
            "et": "Kogu keskkonna paigaldus või puhas lähtestamine (setup/reset)",
            "fi": "Ympäristön täysi asennus tai puhdas nollaus (setup/reset)",
            "sv": "Distribuera hela miljön eller återställ rent (setup/reset)",
            "lv": "Izvietot pilnu vidi vai tīri atiestatīt (setup/reset)",
            "lt": "Įdiegti visą aplinką arba švariai atkurti (setup/reset)"
        },
        "primary_skill": "setup_orchestration",
        "secondary_skills": ["blueprints_and_topology", "oracle_containers"],
        "cli_hint": "./scripts/setup-all.sh / ./scripts/reset-all.sh"
    },
    {
        "id": "task_run_tests_ci",
        "task": {
            "en": "Run automated test suites, 6-language audit and local CI simulation",
            "et": "Automaattestide, 6-keelse auditi ja kohaliku CI/CD käivitamine",
            "fi": "Automaattitestien, 6 kielen auditoinnin ja paikallisen CI:n ajo",
            "sv": "Kör automatiserade tester, flerspråksrevision och lokal CI-simulering",
            "lv": "Palaist automatizētos testus, 6 valodu auditu un lokālo CI",
            "lt": "Paleisti automatinius testus, 6 kalbų auditą ir vietinį CI"
        },
        "primary_skill": "testing_and_ci_framework",
        "secondary_skills": ["cross_platform_portability", "sqlcl_project"],
        "cli_hint": "./scripts/test-local-ci.sh & ./tests/test-multilingual-support.sh --all"
    },
    {
        "id": "task_read_passwords_wallet",
        "task": {
            "en": "Read zero-trust credentials and rotate SEPS wallet passwords",
            "et": "Paroolide pärimine ja SEPS Wallet paroolide turvaline rotatsioon",
            "fi": "Zero-trust-tunnusten lukeminen ja SEPS-lompakon salasanojen vaihto",
            "sv": "Läs zero-trust-lösenord och rotera SEPS-plånbokssäkerhet",
            "lv": "Lasīt zero-trust akreditācijas datus un rotēt SEPS maka paroles",
            "lt": "Skaityti zero-trust prisijungimus ir keisti SEPS piniginės slaptažodžius"
        },
        "primary_skill": "wallet_security_rotation",
        "secondary_skills": ["vscode_sql_developer", "sqlcl_project"],
        "cli_hint": "./scripts/get-password.sh <ALIAS>"
    },
    {
        "id": "task_windows_wsl2_setup",
        "task": {
            "en": "Troubleshoot Windows WSL2, enterprise proxy, NTLM & VPN split tunnel",
            "et": "Windows 11 / WSL2, ettevõtte proxy, NTLM ja VPN seadistamine",
            "fi": "Windows WSL2:n, yritysvälityspalvelimen ja VPN:n vianmääritys",
            "sv": "Felsök Windows WSL2, företagsproxy, NTLM och VPN-tunnel",
            "lv": "Novērst Windows WSL2, korporatīvā starpniekservera un VPN problēmas",
            "lt": "Spręsti Windows WSL2, įmonės proxy ir VPN tunelio problemas"
        },
        "primary_skill": "windows_enterprise_devops",
        "secondary_skills": ["cross_platform_portability"],
        "cli_hint": "./scripts/onboard-enterprise.sh"
    },
    {
        "id": "task_verify_portability",
        "task": {
            "en": "Verify Rule 13 filename portability before committing changes",
            "et": "Failiportatiivsuse (Reegel 13) kontrollimine enne Git committi",
            "fi": "Tarkista tiedostonimien siirrettävyys (Sääntö 13) ennen committia",
            "sv": "Verifiera filnamnsportabilitet (Regel 13) före commit",
            "lv": "Pārbaudīt failu nosaukumu pārnesamību (13. noteikums) pirms commit",
            "lt": "Patikrinti failų pavadinimų perkeliamumą (13 taisyklė) prieš commit"
        },
        "primary_skill": "cross_platform_portability",
        "secondary_skills": ["testing_and_ci_framework"],
        "cli_hint": "./tests/unit/test-filename-portability.sh"
    },
    {
        "id": "task_golden_snapshot",
        "task": {
            "en": "Create golden snapshot or perform instant ~15s database recovery",
            "et": "Kuldse snapshot'i loomine või ~15s andmebaasi kiirtaastus",
            "fi": "Kultaisen tilannevedoksen luonti tai ~15s palautus",
            "sv": "Skapa gyllene ögonblicksbild eller ~15s databasåterställning",
            "lv": "Izveidot zelta momentuzņēmumu vai ~15s datubāzes atkopšanu",
            "lt": "Sukurti auksinę momentinę kopiją arba ~15s greitą atkūrimą"
        },
        "primary_skill": "golden_snapshots_dr",
        "secondary_skills": ["setup_orchestration", "oracle_containers"],
        "cli_hint": "./scripts/snapshots/create-golden-snapshots.sh / restore-golden-snapshots.sh"
    },
    {
        "id": "task_sqlcl_liquibase",
        "task": {
            "en": "Manage SQLcl Liquibase declarative changelogs and schema migrations",
            "et": "SQLcl Liquibase deklaratiivsete changelogide ja skeemi haldus",
            "fi": "SQLcl Liquibase -muutoslokien ja skeemamigraatioiden hallinta",
            "sv": "Hantera SQLcl Liquibase ändringsloggar och schemamigrering",
            "lv": "Pārvaldīt SQLcl Liquibase deklaratīvos žurnālus un shēmas",
            "lt": "Valdyti SQLcl Liquibase deklaratyvius žurnalus ir schemas"
        },
        "primary_skill": "sqlcl_project",
        "secondary_skills": ["wallet_security_rotation", "vscode_sql_developer"],
        "cli_hint": "./scripts/sqlcl.sh /@<ALIAS>"
    },
    {
        "id": "task_vscode_connections",
        "task": {
            "en": "Register VS Code Oracle SQL Developer connections with OS Keychain",
            "et": "VS Code Oracle SQL Developer ühenduste automaatne registreerimine",
            "fi": "VS Coden Oracle SQL Developer -yhteyksien automaattinen rekisteröinti",
            "sv": "Registrera VS Code Oracle SQL Developer-anslutningar automatiskt",
            "lv": "Automātiski reģistrēt VS Code Oracle SQL Developer savienojumus",
            "lt": "Automatiškai užregistruoti VS Code Oracle SQL Developer ryšius"
        },
        "primary_skill": "vscode_sql_developer",
        "secondary_skills": ["wallet_security_rotation", "blueprints_and_topology"],
        "cli_hint": "./scripts/register-connections.sh"
    },
    {
        "id": "task_apex_developer_sso",
        "task": {
            "en": "Provision APEX developer accounts and configure Entra-ID SSO",
            "et": "APEX arendajakontode loomine ja Azure Entra-ID SSO autentimine",
            "fi": "APEX-kehittäjätilien luonti ja Azure Entra-ID SSO -todennus",
            "sv": "Provisionera APEX-utvecklarkonton och konfigurera Entra-ID SSO",
            "lv": "Nodrošināt APEX izstrādātāju kontus un konfigurēt Entra-ID SSO",
            "lt": "Sukurti APEX kūrėjų paskyras ir sukonfigūruoti Entra-ID SSO"
        },
        "primary_skill": "apex_dev",
        "secondary_skills": ["sqlcl_project", "wallet_security_rotation"],
        "cli_hint": "./scripts/create-developer.sh <USERNAME> [WORKSPACE]"
    },
    {
        "id": "task_apexlang_generation",
        "task": {
            "en": "Generate production APEX applications from .apx DSL specifications",
            "et": "APEX rakenduste genereerimine deklaratiivsest .apx DSL failist",
            "fi": "APEX-sovellusten luonti deklaratiivisesta .apx DSL -tiedostosta",
            "sv": "Generera APEX-applikationer från deklarativ .apx DSL-fil",
            "lv": "Ģenerēt APEX lietojumprogrammas no deklaratīva .apx DSL faila",
            "lt": "Generuoti APEX programas iš deklaratyvaus .apx DSL failo"
        },
        "primary_skill": "apexlang_app_generation",
        "secondary_skills": ["apexlang", "apex_dev"],
        "cli_hint": "APEXlang DSL / .agents/skills/apexlang_app_generation/SKILL.md"
    },
    {
        "id": "task_analytics_publisher",
        "task": {
            "en": "Deploy Oracle Analytics Publisher pixel-perfect reports and REST APIs",
            "et": "Oracle Analytics Publisher pixel-perfect raportite paigaldus ja REST API",
            "fi": "Oracle Analytics Publisher -raporttien asennus ja REST API",
            "sv": "Distribuera Analytics Publisher pixel-perfect-rapporter och REST API",
            "lv": "Izvietot Analytics Publisher atskaites un REST API",
            "lt": "Įdiegti Analytics Publisher ataskaitas ir REST API"
        },
        "primary_skill": "oracle_publisher",
        "secondary_skills": ["blueprints_and_topology", "wallet_security_rotation"],
        "cli_hint": "./scripts/publisher/status-publisher.sh"
    },
    {
        "id": "task_audit_publisher_a11y",
        "task": {
            "en": "Audit Publisher templates for PDF/UA-1, Section 508 & WCAG 2.1 AA accessibility",
            "et": "Publisheri mallide ligipääsetavuse audit (PDF/UA-1, Section 508 & WCAG AA)",
            "fi": "Publisher-mallien saavutettavuusauditointi (PDF/UA-1, Section 508 & WCAG AA)",
            "sv": "Granska Publisher-mallar för PDF/UA-1, Section 508 & WCAG 2.1 AA tillgänglighet",
            "lv": "Pārbaudīt Publisher veidņu piekļūstamību (PDF/UA-1, Section 508 & WCAG AA)",
            "lt": "Tikrinti Publisher šablonų prieinamumą (PDF/UA-1, Section 508 & WCAG AA)"
        },
        "primary_skill": "oracle_publisher_accessibility",
        "secondary_skills": ["oracle_publisher", "testing_and_ci_framework"],
        "cli_hint": "./scripts/publisher/validate-rtf-accessibility.sh <rtf>"
    },
    {
        "id": "task_forms_novnc",
        "task": {
            "en": "Run Oracle Forms 14c Builder in browser via noVNC and plan APEX migration",
            "et": "Oracle Forms 14c käivitamine brauseris (noVNC) ja APEX migratsioon",
            "fi": "Oracle Forms 14c:n käyttö selaimessa noVNC:n kautta ja APEX-migraatio",
            "sv": "Kör Oracle Forms 14c i webbläsaren via noVNC och migrera till APEX",
            "lv": "Darbināt Oracle Forms 14c pārlūkprogrammā ar noVNC un migrēt uz APEX",
            "lt": "Paleisti Oracle Forms 14c naršyklėje per noVNC ir migruoti į APEX"
        },
        "primary_skill": "oracle_forms_devops",
        "secondary_skills": ["oracle_containers", "apex_dev"],
        "cli_hint": "http://localhost:6080/vnc.html"
    },
    {
        "id": "task_devhub_maintenance",
        "task": {
            "en": "Update Developer Hub cards, glossary, test history and recompile SPA",
            "et": "Developer Hubi kaartide, sõnastiku, testide täiendamine ja HTML kompileerimine",
            "fi": "Developer Hubin korttien, sanaston ja testien päivitys sekä kääntäminen",
            "sv": "Uppdatera Developer Hub-kort, ordlista, tester och kompilera om HTML",
            "lv": "Atjaunināt Developer Hub kartītes, vārdnīcu, testus un kompilēt HTML",
            "lt": "Atnaujinti Developer Hub korteles, žodyną, testus ir perkompiliuoti HTML"
        },
        "primary_skill": "devhub_architecture",
        "secondary_skills": ["mermaid_diagram_design", "testing_and_ci_framework"],
        "cli_hint": "python3 scripts/internal/dev_hub/compiler.py"
    },
    {
        "id": "task_mermaid_design",
        "task": {
            "en": "Design responsive, balanced Mermaid flowcharts following Rule 10",
            "et": "Reageerivate ja ekraanile mahtuvate Mermaid diagrammide koostamine (Reegel 10)",
            "fi": "Responsiivisten Mermaid-kaavioiden suunnittelu (Sääntö 10)",
            "sv": "Designa responsiva och balanserade Mermaid-diagram (Regel 10)",
            "lv": "Izveidot pielāgotas un līdzsvarotas Mermaid diagrammas (10. noteikums)",
            "lt": "Kurti prisitaikančias Mermaid diagramas pagal 10 taisyklę"
        },
        "primary_skill": "mermaid_diagram_design",
        "secondary_skills": ["devhub_architecture", "repo_codebase_navigator"],
        "cli_hint": "Use <br/> in diamonds & boxes, max 30 chars per line"
    }
]

def parse_frontmatter(content):
    """Extracts YAML frontmatter from Markdown file content."""
    meta = {}
    body = content
    if content.startswith("---"):
        parts = content.split("---", 2)
        if len(parts) >= 3:
            raw_fm = parts[1].strip()
            body = parts[2].strip()
            
            # Simple regex-based YAML parser for name and description
            m_name = re.search(r"^name:\s*(.+)$", raw_fm, re.MULTILINE)
            if m_name:
                meta["name"] = m_name.group(1).strip()
            
            m_desc = re.search(r"^description:\s*(?:>-\s*|\s*)(.*?)(?=\n[a-z_]+:|\Z)", raw_fm, re.DOTALL | re.MULTILINE)
            if m_desc:
                # Clean description string
                clean_desc = " ".join(line.strip() for line in m_desc.group(1).splitlines() if line.strip())
                meta["description"] = clean_desc
    return meta, body

def extract_h1_title(content):
    """Finds the first H1 markdown heading."""
    for line in content.splitlines():
        line = line.strip()
        if line.startswith("# ") and not line.startswith("##"):
            return line[2:].strip()
    return ""

def extract_triggers(description):
    """Extracts search triggers / keywords from description."""
    triggers = []
    # Common trigger words
    desc_clean = description.replace("(", " ").replace(")", " ").replace(",", " ").replace(".", " ")
    for word in desc_clean.split():
        w = word.strip().strip("'\"").strip()
        if len(w) >= 4 and w.lower() not in ["whenever", "across", "before", "platform", "guidelines", "rules", "using", "with", "this"]:
            if w not in triggers:
                triggers.append(w)
    return triggers[:8]

def get_skills_catalog(workspace_dir):
    """
    Scans .agents/skills/ directory and builds complete catalog
    for all skills with dependencies and metadata.
    """
    skills_dir = os.path.join(workspace_dir, ".agents", "skills")
    catalog = []

    if not os.path.isdir(skills_dir):
        return catalog

    for skill_name in sorted(os.listdir(skills_dir)):
        skill_path = os.path.join(skills_dir, skill_name)
        skill_file = os.path.join(skill_path, "SKILL.md")
        
        if os.path.isdir(skill_path) and os.path.isfile(skill_file):
            content = ""
            try:
                with open(skill_file, "r", encoding="utf-8", errors="ignore") as sf:
                    content = sf.read()
            except Exception:
                continue

            meta, body = parse_frontmatter(content)
            h1 = extract_h1_title(body)
            desc = meta.get("description", "")
            
            # Lookup curated specs
            spec = SKILL_SPECS.get(skill_name, {
                "tier": 1,
                "icon": "📦",
                "category": "core_foundations",
                "title_et": h1 or skill_name,
                "dependencies": [],
                "used_by": [],
                "related": []
            })
            
            tier_info = TIER_METADATA.get(spec["tier"], TIER_METADATA[1])
            triggers = extract_triggers(desc)
            
            catalog.append({
                "id": skill_name,
                "name": meta.get("name", skill_name),
                "title": h1 or skill_name.replace("_", " ").title(),
                "title_et": spec.get("title_et", h1 or skill_name),
                "description": desc,
                "tier": spec["tier"],
                "tier_name": tier_info["name"],
                "tier_name_et": tier_info["name_et"],
                "tier_color": tier_info["color"],
                "tier_bg": tier_info["bg"],
                "tier_border": tier_info["border"],
                "icon": spec.get("icon", "📦"),
                "category": spec.get("category", "core_foundations"),
                "rel_path": os.path.relpath(skill_file, workspace_dir),
                "dependencies": spec.get("dependencies", []),
                "used_by": spec.get("used_by", []),
                "related": spec.get("related", []),
                "triggers": triggers,
                "markdown": body,
                "sloc": len(content.splitlines()),
                "bytes": len(content.encode("utf-8"))
            })

    # Sort catalog: Tier ascending, then name ascending
    catalog.sort(key=lambda x: (x["tier"], x["id"]))
    return catalog

def generate_skills_mermaid():
    """
    Generates a responsive Mermaid relationship graph adhering strictly
    to Rule 10 (multi-line diamonds, <br/> breaks, max 30 chars/line, flowchart TB).
    """
    mermaid_code = """flowchart TB
    %% ==========================================
    %% TIER 0: MASTER NAVIGATOR & ROUTER
    %% ==========================================
    subgraph T0 ["🧭 Tier 0: Master Router"]
        direction TB
        NAV["repo_codebase_navigator<br/>(Central Directory Atlas)"]
    end

    %% ==========================================
    %% TIER 1: CORE FOUNDATIONS & LIFECYCLE
    %% ==========================================
    subgraph T1 ["🏗️ Tier 1: Core Platform & Foundations"]
        direction TB
        BP["blueprints_and_topology<br/>(12 Blueprints & Dynamic Ports)"]
        SET["setup_orchestration<br/>(setup-all.sh & Locks)"]
        DB["oracle_containers<br/>(23ai Free DB & FastStart)"]
        WLT["wallet_security_rotation<br/>(SEPS Wallet & Zero-Trust)"]
        TST["testing_and_ci_framework<br/>(172 Tests & Local CI)"]
        SNP["golden_snapshots_dr<br/>(Golden Snapshots ~15s)"]
    end

    %% ==========================================
    %% TIER 2: ENTERPRISE & OS PORTABILITY
    %% ==========================================
    subgraph T2 ["💻 Tier 2: Enterprise OS & Portability"]
        direction TB
        WIN["windows_enterprise_devops<br/>(WSL2, Proxy & Corporate VPN)"]
        PORT["cross_platform_portability<br/>(Rule 13 Filename Portability)"]
    end

    %% ==========================================
    %% TIER 3: DATABASE DEVELOPMENT & APEX
    %% ==========================================
    subgraph T3 ["⚡ Tier 3: Database Development & APEX"]
        direction TB
        SQL["sqlcl_project<br/>(Liquibase & Git CI/CD)"]
        VSC["vscode_sql_developer<br/>(Connections Registration)"]
        APX["apex_dev<br/>(Provisioning & SSO)"]
        DSL["apexlang & app_generation<br/>(APEXlang DSL .apx)"]
    end

    %% ==========================================
    %% TIER 4: UI, ANALYTICS & VISUAL DESIGN
    %% ==========================================
    subgraph T4 ["📊 Tier 4: Enterprise UI, Analytics & Visuals"]
        direction TB
        PUB["oracle_publisher<br/>(Pixel Perfect & REST API)"]
        FRM["oracle_forms_devops<br/>(Forms 14c noVNC & APEX)"]
        HUB["devhub_architecture<br/>(Dev Hub SPA & Bridge)"]
        MER["mermaid_diagram_design<br/>(Responsive Rule 10 Design)"]
    end

    %% Router Connections
    NAV -->|"Architecture"| BP
    NAV -->|"Lifecycle"| SET
    NAV -->|"Security"| WLT
    NAV -->|"Verification"| TST
    NAV -->|"Windows / WSL2"| WIN

    %% Core Dependencies
    BP --> SET
    BP --> DB
    BP --> WLT
    SET --> SNP
    DB --> SNP
    PORT --> WIN
    PORT --> TST

    %% Database & APEX Tooling
    WLT -.->|"SEPS Passwords"| SQL
    WLT -.->|"Keychain"| VSC
    SQL --> APX
    APX --> DSL

    %% UI & Enterprise Connectors
    BP -.-> PUB
    DB -.-> FRM
    APX -.-> FRM
    HUB -.-> MER
    WLT -.-> HUB
"""
    return mermaid_code

def get_skills_task_matrix():
    """Returns practical task matrix for Dev Hub."""
    return TASK_MATRIX
