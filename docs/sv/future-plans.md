[ 🇬🇧 English ](../future-plans.md) | [ 🇪🇪 Eesti ](../et/future-plans.md) | [ 🇫🇮 Suomi ](../fi/future-plans.md) | [ 🇸🇪 Svenska ](future-plans.md) | [ 🇱🇻 Latviešu ](../lv/future-plans.md) | [ 🇱🇹 Lietuvių ](../lt/future-plans.md)

# 🛡️ Färdplan och säkerhetsrevision för utvecklingsmiljön

> [!NOTE]
> **Framtidsplaner har omorganiserats till ett modulärt Backlog-system:**
> Alla enskilda uppgifter, arkitektur och livscykelhantering finns nu under **[`backlog/`](../../backlog/README.md)**:
> - 🟢 **Slutförda uppgifter:** [`backlog/done/`](../../backlog/done/)
> - 🟡 **Väntande / Planerade uppgifter:** [`backlog/todo/`](../../backlog/todo/)
> - 📄 **Mall för nya uppgifter:** [`backlog/template.md`](../../backlog/template.md)

Detta dokument sammanställer plattformens **genomföranderevision (Statuskontroll)**, den realiserade funktionaliteten samt planerade säkerhetsförbättringar och produktionskrav.

---

## 📊 SAMMANFATTANDE STATUSMATRIS (STATUS MATRIX)

