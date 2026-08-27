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

Et hoida projekti juurkataloog ja skriptide kaust puhtana ja professionaalselt struktureerituna, järgitakse **modulaarset 3-kihilist skriptide struktuuri**:

1. **Kasutaja CLI ja arendaja igapäevased tööriistad (`scripts/` juurkaust):**
   - **Keskkonna elutsükli käsud:** `setup-all.sh`, `reset-all.sh`, `start-containers.sh`, `sqlcl.sh`, `deploy-remote.sh`, `test-local-ci.sh`.
   - **Arendaja tööriistad:** `get-password.sh` (paroolide lugemine Walletist), `check-urls.sh` (veebiteenuste diagnostika), `check-wallet.sh` (SEPS ühenduste diagnostika), `create-developer.sh` (arendajakontode loomine/taastamine), `register-connections.sh` (VS Code ühenduste registreerimine), `clean-logs.sh`.

2. **Loogilised alamkataloogid (Modular Feature Folders):**
   - **`scripts/snapshots/`:** Hetktõmmiste haldus (`create-golden-snapshots.sh`, `restore-golden-snapshots.sh`, `clean-golden-snapshots.sh`).
   - **`scripts/certs/`:** OS-spetsiifilised sertifikaatide usaldamise skriptid (`trust-local-cert-mac.sh`, `trust-local-cert.cmd`, `trust-local-cert.ps1` jne).
   - **`scripts/publisher/`:** Analytics Publisheri operatsioonid (`status-publisher.sh`, `restart-publisher.sh`, `backup-publisher-catalog.sh`, `deploy-publisher-reports.sh`).
   - **`scripts/patches/`:** Patchide käsitsi paigaldamise utiliidid (`apply-apex-patch.sh`, `apply-publisher-patch.sh`).

3. **Sisemised abiskriptid, paigaldused ja SQL-id (`scripts/internal/`):**
   - Kõik automatiseerimise sisemised abiskriptid paigutatakse alamkataloogi `scripts/internal/`:
     - Ühised mootorid: `common.sh`, `load-profile.sh`, `resolve-topology.sh`
     - Automaatsed genereerijad: `generate-compose-override.sh`, `generate-local-certs.sh`, `generate-passwords.sh`, `create-wallet.sh`
     - Konteinerite initsialiseerimine: `wait-db-healthy.sh`, `init-db-instance.sh`, `init-db-instance.sql`, `apply-profile-users.sh`
     - APEX ja Publisheri paigaldusmootorid: `install-apex.sh`, `install-publisher.sh`, `install-ords-standalone.sh`

4. **Viidete ja ühilduvuse tagamine:**
   - Iga kord, kui skripte liigutatakse, tagatakse tagasiühilduvus (`scripts/internal/` symlingid või wrapperid) ning testitakse relative paths (`SCRIPT_DIR`, `WORKSPACE_DIR`).

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
   - Paroolid ja ühenduse rekvisiidid tuleb pärida keskse utiliidi kaudu: `./scripts/get-password.sh <alias>` (ühilduvus: `./scripts/internal/view-wallet-credential.sh <alias>`).
   - **Kõik Walleti aliased TULEVAD DÜNAAMILISELT YAML profiilifailist (`config/profiles/*.yaml`).** Koodis ja skriptides ei tohi sisalduda ühtegi kõvakodeeritud Walleti aliast (nt `DB_APEX_PROXY_SYS`) ega kõvakodeeritud kasutajanime.
2. **Kõvakodeerimise ja `ps aux` lekete vältimine:**
## 6. SQLcl & VS Code CLI Stability Contract Rule

Kõik skriptid, wrapperid ja automaatse ühenduse generaatorid peavad järgima **5 kohustuslikku stabiilsusreeglit**, et vältida regressioone:

