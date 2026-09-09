"""
Testing utilities and catalog scanners for Developer Hub (tab-testing).
"""
import os
import re
import json
from datetime import datetime

SCRIPT_DOC_PATTERNS = [
    (r"^test-(apex-suite|apex-devhub.*)\.sh$", {
        "doc_file": "docs/apex-devhub-test-plan.md",
        "doc_key": "apex_testing",
        "title": "Oracle APEX DevHub Testing Plan"
    }),
    (r"^test-.*glossary.*\.sh$", {
        "doc_file": "docs/glossary.md",
        "doc_key": "glossary",
        "title": "Architecture Glossary & Acronyms"
    }),
    (r"^(test|report)-(repo-stats|devhub-mermaid-rendering|devhub-search-and-filters|devhub-testing-tab|dev-hub-generation|i18n-translations|filename-portability|multilingual-support|live-platform|pre-commit.*|devhub-doc-links|title-capitalization.*)\.sh$", {
        "doc_file": "docs/testing-framework-and-devhub.md",
        "doc_key": "testing_framework",
        "title": "Testing Framework & Dev Hub Architecture"
    }),
    (r"^test-(browser-login|devhub-browser-blueprints|devhub-lifecycle.*)\.sh$", {
        "doc_file": "docs/devhub-browser-testing-plan.md",
        "doc_key": "devhub_browser_testing",
        "title": "DevHub Browser Blueprints E2E Testing Plan"
    }),
    (r"^test-(all-blueprints.*|blueprints.*|blueprint-profiles-integrity|cli-blueprint-params|script-deploy-blueprint|script-test-all-blueprints.*)\.sh$", {
        "doc_file": "docs/incremental-blueprints-test-plan.md",
        "doc_key": "incremental_blueprints_testing",
        "title": "Incremental Blueprints Testing Plan"
    }),
    (r"^test-.*forms.*\.sh$", {
        "doc_file": "docs/forms-setup.md",
        "doc_key": "forms_setup",
        "title": "Oracle Forms 14c Setup Guide"
    }),
    (r"^test-.*publisher.*\.sh$", {
        "doc_file": "docs/publisher-setup.md",
        "doc_key": "publisher_setup",
        "title": "Analytics Publisher Setup Guide"
    }),
    (r"^test-.*ords.*\.sh$", {
        "doc_file": "docs/ords-profiles-lifecycle.md",
        "doc_key": "ords_lifecycle",
        "title": "ORDS Profiles & Topology Lifecycle"
    }),
    (r"^test-.*(wallet|db-profiles|password|load-profile|resolve-topology|apply-profile).*\.sh$", {
        "doc_file": "docs/db-profiles-and-topology.md",
        "doc_key": "db_topology",
        "title": "Database Profiles & Dynamic Topology"
    }),
    (r"^test-.*(artifactory|web-ide).*\.sh$", {
        "doc_file": "docs/artifactory-setup.md",
        "doc_key": "artifactory_setup",
        "title": "Enterprise Artifactory Setup & Offline Delivery"
    }),
    (r"^test-.*remote.*\.sh$", {
        "doc_file": "docs/remote-multicloud-setup-guide.md",
        "doc_key": "remote_multicloud",
        "title": "Multi-Cloud Enterprise Remote DB Architecture"
    }),
    (r"^test-.*(windows|wsl).*\.sh$", {
        "doc_file": "docs/windows-enterprise-setup-guide.md",
        "doc_key": "windows_enterprise_guide",
        "title": "Enterprise Windows & WSL2 Setup Guide"
    }),
    (r"^test-.*enterprise-onboarding.*\.sh$", {
        "doc_file": "docs/enterprise-onboarding-guide.md",
        "doc_key": "enterprise_onboarding_guide",
        "title": "Enterprise Onboarding & Registry Mirrors Guide"
    }),
    (r"^test-.*security-audit.*\.sh$", {
        "doc_file": "docs/security-audit-report.md",
        "doc_key": "security_audit",
        "title": "Enterprise Security Audit & Hardening"
    }),
    (r"^test-(all-components|subcomponent-services|instance-initializer|e2e-system|devhub-async-guardrails|credentials-matrix)\.sh$", {
        "doc_file": "docs/devhub-platform-test-plan.md",
        "doc_key": "devhub_platform_testing",
        "title": "DevHub Platform Full Lifecycle Test Plan"
    }),
]

def get_script_doc_reference(script_name):
    """Returns matching doc metadata for a test script or default testing doc."""
    sname = os.path.basename(script_name)
    for pattern, info in SCRIPT_DOC_PATTERNS:
        if re.search(pattern, sname):
            return info
    return {
        "doc_file": "docs/testing-framework-and-devhub.md",
        "doc_key": "testing_framework",
        "title": "Testing Framework & Dev Hub Architecture"
    }

