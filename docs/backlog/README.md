# 📋 Oracle DevOps Platform — Arendus- ja Arhitektuuri Backlog

See kataloog sisaldab projekti tsentraalset ja modulaarset **Backlog süsteemi**, kus igal funktsionaalsusel, täiendusel ja turvakomponendil on oma eraldiseisev Markdown fail.

---

## 🧭 Backlogi Struktuur ja Elutsükli Reeglid

```text
docs/backlog/
├── README.md               # Backlogi reeglid, elutsükkel ja staatuse koondmaatriks
├── template.md             # Standardne mall uute ülesannete lisamiseks
├── todo/                   # Ootel / kavandamisel / teostamisel olevad ülesanded
└── done/                   # Teostatud, testitud ja valideeritud funktsionaalsused
```

### Elutsükli Reeglid (Workflow):
1. **Uue idee lisamine:** Kopeeri [`template.md`](template.md) fail kausta `todo/` nimega `TASK-XXX-[nimi].md` ja täida vastavad jaotised.
2. **Teostamine:** Kui ülesanne võetakse töösse, märgitakse selle staatus faili päises: `IN_PROGRESS`.
3. **Valmimine ja Arhiveerimine:** Kui kood on realiseeritud, dokumenteeritud ja kõik testid (`tests/unit/`, `tests/integration/`) läbivad 100%, liigutatakse fail kausta `done/` käsuga:
   ```bash
   mv docs/backlog/todo/TASK-XXX-*.md docs/backlog/done/
   ```
4. **Indeksi uuendamine:** Märgi tabelis staatus `✅ REALISEERITUD` ja uuenda viidet.

---

## 📊 KOKKUVÕTLIK STAATUSE MAATRIKS (STATUS MATRIX)

### 🟢 Teostatud ja Valideeritud Funktsionaalsused (`done/`)

| ID | Teema / Funktsionaalsus | Valdkond | Fail | Reaalne Staatus |
| :--- | :--- | :--- | :--- | :--- |
| **001** | Konteineriseeritud Web IDE (`code-server`) | `Tooling` | [`TASK-001-web-ide.md`](done/TASK-001-web-ide.md) | **✅ REALISEERITUD** |
| **002** | GitHub Actions & Offline `act` CI/CD | `Tooling` | [`TASK-002-github-actions-act-cicd.md`](done/TASK-002-github-actions-act-cicd.md) | **✅ REALISEERITUD** |
| **003** | Analytics Publisher (Pixel Perfect) paigaldus | `Architecture` | [`TASK-003-analytics-publisher.md`](done/TASK-003-analytics-publisher.md) | **✅ REALISEERITUD** |
| **004** | VS Code SQL Developer ühenduste automaatne registreering | `Tooling` | [`TASK-004-vscode-connections.md`](done/TASK-004-vscode-connections.md) | **✅ REALISEERITUD** |
| **005** | Ristplatvormne SSL Juursertifikaadi usaldamine (0-admin) | `Security` | [`TASK-005-cross-platform-ssl-trust.md`](done/TASK-005-cross-platform-ssl-trust.md) | **✅ REALISEERITUD** |
| **006** | Dünaamiline YAML Andmebaasi Profiilide Mootor | `Architecture` | [`TASK-006-dynamic-db-profiles.md`](done/TASK-006-dynamic-db-profiles.md) | **✅ REALISEERITUD** |
| **007** | Automaattestimise Raamistik (Unit, E2E, TLS) | `Tooling` | [`TASK-007-automated-testing-suite.md`](done/TASK-007-automated-testing-suite.md) | **✅ REALISEERITUD** |
| **008** | Logide & Diagnostikafailide Puhastamine (`clean-logs.sh`) | `Tooling` | [`TASK-008-clean-logs.md`](done/TASK-008-clean-logs.md) | **✅ REALISEERITUD** |
| **009** | Vaikimisi Varuparoolide Eemaldamine & SEPS Wallet | `Security` | [`TASK-009-remove-default-passwords.md`](done/TASK-009-remove-default-passwords.md) | **✅ REALISEERITUD** |
| **010** | Konteinerite Pordi Isoleerimine (`127.0.0.1`) | `Security` | [`TASK-010-port-isolation-localhost.md`](done/TASK-010-port-isolation-localhost.md) | **✅ REALISEERITUD** |
| **011** | WebLogic REST & Publisher HTTPS Reverse Proxy | `Security` | [`TASK-011-weblogic-reverse-proxy.md`](done/TASK-011-weblogic-reverse-proxy.md) | **✅ REALISEERITUD** |
| **012** | Rootless Konteinerite Režiim & Privileegide Piiramine | `Security` | [`TASK-012-rootless-privilege-limits.md`](done/TASK-012-rootless-privilege-limits.md) | **✅ REALISEERITUD** |
| **013** | Artifactory & Git žetoonide maskeerimine logides | `Security` | [`TASK-013-sanitize-token-logging.md`](done/TASK-013-sanitize-token-logging.md) | **✅ REALISEERITUD** |
| **014** | Universaalne Reaalaegne Progress ja Puhverdamata Väljund | `Tooling` | [`TASK-014-realtime-progress-output.md`](done/TASK-014-realtime-progress-output.md) | **✅ REALISEERITUD** |
| **015** | Viivitatud Tsentraalne Tervisekontrolli Arhitektuur | `Architecture` | [`TASK-015-deferred-health-checks.md`](done/TASK-015-deferred-health-checks.md) | **✅ REALISEERITUD** |
| **016** | LIS Süsteemi Üldine Põhiarhitektuur (4-Kihiline Mudel) | `Architecture` | [`TASK-016-lis-4-tier-architecture.md`](done/TASK-016-lis-4-tier-architecture.md) | **✅ REALISEERITUD** |
| **017** | Automaatne Versiooni Tuvastamine (DB, APEX, ORDS) | `Tooling` | [`TASK-017-auto-version-detection.md`](done/TASK-017-auto-version-detection.md) | **✅ REALISEERITUD** |

