# Blueprinti 20 Testiaruanne (2026-08-30 15:05:10)

- **Aeg ja Kuupäev:** 2026-08-30 15:05:10
- **Kogu Paigalduse Kestus:** 1m 14s
- **Blueprinti Fail:** `config/blueprints/.env.20-*`

---

## 1. ⏱ Ajakulu ja Tervisekontroll (Duration & Health)
- **Tulemus:** ✅ Paigaldus ja tervisekontrollid läbitud 100% korrektselt.
- **Kestus kokku:** 1m 14s

---

## 2. 💻 Konteinerite Mälukasutus & CPU (RAM / CPU Metrics)

| Konteineri Nimi | CPU % | Mälukasutus / Limiit | RAM % |
| :--- | :--- | :--- | :--- |
| web-ide-dev | 4.86% | 90.32MB / 8.297GB | 1.09% |
| db-forms | 27.44% | 607.9MB / 3.221GB | 18.87% |
| app-forms | 0.38% | 9.97MB / 8.297GB | 0.12% |

---

## 3. 💾 Kettamaht (Podman Volumes & Storage)

| Voluumi Nimi | Kettamaht |
| :--- | :--- |
| oracle-free-db-in-prod_web_ide_data | N/A |
| oracle-free-db-in-prod_forms_oradata | N/A |
| oracle-free-db-in-prod_apex_images_26_1 | N/A |

---

## 4. 🗄️ Aktiivsed Konteinerid ja Pordid (Active Containers)

| Konteineri Nimi | Staatus | Pordid |
| :--- | :--- | :--- |
| web-ide-dev | Up About a minute (starting) | 0.0.0.0:8090->8443/tcp, 0.0.0.0:8091->8091/tcp, 0.0.0.0:8449->8443/tcp |
| db-forms | Up About a minute (healthy) | 127.0.0.1:1534->1521/tcp |
| app-forms | Up 29 seconds (starting) | 127.0.0.1:6082->6082/tcp, 127.0.0.1:7001->7001/tcp, 127.0.0.1:9001-9002->9001-9002/tcp, 8088/tcp |

---

## 5. 🌐 Veebiteenuste URL Audit (URL Health Matrix)

| Veebiteenuse Nimi | Kontrollitud URL | HTTP Kood | TLS Usaldus | Staatus |
| :--- | :--- | :--- | :--- | :--- |
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
| `DB_FORMS_APP` | ✅ OK | `USER_APP@FREEPDB1         ` |
| `DB_FORMS_DBA_ADMIN` | ✅ OK | `DBA_ADMIN@FREEPDB1        ` |
| `DB_FORMS_DEV` | ✅ OK | `USER_DEVELOPER@FREEPDB1    ` |
| `DB_FORMS_SCHEMA` | ✅ OK | `APEX_PROXY_SCHEMA@FREEPDB1    ` |
| `DB_FORMS_SYS` | ✅ OK | `SYS@FREEPDB1              ` |
| `DB_FORMS_VIEWER` | ✅ OK | `USER_VIEWER@FREEPDB1      ` |

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
