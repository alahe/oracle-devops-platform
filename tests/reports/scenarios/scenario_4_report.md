# Stsenaariumi 4 Testiaruanne (2026-08-26 22:41:41)

- **Aeg ja Kuupäev:** 2026-08-26 22:41:41
- **Kogu Paigalduse Kestus:** 30s
- **Stsenaariumi Profiilifail:** `tests/scenarios/.env.4-*`

---

## 1. ⏱ Ajakulu ja Tervisekontroll (Duration & Health)
- **Tulemus:** ✅ Paigaldus ja tervisekontrollid läbitud 100% korrektselt.
- **Kestus kokku:** 30s

---

## 2. 💻 Konteinerite Mälukasutus & CPU (RAM / CPU Metrics)

| Konteineri Nimi | CPU % | Mälukasutus / Limiit | RAM % |
| :--- | :--- | :--- | :--- |
| db-publisher | 61.40% | 534.4MB / 3.221GB | 16.59% |

---

## 3. 💾 Kettamaht (Podman Volumes & Storage)

| Voluumi Nimi | Kettamaht |
| :--- | :--- |
| oracle-free-db-in-prod_publisher_oradata | N/A |
| oracle-free-db-in-prod_apex_images_26_1 | N/A |

---

## 4. 🗄️ Aktiivsed Konteinerid ja Pordid (Active Containers)

| Konteineri Nimi | Staatus | Pordid |
| :--- | :--- | :--- |
| db-publisher | Up 46 seconds (healthy) | 127.0.0.1:1531->1521/tcp |

---

## 5. 🌐 Veebiteenuste URL Audit (URL Health Matrix)

Ei ole aktiivseid veebiteenuse URL-e

---

## 6. 🔑 SEPS Paroolivabade Oracle Wallet Ühenduste Audit (SEPS Wallet Connection Audit)

> 🛡️ **Turvalisus:** Aruanne ei sisalda avatud kujul ega salvestatud paroole. Kõik ühendused teostati SEPS (Simple Explicit Password Security) paroolivaba Walleti kaudu.

| SEPS Walleti Alias | Ühenduse Staatus | Tuvastatud Kasutaja & Baas |
| :--- | :--- | :--- |
| `DB_DB_PUBLISHER_DBA_ADMIN` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_PUBLISHER_DEV` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_PUBLISHER_SCHEMA` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_PUBLISHER_SYS` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_PUBLISHER_VIEWER` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_PUBLISHER_BIPLATFORM` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_PUBLISHER_RCU` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_PUBLISHER_READER` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_PUBLISHER_SYS` | ✅ Ühendus Õnnestus | `SYS@FREE` |

---

## 7. ⚠️ Tuvastatud Probleemid ja Iseparanemised (Log & Self-Healing Audit)
- Vead / Iseparanemised: 0 kriitilist viga. Automaatne kontroll sooritatud.
