# Workspace Rules for Oracle Free DB in Prod

## 1. Automatic Step Timing & Logging Rule

Iga kord kui projekti skriptidesse (`scripts/*.sh` või `scripts/setup-all.sh`) lisatakse UUS paigalduse, konfigureerimise või taastamise samm:

1. **Ajamõõtmine & Git Mõõdikud (`metrics/`):**
   - Sammu algus- ja lõpuaeg tuleb sekundite täpsusega mõõta (`format_duration`).
   - Tulemus tuleb salvestada faili `metrics/setup_benchmarks.json` (JSON) ja `metrics/setup_benchmarks.env` (ENV muutujatena).
   - `metrics/` kataloog peab olema versioonihalduses (Git tracked).

2. **Lokaalne täielik logimine (`install_logs/`):**
   - Kogu sammu käivituslogi (stdout ja stderr) peab automaatselt salvestuma ajatempliga logifaili kaustas `install_logs/` (nt `install_logs/setup_step_YYYYMMDD_HHMMSS.log`).
   - `install_logs/` kataloog on `.gitignore` failis ning jääb AINULT lokaalseks (local-only).

---

## 2. Mandatory Documentation Maintenance Rule

Iga kord kui projekti lisatakse uut funktsionaalsust, muudetakse seadistusi või luuakse uusi skripte/konteinereid/parameetreid:

1. **Dokumentatsiooni kohustuslik uuendamine:**
   - Vastavat dokumentatsiooni faili (peamiselt `README.md`, vajadusel `patches/README.md` või `connections/README.md`) TULEB KOHE KOHUSTUSLIKULT UUENDADA.
   - Uue funktsionaalsuse kasutusjuhend, skripti käivituskäsk, parameetrid ja eeldatav tulemus peavad olema selgelt kirjeldatud.

2. **Koodi ja dokumentatsiooni kooskõla:**
   - Dokumentatsioonis ei tohi olla aegunud ega puuduvaid käske.
   - Iga muudatus koodis/skriptides peab kajastuma vastavas dokumentatsioonis samas töötsüklis.

---

## 3. Directory Layout Rule for Scripts

Et hoida projekti juurkataloog ja skriptide kaust puhtana, tuleb järgida ranget failide paigutuse struktuuri:

1. **Kasutaja poolt otse käivitatavad skriptid (`scripts/` juurkaust):**
   - Siia jäävad AINULT need põhilised skriptid, mida kasutaja või arendaja peab käsitsi teatud juhtudel otse käivitama:
     - `setup-all.sh` (Kogu keskkonna paigaldus)
     - `reset-all.sh` (Puhastamine/kustutamine)
     - `backup-volumes.sh` (Varukoopia tegemine)
     - `restore-volumes.sh` (Varukoopiast taastamine)
     - `start-containers.sh` (Konteinerite käivitamine)

2. **Sisemised abiskriptid, paigaldused ja SQL-id (`scripts/internal/`):**
   - Kõik muud abiskriptid, automaatsed sammud, SQL failid ja eriseadistused paigutatakse alamkataloogi `scripts/internal/`:
     - APEX installi- ja patchimise skriptid (`install-apex.sh`, `apply-apex-patch.sh`)
     - Andmebaasi käivitus- ja häälestusskriptid (`init-apex-proxy.sh`, `init-apex-proxy.sql`, `init-publisher.sh`, `init-publisher.sql`)
     - Kliendiühenduste ja VS Code SQL Developer konfigureerimine (`register-connections.sh`, `register-connections-sqlcl.sh`, `deploy-apex.sql`)
     - Spetsiaalsed test/standalone skriptid (`install-ords-standalone.sh`)

3. **Viidete uuendamine:**
   - Iga kord, kui lisatakse või muudetakse skripti, mis viitab mõnele neist failidest, tuleb veenduda, et relative paths (`../../`) ja Docker Compose volume mountid (`./scripts/internal/...`) on korrektselt uuendatud.

---

## 4. Ephemeral Container Fallback Pattern for Restricted Environments

Kui arendus- või sihtkeskkonnas (näiteks range turvapoliitikaga suurettevõttes) tekivad piirangud lokaalsete tööriistade (Java, SQLcl, Liquibase jne) paigaldamisele või kasutamisele, tuleb alati eelistada ja toetada **ajutiste (ephemeral) konteinerite fallback** lahendust:

