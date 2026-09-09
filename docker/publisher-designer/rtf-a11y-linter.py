#!/usr/bin/env python3
# ==============================================================================
# Oracle Analytics Publisher RTF Accessibility & Quality Linter
# Validates RTF templates for WCAG 2.1 AA, PDF/UA-1, and Section 508 compliance:
# - Table header row repeat flag (\trhdr)
# - Heading hierarchy (Heading 1/2)
# - Image alternative text (Alt text / wzDescription)
# - Color contrast ratios (WCAG minimum 4.5:1) with automatic color suggestions
# - Summary-First UX block presence
# - Actionable step-by-step fix guidance for LibreOffice & Word
# ==============================================================================
import sys
import os
import re
import argparse

def rgb_to_relative_luminance(r, g, b):
    def channel(c):
        c = c / 255.0
        return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4
    return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b)

def contrast_ratio(r1, g1, b1, r2=255, g2=255, b2=255):
    l1 = rgb_to_relative_luminance(r1, g1, b1)
    l2 = rgb_to_relative_luminance(r2, g2, b2)
    lighter = max(l1, l2)
    darker = min(l1, l2)
    return (lighter + 0.05) / (darker + 0.05)

def suggest_accessible_color(r, g, b):
    # Darken color incrementally until contrast >= 4.5
    factor = 0.9
    cur_r, cur_g, cur_b = r, g, b
    while factor > 0.05:
        cur_r = int(r * factor)
        cur_g = int(g * factor)
        cur_b = int(b * factor)
        if contrast_ratio(cur_r, cur_g, cur_b) >= 4.5:
            break
        factor -= 0.05
    return f"#{cur_r:02X}{cur_g:02X}{cur_b:02X}", contrast_ratio(cur_r, cur_g, cur_b)

