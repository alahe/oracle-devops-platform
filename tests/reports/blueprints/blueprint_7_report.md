# Blueprinti 7 Testiaruanne (2026-09-04 00:34:40)

- **Aeg ja Kuupäev:** 2026-09-04 00:34:40
- **Kogu Paigalduse Kestus:** 11m 0s
- **Blueprinti Fail:** `config/blueprints/.env.7-*`

---

## 1. ⏱ Ajakulu ja Tervisekontroll (Duration & Health)
- **Tulemus:** ✅ Paigaldus ja tervisekontrollid läbitud 100% korrektselt.
- **Kestus kokku:** 11m 0s

---

## 2. 💻 Konteinerite Mälukasutus & CPU (RAM / CPU Metrics)

| Konteineri Nimi | CPU % | Mälukasutus / Limiit | RAM % |
| :--- | :--- | :--- | :--- |
| db-publisher | 27.83% | 547.2MB / 3.221GB | 16.99% |
| app-publisher | 192.54% | 4.693GB / 12.5GB | 37.53% |

---

## 3. 💾 Kettamaht (Podman Volumes & Storage)

| Voluumi Nimi | Kettamaht |
| :--- | :--- |
| oracle-free-db-in-prod_publisher_data | N/A |
| oracle-free-db-in-prod_publisher_oradata | N/A |
| oracle-free-db-in-prod_apex_images_26_1 | N/A |

---

## 4. 🗄️ Aktiivsed Konteinerid ja Pordid (Active Containers)

| Konteineri Nimi | Staatus | Pordid |
| :--- | :--- | :--- |
| db-publisher | Up About a minute (healthy) | 0.0.0.0:1531->1521/tcp |
| app-publisher | Up 9 minutes (starting) | 127.0.0.1:9500->9500/tcp, 127.0.0.1:9502-9503->9502-9503/tcp, 9501/tcp, 9504-9999/tcp |

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
| `DB_DB_PUBLISHER_APP` | ✅ OK | `SYS@FREE` |
| `DB_DB_PUBLISHER_DBA_ADMIN` | ✅ OK | `SYS@FREE` |
| `DB_DB_PUBLISHER_DEV` | ✅ OK | `SYS@FREE` |
| `DB_DB_PUBLISHER_SCHEMA` | ✅ OK | `SYS@FREE` |
| `DB_DB_PUBLISHER_SYS` | ✅ OK | `SYS@FREE` |
| `DB_DB_PUBLISHER_VIEWER` | ✅ OK | `SYS@FREE` |
| `DB_PUBLISHER_DBA_ADMIN` | ✅ OK | `DBA_ADMIN@FREEPDB1        ` |
| `DB_PUBLISHER_DEV` | ✅ OK | `USER_DEVELOPER@FREEPDB1    ` |
| `DB_PUBLISHER_SCHEMA` | ✅ OK | `SYS@FREE` |
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
