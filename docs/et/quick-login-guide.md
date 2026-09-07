<!-- [ 🇬🇧 English ](../quick-login-guide.md) | [ 🇪🇪 Eesti ](quick-login-guide.md) | [ 🇸🇪 Svenska ](../quick-login-guide.md) | [ 🇱🇻 Latviešu ](../quick-login-guide.md) | [ 🇱🇹 Lietuvių ](../quick-login-guide.md) -->

# 🚀 Kiire ja Turvalise Sisselogimise Juhend

See juhend kirjeldab kõige kiiremat ja turvalisemat viisi Oracle DevOps Platvormi veebiteenustesse, andmebaasidesse ja haldusliidestesse sisselogimiseks.

---

## ⚡ Kiireim 2-Sammuline Sisselogimine (Lõikelaua Tugi `-c`)

Paroolide ekraanile kuvamise või käsitsi kopeerimise asemel saab parooli kopeerida otse arvuti lõikelauale (`pbcopy` Macis, `xclip`/`wl-copy` Linuxis, `clip.exe` Windowsis/WSL-is) ilma parooli ekraanile manamata:

```bash
# 1. Kopeeri parool lõikelauale 1 sekundiga:
./scripts/get-password.sh <ALIAS> -c

# 2. Kleebi see otse brauseri parooliväljale:
# Cmd+V (macOS) või Ctrl+V (Windows/Linux)
```

---

## 🌐 Teenuste ja Kasutajate Kiirspikker

| Teenus / Veebiliides | Otselink Brauseris (Eeltäidetud) | Vaikekasutaja / Workspace | Parooli Hankimine (Lõikelaud) |
| :--- | :--- | :--- | :--- |
| **🛠️ APEX Builder** | [Ava APEX Tööruum (Eeltäidetud)](https://localhost:8448/ords/proxy/r/apex/workspace-sign-in/oracle-apex-sign-in?f4550_p1_company=PROXY_WORKSPACE&f4550_p1_username=DEV) | Workspace: `PROXY_WORKSPACE`<br/>Kasutaja: `DEV` *(Eeltäidetud)* | `./scripts/get-password.sh DB_PROXY_DEV -c` |
| **⚙️ APEX Instance Admin** | [Ava APEX Admin (Eeltäidetud)](https://localhost:8448/ords/proxy/r/apex/workspace-sign-in/administration-sign-in?p10_username=ADMIN) | Tööruum: `INTERNAL`<br/>Kasutaja: `ADMIN` *(Eeltäidetud)* | `./scripts/get-password.sh DB_PROXY_APEX_ADMIN -c` |
| **📊 Database Actions (SDW)** | [Ava SQL Developer Web](https://localhost:8448/ords/proxy/user_developer/sign-in?r=_sdw) | Skeem: `user_developer`<br/>Kasutaja: `USER_DEVELOPER` | `./scripts/get-password.sh DB_PROXY_DEV -c` |
| **📑 Analytics Publisher** | [Ava Analytics Publisher](http://localhost:9502/xmlpserver) | Kasutaja: `weblogic` | `./scripts/get-password.sh DB_PUBLISHER_SYS -c` |
| **📐 Forms 14c Teenused** | [Ava Forms Testvorm](http://localhost:9001/forms/frmservlet?form=test.fmx) | Runtime / `test.fmx` | Parooli pole vaja |
| **🎨 Forms Builder GUI** | [Ava Forms Builder Web GUI](http://localhost:6082/vnc.html) | HTML5 noVNC Klient | Parooli pole vaja |
| **💻 VS Code Web IDE** | [Ava Web IDE Töökoht](http://localhost:8090/?folder=/workspace) | Kasutaja: `developer` | Paroolita töökoht |
| **⚙️ WebLogic Admin Console** | [Ava WebLogic Konsool](http://localhost:7001/console) | Kasutaja: `weblogic` | `./scripts/get-password.sh DB_FORMS_SYS -c` |

> [!TIP]
> **Database Actions (SQL Developer Web) otselink:**
> Kasutage otselinki `https://localhost:8448/ords/<pool>/user_developer/sign-in?r=_sdw`, mis suunab pärast sisselogimist otse SQL Developer Web töölauale.

> [!TIP]
> **Developer Hub (`https://localhost:8448/dev-hub.html`):** Juhtpaneeli pealehel on integreeritud täielik paroolimaatriks koos 1-kliki `[📋 Copy]` nuppudega iga andmebaasi konto jaoks.

---

## 💾 Käsurea Kiirühendused (Oracle SQLcl läbi SEPS Walleti)

Otseühendus andmebaasi ilma parooli terminalis näitamata:

```bash
# Ühendu arendajana
sql /@DB_PROXY_DEV

# Ühendu DBA administraatorina
sql /@DB_PROXY_DBA_ADMIN

# Ühendu SYSDBA õigustes
sql /@DB_PROXY_SYS as sysdba
```

## 🧪 Automaatne Sisselogimise Testimine (E2E Login Test)

Automaatne test, mis simuleerib reaalset vormi POST autentimist ja kontrollib sessiooni toimimist:

```bash
./scripts/test-browser-login.sh
```

See test valideerib:
1. **APEX Instance Admin:** Autendib `ADMIN` kasutaja `INTERNAL` tööruumis.
2. **APEX Workspace Builder:** Autendib `DEV` kasutaja aktiivses tööruumis.
3. **Database Actions:** Autendib `USER_DEVELOPER` kasutaja läbi HTTP sessiooni.

---

## 🔄 Paroolide Roteerimine

Paroolide turvaliseks vahetamiseks andmebaasis, Podman Secrets hoidlas ja Walletis korraga:

```bash
# Roteeri konkreetse andmebaasi arendaja parool
./scripts/rotate-password.sh db-proxy dev

# Roteeri kogu keskkonna kõik paroolid
./scripts/rotate-password.sh all
```

---

## 💡 Veatuvastus ja Brauseri Sessiooniküpsiste Isoleerimine

> [!NOTE]
> **APEX Sessioonide Isoleerimine (`INTERNAL` vs Tööruum):**
> Kui testite samaaegselt APEX Admini (`INTERNAL`) ja APEX Builderit (`<WORKSPACE>`) aadressil `localhost:8448`, avage üks neist tavalises vahelehes ja teine **Incognito / Private aknas** (`Cmd+Shift+N`), et vältida brauseri sessiooniküpsiste segunemist ja veateadet *"Your session has ended"*.

