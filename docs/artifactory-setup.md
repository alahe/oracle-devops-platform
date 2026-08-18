# Sisemise Artifactory Hoidla Seadistamine (`.env`)

Tulemüüriga piiratud ettevõtte keskkonnas saab ORDS-i ja APEX-i tarkvara allalaadimise aadressid ning autentimistunnused määrata failis **[.env](../.env)** (näidis asub failis **[.env.example](../.env.example)**).

---

## Seadistamise näidis

Kopeeri või muuda faili `.env`:

```bash
# Artifactory tarkvara allalaadimise aadressid:
ORDS_URL="https://artifactory.ettevote.ee/artifactory/oracle-repo/ords-latest.zip"
APEX_URL="https://artifactory.ettevote.ee/artifactory/oracle-repo/apex-latest.zip"

# Vajadusel Artifactory autentimine (kasutaja:token):
# ARTIFACTORY_AUTH="kasutaja:api_token_või_parool"
```

Kõik paigaldusskriptid (`install-ords-standalone.sh` ja `install-apex.sh`) loevad neis olevad URL-id ja tunnused automaatselt neist seadistustest.

---

## Ametlikud Allalaadimise Otselingid (OTN)

Kui sul on vaba pääs välisvõrku, laevad skriptid vaikimisi failid alla ametlikest Oracle'i hoidlatest:

*   **Ametlik ORDS allalaadimisportaal:** [Oracle ORDS Downloads](https://www.oracle.com/database/sqldeveloper/technologies/dbactions/download/)
*   **Ametlik ORDS OTN otselink:** `https://download.oracle.com/otn_software/java/ords/ords-latest.zip`
*   **Ametlik APEX allalaadimisportaal:** [Oracle APEX Downloads](https://apex.oracle.com/download/)
*   **Ametlik APEX OTN otselink:** `https://download.oracle.com/otn_software/apex/apex-latest.zip`

> ℹ️ *Märkus: Konkreetse versiooniga failide URL-id (nt `ords-24.1.0.zip` või `apex_23.2.zip`) muutuvad ajas uute versioonide väljatulekul. OTN otselink `ords-latest.zip` suunab alati staatiliselt uusimale stabiilsele versioonile. Ettevõtte sise-Artifactorys on soovitav hoida versioneeritud paigalduspakette.*
