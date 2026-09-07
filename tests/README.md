[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🧪 Automated Testing & Blueprints Verification Suite (`tests/`)

This directory houses the end-to-end testing infrastructure, automated benchmark reports, and blueprint verification suites for the Oracle DevOps Platform.

All 12 canonical architecture blueprints are defined centrally in **[`config/blueprints/`](../config/blueprints/)**.

---

## 📁 Directory Structure

- **`config/blueprints/`** ➔ 12 canonical architecture blueprints (`.env.0-*` through `.env.11-*`).
- **`tests/reports/`** ➔ Architecture test reports and benchmark matrix ([`blueprint_benchmark_matrix.md`](reports/blueprint_benchmark_matrix.md)).
- **`tests/reports/blueprints/`** ➔ Automatically generated test reports (`blueprint_0_report.md` through `blueprint_11_report.md`).
- **`tests/unit/`
  - **`tests/unit/test-glossary-links.sh` / `.cmd`** ➔ Zero-download audit of all 57 external glossary and Wikipedia links (in-memory HTTP HEAD, virtual null device NUL / /dev/null).** ➔ Modular unit test scripts verifying CLI stability contracts, DevHub generators, and credential safety.

---

## 🚀 CLI Test Execution

To run automated blueprint tests from a clean baseline (with automatic `reset-all.sh -y`):

```bash
# 1. Test single blueprint from scratch:
./scripts/setup-all.sh -tb 3

# 2. Test specific list of blueprints:
./scripts/setup-all.sh -tb 1,5,8,10

# 3. Test ALL 12 blueprints sequentially:
./scripts/setup-all.sh -tb all

# 4. Multi-Language & i18n Verification:
./tests/test-multilingual-support.sh --all

# 5. Remote Multi-Cloud Test Suite:
./tests/test-remote-multicloud.sh --dry-run
```

---

## 🔍 Validation Invariants

Every automated test run validates:
1. **🌐 Web Endpoints HTTP Health (`scripts/check-urls.sh`):** Real HTTP/HTTPS requests verifying status 200/302.
2. **🔑 SEPS Wallet Passwordless Connectivity (`scripts/check-wallet.sh`):** Passwordless SQLcl connection checks (`SELECT status FROM v$instance`).
3. **📊 Resource & Duration Benchmarks (Rule 1):** Measurement of step durations saved in `metrics/setup_benchmarks.json`.