1. **Uusima VS Code SQLcl eelistamine (Binary Resolution Order):** SQLcl käivitamisel tuleb eelistada alati VS Code laienduse uusimat SQLcl versiooni (`find "$HOME/.vscode/extensions" ... | sort -rV | head -n 1`). Keelatud on loota pelgalt süsteemse `$PATH` peale ilma keskkonda saniteerimata.
2. **Keskkonna Isoleerimine (`unset JAVA_HOME` & Puhas `JAVA_TOOL_OPTIONS`):** Enne SQLcl käivitamist tuleb teostada `unset JAVA_HOME` (vältimaks vanade SQL Developer Java 11 seadistuste sekkumist Java 21+ töösse). `JAVA_TOOL_OPTIONS` peab sisaldama AINULT `-Doracle.net.tns_admin=$TNS_DIR` ilma korduvate `-Doracle.net.wallet_location` aheldamisteta (ennetab vea `Syntax error at column 14: '`).
3. **Binaarparooli Fallback:** `mkstore -viewEntry` tulemust ei edastata otseselt SQLcl-ile ilma kontrollita. Kui parool sisaldab binaarmärke või küsimärke (`[[ "$PWD_VAL" == *"?"* ]]`), päritakse parool automaatselt Podman secret store'ist (`apex_db_sys_password`, `apex_db_dev_password` jne).
4. **POSIX Kesta Ühilduvus:** Keelatud on kasutada Bashi-spetsiifilisi laiendusi (nagu `${ALIAS,,}`), mis murduvad `sh` / `zsh` all sisselugemisel. Kasutada tuleb porditavaid `tr '[:upper:]' '[:lower:]'` ja `awk` käske.
5. **Multi-Shell Registreerimine:** Kesta seadistamisel tuleb lisada `TNS_ADMIN` ja `alias sql` kõikidesse kesta profiilidesse (`~/.zshrc`, `~/.zshenv`, `~/.bashrc`, `~/.bash_profile`) ning tagada käivitatav wrapper kaustas `~/Applications/sqlcl/bin/sql`.

---

## 7. Standardized Terminal UX, Live Timer & Credential Helper Rule

Kõik paigalduse, halduse ja testimise skriptid peavad järgima **ühtset terminali UX standardit**:

1. **Reaalajas Jooksev Taimer Pikematel Sammudel:** Kõik pikaajalised operatsioonid (APEX paigaldus, patchimine, konteinerite tõmbamine, tervislikkuse ootamine) peavad kasutama reaalajas uuenevat sekundiloendurit (`run_with_live_timer` või `print_progress`), vältimaks muljet hangumisest.
2. **Standardiseeritud Lõpparuanne:**
   - **Veebirakenduste tabel:** Eristatud URL-id ja kasutajainfo (APEX Builder, APEX Instance Admin, Database Actions, Analytics Publisher, Web IDE).
   - **VS Code ühenduste puudiagramm:** Hierarhiline ASCII diagramm kaustadest ja TNS aliasetest.
   - **Paroolide pärimise spikker:** Selged käsud `./scripts/internal/view-wallet-credential.sh <ALIAS>`.
   - **Kogukestus lõpus:** Kogu paigalduse aeg kuvatakse viimases plokis ilma info dubleerimiseta.
   - **Logiviited:** Täielikud detailid suunatakse `install_logs/` failidesse ja viidatakse klikitavate linkidega.

---

## 8. Dynamic Database Profiles & Multi-DB SEPS Wallet Rule

1. **Null Kõvakodeeritud Nimesid (Zero Hardcoding):** Keelatud on kõvakodeerida andmebaaside nimesid (nagu `proxy`, `lis`, `publisher`), porte või ORDS basseine. Kõik väärtused loetakse dünaamiliselt `.env` failist ja YAML profiilidest (`config/profiles/databases/*.yaml`).
2. **Süsteemsete Kontode Talletamine Walletis:** Iga andmebaasi instantsi kohta luuakse automaatselt andmebaasipõhised süsteemsed aliased:
   - `${DB_PREFIX}_APEX_ADMIN` (APEX `INTERNAL` Workspace administraatori parool veebi jaoks)
   - `${DB_PREFIX}_APEX_PUBLIC_USER` / `${DB_PREFIX}_APEX_LISTENER`
   - `${DB_PREFIX}_ORDS_PUBLIC_USER`
   - `${DB_PREFIX}_SYS`, `${DB_PREFIX}_DBA_ADMIN`, `${DB_PREFIX}_DEV`, `${DB_PREFIX}_VIEWER`
3. **URL Testimise Sisu ja TLS Valideerimine:** `test-urls.sh` peab testima kõiki aktiivseid basseine, kontrollima vastuse sisu (välistama `DatabaseCredentialError`) ja verifitseerima TLS usaldusväärsuse.
4. **Keskne Blueprints Mudel ja Toodangu Turvalukud (`config/blueprints/`):** Kõik 13 arhitektuurset keskkonnamudelit asuvad kanoonilises kaustas `config/blueprints/`. Toodangus (`-b <N>` / `--blueprint <N>`) on lubatud korraga valida AINULT ÜKS number [1-13] ning `reset-all` on keelatud (idempotentne jätkamine). Testimisrežiimis (`-tb <LIST|all>` / `--test-blueprints`) tehakse alati enne iga testi `reset-all.sh -y` puhta algseisu tagamiseks. Juurkataloogis ei hoita dubleerivat `.env.example` faili.



