[ 🇬🇧 English ](getting-started-from-scratch.md) | [ 🇪🇪 Eesti ](et/getting-started-from-scratch.md)

# 🚀 Zero-to-Hero Quickstart: Setting Up From Scratch

This guide walks you through setting up the **Oracle DevOps Platform** from absolute zero on a brand new development workstation (macOS, Windows 11 WSL2, or Linux).

> [!TIP]
> **Already running Dev Hub?** If you are viewing this inside your running Developer Hub browser, your system is already configured! You do not need to repeat these steps on this machine. This guide is specifically written for provisioning new machines, onboarding team members, or setting up a clean CI/CD runner.

---

## 📋 Minimum Requirements

| Component | Minimum | Recommended | Notes |
| :--- | :--- | :--- | :--- |
| **RAM** | 8 GB | 16 GB+ | Oracle DB Free requires ~2 GB; additional stacks (APEX, ORDS, Forms, Publisher) require 1–3 GB each. |
| **Disk Space** | 20 GB free | 50 GB free | Container images and database volumes. |
| **Container Engine** | Podman 4.5+ or Docker 24+ | Rootless Podman 5.x | Default configuration runs rootless Podman. |
| **Terminal / Shell** | Bash 4.x / Zsh | Zsh / Bash | Git Bash or native WSL2 Linux terminal on Windows. |
| **VS Code** | Latest | Latest + Extensions | Oracle SQL Developer extension recommended. |

---

## 💻 Step-by-Step Installation (Zero-to-Hero)

### Step 1: Clone the Repository

Clone the project repository to your local machine:

```bash
git clone https://github.com/alahe/oracle-devops-platform.git
cd oracle-devops-platform
```

> [!WARNING]
> **Windows Users (WSL2 Mandatory):** Always clone and execute inside the native WSL2 Linux filesystem (`~/oracle-devops-platform`), **NEVER** under the Windows host mount (`/mnt/c/...`). Running under `/mnt/c/` causes extreme 9P filesystem slowdowns and permission failures on Oracle SEPS Wallets.

---

### Step 2: Open in VS Code

Open the project in your code editor:

```bash
code .
```

Open the integrated terminal in VS Code:
- **Windows / Linux:** `Ctrl + \``
- **macOS:** `Cmd + \``

---

### Step 3: Run Pre-Flight Diagnostics

Verify your container runtime, available RAM, and required network ports:

```bash
# On macOS or Linux:
./scripts/check-prerequisites.sh

# On Windows (via PowerShell or Command Prompt):
.\setup.cmd --check
```

The pre-flight engine verifies:
- Container daemon availability (`podman` or `docker`)
- Host RAM and CPU cores
- Port availability for database (1531–1537) and web services (8448, 8088, 9502, 6083)
- Hyper-V port exclusion conflicts (on Windows)

---

### Step 4: Execute the Automated Setup

Run the automated orchestrator to pull images, configure Oracle 23ai DB Free, generate auto-login SEPS Wallets, and deploy ORDS / APEX:

```bash
# Automated non-interactive installation (Blueprint 1: Database + APEX + ORDS):
./scripts/setup-all.sh -y
```

> [!NOTE]
> **Duration:** Fresh cold installation typically takes 10–14 minutes (pulling container images, initial PDB creation, APEX schema compilation, and SEPS Wallet encryption). Subsequent restarts take under 15 seconds.

---

### Step 5: Trust the Local SSL Certificate

To enable secure HTTPS (`https://localhost:8448`) without browser security warnings, register the generated local CA into your operating system trust store:

```bash
# macOS:
./scripts/certs/trust-local-cert-mac.sh

# Windows (Zero-Admin / No-UAC required):
.\scripts\certs\trust-local-cert.cmd

# Linux:
sudo cp config/certs/ca.crt /usr/local/share/ca-certificates/oracle-local-ca.crt && sudo update-ca-certificates
```

---

### Step 6: Launch Developer Hub & Connect

Once setup completes, open Developer Hub in your browser:

```bash
# macOS:
open ./docs/dev-hub.html

# Linux:
xdg-open ./docs/dev-hub.html

# Windows:
start ./docs/dev-hub.html
```

Or connect directly via HTTPS:
- **Developer Hub Web UI:** [https://localhost:8448/dev-hub](https://localhost:8448/dev-hub)
- **APEX Workspace:** [https://localhost:8448/ords/r/oracle/workspace](https://localhost:8448/ords/r/oracle/workspace)
- **Database Actions:** [https://localhost:8448/ords/sql-developer](https://localhost:8448/ords/sql-developer)

---

## 🔑 Passwordless CLI & SQLcl Connections

Platform uses **Oracle SEPS (Secure External Password Store)** auto-login wallets. You never type plaintext passwords:

```bash
# Connect as Developer into Pluggable Database (PDB):
./scripts/sqlcl.sh /@DB_PROXY_DEV

# Connect as Instance Admin:
./scripts/sqlcl.sh /@DB_PROXY_ADMIN

# Retrieve any credential dynamically from encrypted wallet in-memory:
./scripts/get-password.sh DB_PROXY_DEV
```

---

## 🔄 Managing Multi-Database Stacks

The platform supports running **1, 2, or 3 database stacks concurrently**:
- Starting a secondary stack (e.g. Blueprint 3 LIS Database or Blueprint 4 Analytics Publisher) **does not tear down your existing database**.
- The system automatically checks free host RAM before launching additional services to prevent out-of-memory container crashes.
- Open **Juhtpaneel (Cockpit)** in Developer Hub to manage individual stacks, trigger instant Golden Snapshot recovery, or perform clean restarts.

---

## ❓ Frequently Asked Questions & Official Downloads

- Have questions about RAM limits, port conflicts, SSL warnings, or Golden Snapshot recovery? See [Platform Frequently Asked Questions (FAQ)](faq.md).
- Need official Oracle container images, product downloads, or documentation portals? See [Official Oracle Resources & Container Images](oracle-resources-and-downloads.md).

