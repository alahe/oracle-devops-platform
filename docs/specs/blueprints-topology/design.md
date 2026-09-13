# Blueprints & Dynamic Port Topology — Technical Design & Architecture

- **Domain (SCS):** `blueprints-topology`
- **Referenced Requirements:** `docs/specs/blueprints-topology/requirements.md`
- **Methodology:** Simon Martinelli (SCS Architecture) & Julian Wood (SDD Design)

---

## 1. Architectural Overview & Bounded Context

The Blueprint and Topology system is an autonomous **Self-Contained System (SCS)** that governs declarative stack models and host port allocation while enforcing Zero-Trust service isolation.

```mermaid
flowchart TD
    subgraph BP["📋 Blueprints (config/blueprints/)"]
        direction TB
        CORE["Core Base (BP 0–4)<br/>(DB, APEX, ORDS)"]
        SPEC["Specialized (BP 5–7)<br/>(Forms, Publisher)"]
        DEV["Developer (BP 8–11)<br/>(Web-IDE, Designer)"]
    end

    subgraph Topo["⚙️ Topology Engine (SCS)"]
        direction TB
        RESOLVE["resolve-topology.sh<br/>(Port check & allocation)"]
        OVERRIDE["generate-compose-override.sh<br/>(YAML compilation)"]
        RESOLVE --> OVERRIDE
    end

    subgraph Runtime["🐳 Runtime Environment"]
        direction TB
        PODMAN["Podman Compose<br/>(Conflict-free launch)"]
        WAL["Zero-Trust Wallet<br/>(Synced Ports)"]
        PODMAN --- WAL
    end

    BP --> Topo
    Topo --> Runtime
```

---

## 2. Port Topology Matrix

| Service | Default Host Port | Container Port | Profile |
| :--- | :--- | :--- | :--- |
| **Oracle 23ai Free DB** | `1521` | `1521` | `db-oracle-free` |
| **ORDS Smart Gateway** | `8088` (HTTP) / `8448` (HTTPS) | `8080` / `8443` | `ords-standard` |
| **Analytics Publisher** | `9704` | `9704` | `publisher-standard` |
| **Oracle Forms 14c** | `9001` (WLS) / `6080` (noVNC) | `9001` / `6080` | `forms-standard` |
| **Web-IDE (VS Code)** | `8444` | `8443` | `web-ide-standard` |

---

## 3. Zero-Trust Architecture & Core Base Protection

- **Core Base Protection:** Switching blueprints leaves core database volumes and credentials fully intact.
- **Port Isolation:** Endpoints prefer encrypted transports (HTTPS/TLS) across development and production profiles.
