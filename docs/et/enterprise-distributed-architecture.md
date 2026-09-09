# Ettevõtteklassi hajutatud multi-host arhitektuuri spetsifikatsioon

[ 🇬🇧 English ](../enterprise-distributed-architecture.md) | [ 🇪🇪 Eesti ](enterprise-distributed-architecture.md) | [ 🇫🇮 Suomi ](../fi/enterprise-distributed-architecture.md) | [ 🇸🇪 Svenska ](../sv/enterprise-distributed-architecture.md) | [ 🇱🇻 Latviešu ](../lv/enterprise-distributed-architecture.md) | [ 🇱🇹 Lietuvių ](../lt/enterprise-distributed-architecture.md)

---

## 1. Ülevaade ja finantsregulatsioonide nõuetele vastavus

Käesolev dokument sätestab toodangukõlbliku, kõrgkäideldava ja hajutatud arhitektuurse mudeli Oracle DevOps & APEX platvormi paigaldamiseks finantsettevõtte ja reguleeritud sektori remote Linux serveritele kolmes elutsükli etapis: **DEV**, **TEST** ja **PROD**.

### Regulatiivsed ja turvalisuse invariandid
- **DORA (Digitaalse Tegevuskerksuse Määrus) & EBA Juhendid:** Garanteerib äritegevuse järjepidevuse kahe andmekeskuse **Active / Standby** mudeli kaudu, pakkudes **RTO < 60s** (taasteaja eesmärk) ja **RPO < 15m** (andmekao piirmäär).
- **PCI-DSS & ISO/IEC 27001:** Null plaintext parooli kettal, kohustuslik otspunktidevaheline TLS 1.3 / mTLS krüpteering, AES-256 Oracle Secure External Password Store (SEPS) Auto-Login Walleti kasutamine, rootless Podman konteinerite isolatsioon ja vähimate õiguste printsiip andmebaasikasutajatele.
- **Vastutusalade Selge Eraldamine (4 Kihti):** Likvideerib ühise tõrkepunkti ja mälukonkurentsi, hajutades töökoormuse 4 eraldiseisva serverisõlme vahel igas keskkonnas.

---

## 2. Hajutatud 4-kihiline arhitektuuritopoloogia

Iga keskkond (DEV, TEST, PROD) koosneb 4 eraldiseisvast füüsilisest või virtuaalsest Linux hostist (RHEL 9 / Oracle Linux 9):

```mermaid
flowchart TB
    subgraph Clients ["Kliendid & Välissüsteemid"]
        Browser["Kasutajate Brauserid (APEX & DevHub)<br/>HTTPS: 443 / 8448"]
        ApiClients["Pangatuum & REST Kliendid<br/>HTTPS: 443 / 8448"]
        ReportClients["Aruandlus & ERP Planeerijad<br/>HTTPS: 443 / 9502"]
    end

    subgraph Ingress ["Võrgu & Koormusjaotuse Kiht"]
        F5_VIP["Ettevõtte Koormusjagaja / VIP<br/>F5 BIG-IP / HAProxy (TLS / mTLS)<br/>Tervisekontrollid & Ruutimine"]
    end

    subgraph Tier1 ["KIHT 1: ORDS + APEX App Server (Host 1)"]
        direction TB
        ORDS_SRV["Oracle REST Data Services (ORDS)<br/>Port: 8448 (TLS) / 8088 (Plain)<br/>APEX Pildid (/i/) & Multi-Pool"]
        POOL_PROXY["Bassein 1: 'proxy'<br/>URL: /ords/r/proxy/*<br/>Siht: Host 3 (Proxy DB)"]
        POOL_BIZ["Bassein 2: 'business'<br/>URL: /ords/business/*<br/>Siht: Olemasolev Äri-DB"]
        ORDS_SRV --> POOL_PROXY
        ORDS_SRV --> POOL_BIZ
    end

    subgraph Tier2 ["KIHT 2: Analytics Publisher Server (Host 2)"]
        direction TB
        PUB_SRV["Oracle Analytics Publisher 12c/14c<br/>Port: 9502 (TLS) / 9500 (Plain)<br/>Pixel-Perfect & Pakktarned"]
        PUB_RCU_CONN["RCU Metadata Ühendus<br/>JDBC: Host 4 (Publisher DB)"]
        PUB_BIZ_CONN["Äriandmete Andmeallika Ühendus<br/>JDBC: Olemasolev Äri-DB"]
        PUB_SRV --> PUB_RCU_CONN
        PUB_SRV --> PUB_BIZ_CONN
    end

    subgraph Tier3 ["KIHT 3: PROXY DB Server (Host 3)"]
        direction TB
        DB_PROXY["Oracle 23ai Free DB Konteiner<br/>Port: 1533 (või 1521)<br/>APEX 26.1 & DEVHUB Portaal"]
    end

    subgraph Tier4 ["KIHT 4: Publisher DB Server (Host 4)"]
        direction TB
        DB_PUB["Oracle 23ai Free DB Konteiner<br/>Port: 1532 (või 1521)<br/>WebLogic RCU & BIP Kataloog"]
    end

    subgraph ExternalDB ["Olemasolev Ettevõtte Taristu"]
        BIZ_DB[("OLEMASOLEV ÄRIANDMEBAAS<br/>Enterprise / RAC / Exadata<br/>Port: 1521 / TCPS mTLS")]
    end

    Browser --> F5_VIP
    ApiClients --> F5_VIP
    ReportClients --> F5_VIP

    F5_VIP -->|Port 8448 / HTTPS| ORDS_SRV
    F5_VIP -->|Port 9502 / HTTPS| PUB_SRV

    POOL_PROXY -->|SQL*Net Port 1533 / TCPS| DB_PROXY
    POOL_BIZ -->|SQL*Net Port 1521 / TCPS| BIZ_DB

    PUB_RCU_CONN -->|JDBC Port 1532| DB_PUB
    PUB_BIZ_CONN -->|JDBC Port 1521| BIZ_DB
```

