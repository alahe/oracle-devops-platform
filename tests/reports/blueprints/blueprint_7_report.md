# Blueprinti 7 Testiaruanne (2026-08-30 14:06:41)

- **Aeg ja Kuupäev:** 2026-08-30 14:06:41
- **Kogu Paigalduse Kestus:** 2m 1s
- **Blueprinti Fail:** `config/blueprints/.env.7-*`

---

## 1. ⏱ Ajakulu ja Tervisekontroll (Duration & Health)
- **Tulemus:** ✅ Paigaldus ja tervisekontrollid läbitud 100% korrektselt.
- **Kestus kokku:** 2m 1s

---

## 2. 💻 Konteinerite Mälukasutus & CPU (RAM / CPU Metrics)

| Konteineri Nimi | CPU % | Mälukasutus / Limiit | RAM % |
| :--- | :--- | :--- | :--- |
| web-ide-dev | 3.13% | 97.6MB / 8.297GB | 1.18% |
| db-proxy | 22.76% | 682.7MB / 3.221GB | 21.19% |
| db-alise | 13.88% | 538.9MB / 3.221GB | 16.73% |
| app-ords | 75.17% | 578.7MB / 1.074GB | 53.89% |

---

## 3. 💾 Kettamaht (Podman Volumes & Storage)

| Voluumi Nimi | Kettamaht |
| :--- | :--- |
| oracle-free-db-in-prod_web_ide_data | N/A |
| oracle-free-db-in-prod_proxy_oradata | N/A |
| oracle-free-db-in-prod_apex_images_26_1 | N/A |
| oracle-free-db-in-prod_alise_oradata | N/A |

---

## 4. 🗄️ Aktiivsed Konteinerid ja Pordid (Active Containers)

| Konteineri Nimi | Staatus | Pordid |
| :--- | :--- | :--- |
| web-ide-dev | Up 2 minutes (starting) | 0.0.0.0:8090->8443/tcp, 0.0.0.0:8091->8091/tcp, 0.0.0.0:8449->8443/tcp |
| db-proxy | Up 2 minutes (healthy) | 127.0.0.1:1532->1521/tcp |
| db-alise | Up About a minute (healthy) | 127.0.0.1:1534->1521/tcp |
| app-ords | Up About a minute (starting) | 127.0.0.1:8088->8088/tcp, 127.0.0.1:8448->8448/tcp |

---

## 5. 🌐 Veebiteenuste URL Audit (URL Health Matrix)

| Veebiteenuse Nimi | Kontrollitud URL | HTTP Kood | TLS Usaldus | Staatus |
| :--- | :--- | :--- | :--- | :--- |
| ORDS Root HTTP | `http://localhost:8088/ords/` | `HTTP 200` | N/A | ✅ OK |
| Developer Hub (HTTPS) | `https://localhost:8448/dev-hub.html` | `HTTP 200` | ⚠️ Self-Signed | ✅ OK |
| ORDS Root HTTPS | `https://localhost:8448/ords/` | `HTTP 200` | ⚠️ Self-Signed | ✅ OK |
| ORDS Database Actions (Default) | `https://localhost:8448/ords/_/landing` | `HTTP 200` | ⚠️ Self-Signed | ✅ OK |
| APEX Builder (PROXY) | `https://localhost:8448/ords/proxy/r/apex/workspace-sign-in/oracle-apex-sign-in` | `HTTP 302` | ⚠️ Self-Signed | ✅ OK |
| APEX Instance Admin (PROXY) | `https://localhost:8448/ords/proxy/apex_admin` | `HTTP 302` | ⚠️ Self-Signed | ✅ OK |
| ORDS Database Actions (PROXY) | `https://localhost:8448/ords/proxy/_/landing` | `HTTP 200` | ⚠️ Self-Signed | ✅ OK |
| Web IDE (HTTP) | `http://localhost:8090` | `HTTP 200` | N/A | ✅ OK |

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
| `DB_ALISE_DBA_ADMIN` | ℹ️ Skipped | `ALISE profile is not active` |
| `DB_ALISE_DEV` | ℹ️ Skipped | `ALISE profile is not active` |
| `DB_ALISE_SCHEMA` | ℹ️ Skipped | `ALISE profile is not active` |
| `DB_ALISE_SYS` | ℹ️ Skipped | `ALISE profile is not active` |
| `DB_ALISE_VIEWER` | ℹ️ Skipped | `ALISE profile is not active` |
| `DB_INFRA_RCU` | ✅ OK | `SYS@FREE` |
| `DB_INFRA_SYS` | ✅ OK | `SYS@FREEPDB1              ` |
| `DB_PROXY_APP` | ✅ OK | `USER_APP@FREEPDB1         ` |
| `DB_PROXY_DBA_ADMIN` | ✅ OK | `DBA_ADMIN@FREEPDB1        ` |
| `DB_PROXY_DEV` | ✅ OK | `USER_DEVELOPER@FREEPDB1    ` |
| `DB_PROXY_SCHEMA` | ✅ OK | `APEX_PROXY_SCHEMA@FREEPDB1    ` |
| `DB_PROXY_SYS` | ✅ OK | `SYS@FREEPDB1              ` |
| `DB_PROXY_VIEWER` | ✅ OK | `USER_VIEWER@FREEPDB1      ` |
| `DB_PUBLISHER_READER` | ℹ️ Skipped | `Publisher profile is not active` |

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
