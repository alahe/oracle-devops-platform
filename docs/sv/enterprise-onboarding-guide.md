# Företagsonboarding och guide för registerspegling

[ 🇬🇧 English ](../enterprise-onboarding-guide.md) | [ 🇪🇪 Eesti ](../et/enterprise-onboarding-guide.md) | [ 🇫🇮 Suomi ](../fi/enterprise-onboarding-guide.md) | [ 🇸🇪 Svenska ](enterprise-onboarding-guide.md) | [ 🇱🇻 Latviešu ](../lv/enterprise-onboarding-guide.md) | [ 🇱🇹 Lietuvių ](../lt/enterprise-onboarding-guide.md)

---

## 1. Översikt och arkitekturens syfte

I företagsmiljöer körs utvecklingsarbetsstationer och produktionsservrar ofta i slutna företagsnätverk utan direkt åtkomst till publika containerregister (`container-registry.oracle.com`, `docker.io`, `ghcr.io`). Företagspolicy kräver att containeravbildningar och binärer hämtas via **interna artefaktarkiv** (JFrog Artifactory, Harbor, Sonatype Nexus), utgående trafik dirigeras via TLS-inspekterande proxyservrar (Zscaler, Netskope) och företagsinterna certifikatutfärdare (Root CA) betros.

Denna guide beskriver:
1. Hur företagsinfrastruktur konfigureras i [`config/enterprise.yaml`](../../config/enterprise.yaml).
2. Hur onboardningsverktyget [`scripts/onboard-enterprise.sh`](../../scripts/onboard-enterprise.sh) används.
3. Hur profil-YAML uppdateras explicit på disk (`--patch-profiles`).
4. Hur profiler återställs till publika register (`--revert`).
5. Hur proxyservrar, CA-certifikat och interna domäner konfigureras.
6. Hur företagsdokumentmallar anpassas för visuell identitet och tillgänglighet (PDF/UA-1, WCAG 2.1 AA).

---

## 2. Företagets centrala konfiguration (`config/enterprise.yaml`)

Plattformen tillhandahåller en central konfigurationsmall i [`config/enterprise.yaml.example`](../../config/enterprise.yaml.example). Aktivera den:

```bash
cp config/enterprise.yaml.example config/enterprise.yaml
```

### Konfigurationsavsnitt

```yaml
enterprise:
  name: "Företagsnamn"
  environment: "production" # development | test | staging | production

# 1. Internt containerregister och Artifactory-spegel
registry:
  base_url: "artifactory.corp.internal/docker-mirror"
  auth_mode: "anonymous" # anonymous | podman_secret | token
  mappings:
    "container-registry.oracle.com/database/free": "artifactory.corp.internal/docker-mirror/oracle/database/free"
    "container-registry.oracle.com/database/ords": "artifactory.corp.internal/docker-mirror/oracle/database/ords"
    "container-registry.oracle.com/database/sqlcl": "artifactory.corp.internal/docker-mirror/oracle/database/sqlcl"
    "docker.io/library/ubuntu": "artifactory.corp.internal/docker-mirror/dockerhub/library/ubuntu"
    "ghcr.io": "artifactory.corp.internal/docker-mirror/ghcr"

# 2. Proxy och CA-förtroende
network:
  http_proxy: "http://proxy.corp.internal:8080"
  https_proxy: "http://proxy.corp.internal:8080"
  no_proxy: "localhost,127.0.0.1,*.corp.internal,.local,podman-machine-default"
  corporate_ca_bundle_path: "/etc/pki/ca-trust/source/anchors/corp-root-ca.crt"

# 3. Företagsdomän och TLS
domain:
  internal_domain: "corp.internal"
  custom_tls_cert: ""
  custom_tls_key: ""

# 4. Säkerhets- och granskningspolicy
security:
  enforce_seps_wallet: true
  mask_tokens_in_logs: true
  audit_level: "strict"
```

---

## 3. Explicit profilkorrigering på disk

För fullständig transparens uppdaterar verktyget direkt `container_image:` -deklarationer i alla YAML-profiler under `config/profiles/**/*.yaml`:

```bash
# 1. Uppdatera alla YAML-profiler till Artifactory-speglar:
./scripts/onboard-enterprise.sh --patch-profiles

# 2. Inspektera profilernas status:
./scripts/onboard-enterprise.sh --status
```

