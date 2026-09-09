#!/usr/bin/env bash
# ==============================================================================
# Unit Test: Dev-Hub Interactive Mermaid Diagram Rendering Engine
# Validates marked-to-mermaid transformation, toolbars, zoom modal, and 6-language i18n
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🔍 Validating Dev-Hub Mermaid Diagram Rendering Architecture..."

# 1. Check style.css definitions
echo "  [1/6] Checking style.css diagram components..."
CSS_FILE="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/style.css"
for rule in ".mermaid-diagram-card" ".mermaid-toolbar" ".mermaid-render-target" ".mermaid-raw-code" "#mermaid-zoom-modal"; do
  if ! grep -q "$rule" "$CSS_FILE"; then
    echo "❌ Missing CSS rule in style.css: $rule"
    exit 1
  fi
done
if ! grep -q "line-height: 1.25 !important" "$CSS_FILE"; then
  echo "❌ Missing line-height containment rule in style.css (line-height: 1.25 !important)"
  exit 1
fi
echo "     ✅ All Mermaid CSS classes, modal styles, and line-height containment rules present."

# 2. Check layout.html modal and blueprint toolbar
echo "  [2/6] Checking layout.html blueprint toolbar and zoom modal..."
LAYOUT_FILE="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/templates/layout.html"
for elem in "id=\"bp-modal-mermaid\"" "toggleBlueprintMermaidCode" "copyBlueprintMermaidCode" "openBlueprintMermaidZoom" "id=\"mermaid-zoom-modal\""; do
  if ! grep -q "$elem" "$LAYOUT_FILE"; then
    echo "❌ Missing element in layout.html: $elem"
    exit 1
  fi
done
echo "     ✅ Blueprint topology toolbar and zoom modal markup present."

# 3. Check i18n.js 6-language parity
echo "  [3/6] Checking 6-language parity in i18n.js for Mermaid keys..."
I18N_FILE="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/i18n.js"

python3 -c "
import re, sys

with open('$I18N_FILE', 'r', encoding='utf-8') as f:
    code = f.read()

languages = ['en', 'et', 'fi', 'sv', 'lv', 'lt']
keys = ['mermaid_diag_title', 'mermaid_toggle_code', 'mermaid_hide_code', 'mermaid_copy_code', 'mermaid_copied', 'mermaid_zoom', 'mermaid_zoom_title', 'mermaid_offline_msg', 'mermaid_err_msg']

for lang in languages:
    m = re.search(r'\b' + lang + r'\s*:\s*\{([^}]+)\}', code)
    if not m:
        print(f'❌ Missing language block: {lang}', file=sys.stderr)
        sys.exit(1)
    block = m.group(1)
    for k in keys:
        if k not in block:
            print(f'❌ Missing key {k} in language {lang}', file=sys.stderr)
            sys.exit(1)

print('     ✅ All 9 Mermaid keys verified across all 6 languages.')
"

# 4. Check app.js functions and wiring
echo "  [4/6] Checking JavaScript engine and wiring in app.js..."
APP_JS="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/app.js"
for fn in "initMermaidGlobal" "cleanupStrayMermaidElements" "renderMermaidInContainer" "toggleMermaidCardCode" "copyMermaidCardCode" "openMermaidZoomModal" "closeMermaidZoomModal"; do
  if ! grep -q "$fn" "$APP_JS"; then
    echo "❌ Missing function in app.js: $fn"
    exit 1
  fi
done

if ! grep -q "renderMermaidInContainer(bodyEl)" "$APP_JS"; then
  echo "❌ renderMermaidInContainer(bodyEl) not called in app.js"
  exit 1
fi
echo "     ✅ JavaScript functions, error cleanup handler, and render call sites verified."

# 5. Check JS syntax validity
echo "  [5/6] Validating JS syntax with node --check..."
node --check "$APP_JS"
node --check "$I18N_FILE"
echo "     ✅ JavaScript syntax is 100% valid."

# 6. Recompile Dev-Hub HTML and check generated output
echo "  [6/6] Generating and validating standalone docs/dev-hub.html..."
"$WORKSPACE_DIR/scripts/internal/generate-dev-hub.sh" "$WORKSPACE_DIR/docs/dev-hub.html" >/dev/null

if ! grep -q "mermaid-diagram-card" "$WORKSPACE_DIR/docs/dev-hub.html"; then
  echo "❌ Compiled dev-hub.html does not contain mermaid-diagram-card styles!"
  exit 1
