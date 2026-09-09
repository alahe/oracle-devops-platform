---
name: oracle_publisher_accessibility
description: Guidelines and mandatory rules for designing, validating, and testing accessible (PDF/UA-1, WCAG 2.1 AA, Section 508) templates in Oracle Analytics Publisher.
---

# Oracle Analytics Publisher: Document Accessibility & PDF/UA-1 Standard

This skill establishes the mandatory architectural rules, minimum design requirements, and verification procedures for creating **accessible pixel-perfect documents, electronic invoices, and financial reports** compliant with **PDF/UA-1 (ISO 14289-1)**, **WCAG 2.1 Level AA**, **European Accessibility Act (EAA / EN 301 549)**, and **Section 508**.

---

## 1. When to Use & Routing

### Positive Triggers (Activate this skill when:)
- Designing or modifying RTF templates in Microsoft Word or LibreOffice Writer for Oracle BI Publisher / Analytics Publisher.
- Configuring accessibility properties (`pdf-accessible = true`, `pdf-a-mode`, `pdf-ua-mode`).
- Ensuring screen reader compatibility (NVDA, JAWS, Apple VoiceOver, Microsoft Edge Read Aloud).
- Adding alternative text (`Alt Text`) to images, corporate logos, and QR codes.
- Structuring tables, repeating header rows (`\trhdr`), and associating column headers with data cells.
- Verifying WCAG AA color contrast (minimum 4.5:1 for standard text).
- Running accessibility test suites, RTF linters, or generating official VPAT / ACR compliance reports.
- Customizing corporate invoice branding using the centralized assets repository (`templates/publisher/common/images/`).