---

## 3. Toodangu (PROD) active / standby avariitaaste

Toodangukeskkonnas (PROD) peegeldatakse kõik 4 kihti kahe andmekeskuse vahel (DC-1 Aktiivne vs DC-2 Ootel/Standby):

```mermaid
flowchart LR
    subgraph DC1 ["ANDMEKESKUS 1 (AKTIIVNE)"]
        direction TB
        A_VIP["Aktiivne VIP Sõlm (F5)"]
        A_ORDS["Aktiivne ORDS Server (Host-1A)"]
        A_PUB["Aktiivne Publisher Server (Host-2A)"]
        A_DB_PROXY["Aktiivne Proxy DB (Host-3A)"]
        A_DB_PUB["Aktiivne Publisher DB (Host-4A)"]
        
        A_VIP --> A_ORDS
        A_VIP --> A_PUB
        A_ORDS --> A_DB_PROXY
        A_PUB --> A_DB_PUB
    end

    subgraph Replication ["Replikatsiooni & Sünkroniseerimise Kanal"]
        direction TB
        SYNC_CFG["Konfiguratsiooni & Git Sünkroonimine<br/>(APEX Images, ORDS Basseinid, BIP Kataloog)<br/>Reaalajas / Tarnel"]
        SYNC_DB["Golden Snapshot + Rsync Plokisünkroonimine<br/>(Krüpteeritud Tõmmised & Arhiivilogid)<br/>Intervall: Iga 15 minuti järel"]
    end

    subgraph DC2 ["ANDMEKESKUS 2 (OOTEL - STANDBY)"]
        direction TB
        S_VIP["Passiivne VIP Sõlm (F5)"]
        S_ORDS["Ootel ORDS Server (Host-1B)"]
        S_PUB["Ootel Publisher Server (Host-2B)"]
        S_DB_PROXY["Ootel Proxy DB (Host-3B)"]
        S_DB_PUB["Ootel Publisher DB (Host-4B)"]
    end

    A_ORDS -.->|Sünkroonimine| SYNC_CFG -.->|Rakendamine| S_ORDS
    A_PUB -.->|Sünkroonimine| SYNC_CFG -.->|Rakendamine| S_PUB
    A_DB_PROXY -.->|Snapshot Rsync| SYNC_DB -.->|Valmis Kettad| S_DB_PROXY
    A_DB_PUB -.->|Snapshot Rsync| SYNC_DB -.->|Valmis Kettad| S_DB_PUB

    A_DB_PROXY ==>|Tõrkesiirde Käsk<br/>RTO < 60s| S_DB_PROXY
    A_VIP ==>|VIP / DNS Ümberlülitus| S_VIP
```

---

## 4. Võrgupordi ja tulemüüri maatriks

| Lähteallikas | Sihtkoht | Port / Protokoll | Teenus | Kirjeldus |
|:---|:---|:---|:---|:---|
| Sisevõrk / Kasutajad | F5 Koormusjagaja (VIP) | `443/TCP`, `8448/TCP` | HTTPS | APEX rakendused, DevHub & Core REST API-d |
| Sisevõrk / ERP | F5 Koormusjagaja (VIP) | `9502/TCP` | HTTPS | Analytics Publisher veebiliides & REST API |
| F5 Koormusjagaja | Server 1 (ORDS) | `8448/TCP` | HTTPS | Pöördproksi liiklus ORDS konteinerisse |
| F5 Koormusjagaja | Server 2 (Publisher) | `9502/TCP` | HTTPS | Pöördproksi liiklus Publisher konteinerisse |
| Server 1 (ORDS) | Server 3 (Proxy DB) | `1533/TCP` | Oracle SQL*Net | APEX tuuma & DevHub päringud (`proxy` bassein) |
| Server 1 (ORDS) | Olemasolev Äri-DB | `1521/TCP` (või `2484`) | SQL*Net / TCPS | Äriandmebaasi REST teenused (`business` bassein) |
| Server 2 (Publisher) | Server 4 (Publisher DB) | `1532/TCP` | Oracle SQL*Net | WebLogic RCU konfiguratsioon & kataloogi talletus |
| Server 2 (Publisher) | Olemasolev Äri-DB | `1521/TCP` (või `2484`) | SQL*Net / TCPS | Äriandmete lugemine aruannete genereerimiseks |
| Bastion / CI Runner | Kõik Serverid (1..4) | `22/TCP` | SSH / SFTP | Automaatne paigaldus, Ansible, käsureatööriistad |
| Server 3A (Active DB) | Server 3B (Standby DB) | `22/TCP` / `873/TCP` | SSH / rsync | Proxy DB Golden Snapshot andmemahu replikatsioon |
| Server 4A (Active DB) | Server 4B (Standby DB) | `22/TCP` / `873/TCP` | SSH / rsync | Publisher DB RCU Golden Snapshot andmemahu replikatsioon |
