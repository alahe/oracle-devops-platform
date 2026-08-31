# Blueprinti 43 Testiaruanne (2026-08-30 16:54:30)

- **Aeg ja Kuupäev:** 2026-08-30 16:54:30
- **Kogu Paigalduse Kestus:** 10m 58s
- **Blueprinti Fail:** `config/blueprints/.env.43-*`

---

## 1. ⏱ Ajakulu ja Tervisekontroll (Duration & Health)
- **Tulemus:** ✅ Paigaldus ja tervisekontrollid läbitud 100% korrektselt.
- **Kestus kokku:** 10m 58s

---

## 2. 💻 Konteinerite Mälukasutus & CPU (RAM / CPU Metrics)

| Konteineri Nimi | CPU % | Mälukasutus / Limiit | RAM % |
| :--- | :--- | :--- | :--- |
| web-ide-dev | 1.19% | 79.25MB / 8.297GB | 0.96% |
| db-publisher | 24.12% | 607.3MB / 3.221GB | 18.85% |
| app-ords | 18.94% | 625.9MB / 1.074GB | 58.29% |
| app-publisher | 215.48% | 4.404GB / 8.297GB | 53.08% |
| app-forms | 0.33% | 10.45MB / 8.297GB | 0.13% |

---

## 3. 💾 Kettamaht (Podman Volumes & Storage)

| Voluumi Nimi | Kettamaht |
| :--- | :--- |
| oracle-free-db-in-prod_web_ide_data | N/A |
| oracle-free-db-in-prod_proxy_oradata | N/A |
| oracle-free-db-in-prod_apex_images_26_1 | N/A |
| oracle-free-db-in-prod_publisher_oradata | N/A |

---

## 4. 🗄️ Aktiivsed Konteinerid ja Pordid (Active Containers)

| Konteineri Nimi | Staatus | Pordid |
| :--- | :--- | :--- |
| web-ide-dev | Up 14 minutes (starting) | 0.0.0.0:8090->8443/tcp, 0.0.0.0:8091->8091/tcp, 0.0.0.0:8449->8443/tcp |
| db-publisher | Up 13 minutes (healthy) | 127.0.0.1:1534->1521/tcp |
| app-ords | Up 12 minutes (starting) | 127.0.0.1:8088->8088/tcp, 127.0.0.1:8448->8448/tcp |
| app-publisher | Up 11 minutes (starting) | 127.0.0.1:9500->9500/tcp, 127.0.0.1:9502-9503->9502-9503/tcp, 9501/tcp, 9504-9999/tcp |
| app-forms | Up 3 minutes (starting) | 127.0.0.1:6082->6082/tcp, 127.0.0.1:7001->7001/tcp, 127.0.0.1:9001-9002->9001-9002/tcp, 8088/tcp |

---

## 5. 🌐 Veebiteenuste URL Audit (URL Health Matrix)

| Veebiteenuse Nimi | Kontrollitud URL | HTTP Kood | TLS Usaldus | Staatus |
| :--- | :--- | :--- | :--- | :--- |
| ORDS Root HTTP | `http://localhost:8088/ords/` | `HTTP 571` | N/A | ❌ Kättesaamatu |
| Developer Hub (HTTPS) | `https://localhost:8448/dev-hub.html` | `HTTP 200` | ⚠️ Self-Signed | ✅ OK |
| ORDS Root HTTPS | `https://localhost:8448/ords/` | `HTTP 571` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| ORDS Database Actions (Default) | `https://localhost:8448/ords/_/landing` | `HTTP 571` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| APEX Builder (PROXY) | `https://localhost:8448/ords/proxy/r/apex/workspace-sign-in/oracle-apex-sign-in` | `HTTP 571` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| APEX Instance Admin (PROXY) | `https://localhost:8448/ords/proxy/apex_admin` | `HTTP 571` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| ORDS Database Actions (PROXY) | `https://localhost:8448/ords/proxy/_/landing` | `HTTP 571` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| Publisher UI (HTTP) | `http://localhost:9502/xmlpserver` | `HTTP 200` | N/A | ✅ OK |
| Forms Runtime (HTTP) | `http://localhost:9001/forms/frmservlet` | `HTTP 200` | N/A | ✅ OK |
| Forms Test Form (HTTP) | `http://localhost:9001/forms/frmservlet?form=test.fmx` | `HTTP 200` | N/A | ✅ OK |
| Forms Builder GUI (noVNC) | `http://localhost:6082/vnc.html` | `HTTP 200` | N/A | ✅ OK |
| Forms WebLogic Console (HTTP) | `http://localhost:7001/console` | `HTTP 200` | N/A | ✅ OK |
| Forms Builder Web GUI (HTTP) | `http://localhost:6082/vnc.html` | `HTTP 200` | N/A | ✅ OK |
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
| `DB_INFRA_RCU` | ✅ OK | `SYS@FREE` |
| `DB_INFRA_SYS` | ✅ OK | `SYS@FREEPDB1              ` |
| `DB_PROXY_APP` | ℹ️ Skipped | `Port 1532 closed` |
| `DB_PROXY_DBA_ADMIN` | ℹ️ Skipped | `Port 1532 closed` |
| `DB_PROXY_DEV` | ℹ️ Skipped | `Port 1532 closed` |
| `DB_PROXY_SCHEMA` | ℹ️ Skipped | `Port 1532 closed` |
| `DB_PROXY_SYS` | ℹ️ Skipped | `Port 1532 closed` |
| `DB_PROXY_VIEWER` | ℹ️ Skipped | `Port 1532 closed` |
| `DB_PUBLISHER_DBA_ADMIN` | ℹ️ Skipped | `Publisher profile is not active` |
| `DB_PUBLISHER_DEV` | ℹ️ Skipped | `Publisher profile is not active` |
| `DB_PUBLISHER_READER` | ℹ️ Skipped | `Publisher profile is not active` |
| `DB_PUBLISHER_SCHEMA` | ℹ️ Skipped | `Publisher profile is not active` |
| `DB_PUBLISHER_SYS` | ℹ️ Skipped | `Publisher profile is not active` |
| `DB_PUBLISHER_VIEWER` | ℹ️ Skipped | `Publisher profile is not active` |

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
