# Enterprise Onboarding & Mirror Configuration Guide

[ 🇬🇧 English ](enterprise-onboarding-guide.md) | [ 🇪🇪 Eesti ](et/enterprise-onboarding-guide.md) | [ 🇫🇮 Suomi ](fi/enterprise-onboarding-guide.md) | [ 🇸🇪 Svenska ](sv/enterprise-onboarding-guide.md) | [ 🇱🇻 Latviešu ](lv/enterprise-onboarding-guide.md) | [ 🇱🇹 Lietuvių ](lt/enterprise-onboarding-guide.md)

---

## 1. Overview & Architecture Purpose

In enterprise IT environments, developer workstations and production servers often operate within restricted corporate networks without direct internet access to public container registries (`container-registry.oracle.com`, `docker.io`, `ghcr.io`). Instead, corporate policies mandate pulling container images and binaries through **internal artifact repositories** (JFrog Artifactory, Harbor, Sonatype Nexus), routing outbound traffic through TLS-inspecting proxies (Zscaler, Netskope), and trusting corporate internal Certificate Authorities (Root CAs).

This guide explains how to:
1. Define corporate infrastructure parameters in [`config/enterprise.yaml`](../config/enterprise.yaml).
2. Use the onboarding CLI tool [`scripts/onboard-enterprise.sh`](../scripts/onboard-enterprise.sh).
3. Explicitly patch all YAML profiles on disk with `--patch-profiles`.
4. Revert profiles back to upstream public registries anytime with `--revert`.
5. Configure corporate proxies, CA certificates, and internal domain names.

---

## 2. Enterprise Single Source of Truth (`config/enterprise.yaml`)

The platform provides a centralized configuration template at [`config/enterprise.yaml.example`](../config/enterprise.yaml.example). To activate it:

```bash
cp config/enterprise.yaml.example config/enterprise.yaml
```

### Configuration Sections

```yaml
enterprise:
  name: "Corporate Enterprise"
  environment: "production" # development | test | staging | production

# 1. Internal Container Registry & Artifactory Mirror
registry:
  base_url: "artifactory.corp.internal/docker-mirror"
  auth_mode: "anonymous" # anonymous | podman_secret | token
  mappings:
    "container-registry.oracle.com/database/free": "artifactory.corp.internal/docker-mirror/oracle/database/free"
    "container-registry.oracle.com/database/ords": "artifactory.corp.internal/docker-mirror/oracle/database/ords"
    "container-registry.oracle.com/database/sqlcl": "artifactory.corp.internal/docker-mirror/oracle/database/sqlcl"
    "docker.io/library/ubuntu": "artifactory.corp.internal/docker-mirror/dockerhub/library/ubuntu"
    "ghcr.io": "artifactory.corp.internal/docker-mirror/ghcr"

# 2. Corporate Proxy & CA Trust
network:
  http_proxy: "http://proxy.corp.internal:8080"
  https_proxy: "http://proxy.corp.internal:8080"
  no_proxy: "localhost,127.0.0.1,*.corp.internal,.local,podman-machine-default"
  corporate_ca_bundle_path: "/etc/pki/ca-trust/source/anchors/corp-root-ca.crt"

# 3. Enterprise Domain & TLS
domain:
  internal_domain: "corp.internal"
  custom_tls_cert: ""
  custom_tls_key: ""

# 4. Security & Audit Policy
security:
  enforce_seps_wallet: true
  mask_tokens_in_logs: true
  audit_level: "strict"
```

---

## 3. Explicit Profile Patching on Disk

To maintain 100% transparency and avoid hidden runtime transformations, the onboarding tool directly updates `container_image:` declarations in all YAML profiles under `config/profiles/**/*.yaml`:

```bash
# 1. Patch all YAML profiles to use Artifactory mirrors:
./scripts/onboard-enterprise.sh --patch-profiles

# 2. Inspect current profile status:
./scripts/onboard-enterprise.sh --status
```

### Instant Rollback / Revert

If you need to switch back to official upstream registries (e.g. for testing outside the corporate network or comparing against baseline images):

```bash
./scripts/onboard-enterprise.sh --revert
```

The script automatically restores files from `.bak` snapshots or reverses URL mappings.

---

## 4. Interactive Onboarding Wizard

Developers new to the repository can run the interactive onboarding wizard:

```bash
./scripts/onboard-enterprise.sh --interactive
```

The wizard prompts for:
- Corporate organization name
- Artifactory registry base URL
- HTTP/HTTPS proxy endpoint (if applicable)
- Corporate Root CA path
It writes `config/enterprise.yaml` and offers immediate profile patching.

---

## 5. Network Connectivity & Health Validation

Verify that your workstation can successfully communicate with the enterprise registry and proxy:

```bash
./scripts/onboard-enterprise.sh --validate
```

Output:
```text
==================================================================
🌐 Validating Enterprise Endpoints & Network
==================================================================
1. Checking Enterprise Registry: artifactory.corp.internal/docker-mirror
   ├─ Corporate CA loaded from: /etc/ssl/certs/corp-ca.pem
   └─ ✅ Registry endpoint reachable & active (HTTP 401 auth response)

2. Checking Corporate CA Bundle:
   └─ ✅ CA bundle exists on disk: /etc/ssl/certs/corp-ca.pem
```

---

## 6. Developer Hub Integration

Enterprise status, clipboard commands, and onboarding workflows are fully integrated into Developer Hub ([`docs/dev-hub.html`](dev-hub.html)):
- Navigate to the **DevOps & Quick Commands** tab.
- Click **Enterprise Artifactory & Onboarding** to copy ready-to-run terminal commands or trigger health diagnostics.
