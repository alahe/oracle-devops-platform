---
name: windows_enterprise_devops
description: Guidelines and enforcement standards for enterprise Windows workstations, WSL2 virtualization, zero-admin environments, corporate proxies, VPN DNS tunneling, and antivirus optimizations.
---

# Enterprise Windows & WSL2 Compatibility Engine

This skill guides engineering and automation practices to guarantee that the Oracle DevOps Platform runs flawlessly on **corporate-managed Windows workstations** (Enterprise / Pro, Intune/GPO managed, zero-local-admin environments) without performance degradation, network dropouts, or permission conflicts.

---

## 1. The 8 Enterprise Windows Compatibility Contracts

Every AI agent modifying code, creating scripts, or designing deployment plans must strictly adhere to these **8 mandatory contracts**:

### Contract 1: Native WSL2 Filesystem Invariant (Strict Prohibition of `/mnt/c/` Execution)
- **Problem:** When repository code resides on the Windows NTFS filesystem and is accessed from WSL2 via the Plan9 (9P) mount (`/mnt/c/...`), filesystem I/O is **10x–50x slower** than native Linux ext4. Operations involving thousands of files (APEX unpack, ORDS build, WebLogic domain generation) can take 45–90 minutes or stall completely.
- **Enforcement:**
  - The repository **MUST ALWAYS be cloned and executed inside the native WSL2 Linux filesystem** (e.g. `/home/<username>/oracle-free-db-in-prod` or `~/oracle-free-db-in-prod`).
  - Windows file explorer access to the project should be done via `\\wsl$\<distro>\home\<username>\...`.
  - All pre-flight checks (`check-prerequisites.sh`) and launcher scripts (`setup.cmd`) must detect if `$WORKSPACE_DIR` starts with `/mnt/` and issue a prominent warning advising the developer to migrate to native ext4.

### Contract 2: LF Line Ending Invariant & `.gitattributes` Protection
- **Problem:** Windows Git checkouts default to `core.autocrlf = true`, converting `\n` to `\r\n` (CRLF). When shell scripts containing CRLF are executed in WSL2 or containers, Bash fails with `/bin/bash^M: bad interpreter`.
- **Enforcement:**
  - Repositories must enforce `eol=lf` via root `.gitattributes` for all `.sh`, `.sql`, `.yaml`, `.json`, `.md`, and `.apx` files.
  - Windows scripts (`.cmd`, `.bat`, `.ps1`) are explicitly set to `eol=crlf`.
  - AI agents must never introduce CRLF line endings into shell scripts or Linux configs.

### Contract 3: Zero-Admin (0-Root / No-UAC) Workstation Standard
- **Problem:** Enterprise developers do not have local Administrator rights (`runas administrator` or UAC prompts fail).
- **Enforcement:**
  - Windows scripts (`setup.cmd`, `setup.ps1`, `trust-local-cert.cmd`) must execute in standard user space without requiring elevation.
  - SSL certificates must be registered into the Current User store (`certutil -user -addstore Root "%CERT_FILE%"`), which succeeds with zero admin privileges.
  - Container runtimes must run in rootless user space (Podman).

### Contract 4: Corporate Proxy & MITM TLS Inspection Resilience
- **Problem:** Enterprise proxies (Zscaler, Netskope, Palo Alto, Blue Coat) intercept outbound TLS traffic, causing `x509: certificate signed by unknown authority` errors during `podman pull`, `curl`, and Artifactory operations.
- **Enforcement:**
  - Automation scripts must detect and honor standard proxy environment variables (`HTTP_PROXY`, `HTTPS_PROXY`, `NO_PROXY`, `http_proxy`, `https_proxy`, `no_proxy`).
  - Corporate Root CA certificates exported from the Windows Certificate Store must be injected into WSL2 (`/usr/local/share/ca-certificates/`) and Podman container storage.
  - Download utilities in scripts must provide fallback parameters (`--insecure` / `-k`) when corporate MITM proxies break public CDN handshakes.

### Contract 5: VPN DNS Tunneling & Mirrored Networking
- **Problem:** Corporate VPN clients (Cisco AnyConnect, GlobalProtect, Fortinet) frequently break DNS forwarding on the default WSL2 virtual NAT switch, cutting off internet inside WSL2 upon VPN connection.
- **Enforcement:**
  - On Windows 11 (Build 22H2+), recommend and automate configuring `%USERPROFILE%\.wslconfig` with:
    ```ini
    [wsl2]
    networkingMode=mirrored
    dnsTunneling=true
    autoProxy=true
    ```
  - On Windows 10, provide fallback `/etc/resolv.conf` stabilization guidance.

