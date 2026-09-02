[ 🇬🇧 English ](../artifactory-setup.md) | [ 🇪🇪 Eesti ](artifactory-setup.md) | [ 🇫🇮 Suomi ](../fi/artifactory-setup.md) | [ 🇸🇪 Svenska ](../sv/artifactory-setup.md) | [ 🇱🇻 Latviešu ](../lv/artifactory-setup.md) | [ 🇱🇹 Lietuvių ](../lt/artifactory-setup.md)

# 🏢 Ettevõtte Artifactory Hoidla, Tootekataloog & Zero-Trust Metaandmete Juhend

Tulemüüriga piiratud, suletud võrguga (*air-gapped*) või rangete turvanõuetega ettevõtte keskkonnas võimaldab platvorm suunata nii binaarpaketid (ORDS ja APEX `.zip` failid), veaparandused kui ka Kuldsed Hetktõmmised ettevõtte sisesesse **JFrog Artifactory**, **Harbor**, **Nexus** või **GitLab Container Registry** hoidlasse.

---

## 🎯 1. Peamised Eelised & LAN FastPath

1. **🚀 ~15s LAN Kiirpaigaldus (FastPath):** Kuldsete Hetktõmmiste ja OCI konteineripiltide allalaadimine sisevõrgu LAN-ist võtab 5–15 sekundit (avalikust internetist 5–15 min).
2. **📑 Kergekaaluline `.meta.json` Eelkontroll:** Enne gigabaitide allalaadimist laaditakse alla väike `.meta.json` (< 1 KB), et kontrollida APEX, DB ja middleware versioone.
3. **🔒 Zero-Trust Autentimine:** JIT tokeni päring **Azure Key Vaultist** (`az keyvault secret show`) või krüpteeritud **Oracle SEPS Walletist** (`cwallet.sso`). Kettale plaintext faile ei tekitata.
4. **🛡️ 1-to-1 Tootekeskne Sümmeetria:** Identsed kataloogipuud Artifactorys ja arendaja kohalikus töölauas.

---

## 🏗 2. Unifitseeritud Tootekeskne Kataloogipuu

```text
{ARTIFACTORY_URL}/{ARTIFACTORY_REPO}/products/
  │
  ├── apex/                               <-- Oracle APEX
  │     ├── binaries/                     <-- apex_26.1_en.zip, apex-latest.zip
  │     ├── patches/                      <-- p36758444_latest.zip, patch_latest.meta.json
  │     ├── snapshots/                    <-- profile_db-proxy-oracle_latest.tar.gz
  │     └── metadata/                     <-- product.meta.json
  │
  ├── ords/                               <-- Oracle REST Data Services
  │     ├── binaries/                     <-- ords-24.4.1.zip, ords-latest.zip
  │     ├── patches/
  │     └── snapshots/
  │
  ├── database/                           <-- Oracle 23ai Free DB & OCI FastStart
  │     ├── images/                       <-- oracle-free-23ai.tar, oracle-free-apex-26.1.tar
  │     └── snapshots/                    <-- profile_db-proxy-oracle_latest.tar.gz
  │
  ├── forms/                              <-- Oracle Forms 14c
  │     ├── binaries/                     <-- forms-14.1.2.zip, forms-latest.zip
  │     ├── patches/                      <-- p_forms_patch_latest.zip
  │     └── snapshots/                    <-- profile_db-forms_latest.tar.gz
  │
  ├── publisher/                          <-- Oracle Analytics Publisher
  │     ├── binaries/                     <-- publisher-2025.zip
  │     ├── patches/                      <-- p_publisher_patch_latest.zip
  │     └── snapshots/                    <-- profile_db-publisher_latest.tar.gz
  │
  └── blueprints/                         <-- Kureeritud Blueprintid
        ├── bp_3/                         <-- bp_3_latest.tar.gz, bp_3_latest.meta.json
        ├── bp_34/                        <-- bp_34_latest.tar.gz, bp_34_latest.meta.json
        └── bp_41/                        <-- bp_41_latest.tar.gz, bp_41_latest.meta.json
```

---

## 🚀 3. Universaalne Publitseerija (`./scripts/publish-to-artifactory.sh`)

```bash
# 1. Publitseeri Blueprint 3 Golden Snapshot ja metaandmed:
./scripts/publish-to-artifactory.sh --product blueprints --blueprint 3

# 2. Publitseeri APEX Patch:
./scripts/publish-to-artifactory.sh --product apex --category patches --file binaries/apex/patches/p36758444_latest.zip
```

---

## ⚙️ 4. Seadistuse Näidis (`.env`)

```bash
ARTIFACTORY_URL="https://artifactory.ettevote.ee/artifactory"
ARTIFACTORY_REPO="oracle-devops-platform"
ARTIFACTORY_USER="jfrog_deployer"
AZURE_KEYVAULT_NAME=""
ARTIFACTORY_SECRET_NAME="artifactory-token"
ARTIFACTORY_AUTO_PUBLISH="false"
```