def get_test_suites_catalog(ws):
    """Returns structured catalog of test suites and test scripts."""
    unit_tests = []
    unit_dir = os.path.join(ws, "tests", "unit")
    if os.path.isdir(unit_dir):
        for f in sorted(os.listdir(unit_dir)):
            if f.endswith(".sh") and not f.startswith("."):
                unit_tests.append(f)

    integration_tests = []
    integ_dir = os.path.join(ws, "tests", "integration")
    if os.path.isdir(integ_dir):
        for f in sorted(os.listdir(integ_dir)):
            if f.endswith(".sh") and not f.startswith("."):
                integration_tests.append(f)

    return {
        "unit": {
            "key": "unit",
            "category": "core",
            "title": "Unit Test Suite",
            "desc": f"Fast isolation tests ({len(unit_tests)} scripts) validating configs, SEPS wallet, script syntax, and logic without live DB",
            "icon": "🧪",
            "count": len(unit_tests),
            "tests": unit_tests,
            "cmd": "./tests/test-all-components.sh"
        },
        "integration": {
            "key": "integration",
            "category": "core",
            "title": "Integration Test Suite",
            "desc": f"Multi-database topology ({len(integration_tests)} scripts), compose override generation, profile roles, and connection handshakes",
            "icon": "⚙️",
            "count": len(integration_tests),
            "tests": integration_tests,
            "cmd": "tests/integration/*.sh"
        },
        "apex": {
            "key": "apex",
            "category": "e2e",
            "title": "Oracle APEX Full Test Suite",
            "desc": "4-tier comprehensive APEX suite: Level 1 (utPLSQL), Level 2 (REST Bridge), Level 3 (Browser E2E), Level 4 (APEX Advisor)",
            "icon": "⚡",
            "count": 4,
            "tests": ["test-apex-suite.sh --tier db", "test-apex-suite.sh --tier rest", "test-apex-suite.sh --tier e2e", "test-apex-suite.sh --tier advisor"],
            "cmd": "./tests/test-apex-suite.sh"
        },
        "browser": {
            "key": "browser",
            "category": "e2e",
            "title": "Browser & SSO End-to-End",
            "desc": "Simulates browser interactions, APEX login flows, Dev Hub shortcuts, and SSO authentication",
            "icon": "🖥️",
            "count": 2,
            "tests": ["test-browser-login.sh", "test-devhub-browser-blueprints.sh"],
            "cmd": "./tests/test-browser-login.sh"
        },
        "live": {
            "key": "live",
            "category": "e2e",
            "title": "End-to-End Live Platform",
            "desc": "Full regression against active running containers, database listeners, and web service endpoints",
            "icon": "🚀",
            "count": 1,
            "tests": ["test-live-platform.sh"],
            "cmd": "./tests/test-live-platform.sh"
        },
        "blueprints_matrix": {
            "key": "blueprints_matrix",
            "category": "e2e",
            "title": "Blueprints Matrix & Incremental Lifecycle",
            "desc": "Incremental and live test suite covering Blueprints 0 through 11 and state transitions",
            "icon": "🏗️",
            "count": 3,
            "tests": ["test-all-blueprints-live.sh", "test-all-blueprints-incremental.sh", "test-blueprints-6-11.sh"],
            "cmd": "./tests/test-all-blueprints-live.sh"
        },
        "devhub_lifecycle": {
            "key": "devhub_lifecycle",
            "category": "e2e",
            "title": "Dev-Hub Full Lifecycle (0-9)",
            "desc": "Tests the complete 3-step lifecycle (Start -> Stop -> Fast-Start) through Dev-Hub Bridge API for Blueprints 0 through 9",
            "icon": "🔄",
            "count": 2,
            "tests": ["test-devhub-lifecycle-full.sh", "test-devhub-browser-blueprints.sh"],
            "cmd": "./tests/test-devhub-lifecycle-full.sh --all --dry-run"
        },
        "containers_infra": {
            "key": "containers_infra",
            "category": "e2e",
            "title": "Container Health & Multi-DB Services",
            "desc": "Verifies active container sockets, multi-cloud topologies, and ORDS/Publisher connection pools",
            "icon": "🐳",
            "count": 4,
            "tests": ["test-containers-live.sh", "test-ords-lifecycle-matrix.sh", "test-remote-multicloud.sh", "test-tiered-lifecycle-matrix.sh"],
            "cmd": "./tests/test-containers-live.sh"
        },
        "windows_enterprise": {
            "key": "windows_enterprise",
            "category": "compliance",
            "title": "Enterprise Windows & WSL2 Diagnostics",
            "desc": "Non-destructive dry-run compatibility verification (Rule 14): WSL2 ext4, RAM, Hyper-V ports, CRLF, corporate TLS/proxy, VPN DNS",
            "icon": "🪟",
            "count": 2,
            "tests": ["test-windows-dryrun.sh", "test-windows-enterprise-rules.sh"],
            "cmd": "./tests/test-windows-dryrun.sh"
        },
        "i18n": {
            "key": "i18n",
            "category": "compliance",
            "title": "Multilingual & i18n Parity",
            "desc": "Full 6-language compliance audit (Rule 9): checks dictionary symmetry, headers, and translations",
            "icon": "🌐",
            "count": 1,
            "tests": ["test-multilingual-support.sh"],
            "cmd": "./tests/test-multilingual-support.sh --all"
        },
        "portability": {
            "key": "portability",
            "category": "compliance",
            "title": "Cross-Platform Portability",
            "desc": "Strict verification of Rule 13: Windows NTFS/FAT forbidden chars, device names, and ASCII path standards",
            "icon": "🛡️",
            "count": 1,
            "tests": ["test-filename-portability.sh"],
            "cmd": "./tests/unit/test-filename-portability.sh"
        },
        "mermaid": {
            "key": "mermaid",
            "category": "compliance",
            "title": "Mermaid & Architecture Diagrams",
            "desc": "Validates marked-to-mermaid transformation, toolbars, zoom modal, 6-language i18n, and dynamic diagram rendering",
            "icon": "📊",
            "count": 1,
            "tests": ["test-devhub-mermaid-rendering.sh"],
            "cmd": "./tests/unit/test-devhub-mermaid-rendering.sh"
        },
        "precommit": {
            "key": "precommit",
            "category": "compliance",
            "title": "Git Pre-Commit & Pre-Push Security Guard",
            "desc": "Lightning-fast 6-phase verification: Zero-Trust secrets, GDPR/PII leaks, Zero-Knowledge hashed company info, Rule 13 portability, script syntax, and CRLF line endings",
            "icon": "🛡️",
            "count": 2,
            "tests": ["check-pre-commit.sh --full", "test-pre-commit-check.sh"],
            "cmd": "./scripts/check-pre-commit.sh --full"
        },
        "glossary": {
            "key": "glossary",
            "category": "compliance",
            "title": "Architecture Glossary & Acronyms Parity",
            "desc": "Validates 6-language glossary parity, Markdown generation, and Dev Hub search registry across 50+ acronyms",
            "icon": "📖",
            "count": 1,
            "tests": ["test-glossary-parity.sh"],
            "cmd": "./tests/unit/test-glossary-parity.sh"
        },
        "tls_security": {
            "key": "tls_security",
            "category": "compliance",
            "title": "TLS & Certificate Lifecycle Safety",
            "desc": "Validates self-signed Root CA generation, OS trust store injection, and safe cert cleanups",
            "icon": "🔒",
            "count": 2,
            "tests": ["test-tls-scenarios.sh", "test-clean-certs-safety.sh"],
            "cmd": "./tests/test-tls-scenarios.sh"
        },
        "security_audit": {
            "key": "security_audit",
            "category": "compliance",
            "title": "Enterprise Security Audit (DORA / PCI-DSS / CIS)",
            "desc": "16-point automated enterprise security audit covering OWASP Top 10, CIS Oracle DB, CIS Podman, Zero-Trust secrets, DevHub bridge, and network ACLs",
            "icon": "🛡️",
            "count": 1,
            "tests": ["test-security-audit.sh"],
            "cmd": "./scripts/test-security-audit.sh"
        },
        "doc_links": {
            "key": "doc_links",
            "category": "compliance",
            "title": "Dev Hub Documentation Links & Language Switchers",
            "desc": "Universal audit of internal relative links, 6-language switcher parity, and SPA route interception to prevent 404s",
            "icon": "🔗",
            "count": 1,
            "tests": ["test-devhub-doc-links.sh"],
            "cmd": "./tests/unit/test-devhub-doc-links.sh"
        },
        "title_capitalization": {
            "key": "title_capitalization",
            "category": "compliance",
            "title": "Language Title Capitalization Rules",
            "desc": "Validates English Title Case (Rule 9 canonical) and Sentence case across ET, FI, SV, LV, LT in Dev Hub and Markdown docs",
            "icon": "🔤",
            "count": 1,
            "tests": ["test-title-capitalization-rules.sh"],
            "cmd": "./tests/unit/test-title-capitalization-rules.sh"
        },
        "ci_sim": {
            "key": "ci_sim",
            "category": "ci",
            "title": "Local GitHub Actions CI Simulator",
            "desc": "Executes or dry-runs repository CI/CD workflows offline using ephemeral containers",
            "icon": "🐙",
            "count": 1,
            "tests": ["test-local-ci.sh"],
            "cmd": "./tests/test-local-ci.sh --dry-run"
        },
        "coverage": {
            "key": "coverage",
            "category": "ci",
            "title": "Test Coverage Report Generator",
            "desc": "Analyzes test coverage of all scripts/ and scripts/internal/ files and updates markdown reports",
            "icon": "📊",
            "count": 1,
            "tests": ["generate-test-coverage-report.sh"],
            "cmd": "./tests/generate-test-coverage-report.sh"
        },
        "repo_stats": {
            "key": "repo_stats",
            "category": "ci",
            "title": "Repository Statistics & Architecture Metrics",
            "desc": "Calculates LOC breakdown, test distribution, blueprints, profiles, and 6-language i18n parity",
            "icon": "📈",
            "count": 1,
            "tests": ["report-repo-stats.sh"],
            "cmd": "./tests/report-repo-stats.sh"
        }
    }

