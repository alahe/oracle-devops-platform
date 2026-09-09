# 📊 Repositooriumi Statistika ja Koodibaasi Mõõdikud

> **Genereeritud:** `2026-09-08 21:22:37` | **Faile kokku:** `1966` | **Koodiridu (LOC):** `250,042`

---

## 1. 💻 Programmeerimiskeelte ja Failitüüpide Jaotus

| Komponent / Keel | Faile | Ridu (LOC) | Osakaal (LOC) |
| :--- | :---: | :---: | :---: |
| **Shell Scripts (.sh, .cmd, .ps1)** | `254` | `40,354` | `16.1%` |
| **Python (.py)** | `21` | `22,229` | `8.9%` |
| **SQL (.sql)** | `10` | `1,451` | `0.6%` |
| **APEXlang DSL (.apx)** | `15` | `696` | `0.3%` |
| **YAML Profiles & Configs (.yaml, .yml)** | `30` | `1,476` | `0.6%` |
| **JSON Data & Metrics (.json)** | `222` | `20,785` | `8.3%` |
| **Markdown Documentation (.md)** | `1307` | `90,388` | `36.1%` |
| **Web Frontend (.html, .js, .css)** | `22` | `72,663` | `29.1%` |
| **KOKKU** | **`1966`** | **`250,042`** | **`100.0%`** |

---

## 2. 🧪 Testimissüsteemi ja Kvaliteedikontrolli Mõõdikud

| Testikategooria | Skripte / Aruandeid | Ridu (LOC) | Kirjeldus |
| :--- | :---: | :---: | :--- |
| **Ühiktestid (`tests/unit/*.sh`)** | `102` | `5,391` | Kiired, isoleeritud testid (profiilid, süntaks, i18n, pariteet) |
| **Integratsioonitestid (`tests/integration/*.sh`)** | `11` | `783` | Mitme komponendi koostöö ja topoloogia testid |
| **Platvormi & E2E Testikomplektid (`tests/*.sh`)** | `19` | `6,788` | Täielikud elutsükli-, brauseri- ja turvaauditid |
| **Aruanded ja Benchmarkid (`tests/reports/`)** | `27` | — | Automatiseeritud Markdown testitulemuste raportid |
| **TESTISKIPTE KOKKU** | **`132`** | **`12,962`** | **Testikaetus üle kogu platvormi** |

---

## 3. 🏗️ Arhitektuursed Blueprindid ja Profiilid

| Ressurss | Kogus | Asukoht | Märkused |
| :--- | :---: | :--- | :--- |
| **Arhitektuurilised Blueprindid** | `12` | `config/blueprints/.env.*` | BP 0 kuni BP 11 (Kanoonilised lahendused) |
| **Andmebaasiprofiilid (DB)** | `11` | `config/profiles/databases/*.yaml` | Oracle 23ai Free, ALISE, Forms, Publisher, ADB, Gvenzl |
| **Vahevara profiilid (Middleware)** | `12` | `config/profiles/{ords,forms,publisher...}` | ORDS, Forms, Publisher, Web-IDE, Designer |
| **Profiile kokku** | **`23`** | `config/profiles/` | 100% deklaratiivne konfiguratsioon |

---

## 4. 🌍 Lokaliseerimise Pariteet (6 Keelt: 🇬🇧 EN, 🇪🇪 ET, 🇫🇮 FI, 🇸🇪 SV, 🇱🇻 LV, 🇱🇹 LT)

| Keel | Lipuke | Dokumente (`.md`) | Dev Hub Sõnastiku Võtmeid |
| :--- | :---: | :---: | :---: |
| **Inglise (Canonical)** | 🇬🇧 `EN` | `960` | `348` |
| **Eesti** | 🇪🇪 `ET` | `72` | `348` |
| **Soome** | 🇫🇮 `FI` | `71` | `348` |
| **Rootsi** | 🇸🇪 `SV` | `68` | `348` |
| **Läti** | 🇱🇻 `LV` | `68` | `348` |
| **Leedu** | 🇱🇹 `LT` | `68` | `348` |

---