| ID | Tema / Funktionalitet | Faktisk Status | Anmärkningar |
|---|---|---|---|
| **1.1** | Containeriserad Web IDE (`code-server`) | **✅ SLUTFÖRD** | `web-ide`-container, OpenJDK 21, SQLcl, VS Code-tillägg |
| **1.2** | GitHub Actions & Offline `act` CI/CD | **✅ SLUTFÖRD** | `scripts/test-local-ci.sh`, `.dbtools/project.config.json` |
| **1.3** | Analytics Publisher (Pixel Perfect) driftsättning | **✅ SLUTFÖRD** | `oracle/analyticsserver:2025`, HTTP 200 OK verifierat |
| **1.4** | VS Code SQL Developer automatisk anslutningsregistrering | **✅ SLUTFÖRD** | `register-connections.sh`, mappar `/APEX`, `/Publisher`, `/MYATP` |
| **1.5** | SSL-rotcertifikatsförtroende över plattformar | **✅ SLUTFÖRD** | macOS `security`, Windows `certutil`, WSL interop |
| **1.6** | Dynamisk YAML Databasprofilsmotor | **✅ SLUTFÖRD** | 7 YAML-profiler, `resolve-topology.sh` topologihanterare |
| **1.7** | Automatiserat testramverk (Enhet & E2E) | **✅ SLUTFÖRD** | `test-all-components.sh`, `test-e2e-system.sh`, enhetstester |
| **2.1** | Borttagning av standardreservlösenord | **✅ SLUTFÖRD** | Alla reservlösenord borttagna, hämtas från SEPS Wallet |
| **2.2** | WebLogic REST & Publisher HTTPS Reverse Proxy | **✅ SLUTFÖRD** | Nginx TLS 1.3 reverse proxy (`publisher-ssl-proxy.conf`) |
| **3.1** | Isolering av värdportar (`127.0.0.1`) | **✅ SLUTFÖRD** | Portar strikt bundna till lokalt gränssnitt (`127.0.0.1`) |
| **3.2** | Rootless containerläge & behörighetsbegränsning | **✅ SLUTFÖRD** | Tillagd `--security-opt=no-new-privileges` till alla containrar |
| **4.1** | Maskering av logghemligheter och tokens | **✅ SLUTFÖRD** | Skriptet `sanitize-logs.sh` maskerar lösenord och tokens |
| **1.14** | Universell realtidsframsteg & obuffrad strömning | **✅ SLUTFÖRD** | Hybrid `print_step_progress` & `sed -u` unbuffered filter |
| **1.15** | Centraliserad hälsokontrollsarkitektur | **✅ SLUTFÖRD** | En central slutkontroll `test-urls.sh` |
| **1.16** | 4-skikts distribuerad företagsarkitektur | **✅ SLUTFÖRD** | `publisher-free` + `proxy-gvenzl` + `app-free`, Outbound REST ACLs |
| **1.17** | Automatisk versionsidentifiering | **✅ SLUTFÖRD** | Identifiering direkt från containeravbildning och arkiv |
| **1.18** | Snabbare driftsättning (APEX DB 15m ➔ 1–2m) | **✅ SLUTFÖRD** | FastStart-avbildningar, Golden Snapshots (~30s), runtime-läge (`TASK-018`) |
| **1.19** | Snabbare Analytics Publisher & multidatabas | **✅ SLUTFÖRD** | Förbyggd WebLogic-domänavbildning (~45s) (`TASK-019`) |
| **1.20** | Multidatabas SEPS Wallet & TNS-synkronisering | **✅ SLUTFÖRD** | Separata SEPS Wallets och synkroniserad `tnsnames.ora` (`TASK-027`) |
| **1.21** | VS Code Wallet-synkronisering för alla användare | **✅ SLUTFÖRD** | Automatisk registrering av profilscheman (`TASK-028`) |
| **1.22** | Oracle Forms 14c-container & noVNC-stöd | **✅ SLUTFÖRD** | Forms 14c körmiljö, HTML5 noVNC Forms Builder (`TASK-029`) |
| **1.23** | Kanoniska containerprefix för SEPS Wallets | **✅ SLUTFÖRD** | Formel `DB_${PREFIX}_*` utan hårdkodning (`TASK-030`) |
| **1.24** | Kompakt terminalframstegsfält | **✅ SLUTFÖRD** | In-place TTY-uppdatering (`\r\033[K`), historiska mätvärden (`TASK-025`) |
| **1.25** | `setup-all.sh` Blueprint-listning och info CLI | **✅ SLUTFÖRD** | `--list-blueprints` (`-lb`), `--show-blueprint <N>` (`TASK-026`) |
| **2.13** | Omorganisering av framtidsplaner till Backlog | **✅ SLUTFÖRD** | Modulär struktur `backlog/todo/` och `backlog/done/` |
| **4.2** | Rengöring av loggar och diagnostik (`clean-logs.sh`) | **✅ SLUTFÖRD** | Skriptet `scripts/clean-logs.sh` skapat och verifierat (`TASK-008`) |
| **5.1** | Stöd för officiella företags-TLS-certifikat | **❌ EJ PÅBÖRJAD** | Använder för närvarande lokalt självsignerat `localCA.pem` |
| **6.1** | OCI Always Free molndriftsättningstest | **🟡 PÅGÅR** | `deploy-remote.sh` klar, inväntar molnmiljötest (`TASK-020`) |
| **6.2** | GitHub Actions molnleverans | **🟡 PÅGÅR** | `deploy-remote-cloud.yml` klar, inväntar hemligheter (`TASK-020`) |
| **2.8** | Automatiskt TDE-krypteringsstöd | **🟡 PÅGÅR** | AES-256 tabellutrymmeskryptering på disk (`TASK-021`) |
| **2.9** | Skrivskyddat rotfilsystem (`--read-only`) | **🟡 PÅGÅR** | Låsning av containerns rotfilsystem och `tmpfs` (`TASK-022`) |
| **2.10** | Centraliserad granskningslogg & SIEM-integrering | **❌ EJ PÅBÖRJAD** | Oracle Unified Auditing-policyer och loggvidarebefordrare (`TASK-023`) |
| **2.11** | WAF & OAuth2 / OIDC Entra-ID för REST API:er | **🟡 PÅGÅR** | Nginx ModSecurity WAF & ORDS OAuth2-skydd (`TASK-024`) |