fi
if ! grep -q "id=\"mermaid-zoom-modal\"" "$WORKSPACE_DIR/docs/dev-hub.html"; then
  echo "❌ Compiled dev-hub.html does not contain mermaid-zoom-modal!"
  exit 1
fi
echo "     ✅ Compiled dev-hub.html contains all required modal and card components."

# 7. Check layout.html tag balance and Markdown diagram syntax
echo "  [7/7] Validating DOM tag balance and Markdown diagram syntax..."
LAYOUT_FILE="$LAYOUT_FILE" WORKSPACE_DIR="$WORKSPACE_DIR" python3 << 'PY_EOF'
import sys, re, glob, os

layout_file = os.environ["LAYOUT_FILE"]
workspace_dir = os.environ["WORKSPACE_DIR"]

with open(layout_file, "r", encoding="utf-8") as f:
    lines = f.readlines()

# Check layout tag balancing
stack = []
for idx, line in enumerate(lines, 1):
    clean_line = re.sub(r'"[^"]*"|\'[^\']*\'', '""', line)
    tokens = re.finditer(r'<(\/)?([a-zA-Z0-9]+)\b([^>]*?)(\/)?>', clean_line)
    for t in tokens:
        is_close = bool(t.group(1))
        tag = t.group(2).lower()
        attrs = t.group(3)
        is_self = bool(t.group(4)) or tag in ["img", "br", "hr", "input", "meta", "link"]
        if is_self:
            continue
        if is_close:
            if stack and stack[-1][0] == tag:
                stack.pop()
            else:
                print(f"❌ layout.html line {idx}: close </{tag}> does not match stack top", file=sys.stderr)
                sys.exit(1)
        else:
            stack.append((tag, idx))

if stack:
    print(f"❌ layout.html has {len(stack)} unclosed tags: {stack}", file=sys.stderr)
    sys.exit(1)

# Check that layout has no empty elements with class="mermaid" (prevents auto-render trap)
layout_text = "".join(lines)
if re.search(r'<[a-zA-Z0-9]+\b[^>]*\bclass=["\'][^"\']*(?<![\w-])mermaid(?![\w-])[^"\']*["\'][^>]*>', layout_text):
    print('❌ layout.html contains element with class="mermaid", which triggers auto-render traps!', file=sys.stderr)
    sys.exit(1)