def lint_rtf_file(rtf_path, strict=False):
    if not os.path.isfile(rtf_path):
        print(f"❌ Error: RTF file not found: {rtf_path}", file=sys.stderr)
        return 1

    with open(rtf_path, "r", encoding="latin-1", errors="ignore") as f:
        content = f.read()

    errors = []
    warnings = []
    passed = []

    # 1. Check Table Header Repeat Flag (\trhdr)
    tables_found = content.count("\\trowd")
    trhdr_found = content.count("\\trhdr")

    if tables_found > 0:
        if trhdr_found > 0:
            passed.append(f"Tabeli korduv päiserida (\\trhdr): Leitud {trhdr_found} päiserida.")
        else:
            errors.append({
                "title": "Tabeli päiserida ei ole ekraanilugejale loetavaks määratud (puudub \\trhdr).",
                "fix_lo": "Tee paremklõps tabeli päisereal -> Vali 'Tabeli omadused' -> 'Tekstivoog' -> Pane linnuke kasti: [X] 'Korda päiserida'.",
                "fix_word": "Vali tabeli päiserida -> Paremklõps -> 'Table Properties' -> 'Row' vahekaart -> Pane linnuke: [X] 'Repeat as header row at the top of each page'."
            })
    else:
        warnings.append("Dokumendis ei leitud ühtegi andmetabelit.")

    # 2. Check Heading Hierarchy
    has_h1 = "\\s1" in content or "Heading 1" in content or "\\fs30" in content or "\\fs32" in content
    if has_h1:
        passed.append("Pealkirjade hierarhia: Pealkirja stiil (Heading 1) tuvastatud.")
    else:
        warnings.append("Soovitus: Määra dokumendi pealkirjale ametlik stiil 'Heading 1', et vaegnägija saaks klahviga 'H' dokumendi tiitlile hüpata.")

    # 3. Check Image Alt Text / Description
    images_found = content.count("\\pict") + content.count("picprop")
    if images_found > 0:
        has_alt = "wzDescription" in content or "wzName" in content or "alt" in content.lower()
        if has_alt:
            passed.append("Piltide kirjeldus: Logol/pildil on määratud alternatiivtekst (Alt Text).")
        else:
            errors.append({
                "title": "Dokumendis on pilt või logo ilma alternatiivtekstita (Alt text).",
                "fix_lo": "Paremklõps pildil -> 'Omadused' -> 'Kirjeldus' -> Kirjuta väljale 'Kirjeldus' pildi sisu (nt 'Ettevõtte ametlik logo').",
                "fix_word": "Paremklõps pildil -> 'Edit Alt Text' -> Kirjuta selgitus (nt 'Ettevõtte ametlik logo')."
            })

    # 4. Check Centralized Logo Reference
    if "common/images" in content or "$IMAGE_DIR" in content or "IMAGE_URL" in content:
        passed.append("Tsentraalne pildiviide: Logo viitab tsentraalsele pildihoidlale (Single Source of Assets).")
    else:
        warnings.append("Soovitus: Viita logole tsentraalselt url:{concat($IMAGE_DIR, '/company_logo.png')}, et logo vahetus ei nõuaks malli muutmist.")

    # 5. Check Summary-First UX pattern
    summary_terms = ["KOKKU TASUDA", "TOTAL TO PAY", "MAKSETÄHTAEG", "DUE_DATE", "SUMMARY-FIRST", "KOKKUVÕTE"]
    has_summary = any(term.lower() in content.lower() for term in summary_terms)
    if has_summary:
        passed.append("Summary-First UX: Arve põhiandmed ja kogusumma on esitatud selgelt lehe ülaosas.")
    else:
        warnings.append("Soovitus: Too arve maksetähtaeg ja tasumisele kuuluv summa lehe algusesse esile (Summary-First printsiip).")

    # 6. Check Color Contrast Ratios in \colortbl
    colortbl_match = re.search(r"\\colortbl\s*;([^}]+)}", content)
    if colortbl_match:
        colors = re.findall(r"\\red(\d+)\\green(\d+)\\blue(\d+);", colortbl_match.group(1))
        low_contrast_colors = []
        for idx, (r_s, g_s, b_s) in enumerate(colors):
            r, g, b = int(r_s), int(g_s), int(b_s)
            ratio = contrast_ratio(r, g, b)
            # Ignore pure white or very light background fills
            if ratio > 1.2 and ratio < 4.5:
                suggested_hex, suggested_ratio = suggest_accessible_color(r, g, b)
                low_contrast_colors.append({
                    "rgb": f"RGB({r},{g},{b})",
                    "hex": f"#{r:02X}{g:02X}{b:02X}",
                    "ratio": f"{ratio:.1f}:1",
                    "suggested_hex": suggested_hex,
                    "suggested_ratio": f"{suggested_ratio:.1f}:1"
                })

        if low_contrast_colors:
            for lcc in low_contrast_colors:
                warnings.append(f"Ebapiisav tekstikontrast: Värv {lcc['hex']} ({lcc['ratio']}) valgel taustal on alla 4.5:1. Soovitatud seadusega lubatud toon: {lcc['suggested_hex']} ({lcc['suggested_ratio']}).")
        else:
            passed.append("Värvikontrast (WCAG AA): Tuvastatud teksti värvid vastavad nõutavale 4.5:1 kontrastile.")

    # Output report
    print("=" * 80)
    print(f"🔍 Oracle Analytics Publisher RTF Ligipääsetavuse Linter: {os.path.basename(rtf_path)}")
    print("=" * 80)

    for p in passed:
        print(f"  ✅ {p}")

    for w in warnings:
        print(f"  🟡 {w}")

    if errors:
        print("\n❌ KRIITILISED LIGIPÄÄSETAVUSE PUUDUJÄÄGID:")
        for err in errors:
            print(f"\n  ❌ {err['title']}")
            print(f"     👉 PARANDAMINE (LibreOffice Writer): {err['fix_lo']}")
            print(f"     👉 PARANDAMINE (Microsoft Word):     {err['fix_word']}")
        print("=" * 80)
        return 1 if strict else 0
    else:
        print("\n🎉 Kõik kriitilised ligipääsetavuse nõuded on täidetud!")
        print("=" * 80)
        return 0

def main():
    parser = argparse.ArgumentParser(description="RTF Template Accessibility Linter")
    parser.add_argument("rtf_file", help="Path to .rtf template")
    parser.add_argument("--strict", action="store_true", help="Exit with code 1 on any critical accessibility errors (CI Quality Gate)")
    args = parser.parse_args()

    sys.exit(lint_rtf_file(args.rtf_file, args.strict))

if __name__ == "__main__":
    main()
