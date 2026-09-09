[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📊 Oracle Analytics Publisher Rakendused ja Kataloog (`applications/publisher/`)

See kataloog on **ühtne tõeallikas (SSoT)** Oracle Analytics Publisheri aruannetele, pikslitäpsetele RTF mallidele ja andmemudelitele. Kaustapuu peegeldab serveri kataloogi 1:1 (`/Custom/<Valdkond>/<Raport>/`).

---

## 📁 Kataloogi Struktuur

```text
applications/publisher/
├── .gitignore                         # Välistab binaarsed *.xdoz ja *.xdmz arhiivid
├── README.md                          # Dokumentatsioon (6 keelt: EN, ET, FI, SV, LV, LT)
└── Custom/
    └── Invoices/
        └── Invoice_Report/
            ├── Invoice_Report.xdo/       # Git-jälgitav raporti pakett
            │   ├── template.rtf          # Ligipääsetav PDF/UA-1 RTF mall
            │   ├── template_et.xlf       # Eesti keele XLIFF tõlked
            │   ├── template_fi.xlf       # Soome keele XLIFF tõlked
            │   └── _manifest.xml         # Publisheri raporti manifest
            └── Invoice_DataModel.xdm/    # Git-jälgitav andmemudeli pakett
                ├── datamodel.sql         # Puhas SQL andmete kogumise päring
                ├── datamodel.xml         # Andmemudeli XML (seotud ALISE_APP_DB-ga)
                └── sample_data.xml       # Näidisandmed offline ja CI testimiseks
```

> [!IMPORTANT]
> **GitOps Reegel:** Git jälgib ainult loetavaid lähtefaile. Binaarsed arhiivid (`*.xdoz` ja `*.xdmz`) on ajutised ehitusartefaktid ja genereeritakse paigaldusskripti poolt vahetult mälus (*Just-In-Time*).

---

## 🚀 Käsurea Tööriistad (CLI)

### 1. Uue raporti loomine (Scaffolding)
Genereeri terviklik ja standarditele vastav raport ühe käsuga:
```bash
./scripts/publisher/create-report.sh Custom/Billing/Monthly_Statement "Kuu koondaruanne"
```

### 2. Serverisse saatmine (Deploy)
Paigalda üksik raport või terve kataloog REST API kaudu:
```bash
# Raporti paigaldamine (Idempotentne upsert)
./scripts/publisher/deploy-template.sh Custom/Invoices/Invoice_Report --mode rest

# Paigaldamine koos kohese serveripoolse PDF test-renderdusega:
./scripts/publisher/deploy-template.sh Custom/Invoices/Invoice_Report --render
```

### 3. Paroolide rotatsioon
Halda paroole turvaliselt Oracle SEPS Walletis (`cwallet.sso`):
```bash
./scripts/rotate-password.sh publisher dev     # Roteerib bip_developer parooli
./scripts/rotate-password.sh publisher user    # Roteerib bip_user parooli
./scripts/rotate-password.sh publisher admin   # Roteerib bip_admin parooli
```

---

## 🛡️ Turvarollid ja SEPS Wallet

| Kasutaja | Grupp / Rollid | SEPS Walleti Alias | Eesmärk |
| :--- | :--- | :--- | :--- |
| `bip_developer` | `XMLP_DEVELOPER`, `XMLP_TEMPLATE_DESIGNER` | `PUBLISHER_DEVELOPER` | Mallide ja andmemudelite loomine kaustas `/Custom/` |
| `bip_user` | `XMLP_SCHEDULER`, `XMLP_ANALYZER` | `PUBLISHER_USER` | Trükiste käivitamine, vaatamine ja ajaloo haldus |
| `bip_admin` | `XMLP_ADMIN` | `PUBLISHER_ADMIN` | BIP kataloogi haldus (puudub WebLogic konsool) |
