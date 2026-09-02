[ 🇬🇧 English ](devops-lifecycle-guide.md) | [ 🇪🇪 Eesti ](et/devops-lifecycle-guide.md) | [ 🇫🇮 Suomi ](fi/devops-lifecycle-guide.md) | [ 🇸🇪 Svenska ](sv/devops-lifecycle-guide.md) | [ 🇱🇻 Latviešu ](lv/devops-lifecycle-guide.md) | [ 🇱🇹 Lietuvių ](lt/devops-lifecycle-guide.md)

# 🔄 Container Images, Golden Snapshots & Backups Lifecycle Guide

This guide explains the architectural purpose, storage locations, and execution workflows for the platform's **3-Tier Disaster Recovery & FastPath Acceleration Model**:
1. **Container Images (Images):** Base immutable OS, runtime, and software engines.
2. **Golden Snapshots (Snapshots):** Full persistent state & database volume dumps for instant ~15-second recovery.
3. **Backups (Backups):** Granular, component-specific export archives (Publisher catalog, SEPS Wallet, SQL exports).

---

## 🗺️ 1. Architecture & Decision Flow Diagram (Mermaid)

```mermaid
flowchart TD
    Start([🚀 Launch:<br/>setup-all.sh / deploy-blueprint.sh]) --> CheckLocal{1. Does local<br/>Golden Snapshot<br/>exist and match<br/>target version?}

    %% DETAILED VERSION VERIFICATION ANNOTATION
    subgraph VerifyLogic ["🔍 HOW STEP 1 VERIFIES VERSIONS (.meta.json contract)"]
        LookDisk["1. Search golden-snapshots/<br/>for bp_X_latest.tar.gz or profile_*.tar.gz"]
        ReadMeta["2. Parse companion .meta.json file<br/>(apex_version, db_image, blueprint_id)"]
        Compare["3. verify_snapshot_version_match:<br/>Compare target .env/YAML vs snapshot metadata"]
        LookDisk --> ReadMeta --> Compare
    end

    CheckLocal -.->|Inspects| VerifyLogic

    %% WARM RESTORE PATH (FASTPATH)
    CheckLocal -->|MATCH: .meta.json valid<br/>(e.g. 26.1 == 26.1)| FastPath["⚡ WARM FASTPATH RECOVERY<br/>• restore-golden-snapshots.sh (~15s)<br/>• Restores exact oradata volume state<br/>• Skips APEX/RCU re-compilation"]
    
    FastPath --> StartContainers["🚀 Start containers<br/>(start-containers.sh)<br/>Uses pre-built Images<br/>(DB 23ai, ORDS, Web IDE)"]
    
    StartContainers --> HealthCheck["🔍 Service Diagnostics<br/>• check-urls.sh (HTTP 200)<br/>• check-wallet.sh (SEPS)"]

    %% COLD BUILD & ARTIFACTORY DISCOVERY
    CheckLocal -->|MISMATCH or MISSING<br/>(e.g. Target 26.1 != Snap 24.2)| CheckArtifactory{2. Does enterprise<br/>Artifactory have<br/>matching snapshot<br/>in catalog?}
    
    CheckArtifactory -->|YES: Remote .meta.json match| DownloadArt["⬇️ Download Snapshot at LAN speed<br/>(artifactory-client.sh)"]
    DownloadArt --> FastPath

    CheckArtifactory -->|NO: Build required| ColdBuild["❄️ COLD CLEAN BUILD (FROM SCRATCH)<br/>1. Pull Image (Oracle Free 23ai)<br/>2. Download binaries/ (apex, ords)<br/>3. Start fresh empty DB container<br/>4. Compile APEX & schemas (~5-12 min)"]
    
    ColdBuild --> CreateSnap["💾 GENERATE GOLDEN SNAPSHOT<br/>• create-golden-snapshots.sh<br/>• Saves bp_X_latest.tar.gz<br/>• Writes .meta.json contract"]
    
    CreateSnap --> CheckAutoPublish{3. Publish snapshot<br/>to Artifactory?<br/>(--publish or<br/>AUTO_PUBLISH=true)}
    
    CheckAutoPublish -->|YES| PublishArt["⬆️ Publish to product catalog<br/>(publish-to-artifactory.sh)"]
    CheckAutoPublish -->|NO| HealthCheck
    PublishArt --> HealthCheck

    %% GRANULAR BACKUPS LAYER
    subgraph BackupsLayer ["💾 GRANULAR BACKUPS LAYER — Daily Developer Operations"]
        DevWork["👨‍💻 Developer builds solutions<br/>(APEX apps, Forms, Publisher reports)"]
        DevWork --> RunBackup["📦 Execute backup tool:<br/>• backup-publisher-catalog.sh<br/>• SEPS Wallet backup"]
        RunBackup --> SaveBackup["📂 Persist export to disk:<br/>backups/publisher_catalog_*.tar.gz"]
    end

    HealthCheck --> DevWork
```

