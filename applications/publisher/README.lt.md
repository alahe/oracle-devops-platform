[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📊 Oracle Analytics Publisher Programos ir Katalogas (`applications/publisher/`)

Šis katalogas yra **vienintelis tiesos šaltinis (SSoT)** Oracle Analytics Publisher ataskaitoms, tiksliems RTF šablonams ir duomenų modeliams. Aplankų struktūra atitinka serverio katalogą 1:1 (`/Custom/<Sritis>/<Ataskaita>/`).

---

## 📁 Katalogo Struktūra

```text
applications/publisher/
├── .gitignore                         # Neįtraukia binarinių *.xdoz ir *.xdmz archyvų
├── README.md                          # Dokumentacija (6 kalbos: EN, ET, FI, SV, LV, LT)
└── Custom/
    └── Invoices/
        └── Invoice_Report/
            ├── Invoice_Report.xdo/       # Git sekamas ataskaitos paketas
            │   ├── template.rtf          # Prieinamas PDF/UA-1 RTF šablonas
            │   ├── template_et.xlf       # Estų kalbos XLIFF vertimai
            │   ├── template_fi.xlf       # Suomių kalbos XLIFF vertimai
            │   └── _manifest.xml         # Publisher ataskaitos manifestas
            └── Invoice_DataModel.xdm/    # Git sekamas duomenų modelio paketas
                ├── datamodel.sql         # Švari SQL duomenų rinkimo užklausa
                ├── datamodel.xml         # Duomenų modelio XML (susietas su ALISE_APP_DB)
                └── sample_data.xml       # Pavyzdiniai duomenys testavimui
```

> [!IMPORTANT]
> **GitOps Taisyklė:** Git seka tik skaitomus šaltinio failus. Binariniai archyvai (`*.xdoz` ir `*.xdmz`) yra laikini kūrimo artefaktai, kuriuos diegimo scenarijus sugeneruoja atmintyje prieš pat siuntimą (*Just-In-Time*).

---

## 🚀 Komandinės Eilutės Įrankiai (CLI)

### 1. Sukurti naują ataskaitą (Scaffolding)
Sugeneruokite standartus atitinkančią ataskaitą viena komanda:
```bash
./scripts/publisher/create-report.sh Custom/Billing/Monthly_Statement "Mėnesio ataskaita"
```

### 2. Įdiegti į serverį (Deploy)
Įdiekite atskirą ataskaitą arba visą katalogą per REST API:
```bash
# Ataskaitos diegimas (Idempotentinis atnaujinimas)
./scripts/publisher/deploy-template.sh Custom/Invoices/Invoice_Report --mode rest

# Diegimas su momentiniu bandomuoju PDF generavimu serveryje:
./scripts/publisher/deploy-template.sh Custom/Invoices/Invoice_Report --render
```

### 3. Slaptažodžių rotacija
Valdykite slaptažodžius saugiai Oracle SEPS Wallet (`cwallet.sso`):
```bash
./scripts/rotate-password.sh publisher dev     # Keičia bip_developer slaptažodį
./scripts/rotate-password.sh publisher user    # Keičia bip_user slaptažodį
./scripts/rotate-password.sh publisher admin   # Keičia bip_admin slaptažodį
```

---

## 🛡️ Saugumo Rolės ir SEPS Wallet

| Vartotojas | Grupė / Rolės | SEPS Wallet Alias | Paskirtis |
| :--- | :--- | :--- | :--- |
| `bip_developer` | `XMLP_DEVELOPER`, `XMLP_TEMPLATE_DESIGNER` | `PUBLISHER_DEVELOPER` | Šablonų ir duomenų modelių kūrimas aplanke `/Custom/` |
| `bip_user` | `XMLP_SCHEDULER`, `XMLP_ANALYZER` | `PUBLISHER_USER` | Ataskaitų paleidimas, peržiūra ir istorijos valdymas |
| `bip_admin` | `XMLP_ADMIN` | `PUBLISHER_ADMIN` | BIP katalogo administravimas (be WebLogic konsolės) |
