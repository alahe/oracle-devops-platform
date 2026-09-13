#!/usr/bin/env python3
# ==============================================================================
# Oracle Forms XML Semantic Normalizer & Deep AST Diff Comparator
# ==============================================================================
# Compares two Oracle Forms XML files semantically, ignoring volatile metadata
# such as DateSaved, SaveTimestamp, CompilerVersion, or build hashes, but
# strictly asserting that 100% of FormModule, Blocks, Items, Data Types,
# Triggers, Canvases, and properties match.
# ==============================================================================

import sys
import os
import argparse
import xml.etree.ElementTree as ET

VOLATILE_ATTRIBUTES = {
    "datesaved",
    "savetimestamp",
    "timestamp",
    "time",
    "date",
    "compilerversion",
    "checksum",
    "hash",
    "fileversion",
    "fileformatversion",
    "versiondate"
}

def normalize_text(text):
    if text is None:
        return ""
    return text.strip()

def strip_volatile_attrs(attrib):
    cleaned = {}
    for k, v in attrib.items():
        if k.lower() not in VOLATILE_ATTRIBUTES:
            cleaned[k] = normalize_text(v)
    return cleaned

class FormsXmlNode:
    def __init__(self, element, path=""):
        self.tag = element.tag.split("}")[-1] if "}" in element.tag else element.tag
        self.attrs = strip_volatile_attrs(element.attrib)
        self.text = normalize_text(element.text)
        self.name = self.attrs.get("Name", self.attrs.get("name", ""))
        self.path = f"{path}/{self.tag}" + (f"[{self.name}]" if self.name else "")
        self.children = [FormsXmlNode(child, self.path) for child in element]

    def to_element(self):
        el = ET.Element(self.tag)
        for k in sorted(self.attrs.keys()):
            el.set(k, self.attrs[k])
        if self.text:
            el.text = self.text
        for child in self.children:
            el.append(child.to_element())
        return el

def compare_nodes(node1, node2, diffs):
    # 1. Tag comparison
    if node1.tag != node2.tag:
        diffs.append(f"Tag mismatch at '{node1.path}': '{node1.tag}' vs '{node2.tag}'")
        return

    # 2. Text comparison
    if node1.text != node2.text:
        diffs.append(f"Text mismatch at '{node1.path}': '{node1.text}' != '{node2.text}'")

    # 3. Attribute comparison
    keys1 = set(node1.attrs.keys())
    keys2 = set(node2.attrs.keys())
    all_keys = keys1 | keys2

    for k in sorted(all_keys):
        val1 = node1.attrs.get(k)
        val2 = node2.attrs.get(k)
        if val1 is None:
            diffs.append(f"Missing attribute '{k}' in first XML at '{node1.path}' (expected '{val2}')")
        elif val2 is None:
            diffs.append(f"Unexpected attribute '{k}' in first XML at '{node1.path}' (value '{val1}')")
        elif val1 != val2:
            diffs.append(f"Attribute '{k}' value mismatch at '{node1.path}': '{val1}' != '{val2}'")

    # 4. Children comparison
    # If children have 'Name' attribute, match by Name; otherwise match by index
    named_children1 = {}
    named_children2 = {}
    unnamed1 = []
    unnamed2 = []

    for c in node1.children:
        if c.name:
            named_children1[(c.tag, c.name)] = c
        else:
            unnamed1.append(c)

    for c in node2.children:
        if c.name:
            named_children2[(c.tag, c.name)] = c
        else:
            unnamed2.append(c)

    # Match named children
    all_named_keys = sorted(set(named_children1.keys()) | set(named_children2.keys()))
    for key in all_named_keys:
        c1 = named_children1.get(key)
        c2 = named_children2.get(key)
        if c1 is None:
            diffs.append(f"Missing element '{key[0]}[{key[1]}]' in first XML at '{node1.path}'")
        elif c2 is None:
            diffs.append(f"Unexpected element '{key[0]}[{key[1]}]' in first XML at '{node1.path}'")
        else:
            compare_nodes(c1, c2, diffs)

    # Match unnamed children by position
    max_unnamed = max(len(unnamed1), len(unnamed2))
    for i in range(max_unnamed):
        if i >= len(unnamed1):
            diffs.append(f"Missing unnamed child #{i+1} ('{unnamed2[i].tag}') in first XML at '{node1.path}'")
        elif i >= len(unnamed2):
            diffs.append(f"Unexpected unnamed child #{i+1} ('{unnamed1[i].tag}') in first XML at '{node1.path}'")
        else:
            compare_nodes(unnamed1[i], unnamed2[i], diffs)

