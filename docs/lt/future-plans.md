[ 🇬🇧 English ](../future-plans.md) | [ 🇪🇪 Eesti ](../et/future-plans.md) | [ 🇫🇮 Suomi ](../fi/future-plans.md) | [ 🇸🇪 Svenska ](../sv/future-plans.md) | [ 🇱🇻 Latviešu ](../lv/future-plans.md) | [ 🇱🇹 Lietuvių ](future-plans.md)

# 🛡️ Kūrimo aplinkos plėtros ir saugumo gairės

> [!NOTE]
> **Ateities planai reorganizuoti į modulinę Backlog sistemą:**
> Visi atskiri uždaviniai, architektūra ir gyvavimo ciklas dabar yra kataloge **[`backlog/`](../../backlog/README.md)**:
> - 🟢 **Atliktos užduotys:** [`backlog/done/`](../../backlog/done/)
> - 🟡 **Laukiančios / Planuojamos užduotys:** [`backlog/todo/`](../../backlog/todo/)
> - 📄 **Naujos užduoties šablonas:** [`backlog/template.md`](../../backlog/template.md)

Šiame dokumente pateikiamas platformos **įgyvendinimo auditas (būsenos patikra)**, realizuotas funkcionalumas bei planuojami saugumo patobulinimai ir gamybinės aplinkos reikalavimai.

---

## 📊 SUVESTINĖ BŪSENOS MATRICA (STATUS MATRIX)

