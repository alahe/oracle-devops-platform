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

---

## 7. Enterprise Document Branding & Accessibility Customization (PDF/UA-1 & WCAG 2.1 AA)

When onboarding new enterprise systems, document templates (Invoices, Receipts, Delivery Notes, Financial Statements) must adhere to corporate visual identity and mandatory accessibility laws (**European Accessibility Act / EN 301 549, US Section 508, PDF/UA-1 ISO 14289-1**). Non-compliance risks legal penalties or public procurement exclusions.

### 1. Centralized Image Repository & Logo Management (Single Source of Assets)
To avoid hardcoding machine-specific file paths (such as `C:\logo.png`) or embedding duplicate raster images into dozens of RTF templates:
1. **Host Asset Repository:** Store official high-resolution corporate vector/PNG logos in:
   ```text
   templates/publisher/common/images/company_logo.png
   ```
2. **Container Runtime Path:** The designer container automatically mounts this directory at `/u01/common/images/company_logo.png`.
3. **Dynamic Template Reference:** In Microsoft Word or LibreOffice Writer, insert a dummy placeholder image, right-click -> **Alt Text / Description / Web Tab**, and specify the dynamic Oracle XDO URL:
   ```text
   url:{concat($IMAGE_DIR, '/company_logo.png')}
   ```
   Set Alt Text to the official corporate description (e.g. `Official Company Logo`).
4. **Automated Server Synchronization:** When deploying templates to test or production Oracle Analytics Publisher instances via `./scripts/publisher/deploy-publisher-reports.sh`, all assets in `common/images/` are automatically synchronized to the target Publisher catalog server.

### 2. Accessible Starter Template (`accessible_starter_template.rtf`)
The platform includes an enterprise-grade accessible starter template at:
[`templates/publisher/samples/accessible_starter_template.rtf`](../templates/publisher/samples/accessible_starter_template.rtf)

It features:
- **`\trhdr` Table Header Row Repeat:** Guarantees screen readers announce column headers across multi-page document pagination.
- **Summary-First Financial Block:** High-contrast summary (Total Due, Due Date, IBAN) placed immediately below the title for quick accessibility.
- **Strict WCAG AA Color Contrast:** Deep enterprise blue (`#0A3663`) and dark gray (`#222222`), achieving **7.1:1 contrast ratio** against white backgrounds (surpassing the 4.5:1 statutory requirement).
- **Embedded PDF/UA-1 Structural Tags:** Fully tagged headings (`Heading 1`, `Heading 2`), tables (`/S/Table`, `/S/TR`, `/S/TH`, `/S/TD`), and document metadata.

### 3. Automated Accessibility Audit CLI & Screen Reader Simulator
Before deploying templates to testing or production environments, run automated audits:

```bash
# 1. Audit RTF Template for WCAG AA compliance & actionable fix instructions:
./scripts/publisher/validate-rtf-accessibility.sh templates/publisher/samples/accessible_starter_template.rtf

# 2. Validate rendered PDF tags and generate simulated screen reader speech:
./scripts/publisher/validate-pdf-accessibility.sh build/accessible_starter_template_en.pdf
```

### 4. Zero-Tolerance CI/CD Quality Gate
The platform runs automated document accessibility verification in continuous integration:
```bash
./tests/integration/test-publisher-accessibility-suite.sh
```
This suite compiles multi-page invoices, high-volume line item reports, and financial summaries, verifying that all output PDFs score **100% compliance** on structural tagging and metadata before deployment.
