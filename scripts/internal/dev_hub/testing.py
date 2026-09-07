"""
Testing utilities and catalog scanners for Developer Hub (tab-testing).
"""
import os
import re
import json
from datetime import datetime

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
            "title": "Unit Test Suite",
            "desc": f"Fast isolation tests ({len(unit_tests)} scripts) validating configs, SEPS wallet, script syntax, and logic without live DB",
            "icon": "🧪",
            "count": len(unit_tests),
            "tests": unit_tests,
            "cmd": "./tests/test-all-components.sh"
        },
        "integration": {
            "key": "integration",
            "title": "Integration Test Suite",
            "desc": f"Multi-database topology ({len(integration_tests)} scripts), compose override generation, profile roles, and connection handshakes",
            "icon": "⚙️",
            "count": len(integration_tests),
            "tests": integration_tests,
            "cmd": "tests/integration/*.sh"
        },
        "live": {
            "key": "live",
            "title": "End-to-End Live Platform",
            "desc": "Full regression against active running containers, database listeners, and web service endpoints",
            "icon": "🚀",
            "count": 1,
            "tests": ["test-live-platform.sh"],
            "cmd": "./tests/test-live-platform.sh"
        },
        "i18n": {
            "key": "i18n",
            "title": "Multilingual & i18n Parity",
            "desc": "Full 6-language compliance audit (Rule 9): checks dictionary symmetry, headers, and translations",
            "icon": "🌐",
            "count": 1,
            "tests": ["test-multilingual-support.sh"],
            "cmd": "./tests/test-multilingual-support.sh --all"
        },
        "portability": {
            "key": "portability",
            "title": "Cross-Platform Portability",
            "desc": "Strict verification of Rule 13: Windows NTFS/FAT forbidden chars, device names, and ASCII path standards",
            "icon": "🛡️",
            "count": 1,
            "tests": ["test-filename-portability.sh"],
            "cmd": "./tests/unit/test-filename-portability.sh"
        },
        "browser": {
            "key": "browser",
            "title": "Browser & SSO End-to-End",
            "desc": "Simulates browser interactions, APEX login flows, Dev Hub shortcuts, and SSO authentication",
            "icon": "🖥️",
            "count": 2,
            "tests": ["test-browser-login.sh", "test-devhub-browser-blueprints.sh"],
            "cmd": "./scripts/test-browser-login.sh"
        },
        "ci_sim": {
            "key": "ci_sim",
            "title": "Local GitHub Actions CI Simulator",
            "desc": "Executes or dry-runs repository CI/CD workflows offline using ephemeral containers",
            "icon": "🐙",
            "count": 1,
            "tests": ["test-local-ci.sh"],
            "cmd": "./scripts/test-local-ci.sh --dry-run"
        },
        "coverage": {
            "key": "coverage",
            "title": "Test Coverage Report Generator",
            "desc": "Analyzes test coverage of all scripts/ and scripts/internal/ files and updates markdown reports",
            "icon": "📊",
            "count": 1,
            "tests": ["generate-test-coverage-report.sh"],
            "cmd": "./tests/generate-test-coverage-report.sh"
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
