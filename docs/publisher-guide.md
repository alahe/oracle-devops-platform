# Oracle Analytics Publisher (Pixel Perfect) Integration Guide

This guide describes how to configure, build, run, patch, and manage **Oracle Analytics Publisher (Pixel Perfect / BI Publisher)** locally with Podman or on Linux servers natively without Podman.

---

## 1. Quick Architecture & Execution Modes

Oracle Analytics Publisher supports two execution engines:
1. **Container Mode (Podman / Docker)**: For local development and containerized production environments (`oracle-publisher-dev`, ports `9502:9502` / `9503:9503`).
2. **Native Linux Server Mode (Non-Containerized VM)**: Silent response-file installer (`./scripts/install-publisher.sh`) for enterprise RHEL/Oracle Linux VMs.

---

## 2. Profile Configuration

Publisher profiles are defined in `config/profiles/databases/publisher-free.yaml` and `config/profiles/databases/appinfra.yaml`:

```yaml
profile:
  id: publisher-free
  name: publisher-free
  description: "Dedicated Oracle Database & Analytics Publisher with RCU schemas and ORDS REST management."

components:
  ords:
    enabled: true
    container_name: oracle-ords-publisher
    http_port: 8089
    https_port: 8449
  publisher:
    enabled: true
    container_name: oracle-publisher-dev
    http_port: 9502
    https_port: 9503
    rcu_prefix: OAS
    domain_name: bi
```

---

## 3. Building the Container Image

Build the container image using the imported Oracle build templates:

```bash
./docker/publisher/build-publisher-image.sh 2025
```

---

## 4. Automated RCU & ORDS Integration

During environment setup, the RCU schemas (`OAS_STB`, `OAS_CONFIG`, etc.) are automatically provisioned in `db-publisher` (port `1533`), and ORDS is enabled on port `8089/8449` providing SQL Developer Web (`_sdw`) for direct browser administration.

---

## 5. Automated Patching

Place Oracle OPatch ZIP files (e.g., `p39179920_publisher.zip`) into the `patches/` directory and execute:

```bash
./scripts/apply-publisher-patch.sh
```

Execution output is logged to `install_logs/publisher_patch_YYYYMMDD_HHMMSS.log` and duration metrics are recorded in `metrics/setup_benchmarks.json`.

---

## 6. Useful Resources & Video Tutorials

- 🎥 **YouTube Tutorial:** [Developer Coaching - Pixel-Perfect Printing in Oracle APEX with Analytics Publisher](https://www.youtube.com/watch?v=EyJ_fjzFy3s&t=28s)
- 📖 **Official REST API Endpoints:** [Oracle Analytics Server REST API Documentation](https://docs.oracle.com/en/middleware/bi/analytics-server/oap_rest_api/rest-endpoints.html)
- 📘 **Official Report Design Guide:** [Create Pixel-Perfect Reports in Oracle Analytics Server](https://docs.oracle.com/en/middleware/bi/analytics-server/create-pixel-perfect-reports.html)
- 💻 **Desktop Tools Download Guide (Word/Excel Template Builders):** [Download Desktop Tools for Publisher](https://docs.oracle.com/en/middleware/bi/analytics-server/user-publisher-oas/download-desktop-tools.html)
- 📄 **Custom Skill Instructions:** [.agents/skills/oracle_publisher/SKILL.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/.agents/skills/oracle_publisher/SKILL.md)
