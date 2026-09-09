[ 🇬🇧 English ](../security.md) | [ 🇪🇪 Eesti ](../et/security.md) | [ 🇫🇮 Suomi ](../fi/security.md) | [ 🇸🇪 Svenska ](../sv/security.md) | [ 🇱🇻 Latviešu ](security.md) | [ 🇱🇹 Lietuvių ](../lt/security.md)

# 🛡️ Oracle Free DB & APEX drošība un SSO arhitektūra

Šis dokuments apkopo platformas drošības apsvērumus, akreditācijas datu pārvaldību, izstrādātāju lomas un vienotās pieteikšanās (SSO / Azure Entra-ID) arhitektūru.

---

## 1. Lokālā noslēpumu pārvaldība (zero-trust - 5. noteikums)

Visas paroles un noslēpumi tiek glabāti AES-256 šifrētā **Oracle SEPS (Secure External Password Store) Auto-Login Wallet** (`cwallet.sso`).

- **Atklāta Teksta Failu Aizliegums:** Paroles nekad netiek rakstītas uz diska atklātā tekstā (nav `.json`, `.txt`, `.env` vai `.cache` failu).
- **Atmiņā Balstīta Dekrēpšana:** Paroles tiek dinamiski atšifrētas atmiņā pēc pieprasījuma:
  ```bash
  ./scripts/get-password.sh <alias>
  ```
- **Minimālo Privilēģiju Princips:** Katrai datubāzei tiek ģenerēti standarta konti:
  - `DBA_ADMIN`: Administratīvie uzdevumi (`DBA` loma).
  - `DEV`: Ikdienas izstrādātāja loma ar Oracle 23ai `DB_DEVELOPER_ROLE`.
  - `APP`: Lietojumprogrammu izpildlaika konts (`CREATE SESSION`, `RESOURCE`).
  - `VIEWER`: Tikai lasīšanas audits (`READ ANY TABLE`).

---

## 2. Vides autentifikācijas matrica

| Vide (`ENVIRONMENT_TYPE`) | Atrašanās Vieta | Autentifikācijas Veids (APEX & DB) | Lietotāju Pārvaldība | TLS Šifrēšana (TCPS) |
| :--- | :--- | :--- | :--- | :--- |
| **`DEV_LOCAL`** | Izstrādātāja Dators | Lokālie SEPS Wallet konti | Automatizēta / `create-developer.sh` | Pēc izvēles (Offline) |
| **`DEV`** | Koplietots Izstrādes Serveris | Hibrīds (Lokālais + **Azure AD**) | Azure AD + JIT / Lokālie konti | Pēc izvēles |
| **`TEST`** | Testa Serveris (CI/CD) | **Azure Entra-ID (SSO)** | Centrāla (Azure AD grupas) | Jā (Ports 2484) |
| **`UAT`** | Pirms-Produkcijas Serveris | **Azure Entra-ID (SSO)** | Centrāla (Azure AD grupas) | Jā (Ports 2484) |
| **`PROD`** | Produkcijas Serveris | **Azure Entra-ID (SSO)** | Centrāla (Azure AD grupas) | Jā (Ports 2484) |

```mermaid
graph TD
    User([Izstrādātājs / Lietotājs]) --> EnvCheck{Vide?}
    EnvCheck -->|DEV_LOCAL| LocalAuth[Lokālie konti / SEPS Wallet]
    EnvCheck -->|DEV| HybridAuth[Hibrīds: Azure AD vai Lokāls]
    EnvCheck -->|TEST / UAT / PROD| SSOAuth[Azure Entra-ID SSO + MFA]
    
    SSOAuth --> TCPS[TLS / TCPS Šifrēts kanāls]
```

---

## 3. Adaptīvais 5 līmeņu TLS/HTTPS dzinējs

Tīmekļa pakalpojumi (ORDS, APEX, Analytics Publisher) izmanto adaptīvu 5 līmeņu sertifikātu hierarhiju bez administratora tiesībām (`scripts/internal/resolve-tls-mode.sh`):

```text
config/certs/
├── custom/          # 0. līmenis: Manuāli pievienoti sertifikāti (tls.crt, tls.key)
├── public/          # 1. līmenis: Publiskais FQDN & Let's Encrypt / Publiskā CA
├── corp/            # 2. līmenis: Uzņēmuma Iekšējā PKI (corp_cert.crt)
├── user_ca/         # 3. līmenis: Lokālā Root CA (lietotāja atslēgu glabātuvē, 0-admin)
└── self_signed/     # 4. līmenis: Dinamiski ģenerēts pašparakstīts sertifikāts
```

---

## 4. Vienotā pieteikšanās (SSO)

- **Datubāzes Līmeņa SSO:** Oracle 23ai atbalsta Azure AD OAuth2 marķierus un globālās lomas.
- **ORDS & REST API:** ORDS pārbauda ienākošos Bearer JWT marķierus pret Azure AD publiskajām atslēgām.
- **APEX Lietotņu SSO:** Lietotnes izmanto Social Sign-In (OpenID Connect) ar automātisku lietotāju reģistrāciju.

---

## 5. Analytics Publisher Drošības un Lomu Matrica

Oracle Analytics Publisher izmanto divu fāžu uzņēmuma līmeņa drošības modeli:

### 1. Fāze: Lokālā Zero-Trust SEPS Wallet (Noklusējuma Aktīvā)
Visi akreditācijas dati tiek droši glabāti šifrētā Oracle SEPS Auto-Login Wallet (`cwallet.sso`). Paroles nekad netiek rakstītas diskā vienkāršā tekstā.

| Loma / Konts | WebLogic Drošības Grupa | SEPS Wallet Alias | Tiesības un Atbildības Joma |
| :--- | :--- | :--- | :--- |
| `bip_developer` | `XMLP_DEVELOPER`, `XMLP_TEMPLATE_DESIGNER` | `PUBLISHER_DEVELOPER` | Veidņu, XLIFF tulkojumu un datu modeļu izstrāde mapē `/Custom/` |
| `bip_user` | `XMLP_SCHEDULER`, `XMLP_ANALYZER` | `PUBLISHER_USER` | Atskaišu izpilde, plānošana, vēstures skatīšana un REST API klienti |
| `bip_admin` | `XMLP_ADMIN` | `PUBLISHER_ADMIN` | BIP kataloga administrēšana (izolēta no WebLogic konsoles) |

Paroļu pārvaldības un rotācijas komandas:
```bash
./scripts/get-password.sh PUBLISHER_DEVELOPER
./scripts/rotate-password.sh publisher dev     # Rotē izstrādātāja paroli
./scripts/rotate-password.sh publisher user    # Rotē lietotāja paroli
./scripts/rotate-password.sh publisher admin   # Rotē administratora paroli
./scripts/rotate-password.sh publisher all     # Rotē visas Publisher paroles
```

### 2. Fāze: Uzņēmuma Mākoņa Identitāte un M2M (Gaidīšanas / Standby Režīms)
- **Interaktīvie tīmekļa lietotāji:** SAML 2.0 Web SSO ar Azure Entra ID / Okta / PingFederate.
- **REST API / CI/CD konveijeri:** OAuth2 M2M Bearer marķieri (`client_credentials` piešķiršana) piesaistīti virtuālajām AppRoles (`BIP_DEVELOPER`, `BIP_INTEGRATION`).
- Var aktivizēt pēc pieprasījuma bez koda izmaiņām, izmantojot `config/profiles/publisher/publisher-standard.yaml` un `./scripts/internal/configure-publisher-sso.sh`.

