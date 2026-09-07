[ 🇬🇧 English ](../security.md) | [ 🇪🇪 Eesti ](../et/security.md) | [ 🇫🇮 Suomi ](../fi/security.md) | [ 🇸🇪 Svenska ](../sv/security.md) | [ 🇱🇻 Latviešu ](../lv/security.md) | [ 🇱🇹 Lietuvių ](security.md)

# 🛡️ Oracle Free DB & APEX Sauga ir SSO Architektūra

Šiame dokumente pateikiami platformos saugumo principai, slaptažodžių valdymas, kūrėjų vaidmenys ir vieningo prisijungimo (SSO / Azure Entra-ID) architektūra.

---

## 1. Vietinis Paslapčių Valdymas (Zero-Trust - 5 Taisyklė)

Visi slaptažodžiai ir paslaptys saugomi AES-256 užšifruotoje **Oracle SEPS (Secure External Password Store) Auto-Login Wallet** piniginėje (`cwallet.sso`).

- **Atviro Teksto Failų Draudimas:** Slaptažodžiai niekada nerašomi į diską atviru tekstu (jokių `.json`, `.txt`, `.env` ar `.cache` failų).
- **Atmintyje Vykdomas Iššifravimas:** Slaptažodžiai dinamiškai iššifruojami atmintyje pagal poreikį:
  ```bash
  ./scripts/get-password.sh <alias>
  ```
- **Mažiausių Teisių Principas:** Kiekvienai duomenų bazei automatiškai sugeneruojamos standartinės paskyros:
  - `DBA_ADMIN`: Administracinės užduotys (`DBA` rolė).
  - `DEV`: Kasdienis kūrėjas su Oracle 23ai `DB_DEVELOPER_ROLE`.
  - `APP`: Programų vykdymo paskyra (`CREATE SESSION`, `RESOURCE`).
  - `VIEWER`: Tik skaitymo auditas (`READ ANY TABLE`).

---

## 2. Aplinkų Autentifikavimo Matrica

| Aplinka (`ENVIRONMENT_TYPE`) | Vieta | Autentifikavimo Tipas (APEX & DB) | Vartotojų Valdymas | TLS Šifravimas (TCPS) |
| :--- | :--- | :--- | :--- | :--- |
| **`DEV_LOCAL`** | Kūrėjo Kompiuteris | Vietinės SEPS Wallet paskyros | Automatizuotas / `create-developer.sh` | Pasirinktinai (Offline) |
| **`DEV`** | Bendras Kūrimo Serveris | Hibridinis (Vietinis + **Azure AD**) | Azure AD + JIT / Vietinės paskyros | Pasirinktinai |
| **`TEST`** | Testavimo Serveris (CI/CD) | **Azure Entra-ID (SSO)** | Centrinis (Azure AD grupės) | Taip (Prievadas 2484) |
| **`UAT`** | Priešgamybinis Serveris | **Azure Entra-ID (SSO)** | Centrinis (Azure AD grupės) | Taip (Prievadas 2484) |
| **`PROD`** | Gamybinis Serveris | **Azure Entra-ID (SSO)** | Centrinis (Azure AD grupės) | Taip (Prievadas 2484) |

```mermaid
graph TD
    User([Kūrėjas / Vartotojas]) --> EnvCheck{Aplinka?}
    EnvCheck -->|DEV_LOCAL| LocalAuth[Vietinės paskyros / SEPS Wallet]
    EnvCheck -->|DEV| HybridAuth[Hibridinis: Azure AD arba Vietinis]
    EnvCheck -->|TEST / UAT / PROD| SSOAuth[Azure Entra-ID SSO + MFA]
    
    SSOAuth --> TCPS[TLS / TCPS Šifruotas kanalas]
```

---

## 3. Adaptyvus 5 Lygių TLS/HTTPS Variklis

Žiniatinklio paslaugos (ORDS, APEX, Analytics Publisher) naudoja adaptyvią sertifikatų hierarchiją be administratoriaus teisių (`scripts/internal/resolve-tls-mode.sh`):

```text
config/certs/
├── custom/          # 0 lygis: Rankiniu būdu pridėti sertifikatai (tls.crt, tls.key)
├── public/          # 1 lygis: Viešasis FQDN & Let's Encrypt / Viešasis CA
├── corp/            # 2 lygis: Įmonės Vidinis PKI (corp_cert.crt)
├── user_ca/         # 3 lygis: Vietinis Root CA (vartotojo raktinėje, 0-admin)
└── self_signed/     # 4 lygis: Dinamiškai sugeneruotas savarankiškai pasirašytas sertifikatas
```

---

## 4. Vieningas Prisijungimas (SSO)

- **Duomenų Bazės Lygio SSO:** Oracle 23ai palaiko Azure AD OAuth2 žetonus ir visuotines roles.
- **ORDS & REST API:** ORDS tikrina gaunamus Bearer JWT žetonus pagal Azure AD viešuosius raktus.
- **APEX Programų SSO:** Programos naudoja Social Sign-In (OpenID Connect) su automatiniu vartotojų registravimu.
