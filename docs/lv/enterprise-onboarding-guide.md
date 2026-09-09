# Uzņēmuma ievadīšana un reģistru spoguļu uzstādīšanas rokasgrāmata

[ 🇬🇧 English ](../enterprise-onboarding-guide.md) | [ 🇪🇪 Eesti ](../et/enterprise-onboarding-guide.md) | [ 🇫🇮 Suomi ](../fi/enterprise-onboarding-guide.md) | [ 🇸🇪 Svenska ](../sv/enterprise-onboarding-guide.md) | [ 🇱🇻 Latviešu ](enterprise-onboarding-guide.md) | [ 🇱🇹 Lietuvių ](../lt/enterprise-onboarding-guide.md)

---

## 1. Pārskats un arhitektūras mērķis

Uzņēmumu IT vidē izstrādātāju darbstacijas un produkcijas serveri bieži darbojas slēgtos korporatīvajos tīklos bez tiešas piekļuves publiskajiem konteineru reģistriem (`container-registry.oracle.com`, `docker.io`, `ghcr.io`). Korporatīvā politika pieprasa konteineru attēlus un bināros failus lejupielādēt caur **iekšējām artefaktu krātuvēm** (JFrog Artifactory, Harbor, Sonatype Nexus), maršrutējot izejošo datplūsmu caur TLS pārbaudes starpniekserveriem (Zscaler, Netskope) un uzticoties iekšējām sertifikātu iestādēm (Root CA).

Šī rokasgrāmata izskaidro:
1. Kā definēt korporatīvo infrastruktūru failā [`config/enterprise.yaml`](../../config/enterprise.yaml).
2. Kā izmantot integrācijas rīku [`scripts/onboard-enterprise.sh`](../../scripts/onboard-enterprise.sh).
3. Kā tieši atjaunināt YAML profilus diskā (`--patch-profiles`).
4. Kā atjaunot profilus uz publiskajiem reģistriem (`--revert`).
5. Kā konfigurēt starpniekserverus, CA sertifikātus un iekšējos domēnus.
6. Kā pielāgot uzņēmuma dokumentu veidnes un nodrošināt piekļūstamību (PDF/UA-1, WCAG 2.1 AA).

---

## 2. Uzņēmuma vienotais konfigurācijas avots (`config/enterprise.yaml`)

Platforma nodrošina centralizētu konfigurācijas paraugu failā [`config/enterprise.yaml.example`](../../config/enterprise.yaml.example). Lai to aktivizētu:

```bash
cp config/enterprise.yaml.example config/enterprise.yaml
```

### Konfigurācijas sadaļas

```yaml
enterprise:
  name: "Uzņēmuma Nosaukums"
  environment: "production" # development | test | staging | production

# 1. Iekšējais konteineru reģistrs un Artifactory spogulis
registry:
  base_url: "artifactory.corp.internal/docker-mirror"
  auth_mode: "anonymous" # anonymous | podman_secret | token
  mappings:
    "container-registry.oracle.com/database/free": "artifactory.corp.internal/docker-mirror/oracle/database/free"
    "container-registry.oracle.com/database/ords": "artifactory.corp.internal/docker-mirror/oracle/database/ords"
    "container-registry.oracle.com/database/sqlcl": "artifactory.corp.internal/docker-mirror/oracle/database/sqlcl"
    "docker.io/library/ubuntu": "artifactory.corp.internal/docker-mirror/dockerhub/library/ubuntu"
    "ghcr.io": "artifactory.corp.internal/docker-mirror/ghcr"

# 2. Starpniekserveris un CA uzticamība
network:
  http_proxy: "http://proxy.corp.internal:8080"
  https_proxy: "http://proxy.corp.internal:8080"
  no_proxy: "localhost,127.0.0.1,*.corp.internal,.local,podman-machine-default"
  corporate_ca_bundle_path: "/etc/pki/ca-trust/source/anchors/corp-root-ca.crt"

# 3. Uzņēmuma domēns un TLS
domain:
  internal_domain: "corp.internal"
  custom_tls_cert: ""
  custom_tls_key: ""

# 4. Drošības un audita politika
security:
  enforce_seps_wallet: true
  mask_tokens_in_logs: true
  audit_level: "strict"
```

---

## 3. Tieša profilu labošana diskā

Lai saglabātu pilnīgu caurskatāmību, rīks tieši atjaunina `container_image:` deklarācijas visos YAML profilos mapē `config/profiles/**/*.yaml`:

```bash
# 1. Pielāgot visus YAML profilus Artifactory spoguļiem:
./scripts/onboard-enterprise.sh --patch-profiles

# 2. Pārbaudīt profilu statusu:
./scripts/onboard-enterprise.sh --status
```

### Tūlītēja atjaunošana (Rollback)

Lai atgrieztos pie oficiālajiem reģistriem:

