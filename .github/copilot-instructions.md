# GitHub Copilot Instructions for Oracle DevOps Platform & BI Publisher

This file provides system instructions for GitHub Copilot in Visual Studio Code across this repository.

---

## 1. Domain Specialization: Oracle Analytics Publisher (BI Publisher) RTF Templates

When generating, modifying, or refactoring Oracle Analytics Publisher report templates (`templates/publisher/**/*.rtf`) and sample datasets (`templates/publisher/**/*.xml`):

### 1.1 Oracle XDO / XSL-FO Syntax Standards
Always adhere to official Oracle BI Publisher template syntax:
- **Field Substitution:**
  - Standard syntax: `<?FIELD_NAME?>` or relative path `<?PARENT/FIELD_NAME?>`.
  - Example: `<?SELLER/COMPANY_NAME?>`, `<?INVOICE_METADATA/INVOICE_NUM?>`.
- **Repeating Rows / Line Items (`for-each`):**
  - In RTF tables, place the opening tag in the **first column**: `<?for-each:LINES/LINE?><?LINE_NUM?>`.
  - Place the closing tag in the **last column**: `<?format-number(LINE_TOTAL, '#,##0.00')?><?end for-each?>`.
  - Never leave an unclosed `<?for-each:...?>`.
- **Number & Currency Formatting:**
  - Syntax: `<?format-number(FIELD, '#,##0.00')?>`.
  - Example: `<?format-number(UNIT_PRICE, '#,##0.00')?> EUR`.
- **Date Formatting:**
  - Syntax: `<?format-date(FIELD, 'YYYY-MM-DD')?>`.
  - Example: `<?format-date(INVOICE_DATE, 'YYYY-MM-DD')?>`.
- **Conditional Visibility (`if` / `choose`):**
  - Simple condition: `<?if:DISCOUNT_PCT > 0?><?DISCOUNT_PCT?>%<?end if?>`.
  - Total condition: `<?if:TOTALS/DISCOUNT_TOTAL > 0?>Soodustus: -<?TOTALS/DISCOUNT_TOTAL?> EUR<?end if?>`.
  - Always close every `<?if:...?>` with `<?end if?>`.
- **Calculations & Aggregates:**
  - Sum: `<?sum(LINE_TOTAL)?>`.
  - Count: `<?count(LINE)?>`.

### 1.2 RTF Structure Preservation
When modifying `.rtf` files in VS Code:
- Preserve RTF table boundaries (`\trowd`, `\clvertalt`, `\cellx`, `\pard\intbl`, `\cell`, `\row`).
- Do NOT delete column definitions (`\cellx`) when adding or removing tags inside cells.
- Keep font and color tables intact at the top of the file (`{\fonttbl...}`, `{\colortbl...}`).

### 1.3 Active Sample Dataset: `templates/publisher/samples/arve_test_andmed.xml`
The canonical test dataset contains the following structure:
- `SELLER`: `COMPANY_NAME`, `REG_CODE`, `VAT_NUMBER`, `ADDRESS`, `EMAIL`, `PHONE`, `WEBSITE`, `BANK_NAME`, `IBAN`, `SWIFT_BIC`.
- `BUYER`: `COMPANY_NAME`, `REG_CODE`, `VAT_NUMBER`, `ADDRESS`, `CONTACT_PERSON`, `EMAIL`.
- `INVOICE_METADATA`: `INVOICE_NUM`, `INVOICE_DATE`, `DUE_DATE`, `PAYMENT_TERMS`, `CURRENCY`, `PAYMENT_REFERENCE`, `ORDER_NUMBER`.
- `LINES/LINE`: `LINE_NUM`, `ITEM_CODE`, `ITEM_NAME`, `QTY`, `UNIT`, `UNIT_PRICE`, `DISCOUNT_PCT`, `LINE_TOTAL`.
- `TOTALS`: `SUBTOTAL`, `DISCOUNT_TOTAL`, `VAT_RATE`, `VAT_AMOUNT`, `GRAND_TOTAL`, `TOTAL_IN_WORDS`.
- `FOOTER`: `PAYMENT_NOTICE`, `LATE_FEE_NOTICE`, `THANK_YOU_MESSAGE`.

---

## 2. Platform DevOps Architecture & Coding Rules

- **Zero Plaintext Passwords (Rule 5):** Never output or hardcode database passwords. Passwords come dynamically from Oracle SEPS Wallet (`./scripts/get-password.sh <ALIAS>`).
- **No Legacy SQL*Plus (Rule 6.6):** Always use modern SQLcl (`sql`) for Oracle database operations.
- **6-Language Parity (Rule 9):** User-facing documentation must maintain parity across EN, ET, FI, SV, LV, LT.
- **Responsive Mermaid (Rule 10):** Diagrams must be vertical or multi-tier grid clusters, max 4 lines per box, max 25-28 chars in diamonds.
- **Cross-Platform Portability (Rule 13):** Clean ASCII filenames, no spaces, no reserved Windows characters (`< > : " / \ | ? *`).
- **macOS / Bash 3.2 Compatibility (Rule 6.4):** Use portable shell syntax. Do not use `${VAR,,}` or `declare -A` in shell scripts intended for host macOS execution.
