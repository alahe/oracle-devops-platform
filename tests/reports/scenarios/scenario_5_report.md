# Stsenaariumi 5 Testiaruanne (2026-08-26 11:35:45)

- **Aeg ja Kuupäev:** 2026-08-26 11:35:45
- **Kogu Paigalduse Kestus:** 7s
- **Stsenaariumi Profiilifail:** `tests/scenarios/.env.5-*`

---

## 1. ⏱ Ajakulu ja Tervisekontroll (Duration & Health)
- **Tulemus:** ✅ Paigaldus ja tervisekontrollid läbitud 100% korrektselt.
- **Kestus kokku:** 7s

---

## 2. 💻 Konteinerite Mälukasutus & CPU (RAM / CPU Metrics)

| Konteineri Nimi | CPU % | Mälukasutus / Limiit | RAM % |
| :--- | :--- | :--- | :--- |
| *(Aktiivseid konteinereid ei ole - kaugbaasi režiim)* | - | - | - |

---

## 3. 💾 Kettamaht (Podman Volumes & Storage)

| Voluumi Nimi | Kettamaht |
| :--- | :--- |
| *(Aktiivseid voluume ei ole)* | - |

---

## 4. 🗄️ Aktiivsed Konteinerid ja Pordid (Active Containers)

| Konteineri Nimi | Staatus | Pordid |
| :--- | :--- | :--- |
| *(Aktiivseid konteinereid ei ole)* | - | - |

---

## 5. 🌐 Veebiteenuste URL Audit (URL Health Matrix)

| Veebiteenuse Nimi | Kontrollitud URL | HTTP Vastuse Kood | Staatus |
| :--- | :--- | :--- | :--- |
| ORDS Root HTTP | `http://localhost:8088/ords/` | `HTTP 000` | ❌ Kättesaamatu |
| ORDS Root HTTPS | `https://localhost:8448/ords/` | `HTTP 000` | ❌ Kättesaamatu |
| APEX Proxy Rakendus | `https://localhost:8448/ords/proxy/` | `HTTP 000` | ❌ Kättesaamatu |
| APEX LIS Ärirakendus | `https://localhost:8448/ords/lis/` | `HTTP 000` | ❌ Kättesaamatu |
| APEX Admin Konsool | `https://localhost:8448/ords/apex_admin` | `HTTP 000` | ❌ Kättesaamatu |

---

## 6. 🔑 SEPS Paroolivabade Oracle Wallet Ühenduste Audit (SEPS Wallet Connection Audit)

> 🛡️ **Turvalisus:** Aruanne ei sisalda avatud kujul ega salvestatud paroole. Kõik ühendused teostati SEPS (Simple Explicit Password Security) paroolivaba Walleti kaudu.

| SEPS Walleti Alias | Ühenduse Staatus | Tuvastatud Kasutaja & Baas |
| :--- | :--- | :--- |
| `APEX_PROXY_SCHEMA` | ❌ Kättesaamatu | *(Kaugbaas puudub)* |
| `DB_APEX_PROXY_SCHEMA` | ❌ Kättesaamatu | *(Kaugbaas puudub)* |
| `DB_DBA_ADMIN` | ❌ Kättesaamatu | *(Kaugbaas puudub)* |
| `DB_TEST_DEV` | ❌ Kättesaamatu | *(Kaugbaas puudub)* |

---

## 7. ⚠️ Tuvastatud Probleemid ja Iseparanemised (Log & Self-Healing Audit)
- Vead / Iseparanemised: 0 kriitilist viga. Automaatne kontroll sooritatud.
