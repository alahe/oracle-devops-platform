[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📦 Oracle Analytics Publisher -paketit (`binaries/publisher/`)

Analytics Publisherin (BIP) asennusarkistot ja työpöytäsuunnittelijan paketit.

## 1. Tuetut paketit
- **Analytics Publisher Server:** ZIP / RPM / JAR -paketit OAS/Publisher-palvelimen rakentamiseen.
- **Publisher Designer -työasema (BP 9):**
  - **Microsoft Office -asennusohjelma:** `setup.exe` (suositus: Office 2010/2013/2016 32-bit standalone installer Wine-konttiin).
  - **Oracle BI Publisher Desktop -apuohjelma:** `BIPublisherDesktop32.exe` (tai `BIPublisherDesktop64.exe` Windows KVM -konttiin).

## 2. Automaattinen asennus
Kun asennusohjelmat on kopioitu tähän hakemistoon, suorita:
```bash
./scripts/publisher/setup-word-designer.sh
```
Tai avaa noVNC-työpöytä portissa 6083 (`./scripts/publisher/open-designer.sh`) ja napsauta kuvaketta **"⚡ Paigalda Word & Publisher Designer"**.

## 3. Git-tila
Binaaritiedostot (`*.exe`, `*.zip`, `*.iso`, `*.rpm`) ovat gitignore-suojattuja (vain paikallisia).
