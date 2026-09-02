[ 🇬🇧 English ](../artifactory-setup.md) | [ 🇪🇪 Eesti ](../et/artifactory-setup.md) | [ 🇫🇮 Suomi ](artifactory-setup.md) | [ 🇸🇪 Svenska ](../sv/artifactory-setup.md) | [ 🇱🇻 Latviešu ](../lv/artifactory-setup.md) | [ 🇱🇹 Lietuvių ](../lt/artifactory-setup.md)

# 🏢 Yrityksen Artifactory-arkisto, Tuoteluettelo ja Zero-Trust-metatiedot

Suljetuissa ja yritysturvallisissa ympäristöissä alusta ohjaa binaaripaketit, korjaustiedostot ja tilannevedokset suoraan yrityksen **JFrog Artifactory**-, **Harbor**- tai **Nexus**-arkistoon.

---

## 🎯 1. Tärkeimmät Edut & LAN-pikatoiminto

1. **🚀 ~15s LAN-pikapalautus:** Golden Snapshot -vedokset ladataan sisäverkosta sekunneissa.
2. **📑 Kevyt `.meta.json` -esitarkistus:** Ennen latausta tarkistetaan APEX- ja tietokantaversioiden yhteensopivuus.
3. **🔒 Zero-Trust-todennus:** JIT-tunnukset noudetaan suoraan **Azure Key Vaultista** tai **Oracle SEPS Walletista**.
4. **🛡️ 1-to-1 Tuoteluettelosymmetria:** Identtinen kansiorakenne Artifactoryssa ja kehittäjän koneella.

---

## 🚀 2. Yleinen Julkaisutyökalu (`./scripts/publish-to-artifactory.sh`)

```bash
# 1. Julkaise Blueprint 3 Golden Snapshot:
./scripts/publish-to-artifactory.sh --product blueprints --blueprint 3

# 2. Julkaise APEX-korjaustiedosto:
./scripts/publish-to-artifactory.sh --product apex --category patches --file binaries/apex/patches/p36758444_latest.zip
```
