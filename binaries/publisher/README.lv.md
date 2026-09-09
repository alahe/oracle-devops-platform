[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📦 Oracle Analytics Publisher pakotnes (`binaries/publisher/`)

Analytics Publisher (BIP) instalācijas arhīvi un darbstacijas komponentes.

## 1. Atbalstītās pakotnes
- **Analytics Publisher Server:** ZIP / RPM / JAR arhīvi servera veidošanai.
- **Publisher Designer darbstacija (BP 9):**
  - **Microsoft Office instalators:** `setup.exe` (ieteicams Office 2010/2013/2016 32-bit standalone priekš Wine).
  - **Oracle BI Publisher Desktop spraudnis:** `BIPublisherDesktop32.exe` (vai `BIPublisherDesktop64.exe` Windows KVM konteineram).

## 2. Automatizēta uzstādīšana
Kad instalatori ir iekopēti šajā direktorijā, izpildiet:
```bash
./scripts/publisher/setup-word-designer.sh
```
Vai atveriet noVNC darbvirsmu portā 6083 (`./scripts/publisher/open-designer.sh`) un noklikšķiniet uz ikonas **"⚡ Paigalda Word & Publisher Designer"**.

## 3. Git statuss
Binārie faili (`*.exe`, `*.zip`, `*.iso`, `*.rpm`) ir gitignored (tikai lokāli).
