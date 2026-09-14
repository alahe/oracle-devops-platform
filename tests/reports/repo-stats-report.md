# 📊 Repositooriumi Statistika ja Koodibaasi Mõõdikud

> **Genereeritud:** `2026-09-14 08:24:39` | **Faile kokku:** `2189` | **Koodiridu (LOC):** `340,066`

---

## 1. 💻 Programmeerimiskeelte ja Failitüüpide Jaotus

| Komponent / Keel | Faile | Ridu (LOC) | Osakaal (LOC) |
| :--- | :---: | :---: | :---: |
| **Shell Scripts (.sh, .cmd, .ps1)** | `304` | `49,974` | `14.7%` |
| **Python (.py)** | `36` | `32,112` | `9.4%` |
| **SQL (.sql)** | `12` | `1,530` | `0.4%` |
| **APEXlang DSL (.apx)** | `15` | `696` | `0.2%` |
| **YAML Profiles & Configs (.yaml, .yml)** | `33` | `1,839` | `0.5%` |
| **JSON Data & Metrics (.json)** | `225` | `21,422` | `6.3%` |
| **Markdown Documentation (.md)** | `1411` | `104,413` | `30.7%` |
| **Web Frontend (.html, .js, .css)** | `23` | `128,080` | `37.7%` |
| **KOKKU** | **`2189`** | **`340,066`** | **`100.0%`** |

---

## 2. 🧪 Testimissüsteemi ja Kvaliteedikontrolli Mõõdikud

| Testikategooria | Skripte / Aruandeid | Ridu (LOC) | Kirjeldus |
| :--- | :---: | :---: | :--- |
| **Ühiktestid (`tests/unit/*.sh`)** | `127` | `8,803` | Kiired, isoleeritud testid (profiilid, süntaks, i18n, pariteet) |
| **Integratsioonitestid (`tests/integration/*.sh`)** | `16` | `1,936` | Mitme komponendi koostöö ja topoloogia testid |
| **Platvormi & E2E Testikomplektid (`tests/*.sh`)** | `19` | `7,050` | Täielikud elutsükli-, brauseri- ja turvaauditid |
| **Aruanded ja Benchmarkid (`tests/reports/`)** | `29` | — | Automatiseeritud Markdown testitulemuste raportid |
| **TESTISKIPTE KOKKU** | **`162`** | **`17,789`** | **Testikaetus üle kogu platvormi** |

---

## 3. 🏗️ Arhitektuursed Blueprindid ja Profiilid

| Ressurss | Kogus | Asukoht | Märkused |
| :--- | :---: | :--- | :--- |
| **Arhitektuurilised Blueprindid** | `12` | `config/blueprints/.env.*` | BP 0 kuni BP 11 (Kanoonilised lahendused) |
| **Andmebaasiprofiilid (DB)** | `11` | `config/profiles/databases/*.yaml` | Oracle 23ai Free, ALISE, Forms, Publisher, ADB, Gvenzl |
| **Vahevara profiilid (Middleware)** | `13` | `config/profiles/{ords,forms,publisher...}` | ORDS, Forms, Publisher, Web-IDE, Designer |
| **Profiile kokku** | **`24`** | `config/profiles/` | 100% deklaratiivne konfiguratsioon |

---

## 4. 🌍 Lokaliseerimise Pariteet (6 Keelt: 🇬🇧 EN, 🇪🇪 ET, 🇫🇮 FI, 🇸🇪 SV, 🇱🇻 LV, 🇱🇹 LT)

| Keel | Lipuke | Dokumente (`.md`) | Dev Hub Sõnastiku Võtmeid |
| :--- | :---: | :---: | :---: |
| **Inglise (Canonical)** | 🇬🇧 `EN` | `1016` | `708` |
| **Eesti** | 🇪🇪 `ET` | `92` | `708` |
| **Soome** | 🇫🇮 `FI` | `78` | `708` |
| **Rootsi** | 🇸🇪 `SV` | `75` | `708` |
| **Läti** | 🇱🇻 `LV` | `75` | `708` |
| **Leedu** | 🇱🇹 `LT` | `75` | `708` |

---
