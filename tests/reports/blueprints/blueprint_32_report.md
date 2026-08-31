# Blueprinti 32 Testiaruanne (2026-08-30 15:37:08)

- **Aeg ja Kuupäev:** 2026-08-30 15:37:08
- **Kogu Paigalduse Kestus:** 9m 24s
- **Blueprinti Fail:** `config/blueprints/.env.32-*`

---

## 1. ⏱ Ajakulu ja Tervisekontroll (Duration & Health)
- **Tulemus:** ✅ Paigaldus ja tervisekontrollid läbitud 100% korrektselt.
- **Kestus kokku:** 9m 24s

---

## 2. 💻 Konteinerite Mälukasutus & CPU (RAM / CPU Metrics)

| Konteineri Nimi | CPU % | Mälukasutus / Limiit | RAM % |
| :--- | :--- | :--- | :--- |
| web-ide-dev | 1.06% | 77.35MB / 8.297GB | 0.93% |
| db-publisher | 14.57% | 621.6MB / 3.221GB | 19.30% |
| app-publisher | 232.24% | 4.67GB / 8.297GB | 56.28% |

---

## 3. 💾 Kettamaht (Podman Volumes & Storage)

| Voluumi Nimi | Kettamaht |
| :--- | :--- |
| oracle-free-db-in-prod_web_ide_data | N/A |
| oracle-free-db-in-prod_publisher_oradata | N/A |
| oracle-free-db-in-prod_apex_images_26_1 | N/A |

---

## 4. 🗄️ Aktiivsed Konteinerid ja Pordid (Active Containers)

| Konteineri Nimi | Staatus | Pordid |
| :--- | :--- | :--- |
| web-ide-dev | Up 9 minutes (starting) | 0.0.0.0:8090->8443/tcp, 0.0.0.0:8091->8091/tcp, 0.0.0.0:8449->8443/tcp |
| db-publisher | Up 9 minutes (healthy) | 127.0.0.1:1531->1521/tcp |
| app-publisher | Up 7 minutes (starting) | 127.0.0.1:9500->9500/tcp, 127.0.0.1:9502-9503->9502-9503/tcp, 9501/tcp, 9504-9999/tcp |

---

## 5. 🌐 Veebiteenuste URL Audit (URL Health Matrix)

| Veebiteenuse Nimi | Kontrollitud URL | HTTP Kood | TLS Usaldus | Staatus |
| :--- | :--- | :--- | :--- | :--- |
| Publisher UI (HTTP) | `http://localhost:9502/xmlpserver` | `HTTP 200` | N/A | ✅ OK |
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
| `DB_PUBLISHER_BIPLATFORM` | ✅ OK | `SYS@FREE` |
| `DB_PUBLISHER_DBA_ADMIN` | ✅ OK | `DBA_ADMIN@FREEPDB1        ` |
| `DB_PUBLISHER_DEV` | ✅ OK | `USER_DEVELOPER@FREEPDB1    ` |
| `DB_PUBLISHER_RCU` | ✅ OK | `SYS@FREE` |
| `DB_PUBLISHER_READER` | ✅ OK | `SYS@FREE` |
| `DB_PUBLISHER_SCHEMA` | ✅ OK | `APEX_PROXY_SCHEMA@FREEPDB1    ` |
| `DB_PUBLISHER_SYS` | ✅ OK | `SYS@FREEPDB1              ` |
| `DB_PUBLISHER_VIEWER` | ✅ OK | `USER_VIEWER@FREEPDB1      ` |

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
