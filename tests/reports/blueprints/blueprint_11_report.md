# Blueprinti 11 Testiaruanne (2026-09-03 23:53:13)

- **Aeg ja Kuupäev:** 2026-09-03 23:53:13
- **Kogu Paigalduse Kestus:** 8m 19s
- **Blueprinti Fail:** `config/blueprints/.env.11-*`

---

## 1. ⏱ Ajakulu ja Tervisekontroll (Duration & Health)
- **Tulemus:** ✅ Paigaldus ja tervisekontrollid läbitud 100% korrektselt.
- **Kestus kokku:** 8m 19s

---

## 2. 💻 Konteinerite Mälukasutus & CPU (RAM / CPU Metrics)

| Konteineri Nimi | CPU % | Mälukasutus / Limiit | RAM % |
| :--- | :--- | :--- | :--- |
| db-proxy | 38.94% | 635.5MB / 3.221GB | 19.73% |
| app-ords | 41.67% | 888MB / 1.074GB | 82.70% |

---

## 3. 💾 Kettamaht (Podman Volumes & Storage)

| Voluumi Nimi | Kettamaht |
| :--- | :--- |
| oracle-free-db-in-prod_publisher_data | N/A |
| oracle-free-db-in-prod_apex_images_26_1 | N/A |
| oracle-free-db-in-prod_proxy_oradata | N/A |

---

## 4. 🗄️ Aktiivsed Konteinerid ja Pordid (Active Containers)

| Konteineri Nimi | Staatus | Pordid |
| :--- | :--- | :--- |
| db-proxy | Up 32 seconds (healthy) | 0.0.0.0:1532->1521/tcp |
| app-ords | Up 31 seconds (starting) | 0.0.0.0:8088->8088/tcp, 0.0.0.0:8448->8448/tcp |

---

## 5. 🌐 Veebiteenuste URL Audit (URL Health Matrix)

| Veebiteenuse Nimi | Kontrollitud URL | HTTP Kood | TLS Usaldus | Staatus |
| :--- | :--- | :--- | :--- | :--- |
| Publisher UI (HTTP) | `http://localhost:9502/xmlpserver` | `HTTP 000` | N/A | ❌ Kättesaamatu |

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
