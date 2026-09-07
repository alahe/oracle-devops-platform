/* ==============================================================================
 * Oracle DevOps Platform - Developer Hub Multilingual Static Mermaid Diagrams
 * Overview Topology, SEPS Passwordless Authentication Sequence, and Schemas.
 * ============================================================================== */

const MERMAID_DIAGRAMS = {
  en: [
`graph TD
    Client["Developer / Web Browser"] -->|HTTP 8088 / HTTPS 8448| ORDS["app-ords (Jetty & ORDS Engine)"]
    Client -->|HTTP 9502| Pub["app-publisher (Analytics Publisher 2025)"]
    Client -->|HTTP 9001 / 7001| Forms["app-forms (Forms 14.1.2 & WebLogic)"]
    Client -->|HTTP 8090| WebIDE["web-ide-dev (VS Code Web IDE)"]

    subgraph DatabaseLayer ["Oracle 23ai Database Tier (SEPS Wallet Secured)"]
        DBProxy[("db-proxy : 1532<br/>APEX Proxy, OIDC & Kafka")]
        DBCustom[("db-alise : 1533<br/>ALISE Schema Engine & Logic")]
        DBPub[("db-publisher : 1535<br/>Publisher RCU Metadata")]
        DBForms[("db-forms : 1536<br/>Forms 14c RCU Metadata")]
    end

    ORDS -->|TCPS / SQLNet| DBProxy
    ORDS -->|TCPS / SQLNet| DBCustom
    Pub -->|JDBC Thin| DBPub
    Forms -->|JDBC Thin| DBForms`,

`sequenceDiagram
    autonumber
    actor Dev as Developer / CLI
    participant W as SEPS Wallet (~/config/tns_admin)
    participant SQLcl as Oracle SQLcl CLI
    participant DB as Oracle 23ai Database

    Dev->>SQLcl: sql /@DB_PROXY_DEV
    SQLcl->>W: Lookup credentials & TLS cert for alias
    W-->>SQLcl: Return auto-login decrypted token
    SQLcl->>DB: Secure TLS Handshake (No plaintext password in ps aux)
    DB-->>SQLcl: Authentication Successful (Session Opened)`,

`graph LR
    subgraph S1 ["1. Forms 14c Source and Dev Tier"]
        FMB["📄 Forms Source (.FMB / .MMB / .PLL)"]
        Builder["🎨 Forms Builder GUI (noVNC 6082)"]
        Compiler["⚙️ Headless frmcmp.sh Compiler"]
        FMX["📦 Runtime Forms Executable (.FMX)"]
        FMB --> Builder
        FMB --> Compiler --> FMX
    end

    subgraph S2 ["2. Automated Conversion and CI/CD Pipeline"]
        XML["📑 Git-Versioned XML (frmf2xml)"]
        PLSQL["🧠 PL/SQL Business Logic Extraction"]
        ExportZip["📦 APEX Migration Workshop Package"]
        FMB -->|frmf2xml.sh| XML
        XML --> PLSQL
        XML --> ExportZip
    end

    subgraph S3 ["3. Target Modern Cloud Architecture"]
        DB["🛡️ Oracle 23ai Database (PL/SQL Packages)"]
        APEX["🚀 Oracle APEX 26.1 (Universal Theme)"]
        ORDS["🌐 ORDS 26.2 REST APIs and OAuth2 SSO"]
        Pub["📊 Analytics Publisher (Pixel-Perfect PDF)"]
        PLSQL --> DB
        ExportZip --> APEX
        DB <--> APEX
        APEX <--> ORDS
        APEX --> Pub
    end`
  ],

  et: [
`graph TD
    Client["Arendaja / Veebibrauser"] -->|HTTP 8088 / HTTPS 8448| ORDS["app-ords (Jetty & ORDS Mootor)"]
    Client -->|HTTP 9502| Pub["app-publisher (Analytics Publisher 2025)"]
    Client -->|HTTP 9001 / 7001| Forms["app-forms (Forms 14.1.2 & WebLogic)"]
    Client -->|HTTP 8090| WebIDE["web-ide-dev (VS Code Web IDE)"]

    subgraph DatabaseLayer ["Oracle 23ai Andmebaasikiht (SEPS Walletiga Kaitstud)"]
        DBProxy[("db-proxy : 1532<br/>APEX Proxy, OIDC & Kafka")]
        DBCustom[("db-alise : 1533<br/>ALISE Skeemimootor ja Loogika")]
        DBPub[("db-publisher : 1535<br/>Publisher RCU Metaandmed")]
        DBForms[("db-forms : 1536<br/>Forms 14c RCU Metaandmed")]
    end

    ORDS -->|TCPS / SQLNet| DBProxy
    ORDS -->|TCPS / SQLNet| DBCustom
    Pub -->|JDBC Thin| DBPub
    Forms -->|JDBC Thin| DBForms`,

`sequenceDiagram
    autonumber
    actor Dev as Arendaja / Käsirida
    participant W as SEPS Wallet (~/config/tns_admin)
    participant SQLcl as Oracle SQLcl CLI
    participant DB as Oracle 23ai Andmebaas

    Dev->>SQLcl: sql /@DB_PROXY_DEV
    SQLcl->>W: Päri aliasele vastav sertifikaat ja parool
    W-->>SQLcl: Väljasta dekrüpteeritud token
    SQLcl->>DB: Turvaline TLS kätlemine (Zero plaintext parool ps aux-is)
    DB-->>SQLcl: Autentimine õnnestus (Sessioon avatud)`,

`graph LR
    subgraph S1 ["1. Forms 14c Lähtekood ja Arenduskiht"]
        FMB["📄 Forms Lähtekood (.FMB / .MMB / .PLL)"]
        Builder["🎨 Forms Builder GUI (noVNC 6082)"]
        Compiler["⚙️ Headless frmcmp.sh Kompilaator"]
        FMX["📦 Käitusaegne Forms Moodul (.FMX)"]
        FMB --> Builder
        FMB --> Compiler --> FMX
    end

    subgraph S2 ["2. Automaatne Teisendus ja CI/CD Töövoog"]
        XML["📑 Git-Jälgitav XML Struktuur (frmf2xml)"]
        PLSQL["🧠 PL/SQL Äriloogika ja Triggerite Eraldus"]
        ExportZip["📦 APEX Migratsiooni Töölaua Pakett"]
        FMB -->|frmf2xml.sh| XML
        XML --> PLSQL
        XML --> ExportZip
    end

    subgraph S3 ["3. Siht-Pilvearhitektuur"]
        DB["🛡️ Oracle 23ai Andmebaas (PL/SQL Paketid)"]
        APEX["🚀 Oracle APEX 26.1 (Universal Theme)"]
        ORDS["🌐 ORDS 26.2 REST Liidesed ja SSO"]
        Pub["📊 Analytics Publisher (Pixel-Perfect PDF)"]
        PLSQL --> DB
        ExportZip --> APEX
        DB <--> APEX
        APEX <--> ORDS
        APEX --> Pub
    end`
  ],

  fi: [
`graph TD
    Client["Kehittäjä / Verkkoselain"] -->|HTTP 8088 / HTTPS 8448| ORDS["app-ords (Jetty & ORDS-moottori)"]
    Client -->|HTTP 9502| Pub["app-publisher (Analytics Publisher 2025)"]
    Client -->|HTTP 9001 / 7001| Forms["app-forms (Forms 14.1.2 & WebLogic)"]
    Client -->|HTTP 8090| WebIDE["web-ide-dev (VS Code Web IDE)"]

    subgraph DatabaseLayer ["Oracle 23ai -tietokantakerros (SEPS Wallet -suojattu)"]
        DBProxy[("db-proxy : 1532<br/>APEX Proxy, OIDC & Kafka")]
        DBCustom[("db-alise : 1533<br/>ALISE-skeemamoottori ja logiikka")]
        DBPub[("db-publisher : 1535<br/>Publisher RCU -metatiedot")]
        DBForms[("db-forms : 1536<br/>Forms 14c RCU -metatiedot")]
    end

    ORDS -->|TCPS / SQLNet| DBProxy
    ORDS -->|TCPS / SQLNet| DBCustom
    Pub -->|JDBC Thin| DBPub
    Forms -->|JDBC Thin| DBForms`,

`sequenceDiagram
    autonumber
    actor Dev as Kehittäjä / CLI
    participant W as SEPS Wallet (~/config/tns_admin)
    participant SQLcl as Oracle SQLcl CLI
    participant DB as Oracle 23ai -tietokanta

    Dev->>SQLcl: sql /@DB_PROXY_DEV
    SQLcl->>W: Hae tunnistetiedot & TLS-sertifikaatti
    W-->>SQLcl: Palauta automaattikirjautumisen salattu token
    SQLcl->>DB: Suojattu TLS-kättely (Ei selväkielistä salasanaa ps aux -listauksessa)
    DB-->>SQLcl: Autentikointi onnistui (Istunto avattu)`,

`graph LR
    subgraph S1 ["1. Forms 14c -lähdekoodi ja kehityskerros"]
        FMB["📄 Forms-lähdekoodi (.FMB / .MMB / .PLL)"]
        Builder["🎨 Forms Builder GUI (noVNC 6082)"]
        Compiler["⚙️ Headless frmcmp.sh -kääntäjä"]
        FMX["📦 Ajonaikainen Forms-moduuli (.FMX)"]
        FMB --> Builder
        FMB --> Compiler --> FMX
    end

    subgraph S2 ["2. Automaattinen muunnos ja CI/CD-putki"]
        XML["📑 Git-seurattava XML-rakenne (frmf2xml)"]
        PLSQL["🧠 PL/SQL-liiketoimintalogiikan erotus"]
        ExportZip["📦 APEX Migration Workshop -paketti"]
        FMB -->|frmf2xml.sh| XML
        XML --> PLSQL
        XML --> ExportZip
    end

    subgraph S3 ["3. Moderni kohdepilviarkkitehtuuri"]
        DB["🛡️ Oracle 23ai -tietokanta (PL/SQL-paketit)"]
        APEX["🚀 Oracle APEX 26.1 (Universal Theme)"]
        ORDS["🌐 ORDS 26.2 REST -rajapinnat ja SSO"]
        Pub["📊 Analytics Publisher (Pixel-Perfect PDF)"]
        PLSQL --> DB
        ExportZip --> APEX
        DB <--> APEX
        APEX <--> ORDS
        APEX --> Pub
    end`
  ],

  sv: [
`graph TD
    Client["Utvecklare / Webbläsare"] -->|HTTP 8088 / HTTPS 8448| ORDS["app-ords (Jetty & ORDS Motor)"]
    Client -->|HTTP 9502| Pub["app-publisher (Analytics Publisher 2025)"]
    Client -->|HTTP 9001 / 7001| Forms["app-forms (Forms 14.1.2 & WebLogic)"]
    Client -->|HTTP 8090| WebIDE["web-ide-dev (VS Code Web IDE)"]

    subgraph DatabaseLayer ["Oracle 23ai Databasskikt (SEPS Wallet Säkrat)"]
        DBProxy[("db-proxy : 1532<br/>APEX Proxy, OIDC & Kafka")]
        DBCustom[("db-alise : 1533<br/>ALISE Schemamotor och Logik")]
        DBPub[("db-publisher : 1535<br/>Publisher RCU Metadata")]
        DBForms[("db-forms : 1536<br/>Forms 14c RCU Metadata")]
    end

    ORDS -->|TCPS / SQLNet| DBProxy
    ORDS -->|TCPS / SQLNet| DBCustom
    Pub -->|JDBC Thin| DBPub
    Forms -->|JDBC Thin| DBForms`,

`sequenceDiagram
    autonumber
    actor Dev as Utvecklare / CLI
    participant W as SEPS Wallet (~/config/tns_admin)
    participant SQLcl as Oracle SQLcl CLI
    participant DB as Oracle 23ai Databas

    Dev->>SQLcl: sql /@DB_PROXY_DEV
    SQLcl->>W: Hämta autentisering och certifikat
    W-->>SQLcl: Returnera dekrypterat token
    SQLcl->>DB: Säker TLS-anslutning (Inget lösenord i ps aux)
    DB-->>SQLcl: Autentisering lyckades (Session öppnad)`,

`graph LR
    subgraph S1 ["1. Forms 14c Källkod och Utvecklingsskikt"]
        FMB["📄 Forms Källkod (.FMB / .MMB / .PLL)"]
        Builder["🎨 Forms Builder GUI (noVNC 6082)"]
        Compiler["⚙️ Headless frmcmp.sh Kompilator"]
        FMX["📦 Körbar Forms Modul (.FMX)"]
        FMB --> Builder
        FMB --> Compiler --> FMX
    end

    subgraph S2 ["2. Automatiserad Konvertering och CI/CD-pipeline"]
        XML["📑 Git-Spårbar XML Struktur (frmf2xml)"]
        PLSQL["🧠 PL/SQL Affärslogik och Triggers"]
        ExportZip["📦 APEX Migration Workshop Paket"]
        FMB -->|frmf2xml.sh| XML
        XML --> PLSQL
        XML --> ExportZip
    end

    subgraph S3 ["3. Mål Cloud-arkitektur"]
        DB["🛡️ Oracle 23ai Databas (PL/SQL Paket)"]
        APEX["🚀 Oracle APEX 26.1 (Universal Theme)"]
        ORDS["🌐 ORDS 26.2 REST API och SSO"]
        Pub["📊 Analytics Publisher (Pixel-Perfect PDF)"]
        PLSQL --> DB
        ExportZip --> APEX
        DB <--> APEX
        APEX <--> ORDS
        APEX --> Pub
    end`
  ],

  lv: [
`graph TD
    Client["Izstrādātājs / Pārlūks"] -->|HTTP 8088 / HTTPS 8448| ORDS["app-ords (Jetty & ORDS Dzinējs)"]
    Client -->|HTTP 9502| Pub["app-publisher (Analytics Publisher 2025)"]
    Client -->|HTTP 9001 / 7001| Forms["app-forms (Forms 14.1.2 & WebLogic)"]
    Client -->|HTTP 8090| WebIDE["web-ide-dev (VS Code Web IDE)"]

    subgraph DatabaseLayer ["Oracle 23ai Datubāzes Slānis (SEPS Wallet Drošs)"]
        DBProxy[("db-proxy : 1532<br/>APEX Proxy, OIDC & Kafka")]
        DBCustom[("db-alise : 1533<br/>ALISE Shēmas Dzinējs")]
        DBPub[("db-publisher : 1535<br/>Publisher RCU Metadati")]
        DBForms[("db-forms : 1536<br/>Forms 14c RCU Metadati")]
    end

    ORDS -->|TCPS / SQLNet| DBProxy
    ORDS -->|TCPS / SQLNet| DBCustom
    Pub -->|JDBC Thin| DBPub
    Forms -->|JDBC Thin| DBForms`,

`sequenceDiagram
    autonumber
    actor Dev as Izstrādātājs / CLI
    participant W as SEPS Wallet (~/config/tns_admin)
    participant SQLcl as Oracle SQLcl CLI
    participant DB as Oracle 23ai Datubāze

    Dev->>SQLcl: sql /@DB_PROXY_DEV
    SQLcl->>W: Iegūt piekļuves datus un sertifikātu
    W-->>SQLcl: Atgriezt atšifrētu marķieri
    SQLcl->>DB: Droša TLS savienojuma izveide
    DB-->>SQLcl: Autentifikācija veiksmīga (Sesija atvērta)`,

`graph LR
    subgraph S1 ["1. Forms 14c Pirmkods un Izstrādes Slānis"]
        FMB["📄 Forms Pirmkods (.FMB / .MMB / .PLL)"]
        Builder["🎨 Forms Builder GUI (noVNC 6082)"]
        Compiler["⚙️ Headless frmcmp.sh Kompilators"]
        FMX["📦 Izpildāmais Forms Modulis (.FMX)"]
        FMB --> Builder
        FMB --> Compiler --> FMX
    end

    subgraph S2 ["2. Automatizēta Konvertēšana un CI/CD Caurule"]
        XML["📑 Git Sekojama XML Struktūra (frmf2xml)"]
        PLSQL["🧠 PL/SQL Biznesa Loģika un Trigeri"]
        ExportZip["📦 APEX Migrācijas Pakotne"]
        FMB -->|frmf2xml.sh| XML
        XML --> PLSQL
        XML --> ExportZip
    end

    subgraph S3 ["3. Mūsdienu Mākoņa Mērķarhitektūra"]
        DB["🛡️ Oracle 23ai Datubāze (PL/SQL Pakotnes)"]
        APEX["🚀 Oracle APEX 26.1 (Universal Theme)"]
        ORDS["🌐 ORDS 26.2 REST Saskarnes un SSO"]
        Pub["📊 Analytics Publisher (Pixel-Perfect PDF)"]
        PLSQL --> DB
        ExportZip --> APEX
        DB <--> APEX
        APEX <--> ORDS
        APEX --> Pub
    end`
  ],

  lt: [
`graph TD
    Client["Kūrėjas / Naršyklė"] -->|HTTP 8088 / HTTPS 8448| ORDS["app-ords (Jetty & ORDS Variklis)"]
    Client -->|HTTP 9502| Pub["app-publisher (Analytics Publisher 2025)"]
    Client -->|HTTP 9001 / 7001| Forms["app-forms (Forms 14.1.2 & WebLogic)"]
    Client -->|HTTP 8090| WebIDE["web-ide-dev (VS Code Web IDE)"]

    subgraph DatabaseLayer ["Oracle 23ai Duomenų Bazių Sluoksnis (SEPS Wallet Apsaugotas)"]
        DBProxy[("db-proxy : 1532<br/>APEX Proxy, OIDC & Kafka")]
        DBCustom[("db-alise : 1533<br/>ALISE Schemų Variklis")]
        DBPub[("db-publisher : 1535<br/>Publisher RCU Metaduomenys")]
        DBForms[("db-forms : 1536<br/>Forms 14c RCU Metaduomenys")]
    end

    ORDS -->|TCPS / SQLNet| DBProxy
    ORDS -->|TCPS / SQLNet| DBCustom
    Pub -->|JDBC Thin| DBPub
    Forms -->|JDBC Thin| DBForms`,

`sequenceDiagram
    autonumber
    actor Dev as Kūrėjas / CLI
    participant W as SEPS Wallet (~/config/tns_admin)
    participant SQLcl as Oracle SQLcl CLI
    participant DB as Oracle 23ai Duomenų Bazė

    Dev->>SQLcl: sql /@DB_PROXY_DEV
    SQLcl->>W: Gauti prisijungimo duomenis ir sertifikatą
    W-->>SQLcl: Grąžinti iššifruotą prieigos raktą
    SQLcl->>DB: Saugus TLS sujungimas
    DB-->>SQLcl: Autentifikacija sėkminga (Sesija atidaryta)`,

`graph LR
    subgraph S1 ["1. Forms 14c Išeities Kodas ir Kūrimo Sluoksnis"]
        FMB["📄 Forms Išeities Kodas (.FMB / .MMB / .PLL)"]
        Builder["🎨 Forms Builder GUI (noVNC 6082)"]
        Compiler["⚙️ Headless frmcmp.sh Kompiliatorius"]
        FMX["📦 Vykdomasis Forms Modulis (.FMX)"]
        FMB --> Builder
        FMB --> Compiler --> FMX
    end

    subgraph S2 ["2. Automatizuotas Konvertavimas ir CI/CD Srautas"]
        XML["📑 Git Sekama XML Struktūra (frmf2xml)"]
        PLSQL["🧠 PL/SQL Verslo Logika ir Trigeriai"]
        ExportZip["📦 APEX Migracijos Paketas"]
        FMB -->|frmf2xml.sh| XML
        XML --> PLSQL
        XML --> ExportZip
    end

    subgraph S3 ["3. Tikslinė Debesų Architektūra"]
        DB["🛡️ Oracle 23ai Duomenų Bazė (PL/SQL Paketai)"]
        APEX["🚀 Oracle APEX 26.1 (Universal Theme)"]
        ORDS["🌐 ORDS 26.2 REST Sąsajos ir SSO"]
        Pub["📊 Analytics Publisher (Pixel-Perfect PDF)"]
        PLSQL --> DB
        ExportZip --> APEX
        DB <--> APEX
        APEX <--> ORDS
        APEX --> Pub
    end`
  ]
};
