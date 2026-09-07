# Ettevõtte onboarding ja registripeeglite seadistusjuhend
[ 🇬🇧 English ](../enterprise-onboarding-guide.md) | [ 🇪🇪 Eesti ](enterprise-onboarding-guide.md) | [ 🇫🇮 Suomi ](../fi/enterprise-onboarding-guide.md) | [ 🇸🇪 Svenska ](../sv/enterprise-onboarding-guide.md) | [ 🇱🇻 Latviešu ](../lv/enterprise-onboarding-guide.md) | [ 🇱🇹 Lietuvių ](../lt/enterprise-onboarding-guide.md)

---

## 1. Ülevaade ja eesmärk
Ettevõtte IT-keskkonnas töötavad arendustöökohad ja serverid suletud sisevõrgus, kus puudub otsene väljapääs avalikesse konteineriregistritesse (`container-registry.oracle.com`, `docker.io`, `ghcr.io`). Turvanõuete kohaselt tuleb konteineripildid ja binaarid laadida **ettevõtte sise-Artifactory või Harbor peeglist**, väljuv võrguliiklus suunata läbi korporatiivse TLS-proksi (Zscaler, Netskope) ning usaldada sisevõrgu Root CA sertifikaate.

Käesolev juhend selgitab:
1. Kuidas kirjeldada ettevõtte taristut failis [`config/enterprise.yaml`](../../config/enterprise.yaml).
2. Kuidas kasutada käsureatööriista [`scripts/onboard-enterprise.sh`](../../scripts/onboard-enterprise.sh).
3. Kuidas muuta profiilide YAML-failides väärtused ilmutatud kujul kettal käsuga `--patch-profiles`.
4. Kuidas profiilid igal ajal algsetele avalikele registritele tagasi pöörata käsuga `--revert`.
5. Kuidas seadistada proksit, CA sertifikaate ja sisedomeene.

---

## 2. Ettevõtte konfiguratsioon (`config/enterprise.yaml`)
Platvorm pakub keskset malli [`config/enterprise.yaml.example`](../../config/enterprise.yaml.example). Selle aktiveerimiseks:

```bash
cp config/enterprise.yaml.example config/enterprise.yaml
```

### Seadistuse struktuur

```yaml
enterprise:
  name: "Ettevõte"
  environment: "production" # development | test | staging | production

# 1. Sise-artifactory ja konteinerite peegeldus
registry:
  base_url: "artifactory.corp.internal/docker-mirror"
  auth_mode: "anonymous" # anonymous | podman_secret | token
  mappings:
    "container-registry.oracle.com/database/free": "artifactory.corp.internal/docker-mirror/oracle/database/free"
    "container-registry.oracle.com/database/ords": "artifactory.corp.internal/docker-mirror/oracle/database/ords"
    "container-registry.oracle.com/database/sqlcl": "artifactory.corp.internal/docker-mirror/oracle/database/sqlcl"
    "docker.io/library/ubuntu": "artifactory.corp.internal/docker-mirror/dockerhub/library/ubuntu"
    "ghcr.io": "artifactory.corp.internal/docker-mirror/ghcr"

# 2. Korporatiivne Proxy ja CA usaldus
network:
  http_proxy: "http://proxy.corp.internal:8080"
  https_proxy: "http://proxy.corp.internal:8080"
  no_proxy: "localhost,127.0.0.1,*.corp.internal,.local,podman-machine-default"
  corporate_ca_bundle_path: "/etc/pki/ca-trust/source/anchors/corp-root-ca.crt"

# 3. Sisedomeen ja TLS sertifikaadid
domain:
  internal_domain: "corp.internal"
  custom_tls_cert: ""
  custom_tls_key: ""

# 4. Turvalisus ja audit
security:
  enforce_seps_wallet: true
  mask_tokens_in_logs: true
  audit_level: "strict"
```

---

## 3. Profiilide ilmutatud muutmine kettal

Täieliku läbipaistvuse tagamiseks ja käitusaegse peidetud asendamise vältimiseks uuendab onboarding-tööriist otse kettal kõiki faili `config/profiles/**/*.yaml` `container_image:` kirjeid:

```bash
# 1. Asenda profiilides avalikud registrid ettevõtte artifactory peegliga:
./scripts/onboard-enterprise.sh --patch-profiles

# 2. Kontrolli profiilide hetkeseisu:
./scripts/onboard-enterprise.sh --status
```

### Kiire algseisu taastamine (rollback)
Kui soovite pöörduda tagasi ametlikele avalikele registritele:

```bash
./scripts/onboard-enterprise.sh --revert
```

Skript taastab automaatselt failid loodud `.bak` varukoopiatest või pöörab URL-ide asendused tagasi.

---

## 4. Interaktiivne onboarding-viisard

Uued arendajad saavad seadistuse läbida viisardi abil:

```bash
./scripts/onboard-enterprise.sh --interactive
```

Viisard küsib organisatsiooni nime, Artifactory baasaadressi, proksi ja CA sertifikaadi asukoha, loob faili `config/enterprise.yaml` ning pakub profiilide kohest uuendamist.

---

## 5. Võrguühenduse valideerimine
Kontrollige ühenduvust sise-Artifactory ja proksiga:

```bash
./scripts/onboard-enterprise.sh --validate
```

---

## 6. Developer Hub integratsioon
Ettevõtte seadistused ja kiirkäsud on integreeritud Developer Hubi veebiliidesesse ([`docs/dev-hub.html`](../dev-hub.html)):
- Ava vahekaart **Tööriistad & Skriptid**.
- Vali kaart **Ettevõtte seadistus ja Artifactory peeglid**, et kopeerida terminalikäsud või käivitada olekukontroll.