---

### 🟡 Ootel ja Kavandatavad Ülesanded (`todo/`)

| ID | Teema / Funktsionaalsus | Valdkond | Fail | Staatus |
| :--- | :--- | :--- | :--- | :--- |
| **018** | Paigalduse Ajakulu Optimeerimine (APEX DB Kiirendus 15m ➔ 1-2m) | `Performance` | [`TASK-018-apex-install-speedup.md`](todo/TASK-018-apex-install-speedup.md) | **🟡 NÕUAB OTSUSTAMIST** |
| **019** | Analytics Publisheri & Multi-DB Paigalduse Kiirendus | `Performance` | [`TASK-019-publisher-speedup.md`](todo/TASK-019-publisher-speedup.md) | **🟡 NÕUAB OTSUSTAMIST** |
| **020** | Oracle Cloud (OCI) Always Free Kaug-Paigalduse Katse | `Orchestration` | [`TASK-020-cloud-oci-deployment.md`](todo/TASK-020-cloud-oci-deployment.md) | **🟡 OSALISELT VALMIS** |
| **021** | Automaatne TDE (Transparent Data Encryption) Tugi | `Security` | [`TASK-021-tde-encryption.md`](todo/TASK-021-tde-encryption.md) | **🟡 OSALISELT VALMIS** |
| **022** | Loetav Juurfailisüsteem ja Hardening (`--read-only`) | `Security` | [`TASK-022-readonly-hardening.md`](todo/TASK-022-readonly-hardening.md) | **🟡 OSALISELT VALMIS** |
| **023** | Keskne Auditilogi ja SIEM Integratsioon (Unified Auditing) | `Security` | [`TASK-023-unified-auditing-siem.md`](todo/TASK-023-unified-auditing-siem.md) | **❌ OOTEL** |
| **024** | WAF & OAuth2 / OIDC Entra-ID Lõiming REST API-dele | `Security` | [`TASK-024-waf-oauth2-entra-id.md`](todo/TASK-024-waf-oauth2-entra-id.md) | **🟡 OSALISELT VALMIS** |
| **025** | Terminali Progressi ja Ajakulu Kompaktne Kuvamine | `Tooling` | [`TASK-025-compact-terminal-ux.md`](todo/TASK-025-compact-terminal-ux.md) | **🟡 DISAIN** |
| **026** | `setup-all.sh` Blueprintide Nimekirja ja Info CLI Parameetrid | `Tooling` | [`TASK-026-blueprint-cli-params.md`](todo/TASK-026-blueprint-cli-params.md) | **🟡 KAVANDATUD** |
