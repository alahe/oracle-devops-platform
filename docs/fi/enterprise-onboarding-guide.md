# Yrityksen perehdytys ja rekisteripeilien asennusopas

[ 🇬🇧 English ](../enterprise-onboarding-guide.md) | [ 🇪🇪 Eesti ](../et/enterprise-onboarding-guide.md) | [ 🇫🇮 Suomi ](enterprise-onboarding-guide.md) | [ 🇸🇪 Svenska ](../sv/enterprise-onboarding-guide.md) | [ 🇱🇻 Latviešu ](../lv/enterprise-onboarding-guide.md) | [ 🇱🇹 Lietuvių ](../lt/enterprise-onboarding-guide.md)

---

## 1. Yleiskatsaus ja arkkitehtuurin tarkoitus

Yritysympäristöissä kehittäjien työpisteet ja tuotantopalvelimet toimivat usein suljetuissa yritysverkoissa ilman suoraa pääsyä julkisiin konttirekistereihin (`container-registry.oracle.com`, `docker.io`, `ghcr.io`). Sen sijaan yrityskäytännöt velvoittavat lataamaan konttikuvat ja binäärit **sisäisten artefaktivarastojen** kautta (JFrog Artifactory, Harbor, Sonatype Nexus), ohjaamaan ulospäin suuntautuvan liikenteen TLS-tarkistavien välityspalvelinten (Zscaler, Netskope) kautta ja luottamaan yrityksen sisäisiin varmenneviranomaisiin (Root CA).

Tämä opas neuvoo:
1. Miten yrityksen infrastruktuuri määritetään tiedostossa [`config/enterprise.yaml`](../../config/enterprise.yaml).
2. Miten käytetään perehdytystyökalua [`scripts/onboard-enterprise.sh`](../../scripts/onboard-enterprise.sh).
3. Miten profiili-YAMLit päivitetään suoraan levyllä (`--patch-profiles`).
4. Miten profiilit palautetaan alkuperäisiin julkisiin rekistereihin (`--revert`).
5. Miten määritetään välityspalvelimet, CA-varmenteet ja sisäiset verkkotunnukset.
6. Miten yritysasiakirjojen brändäys ja saavutettavuus (PDF/UA-1, WCAG 2.1 AA) toteutetaan.

---

## 2. Yrityksen keskitetty konfiguraatio (`config/enterprise.yaml`)

Alusta tarjoaa keskitetyn konfiguraatiomallin tiedostossa [`config/enterprise.yaml.example`](../../config/enterprise.yaml.example). Ota se käyttöön:

```bash
cp config/enterprise.yaml.example config/enterprise.yaml
```

### Konfiguraation osiot

```yaml
enterprise:
  name: "Yrityksen Nimi"
  environment: "production" # development | test | staging | production

# 1. Sisäinen konttirekisteri ja Artifactory-peili
registry:
  base_url: "artifactory.corp.internal/docker-mirror"
  auth_mode: "anonymous" # anonymous | podman_secret | token
  mappings:
    "container-registry.oracle.com/database/free": "artifactory.corp.internal/docker-mirror/oracle/database/free"
    "container-registry.oracle.com/database/ords": "artifactory.corp.internal/docker-mirror/oracle/database/ords"
    "container-registry.oracle.com/database/sqlcl": "artifactory.corp.internal/docker-mirror/oracle/database/sqlcl"
    "docker.io/library/ubuntu": "artifactory.corp.internal/docker-mirror/dockerhub/library/ubuntu"
    "ghcr.io": "artifactory.corp.internal/docker-mirror/ghcr"

# 2. Välityspalvelin ja CA-luottamus
network:
  http_proxy: "http://proxy.corp.internal:8080"
  https_proxy: "http://proxy.corp.internal:8080"
  no_proxy: "localhost,127.0.0.1,*.corp.internal,.local,podman-machine-default"
  corporate_ca_bundle_path: "/etc/pki/ca-trust/source/anchors/corp-root-ca.crt"

# 3. Yritysverkkotunnus ja TLS
domain:
  internal_domain: "corp.internal"
  custom_tls_cert: ""
  custom_tls_key: ""

# 4. Tietoturva- ja auditointikäytäntö
security:
  enforce_seps_wallet: true
  mask_tokens_in_logs: true
  audit_level: "strict"
```

---

## 3. Profiilien suora muokkaus levyllä

Täyden läpinäkyvyyden säilyttämiseksi perehdytystyökalu päivittää suoraan `container_image:` -määritykset kaikissa YAML-profiileissa hakemistossa `config/profiles/**/*.yaml`:

```bash
# 1. Päivitä kaikki YAML-profiilit käyttämään Artifactory-peilejä:
./scripts/onboard-enterprise.sh --patch-profiles

# 2. Tarkista profiilien nykytila:
./scripts/onboard-enterprise.sh --status
```

### Välitön palautus (Rollback)

Jos haluat palata virallisiin julkisiin rekistereihin:

```bash
./scripts/onboard-enterprise.sh --revert
```

