# Įmonės konfigūravimas ir registrų veidrodžių diegimo vadovas

[ 🇬🇧 English ](../enterprise-onboarding-guide.md) | [ 🇪🇪 Eesti ](../et/enterprise-onboarding-guide.md) | [ 🇫🇮 Suomi ](../fi/enterprise-onboarding-guide.md) | [ 🇸🇪 Svenska ](../sv/enterprise-onboarding-guide.md) | [ 🇱🇻 Latviešu ](../lv/enterprise-onboarding-guide.md) | [ 🇱🇹 Lietuvių ](enterprise-onboarding-guide.md)

---

## 1. Apžvalga ir architektūros tikslas

Įmonių IT aplinkoje kūrėjų darbo vietos ir gamybiniai serveriai dažnai veikia uždaruose įmonės tinkluose be tiesioginės prieigos prie viešų konteinerių registrų (`container-registry.oracle.com`, `docker.io`, `ghcr.io`). Įmonės politika reikalauja konteinerių atvaizdus ir dvejetainius failus siųstis per **vidines artefaktų talpyklas** (JFrog Artifactory, Harbor, Sonatype Nexus), nukreipiant išeinantį srautą per TLS tikrinančius tarpinius serverius (Zscaler, Netskope) ir pasitikint įmonės vidinėmis sertifikavimo įstaigomis (Root CA).

Šiame vadove paaiškinama:
1. Kaip apibrėžti įmonės infrastruktūrą faile [`config/enterprise.yaml`](../../config/enterprise.yaml).
2. Kaip naudoti integracijos įrankį [`scripts/onboard-enterprise.sh`](../../scripts/onboard-enterprise.sh).
3. Kaip tiesiogiai atnaujinti YAML profilius diske (`--patch-profiles`).
4. Kaip atkurti profilius į viešus registrus (`--revert`).
5. Kaip konfigūruoti tarpinius serverius, CA sertifikatus ir vidinius domenus.
6. Kaip pritaikyti įmonės dokumentų šablonus ir užtikrinti prieinamumą (PDF/UA-1, WCAG 2.1 AA).

---

## 2. Įmonės bendras konfigūracijos šaltinis (`config/enterprise.yaml`)

Platforma pateikia centralizuotą konfigūracijos šabloną faile [`config/enterprise.yaml.example`](../../config/enterprise.yaml.example). Norėdami jį aktyvuoti:

```bash
cp config/enterprise.yaml.example config/enterprise.yaml
```

### Konfigūracijos skyriai

```yaml
enterprise:
  name: "Įmonės Pavadinimas"
  environment: "production" # development | test | staging | production

# 1. Vidinis konteinerių registras ir Artifactory veidrodis
registry:
  base_url: "artifactory.corp.internal/docker-mirror"
  auth_mode: "anonymous" # anonymous | podman_secret | token
  mappings:
    "container-registry.oracle.com/database/free": "artifactory.corp.internal/docker-mirror/oracle/database/free"
    "container-registry.oracle.com/database/ords": "artifactory.corp.internal/docker-mirror/oracle/database/ords"
    "container-registry.oracle.com/database/sqlcl": "artifactory.corp.internal/docker-mirror/oracle/database/sqlcl"
    "docker.io/library/ubuntu": "artifactory.corp.internal/docker-mirror/dockerhub/library/ubuntu"
    "ghcr.io": "artifactory.corp.internal/docker-mirror/ghcr"

# 2. Tarpinis serveris ir CA pasitikėjimas
network:
  http_proxy: "http://proxy.corp.internal:8080"
  https_proxy: "http://proxy.corp.internal:8080"
  no_proxy: "localhost,127.0.0.1,*.corp.internal,.local,podman-machine-default"
  corporate_ca_bundle_path: "/etc/pki/ca-trust/source/anchors/corp-root-ca.crt"

# 3. Įmonės domenas ir TLS
domain:
  internal_domain: "corp.internal"
  custom_tls_cert: ""
  custom_tls_key: ""

# 4. Saugumo ir audito politika
security:
  enforce_seps_wallet: true
  mask_tokens_in_logs: true
  audit_level: "strict"
```

---

## 3. Tiesioginis profilių koregavimas diske

Siekdamas visiško skaidrumo, įrankis tiesiogiai atnaujina `container_image:` deklaracijas visuose YAML profiliuose kataloge `config/profiles/**/*.yaml`:

```bash
# 1. Pritaikyti visus YAML profilius Artifactory veidrodžiams:
./scripts/onboard-enterprise.sh --patch-profiles

# 2. Patikrinti profilių būseną:
./scripts/onboard-enterprise.sh --status
```

### Greitas atkūrimas (Rollback)

Norėdami grįžti prie oficialių registrų:

```bash
./scripts/onboard-enterprise.sh --revert
```

---

## 4. Interaktyvus vedlys

