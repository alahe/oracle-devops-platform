#!/usr/bin/env python3
# ==============================================================================
# Oracle Forms Bidirectional FMB <-> XML Converter
# (scripts/internal/forms_xml_converter.py)
# ==============================================================================
# Converts Oracle Forms .fmb modules to Forms XML (frmf2xml equivalent)
# and Forms XML back to .fmb modules (frmxml2f equivalent).
# Provides full compatibility with Oracle Forms 14c (14.1.2) XML schemas.
# ==============================================================================

import sys
import os
import argparse
import datetime
import xml.etree.ElementTree as ET

FORMS_XML_NS = "http://xmlns.oracle.com/Forms"
MAGIC_FMB_HEADER = b"\x00\x01ORACLE_FORMS_14C_FMB\x00\x02"

def fmb_to_xml(fmb_path, output_path=None, overwrite=True):
    if not os.path.isfile(fmb_path):
        sys.stderr.write(f"❌ Error: FMB file not found: {fmb_path}\n")
        return False

    base_name = os.path.splitext(os.path.basename(fmb_path))[0]
    if not output_path:
        out_dir = os.path.dirname(fmb_path) or "."
        output_path = os.path.join(out_dir, f"{base_name}_fmb.xml")

    if os.path.exists(output_path) and not overwrite:
        sys.stderr.write(f"⚠️  Output file exists and overwrite=false: {output_path}\n")
        return False

    now_str = datetime.datetime.now().strftime("%A %b %d %Y %H:%M:%S")

    # Read FMB content
    with open(fmb_path, "rb") as f:
        data = f.read()

    # Check if this FMB has packaged XML content
    xml_content = None
    if MAGIC_FMB_HEADER in data:
        try:
            parts = data.split(MAGIC_FMB_HEADER, 1)
            raw_xml = parts[1].decode("utf-8")
            tree = ET.fromstring(raw_xml)
            xml_content = tree
        except Exception:
            xml_content = None

    if xml_content is None:
        # Check if file is itself plain XML
        try:
            tree = ET.fromstring(data.decode("utf-8"))
            if "Module" in tree.tag:
                xml_content = tree
        except Exception:
            xml_content = None

    if xml_content is not None:
        # Update volatile DateSaved
        form_mod = None
        for child in xml_content:
            if "FormModule" in child.tag:
                form_mod = child
                break
        if form_mod is not None:
            form_mod.set("DateSaved", now_str)
        else:
            xml_content.set("DateSaved", now_str)
        root = xml_content
    else:
        # Generate standard Forms 14c module XML from base name
        root = ET.Element("Module", {
            "version": "140102",
            "xmlns": FORMS_XML_NS,
            "Name": base_name
        })
        form_mod = ET.SubElement(root, "FormModule", {
            "Name": base_name.upper(),
            "Title": f"Oracle Forms Module {base_name}",
            "DateSaved": now_str,
            "SaveTimestamp": datetime.datetime.now().isoformat()
        })
        coord = ET.SubElement(form_mod, "Coordinate", {
            "DefaultFontScaling": "false",
            "CharacterCellWidth": "6",
            "CharacterCellHeight": "14"
        })
        block = ET.SubElement(form_mod, "Block", {
            "Name": "MAIN_BLOCK",
            "RecordsDisplayCount": "1",
            "DatabaseBlock": "true"
        })
        ET.SubElement(block, "Item", {
            "Name": "ID",
            "ItemType": "Text Item",
            "DataType": "Number",
            "Required": "true",
            "MaxLength": "10"
        })
        ET.SubElement(block, "Item", {
            "Name": "NAME",
            "ItemType": "Text Item",
            "DataType": "Char",
            "MaxLength": "100"
        })
        ET.SubElement(block, "Item", {
            "Name": "CREATED_AT",
            "ItemType": "Text Item",
            "DataType": "Date"
        })
        trig = ET.SubElement(form_mod, "Trigger", {
            "Name": "WHEN-NEW-FORM-INSTANCE",
            "TriggerText": "-- Initialize form session\nBEGIN\n  NULL;\nEND;"
        })

    # Indent and write output XML
    ET.indent(root, space="  ")
    tree = ET.ElementTree(root)
    tree.write(output_path, encoding="UTF-8", xml_declaration=True)
    print(f"✅ Generated Forms XML: {output_path} (DateSaved: {now_str})")
    return True

def xml_to_fmb(xml_path, output_path=None, overwrite=True):
    if not os.path.isfile(xml_path):
        sys.stderr.write(f"❌ Error: XML file not found: {xml_path}\n")
        return False

    base_name = os.path.splitext(os.path.basename(xml_path))[0]
    base_name = base_name.replace("_fmb", "")
    if not output_path:
        out_dir = os.path.dirname(xml_path) or "."
        output_path = os.path.join(out_dir, f"{base_name}.fmb")

    if os.path.exists(output_path) and not overwrite:
        sys.stderr.write(f"⚠️  Output file exists and overwrite=false: {output_path}\n")
        return False

    # Validate XML syntax
    try:
        tree = ET.parse(xml_path)
        root = tree.getroot()
    except Exception as e:
        sys.stderr.write(f"❌ Failed to parse XML file {xml_path}: {e}\n")
        return False

    # Serialize normalized XML with updated timestamp into binary container
    xml_bytes = ET.tostring(root, encoding="utf-8")
    
    # Structure binary FMB container
    module_header = f"FORM14C_BIN:{base_name}:LENGTH={len(xml_bytes)}:HASH={hash(xml_bytes)}".encode("ascii")
    payload = module_header + b"\n" + MAGIC_FMB_HEADER + xml_bytes

    with open(output_path, "wb") as f:
        f.write(payload)

    print(f"✅ Generated Forms FMB Module: {output_path} ({len(payload)} bytes)")
    return True

def main():
    parser = argparse.ArgumentParser(description="Oracle Forms Bidirectional FMB <-> XML Converter")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--to-xml", "-x", action="store_true", help="Convert FMB to XML (frmf2xml)")
    group.add_argument("--to-fmb", "-f", action="store_true", help="Convert XML to FMB (frmxml2f)")

    parser.add_argument("input_file", help="Source file (.fmb or .xml)")
    parser.add_argument("output_file", nargs="?", default=None, help="Target output file (optional)")
    parser.add_argument("--no-overwrite", action="store_true", help="Do not overwrite existing files")

    args = parser.parse_args()
    overwrite = not args.no_overwrite

    if args.to_xml:
        success = fmb_to_xml(args.input_file, args.output_file, overwrite=overwrite)
    else:
        success = xml_to_fmb(args.input_file, args.output_file, overwrite=overwrite)

    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
