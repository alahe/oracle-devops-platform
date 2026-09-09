-- ==============================================================================
-- Oracle Analytics Publisher Data Model SQL Query: Invoice_Report
-- Target Database: ALISE_APP_DB (Oracle 23ai Free PDB)
-- Schema: Standard Invoicing Contract
-- ==============================================================================

SELECT 
    -- Header & Seller details
    s.company_name    AS seller_company_name,
    s.reg_code        AS seller_reg_code,
    s.vat_number      AS seller_vat_number,
    s.address         AS seller_address,
    s.email           AS seller_email,
    s.phone           AS seller_phone,
    s.bank_name       AS seller_bank_name,
    s.iban            AS seller_iban,
    s.swift_bic       AS seller_swift_bic,
    
    -- Buyer / Customer details
    b.company_name    AS buyer_company_name,
    b.reg_code        AS buyer_reg_code,
    b.vat_number      AS buyer_vat_number,
    b.address         AS buyer_address,
    b.contact_person  AS buyer_contact_person,
    b.email           AS buyer_email,
    
    -- Invoice metadata
    i.invoice_id      AS invoice_id,
    i.invoice_num     AS invoice_num,
    TO_CHAR(i.invoice_date, 'YYYY-MM-DD') AS invoice_date,
    TO_CHAR(i.due_date, 'YYYY-MM-DD')     AS due_date,
    i.payment_terms   AS payment_terms,
    i.payment_ref     AS payment_reference,
    i.order_num       AS order_number,
    i.currency        AS currency,
    
    -- Totals
    i.subtotal        AS subtotal,
    i.vat_rate        AS vat_rate,
    i.vat_amount      AS vat_amount,
    i.discount_total  AS discount_total,
    i.grand_total     AS grand_total,
    i.total_in_words  AS total_in_words,
    
    -- Line items
    l.line_num        AS line_num,
    l.item_code       AS item_code,
    l.item_name       AS item_name,
    l.qty             AS qty,
    l.unit            AS unit,
    l.unit_price      AS unit_price,
    l.discount_pct    AS discount_pct,
    l.line_total      AS line_total
FROM inv_invoices i
JOIN inv_sellers s ON s.seller_id = i.seller_id
JOIN inv_buyers  b ON b.buyer_id = i.buyer_id
JOIN inv_lines   l ON l.invoice_id = i.invoice_id
WHERE i.invoice_id = :p_invoice_id
ORDER BY l.line_num ASC;
