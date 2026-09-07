# Yritystason Hajautetun Multi-Host-Arkkitehtuurin Määritelmä

[ 🇬🇧 English ](../enterprise-distributed-architecture.md) | [ 🇪🇪 Eesti ](../et/enterprise-distributed-architecture.md) | [ 🇫🇮 Suomi ](enterprise-distributed-architecture.md) | [ 🇸🇪 Svenska ](../sv/enterprise-distributed-architecture.md) | [ 🇱🇻 Latviešu ](../lv/enterprise-distributed-architecture.md) | [ 🇱🇹 Lietuvių ](../lt/enterprise-distributed-architecture.md)

---

## 1. Yleiskatsaus ja Rahoitusalan Vaatimustenmukaisuus

Tämä asiakirja määrittelee tuotantovalmiin, korkean käytettävyyden hajautetun multi-host-arkkitehtuurin Oracle DevOps & APEX -alustan käyttöönotolle rahoituslaitoksissa ja säännellyissä yritysympäristöissä kolmessa eri elinkaarivaiheessa: **DEV**, **TEST** ja **PROD**.

### Sääntely- ja Tietoturvainvariantit
- **DORA & EBA-Ohjeistukset:** Takaa toiminnan jatkuvuuden kahden konesalin **Active / Standby** -mallilla tarjoten **RTO < 60s** ja **RPO < 15m**.
- **PCI-DSS & ISO/IEC 27001:** Ei selväkielisiä salasanoja levyllä, pakollinen päästä-päähän TLS 1.3 / mTLS -salaus, AES-256 Oracle SEPS Auto-Login Wallet, rootless Podman -konttieristys ja vähimpien oikeuksien periaate tietokantatunnuksille.
- **4 Kerroksen Hajautettu Rakenne:** Poistaa kerta-alttiuden (SPOF) ja muistikonfliktit hajauttamalla työkuorman 4 erilliselle palvelimelle ympäristöä kohden.

---

## 2. Hajautettu 4-Tasoinen Arkkitehtuuritopologia

Jokainen ympäristö (DEV, TEST, PROD) toimii 4 erillisellä Linux-palvelimella (RHEL 9 / Oracle Linux 9):
- **Taso 1 (Palvelin 1):** Itsenäinen **ORDS + APEX Images** (portit 8448/443), joka hoitaa multi-pool-reitityksen.
- **Taso 2 (Palvelin 2):** Itsenäinen **Oracle Analytics Publisher** (portit 9502/443) pikselintarkkaan raportointiin.
- **Taso 3 (Palvelin 3):** Dedikoitu **PROXY DB** (Oracle 23ai Free DB kontissa), jossa APEX-ydin ja DevHub.
- **Taso 4 (Palvelin 4):** Dedikoitu **Publisher DB** (Oracle 23ai Free DB kontissa) WebLogic RCU -skeemoille.
- **Olemassa Oleva Liiketoimintatietokanta:** Yhdistetään suoraan ORDS Multi-Poolin ja Publisher JDBC:n kautta ilman monistamista.

---

## 3. Tuotannon (PROD) Active / Standby Toipumissuunnitelma
- **RPO:** $< 15$ minuuttia (automaattinen Golden Snapshot -synkronointi rsyncillä).
- **RTO:** $< 60$ sekuntia (automaattinen palautuskomento `./scripts/dr/failover-standby.sh`).
- **Kuormantasaus:** F5 / VIP ohjaa liikenteen automaattisesti aktiiviseen konesaliin.