### Återställning (Rollback)

För att återgå till officiella publika register:

```bash
./scripts/onboard-enterprise.sh --revert
```

---

## 4. Interaktiv onboardningsguide

Nya utvecklare kan köra den interaktiva guiden:

```bash
./scripts/onboard-enterprise.sh --interactive
```

---

## 5. Nätverksvalidering

Verifiera anslutningen till företagsregistret och proxyn:

```bash
./scripts/onboard-enterprise.sh --validate
```

---

## 6. Developer Hub-integration

Företagsinställningar och snabbkommandon är integrerade i Developer Hub ([`docs/dev-hub.html`](../dev-hub.html)):
- Gå till fliken **Verktyg & Kommandon**.
- Välj kortet **Företagskonfiguration och Artifactory-speglar** för att kopiera terminalkommandon eller köra diagnostik.

---

## 7. Företagsdokumentmallars Varumärke och Tillgänglighet (PDF/UA-1 & WCAG 2.1 AA)

Vid driftsättning av nya system måste affärsdokumentmallar (fakturor, följesedlar, finansiella rapporter) uppfylla företagets grafiska profil och lagstadgade tillgänglighetskrav (**Europeiska tillgänglighetsdirektivet / EN 301 549, US Section 508, PDF/UA-1 ISO 14289-1**).

### 1. Central Bildlagring och Logohantering (Single Source of Assets)
För att undvika hårdkodade lokala filsökvägar (som `C:\logo.png`):
1. **Värdfilsarkiv:** Spara företagets officiella högupplösta logotyp i:
   ```text
   templates/publisher/common/images/company_logo.png
   ```
2. **Containersökväg:** Designcontainern monterar automatiskt mappen på `/u01/common/images/company_logo.png`.
3. **Dynamisk Referens i Mall:** Lägg till en platshållarbild i Word eller LibreOffice Writer, högerklicka -> **Egenskaper / Beskrivning / Webb** och ange Oracle XDO URL:
   ```text
   url:{concat($IMAGE_DIR, '/company_logo.png')}
   ```
   Ange alternativtext (Alt-text): `Företagets officiella logotyp`.
4. **Automatisk Serversynkronisering:** Vid körning av `./scripts/publisher/deploy-publisher-reports.sh` synkroniseras `common/images/` automatiskt till målservrarnas Publisher-kataloger.

### 2. Tillgänglig Startmall (`accessible_starter_template.rtf`)
Plattformen inkluderar en standardiserad grundmall:
[`templates/publisher/samples/accessible_starter_template.rtf`](../../templates/publisher/samples/accessible_starter_template.rtf)

Egenskaper:
- **`\trhdr` Upprepad Tabellrubrikrad:** Säkerställer att skärmläsare läser upp kolumnrubriker på varje sida i flersidiga tabeller.
- **Summary-First Ekonomiblock:** Fakturans viktigaste uppgifter (totalsumma, förfallodatum, IBAN) presenteras tydligt högst upp.
- **Strikt WCAG AA Färgkontrast:** Mörkblå (`#0A3663`) och mörkgrå (`#222222`), som uppnår **7.1:1 kontrastförhållande** mot vit bakgrund (långt över 4.5:1 lagkravet).
- **Inbäddade PDF/UA-1 Strukturtaggar:** Semantiska rubriker (`Heading 1`, `Heading 2`), tabelltaggar (`/S/Table`, `/S/TR`, `/S/TH`, `/S/TD`) och dokumentmetadata.

### 3. Automatiserad Tillgänglighetsrevision & Skärmläsarsimulator
Kontrollera tillgängligheten före produktionsdriftsättning:

```bash
# 1. Granska RTF-mallen och få konkreta åtgärdsförslag:
./scripts/publisher/validate-rtf-accessibility.sh templates/publisher/samples/accessible_starter_template.rtf

# 2. Validera genererad PDF och lyssna på simulerad skärmläsartranskription:
./scripts/publisher/validate-pdf-accessibility.sh build/accessible_starter_template_sv.pdf
```

### 4. Nolltolerans CI/CD Kvalitetsgrind
Automatiserade tester kontrollerar tillgänglighet vid varje ändring:
```bash
./tests/integration/test-publisher-accessibility-suite.sh
```
Testsviten kräver **100% efterlevnad** innan mallar godkänns för produktion.
