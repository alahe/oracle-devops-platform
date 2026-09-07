[ 🇬🇧 English ](../artifactory-setup.md) | [ 🇪🇪 Eesti ](../et/artifactory-setup.md) | [ 🇫🇮 Suomi ](../fi/artifactory-setup.md) | [ 🇸🇪 Svenska ](artifactory-setup.md) | [ 🇱🇻 Latviešu ](../lv/artifactory-setup.md) | [ 🇱🇹 Lietuvių ](../lt/artifactory-setup.md)

# 🏢 Företagets artifactory-arkiv, produktkatalog och zero-trust metadata

I begränsade företagsmiljöer dirigerar plattformen binärer, patchar och ögonblicksbilder till **JFrog Artifactory**, **Harbor** eller **Nexus**.

---

## 🎯 1. Fördelar och LAN snabbåterställning

1. **🚀 ~15s LAN Snabbåterställning:** Ladda ned ögonblicksbilder över företagsnätverket på några sekunder.
2. **📑 Lätt `.meta.json` Förvalidering:** Kontrollera kompatibilitet före nedladdning.
3. **🔒 Zero-Trust Autentisering:** JIT-token från **Azure Key Vault** eller **SEPS Wallet**.
4. **🛡️ 1-till-1 Produktkatalogsymmetri:** Identisk struktur i Artifactory och lokalt.

---

## 🚀 2. Universellt publiceringsverktyg (`./scripts/publish-to-artifactory.sh`)

```bash
./scripts/publish-to-artifactory.sh --product blueprints --blueprint 3
```
