[ 🇬🇧 English ](../future-plans.md) | [ 🇪🇪 Eesti ](../et/future-plans.md) | [ 🇫🇮 Suomi ](../fi/future-plans.md) | [ 🇸🇪 Svenska ](../sv/future-plans.md) | [ 🇱🇻 Latviešu ](future-plans.md) | [ 🇱🇹 Lietuvių ](../lt/future-plans.md)

# 🛡️ Izstrādes vides paplašināšanas un drošības ceļvedis

> [!NOTE]
> **Nākotnes plāni ir reorganizēti modulārā Backlog sistēmā:**
> Visi atsevišķie uzdevumi, arhitektūra un dzīves cikls atrodas direktorijā **[`backlog/`](../../backlog/README.md)**:
> - 🟢 **Paveiktie uzdevumi:** [`backlog/done/`](../../backlog/done/)
> - 🟡 **Gaidošie / Plānotie uzdevumi:** [`backlog/todo/`](../../backlog/todo/)
> - 📄 **Jauna uzdevuma veidne:** [`backlog/template.md`](../../backlog/template.md)

Šis dokuments apkopo platformas **īstenošanas auditu (Statusa pārbaude)**, realizēto funkcionalitāti, kā arī plānotos drošības uzlabojumus un ražošanas vides prasības.

---

## 📊 KOPSAVILKUMA STATUSA MATRICA (STATUS MATRIX)

