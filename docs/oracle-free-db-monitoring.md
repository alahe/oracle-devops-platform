# Oracle Database Free (23ai) Toodangu Piirangud & Monitooring

See dokument kirjeldab **Oracle Database Free (23ai)** tehnilisi piiranguid, toodangukeskkonnas (Production) kasutamise riske ning annab konkreetsed SQL skriptid ja automaatsed protseduurid kettamahu, mälu ja auditilogide monitoorimiseks ning hooldamiseks.

> [!TIP]
> Reaalseid andmebaasi algseisu mõõtmistulemusi vahetult pärast APEX ja ORDS paigaldust vaata dokumendist **[docs/oracle-free-db-initial-state.md](oracle-free-db-initial-state.md)**.

---

## 1. Oracle Database Free Tehnilised Piirangud

Oracle Database Free (varasema nimega Express Edition / XE) omab kõvasid ressursipiiranguid, mis on sisse kodeeritud ja mida andmebaasimootor automaatselt kontrollib:

| Ressurss | Piirang | Kirjeldus |
| :--- | :--- | :--- |
| **CPU** | Max **2 CPU tuuma** | Andmebaasi taustaprotsessid kasutavad maksimaalselt kahte tuuma. Kui serveril on rohkem tuumi, jäetakse need andmebaasi poolt kasutuseta. |
| **RAM** | Max **2 GB** | SGA ja PGA koondmälu limiit on 2 GB. Suurema koormuse korral hakkab andmebaas andmeid kettale saalima (swapping). |
| **Kettaruum** | Max **12 GB** | Kasutajaandmete ja süsteemiandmete (sh `SYSTEM` ja `SYSAUX`) kogumaht ei tohi ületada 12 GB. |
| **Instances** | **1 andmebaas** hosti kohta | Lubatud on ainult üks töötav Oracle Free instants loogilise hosti, virtuaalmasina või konteineri kohta. |

---

## 2. Kriitilised riskid toodangus (Production Gotchas)

