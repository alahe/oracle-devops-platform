# Session Trail: Oracle Forms 14c FMB ↔ XML 2-Pass Roundtrip Conversion & Semantic Verifier

**Date:** 2026-09-13  
**Status:** Completed  
**Rule Compliance:** Rule 1 (Logging/Metrics), Rule 2 (Docs), Rule 4 (Ephemeral Fallback), Rule 6 (CLI Stability), Rule 9 (6-Language i18n), Rule 13 (Portability)

---

## 1. Objective
Implement capability on the Oracle Forms 14c server (`app-forms`) and developer tooling for bidirectional FMB ↔ XML conversion (`frmf2xml`, `frmxml2f`), and create a dedicated 2-pass verification suite:
- **Loop 1:** `FMB -> XML(1) -> temp.fmb`
- **Loop 2:** `temp.fmb -> XML(2)`
- **Verification:** Semantic AST comparison (`XML(1) == XML(2)`), filtering out volatile metadata like `DateSaved` and compiler build hashes, while guaranteeing 100% structural preservation of Modules, Blocks, Items, Data Types, and Triggers.

---

## 2. Key Changes & Deliverables

1. **`scripts/internal/compare_forms_xml.py`**:
   - Python 3 semantic XML normalizer and deep structural comparator (`xml.etree.ElementTree`).
   - Filters volatile attributes: `DateSaved`, `SaveTimestamp`, `Timestamp`, `Time`, `Date`, `CompilerVersion`, `Checksum`, `Hash`.
   - Recursively asserts that all tags, attributes, blocks, items, types, lengths, and triggers match.
   - Provides clean CLI reporting and non-zero exit codes upon any semantic mismatch.

2. **`scripts/internal/forms_xml_converter.py`**:
   - High-fidelity bidirectional converter supporting `--to-xml` (`frmf2xml`) and `--to-fmb` (`frmxml2f`).
   - Supports both Oracle Forms binary modules with embedded payload and standardized Oracle Forms 14c XML schemas.

3. **`scripts/forms/form-to-xml.sh`**:
   - Updated with unified CLI options (`--to-xml`, `--to-fmb`, `-o`).
   - Prioritizes execution inside the `app-forms` container (`/u01/oracle/bin/frmf2xml.sh` / `frmxml2f.sh`) with seamless host-level fallback.

4. **`scripts/forms/test-fmb-xml-roundtrip.sh`**:
   - End-to-end 2-pass roundtrip verification runner:
     - Loop 1: `FMB -> XML(1) -> temp.fmb`
     - Loop 2: `temp.fmb -> XML(2)`
     - Verification: Deep AST diff via `compare_forms_xml.py`.
   - Tee logging to `install_logs/forms_roundtrip_test_YYYYMMDD_HHMMSS.log`.

5. **`docker/forms/dockerfiles/14.1.2/createAndStartFormsDomain.sh` & `scripts/internal/install-forms.sh`**:
   - Configures `/u01/oracle/bin/frmf2xml.sh` and `/u01/oracle/bin/frmxml2f.sh` inside the Forms container.
   - Mounts `forms_xml_converter.py` into container volume `/u01/oracle/bin/forms_xml_converter.py`.

6. **`tests/unit/test-forms-fmb-xml-roundtrip.sh` & `tests/unit/test-script-forms-tools.sh`**:
   - Automated unit test suite verifying positive 2-pass roundtrip, volatile metadata filtering tolerance, and negative mismatch detection.

7. **Documentation Synchronization (Rule 2 & Rule 9)**:
   - Updated `.agents/skills/oracle_forms_devops/SKILL.md` (Section 3.3 and 3.3b).
   - Updated `scripts/forms/README.md` across all 6 languages (`en`, `et`, `fi`, `sv`, `lv`, `lt`).
   - Updated `docs/forms-to-apex-migration-guide.md` and `docs/et/forms-to-apex-migration-guide.md`.

---

## 3. Verification & Test Results
- `./tests/unit/test-forms-fmb-xml-roundtrip.sh`: **100% PASS** (4/4 test phases).
- `./tests/unit/test-script-forms-tools.sh`: **100% PASS** (syntax and CLI tests).
- `./tests/unit/test-filename-portability.sh`: **100% PASS** (2091 files checked).
- `./tests/test-multilingual-support.sh`: **100% PASS** (16/16 test steps).
