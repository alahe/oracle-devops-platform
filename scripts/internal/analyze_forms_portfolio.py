#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Oracle Forms Portfolio & Modernization Analyzer Engine
Scans and analyzes Oracle Forms XML definitions (frmf2xml output).
Computes complexity scores, database dependencies, trigger lines, and migration waves.
100% vendor-neutral, enterprise-generic.
"""

import os
import sys
import json
import glob
import xml.etree.ElementTree as ET
from datetime import datetime

def strip_ns(tag):
    return tag.split('}')[-1] if '}' in tag else tag

def analyze_form_xml(file_path):
    rel_path = os.path.basename(file_path)
    form_name = os.path.splitext(rel_path)[0].replace("_fmb", "")
    
    result = {
        "file": rel_path,
        "form_name": form_name,
        "title": form_name,
        "data_blocks": 0,
        "control_blocks": 0,
        "total_items": 0,
        "item_types": {},
        "db_items": 0,
        "non_db_items": 0,
        "triggers_count": 0,
        "trigger_names": [],
        "trigger_code_lines": 0,
        "program_units_count": 0,
        "program_units_code_lines": 0,
        "canvases_count": 0,
        "windows_count": 0,
        "lovs_count": 0,
        "db_tables": set(),
        "complexity_score": 0,
        "wave": 1,
        "category": "Simple CRUD"
    }

    try:
        tree = ET.parse(file_path)
        root = tree.getroot()
    except Exception as e:
        result["error"] = str(e)
        return result

    for elem in root.iter():
        tag = strip_ns(elem.tag)
        
        if tag == "FormModule":
            result["title"] = elem.attrib.get("Title", elem.attrib.get("Name", form_name))
        
        elif tag == "Block":
            is_db = elem.attrib.get("DatabaseBlock", "false").lower() == "true"
            data_source = elem.attrib.get("QueryDataSourceName", elem.attrib.get("Name", ""))
            if is_db:
                result["data_blocks"] += 1
                if data_source and not data_source.startswith(":"):
                    result["db_tables"].add(data_source.upper())
            else:
                result["control_blocks"] += 1

        elif tag == "Item":
            result["total_items"] += 1
            item_type = elem.attrib.get("ItemType", "Text Item")
            result["item_types"][item_type] = result["item_types"].get(item_type, 0) + 1
            
            is_db_col = elem.attrib.get("DatabaseItem", "true").lower() == "true"
            if is_db_col:
                result["db_items"] += 1
            else:
                result["non_db_items"] += 1

            col_name = elem.attrib.get("ColumnName", "")
            if col_name and "." in col_name:
                table_part = col_name.split(".")[0].upper()
                result["db_tables"].add(table_part)

        elif tag == "Trigger":
            result["triggers_count"] += 1
            trg_name = elem.attrib.get("Name", "UNKNOWN")
            result["trigger_names"].append(trg_name)
            text = elem.attrib.get("TriggerText", "") or (elem.text or "")
            lines = len([l for l in text.splitlines() if l.strip()])
            result["trigger_code_lines"] += lines

        elif tag == "ProgramUnit":
            result["program_units_count"] += 1
            text = elem.attrib.get("ProgramUnitText", "") or (elem.text or "")
            lines = len([l for l in text.splitlines() if l.strip()])
            result["program_units_code_lines"] += lines

        elif tag == "Canvas":
            result["canvases_count"] += 1

        elif tag == "Window":
            result["windows_count"] += 1

        elif tag == "LOV":
            result["lovs_count"] += 1

    result["db_tables"] = sorted(list(result["db_tables"]))

    # Complexity score formula:
    # Items: 1pt, Data Blocks: 5pt, Control Blocks: 8pt (usually custom state),
    # Triggers: 4pt + 0.1pt/line, Program Units: 5pt + 0.1pt/line, LOVs: 3pt, Canvases: 4pt
    score = (
        result["total_items"] * 1 +
        result["data_blocks"] * 5 +
        result["control_blocks"] * 8 +
        result["triggers_count"] * 4 +
        int(result["trigger_code_lines"] * 0.1) +
        result["program_units_count"] * 5 +
        int(result["program_units_code_lines"] * 0.1) +
        result["lovs_count"] * 3 +
        result["canvases_count"] * 4
    )
    result["complexity_score"] = score

    # Wave Categorization
    if score <= 40 and result["control_blocks"] <= 1 and result["triggers_count"] <= 4:
        result["wave"] = 1
        result["category"] = "Wave 1: Simple CRUD / Lookups"
    elif score <= 120 and result["program_units_count"] <= 2:
        result["wave"] = 2
        result["category"] = "Wave 2: Standard Master-Detail Transactions"
    else:
        result["wave"] = 3
        result["category"] = "Wave 3: Complex Financial Monolith"

    return result

def main():
    target_dir = sys.argv[1] if len(sys.argv) > 1 else "forms_apps"
    output_json = sys.argv[2] if len(sys.argv) > 2 else "metrics/forms_portfolio_analysis.json"
    output_md = sys.argv[3] if len(sys.argv) > 3 else "tests/reports/forms_portfolio_analysis.md"

    if not os.path.exists(target_dir):
        print(f"Directory not found: {target_dir}", file=sys.stderr)
        sys.exit(1)

    xml_files = sorted(glob.glob(os.path.join(target_dir, "*.xml")))
    if not xml_files:
        print(f"No XML files found in {target_dir}. Did you run form-to-xml.sh?", file=sys.stderr)
        sys.exit(0)

    forms_data = []
    for xf in xml_files:
        forms_data.append(analyze_form_xml(xf))

    total_forms = len(forms_data)
    w1_count = len([f for f in forms_data if f["wave"] == 1])
    w2_count = len([f for f in forms_data if f["wave"] == 2])
    w3_count = len([f for f in forms_data if f["wave"] == 3])
    total_blocks = sum(f["data_blocks"] + f["control_blocks"] for f in forms_data)
    total_items = sum(f["total_items"] for f in forms_data)
    total_triggers = sum(f["triggers_count"] for f in forms_data)
    total_trig_lines = sum(f["trigger_code_lines"] for f in forms_data)
    total_pu_lines = sum(f["program_units_code_lines"] for f in forms_data)

    payload = {
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "total_forms_scanned": total_forms,
        "wave_breakdown": {
            "wave_1_simple": w1_count,
            "wave_2_master_detail": w2_count,
            "wave_3_complex_monolith": w3_count
        },
        "aggregate_metrics": {
            "total_blocks": total_blocks,
            "total_items": total_items,
            "total_triggers": total_triggers,
            "total_trigger_code_lines": total_trig_lines,
            "total_program_unit_code_lines": total_pu_lines
        },
        "forms": forms_data
    }

    os.makedirs(os.path.dirname(output_json), exist_ok=True)
    with open(output_json, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2)

    # Generate Markdown Report
    os.makedirs(os.path.dirname(output_md), exist_ok=True)
    with open(output_md, "w", encoding="utf-8") as f:
        f.write("# 🏛️ Oracle Forms Modernization Portfolio Analysis\n\n")
        f.write(f"- **Generated At:** {payload['timestamp']}\n")
        f.write(f"- **Total Forms Analyzed:** {total_forms}\n")
        f.write(f"- **Wave 1 (Simple CRUD / Lookups):** {w1_count}\n")
        f.write(f"- **Wave 2 (Master-Detail Transactions):** {w2_count}\n")
        f.write(f"- **Wave 3 (Complex Financial Monoliths):** {w3_count}\n\n")
        
        f.write("## 📊 Aggregate Complexity Metrics\n\n")
        f.write(f"| Metric | Total Count |\n|---|---|\n")
        f.write(f"| Total Blocks (Data + Control) | **{total_blocks}** |\n")
        f.write(f"| Total Items (Inputs, Buttons, Lists) | **{total_items}** |\n")
        f.write(f"| Total Triggers | **{total_triggers}** |\n")
        f.write(f"| Embedded PL/SQL Trigger Lines | **{total_trig_lines}** |\n")
        f.write(f"| Program Units PL/SQL Lines | **{total_pu_lines}** |\n\n")

        f.write("## 📋 Forms Portfolio Inventory & Wave Categorization\n\n")
        f.write("| Form Module | Title | Blocks (DB/Ctrl) | Items | Triggers (Lines) | Score | Target Migration Wave |\n")
        f.write("|---|---|---|---|---|---|---|\n")
        for f_item in forms_data:
            f.write(f"| `{f_item['form_name']}` | {f_item['title']} | {f_item['data_blocks']} / {f_item['control_blocks']} | {f_item['total_items']} | {f_item['triggers_count']} ({f_item['trigger_code_lines']}) | **{f_item['complexity_score']}** | `{f_item['category']}` |\n")
        
        f.write("\n---\n*Report automatically generated by `scripts/forms/analyze-forms-portfolio.sh`*\n")

    print(f"Analysis successfully exported to {output_json} and {output_md}")

if __name__ == "__main__":
    main()
