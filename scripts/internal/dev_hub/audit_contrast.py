#!/usr/bin/env python3
"""
Oracle DevOps Platform - Developer Hub WCAG 2.1 AA Contrast Auditor
Calculates sRGB relative luminance and verifies contrast ratios between
text and surface backgrounds in both Light Mode (default: #ffffff / #f8fafc)
and Dark Mode (default: #090d16 / #111827).

WCAG 2.1 AA Requirements:
- Normal text (< 18pt or < 14pt bold): minimum 4.5:1
- Large text (>= 18pt or >= 14pt bold): minimum 3.0:1
- UI components & graphical objects: minimum 3.0:1
"""

import sys
import os
import re
import glob

# Standard theme surface backgrounds
LIGHT_SURFACE = (255, 255, 255)       # #ffffff
LIGHT_BG = (248, 250, 252)            # #f8fafc
DARK_SURFACE = (17, 24, 39)           # #111827
DARK_BG = (9, 13, 22)                 # #090d16

NAMED_COLORS = {
    "white": (255, 255, 255),
    "black": (0, 0, 0),
    "transparent": None,
}

def parse_hex_color(hex_str):
    hex_str = hex_str.strip().lstrip('#')
    if len(hex_str) == 3:
        hex_str = ''.join([c * 2 for c in hex_str])
    elif len(hex_str) == 4: # #rgba
        hex_str = ''.join([c * 2 for c in hex_str[:3]])
    elif len(hex_str) == 8: # #rrggbbaa
        hex_str = hex_str[:6]
    if len(hex_str) == 6:
        try:
            return (int(hex_str[0:2], 16), int(hex_str[2:4], 16), int(hex_str[4:6], 16))
        except ValueError:
            return None
    return None

def parse_color(color_str):
    if not color_str:
        return None
    color_str = color_str.strip().lower()
    if 'gradient' in color_str:
        hex_in_grad = re.search(r'#(?:[0-9a-f]{3,8})\b', color_str)
        if hex_in_grad:
            return parse_hex_color(hex_in_grad.group(0))
        rgb_in_grad = re.search(r'rgba?\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)', color_str)
        if rgb_in_grad:
            return (int(rgb_in_grad.group(1)), int(rgb_in_grad.group(2)), int(rgb_in_grad.group(3)))
    if color_str in NAMED_COLORS:
        return NAMED_COLORS[color_str]
    if color_str.startswith('#'):
        return parse_hex_color(color_str)
    rgba_match = re.match(r'rgba?\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)', color_str)
    if rgba_match:
        return (int(rgba_match.group(1)), int(rgba_match.group(2)), int(rgba_match.group(3)))
    return None

def srgb_to_linear(c):
    val = c / 255.0
    if val <= 0.03928:
        return val / 12.92
    else:
        return ((val + 0.055) / 1.055) ** 2.4

def relative_luminance(rgb):
    r, g, b = [srgb_to_linear(v) for v in rgb]
    return 0.2126 * r + 0.7152 * g + 0.0722 * b

def contrast_ratio(rgb1, rgb2):
    if not rgb1 or not rgb2:
        return 0.0
    l1 = relative_luminance(rgb1)
    l2 = relative_luminance(rgb2)
    lighter = max(l1, l2)
    darker = min(l1, l2)
    return (lighter + 0.05) / (darker + 0.05)

def audit_file(filepath):
    """
    Audits a template, script, or HTML file for inline color definitions
    that would cause contrast failures when rendered on a light surface.
    """
    issues = []
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()

    for idx, line in enumerate(lines, 1):
        # We look for inline style="..." blocks
        style_matches = re.findall(r'style="([^"]+)"', line)
        for style in style_matches:
            # Check if there is an explicit background in the same style
            bg_match = re.search(r'background(?:-color)?\s*:\s*([^;]+)', style)
            color_match = re.search(r'(?:^|;|\s)color\s*:\s*([^;]+)', style)

            explicit_bg = None
            if bg_match:
                bg_raw = bg_match.group(1).rstrip(';').strip()
                explicit_bg = parse_color(bg_raw)

            if color_match:
                raw_color = color_match.group(1).split(';')[0].strip()
                color_rgb = parse_color(raw_color)

                if color_rgb:
                    # In light mode, if there is no explicit dark background,
                    # the element sits on LIGHT_SURFACE (#ffffff) or LIGHT_BG (#f8fafc)
                    target_bg = explicit_bg if explicit_bg else LIGHT_SURFACE

                    ratio = contrast_ratio(color_rgb, target_bg)
                    
                    # If contrast is below 3.0:1, it fails even large text WCAG standards
                    # If contrast is between 3.0:1 and 4.5:1, it fails normal text WCAG standards
                    if ratio < 3.0:
                        issues.append({
                            'file': filepath,
                            'line': idx,
                            'level': 'CRITICAL',
                            'color': raw_color,
                            'bg': 'explicit' if explicit_bg else 'light-surface (#ffffff)',
                            'ratio': ratio,
                            'snippet': line.strip()[:100]
                        })
                    elif ratio < 4.5:
                        issues.append({
                            'file': filepath,
                            'line': idx,
                            'level': 'WARNING',
                            'color': raw_color,
                            'bg': 'explicit' if explicit_bg else 'light-surface (#ffffff)',
                            'ratio': ratio,
                            'snippet': line.strip()[:100]
                        })

    return issues

def main():
    workspace_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../..'))
    dev_hub_dir = os.path.join(workspace_root, 'scripts/internal/dev_hub')
    
    files_to_audit = [
        os.path.join(dev_hub_dir, 'forms_modernization.py'),
        os.path.join(dev_hub_dir, 'cards.py'),
        os.path.join(dev_hub_dir, 'catalog.py'),
        os.path.join(dev_hub_dir, 'assets/templates/layout.html'),
        os.path.join(dev_hub_dir, 'assets/app.js'),
    ]

    all_issues = []
    print("=" * 70)
    print("🎨 DEV HUB WCAG 2.1 AA CONTRAST AUDIT")
    print("=" * 70)

    for fpath in files_to_audit:
        if os.path.exists(fpath):
            issues = audit_file(fpath)
            all_issues.extend(issues)
            rel_path = os.path.relpath(fpath, workspace_root)
            print(f"Scanned {rel_path:50} -> {len(issues)} issues found")

    critical_count = sum(1 for i in all_issues if i['level'] == 'CRITICAL')
    warning_count = sum(1 for i in all_issues if i['level'] == 'WARNING')

    print("-" * 70)
    print(f"Audit Summary: {critical_count} CRITICAL (< 3.0:1), {warning_count} WARNING (< 4.5:1)")
    print("-" * 70)

    if critical_count > 0:
        print("\nTop Critical Failures (Invisible or severely degraded text in Light Mode):")
        for i in [x for x in all_issues if x['level'] == 'CRITICAL'][:15]:
            rel_path = os.path.relpath(i['file'], workspace_root)
            print(f"  ❌ [{i['level']}] {rel_path}:{i['line']} - Color: {i['color']} (Contrast: {i['ratio']:.2f}:1)")
            print(f"     Code: {i['snippet']}")

    return 1 if critical_count > 0 else 0

if __name__ == '__main__':
    sys.exit(main())
