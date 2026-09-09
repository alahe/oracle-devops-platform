[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📊 Oracle Analytics Publisher Applikationer och Katalog (`applications/publisher/`)

Denna katalog är **enda sanningskällan (SSoT)** för Oracle Analytics Publisher-rapporter, pixelperfekta RTF-mallar och datamodeller. Mappstrukturen speglar serverns katalog 1:1 (`/Custom/<Domän>/<Rapport>/`).

---

## 📁 Katalogstruktur

```text
applications/publisher/
├── .gitignore                         # Exkluderar binära *.xdoz och *.xdmz arkiv
├── README.md                          # Dokumentation (6 språk: EN, ET, FI, SV, LV, LT)
└── Custom/
    └── Invoices/
        └── Invoice_Report/
            ├── Invoice_Report.xdo/       # Git-spårat rapportpaket
            │   ├── template.rtf          # Tillgänglig PDF/UA-1 RTF-mall
            │   ├── template_et.xlf       # Estniska XLIFF-översättningar
            │   ├── template_fi.xlf       # Finska XLIFF-översättningar
            │   └── _manifest.xml         # Publisher-rapportmanifest
            └── Invoice_DataModel.xdm/    # Git-spårat datamodellpaket
                ├── datamodel.sql         # Ren SQL-datainsamlingsfråga
                ├── datamodel.xml         # Datamodell XML (kopplad till ALISE_APP_DB)
                └── sample_data.xml       # Exempeldata för offline- och CI-testning
```

> [!IMPORTANT]
> **GitOps-regel:** Git spårar endast läsbara källfiler. Binära arkiv (`*.xdoz` och `*.xdmz`) är tillfälliga byggartefakter som skapas automatiskt i minnet precis före distribution (*Just-In-Time*).

---

## 🚀 Kommandoradsverktyg (CLI)

### 1. Skapa ny rapport (Scaffolding)
Generera en komplett och standardkompatibel rapport med ett enda kommando:
```bash
./scripts/publisher/create-report.sh Custom/Billing/Monthly_Statement "Månadsrapport"
```

### 2. Distribuera till server (Deploy)
Distribuera en enskild rapport eller hela katalogen via REST API:
```bash
# Rapportdistribution (Idempotent upsert)
./scripts/publisher/deploy-template.sh Custom/Invoices/Invoice_Report --mode rest

# Distribution med omedelbar PDF-testrendering på servern:
./scripts/publisher/deploy-template.sh Custom/Invoices/Invoice_Report --render
```

### 3. Lösenordsrotation
Hantera lösenord säkert i Oracle SEPS Wallet (`cwallet.sso`):
```bash
./scripts/rotate-password.sh publisher dev     # Roterar lösenord för bip_developer
./scripts/rotate-password.sh publisher user    # Roterar lösenord för bip_user
./scripts/rotate-password.sh publisher admin   # Roterar lösenord för bip_admin
```

---

## 🛡️ Säkerhetsroller och SEPS Wallet

| Användare | Grupp / Roller | SEPS Wallet Alias | Syfte |
| :--- | :--- | :--- | :--- |
| `bip_developer` | `XMLP_DEVELOPER`, `XMLP_TEMPLATE_DESIGNER` | `PUBLISHER_DEVELOPER` | Utveckling av mallar och datamodeller i `/Custom/` |
| `bip_user` | `XMLP_SCHEDULER`, `XMLP_ANALYZER` | `PUBLISHER_USER` | Köra rapporter, visa och hantera jobbhistorik |
| `bip_admin` | `XMLP_ADMIN` | `PUBLISHER_ADMIN` | BIP-katalogadministration (ingen WebLogic-konsol) |