```bash
./scripts/onboard-enterprise.sh --revert
```

---

## 4. Interaktīvais vednis

Jauni izstrādātāji var palaist interaktīvo vedni:

```bash
./scripts/onboard-enterprise.sh --interactive
```

---

## 5. Tīkla savienojamības pārbaude

Pārbaudiet savienojumu ar uzņēmuma reģistru un starpniekserveri:

```bash
./scripts/onboard-enterprise.sh --validate
```

---

## 6. Developer Hub integrācija

Uzņēmuma iestatījumi un ātrās komandas ir integrētas Developer Hub ([`docs/dev-hub.html`](../dev-hub.html)):
- Atveriet cilni **Rīki un Komandas**.
- Izvēlieties kartīti **Uzņēmuma iestatījumi un Artifactory spoguļi**, lai kopētu termināļa komandas vai veiktu diagnostiku.

---

## 7. Uzņēmuma Dokumentu Zīmolvedība un Piekļūstamība (PDF/UA-1 & WCAG 2.1 AA)

Ieviešot jaunas uzņēmuma sistēmas, dokumentu veidnēm (rēķiniem, pavadzīmēm, finanšu atskaitēm) ir jāatbilst uzņēmuma vizuālajai identitātei un obligātajām piekļūstamības prasībām (**Eiropas Piekļūstamības akts / EN 301 549, ASV Section 508, PDF/UA-1 ISO 14289-1**).

### 1. Centralizēta Attēlu Krātuve un Logo Pārvaldība (Single Source of Assets)
Lai izvairītos no lokālo ceļu (piem., `C:\logo.png`) iekļaušanas kodā:
1. **Saimniekdatora Krātuve:** Saglabājiet oficiālo uzņēmuma logotipu mapē:
   ```text
   templates/publisher/common/images/company_logo.png
   ```
2. **Konteinera Ceļš:** Dizaina konteiners to automātiski piemontē ceļā `/u01/common/images/company_logo.png`.
3. **Dinamiska Atsauce Veidnē:** Ievietojiet viettura attēlu Word vai LibreOffice Writer, ar labo peles pogu izvēlieties **Properties / Description / Web** un ievadiet Oracle XDO URL:
   ```text
   url:{concat($IMAGE_DIR, '/company_logo.png')}
   ```
   Iestatiet alternatīvo tekstu (Alt Text): `Uzņēmuma oficiālais logo`.
4. **Automātiska Serveru Sinhronizācija:** Izpildot `./scripts/publisher/deploy-publisher-reports.sh`, mapes `common/images/` saturs tiek automātiski sinhronizēts ar mērķa Publisher katalogiem.

### 2. Piekļūstama Sākuma Veidne (`accessible_starter_template.rtf`)
Platforma nodrošina standartizētu un prasībām atbilstošu sākuma veidni:
[`templates/publisher/samples/accessible_starter_template.rtf`](../../templates/publisher/samples/accessible_starter_template.rtf)

Īpašības:
- **`\trhdr` Tabulas Galvenes Rindas Atkārtošana:** Nodrošina, ka ekrānlasītāji atkārto kolonnu nosaukumus katrā daudzlappušu tabulas lapā.
- **Summary-First Finanšu Bloks:** Rēķina kopsavilkums (apmaksājamā summa, termiņš, IBAN) ir novietots uzreiz dokumenta augšpusē.
- **Stingrs WCAG AA Krāsu Kontrasts:** Tumši zils (`#0A3663`) un tumši pelēks (`#222222`), sasniedzot **7.1:1 kontrasta attiecību** pret baltu fonu (pārsniedzot likumā prasīto 4.5:1).
- **Iebūvēti PDF/UA-1 Struktūras Tagus:** Semantiskie virsraksti (`Heading 1`, `Heading 2`), tabulu tagi (`/S/Table`, `/S/TR`, `/S/TH`, `/S/TD`) un metadati.

### 3. Automatizēts Piekļūstamības Audits un Ekrānlasītāja Simulators
Pārbaudiet atbilstību pirms ieviešanas produkcijā:

```bash
# 1. Pārbaudīt RTF veidni un saņemt skaidrus labošanas soļus:
./scripts/publisher/validate-rtf-accessibility.sh templates/publisher/samples/accessible_starter_template.rtf

# 2. Validēt ģenerēto PDF un noklausīties imitēto ekrānlasītāja runas transkripciju:
./scripts/publisher/validate-pdf-accessibility.sh build/accessible_starter_template_lv.pdf
```

### 4. Nulles Pielaide CI/CD Kvalitātes Vārtos
Automatizētie testi pārbauda piekļūstamību katrā koda atjauninājumā:
```bash
./tests/integration/test-publisher-accessibility-suite.sh
```
Testu kopa prasa **100% atbilstību** pirms veidņu apstiprināšanas produkcijai.
