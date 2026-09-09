[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📦 Oracle Analytics Publisher paketai (`binaries/publisher/`)

Analytics Publisher (BIP) diegimo archyvai ir šablonų kūrėjo komponentai.

## 1. Palaikomi paketai
- **Analytics Publisher Server:** ZIP / RPM / JAR paketai serverio kūrimui.
- **Publisher Designer darbo vieta (BP 9):**
  - **Microsoft Office diegimo programa:** `setup.exe` (rekomenduojama Office 2010/2013/2016 32-bit standalone Wine konteineriui).
  - **Oracle BI Publisher Desktop papildinys:** `BIPublisherDesktop32.exe` (arba `BIPublisherDesktop64.exe` Windows KVM konteineriui).

## 2. Automatizuotas diegimas
Nukopijavę diegimo programas į šį katalogą, paleiskite:
```bash
./scripts/publisher/setup-word-designer.sh
```
Arba atidarykite noVNC darbalaukį prievade 6083 (`./scripts/publisher/open-designer.sh`) ir paspauskite piktogramą **"⚡ Paigalda Word & Publisher Designer"**.

## 3. Git būsena
Dvejetainiai failai (`*.exe`, `*.zip`, `*.iso`, `*.rpm`) yra gitignored (tik vietiniai).