---

## 4. Vuorovaikutteinen asennusvelho

Uudet kehittäjät voivat ajaa vuorovaikutteisen opastuksen:

```bash
./scripts/onboard-enterprise.sh --interactive
```

---

## 5. Verkkoyhteyksien validointi

Varmista, että työasema pystyy kommunikoimaan yritysrekisterin ja välityspalvelimen kanssa:

```bash
./scripts/onboard-enterprise.sh --validate
```

---

## 6. Developer Hub -integraatio

Yritysasetukset ja pikakomennot on integroitu Developer Hubiin ([`docs/dev-hub.html`](../dev-hub.html)):
- Siirry välilehdelle **Työkalut & Komennot**.
- Avaa **Yrityksen asetukset ja Artifactory-peilit** kopioidaksesi komentorivikomennot tai suorittaaksesi kuntotestin.

---

## 7. Yritysasiakirjamallien Brändäys ja Saavutettavuus (PDF/UA-1 & WCAG 2.1 AA)

Uusia yritysjärjestelmiä käyttöön otettaessa tulostettavien asiakirjamallien (laskut, lähetteet, talousraportit) on noudatettava yrityksen visuaalista ilmettä sekä lakisääteisiä saavutettavuusvaatimuksia (**Euroopan saavutettavuusdirektiivi / EN 301 549, US Section 508, PDF/UA-1 ISO 14289-1**).

### 1. Keskitetty Kuvavarasto ja Logon Hallinta (Single Source of Assets)
Välttääksesi konekohtaisten tiedostopolkujen (kuten `C:\logo.png`) kovakoodaamista:
1. **Työaseman Tiedostovarasto:** Tallenna yrityksen virallinen logo hakemistoon:
   ```text
   templates/publisher/common/images/company_logo.png
   ```
2. **Kontin Polkukuvaus:** Suunnittelukontti liittää hakemiston automaattisesti polkuun `/u01/common/images/company_logo.png`.
3. **Dynaaminen Viittaus Mallissa:** Lisää Microsoft Wordissa tai LibreOffice Writerissa paikkamerkkikuva, napsauta hiiren kakkospainikkeella **Ominaisuudet / Kuvaus / Verkko** ja määritä dynaaminen Oracle XDO -URL:
   ```text
   url:{concat($IMAGE_DIR, '/company_logo.png')}
   ```
   Aseta vaihtoehtoiseksi tekstiksi (Alt-teksti) virallinen kuvaus: `Yrityksen virallinen logo`.
4. **Automaattinen Palvelinsynkronointi:** Ajettaessa `./scripts/publisher/deploy-publisher-reports.sh`, hakemiston `common/images/` sisältö synkronoidaan automaattisesti testi- ja tuotantopalvelinten Publisher-katalogeihin.

### 2. Saavutettava Aloitusmalli (`accessible_starter_template.rtf`)
Alusta sisältää valmiin, säädöstenmukaisen pohjamallin:
[`templates/publisher/samples/accessible_starter_template.rtf`](../../templates/publisher/samples/accessible_starter_template.rtf)

Ominaisuudet:
- **`\trhdr` Taulukon Otsikkorivin Toisto:** Varmistaa, että ruudunlukijat toistavat sarakkeiden otsikot jokaisella sivulla monisivuisissa taulukoissa.
- **Summary-First Talousosio:** Laskun keskeiset tiedot (loppusumma, eräpäivä, IBAN) esitetään selkeästi heti sivun yläosassa.
- **Tiukka WCAG AA Väriristiriita:** Tummansininen (`#0A3663`) ja tummanharmaa (`#222222`), jotka saavuttavat valkoisella taustalla **7.1:1 kontrastisuhteen** (ylittäen 4.5:1 minimivaatimuksen).
- **Sisäänrakennettu PDF/UA-1 Rakennepuu:** Semanttiset otsikot (`Heading 1`, `Heading 2`), taulukkotunnisteet (`/S/Table`, `/S/TR`, `/S/TH`, `/S/TD`) ja metatiedot.

### 3. Automaattinen Saavutettavuusauditointi ja Ruudunlukijasimulaattori
Ennen mallien julkaisua tarkista vaatimustenmukaisuus komentorivityökaluilla:

```bash
# 1. Auditoi RTF-malli ja saa selkeät korjausohjeet:
./scripts/publisher/validate-rtf-accessibility.sh templates/publisher/samples/accessible_starter_template.rtf

# 2. Validoi generoitu PDF ja tarkastele ruudunlukijan puhetranskriptiota:
./scripts/publisher/validate-pdf-accessibility.sh build/accessible_starter_template_fi.pdf
```

### 4. Nollatoleranssin CI/CD Laatuportti
Automaattitestaus tarkistaa saavutettavuuden jatkuvassa integraatiossa:
```bash
./tests/integration/test-publisher-accessibility-suite.sh
```
Testisarja vaatii **100% vaatimustenmukaisuuden** ennen kuin mallit hyväksytään tuotantoon.
