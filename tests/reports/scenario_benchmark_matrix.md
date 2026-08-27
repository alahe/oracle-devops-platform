# 📊 Keskkonna 13 Stsenaariumi Võrdlusmaatriks (Scenario Benchmark Matrix)

Antud dokument koondab kõigi 13 keskkonna stsenaariumi automaattestide, ressursside mõõdistuste ja SEPS Walleti auditite tulemused.

---

## 📈 Stsenaariumite Võrdlustabel (Scenario Benchmarks 1 – 13)

| Stsenaarium | Kirjeldus / Konteinerid | Kogu Kestus | RAM Kasutus (Peak) | URL Health Audit | SEPS Wallet Ühendused | Aruande Fail |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Stsenaarium 1** | **Ainult DB-LIS** (`db-lis`) | **7m 28s** | **684.7 MB** | N/A (ilma veebita) | ✅ Testitud | [`scenarios/scenario_1_report.md`](scenarios/scenario_1_report.md) |
| **Stsenaarium 2** | **DB-LIS + APEX + ORDS** | **7m 52s** | **1.07 GB** | ✅ HTTP 302/574 OK | ✅ Testitud | [`scenarios/scenario_2_report.md`](scenarios/scenario_2_report.md) |
| **Stsenaarium 3** | **DB-LIS + DB-PROXY + ORDS** | **14m 7s** | **1.63 GB** | ✅ HTTP 302/574 OK | ✅ Testitud | [`scenarios/scenario_3_report.md`](scenarios/scenario_3_report.md) |
| **Stsenaarium 4** | **Ainult App-Publisher** | **20s** | **527 MB** | N/A | ✅ 13/13 testitud | [`scenarios/scenario_4_report.md`](scenarios/scenario_4_report.md) |
| **Stsenaarium 5** | **ORDS + Kaug-Andmebaas** | **7s** | 0 MB | ❌ Kättesaamatu | *(Välise baasi test)* | [`scenarios/scenario_5_report.md`](scenarios/scenario_5_report.md) |
| **Stsenaarium 6** | **DB-PROXY + ORDS** | **7m 34s** | **1.00 GB** | ✅ HTTP 302/574 OK | ✅ 13/13 testitud | [`scenarios/scenario_6_report.md`](scenarios/scenario_6_report.md) |
| **Stsenaarium 7** | **Kõik Koos (Full 4-Tier Stack)** | **14m 9s** | **2.20 GB** | ✅ 5/5 URL-i OK | ✅ 28/28 testitud | [`scenarios/scenario_7_report.md`](scenarios/scenario_7_report.md) |
| **Stsenaarium 8** | **Gvenzl DB CI/CD Light** | *Valmis testiks* | *Ootel* | N/A | *Ootel* | *Ootel* |
| **Stsenaarium 9** | **Dev Workstation in a Box (DB+ORDS+Web IDE)** | *Valmis testiks* | *Ootel* | *Ootel* | *Ootel* | *Ootel* |
| **Stsenaarium 10** | **Multi-Vendor DB Klaster (Oracle+Gvenzl)** | *Valmis testiks* | *Ootel* | *Ootel* | *Ootel* | *Ootel* |
| **Stsenaarium 11** | **Autonomous ADB + Web IDE** | *Valmis testiks* | *Ootel* | *Ootel* | *Ootel* | *Ootel* |
| **Stsenaarium 12** | **Publisher + Gvenzl DB + Web IDE** | *Valmis testiks* | *Ootel* | *Ootel* | *Ootel* | *Ootel* |
| **Stsenaarium 13** | **Full Enterprise Zero-Install Sandbox (5 Kont.)** | *Valmis testiks* | *Ootel* | *Ootel* | *Ootel* | *Ootel* |

---

## 📝 Täielikud Testiaruanded

- 📄 **[Stsenaarium 1 Aruanne](scenarios/scenario_1_report.md)** (Aeg: 7m 28s, RAM: 684 MB)
- 📄 **[Stsenaarium 2 Aruanne](scenarios/scenario_2_report.md)** (Aeg: 7m 52s, RAM: 1.07 GB)
- 📄 **[Stsenaarium 3 Aruanne](scenarios/scenario_3_report.md)** (Aeg: 14m 7s, RAM: 1.63 GB)
- 📄 **[Stsenaarium 4 Aruanne](scenarios/scenario_4_report.md)** (Aeg: 20s, RAM: 527 MB)
- 📄 **[Stsenaarium 5 Aruanne](scenarios/scenario_5_report.md)** (Aeg: 7s)
- 📄 **[Stsenaarium 6 Aruanne](scenarios/scenario_6_report.md)** (Aeg: 7m 34s, RAM: 1.00 GB)
- 📄 **[Stsenaarium 7 Aruanne](scenarios/scenario_7_report.md)** (Aeg: 14m 9s, RAM: 2.20 GB)