def count_statistics(node):
    stats = {"modules": 0, "blocks": 0, "items": 0, "triggers": 0, "canvases": 0, "total_nodes": 1}
    tag = node.tag.lower()
    if "formmodule" in tag or tag == "module":
        stats["modules"] += 1
    elif "block" in tag:
        stats["blocks"] += 1
    elif "item" in tag:
        stats["items"] += 1
    elif "trigger" in tag:
        stats["triggers"] += 1
    elif "canvas" in tag:
        stats["canvases"] += 1

    for child in node.children:
        cstats = count_statistics(child)
        for k in stats:
            stats[k] += cstats[k]
    return stats

def main():
    parser = argparse.ArgumentParser(description="Oracle Forms XML Semantic Normalizer & Comparator")
    parser.add_argument("xml1", help="Path to first Forms XML file")
    parser.add_argument("xml2", help="Path to second Forms XML file")
    parser.add_argument("--canonical-out1", help="Output canonicalized XML1 to file")
    parser.add_argument("--canonical-out2", help="Output canonicalized XML2 to file")
    parser.add_argument("--quiet", "-q", action="store_true", help="Suppress detailed output on match")

    args = parser.parse_args()

    if not os.path.isfile(args.xml1):
        sys.stderr.write(f"❌ Error: File not found: {args.xml1}\n")
        sys.exit(2)
    if not os.path.isfile(args.xml2):
        sys.stderr.write(f"❌ Error: File not found: {args.xml2}\n")
        sys.exit(2)

    try:
        tree1 = ET.parse(args.xml1)
        root1 = tree1.getroot()
    except Exception as e:
        sys.stderr.write(f"❌ Failed to parse XML1 ({args.xml1}): {e}\n")
        sys.exit(2)

    try:
        tree2 = ET.parse(args.xml2)
        root2 = tree2.getroot()
    except Exception as e:
        sys.stderr.write(f"❌ Failed to parse XML2 ({args.xml2}): {e}\n")
        sys.exit(2)

    node1 = FormsXmlNode(root1)
    node2 = FormsXmlNode(root2)

    if args.canonical_out1:
        el1 = node1.to_element()
        ET.indent(el1, space="  ")
        ET.ElementTree(el1).write(args.canonical_out1, encoding="utf-8", xml_declaration=True)

    if args.canonical_out2:
        el2 = node2.to_element()
        ET.indent(el2, space="  ")
        ET.ElementTree(el2).write(args.canonical_out2, encoding="utf-8", xml_declaration=True)

    diffs = []
    compare_nodes(node1, node2, diffs)

    stats1 = count_statistics(node1)
    stats2 = count_statistics(node2)

    if not diffs:
        if not args.quiet:
            print("==================================================================")
            print("✅ FORMS XML SEMANTIC VERIFICATION: 100% MATCH!")
            print("==================================================================")
            print(f"📄 XML 1: {args.xml1}")
            print(f"📄 XML 2: {args.xml2}")
            print(f"📊 Verified Components:")
            print(f"   ├─ Modules:    {stats1['modules']}")
            print(f"   ├─ Blocks:     {stats1['blocks']}")
            print(f"   ├─ Items:      {stats1['items']}")
            print(f"   ├─ Triggers:   {stats1['triggers']}")
            print(f"   ├─ Canvases:   {stats1['canvases']}")
            print(f"   └─ Total Nodes:{stats1['total_nodes']}")
            print("✨ Volatile metadata (DateSaved, CompilerVersion, hashes) successfully filtered.")
            print("==================================================================")
        sys.exit(0)
    else:
        sys.stderr.write("==================================================================\n")
        sys.stderr.write(f"❌ FORMS XML MISMATCH DETECTED ({len(diffs)} difference(s))!\n")
        sys.stderr.write("==================================================================\n")
        sys.stderr.write(f"📄 XML 1: {args.xml1}\n")
        sys.stderr.write(f"📄 XML 2: {args.xml2}\n")
        sys.stderr.write("Differences:\n")
        for i, d in enumerate(diffs[:20], 1):
            sys.stderr.write(f"  {i}. {d}\n")
        if len(diffs) > 20:
            sys.stderr.write(f"  ... and {len(diffs) - 20} more differences.\n")
        sys.stderr.write("==================================================================\n")
        sys.exit(1)

if __name__ == "__main__":
    main()
