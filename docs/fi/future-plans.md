[ 🇬🇧 English ](../future-plans.md) | [ 🇪🇪 Eesti ](../et/future-plans.md) | [ 🇫🇮 Suomi ](future-plans.md) | [ 🇸🇪 Svenska ](../sv/future-plans.md) | [ 🇱🇻 Latviešu ](../lv/future-plans.md) | [ 🇱🇹 Lietuvių ](../lt/future-plans.md)

# 🛡️ Kehitysympäristön laajennus- ja tietoturvasuunnitelma

> [!NOTE]
> **Tulevaisuudensuunnitelmat on organisoitu modulaariseksi Backlog-järjestelmäksi:**
> Yksittäiset tehtävät ja elinkaari sijaitsevat hakemistossa **[`backlog/`](../../backlog/README.md)**:
> - 🟢 **Toteutetut tehtävät:** [`backlog/done/`](../../backlog/done/)
> - 🟡 **Odottaa / Suunnitteilla:** [`backlog/todo/`](../../backlog/todo/)
> - 📄 **Uuden tehtävän malli:** [`backlog/template.md`](../../backlog/template.md)

Tämä asiakirja kokoaa yhteen alustan **toteutusauditoinnin (tilannekatsaus)**, toteutetut ominaisuudet sekä suunnitellut tietoturvaparannukset ja tuotantovaatimukset.

---

## 📊 KOKOAVA TILANNEMATRIISI (STATUS MATRIX)

