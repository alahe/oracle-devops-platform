# Kuldsete Hetktõmmiste Katastroofitaastus — Tehniline Disain (Technical Design)

- **Domeen (SCS):** `golden-snapshots`
- **Viidatud Nõuded:** `docs/specs/golden-snapshots/requirements.md`
- **Metoodika:** Simon Martinelli (SCS Arhitektuur) & Julian Wood (SDD Disain)

---

## 1. Arhitektuuriline Ülevaade ja Piiritletud Kontekst (Bounded Context)

Kuldsete hetktõmmiste süsteem on **Self-Contained System (SCS)**, mis haldab andmebaasi füüsiliste andmeköidete varundust ja taastamist, tagades Zero-Trust turvalisuse ja tehingulise terviklikkuse.

```mermaid
flowchart TD
    subgraph Engine["⚡ Taaste ja Varundusmootor (SCS)"]
        direction TB
        CREATE["create-golden-snapshots.sh<br/>(Tehinguline arhiveerimine)"]
        RESTORE["restore-golden-snapshots.sh<br/>(FastStart taastus ~15-20s)"]
        CLEAN["clean-golden-snapshots.sh<br/>(Kettaruumi optimeerimine)"]
    end

    subgraph Storage["💾 Tõmmiste Salvestusruum (snapshots/)"]
        direction TB
        ARCH["db-oracle-golden.tar.gz<br/>(Tihendatud andmefailid)"]
        META["snapshot_meta.json<br/>(SHA-256 kontrollsumma)"]
        ARCH --- META
    end

    subgraph Runtime["🐳 Podman & Andmebaas"]
        direction TB
        VOL["oracle-data köide<br/>(/opt/oracle/oradata)"]
        SEC["SEPS Wallet volitused<br/>(Zero-Trust sünkroon)"]
        VOL --- SEC
    end

    CREATE --> Storage
    Storage --> RESTORE
    RESTORE --> Runtime
```

---

## 2. Protsessivoog ja Tehinguline Konsistents

```mermaid
sequenceDiagram
    autonumber
    participant Dev as Arendaja / CI
    participant Script as setup-all.sh (-s)
    participant Snap as restore-golden-snapshots.sh
    participant Pod as Podman Engine
    participant DB as Oracle 23ai Free

    Dev->>Script: setup-all.sh -s -y
    Script->>Snap: Käivita taastus
    Snap->>Pod: Peata db-oracle konteiner
    Snap->>Pod: Asenda oradata köide arhiiviga
    Snap->>Pod: Käivita db-oracle
    Pod->>DB: Käivitus & PDB avamine
    Script->>DB: Tervisekontroll (wait-db-healthy.sh)
    DB-->>Script: 200 OK (~18s kokku)
```

---

## 3. Zero-Trust Turvalisus ja Terviklikkus

- **Zero-Trust Wallet Sünkroonsus:** Tõmmis sisaldab andmebaasi seisu, mis vastab rangelt `wallet/` SEPS rahakotile.
- **Failisüsteemi Puhastamine:** Enne taastamist puhastatakse vanad ajutised failid ja lock-failid.
