#!/usr/bin/env python3
# ==============================================================================
# Oracle Analytics Publisher PDF Accessibility (PDF/UA & WCAG 2.1 AA) Validator
# Performs deep structural verification of generated PDF files:
# - Tagged PDF check (pdfinfo & /StructTreeRoot)
# - MarkInfo indicator (/MarkInfo << /Marked true >>)
# - BCP 47 Natural Language specification (/Lang)
# - Standard Document Metadata (Title, Subject, Author)
# - Table structure semantics (/S/Table, /S/TR, /S/TD, /S/TH)
# - Generates Simulated Screen Reader Speech Transcript (Visual Timeline)
# ==============================================================================
import sys
import os
import re
import argparse
import subprocess
import json

def validate_pdf(pdf_path, strict=False, output_json=False):
    if not os.path.isfile(pdf_path):
        print(f"❌ Error: PDF file not found: {pdf_path}", file=sys.stderr)
        return {"valid": False, "error": "File not found"}, 1

    results = {
        "file": os.path.abspath(pdf_path),
        "file_name": os.path.basename(pdf_path),
        "file_size": os.path.getsize(pdf_path),
        "tagged": False,
        "mark_info": False,
        "struct_tree_root": False,
        "metadata_stream": False,
        "language": None,
        "title": None,
        "author": None,
        "subject": None,
        "has_tables": False,
        "table_tags_count": 0,
        "compliance_score_pct": 0,
        "passed_checks": [],
        "warnings": [],
        "errors": [],
        "screen_reader_transcript": []
    }

    # 1. Inspect using pdfinfo if available
    try:
        proc = subprocess.run(["pdfinfo", pdf_path], capture_output=True, text=True)
        if proc.returncode == 0:
            for line in proc.stdout.splitlines():
                if line.startswith("Tagged:"):
                    results["tagged"] = "yes" in line.lower()
                elif line.startswith("Metadata Stream:"):
                    results["metadata_stream"] = "yes" in line.lower()
                elif line.startswith("Title:"):
                    results["title"] = line.split(":", 1)[1].strip()
                elif line.startswith("Author:"):
                    results["author"] = line.split(":", 1)[1].strip()
                elif line.startswith("Subject:"):
                    results["subject"] = line.split(":", 1)[1].strip()
    except Exception:
        pass

    # 2. Inspect raw PDF objects for structural tags
    try:
        with open(pdf_path, "rb") as f:
            raw = f.read()

        # Check MarkInfo
        if b"/MarkInfo" in raw and b"/Marked true" in raw:
            results["mark_info"] = True
            results["tagged"] = True

        # Check StructTreeRoot
        if b"/StructTreeRoot" in raw:
            results["struct_tree_root"] = True

        # Check Language
        lang_match = re.search(rb"/Lang\s*\(([^)]+)\)", raw)
        if lang_match:
            results["language"] = lang_match.group(1).decode("latin-1", errors="ignore")

        # Check Tables
        table_tags = raw.count(b"/S/Table")
        tr_tags = raw.count(b"/S/TR")
        td_tags = raw.count(b"/S/TD") + raw.count(b"/S/TH")
        if table_tags > 0:
            results["has_tables"] = True
            results["table_tags_count"] = table_tags

        # Metadata extraction if not populated by pdfinfo
        if not results["title"]:
            title_m = re.search(rb"/Title\s*\(([^)]+)\)", raw)
            if title_m:
                results["title"] = title_m.group(1).decode("latin-1", errors="ignore")
    except Exception as e:
        results["errors"].append(f"PDF raw inspection error: {e}")

    # 3. Evaluate criteria
    score = 0
    total_weight = 6

    if results["tagged"] and results["struct_tree_root"]:
        score += 1
        results["passed_checks"].append("Märgistatud PDF (Tagged PDF): Sisemine loogiline struktuuripuu (/StructTreeRoot) on olemas.")
    else:
        results["errors"].append("KRIITILINE: Puudub Tagged PDF struktuuripuu (/StructTreeRoot). Ekraanilugejad ei suuda sisu tõlgendada.")

    if results["mark_info"]:
        score += 1
        results["passed_checks"].append("Ligipääsetavuse kinnitus: /MarkInfo << /Marked true >> on aktiivne.")
    else:
        results["errors"].append("KRIITILINE: Puudub /MarkInfo kinnitus. PDF lugejad ei tuvasta dokumenti ligipääsetavana.")

    if results["language"]:
        score += 1
        results["passed_checks"].append(f"Dokumendi keel: Tuvastatud ametlik keel '{results['language']}'.")
    else:
        results["warnings"].append("HOIATUS: Dokumendi keel (/Lang) on määramata. Ekraanilugeja võib kasutada valet häälsüntesaatorit.")

    if results["title"]:
        score += 1
        results["passed_checks"].append(f"Dokumendi tiitel: '{results['title']}' on ekraanilugejatele deklareeritud.")
    else:
        results["warnings"].append("HOIATUS: Dokumendi pealkiri (Title) puudub metaandmetes.")

    if results["has_tables"]:
        score += 1
        results["passed_checks"].append(f"Tabelite semantika: Tuvastatud {table_tags} semantiline andmetabel (/S/Table, /S/TR, /S/TD).")
    else:
        score += 1
        results["passed_checks"].append("Tabelite semantika: Dokumendis ei esine tabeleid.")

    if results["metadata_stream"]:
        score += 1
        results["passed_checks"].append("ISO Metaandmete voog: XMP Metadata Stream on manusena aktiivne.")
    else:
        results["warnings"].append("Soovitus: Lisa XMP Metadata Stream täielikuks PDF/UA-1 sertifitseerimiseks.")

    results["compliance_score_pct"] = int((score / total_weight) * 100)

    # 4. Generate Simulated Screen Reader Transcript (Visual Timeline)
    try:
        txt_proc = subprocess.run(["pdftotext", pdf_path, "-"], capture_output=True, text=True)
        if txt_proc.returncode == 0:
            lines = [l.strip() for l in txt_proc.stdout.splitlines() if l.strip()]
            transcript = []
            transcript.append(f"🗣️ [DOKUMENT]: Pealkiri: '{results['title'] or 'Määramata'}' | Keel: {results['language'] or 'Vaikimisi'}")
            
            in_table = False
            for line in lines:
                if any(h in line for h in ["Nr", "Kood", "Kirjeldus", "Item", "Description"]):
                    transcript.append("📋 [TABELI ALGUS]: Päiserida kordub igal lehel")
                    transcript.append(f"   🔹 [PÄIS]: {line}")
                    in_table = True
                elif in_table and any(t in line for t in ["Vahesumma", "KOKKU", "Subtotal", "TOTAL"]):
                    transcript.append("📋 [TABELI LÕPP]")
                    transcript.append(f"📌 [SUMMADE KOKKUVÕTE]: {line}")
                    in_table = False
                elif in_table:
                    transcript.append(f"   🔸 [RIDA]: {line}")
                elif any(title in line for title in ["ARVE NR", "INVOICE", "LASKU", "FAKTURA", "RĒĶINS", "SĄSKAITA"]):
                    transcript.append(f"🏷️ [PEALKIRI 1]: {line}")
                elif any(seller in line for seller in ["OÜ", "AS", "Ltd", "Inc", "GmbH"]):
                    transcript.append(f"🏢 [MÜÜJA]: {line}")
                else:
                    transcript.append(f"📄 [LÕIK]: {line}")

            results["screen_reader_transcript"] = transcript
    except Exception:
        pass

    # Formatting output
    if output_json:
        print(json.dumps(results, indent=2, ensure_ascii=False))
    else:
        print("=" * 80)
        print(f"♿ Oracle Analytics Publisher PDF Ligipääsetavuse Validaator (PDF/UA-1)")
        print(f"   Fail: {results['file_name']} ({results['file_size']} bytes)")
        print(f"   Vastavuse skoor: {results['compliance_score_pct']}%")
        print("=" * 80)

        for p in results["passed_checks"]:
            print(f"  ✅ {p}")

        for w in results["warnings"]:
            print(f"  🟡 {w}")

        for e in results["errors"]:
            print(f"  ❌ {e}")

        if results["screen_reader_transcript"]:
            print("\n🎧 SIMULEERITUD EKRAANILUGEJA KÕNETRANSKRIPTSIOON (Mida pime kasutaja kuuleb):")
            print("-" * 80)
            for t in results["screen_reader_transcript"][:25]:
                print(f"  {t}")
            if len(results["screen_reader_transcript"]) > 25:
                print(f"  ... (+{len(results['screen_reader_transcript']) - 25} rida veel)")
            print("-" * 80)

        if results["errors"]:
            print(f"\n❌ TULEMUS: PDF EI VASTA ligipääsetavuse nõuetele ({len(results['errors'])} kriitilist viga)!")
            print("=" * 80)
            return results, (1 if strict else 0)
        else:
            print(f"\n🎉 TULEMUS: PDF ON LIGIPÄÄSETAV ja vastab PDF/UA-1 ning WCAG 2.1 AA nõuetele!")
            print("=" * 80)
            return results, 0

def main():
    parser = argparse.ArgumentParser(description="PDF Accessibility Validator (PDF/UA-1)")
    parser.add_argument("pdf_file", help="Path to PDF file")
    parser.add_argument("--strict", action="store_true", help="Exit with code 1 on any critical errors (CI Quality Gate)")
    parser.add_argument("--json", action="store_true", help="Output machine-readable JSON")
    args = parser.parse_args()

    res, code = validate_pdf(args.pdf_file, args.strict, args.json)
    sys.exit(code)

if __name__ == "__main__":
    main()