### Contract 6: Hyper-V Dynamic Port Reservation Conflict Prevention
- **Problem:** Windows Hyper-V dynamic port exclusions (`netsh interface ipv4 show excludedportrange protocol=tcp`) randomly reserve ephemeral port ranges. If platform ports (1531–1537, 8088, 8448, 9502, 6083) fall inside these ranges, container port binding fails with permission errors.
- **Enforcement:**
  - `check-prerequisites.sh` and launcher utilities must inspect Windows excluded port ranges and warn developers before starting containers.

### Contract 7: Memory Sizing & WSL2 Resource Allocation
- **Problem:** Default `podman machine init` assigns only 2048 MB RAM, which causes Oracle Database 23ai Free to crash with Out-Of-Memory (OOM, exit code 137).
- **Enforcement:**
  - Hardware minimum: **16 GB Host RAM** (WSL2 allocated: 6–8 GB) for Core Blueprints (BP 0–4).
  - Recommended: **32 GB Host RAM** (WSL2 allocated: 12–16 GB) for Heavy FMW / Publisher / Forms Blueprints (BP 5–8).
  - Pre-flight checks must enforce a minimum of 4096 MB free memory inside the container VM.

### Contract 8: Antivirus / Endpoint Detection (Defender / CrowdStrike) Optimization
- **Problem:** Real-time scanning of large uncompressed archives (APEX with 50,000+ files, ORDS, WebLogic) severely degrades disk I/O.
- **Enforcement:**
  - Enforce Rule 4 (In-Container Unzip & Execution): large archives must never be unpacked onto the host disk.
  - Recommend adding process/folder exclusions in Microsoft Defender for the WSL2 virtual disk (`ext4.vhdx`).

---

## 2. Windows-Specific Scripts & Directory Standards

Platform scripts for Windows integration reside in canonical locations:

| Path | Purpose | Execution Context |
| :--- | :--- | :--- |
| `test-windows-dryrun.cmd` | Root 1-click Windows dry-run diagnostic launcher | Windows CMD / Explorer (delegates to WSL2) |
| `scripts/test-windows-dryrun.sh` | 10-step non-destructive dry-run compatibility engine | Bash / WSL2 / Git Bash (`--fix`, `--json`) |
| `setup.cmd` | Root 1-click Windows CMD launcher (`--dry-run` supported) | Windows CMD / Explorer (delegates to WSL2) |
| `setup.ps1` | Root 1-click Windows PowerShell launcher | PowerShell 5.1+ / 7+ (delegates to WSL2) |
| `scripts/certs/trust-local-cert.cmd` | CurrentUser Root CA cert installer | Windows CMD (0-Admin `certutil -user`) |
| `scripts/certs/trust-local-cert.ps1` | CurrentUser Root CA cert installer | Windows PowerShell (0-Admin) |
| `scripts/wsl/configure-wsl-enterprise.ps1` | Automated `.wslconfig` and proxy setup | Windows PowerShell |

---

## 3. Pre-Flight Verification & Dry-Run Diagnostic Engine

Before executing `setup-all.sh` or `setup.cmd`, developers and automated CI should execute the non-destructive **Dry-Run Diagnostic Engine**:
```bash
# Windows 1-click CMD launcher:
test-windows-dryrun.cmd

# From WSL2 terminal:
./scripts/test-windows-dryrun.sh [--fix] [--json] [-b <N>]
```

The diagnostic engine validates 10 critical checkpoints:
1. **WSL2 Environment:** `grep -qEi 'Microsoft|Subsystem' /proc/version`.
2. **Native ext4 Path:** Verify `pwd` does NOT start with `/mnt/` (9P I/O penalty & permission stripping).
3. **Line Endings (LF):** Scans all `.sh` and `.sql` scripts for Windows `\r` (CRLF) and auto-fixes them (`--fix`).
4. **POSIX 0600 Permissions:** Simulates SEPS Wallet chmod 0600 on secrets directory.
5. **RAM Allocation:** Verify `grep MemTotal /proc/meminfo` reports $\ge 6000000$ kB.
6. **Hyper-V Dynamic Ports:** Checks ports 1531-1537, 8088, 8448, 9502, 6083 against `netsh.exe`.
7. **Corporate Proxy & TLS:** Checks HTTP_PROXY/HTTPS_PROXY and tests TLS handshake against MITM interceptors.
8. **VPN DNS Tunneling:** Verifies DNS resolution and `.wslconfig` `dnsTunneling=true`.
9. **Container Engine:** Checks rootless Podman/Docker availability and daemon responsiveness.
10. **Zero-Admin Standard:** Verifies execution as standard unprivileged user (UID != 0).
