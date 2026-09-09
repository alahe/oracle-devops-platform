[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📊 Oracle Analytics Publisher Sovellukset ja Luettelo (`applications/publisher/`)

Tämä hakemisto on **yhtenäinen totuuden lähde (SSoT)** Oracle Analytics Publisher -raporteille, pikselintarkoille RTF-malleille ja tietomalleille. Hakemistorakenne vastaa palvelimen luetteloa 1:1 (`/Custom/<Toimialue>/<Raportti>/`).

---

## 📁 Hakemistorakenne

```text
applications/publisher/
├── .gitignore                         # Sulkee pois binääriset *.xdoz ja *.xdmz arkistot
├── README.md                          # Dokumentaatio (6 kieltä: EN, ET, FI, SV, LV, LT)
└── Custom/
    └── Invoices/
        └── Invoice_Report/
            ├── Invoice_Report.xdo/       # Git-seurattu raporttipaketti
            │   ├── template.rtf          # Saavutettava PDF/UA-1 RTF-malli
            │   ├── template_et.xlf       # Vironkieliset XLIFF-käännökset
            │   ├── template_fi.xlf       # Suomenkieliset XLIFF-käännökset
            │   └── _manifest.xml         # Publisher-raportin manifesti
            └── Invoice_DataModel.xdm/    # Git-seurattu tietomallipaketti
                ├── datamodel.sql         # Puhdas SQL-tiedonkeruukysely
                ├── datamodel.xml         # Tietomalli XML (sidottu ALISE_APP_DB-lähteeseen)
                └── sample_data.xml       # Esimerkkitiedot offline- ja CI-testaukseen
```

> [!IMPORTANT]
> **GitOps-sääntö:** Git seuraa vain ihmisluettavia lähdetiedostoja. Binääriarkistot (`*.xdoz` ja `*.xdmz`) ovat väliaikaisia koontiartefakteja, jotka luodaan automaattisesti muistissa juuri ennen vientiä (*Just-In-Time*).

---

## 🚀 Komentorivityökalut (CLI)

### 1. Luo uusi raportti (Scaffolding)
Luo täydellinen standardien mukainen raportti yhdellä komennolla:
```bash
./scripts/publisher/create-report.sh Custom/Billing/Monthly_Statement "Kuukausiraportti"
```

### 2. Julkaise palvelimelle (Deploy)
Asenna yksittäinen raportti tai koko luettelo REST API:n kautta:
```bash
# Raportin asennus (Idempotentti upsert)
./scripts/publisher/deploy-template.sh Custom/Invoices/Invoice_Report --mode rest

# Asennus ja välitön palvelinpään PDF-testitulostus:
./scripts/publisher/deploy-template.sh Custom/Invoices/Invoice_Report --render
```

### 3. Salasanojen kierrätys
Hallitse salasanoja turvallisesti Oracle SEPS Walletissa (`cwallet.sso`):
```bash
./scripts/rotate-password.sh publisher dev     # Kierrättää bip_developer salasanan
./scripts/rotate-password.sh publisher user    # Kierrättää bip_user salasanan
./scripts/rotate-password.sh publisher admin   # Kierrättää bip_admin salasanan
```

---

## 🛡️ Turvallisuusroolit ja SEPS Wallet

| Käyttäjä | Ryhmä / Roolit | SEPS Wallet Alias | Tarkoitus |
| :--- | :--- | :--- | :--- |
| `bip_developer` | `XMLP_DEVELOPER`, `XMLP_TEMPLATE_DESIGNER` | `PUBLISHER_DEVELOPER` | Mallien ja tietomallien kehitys kansiossa `/Custom/` |
| `bip_user` | `XMLP_SCHEDULER`, `XMLP_ANALYZER` | `PUBLISHER_USER` | Tulosteiden ajo, katselu ja historiatiedot |
| `bip_admin` | `XMLP_ADMIN` | `PUBLISHER_ADMIN` | BIP-luettelon hallinta (ei WebLogic-konsolia) |
