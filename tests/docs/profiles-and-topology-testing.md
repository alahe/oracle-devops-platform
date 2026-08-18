# Database Profiles & Topology Automated Testing Guide

This document describes how to execute automated and manual test scenarios for the **Dynamic YAML Database Profile Engine** (`config/profiles/*.yaml`) and **Topology Manager** (`config/topology.yaml` / `resolve-topology.sh`).

---

## 🚀 Quick Execution: Automated Test Suite

To run all profile, Artifactory override, and topology tests automatically:

```bash
./tests/test-db-profiles-and-topology.sh
```

### Expected Output:
```text
==================================================================
🧪 DÜNAAMILISTE PROFIILIDE JA TOPOLOOGIA MÕÕTMETE TESTIMINE
==================================================================

[Test 1] Laen ADB profiili (proxy-adb-oracle)...
✅ Test 1 Edukas: ADB profiil laeti korrektselt (IS_ADB=true)!

[Test 2] Laen Gvenzl profiili (proxy-standard-gvenzl)...
✅ Test 2 Edukas: Gvenzl profiil laeti korrektselt!

[Test 3] Testin Artifactory sise-registri globaalset ülekirjutust...
✅ Test 3 Edukas: Artifactory globaalne register rakendus automaatselt (artifactory.minufirma.ee/database/adb-free:latest)!

[Test 4] Käivitan topoloogia ja portide konflikti lahendaja...
✅ Test 4 Edukas: Topoloogia pordid lahendati ilma konfliktideta (DB: 1532, HTTPS: 8444)!

==================================================================
🎉 KÕIK PROFIILIDE JA TOPOLOOGIA TESTID LÄBITUD EDUKALT!
==================================================================
```

---

## 🔍 Individual Test Scenarios

### Test Scenario 1: Loading Profiles Interactively
```bash
./scripts/internal/load-db-profile.sh proxy-adb-oracle
./scripts/internal/load-db-profile.sh proxy-standard-gvenzl
./scripts/internal/load-db-profile.sh bizapp-standard-oracle
```

### Test Scenario 2: Testing Enterprise Artifactory Mirror Overrides
```bash
export ARTIFACTORY_DOCKER_REGISTRY=artifactory.company.local
./scripts/internal/load-db-profile.sh proxy-adb-oracle
unset ARTIFACTORY_DOCKER_REGISTRY
```

### Test Scenario 3: Testing Topology & Port Collision Resolver
```bash
./scripts/internal/resolve-topology.sh
```

### Test Scenario 4: Registering VS Code Connection Profiles
```bash
./scripts/internal/register-connections-sqlcl.sh
cat ~/.sqldev/connections.json
```
