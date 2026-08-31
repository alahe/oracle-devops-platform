<!-- [ 🇬🇧 English ](../quick-login-guide.md) | [ 🇪🇪 Eesti ](../et/quick-login-guide.md) | [ 🇫🇮 Suomi ](quick-login-guide.md) | [ 🇸🇪 Svenska ](../quick-login-guide.md) | [ 🇱🇻 Latviešu ](../quick-login-guide.md) | [ 🇱🇹 Lietuvių ](../quick-login-guide.md) -->

# 🚀 Pikaopas Kirjautumiseen ja Saumattomaan Pääsyyn

Tämä opas kuvaa nopeimman ja turvallisimman tavan käyttää kaikkia aktiivisia verkkopalveluita, tietokantatyökaluja ja hallintapaneeleja Oracle DevOps -alustalla.

---

## ⚡ Nopein 2-Vaiheinen Kirjautuminen (Leikepöytäapuri `-c`)

Salasanojen etsimisen tai ruudulta kirjoittamisen sijaan voit kopioida salasanat suoraan käyttöjärjestelmän leikepöydälle (`pbcopy` / `xclip` / `wl-copy` / `clip.exe`) ilman selväkielisten salasanojen näyttämistä:

```bash
# 1. Kopioi salasana leikepöydälle 1 sekunnissa:
./scripts/get-password.sh <ALIAS> -c

# 2. Liitä suoraan selaimen salasanakenttään:
# Cmd+V (macOS) tai Ctrl+V (Windows/Linux)
```

---

## 🌐 Pääsyportaalit ja Tunnistematriisi

| Palvelu / Portaali | Suora Verkkolinkki | Oletuskäyttäjä / Työtila | Salasanakomento (Välitön Kopiointi) |
| :--- | :--- | :--- | :--- |
| **🛠️ APEX Builder** | [Avaa APEX-Työtila](https://localhost:8448/ords/proxy/r/apex/workspace-sign-in/oracle-apex-sign-in) | Työtila: `DEV_WS`<br/>Käyttäjä: `USER_DEVELOPER` | `./scripts/get-password.sh DB_PROXY_DEV -c` |
| **⚙️ APEX Instance Admin** | [Avaa APEX Admin](https://localhost:8448/ords/proxy/apex_admin) | Työtila: `INTERNAL`<br/>Käyttäjä: `ADMIN` | `./scripts/get-password.sh DB_PROXY_APEX_ADMIN -c` |
| **📊 Database Actions (SDW)** | [Avaa SQL Developer Web](https://localhost:8448/ords/proxy/sql-developer) | Skeema / Käyttäjä: `USER_DEVELOPER` | `./scripts/get-password.sh DB_PROXY_DEV -c` |
| **📑 Analytics Publisher** | [Avaa Analytics Publisher](http://localhost:9502/xmlpserver) | Käyttäjä: `weblogic` | `./scripts/get-password.sh DB_PUBLISHER_SYS -c` |
| **📐 Forms 14c Services** | [Avaa Forms-Testilomake](http://localhost:9001/forms/frmservlet?form=test.fmx) | Runtime / `test.fmx` | Ei vaadita |
| **🎨 Forms Builder GUI** | [Avaa Forms Builder Web GUI](http://localhost:6082/vnc.html) | HTML5 noVNC -asiakas | Ei vaadita |
| **💻 VS Code Web IDE** | [Avaa Web IDE](http://localhost:8090/?folder=/workspace) | Käyttäjä: `developer` | Ei vaadita (Salasanaton) |
| **⚙️ WebLogic Admin Console** | [Avaa WebLogic-Konsoli](http://localhost:7001/console) | Käyttäjä: `weblogic` | `./scripts/get-password.sh DB_FORMS_SYS -c` |

> [!TIP]
> **Developer Hub (`https://localhost:8448/dev-hub.html`):** Komentokeskuksen etusivu sisältää tämän koko taulukon 1-klikkauksen `[Salasana (.sh)]` -painikkeilla ja klikattavilla TNS-aliastunnisteilla jokaiselle tietokantakäyttäjälle ja -palvelulle.

---

## 💾 CLI-Pikapääsy (Oracle SQLcl SEPS Walletin kautta)

Yhdistäminen suoraan tietokantaan ilman salasanojen näkymistä `ps aux` -listauksessa:

```bash
# Yhdistä kehittäjänä
sql /@DB_PROXY_DEV

# Yhdistä DBA-ylläpitäjänä
sql /@DB_PROXY_DBA_ADMIN

# Yhdistä SYSDBA-oikeuksilla
sql /@DB_PROXY_SYS as sysdba
```

## 🧪 Automaattinen Kirjautumisen Testaus (E2E Login Test)

Automaattinen testi, joka simuloi todellista lomakkeen POST-todennusta ja tarkistaa istunnon toiminnan:

```bash
./scripts/test-browser-login.sh
```

Tämä testi validoi:
1. **APEX Instance Admin:** Todentaa `ADMIN`-käyttäjän `INTERNAL`-työtilassa.
2. **APEX Workspace Builder:** Todentaa `DEV`-käyttäjän aktiivisessa työtilassa.
3. **Database Actions:** Todentaa `USER_DEVELOPER`-käyttäjän HTTP-istunnon kautta.

---

## 🔄 Salasanojen Rotaatio

Kierrätä salasanat tietokannassa, Podman-salaisuuksissa ja SEPS Walletissa samanaikaisesti:

```bash
# Kierrätä tietyn tietokannan kehittäjän salasana
./scripts/rotate-password.sh db-proxy dev

# Kierrätä kaikki aktiivisen ympäristön salasanat
./scripts/rotate-password.sh all
```
