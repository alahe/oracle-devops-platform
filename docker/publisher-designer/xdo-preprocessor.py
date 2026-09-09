#!/usr/bin/env python3
"""
Lightweight Oracle XDO RTF + XML Preprocessor with Multi-Language XLIFF Support
Merges XML data into an RTF template (substituting fields, evaluating conditions,
expanding for-each loops, applying XLIFF translation maps, and formatting numbers/dates)
so that headless LibreOffice or PDF printers produce a fully-populated, authentic document.
"""

import sys
import os
import re
import argparse
import xml.etree.ElementTree as ET


def to_rtf_escaped(text):
    """Encodes unicode string to RTF-safe character sequence."""
    out = []
    for ch in text:
        cp = ord(ch)
        if cp < 128:
            if ch in ('\\', '{', '}'):
                out.append('\\' + ch)
            else:
                out.append(ch)
        elif cp <= 255:
            out.append(f"\\'{cp:02x}")
        else:
            signed = cp if cp < 32768 else cp - 65536
            out.append(f"\\u{signed}?")
    return "".join(out)


def format_number(val_str, fmt="#,##0.00", locale="et"):
    try:
        clean = re.sub(r'[^\d.-]', '', val_str)
        val = float(clean)
        if locale.lower().startswith('en'):
            return f"{val:,.2f}"
        else:
            # Nordic-Baltic style: space thousand separator, comma decimal
            formatted = f"{val:,.2f}"
            return formatted.replace(',', ' ').replace('.', ',')
    except Exception:
        return val_str


def build_xml_dict(element, prefix=""):
    """Recursively builds flat and nested dict of XML elements."""
    data = {}
    for child in element:
        path = f"{prefix}/{child.tag}" if prefix else child.tag
        if len(list(child)) == 0:
            val = (child.text or "").strip()
            data[path] = val
            data[child.tag] = val
        else:
            data.update(build_xml_dict(child, path))
    return data


def eval_condition(cond_str, context_data):
    """Evaluates simple conditions like 'DISCOUNT_PCT > 0'."""
    cond = cond_str.strip()
    m = re.match(r'([A-Za-z0-9_/-]+)\s*(>|<|>=|<=|==|!=|=)\s*(.+)', cond)
    if not m:
        val = context_data.get(cond, "")
        return bool(val and val != "0")

    field, op, target = m.group(1), m.group(2), m.group(3).strip().strip("'\"")
    val = context_data.get(field, context_data.get(field.split('/')[-1], ""))

    try:
        f_val = float(val) if val else 0.0
        f_target = float(target)
        if op == '>': return f_val > f_target
        if op == '<': return f_val < f_target
        if op == '>=': return f_val >= f_target
        if op == '<=': return f_val <= f_target
        if op in ('==', '='): return f_val == f_target
        if op == '!=': return f_val != f_target
    except ValueError:
        if op in ('==', '='): return str(val) == target
        if op == '!=': return str(val) != target

    return True


def load_xliff_translations(xlf_path):
    """Parses XLIFF (.xlf) file into a dict of {source_string: target_string}."""
    if not xlf_path or not os.path.exists(xlf_path):
        return {}
    try:
        tree = ET.parse(xlf_path)
        root = tree.getroot()
        ns = {'xlf': 'urn:oasis:names:tc:xliff:document:1.1'}
        # Support both namespaced and non-namespaced XLIFF
        units = root.findall('.//xlf:trans-unit', ns) or root.findall('.//trans-unit')
        translations = {}
        for unit in units:
            src_node = unit.find('xlf:source', ns) if unit.find('xlf:source', ns) is not None else unit.find('source')
            tgt_node = unit.find('xlf:target', ns) if unit.find('xlf:target', ns) is not None else unit.find('target')
            if src_node is not None and tgt_node is not None:
                src_txt = src_node.text or ""
                tgt_txt = tgt_node.text or ""
                if src_txt and tgt_txt:
                    translations[src_txt] = tgt_txt
        return translations
    except Exception as e:
        print(f"Warning: Could not parse XLIFF file {xlf_path}: {e}", file=sys.stderr)
        return {}


def apply_xliff(rtf_text, translations):
    """Replaces source strings in RTF with translated target strings."""
    for src, tgt in translations.items():
        # Match both literal text and RTF escaped text
        src_escaped = to_rtf_escaped(src)
        tgt_escaped = to_rtf_escaped(tgt)

        if src_escaped in rtf_text:
            rtf_text = rtf_text.replace(src_escaped, tgt_escaped)
        elif src in rtf_text:
            rtf_text = rtf_text.replace(src, tgt_escaped)
    return rtf_text