| ID | Tema / Funkcionalumas | Faktinė Būsena | Pastabos |
|---|---|---|---|
| **1.1** | Konteinerizuota Web IDE (`code-server`) | **✅ ĮGYVENDINTA** | `web-ide` konteineris, OpenJDK 21, SQLcl, VS Code plėtiniai |
| **1.2** | GitHub Actions & Autonominis `act` CI/CD | **✅ ĮGYVENDINTA** | `scripts/test-local-ci.sh`, `.dbtools/project.config.json` |
| **1.3** | Analytics Publisher (Pixel Perfect) diegimas | **✅ ĮGYVENDINTA** | `oracle/analyticsserver:2025`, HTTP 200 OK patvirtinta |
| **1.4** | VS Code SQL Developer automatinis jungčių registravimas | **✅ ĮGYVENDINTA** | `register-connections.sh`, aplankai `/APEX`, `/Publisher`, `/MYATP` |
| **1.5** | Kelių platformų SSL šakninio sertifikato pasitikėjimas | **✅ ĮGYVENDINTA** | macOS `security`, Windows `certutil`, WSL interop |
| **1.6** | Dinaminis YAML duomenų bazės profilių variklis | **✅ ĮGYVENDINTA** | 7 YAML profiliai, `resolve-topology.sh` topologijos valdymas |
| **1.7** | Automatizuoto testavimo sistema (Unit & E2E) | **✅ ĮGYVENDINTA** | `test-all-components.sh`, `test-e2e-system.sh`, vienetų testai |
| **2.1** | Numatytųjų atsarginių slaptažodžių pašalinimas | **✅ ĮGYVENDINTA** | Visi atsarginiai slaptažodžiai pašalinti, gaunami iš SEPS Wallet |
| **2.2** | WebLogic REST & Publisher HTTPS Reverse Proxy | **✅ ĮGYVENDINTA** | Nginx TLS 1.3 atvirkštinis proxy (`publisher-ssl-proxy.conf`) |
| **3.1** | Prieglobos prievadų izoliavimas (`127.0.0.1`) | **✅ ĮGYVENDINTA** | Prievadai griežtai susieti su vietine sąsaja (`127.0.0.1`) |
| **3.2** | Rootless konteinerių režimas & teisių apribojimas | **✅ ĮGYVENDINTA** | Pridėta `--security-opt=no-new-privileges` visiems konteineriams |
| **4.1** | Žurnalo paslapčių ir prieigos raktų maskavimas | **✅ ĮGYVENDINTA** | Scenarijus `sanitize-logs.sh` maskuoja slaptažodžius ir raktus |
| **1.14** | Tiesioginė eiga & nebuferizuotas srautas | **✅ ĮGYVENDINTA** | C variantas `print_step_progress` & `sed -u` unbuffered filtras |
| **1.15** | Centralizuota būsenos tikrinimo architektūra | **✅ ĮGYVENDINTA** | Vienas galutinis patikrinimas `test-urls.sh` |
| **1.16** | 4 lygių paskirstyta įmonės architektūra | **✅ ĮGYVENDINTA** | `publisher-free` + `proxy-gvenzl` + `app-free`, Outbound REST ACL |
| **1.17** | Automatinis versijų nustatymas | **✅ ĮGYVENDINTA** | Nustatoma tiesiogiai iš konteinerio atvaizdo ir manifestų |
| **1.18** | Diegimo spartinimas (APEX DB 15m ➔ 1–2m) | **✅ ĮGYVENDINTA** | FastStart atvaizdai, Golden Snapshots (~30s), runtime režimas (`TASK-018`) |
| **1.19** | Analytics Publisher & kelių DB spartinimas | **✅ ĮGYVENDINTA** | Iš anksto sukonstruotas WebLogic domeno atvaizdas (~45s) (`TASK-019`) |
| **1.20** | Kelių DB SEPS Wallet & TNS sinchronizavimas | **✅ ĮGYVENDINTA** | Atskiros SEPS piniginės ir sinchronizuotas `tnsnames.ora` (`TASK-027`) |
| **1.21** | VS Code Wallet visų naudotojų sinchronizavimas | **✅ ĮGYVENDINTA** | Automatinis profilių schemų registravimas (`TASK-028`) |
| **1.22** | Oracle Forms 14c konteineris & noVNC palaikymas | **✅ ĮGYVENDINTA** | Forms 14c vykdymo aplinka, HTML5 noVNC Forms Builder (`TASK-029`) |
| **1.23** | Kanoniniai konteinerių prefiksų SEPS maki | **✅ ĮGYVENDINTA** | Formulė `DB_${PREFIX}_*` be fiksuotų reikšmių (`TASK-030`) |
| **1.24** | Kompaktiška terminalo eigos juosta | **✅ ĮGYVENDINTA** | Vietoje atnaujinama TTY eilutė (`\r\033[K`), etalonai (`TASK-025`) |
| **1.25** | `setup-all.sh` Blueprint sąrašas ir info CLI | **✅ ĮGYVENDINTA** | `--list-blueprints` (`-lb`), `--show-blueprint <N>` (`TASK-026`) |
| **2.13** | Planų pertvarkymas į Backlog sistemą | **✅ ĮGYVENDINTA** | Modulinė struktūra `backlog/todo/` ir `backlog/done/` |
| **4.2** | Žurnalų ir diagnostikos valymas (`clean-logs.sh`) | **✅ ĮGYVENDINTA** | Scenarijus `scripts/clean-logs.sh` sukurtas ir patikrintas (`TASK-008`) |
| **5.1** | Oficialių įmonės TLS sertifikatų palaikymas | **❌ NEPRADĖTA** | Šiuo metu naudojamas vietinis savarankiškai pasirašytas `localCA.pem` |
| **6.1** | OCI Always Free debesijos diegimo bandymas | **🟡 VYKDOMA** | `deploy-remote.sh` parengtas, laukia debesijos aplinkos testo (`TASK-020`) |
| **6.2** | GitHub Actions debesijos nuolatinis pristatymas | **🟡 VYKDOMA** | `deploy-remote-cloud.yml` parengtas, laukia paslapčių (`TASK-020`) |
| **2.8** | Automatinis TDE šifravimo palaikymas | **🟡 VYKDOMA** | AES-256 lentelių sričių šifravimas diske (`TASK-021`) |
| **2.9** | Tik skaitoma šakninė failų sistema (`--read-only`) | **🟡 VYKDOMA** | Konteinerių šakninės failų sistemos užrakinimas ir `tmpfs` (`TASK-022`) |
| **2.10** | Centralizuotas audito žurnalas & SIEM integracija | **❌ NEPRADĖTA** | Oracle Unified Auditing taisyklės ir persiuntėjas (`TASK-023`) |
| **2.11** | WAF & OAuth2 / OIDC Entra-ID REST API | **🟡 VYKDOMA** | Nginx ModSecurity WAF & ORDS OAuth2 apsauga (`TASK-024`) |