---

## 📊 2. Comparative Matrix: Images vs Golden Snapshots vs Backups

| Category | 📂 Storage Location | 🎯 When is it used? | ⚙️ How is it executed? | ⏱️ Recovery Speed |
| :--- | :--- | :--- | :--- | :--- |
| **🖼️ Container Images (Images)** | `docker/`, Podman storage, Artifactory / OCR | Container container boot (Linux OS, Java JDK, ORDS binaries, WebLogic engine). | `podman run` / `podman-compose up`. Immutable layer; does not contain business database rows. | Pulled once into local cache. |
| **📸 Golden Snapshot (Snapshots)** | [`golden-snapshots/`](../golden-snapshots/) (`.tar.gz` + `.meta.json`) | **Testing, Disaster Recovery (DR), and switching between Architecture Blueprints.** | `restore-golden-snapshots.sh` decompresses the persistent block-level `oradata` volume directly to disk. Skips 15-min compilation. | **~15–25 seconds** |
| **💾 Backups (Backups)** | [`backups/`](../backups/), [`config/tns_admin/`](../config/tns_admin/) | **Exporting reports, preserving passwords, and migrating modular components.** | Granular file exports (Publisher catalog `.tar.gz`, APEX SQL split exports, encrypted SEPS Wallet `cwallet.sso`). | Seconds (small lightweight archives). |

---

## 🛠️ 3. Essential CLI Commands

```bash
# 1. Instant ~15-second restore from Golden Snapshot:
./scripts/snapshots/restore-golden-snapshots.sh -b 3

# 2. Create a new Golden Snapshot from active environment:
./scripts/snapshots/create-golden-snapshots.sh -b 3

# 3. Publish Golden Snapshot to Enterprise Artifactory:
./scripts/publish-to-artifactory.sh --product blueprints --blueprint 3

# 4. Backup Analytics Publisher catalog:
./scripts/publisher/backup-publisher-catalog.sh
```

---

## 🚀 2. FastStart Base Image & Snapshot Modes

### A. FastStart Base Image (`oracle-free-apex:23ai-apex26.1`)
- **How it works:** Once Group 1 finishes building APEX 26.1, the image is cached and reused across all database profiles (`db-alise`, `db-forms`, `db-publisher`).
- **Impact:** Reduces multi-DB cold installation from **27 minutes to ~6.5 minutes (76% speedup)**.

### B. Snapshot Modes: Base vs Release
- **`SNAPSHOT_MODE=base` (`--snapshot-mode base`):** Captures clean database + APEX engine **before** custom apps are imported. Ideal for developers needing a pristine test bench.
- **`SNAPSHOT_MODE=release` (`--snapshot-mode release`, Default):** Captures the fully deployed solution for production rollouts and instant rollback.

### C. Developer & CI/CD Acceleration Flags
- `--fast` / `--skip-tests`: Skips post-provisioning E2E diagnostics (~30–45s savings).
- `--lock-internal-apex`: Locks `APEX_PUBLIC_USER` / `APEX_LISTENER` in `db-forms` and `db-publisher` for zero-trust isolation.
- `--single-pass`: Runs single-pass cold test in CI matrix (cuts ~1.5h runtime).
- `--unified-middleware`: Runs unified Forms 14c + Publisher 2025 container (50% RAM savings).
