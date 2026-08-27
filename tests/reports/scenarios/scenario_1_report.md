# Stsenaariumi 1 Testiaruanne (2026-08-26 19:15:10)

- **Aeg ja Kuupäev:** 2026-08-26 19:15:10
- **Kogu Paigalduse Kestus:** 7m 33s
- **Stsenaariumi Profiilifail:** `tests/scenarios/.env.1-*`

---

## 1. ⏱ Ajakulu ja Tervisekontroll (Duration & Health)
- **Tulemus:** ✅ Paigaldus ja tervisekontrollid läbitud 100% korrektselt.
- **Kestus kokku:** 7m 33s

---

## 2. 💻 Konteinerite Mälukasutus & CPU (RAM / CPU Metrics)

| Konteineri Nimi | CPU % | Mälukasutus / Limiit | RAM % |
| :--- | :--- | :--- | :--- |
| db-lis | 87.34% | 709.8MB / 3.221GB | 22.04% |

---

## 3. 💾 Kettamaht (Podman Volumes & Storage)

| Voluumi Nimi | Kettamaht |
| :--- | :--- |
| oracle-free-db-in-prod_lis_oradata | N/A |
| oracle-free-db-in-prod_apex_images_26_1 | N/A |

---

## 4. 🗄️ Aktiivsed Konteinerid ja Pordid (Active Containers)

| Konteineri Nimi | Staatus | Pordid |
| :--- | :--- | :--- |
| db-lis | Up 7 minutes (healthy) | 127.0.0.1:1533->1521/tcp |

---

## 5. 🌐 Veebiteenuste URL Audit (URL Health Matrix)

Ei ole aktiivseid veebiteenuse URL-e

---

## 6. 🔑 SEPS Paroolivabade Oracle Wallet Ühenduste Audit (SEPS Wallet Connection Audit)

> 🛡️ **Turvalisus:** Aruanne ei sisalda avatud kujul ega salvestatud paroole. Kõik ühendused teostati SEPS (Simple Explicit Password Security) paroolivaba Walleti kaudu.

| SEPS Walleti Alias | Ühenduse Staatus | Tuvastatud Kasutaja & Baas |
| :--- | :--- | :--- |
| `DB_DB_LIS_DBA_ADMIN` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_LIS_DEV` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_LIS_SCHEMA` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_LIS_SYS` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_LIS_VIEWER` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_LIS_APP` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_LIS_SYS` | ✅ Ühendus Õnnestus | `SYS@FREE` |

---

## 7. ⚠️ Tuvastatud Probleemid ja Iseparanemised (Log & Self-Healing Audit)
- Vead / Iseparanemised: 0 kriitilist viga. Automaatne kontroll sooritatud.
