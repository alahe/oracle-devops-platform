# ORDS Käitusaegne Konfiguratsioonikataloog (`config/ords/`)

Selles kataloogis asuvad **Oracle REST Data Services (ORDS) genereeritud käitusaegsed konfiguratsioonifailid**, mida monteeritakse ORDS konteinerisse (`app_ords`) teekonnale `/etc/ords/config`.

> [!NOTE]
> **Arhitektuuriline reegel:** Arendaja ja administraator **ei pea selle kausta faile käsitsi muutma**.
> Deklaratiivsed reeglid defineeritakse profiilides ([`config/profiles/databases/*.yaml`](../profiles/databases)) ning `./scripts/setup-all.sh` genereerib vastavad `pool.xml` ja `settings.xml` failid automaatselt nende alusel.

---

## 📁 Kataloogi Sisu ja Struktuur

Failipuu struktuur iga aktiivse profiili/andmebaasi puhul (nt `proxy`, `lis`, `publisher`):

```text
config/ords/
├── README.md               <-- Antud juhend
├── proxy/                  <-- APEX Proxy DB (db-proxy) ORDS seadistused
│   ├── databases/
│   │   ├── default/
│   │   │   └── pool.xml    <-- Vaikimisi andmebaasibasseini seadistus (APEX_PUBLIC_USER)
│   │   └── proxy/
│   │       └── pool.xml    <-- /ords/proxy/ marsruudi ühendusbassein
│   ├── global/
│   │   └── settings.xml   <-- Pordid, HTTPS ja APEX piltide teekonnad
│   └── ssl/
│       ├── cert.crt        <-- Automaatselt genereeritud TLS/SSL sertifikaat
│       └── key.key         <-- Sertifikaadi privaatvõti
└── lis/                    <-- LIS Labori DB (db-lis) ORDS seadistused
    └── databases/
        └── lis/
            └── pool.xml    <-- /ords/lis/ marsruudi ühendusbassein
```

---

## ⚙️ Komponentide Kirjeldused

1. **`databases/<pool_name>/pool.xml`**
   - Määrab ära konkreetse andmebaasi ühendusparameetrid:
     - `db.hostname`: Andmebaasikonteineri nimi (nt `db-proxy`, `db-lis`)
     - `db.port`: Oracle listeneri port (`1521`)
     - `db.servicename`: Andmebaasi teenuse nimi (`FREEPDB1`)
     - `db.username`: ORDS veebikasutaja (`APEX_PUBLIC_USER`)
     - `db.password`: Autentimisrekvisiidid

2. **`global/settings.xml`**
   - Sisaldab ORDS standalone veebiserveri (Jetty) üldiseid parameetreid:
     - `standalone.https.port`: HTTPS pordi määratlus (`8448`)
     - `standalone.static.path`: APEX staatiliste piltide/failide teekond (`/opt/oracle/apex_images/images`)

3. **`ssl/`**
   - Hoidla kohalikele TLS/SSL sertifikaatidele (`cert.crt` ja `key.key`), mis võimaldavad turvalist brauseriühendust `https://localhost:8448/ords/`.

---

## 🔄 Taastamine ja Uuendamine

Kui soovite ORDS-i käitusaegseid seadistusi profiilide alusel uuesti genereerida:
```bash
# Taaskäivita seadistuste uuestigeneratsioon:
./scripts/setup-all.sh -y
```