| ID | Tēma / Funkcionalitāte | Faktiskais Statuss | Piezīmes |
|---|---|---|---|
| **1.1** | Konteinerizēta Web IDE (`code-server`) | **✅ ĪSTENOTS** | `web-ide` konteiners, OpenJDK 21, SQLcl, VS Code paplašinājumi |
| **1.2** | GitHub Actions & Bezsaistes `act` CI/CD | **✅ ĪSTENOTS** | `scripts/test-local-ci.sh`, `.dbtools/project.config.json` |
| **1.3** | Analytics Publisher (Pixel Perfect) izvietošana | **✅ ĪSTENOTS** | `oracle/analyticsserver:2025`, HTTP 200 OK pārbaudīts |
| **1.4** | VS Code SQL Developer savienojumu reģistrācija | **✅ ĪSTENOTS** | `register-connections.sh`, mapes `/APEX`, `/Publisher`, `/MYATP` |
| **1.5** | Starp-platformu SSL saknes sertifikāta uzticamība | **✅ ĪSTENOTS** | macOS `security`, Windows `certutil`, WSL interop |
| **1.6** | Dinamiskais YAML datubāzes profilu dzinējs | **✅ ĪSTENOTS** | 7 YAML profili, `resolve-topology.sh` topoloģijas risinātājs |
| **1.7** | Automatizētās testēšanas ietvars (Unit & E2E) | **✅ ĪSTENOTS** | `test-all-components.sh`, `test-e2e-system.sh`, vienību testi |
| **2.1** | Noklusējuma rezerves paroļu noņemšana | **✅ ĪSTENOTS** | Visas rezerves paroles noņemtas, iegūtas no SEPS Wallet |
| **2.2** | WebLogic REST & Publisher HTTPS Reverse Proxy | **✅ ĪSTENOTS** | Nginx TLS 1.3 apgrieztais starpniekserveris (`publisher-ssl-proxy.conf`) |
| **3.1** | Resursdatora portu izolācija (`127.0.0.1`) | **✅ ĪSTENOTS** | Porti stingri piesaistīti lokālajai saskarnei (`127.0.0.1`) |
| **3.2** | Rootless konteineru režīms & privilēģiju ierobežošana | **✅ ĪSTENOTS** | Pievienots `--security-opt=no-new-privileges` visiem konteineriem |
| **4.1** | Žurnālfailu noslēpumu un marķieru maskēšana | **✅ ĪSTENOTS** | Skripts `sanitize-logs.sh` maskē paroles un marķierus |
| **1.14** | Reāllaika progress & nebuferēta straumēšana | **✅ ĪSTENOTS** | Opcija C `print_step_progress` & `sed -u` unbuffered filtrs |
| **1.15** | Centralizēta veselības pārbaudes arhitektūra | **✅ ĪSTENOTS** | Viena centralizēta gala pārbaude `test-urls.sh` |
| **1.16** | 4-slāņu izkliedētā uzņēmuma arhitektūra | **✅ ĪSTENOTS** | `publisher-free` + `proxy-gvenzl` + `app-free`, Outbound REST ACL |
| **1.17** | Automātiska versiju noteikšana | **✅ ĪSTENOTS** | Noteikšana tieši no konteinera attēla un manifestiem |
| **1.18** | Uzstādīšanas paātrināšana (APEX DB 15m ➔ 1–2m) | **✅ ĪSTENOTS** | FastStart attēli, Golden Snapshots (~30s), runtime režīms (`TASK-018`) |
| **1.19** | Analytics Publisher & multi-DB paātrināšana | **✅ ĪSTENOTS** | Iepriekš uzbūvēts WebLogic domēna attēls (~45s) (`TASK-019`) |
| **1.20** | Multi-DB SEPS Wallet & TNS sinhronizācija | **✅ ĪSTENOTS** | Atsevišķi SEPS maki un sinhronizēts `tnsnames.ora` (`TASK-027`) |
| **1.21** | VS Code Wallet visu lietotāju sinhronizācija | **✅ ĪSTENOTS** | Profilu shēmu automātiska reģistrācija (`TASK-028`) |
| **1.22** | Oracle Forms 14c konteiners & noVNC atbalsts | **✅ ĪSTENOTS** | Forms 14c izpildvide, HTML5 noVNC Forms Builder (`TASK-029`) |
| **1.23** | Kanoniskie konteineru prefiksu SEPS maki | **✅ ĪSTENOTS** | Formula `DB_${PREFIX}_*` bez fiksētām vērtībām (`TASK-030`) |
| **1.24** | Kompakta termināļa progresa josla | **✅ ĪSTENOTS** | Dinamiski atjaunota TTY rinda (`\r\033[K`), etalonu uzskaite (`TASK-025`) |
| **1.25** | `setup-all.sh` Blueprint saraksta un info CLI | **✅ ĪSTENOTS** | `--list-blueprints` (`-lb`), `--show-blueprint <N>` (`TASK-026`) |
| **2.13** | Plānu reorganizācija uz Backlog | **✅ ĪSTENOTS** | Modulāra struktūra `backlog/todo/` un `backlog/done/` |
| **4.2** | Žurnālu un diagnostikas tīrīšana (`clean-logs.sh`) | **✅ ĪSTENOTS** | Skripts `scripts/clean-logs.sh` izveidots un pārbaudīts (`TASK-008`) |
| **5.1** | Oficiālo uzņēmuma TLS sertifikātu atbalsts | **❌ NAV SĀKTS** | Pašlaik tiek izmantots lokālais pašparakstītais `localCA.pem` |
| **6.1** | OCI Always Free mākoņa izvietošanas tests | **🟡 PROCESĀ** | `deploy-remote.sh` gatavs, gaida mākoņa vides pārbaudi (`TASK-020`) |
| **6.2** | GitHub Actions mākoņa nepārtrauktā piegāde | **🟡 PROCESĀ** | `deploy-remote-cloud.yml` gatavs, gaida noslēpumus (`TASK-020`) |
| **2.8** | Automātisks TDE šifrēšanas atbalsts | **🟡 PROCESĀ** | AES-256 tabulu vietu šifrēšana diskā (`TASK-021`) |
| **2.9** | Tikai lasāma saknes failu sistēma (`--read-only`) | **🟡 PROCESĀ** | Konteineru saknes failu sistēmas bloķēšana un `tmpfs` (`TASK-022`) |
| **2.10** | Centralizēts audita žurnāls & SIEM integrācija | **❌ NAV SĀKTS** | Oracle Unified Auditing politikas un pārsūtītājs (`TASK-023`) |
| **2.11** | WAF & OAuth2 / OIDC Entra-ID REST API | **🟡 PROCESĀ** | Nginx ModSecurity WAF & ORDS OAuth2 aizsardzība (`TASK-024`) |