# Check all Markdown mermaid blocks for invalid subgraphs, unquoted diamonds, and subgraph-to-subgraph arrows
md_files = glob.glob(os.path.join(workspace_dir, "**/*.md"), recursive=True)
errs = 0
for path in md_files:
    if any(x in path for x in ["node_modules", ".git", "install_logs", ".gemini", "scratch"]):
        continue
    with open(path, "r", encoding="utf-8", errors="ignore") as f:
        c = f.read()
    blocks = re.findall(r'```mermaid\s*\n(.*?)```', c, re.DOTALL)
    for b_idx, block in enumerate(blocks, 1):
        for l_num, b_line in enumerate(block.strip().splitlines(), 1):
            sl = b_line.strip()
            # Subgraph name validation
            if sl.startswith("subgraph"):
                rest = sl[len("subgraph"):].strip()
                if not rest or not (rest.startswith('"') or rest.startswith('["') or re.match(r'^[a-zA-Z0-9_]+\s*(\[.*\])?$', rest)):
                    print(f"❌ {path} Block {b_idx} L{l_num}: Invalid subgraph syntax: {sl}", file=sys.stderr)
                    errs += 1
            # Unquoted diamonds starting with numbers or colons
            m_diam = re.search(r'(\b\w+)\{([^\"\'\n\}]+)\}', sl)
            if m_diam:
                nid, dtext = m_diam.group(1), m_diam.group(2)
                if re.match(r'^\s*\d', dtext) or any(char in dtext for char in [':', '(', ')']):
                    print(f"❌ {path} Block {b_idx} L{l_num}: Unquoted diamond syntax in {nid}{{{dtext[:30]}}} (must be quoted)", file=sys.stderr)
                    errs += 1
            # Subgraph-to-subgraph link prevention
            if '-->' in sl and not any(bracket in sl for bracket in ['[', '(', '{', '"', "'"]):
                parts = [p.strip() for p in sl.split('-->')]
                if any(p in ['Default', 'DatabaseStacks', 'Middleware', 'DeveloperStudio', 'RemoteGateways'] for p in parts):
                    print(f"❌ {path} Block {b_idx} L{l_num}: Subgraph-to-subgraph arrow detected: {sl}", file=sys.stderr)
                    errs += 1

            # Multi-line Decision Diamond Line Length Check (Rule 10 & mermaid_diagram_design skill)
            for m in re.finditer(r'(\b\w+)\s*\{[\"\'\s]*([^}\"\'\n]+)[\"\'\s]*\}', sl):
                nid, text = m.group(1), m.group(2)
                segments = re.split(r'<br\s*/?>', text, flags=re.IGNORECASE)
                for seg in segments:
                    clean = seg.strip().strip("\"'").strip()
                    if len(clean) > 28:
                        print(f"❌ {path} Block {b_idx} L{l_num}: Decision diamond [{nid}] line exceeds 28 chars ({len(clean)} chars): '{clean}' (must break into multiple lines with <br/>)", file=sys.stderr)
                        errs += 1

            # Process Box Line Length Check (Rule 10 & mermaid_diagram_design skill: max 48 chars per line segment)
            for m in re.finditer(r'(\b\w+)\s*\[[\"\'\s]*([^\]\"\'\n]+)[\"\'\s]*\]', sl):
                nid, text = m.group(1), m.group(2)
                segments = re.split(r'<br\s*/?>', text, flags=re.IGNORECASE)
                for seg in segments:
                    clean = seg.strip().strip("\"'").strip()
                    if len(clean) > 48:
                        print(f"❌ {path} Block {b_idx} L{l_num}: Process box [{nid}] line exceeds 48 chars ({len(clean)} chars): '{clean}' (must break into multiple lines with <br/>)", file=sys.stderr)
                        errs += 1

            # Vertical Node Density Check (Rule 10 & mermaid_diagram_design skill: max 4 lines per node)
            for m in re.finditer(r'(\b\w+)\s*(\[|\(|\{\[|\(\[|\[\()[\"\'\s]*([^\]\)\"\'\n]+)[\"\'\s]*(\]|\)|\)\]|\]\))', sl):
                nid, text = m.group(1), m.group(3)
                segments = re.split(r'<br\s*/?>', text, flags=re.IGNORECASE)
                if len(segments) > 4:
                    print(f"❌ {path} Block {b_idx} L{l_num}: Node [{nid}] has {len(segments)} lines (exceeds max 4 lines per box): '{text[:50]}...' (must condense to 2–4 lines)", file=sys.stderr)
                    errs += 1

        # Horizontal Subgraph Fan-out & Layout Sprawl Check (Rule 10 & mermaid_diagram_design skill)
        sg_stack = []
        node_to_sg = {}
        for b_line in block.strip().splitlines():
            sl = b_line.strip()
            if sl.startswith("subgraph"):
                m = re.match(r'subgraph\s+([a-zA-Z0-9_]+)', sl)
                sg_id = m.group(1) if m else sl
                sg_stack.append(sg_id)
            elif sl == "end" and sg_stack:
                sg_stack.pop()
            elif sg_stack:
                cur_sg = sg_stack[-1]
                m_node = re.match(r'^([a-zA-Z0-9_]+)\s*(\[|\(|\{)', sl)
                if m_node:
                    node_to_sg[m_node.group(1)] = cur_sg

        node_out_sgs = {}
        for b_line in block.strip().splitlines():
            sl = b_line.strip()
            if '-->' in sl:
                parts = [p.strip() for p in sl.split('-->')]
                if len(parts) == 2:
                    src = re.sub(r'\[.*\]|\(.*\)|{.*}', '', parts[0]).strip()
                    tgt = re.sub(r'\[.*\]|\(.*\)|{.*}', '', parts[1]).strip()
                    tgt = re.sub(r'^\|[^\|]+\|\s*', '', tgt).strip()
                    if src and tgt and (src in node_to_sg or tgt in node_to_sg):
                        tgt_sg = node_to_sg.get(tgt)
                        if tgt_sg:
                            node_out_sgs.setdefault(src, set()).add(tgt_sg)

        for src, sgs in node_out_sgs.items():
            if len(sgs) > 3:
                print(f"❌ {path} Block {b_idx}: Node [{src}] links directly to {len(sgs)} distinct subgraphs ({sorted(list(sgs))}), causing horizontal layout sprawl (exceeds max 3 subgraphs per row)", file=sys.stderr)
                errs += 1

if errs > 0:
    print(f"❌ Total Mermaid syntax/formatting errors: {errs}", file=sys.stderr)
    sys.exit(1)

print("     ✅ DOM tag balance and Markdown Mermaid syntax 100% verified.")
PY_EOF

echo "✅ All Dev-Hub Mermaid diagram rendering validations passed successfully!"