### A. Viga ORA-12954: "The request exceeds the maximum allowed database size of 12 GB"
See on kõige sagedasem ja kriitilisem tõrge. Kui andmebaasi maht (mille sisse arvestatakse ka süsteemsed tablespace'id `SYSTEM` ja `SYSAUX`) ületab 12 GB, **blokeeritakse kõik uued andmete kirjutamised**. Rakendused saavad veateateid ning andmebaas muutum sisuliselt "Read-Only" olekusse.

### B. SYSAUX tablespace ja AWR/Audit logide kasv
Isegi kui teie rakenduse andmed (tabelid) on väikesed (näiteks 1 GB), võib andmebaas ikkagi täis saada. Seda põhjustavad:
*   **Unified Audit Trail:** Oracle 23ai-s on auditeerimine vaikimisi sisse lülitatud. Kõik kasutajate tegevused, loginud ja turvasündmused kirjutatakse `AUDSYS` skeemi alla, siia alla kuuluvad ka riigi/ettevõtte nõuetest tulenevad kohustuslikud logid, mis asuvad `SYSAUX` tablespace'is.
*   **Optimizer Statistics History:** Oracle hoiab vaikimisi alles kuni 31 päeva ajaloolisi tabelite statistikaid, et vajadusel täitmisplaane tagasi rullida.
*   **AWR (Automatic Workload Repository) andmed:** Süsteemi jõudluse ja monitooringu snapshotid kogunevad automaatselt.

### C. Turvapaikade ja toe puudumine
*   Oracle Free versioonile **ei pakuta tootja poolt turvapaiku (security patches)** ega veaparandusi.
*   Puudub ametlik **Oracle Support** tugi.
*   Täpsema ülevaate saamiseks turvariskidest, paroolide haldusest ja pilvepõhisest SSO-st vaata: **[docs/turvalisus.md](turvalisus.md)**.

---

## 3. Monitooringu SQL Päringud

Alljärgnevaid päringuid tuleks jooksutada regulaarselt (näiteks monitooringusüsteemi Nagios/Zabbix või APEX-i taustajobi abil).

### A. Kettamahu monitooring (12 GB piirangu lähedus)
See päring näitab praegust andmebaasi mahtu ja protsentuaalset täituvust lubatud 12 GB limiidist:

```sql
SELECT 
    ROUND(SUM(bytes) / 1024 / 1024 / 1024, 2) AS CURRENT_SIZE_GB,
    12 AS LIMIT_GB,
    ROUND((SUM(bytes) / 1024 / 1024 / 1024) / 12 * 100, 2) AS USED_PERCENT
FROM dba_data_files;
```

### B. Tablespace'ide täituvuse monitooring
Tuvastab, milline tablespace (`SYSTEM`, `SYSAUX`, `USERS` vms) võtab kõige rohkem ruumi:

```sql
SELECT 
    df.tablespace_name,
    ROUND(df.total_space_mb, 2) AS TOTAL_MB,
    ROUND(df.total_space_mb - COALESCE(fs.free_space_mb, 0), 2) AS USED_MB,
    ROUND(COALESCE(fs.free_space_mb, 0), 2) AS FREE_MB,
    ROUND(( (df.total_space_mb - COALESCE(fs.free_space_mb, 0)) / df.total_space_mb ) * 100, 2) AS USED_PERCENT
FROM 
    (SELECT tablespace_name, SUM(bytes)/1024/1024 AS total_space_mb 
     FROM dba_data_files GROUP BY tablespace_name) df
LEFT JOIN 
    (SELECT tablespace_name, SUM(bytes)/1024/1024 AS free_space_mb 
     FROM dba_free_space GROUP BY tablespace_name) fs
ON df.tablespace_name = fs.tablespace_name
ORDER BY USED_MB DESC;
```

### C. Auditilogide mahu kontroll
Unified Audit Trail tabeli mahu kontrollimine `SYSAUX` sees:

```sql
SELECT 
    segment_name, 
    segment_type, 
    ROUND(bytes/1024/1024, 2) AS SIZE_MB
FROM dba_segments
WHERE segment_name IN ('AUD$UNIFIED', 'AUD$') OR segment_name LIKE 'SYS_IL%' 
  AND owner = 'AUDSYS'
ORDER BY bytes DESC;
```

---

## 4. Auditilogide ja Kettamahu Automaatne Hooldus

Auditilogide automaatseks kustutamiseks **ei tohi** kasutada `TRUNCATE` või `DELETE` käske, kuna tegu on süsteemsete tabelitega. Oracle pakub selleks spetsiaalset paketti `DBMS_AUDIT_MGMT`.

### Samm 1: Auditilogide osaline kustutamine (nt vanemad kui 14 päeva)
Seda protseduuri tuleks jooksutada regulaarselt.

```sql
DECLARE
    v_purge_date TIMESTAMP WITH TIME ZONE;
BEGIN
    -- Arvutame kuupäeva: 14 päeva tagasi
    v_purge_date := SYSTIMESTAMP - INTERVAL '14' DAY;
    
    -- 1. Seadistame viimase arhiveerimise aja (Last Archive Timestamp)
    DBMS_AUDIT_MGMT.set_last_archive_timestamp(
        audit_trail_type  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
        last_archive_time => v_purge_date
    );
    
    -- 2. Kustutame kõik kirjed, mis on vanemad kui seadistatud aeg
    DBMS_AUDIT_MGMT.clean_audit_trail(
        audit_trail_type        => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
        use_last_arch_timestamp => TRUE
    );
    
    DBMS_OUTPUT.PUT_LINE('Auditilogid vanemad kui ' || v_purge_date || ' on edukalt puhastatud.');
END;
/
```

### Samm 2: Automaatse puhastusjätku (Scheduler Job) loomine
Et süsteem ei jookseks kettaruumi täitumise tõttu kokku, saab luua Oracle Scheduler jobi, mis puhastab auditilogisid **igal öösel kell 02:00**, hoides alles viimase 14 päeva andmed:

```sql
BEGIN
    -- Loome puhastusprogrammi
    DBMS_SCHEDULER.create_job (
        job_name        => 'SYS.AUTO_PURGE_AUDIT_TRAIL_JOB',
        job_type        => 'PLSQL_BLOCK',
        job_action      => '
            DECLARE
                v_purge_date TIMESTAMP WITH TIME ZONE := SYSTIMESTAMP - INTERVAL ''14'' DAY;
            BEGIN
                DBMS_AUDIT_MGMT.set_last_archive_timestamp(
                    audit_trail_type  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
                    last_archive_time => v_purge_date
                );
                DBMS_AUDIT_MGMT.clean_audit_trail(
                    audit_trail_type        => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
                    use_last_arch_timestamp => TRUE
                );
            END;',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=DAILY; BYHOUR=2; BYMINUTE=0; BYSECOND=0',
        enabled         => TRUE,
        comments        => 'Automaatne Unified Audit Trail logide puhastamine (säilitatakse 14 päeva)'
    );
END;
/
```

---

## 5. Kettamahu Tagasivõtmine ja Optimeerimine

Pärast andmete või auditilogide kustutamist vabaneb ruum andmebaasi *sees* (uus andmete kirjutamine saab seda kasutada), kuid füüsilised andmefailid operatsioonisüsteemi kettal ei kahanene automaatselt.

### A. Kustutatud andmete füüsiline vabastamine (Recycle Bin)
Kui kustutad tabeleid, jäävad need vaikimisi prügikasti ja võtavad ikkagi 12 GB limiidist ruumi.
Puhasta prügikast:
```sql
PURGE RECYCLEBIN;
```

### B. SYSAUX tablespace füüsiline kokkutõmbamine
Oracle 23ai toetab tablespace'i kokkutõmbamist otse:
```sql
ALTER TABLESPACE SYSAUX SHRINK SPACE;
```

### C. Andmefaili suuruse käsitsi vähendamine (Resize)
Kui tablespace on kokku tõmmatud, saab andmefaili failisüsteemis füüsiliselt väiksemaks muuta:

```sql
-- 1. Leia andmefaili nimi ja tee
SELECT file_name, bytes/1024/1024 AS size_mb 
FROM dba_data_files 
WHERE tablespace_name = 'SYSAUX';

-- 2. Muuda faili suurust (nt vähenda 3GB peale, kui andmeid on vähem)
ALTER DATABASE DATAFILE '/opt/oracle/oradata/FREE/sysaux01.dbf' RESIZE 3000M;
```

### D. Ajalooliste statistika andmete hoidmise vähendamine
Vaikimisi hoitakse tabeli statistika ajalugu alles 31 päeva, mis kasvatab samuti `SYSAUX`-i. Vähenda see näiteks 7 päeva peale:

```sql
EXEC DBMS_STATS.alter_stats_history_retention(7);
```