Nauji kūrėjai gali paleisti interaktyvų vedlį:

```bash
./scripts/onboard-enterprise.sh --interactive
```

---

## 5. Tinklo ryšio patikra

Patikrinkite ryšį su įmonės registru ir tarpiniu serveriu:

```bash
./scripts/onboard-enterprise.sh --validate
```

---

## 6. Developer Hub integracija

Įmonės nustatymai ir greitosios komandos yra integruotos į Developer Hub ([`docs/dev-hub.html`](../dev-hub.html)):
- Eikite į skirtuką **Įrankiai ir Komandos**.
- Pasirinkite kortelę **Įmonės nustatymai ir Artifactory veidrodžiai**, norėdami nukopijuoti komandas ar atlikti diagnostiką.

---

## 7. Įmonės Dokumentų Šablonų Prekių Ženklas ir Prieinamumas (PDF/UA-1 & WCAG 2.1 AA)

Diegiant naujas įmonės sistemas, generuojami dokumentų šablonai (sąskaitos-faktūros, važtaraščiai, finansinės ataskaitos) privalo atitikti įmonės vizualinį stilių ir privalomus prieinamumo reikalavimus (**Europos Prieinamumo aktas / EN 301 549, JAV Section 508, PDF/UA-1 ISO 14289-1**).

### 1. Centralizuota Vaizdų Saugykla ir Logotipo Valdymas (Single Source of Assets)
Norint išvengti fiksuotų vietinių kelių (pvz., `C:\logo.png`) kodo lygmenyje:
1. **Pagrindinio Kompiuterio Saugykla:** Išsaugokite oficialų įmonės logotipą kataloge:
   ```text
   templates/publisher/common/images/company_logo.png
   ```
2. **Konteinerio Kelias:** Dizaino konteineris automatiškai prijungia katalogą kelyje `/u01/common/images/company_logo.png`.
3. **Dinaminė Nuoroda Šablone:** Įterpkite vietos žymeklio paveikslėlį programoje „Word“ arba „LibreOffice Writer“, dešiniuoju pelės mygtuku pasirinkite **Properties / Description / Web** ir įrašykite „Oracle XDO“ URL:
   ```text
   url:{concat($IMAGE_DIR, '/company_logo.png')}
   ```
   Nustatykite alternatyvųjį tekstą (Alt Text): `Oficialus įmonės logotipas`.
4. **Automatinis Serverių Sinchronizavimas:** Paleidus `./scripts/publisher/deploy-publisher-reports.sh`, aplanko `common/images/` turinys automatiškai sinchronizuojamas su tikslinių serverių „Publisher“ katalogais.

### 2. Prieinamas Pradinis Šablonas (`accessible_starter_template.rtf`)
Platforma pateikia standartizuotą ir reikalavimus atitinkantį pradinį šabloną:
[`templates/publisher/samples/accessible_starter_template.rtf`](../../templates/publisher/samples/accessible_starter_template.rtf)

Savybės:
- **`\trhdr` Lentelės Antraštės Eilutės Kartojimas:** Užtikrina, kad ekrano skaitytuvai perskaitytų stulpelių antraštes kiekviename kelių puslapių lentelės puslapyje.
- **Summary-First Finansinis Blokas:** Sąskaitos suvestinė (mokėtina suma, terminas, IBAN) pateikiama pačioje dokumento pradžioje.
- **Griežtas WCAG AA Spalvų Kontrastas:** Tamsiai mėlyna (`#0A3663`) ir tamsiai pilka (`#222222`), pasiekianti **7.1:1 kontrasto santykį** baltame fone (viršijant 4.5:1 normą).
- **Integruotos PDF/UA-1 Struktūros Žymos:** Semantinės antraštės (`Heading 1`, `Heading 2`), lentelių žymos (`/S/Table`, `/S/TR`, `/S/TH`, `/S/TD`) ir metaduomenys.

### 3. Automatizuotas Prieinamumo Auditas ir Ekrano Skaitytuvo Simuliatorius
Prieš diegdami į gamybą patikrinkite atitiktį naudodami CLI įrankius:

```bash
# 1. Patikrinti RTF šabloną ir gauti aiškias taisymo instrukcijas:
./scripts/publisher/validate-rtf-accessibility.sh templates/publisher/samples/accessible_starter_template.rtf

# 2. Patvirtinti sugeneruotą PDF ir peržiūrėti ekrano skaitytuvo transkripciją:
./scripts/publisher/validate-pdf-accessibility.sh build/accessible_starter_template_lt.pdf
```

### 4. Nulinės Tolerancijos CI/CD Kokybės Vartai
Automatiniai testai tikrina prieinamumą kiekvieno kodo atnaujinimo metu:
```bash
./tests/integration/test-publisher-accessibility-suite.sh
```
Testų rinkinys reikalauja **100% atitikties**, kad šablonai būtų patvirtinti gamybai.
