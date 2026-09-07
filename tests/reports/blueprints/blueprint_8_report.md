# Blueprinti 8 Testiaruanne (2026-09-03 23:36:22)

- **Aeg ja Kuupäev:** 2026-09-03 23:36:22
- **Kogu Paigalduse Kestus:** 2m 23s
- **Blueprinti Fail:** `config/blueprints/.env.8-*`

---

## 1. ⏱ Ajakulu ja Tervisekontroll (Duration & Health)
- **Tulemus:** ✅ Paigaldus ja tervisekontrollid läbitud 100% korrektselt.
- **Kestus kokku:** 2m 23s

---

## 2. 💻 Konteinerite Mälukasutus & CPU (RAM / CPU Metrics)

| Konteineri Nimi | CPU % | Mälukasutus / Limiit | RAM % |
| :--- | :--- | :--- | :--- |
| web-ide-dev | 22.06% | 98.06MB / 12.5GB | 0.78% |

---

## 3. 💾 Kettamaht (Podman Volumes & Storage)

| Voluumi Nimi | Kettamaht |
| :--- | :--- |
| oracle-free-db-in-prod_proxy_oradata | N/A |
| oracle-free-db-in-prod_web_ide_data | N/A |

---

## 4. 🗄️ Aktiivsed Konteinerid ja Pordid (Active Containers)

| Konteineri Nimi | Staatus | Pordid |
| :--- | :--- | :--- |
| web-ide-dev | Up 2 minutes (starting) | 0.0.0.0:8090->8443/tcp, 0.0.0.0:8091->8091/tcp, 0.0.0.0:8449->8443/tcp |

---

## 5. 🌐 Veebiteenuste URL Audit (URL Health Matrix)

| Veebiteenuse Nimi | Kontrollitud URL | HTTP Kood | TLS Usaldus | Staatus |
| :--- | :--- | :--- | :--- | :--- |
| Web IDE (HTTP) | `http://localhost:8090` | `HTTP 200` | N/A | ✅ OK |

---

## 6. 🔒 TLS / HTTPS Turvalisuse ja Sertifikaatide Audit (TLS Trust Matrix)
- **Aktiivne TLS Režiim:** `USER_CA`
- **Režiimi Kirjeldus:** Detected User / Local Dev Root CA certificates
- **Kasutatav Sertifikaat:** `/Users/allanlahe/Oracle/oracle-free-db-in-prod/config/certs/user_ca/localhost.crt`
- **Lubatud Poliitika Tase:** `permissive`
- **Mitte-Admin Usalduse Olek:** ✅ Usaldatud kasutaja tasemel (`Cert:\CurrentUser\Root` / `login.keychain-db`).

---

## 7. 🔑 SEPS Paroolivabade Oracle Wallet Ühenduste Audit (SEPS Wallet Connection Audit)

> 🛡️ **Turvalisus:** Aruanne ei sisalda avatud kujul ega salvestatud paroole. Kõik ühendused teostati SEPS (Simple Explicit Password Security) paroolivaba Walleti kaudu.

| SEPS Walleti Alias | Ühenduse Staatus | Tuvastatud Kasutaja & Baas |
| :--- | :--- | :--- |
| `DB_DB_PROXY_APP` | ℹ️ Skipped | `Proxy profile is not active` |
| `DB_DB_PROXY_DBA_ADMIN` | ℹ️ Skipped | `Proxy profile is not active` |
| `DB_DB_PROXY_DEV` | ℹ️ Skipped | `Proxy profile is not active` |
| `DB_DB_PROXY_SCHEMA` | ℹ️ Skipped | `Proxy profile is not active` |
| `DB_DB_PROXY_SYS` | ℹ️ Skipped | `Proxy profile is not active` |
| `DB_DB_PROXY_VIEWER` | ℹ️ Skipped | `Proxy profile is not active` |
| `DB_PROXY_DBA_ADMIN` | ℹ️ Skipped | `Proxy profile is not active` |
| `DB_PROXY_DEV` | ℹ️ Skipped | `Proxy profile is not active` |
| `DB_PROXY_SCHEMA` | ℹ️ Skipped | `Proxy profile is not active` |
| `DB_PROXY_SYS` | ℹ️ Skipped | `Proxy profile is not active` |
| `DB_PROXY_VIEWER` | ℹ️ Skipped | `Proxy profile is not active` |

### 💡 Parooli Pärimine Walletist
Kui arendajal või administraatoril on vaja tekstilist parooli (nt DBeaveri, DataGripi või välise tööriista jaoks), saab selle turvaliselt pärida käsuga:
```bash
./scripts/get-password.sh <WALLET_ALIAS>
```
Näiteks:
- `./scripts/get-password.sh DB_DEV` *(Arendaja parool)*
- `./scripts/get-password.sh DB_SYS` *(Administraatori parool)*

---

## 8. ⚠️ Tuvastatud Probleemid ja Iseparanemised (Log & Self-Healing Audit)
- Vead / Iseparanemised: 0 kriitilist viga. Automaatne kontroll sooritatud.