def get_test_reports_list(ws):
    """Scans tests/reports/ and returns a structured list of test reports."""
    reports = []
    reports_dir = os.path.join(ws, "tests", "reports")
    if not os.path.isdir(reports_dir):
        return reports

    for root, dirs, files in os.walk(reports_dir):
        for f in sorted(files):
            if f.endswith(".md"):
                full_p = os.path.join(root, f)
                rel_p = os.path.relpath(full_p, ws)
                title = f
                status = "INFO"
                try:
                    with open(full_p, "r", encoding="utf-8", errors="ignore") as rf:
                        lines = [rf.readline() for _ in range(5)]
                        for ln in lines:
                            if ln.startswith("# "):
                                title = ln.replace("# ", "").strip()
                                break
                except Exception:
                    pass

                f_lower = f.lower()
                if "pass" in f_lower or "success" in f_lower or "live" in f_lower or "matrix" in f_lower:
                    status = "PASS"
                elif "fail" in f_lower or "error" in f_lower:
                    status = "FAIL"

                stat = os.stat(full_p)
                reports.append({
                    "name": f,
                    "rel_path": rel_p,
                    "title": title,
                    "status": status,
                    "size": stat.st_size,
                    "mtime": datetime.fromtimestamp(stat.st_mtime).strftime("%Y-%m-%d %H:%M:%S")
                })
    reports.sort(key=lambda x: x["mtime"], reverse=True)
    return reports

