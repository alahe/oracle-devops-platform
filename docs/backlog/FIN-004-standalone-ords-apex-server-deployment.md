# Jira Story: FIN-004 — Standalone ORDS + APEX App Server Deployment

| Field | Value |
|:---|:---|
| **Story ID** | FIN-004 |
| **Epic** | Application Tier Provisioning & Web Routing |
| **Component** | Oracle REST Data Services (ORDS) / Podman / TLS |
| **Priority** | Blocker |
| **Estimation** | **8 Story Points** |
| **Target Environments** | DEV, TEST, PROD |
| **Dependencies** | FIN-001, FIN-002 |

---

## 1. User Story
**As a** Network Security Engineer & Infrastructure Specialist,  
**I want to** deploy a standalone, stateless ORDS container on Server 1 with APEX static images, TLS 1.3 encryption on port 8448, and connection pools routing to the remote Proxy DB,  
**So that** all external web traffic is terminated in the application DMZ on Server 1 without allowing direct client traffic into the database networks.

---

## 2. Business Value & Financial Compliance
- **PCI-DSS 1.3 & Network DMZ Segmentation:** Enforces network boundary separation. Web clients only communicate with Server 1 (ORDS). Database servers (Host 3 and Host 4) remain in private, firewalled database zones.
- **Stateless Horizontal Scaling:** Server 1 can be scaled horizontally or replaced instantly behind the load balancer since it holds no persistent transactional state.

---

## 3. Technical Scope & Architecture

### Files Created / Modified:
1. `config/profiles/ords/ords-standalone-remote.yaml`: Dedicated standalone ORDS profile.
2. `docker-compose.ords-remote.yml`: Compose definition deploying only ORDS on Server 1.
3. `/etc/ords/config/global/settings.xml`: Standalone TLS and doc root configuration.
4. `/etc/ords/config/databases/proxy/pool.xml`: Connection pool pointing to Server 3 (`DB_PROXY_REMOTE`).
5. `scripts/deploy-remote.sh`: Adds support for `--tier ords`.

### Standalone ORDS Profile (`config/profiles/ords/ords-standalone-remote.yaml`):
```yaml
name: ords-standalone-remote
description: "Standalone Enterprise ORDS Server on Host 1"
container_name: app-ords
https_port: 8448
http_port: 8088
memory_limit: 2048m
apex_images_path: /opt/oracle/apex/images
remote_proxy_db_tns: DB_PROXY_REMOTE
```

---

## 4. Definition of Done (DoD)
- [ ] Container `app-ords` successfully running under Podman rootless on Server 1.
- [ ] TLS certificate verified on port 8448 (`curl -k -I https://localhost:8448/ords/`).
- [ ] APEX static images `/i/` serving CSS and JavaScript assets with HTTP 200 / HTTP 304.
- [ ] Connection pool `proxy` connects to Server 3 via SEPS Wallet without plaintext passwords.
- [ ] Health check endpoint `/ords/r/proxy/devhub/home` responds with HTTP 200 / 302 redirect.

---

## 5. Acceptance Criteria & Verification
```bash
# Provision standalone remote ORDS server:
./scripts/deploy-remote.sh --env-file config/environments/dev.env --tier ords

# Verify web endpoint from client network:
curl -k -s -I "https://ords-dev.corp.bank:8448/ords/r/proxy/devhub/home" | grep -E "HTTP/|location"

# Expected Output:
# HTTP/1.1 302 Found
# location: f?p=101:LOGIN:...
```
