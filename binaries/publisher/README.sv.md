[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📦 Oracle Analytics Publisher-paket (`binaries/publisher/`)

Analytics Publisher (BIP) installationsarkiv och komponenter för mallbyggare.

## 1. Paket som stöds
- **Analytics Publisher Server:** ZIP / RPM / JAR-paket för OAS/Publisher-server.
- **Publisher Designer arbetsstation (BP 9):**
  - **Microsoft Office installationsprogram:** `setup.exe` (Office 2010/2013/2016 32-bit standalone rekommenderas för Wine-container).
  - **Oracle BI Publisher Desktop-tillägg:** `BIPublisherDesktop32.exe` (eller `BIPublisherDesktop64.exe` för Windows KVM-container).

## 2. Automatiserad installation
När installationsprogrammen placerats i denna katalog, kör:
```bash
./scripts/publisher/setup-word-designer.sh
```
Eller öppna noVNC-skrivbordet på port 6083 (`./scripts/publisher/open-designer.sh`) och klicka på skrivbordsikonen **"⚡ Paigalda Word & Publisher Designer"**.

## 3. Git-status
Binärfiler (`*.exe`, `*.zip`, `*.iso`, `*.rpm`) är gitignored (strikt lokala).