def get_test_coverage_data(ws):
    """Reads and parses tests/reports/test-coverage-report.md."""
    cov_file = os.path.join(ws, "tests", "reports", "test-coverage-report.md")
    if not os.path.isfile(cov_file):
        cov_file = os.path.join(ws, "tests", "test-coverage-report.md")

    if not os.path.isfile(cov_file):
        return {"total": 0, "covered": 0, "percent": 0, "scripts": [], "updated_at": "Never"}

    scripts = []
    total = 0
    covered = 0
    updated_at = ""

    try:
        with open(cov_file, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                if "Genereeritud:" in line:
                    updated_at = line.split("Genereeritud:")[-1].strip()
                m = re.search(r"\|\s*\*\*`([^`]+)`\*\*\s*\|\s*([^\|]+)\|\s*([^\|]+)\|", line)
                if m:
                    s_name = m.group(1).strip()
                    s_status_raw = m.group(2).strip()
                    s_tests_raw = m.group(3).strip()
                    is_cov = ("✅" in s_status_raw or "Kaetud" in s_status_raw)
                    total += 1
                    if is_cov:
                        covered += 1
                    scripts.append({
                        "name": s_name,
                        "covered": is_cov,
                        "status": "covered" if is_cov else "uncovered",
                        "tests": [t.strip() for t in s_tests_raw.split(",") if t.strip() and t.strip() != "-"]
                    })
    except Exception:
        pass

    percent = round((covered / total * 100), 1) if total > 0 else 0
    return {
        "total": total,
        "covered": covered,
        "percent": percent,
        "scripts": scripts,
        "updated_at": updated_at
    }

def get_test_execution_history(ws):
    """Loads past test executions from metrics/test_execution_history.json."""
    hist_file = os.path.join(ws, "metrics", "test_execution_history.json")
    if os.path.isfile(hist_file):
        try:
            with open(hist_file, "r", encoding="utf-8") as f:
                data = json.load(f)
                if isinstance(data, list):
                    return data
        except Exception:
            pass
    return []
