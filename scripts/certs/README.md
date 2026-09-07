[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🔒 SSL/TLS Certificate & Trust Management Module (Zero-Admin / Non-Root)

This module manages HTTPS and TCPS secure connections, certificate selection, and automated trust installation in macOS and Windows environments without requiring administrator (`root` / `sudo`) privileges.

---

## 🧭 5-Tier Hierarchical TLS Resolution Chain (Priority Chain)

During startup and configuration, [`scripts/internal/resolve-tls-mode.sh`](../internal/resolve-tls-mode.sh) automatically resolves the appropriate certificate:

1. **Step 0 (Manually copied certificate - `config/certs/custom/`):**
   * If you copy an existing certificate (`tls.crt` and `tls.key`) into `config/certs/custom/`, it is used immediately with highest priority.
2. **Step 1 (Option 1 - Public FQDN & Let's Encrypt / Public CA - `config/certs/public/`):**
   * Active when `USE_PUBLIC_CA_CERTS=true` in `.env` and certificate is located at `config/certs/public/public_cert.crt`.
3. **Step 2 (Option 2 - Enterprise Internal PKI - `config/certs/corp/`):**
   * Active when `CORP_PKI_ENABLED=true` in `.env` and certificate is located at `config/certs/corp/corp_cert.crt`.
4. **Step 3 (Option 3 - User-level local CA - `config/certs/user_ca/`):**
   * Local CA is added to the user's personal store (**0 root/admin privileges**) providing a green padlock in browsers.
5. **Step 4 (Option 4 - Dynamically generated Self-signed certificate - `config/certs/self_signed/`):**
   * ⚠️ **Untrusted fallback:** Produces *"Not Secure"* warning in browsers. Allowed only when `TLS_ALLOWED_LEVEL=permissive`.

---

## 💻 User-Space Non-Admin Trust Scripts

* **macOS:**
  * [`trust-local-cert-mac.sh`](trust-local-cert-mac.sh): Installs CA into user keychain `~/Library/Keychains/login.keychain-db` without `sudo`.
  * [`untrust-local-cert-mac.sh`](untrust-local-cert-mac.sh): Removes CA from user keychain.
* **Windows (PowerShell):**
  * [`trust-local-cert.ps1`](trust-local-cert.ps1): Installs CA into user personal store `Cert:\CurrentUser\Root` without admin rights.
* **Windows (CMD):**
  * [`trust-local-cert.cmd`](trust-local-cert.cmd): Executes PowerShell script under standard user privileges.
  * [`untrust-local-cert.cmd`](untrust-local-cert.cmd): Removes CA from Windows user store.
* **Cross-Platform Cleanup (All OS):**
  * [`clean-certs.sh`](clean-certs.sh) (CLI wrapper: `./scripts/clean-certs.sh`): Cleans up old certificates from OS keystores and disk.
  * Supports flags: `--all`, `--keychain-only`, `--files-only`, `--regenerate`, `-y`.
  * Integrated into environment reset: `./scripts/reset-all.sh --clean-certs`.

---

## 🧪 TLS Testing
```bash
./tests/test-tls-scenarios.sh
```
