# Blueprinti 31 Testiaruanne (2026-08-31 04:21:59)

- **Aeg ja Kuupäev:** 2026-08-31 04:21:59
- **Kogu Paigalduse Kestus:** 1m 25s
- **Blueprinti Fail:** `config/blueprints/.env.31-*`

---

## 1. ⏱ Ajakulu ja Tervisekontroll (Duration & Health)
- **Tulemus:** ✅ Paigaldus ja tervisekontrollid läbitud 100% korrektselt.
- **Kestus kokku:** 1m 25s

---

## 2. 💻 Konteinerite Mälukasutus & CPU (RAM / CPU Metrics)

| Konteineri Nimi | CPU % | Mälukasutus / Limiit | RAM % |
| :--- | :--- | :--- | :--- |
| db-proxy | 20.31% | 533.7MB / 3.221GB | 16.57% |

---

## 3. 💾 Kettamaht (Podman Volumes & Storage)

| Voluumi Nimi | Kettamaht |
| :--- | :--- |
| oracle-free-db-in-prod_proxy_oradata | N/A |
| oracle-free-db-in-prod_apex_images_26_1 | N/A |

---

## 4. 🗄️ Aktiivsed Konteinerid ja Pordid (Active Containers)

| Konteineri Nimi | Staatus | Pordid |
| :--- | :--- | :--- |
| db-proxy | Up 4 minutes (healthy) | 127.0.0.1:1532->1522/tcp, 1521/tcp |

---

## 5. 🌐 Veebiteenuste URL Audit (URL Health Matrix)

| Veebiteenuse Nimi | Kontrollitud URL | HTTP Kood | TLS Usaldus | Staatus |
| :--- | :--- | :--- | :--- | :--- |
| Developer Hub (HTTPS) | `https://localhost:8448/dev-hub.html` | `HTTP 000` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| ORDS Root HTTPS | `https://localhost:8448/ords/` | `HTTP 000` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| ORDS Database Actions (Default) | `https://localhost:8448/ords/_/landing` | `HTTP 000` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| APEX Builder (PROXY) | `https://localhost:8448/ords/proxy/r/apex/workspace-sign-in/oracle-apex-sign-in` | `HTTP 000` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| APEX Instance Admin (PROXY) | `https://localhost:8448/ords/proxy/apex_admin` | `HTTP 000` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| ORDS Database Actions (PROXY) | `https://localhost:8448/ords/proxy/_/landing` | `HTTP 000` | ⚠️ Self-Signed | ❌ Kättesaamatu |

---

## 6. 🔒 TLS / HTTPS Turvalisuse ja Sertifikaatide Audit (TLS Trust Matrix)
- **Aktiivne TLS Režiim:** `USER_LOCAL_CA`
- **Režiimi Kirjeldus:** Kasutajataseme lokaalne usaldatud CA (0 root/admin õigust)
- **Kasutatav Sertifikaat:** `/Users/allanlahe/Oracle/oracle-free-db-in-prod/config/certs/user_ca/localhost.crt`
- **Lubatud Poliitika Tase:** `permissive`
- **Mitte-Admin Usalduse Olek:** ✅ Usaldatud kasutaja tasemel (`Cert:\CurrentUser\Root` / `login.keychain-db`).

---

## 7. 🔑 SEPS Paroolivabade Oracle Wallet Ühenduste Audit (SEPS Wallet Connection Audit)

> 🛡️ **Turvalisus:** Aruanne ei sisalda avatud kujul ega salvestatud paroole. Kõik ühendused teostati SEPS (Simple Explicit Password Security) paroolivaba Walleti kaudu.

| SEPS Walleti Alias | Ühenduse Staatus | Tuvastatud Kasutaja & Baas |
| :--- | :--- | :--- |
| `DB_PROXY_APP` | ✅ OK | `SYS@FREE` |
| `DB_PROXY_DBA_ADMIN` | ✅ OK | `SYS@FREE` |
| `DB_PROXY_DEV` | ✅ OK | `SYS@FREE` |
| `DB_PROXY_SCHEMA` | ✅ OK | `SYS@FREE` |
| `DB_PROXY_SYS` | ✅ OK | `SYS@FREE` |
| `DB_PROXY_VIEWER` | ✅ OK | `SYS@FREE` |

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