def replace_fields(text, data_dict, locale="et"):
    # format-number(TAG, 'FMT')
    def fmt_num(m):
        fld = m.group(1).strip()
        fmt = m.group(2).strip()
        val = data_dict.get(fld, data_dict.get(fld.split('/')[-1], '0.00'))
        return format_number(val, fmt, locale)

    text = re.sub(r'<\?format-number\(\s*([A-Za-z0-9_/-]+)\s*,\s*[\'"]([^\'"]+)[\'"]\s*\)\?>', fmt_num, text)

    # format-date(TAG, 'FMT')
    def fmt_date(m):
        fld = m.group(1).strip()
        val = data_dict.get(fld, data_dict.get(fld.split('/')[-1], ''))
        return val

    text = re.sub(r'<\?format-date\(\s*([A-Za-z0-9_/-]+)\s*,\s*[\'"]([^\'"]+)[\'"]\s*\)\?>', fmt_date, text)

    # Simple field <?TAG?> or <?PATH/TAG?>
    def repl_tag(m):
        raw = m.group(1).strip()
        if raw.startswith('for-each') or raw.startswith('if') or raw.startswith('end'):
            return m.group(0)
        val = data_dict.get(raw, data_dict.get(raw.split('/')[-1], ''))
        return val

    text = re.sub(r'<\?([A-Za-z0-9_/-]+)\?>', repl_tag, text)
    return text


def render_xdo_to_rtf(xml_path, rtf_path, out_rtf_path, locale="et", xlf_path=None):
    tree = ET.parse(xml_path)
    root = tree.getroot()

    global_data = build_xml_dict(root)

    with open(rtf_path, 'r', encoding='latin1') as f:
        rtf = f.read()

    # 1. Expand <?for-each:GROUP?>...<?end for-each?>
    def expand_for_each(match):
        group_path = match.group(1).strip()
        body_template = match.group(2)

        xpath = group_path.replace('/', './')
        nodes = root.findall(f".//{group_path.split('/')[-1]}")
        if not nodes:
            nodes = root.findall(f"./{xpath}")

        expanded_parts = []
        for i, node in enumerate(nodes, 1):
            row_data = build_xml_dict(node)
            row_data['LINE_NUM'] = str(i)
            combined = {**global_data, **row_data}

            row_rtf = body_template
            row_rtf = replace_fields(row_rtf, combined, locale)
            expanded_parts.append(row_rtf)

        return "".join(expanded_parts)

    rtf = re.sub(
        r'<\?for-each:([^?]+)\?>(.*?)<\?end for-each\?>',
        expand_for_each,
        rtf,
        flags=re.DOTALL
    )

    # 2. Evaluate <?if:COND?>...<?end if?>
    def eval_if(match):
        cond = match.group(1).strip()
        body = match.group(2)
        if eval_condition(cond, global_data):
            return body
        return ""

    rtf = re.sub(
        r'<\?if:([^?]+)\?>(.*?)<\?end if\?>',
        eval_if,
        rtf,
        flags=re.DOTALL
    )

    # 3. Replace all remaining fields in global scope
    rtf = replace_fields(rtf, global_data, locale)

    # 4. Clean up any remaining unhandled XDO tags
    rtf = re.sub(r'<\?[^?]*\?>', '', rtf)

    # 5. Apply XLIFF translations if available
    resolved_xlf = xlf_path
    if not resolved_xlf:
        # Search relative to RTF path
        rtf_dir = os.path.dirname(os.path.abspath(rtf_path))
        base = os.path.splitext(os.path.basename(rtf_path))[0]
        lang_code = locale[:2].lower()
        candidates = [
            os.path.join(rtf_dir, f"{base}_{lang_code}.xlf"),
            os.path.join(rtf_dir, f"{base}_{locale}.xlf")
        ]
        for c in candidates:
            if os.path.exists(c):
                resolved_xlf = c
                break

    if resolved_xlf and os.path.exists(resolved_xlf):
        translations = load_xliff_translations(resolved_xlf)
        if translations:
            rtf = apply_xliff(rtf, translations)

    with open(out_rtf_path, 'w', encoding='latin1') as f:
        f.write(rtf)

    return out_rtf_path


def main():
    parser = argparse.ArgumentParser(description="Oracle XDO RTF + XML Multi-Language Preprocessor")
    parser.add_argument("xml_file", help="Path to input XML data file")
    parser.add_argument("rtf_file", help="Path to input RTF template file")
    parser.add_argument("out_rtf_file", help="Path to output rendered RTF file")
    parser.add_argument("--locale", "-l", default="et", help="Target locale code (et, en, fi, sv, lv, lt)")
    parser.add_argument("--xlf", "-x", default=None, help="Explicit path to XLIFF (.xlf) translation file")

    args = parser.parse_args()

    render_xdo_to_rtf(args.xml_file, args.rtf_file, args.out_rtf_file, locale=args.locale, xlf_path=args.xlf)
    print(f"✅ Preprocessed populated RTF saved to: {args.out_rtf_file} (Locale: {args.locale})")


if __name__ == '__main__':
    main()