1. **Konfigureeritavad pildid:** Kõik kasutatavad konteineri pildid peavad olema `.env` või konfiguratsioonifailide kaudu ülekirjutatavad (näiteks muutuja `SQLCL_CONTAINER_IMAGE`), et võimaldada ettevõtte sisese Artifactory peegelduse kasutamist.
2. **Käivitamine `--rm` lipuga:** Kõik ajutised konteinerid, mis sooritavad ühekordseid operatsioone (nagu andmete varundamine, skeemide migratsioonid või APEX rakenduste import), tuleb käivitada `--rm` võtmega. See tagab mälupuhvrite ja ajutiste failide (sh saladuste/paroolide) automaatse ja turvalise hävitamise pärast töö sooritamist.
   - **WSL ja hangumiste ennetamine:** See lahendab ka WSL-is (Windows Subsystem for Linux) esinevad probleemid, kus lokaalsed Java/SQLcl protsessid jäävad terminali või VPN katkestuse korral taustal orvuks (orphaned/ghost processes). Konteineri sulgemine hävitab automaatselt kõik alamprotsessid (PID 1 isoleeritus).
3. **Ühtsed abifunktsioonid (wrapperid):** Skriptid peavad võimalusel kapseldama kohaliku CLI ja konteineri käivitamise ühte korduvkasutatavasse funktsiooni (nagu `run_sqlcl`), tagades sujuva toimimise nii arendaja kohalikus masinas kui ka lukustatud korporatiivses võrgus.

---

## 5. Oracle Wallet Mandatory Credential Store Rule

Kõik skriptid, automaattestid (nt `test-browser-login.sh`), CLI utiliidid ja automaatsed vahendid peavad paroolide või kasutajaandmete lugemiseks eelistama ALATI **Oracle Walletit (SEPS)**:

1. **Paroolide ja aliase pärimine Walletist:**
   - Paroolid ja ühenduse rekvisiidid tuleb pärida keskse utiliidi kaudu: `./scripts/internal/view-wallet-credential.sh <alias>`.
   - **Kõik Walleti aliased TULEVAD DÜNAAMILISELT YAML profiilifailist (`config/profiles/*.yaml`).** Koodis ja skriptides ei tohi sisalduda ühtegi kõvakodeeritud Walleti aliast (nt `DB_APEX_PROXY_SYS`) ega kõvakodeeritud kasutajanime.
2. **Kõvakodeerimise ja `ps aux` lekete vältimine:**
   - Parooli ei tohi kunagi kõvakodeerida skriptidesse ega edastada avatud tekstina käsuliini argumentides (`sqlplus sys/password`), mis võiks lekkida operatsioonisüsteemi protsessinimekirja (`ps aux`).
---

## 6. SQLcl & VS Code CLI Stability Contract Rule

Kõik skriptid, wrapperid ja automaatse ühenduse generaatorid peavad järgima **5 kohustuslikku stabiilsusreeglit**, et vältida regressioone:

1. **Uusima VS Code SQLcl eelistamine (Binary Resolution Order):** SQLcl käivitamisel tuleb eelistada alati VS Code laienduse uusimat SQLcl versiooni (`find "$HOME/.vscode/extensions" ... | sort -rV | head -n 1`). Keelatud on loota pelgalt süsteemse `$PATH` peale ilma keskkonda saniteerimata.
2. **Keskkonna Isoleerimine (`unset JAVA_HOME` & Puhas `JAVA_TOOL_OPTIONS`):** Enne SQLcl käivitamist tuleb teostada `unset JAVA_HOME` (vältimaks vanade SQL Developer Java 11 seadistuste sekkumist Java 21+ töösse). `JAVA_TOOL_OPTIONS` peab sisaldama AINULT `-Doracle.net.tns_admin=$TNS_DIR` ilma korduvate `-Doracle.net.wallet_location` aheldamisteta (ennetab vea `Syntax error at column 14: '`).
3. **Binaarparooli Fallback:** `mkstore -viewEntry` tulemust ei edastata otseselt SQLcl-ile ilma kontrollita. Kui parool sisaldab binaarmärke või küsimärke (`[[ "$PWD_VAL" == *"?"* ]]`), päritakse parool automaatselt Podman secret store'ist (`apex_db_sys_password`, `apex_db_dev_password` jne).
4. **POSIX Kesta Ühilduvus:** Keelatud on kasutada Bashi-spetsiifilisi laiendusi (nagu `${ALIAS,,}`), mis murduvad `sh` / `zsh` all sisselugemisel. Kasutada tuleb porditavaid `tr '[:upper:]' '[:lower:]'` ja `awk` käske.
5. **Multi-Shell Registreerimine:** Kesta seadistamisel tuleb lisada `TNS_ADMIN` ja `alias sql` kõikidesse kesta profiilidesse (`~/.zshrc`, `~/.zshenv`, `~/.bashrc`, `~/.bash_profile`) ning tagada käivitatav wrapper kaustas `~/Applications/sqlcl/bin/sql`.