### Negative Routing
| Request / Intent | Do NOT handle here | Route to Skill |
|---|---|---|
| Deploying .xdo files or WebLogic AdminServer operations | `oracle_publisher_devops` | Use [oracle_publisher_devops](file:///.agents/skills/oracle_publisher/SKILL.md) |
| Running Oracle Free DB containers or SQLcl | `oracle_containers` | Use [oracle_containers](file:///.agents/skills/oracle_containers/SKILL.md) |
| APEX application pages or SSO | `apex_dev` | Use [apex_dev](file:///.agents/skills/apex_dev/SKILL.md) |
| Architecture Mermaid diagrams | `mermaid_diagram_design` | Use [mermaid_diagram_design](file:///.agents/skills/mermaid_diagram_design/SKILL.md) |

---

## 2. Mandatory Minimum Template Design Requirements

Every RTF template created or modified on this platform MUST adhere to these **6 non-negotiable rules**:

### 2.1 Document Structure & Heading Hierarchy
1. **Never simulate headings with direct formatting:** Do not just make normal text bold and 16pt. Screen readers rely on structural heading tags (`<H1>`, `<H2>`) to allow blind users to navigate across sections.
2. **Mandatory Heading 1 (`H1`):** Every document must have exactly one primary title formatted in the standard style **Heading 1** (e.g. `ARVE NR: <?INVOICE_NUM?>`).
3. **Sub-Headings (`H2`):** Section blocks must be styled as **Heading 2** (e.g. `Müüja andmed`, `Ostja andmed`, `Arve read`, `Tasumise rekvisiidid`).
4. **Summary-First UX Pattern:** Place essential invoice metadata (*Invoice Number, Issue Date, Due Date, Total Amount Due*) in a dedicated high-level block at the top of the document. Blind users should never have to listen through 50 line items just to discover the total payment due.

### 2.2 Table Accessibility Requirements
1. **Designated Header Row:** Every data table must have a designated first row containing column header descriptions (`<TH>`).
2. **Repeat Header Row (`\trhdr`):** In table properties, the header row must have **Repeat as header row at the top of each page** enabled:
   - **In LibreOffice Writer:** Right-click Table -> *Table Properties* -> *Text Flow* -> Check `[X] Repeat header`.
   - **In Microsoft Word:** Select Header Row -> *Table Properties* -> *Row* tab -> Check `[X] Repeat as header row at the top of each page`.
   - In raw RTF, this emits the control word `\trhdr`.
3. **No Empty Spacer Cells:** Never insert empty table columns or rows to create visual whitespace. Whitespace must be controlled via paragraph spacing or cell margins (`padding`).
4. **Column Alignment & Scope:** Numeric values (quantities, prices, totals) must align right; textual descriptions must align left.

### 2.3 Images, Corporate Logos & Dynamic URIs
1. **Mandatory Alternative Text (`Alt Text`):** Every image, logo, and graphic object MUST have a descriptive alt text:
   - Logo Alt Text: `Ettevõtte ametlik logo` (or `Company official logo`).
   - Signature Alt Text: `Allkiri: <?SIGNER_NAME?>`.
   - Payment QR Alt Text: `Maksekorralduse QR-kood: summa <?TOTAL?> EUR`.
2. **Centralized Asset Repository (Single Source of Assets - SSoA):**
   - **Never hardcode Windows local paths** like `C:\logo.png`.
   - Place shared corporate assets in: `templates/publisher/common/images/company_logo.png` (container: `/u01/common/images/company_logo.png`).
   - In the RTF template dummy image Alt-Text / Web tab, specify Oracle Publisher's dynamic URI formula:
     ```text
     url:{concat($IMAGE_DIR, '/company_logo.png')}
     Alt: Ettevõtte ametlik logo
     ```
   - When rebranding occurs, updating **only that single file** immediately updates all 50+ invoices and reports.
3. **Decorative Graphics as Artifacts:** Any purely visual accent line or decorative divider must be marked as an `/Artifact` or placed in document header/footers so screen readers skip it without distraction.

### 2.4 Color Contrast Minimums (WCAG 2.1 AA)
1. **Minimum Ratio 4.5:1:** Contrast between body text and its background must be at least **4.5:1** (3:1 for text 18pt or larger, or 14pt bold).
2. **Prohibited:** Never use light gray text (e.g. `#888888`, `#AAAAAA`, `#B0C4DE`) on a white background.
3. **Recommended Corporate Accessible Palette:**
   | Purpose | Approved Hex Code | Background | Contrast Ratio |
   |---|---|---|---|
   | Primary Text | `#1A202C` (Off-black) | `#FFFFFF` (White) | **16.1:1 (AAA)** |
   | Corporate Navy | `#0F3D64` (Deep Blue) | `#FFFFFF` (White) | **10.5:1 (AAA)** |
   | Secondary Labels | `#374151` (Dark Slate) | `#FFFFFF` (White) | **9.5:1 (AAA)** |
   | Accent / Status | `#065F46` (Forest Green) | `#FFFFFF` (White) | **7.1:1 (AAA)** |
   | Table Alternate Row | `#F8FAFC` (Light Tint) | Text `#1A202C` | **15.2:1 (AAA)** |

### 2.5 Multi-Language & Locale Synchronization (`/Lang`)
1. **Natural Language Declaration:** The generated PDF must declare its BCP 47 language code (`/Lang (et-EE)`, `(en-US)`, `(fi-FI)`, `(sv-SE)`, `(lv-LV)`, `(lt-LT)`).
2. **Oracle XLIFF Translations:** All static labels (*Invoice Number*, *Due Date*, *Total*, etc.) must be defined via companion `.xlf` translation files (`arve_test_standard_{lang}.xlf`), allowing a single master RTF template to render into all 6 languages seamlessly.

---

## 3. Windows Enterprise & Screen Reader Verification Playbook

Enterprise workstations primarily run Windows 10/11. The following verification procedures ensure flawless operation in corporate IT environments:

### 3.1 NVDA (NonVisual Desktop Access - Free & Open Source)
1. Open the rendered PDF in Adobe Acrobat Reader or Google Chrome / Microsoft Edge.
2. Start NVDA (`Ctrl + Alt + N`).
3. Press `H` to cycle through headings (`Heading 1`, `Heading 2`). Verify that the document title and sections are announced in correct order.
4. Press `T` to jump to the invoice line items table.
5. Use `Ctrl + Alt + Left/Right/Up/Down Arrow` to navigate table cells. NVDA must announce the column header before every cell value (e.g. *"Kirjeldus veerg: Oracle 23ai Konsultatsioon. Summa veerg: 520,00 EUR"*).

### 3.2 JAWS (Freedom Scientific)
1. Open PDF in Adobe Acrobat Reader.
2. Press `Insert + F6` to open the Headings list. Verify structural hierarchy.
3. Press `Insert + F3` -> Select *Tables*. Verify row and column counts.

### 3.3 Microsoft Edge Read Aloud
1. Open PDF in Microsoft Edge.
2. Press **`Ctrl + Shift + U`** (Read Aloud).
3. Verify that the synthesized speech pronounces Estonian and Nordic numbers, dates, and amounts naturally with correct pronunciation.

### 3.4 Apple VoiceOver (macOS)
1. Open PDF in Preview or Safari.
2. Press **`Cmd + F5`** to toggle VoiceOver.
3. Use `Control + Option + Right Arrow` to step through document elements sequentially.

---

## 4. 10-Point "Go / No-Go" Production Checklist

Before merging any new template or committing to `main`:

| # | Check Item | Requirement | Tool / Verification |
| :-: | :--- | :--- | :--- |
| **1** | Heading Hierarchy | `Heading 1` for title, `Heading 2` for sections | `validate-rtf-accessibility.sh` |
| **2** | Repeat Header | `\trhdr` flag present on table header | `validate-rtf-accessibility.sh` |
| **3** | Image Alt Text | All logos have descriptive alt text | `validate-rtf-accessibility.sh` |
| **4** | Centralized Logo | Referenced via `common/images/` | File path check |
| **5** | Color Contrast | All text $\ge 4.5:1$ against background | Color contrast analyzer |
| **6** | Summary-First UX | Key invoice terms placed before line items | Visual review |
| **7** | Tagged PDF | `Tagged: yes` and `/MarkInfo` in output | `validate-pdf-accessibility.sh` |
| **8** | Document Language | `/Lang` tag declared and matches locale | `validate-pdf-accessibility.sh` |
| **9** | Speech Transcript | Simulated screen reader timeline is logical | Template Studio `♿ Ekraanilugeja Vaade` |
| **10**| CI Quality Gate | `deploy-publisher-reports.yml` & `validate-rtf-accessibility.sh` exit 0 | GitHub Actions & Local CI |

---

## 5. Architectural Quality Gate & File Locations

- **Skill Location:** `.agents/skills/oracle_publisher_accessibility/SKILL.md`
- **Application Directory:** `applications/publisher/Custom/<Domain>/<ReportName>/`
- **CI/CD Quality Gate:** `.github/workflows/deploy-publisher-reports.yml` (RTF a11y linter & headless test-render)
- **RTF Linter:** `scripts/publisher/validate-rtf-accessibility.sh` & `docker/publisher-designer/rtf-a11y-linter.py`
- **PDF Validator:** `scripts/publisher/validate-pdf-accessibility.sh` & `docker/publisher-designer/pdf-a11y-validator.py`
- **Central Asset Store:** `templates/publisher/common/images/company_logo.png`
- **Starter Template:** `applications/publisher/Custom/Invoices/Invoice_Report/Invoice_Report.xdo/template.rtf`
- **Test Suite:** `templates/publisher/accessibility_suite/` & `tests/integration/test-publisher-accessibility-suite.sh`
- **Official Compliance Report:** `tests/reports/accessibility_compliance_acr.md`
- **Audit Metrics:** `metrics/accessibility_benchmarks.json`

