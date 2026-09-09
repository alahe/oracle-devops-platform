-- ==============================================================================
-- Data Model Query for --help
-- Target DataSource: ALISE_APP_DB
-- ==============================================================================

SELECT 
    'Eesti Ettevõte OÜ'         AS company_name,
    '12345678'                  AS reg_code,
    'EE101234567'               AS vat_number,
    '--help'           AS report_title,
    'DOC-2026-001'              AS document_num,
    TO_CHAR(SYSDATE, 'YYYY-MM-DD') AS document_date,
    USER                        AS author,
    1                           AS row_num,
    'ITEM-01'                   AS item_code,
    'Standard Teenus / Toode'   AS item_name,
    10                          AS qty,
    100.00                      AS total,
    100.00                      AS grand_total
FROM DUAL;
