[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📊 Oracle Analytics Publisher Lietotnes un Katalogs (`applications/publisher/`)

Šis direktorijs ir **vienotais patiesības avots (SSoT)** Oracle Analytics Publisher pārskatiem, pikseļu precīzām RTF veidnēm un datu modeļiem. Mape atbilst servera katalogam 1:1 (`/Custom/<Nozare>/<Pārskats>/`).

---

## 📁 Kataloga Struktūra

```text
applications/publisher/
├── .gitignore                         # Izslēdz bināros *.xdoz un *.xdmz arhīvus
├── README.md                          # Dokumentācija (6 valodas: EN, ET, FI, SV, LV, LT)
└── Custom/
    └── Invoices/
        └── Invoice_Report/
            ├── Invoice_Report.xdo/       # Git izsekota pārskata pakotne
            │   ├── template.rtf          # Piekļūstama PDF/UA-1 RTF veidne
            │   ├── template_et.xlf       # Igauņu valodas XLIFF tulkojumi
            │   ├── template_fi.xlf       # Somu valodas XLIFF tulkojumi
            │   └── _manifest.xml         # Publisher pārskata manifests
            └── Invoice_DataModel.xdm/    # Git izsekota datu modeļa pakotne
                ├── datamodel.sql         # Tīrs SQL datu atlases vaicājums
                ├── datamodel.xml         # Datu modeļa XML (piesaistīts ALISE_APP_DB)
                └── sample_data.xml       # Paraugdati bezsaistes un CI testēšanai
```

> [!IMPORTANT]
> **GitOps Noteikums:** Git izseko tikai lasāmus avota failus. Binārie arhīvi (`*.xdoz` un `*.xdmz`) ir pagaidu būvēšanas artefakti, kurus izvietošanas skripts automātiski ģenerē atmiņā tieši pirms nosūtīšanas (*Just-In-Time*).

---

## 🚀 Komandrindas Rīki (CLI)

### 1. Izveidot jaunu pārskatu (Scaffolding)
Ģenerējiet pilnīgu un standartiem atbilstošu pārskatu ar vienu komandu:
```bash
./scripts/publisher/create-report.sh Custom/Billing/Monthly_Statement "Mēneša pārskats"
```

### 2. Izvietot serverī (Deploy)
Izvietojiet atsevišķu pārskatu vai visu katalogu, izmantojot REST API:
```bash
# Pārskata izvietošana (Idempotenta atjaunināšana)
./scripts/publisher/deploy-template.sh Custom/Invoices/Invoice_Report --mode rest

# Izvietošana ar tūlītēju PDF testa atveidošanu serverī:
./scripts/publisher/deploy-template.sh Custom/Invoices/Invoice_Report --render
```

### 3. Paroļu rotācija
Pārvaldiet paroles droši Oracle SEPS Wallet (`cwallet.sso`):
```bash
./scripts/rotate-password.sh publisher dev     # Rotē bip_developer paroli
./scripts/rotate-password.sh publisher user    # Rotē bip_user paroli
./scripts/rotate-password.sh publisher admin   # Rotē bip_admin paroli
```

---

## 🛡️ Drošības Lomas un SEPS Wallet

| Lietotājs | Grupa / Lomas | SEPS Wallet Alias | Mērķis |
| :--- | :--- | :--- | :--- |
| `bip_developer` | `XMLP_DEVELOPER`, `XMLP_TEMPLATE_DESIGNER` | `PUBLISHER_DEVELOPER` | Veidņu un datu modeļu izstrāde mapē `/Custom/` |
| `bip_user` | `XMLP_SCHEDULER`, `XMLP_ANALYZER` | `PUBLISHER_USER` | Izdruku palaišana, skatīšana un vēstures pārvaldība |
| `bip_admin` | `XMLP_ADMIN` | `PUBLISHER_ADMIN` | BIP kataloga administrēšana (nav WebLogic konsoles) |
