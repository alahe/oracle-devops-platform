# 📊 Keskkonna 13 Blueprinti Võrdlusmaatriks (Blueprint Benchmark Matrix)

Antud dokument koondab kõigi 13 keskkonna blueprinti automaattestide, ressursside mõõdistuste ja SEPS Walleti auditite tulemused.

---

## 📈 Blueprintide Võrdlustabel (Blueprint Benchmarks 1 – 13)

| Blueprint | Kirjeldus / Konteinerid | Kogu Kestus | RAM Kasutus (Peak) | URL Health Audit | SEPS Wallet Ühendused | Aruande Fail |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Blueprint 1** | **Ainult DB-LIS** (`db-alise`) | **7m 28s** | **684.7 MB** | N/A (ilma veebita) | ✅ Testitud | [`blueprints/blueprint_1_report.md`](blueprints/blueprint_1_report.md) |
| **Blueprint 2** | **DB-LIS + APEX + ORDS** | **7m 52s** | **1.07 GB** | ✅ HTTP 302/574 OK | ✅ Testitud | [`blueprints/blueprint_2_report.md`](blueprints/blueprint_2_report.md) |
| **Blueprint 3** | **DB-LIS + DB-PROXY + ORDS** | **14m 7s** | **1.63 GB** | ✅ HTTP 302/574 OK | ✅ Testitud | [`blueprints/blueprint_3_report.md`](blueprints/blueprint_3_report.md) |
| **Blueprint 4** | **Ainult App-Publisher** | **20s** | **527 MB** | N/A | ✅ 13/13 testitud | [`blueprints/blueprint_4_report.md`](blueprints/blueprint_4_report.md) |
| **Blueprint 5** | **ORDS + Kaug-Andmebaas** | **7s** | 0 MB | ❌ Kättesaamatu | *(Välise baasi test)* | [`blueprints/blueprint_5_report.md`](blueprints/blueprint_5_report.md) |
| **Blueprint 6** | **DB-PROXY + ORDS** | **7m 34s** | **1.00 GB** | ✅ HTTP 302/574 OK | ✅ 13/13 testitud | [`blueprints/blueprint_6_report.md`](blueprints/blueprint_6_report.md) |
| **Blueprint 7** | **Kõik Koos (Full 4-Tier Stack)** | **14m 9s** | **2.20 GB** | ✅ 5/5 URL-i OK | ✅ 28/28 testitud | [`blueprints/blueprint_7_report.md`](blueprints/blueprint_7_report.md) |
| **Blueprint 8** | **Gvenzl DB CI/CD Light** | *Valmis testiks* | *Ootel* | N/A | *Ootel* | *Ootel* |
| **Blueprint 9** | **Dev Workstation in a Box (DB+ORDS+Web IDE)** | *Valmis testiks* | *Ootel* | *Ootel* | *Ootel* | *Ootel* |
| **Blueprint 10** | **Multi-Vendor DB Klaster (Oracle+Gvenzl)** | *Valmis testiks* | *Ootel* | *Ootel* | *Ootel* | *Ootel* |
| **Blueprint 11** | **Autonomous ADB + Web IDE** | *Valmis testiks* | *Ootel* | *Ootel* | *Ootel* | *Ootel* |
| **Blueprint 12** | **Publisher + Gvenzl DB + Web IDE** | *Valmis testiks* | *Ootel* | *Ootel* | *Ootel* | *Ootel* |
| **Blueprint 13** | **Full Enterprise Zero-Install Sandbox (5 Kont.)** | *Valmis testiks* | *Ootel* | *Ootel* | *Ootel* | *Ootel* |

---

## 📝 Täielikud Testiaruanded

- 📄 **[Blueprint 1 Aruanne](blueprints/blueprint_1_report.md)** (Aeg: 7m 28s, RAM: 684 MB)
- 📄 **[Blueprint 2 Aruanne](blueprints/blueprint_2_report.md)** (Aeg: 7m 52s, RAM: 1.07 GB)
- 📄 **[Blueprint 3 Aruanne](blueprints/blueprint_3_report.md)** (Aeg: 14m 7s, RAM: 1.63 GB)
- 📄 **[Blueprint 4 Aruanne](blueprints/blueprint_4_report.md)** (Aeg: 20s, RAM: 527 MB)
- 📄 **[Blueprint 5 Aruanne](blueprints/blueprint_5_report.md)** (Aeg: 7s)
- 📄 **[Blueprint 6 Aruanne](blueprints/blueprint_6_report.md)** (Aeg: 7m 34s, RAM: 1.00 GB)
- 📄 **[Blueprint 7 Aruanne](blueprints/blueprint_7_report.md)** (Aeg: 14m 9s, RAM: 2.20 GB)
- 📄 **[Koondaruanne (Kõik Blueprintid)](blueprints/all_blueprints_summary.md)**
