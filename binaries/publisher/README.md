[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📦 Oracle Analytics Publisher Packages (`binaries/publisher/`)

Analytics Publisher (BIP) installation archives and workstation desktop packages.

## 1. Supported Packages
- **Analytics Publisher Server:** ZIP / RPM / JAR packages for OAS/Publisher server builds.
- **Publisher Designer Workstation (BP 9):**
  - **Microsoft Office Installer:** `setup.exe` (Office 2010/2013/2016 32-bit standalone installer recommended for container Wine runtime).
  - **Oracle BI Publisher Desktop Add-In:** `BIPublisherDesktop32.exe` (or `BIPublisherDesktop64.exe` for Windows KVM container).

## 2. Automated Workstation Installation
Once installers are placed in this directory, run:
```bash
./scripts/publisher/setup-word-designer.sh
```
Or open the noVNC desktop on port 6083 (`./scripts/publisher/open-designer.sh`) and click **"⚡ Paigalda Word & Publisher Designer"**.

## 3. Git Status
Binary files (`*.exe`, `*.zip`, `*.iso`, `*.rpm`) are strictly gitignored (local-only).