| ID | Teema / Ominaisuus | Todellinen Tila | Huomautukset |
|---|---|---|---|
| **1.1** | Kontitettu Web IDE (`code-server`) | **✅ TOTEUTETTU** | `web-ide`-kontti, OpenJDK 21, SQLcl, VS Code -laajennukset |
| **1.2** | GitHub Actions & Offline `act` CI/CD | **✅ TOTEUTETTU** | `scripts/test-local-ci.sh`, `.dbtools/project.config.json` |
| **1.3** | Analytics Publisher (Pixel Perfect) asennus | **✅ TOTEUTETTU** | `oracle/analyticsserver:2025`, HTTP 200 OK varmistettu |
| **1.4** | VS Code SQL Developer -yhteyksien rekisteröinti | **✅ TOTEUTETTU** | `register-connections.sh`, kansiot `/APEX`, `/Publisher`, `/MYATP` |
| **1.5** | SSL-juurivarmenteen monialustainen luottamus | **✅ TOTEUTETTU** | macOS `security`, Windows `certutil`, WSL interop |
| **1.6** | Dynaaminen YAML-tietokantaprofiilimoottori | **✅ TOTEUTETTU** | 7 YAML-profiilia, `resolve-topology.sh` topologian ratkaisija |
| **1.7** | Automaattitestauskehys (Yksikkö & E2E) | **✅ TOTEUTETTU** | `test-all-components.sh`, `test-e2e-system.sh`, yksikkötestit |
| **2.1** | Oletusvarasalasanojen poistaminen | **✅ TOTEUTETTU** | Kaikki varasalasanat poistettu skripteistä, haetaan SEPS Walletista |
| **2.2** | WebLogic REST & Publisher HTTPS Reverse Proxy | **✅ TOTEUTETTU** | Nginx TLS 1.3 reverse proxy (`publisher-ssl-proxy.conf`) |
| **3.1** | Isäntäporttien eristäminen (`127.0.0.1`) | **✅ TOTEUTETTU** | Portit sidottu tiukasti paikalliseen liitäntään (`127.0.0.1`) |
| **3.2** | Rootless-konttitila & oikeuksien rajoitus | **✅ TOTEUTETTU** | Lisätty `--security-opt=no-new-privileges` kaikkiin kontteihin |
| **4.1** | Lokisalaisuuksien ja tunnisteiden maskaus | **✅ TOTEUTETTU** | Skripti `sanitize-logs.sh` maskaa salasanat ja tunnisteet |
| **1.14** | Reaaliaikainen edistyminen ja puskuroimaton tuloste | **✅ TOTEUTETTU** | Option C `print_step_progress` & `sed -u` unbuffered filter |
| **1.15** | Keskitetty terveystarkastusarkkitehtuuri | **✅ TOTEUTETTU** | Yksi keskitetty lopputarkistus `test-urls.sh` |
| **1.16** | 4-kerroksinen hajautettu yritysarkkitehtuuri | **✅ TOTEUTETTU** | `publisher-free` + `proxy-gvenzl` + `app-free`, Outbound REST ACL:t |
| **1.17** | Automaattinen versioiden tunnistus | **✅ TOTEUTETTU** | Tunnistus suoraan konttikuvasta ja arkistojen manifesteista |
| **1.18** | Asennuksen nopeuttaminen (APEX DB 15m ➔ 1–2m) | **✅ TOTEUTETTU** | FastStart-kuvat, Golden Snapshot -palautus (~30s), runtime-tila (`TASK-018`) |
| **1.19** | Analytics Publisherin & monikannan nopeuttaminen | **✅ TOTEUTETTU** | Valmiiksi rakennettu WebLogic-verkkotunnuskuva (~45s) (`TASK-019`) |
| **1.20** | Monikanta-SEPS-wallet & TNS-tasaus | **✅ TOTEUTETTU** | Erilliset SEPS-walletit ja synkronoitu `tnsnames.ora` (`TASK-027`) |
| **1.21** | VS Code Walletin kaikkien käyttäjien synkronointi | **✅ TOTEUTETTU** | Profiilien skeemojen automaattinen rekisteröinti (`TASK-028`) |
| **1.22** | Oracle Forms 14c -kontti ja noVNC-tuki | **✅ TOTEUTETTU** | Forms 14c -suoritusympäristö, HTML5 noVNC Forms Builder (`TASK-029`) |
| **1.23** | Kanoniset konttiprefiksien SEPS-walletit | **✅ TOTEUTETTU** | Kaava `DB_${PREFIX}_*` ilman kovakoodausta (`TASK-030`) |
| **1.24** | Kompakti terminaaliedistymispalkki | **✅ TOTEUTETTU** | Paikallaan päivittyvä TTY-rivi (`\r\033[K`), vertailutiedot (`TASK-025`) |
| **1.25** | `setup-all.sh` Blueprint-listaus ja tiedot | **✅ TOTEUTETTU** | `--list-blueprints` (`-lb`), `--show-blueprint <N>` (`TASK-026`) |
| **2.13** | Tehtävien uudelleenorganisointi Backlogiksi | **✅ TOTEUTETTU** | Modulaarinen rakenne `backlog/todo/` ja `backlog/done/` |
| **4.2** | Lokien ja diagnostiikan puhdistus (`clean-logs.sh`) | **✅ TOTEUTETTU** | Skripti `scripts/clean-logs.sh` luotu ja validoitu (`TASK-008`) |
| **5.1** | Yrityksen virallisten TLS-varmenteiden tuki | **❌ EI ALOITETTU** | Käytössä paikallinen itseallekirjoitettu `localCA.pem` |
| **6.1** | OCI Always Free -pilviasennuksen testaus | **🟡 KESKEN** | `deploy-remote.sh` valmis, odottaa pilviympäristön testiä (`TASK-020`) |
| **6.2** | GitHub Actions -pilvitoimitus | **🟡 KESKEN** | `deploy-remote-cloud.yml` valmis, odottaa salaisuuksia (`TASK-020`) |
| **2.8** | Automaattinen TDE-salaustuki | **🟡 KESKEN** | Levyn tablespace-alueiden AES-256-salaus (`TASK-021`) |
| **2.9** | Vain luku -juuritiedostojärjestelmä (`--read-only`) | **🟡 KESKEN** | Konttien juuritiedostojärjestelmän lukitus ja `tmpfs` (`TASK-022`) |
| **2.10** | Keskitetty auditointiloki ja SIEM-integraatio | **❌ EI ALOITETTU** | Oracle Unified Auditing -säännöt ja logiforwarder (`TASK-023`) |
| **2.11** | WAF & OAuth2 / OIDC Entra-ID REST-rajapinnoille | **🟡 KESKEN** | Nginx ModSecurity WAF & ORDS OAuth2 -suojaus (`TASK-024`) |
