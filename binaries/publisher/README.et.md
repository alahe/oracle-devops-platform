[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📦 Oracle Analytics Publisheri paketid (`binaries/publisher/`)

Analytics Publisheri (BIP) paigaldusarhiivid ja töölaua kujunduskomponendid.

## 1. Toetatud paketid
- **Analytics Publisher Server:** ZIP / RPM / JAR paketid OAS/Publisher serveri ehitamiseks.
- **Publisher Designer arendustöökoht (BP 9):**
  - **Microsoft Office paigaldaja:** `setup.exe` (soovitatavalt Office 2010/2013/2016 32-bit standalone installer Wine konteinerkeskkonda).
  - **Oracle BI Publisher Desktop lisandmoodul:** `BIPublisherDesktop32.exe` (või `BIPublisherDesktop64.exe` Windows KVM konteinerisse).

## 2. Automaatne paigaldamine
Kui installerid on sellesse kausta kopeeritud, käivitage:
```bash
./scripts/publisher/setup-word-designer.sh
```
Või avage noVNC töölaud pordil 6083 (`./scripts/publisher/open-designer.sh`) ja klõpsake töölaual ikooni **"⚡ Paigalda Word & Publisher Designer"**.

## 3. Git staatus
Binaarfailid (`*.exe`, `*.zip`, `*.iso`, `*.rpm`) on gitignored (rangelt lokaalsed).
