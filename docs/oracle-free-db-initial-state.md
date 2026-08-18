# Oracle Database Free (23ai) Algseis pärast paigaldust

See dokument kajastab andmebaasi reaalselt mõõdetud algseisu ja ressursside täituvust vahetult pärast **APEX-i** ja **ORDS-i** edukat paigaldust. Mõõtmised tehti lokaalses Podmani konteinerkeskkonnas.

*   **Mõõtmise kuupäev:** 7. august 2026
*   **Kasutatud andmebaasi pilt:** `gvenzl/oracle-free:23-full-faststart`

---

## 1. Andmebaasi maht ja täituvus limiidist (12 GB)

SQL päring kontrollib andmefailide kogumahtu operatsioonisüsteemi tasandil võrrelduna tasuta litsentsi poolt lubatud 12 GB limiidiga:

```sql
SELECT 
    ROUND(SUM(bytes) / 1024 / 1024 / 1024, 2) AS CURRENT_SIZE_GB,
    12 AS LIMIT_GB,
    ROUND((SUM(bytes) / 1024 / 1024 / 1024) / 12 * 100, 2) AS USED_PERCENT
FROM dba_data_files;
```

### Tulemus:

| CURRENT_SIZE_GB | LIMIT_GB | USED_PERCENT |
| :--- | :--- | :--- |
| **1.69 GB** | 12 GB | **14.10%** |

*Kokkuvõte: Pärast puhast paigaldust on vaba ruumi veel umbes 10.31 GB.*

---

## 2. Tablespace'ide täituvus

SQL päring kontrollib konkreetsete tablespace'ide allokeeritud mahtu ja nende hetketäituvust:

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

### Tulemus:

| Tablespace Name | TOTAL_MB | USED_MB | FREE_MB | USED_PERCENT |
| :--- | :--- | :--- | :--- | :--- |
| **SYSTEM** | 1090.00 MB | 1072.63 MB | 17.38 MB | 98.41% |
| **SYSAUX** | 610.00 MB | 581.50 MB | 28.50 MB | 95.33% |
| **UNDOTBS1** | 25.00 MB | 16.56 MB | 8.44 MB | 66.25% |
| **USERS** | 7.00 MB | 6.06 MB | 0.94 MB | 86.61% |

*Märkus: Suur täituvusprotsent tuleneb sellest, et andmefailid on allokeeritud täpselt praeguse andmemahu järgi. Failid on seadistatud laienema automaatselt (`AUTOEXTEND ON`), seega vajadusel laienevad need automaatselt kuni 12 GB kogulimiidi täitumiseni.*

---

## 3. Auditilogide suurus (`AUDSYS` skeem)

SQL päring kontrollib Unified Audit Trail süsteemsete segmentide mahtu `SYSAUX` tablespace'i sees:

```sql
SELECT 
    owner,
    segment_name, 
    segment_type, 
    ROUND(bytes/1024/1024, 2) AS SIZE_MB
FROM dba_segments
WHERE (segment_name IN ('AUD$UNIFIED', 'AUD$') OR segment_name LIKE 'SYS_IL%')
  AND owner = 'AUDSYS'
ORDER BY bytes DESC;
```

### Tulemus:

| Owner | Segment Name | Segment Type | SIZE_MB |
| :--- | :--- | :--- | :--- |
| `AUDSYS` | `AUD$UNIFIED` | TABLE PARTITION | **0.06 MB** (~60 KB) |
| `AUDSYS` | `SYS_IL0000023054C00113$$` | INDEX PARTITION | 0.06 MB |
| `AUDSYS` | `SYS_IL0000023054C00030$$` | INDEX PARTITION | 0.06 MB |
| `AUDSYS` | `SYS_IL0000023054C00031$$` | INDEX PARTITION | 0.06 MB |
| `AUDSYS` | `SYS_IL0000023054C00097$$` | INDEX PARTITION | 0.06 MB |

*Kokkuvõte: Algne auditilogi maht on marginaalne, kuid toodangus kasutamisel vajab see automaatset puhastamist.*

---

## Vaata lisaks:
*   [docs/oracle-free-db-monitoring.md](oracle-free-db-monitoring.md) — Juhend ja SQL skriptid andmebaasi mahu ning auditilogide automaatseks monitoorimiseks ja puhastamiseks.
