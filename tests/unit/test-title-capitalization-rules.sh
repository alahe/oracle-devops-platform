#!/usr/bin/env bash
# ==============================================================================
# Unit Test: Language Title Capitalization Rules Auditor
# Validates:
#  1. 🇬🇧 English: Strict Title Case (all principal words capitalized; minor words
#     like 'a', 'an', 'the', 'and', 'but', 'or', 'for', 'nor', 'on', 'at', 'to',
#     'from', 'by', 'with', 'in', 'of', 'over', '&' lowercase unless first/last).
#  2. 🇪🇪 ET, 🇫🇮 FI, 🇸🇪 SV, 🇱🇻 LV, 🇱🇹 LT: Strict Sentence case (only initial
#     word capitalized, plus approved proper nouns, products, and technical acronyms:
#     Oracle, Free, APEX, ORDS, SQLcl, SEPS, Wallet, Web IDE, CI/CD, GitHub, Podman,
#     Linux, macOS, Windows, WSL2, REST, SSL, TLS, TDE, API, DB, PDB, HA, FMW, Forms,
#     Publisher, DevHub, ADB, ATP, ADW, OCI, Liquibase, Java, Nginx, Pixel-Perfect,
#     Setup-All, ALISE, Artifactory, Analytics, KKK, UKK, FAQ, BUJ, DUK, etc.).
# Audits:
#  - Dev Hub catalog DOC_SPECS titles (21 docs x 6 languages = 126 titles)
#  - Dev Hub catalog BP_CATALOG titles (12 blueprints x 6 languages = 72 titles)
#  - Catalog documentation file H1 headings (126 views)
#  - All repository localized markdown files in docs/{et,fi,sv,lv,lt}/*.md
#  - Canonical root and architecture blueprints README headings
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🔍 Validating Language Title Capitalization Rules (EN Title Case / ET,FI,SV,LV,LT Sentence Case)..."

WORKSPACE_DIR="$WORKSPACE_DIR" python3 - << 'EOF'
import sys, os, glob, re

WORKSPACE = os.environ.get('WORKSPACE_DIR', os.getcwd())
sys.path.insert(0, WORKSPACE)

try:
    from scripts.internal.dev_hub.catalog import DOC_SPECS, BP_CATALOG
except ImportError as e:
    print(f'❌ Failed to import catalog: {e}', file=sys.stderr)
    sys.exit(1)

ALLOWLIST = {
    'ORACLE', 'FREE', 'APEX', 'ORDS', 'SQLCL', 'SEPS', 'WALLET', 'WEB', 'IDE', 'CI/CD',
    'GITHUB', 'PODMAN', 'LINUX', 'MACOS', 'WINDOWS', 'WSL2', 'REST', 'SSL', 'TLS',
    'TDE', 'API', 'DB', 'PDB', 'HA', 'FMW', 'FORMS', 'PUBLISHER', 'DEV', 'HUB',
    'DEVHUB', 'ADB', 'ATP', 'ADW', 'OCI', 'LIQUIBASE', 'JAVA', 'NGINX', 'PIXEL-PERFECT',
    'SETUP-ALL', 'ALISE', 'MS', 'WORD', 'KKK', 'UKK', 'FAQ', 'BUJ', 'DUK', 'RCU',
    'E2E', 'VNC', 'NOVNC', 'GVENZL', 'DOCKER', 'ZSCALER', 'INTUNE', 'GPO', 'VPN',
    'DNS', 'FASTSTART', 'DEVOPS', 'DESKTOP', 'DESIGNER', 'GATEWAY', 'PROXY',
    'AUTONOMOUS', 'DATABASE', 'CLOUD', 'COMMUNITY', 'ENTERPRISE', 'EDGE', 'SERVER',
    'BLUEPRINTS', 'BLUEPRINT', 'GOLDEN', 'SNAPSHOTS', 'REPORTS', 'REPORT', 'WORKFLOW',
    'KAFKA', 'SSO', 'ENTRA', 'ID', 'AZURE', 'ARTIFACTORY', 'ANALYTICS', 'JIRA',
    'WEBLOGIC', 'CODE', 'PKI', 'CA'
}

MINOR_EN_WORDS = {'a', 'an', 'the', 'and', 'but', 'or', 'for', 'nor', 'on', 'at', 'to', 'from', 'by', 'with', 'in', 'of', 'over', '&'}

def clean_word(w):
    return re.sub(r'^[^\w]+|[^\w]+$', '', w)

def is_version_or_code(w):
    return bool(re.match(r'^\d+[a-z]+$', w, re.I)) or w.endswith('.sh') or w.endswith('.py') or w.endswith('.md')

def strip_technical_annotations(title):
    # Strip trailing parenthesized paths e.g. (`scripts/forms/`) or (`docker/forms/`)
    t = re.sub(r'\s*\(`[^`]+`\)\s*$', '', title)
    t = re.sub(r'\s*\([a-zA-Z0-9_\-\.\/]+\/.*?\)\s*$', '', t)
    return t.strip()

def check_title_en(title):
    clean_t = strip_technical_annotations(title)
    words = re.findall(r'[A-Za-z0-9\-\.\'\&]+', clean_t)
    if not words:
        return True, []
    errors = []
    for i, w in enumerate(words):
        cw = clean_word(w)
        if not cw or cw.isdigit():
            continue
        if is_version_or_code(cw):
            continue
        if cw.lower() in [x.lower() for x in ALLOWLIST]:
            continue
        alpha_match = re.search(r'[A-Za-z]', cw)
        if not alpha_match:
            continue
        ch = alpha_match.group(0)
        if i == 0 or i == len(words) - 1:
            if not ch.isupper():
                errors.append(f'First/last word \"{cw}\" must be capitalized')
        else:
            if cw.lower() in MINOR_EN_WORDS:
                continue
            if not ch.isupper():
                errors.append(f'Word \"{cw}\" must be capitalized (Title Case)')
    return len(errors) == 0, errors

def check_title_non_en(title, lang):
    clean_t = strip_technical_annotations(title)
    clean_t = re.sub(r'`[^`]+`', '', clean_t)
    words = re.findall(r'[^\s()\[\]\"\'\:\,\.\/\&]+', clean_t)
    alpha_words = [w for w in words if re.search(r'\w', w)]
    if not alpha_words:
        return True, []
    errors = []
    for w in alpha_words[1:]:
        cw = clean_word(w)
        if not cw or cw.isdigit() or len(cw) <= 1:
            continue
        if is_version_or_code(cw):
            continue
        if '-' in cw:
            parts = cw.split('-')
            for p in parts[1:]:
                if p and p[0].isupper() and p.upper() not in ALLOWLIST and not p.isupper():
                    errors.append(f'Hyphenated part \"{p}\" in \"{cw}\" must be lowercase in {lang}')
            continue
        if cw[0].isupper():
            if cw.upper() not in ALLOWLIST and not cw.isupper():
                errors.append(f'Word \"{cw}\" must be lowercase in {lang} sentence case')
    return len(errors) == 0, errors

def detect_file_lang(rel_path):
    for l in ['et', 'fi', 'sv', 'lv', 'lt']:
        if rel_path.startswith(f'docs/{l}/') or rel_path.endswith(f'.{l}.md'):
            return l
    return 'en'

def find_h1(filepath):
    full_path = os.path.join(WORKSPACE, filepath)
    if not os.path.exists(full_path):
        return None
    with open(full_path, 'r', encoding='utf-8', errors='ignore') as f:
        for line in f:
            line_str = line.strip()
            if line_str.startswith('# '):
                return line_str[2:].strip()
    return None

errors = []

# Phase 1: Dev Hub DOC_SPECS titles
print('  [1/5] Checking Dev Hub DOC_SPECS titles (21 docs x 6 langs = 126 titles)...')
for doc in DOC_SPECS:
    doc_id = doc['id']
    for lang, title in doc['titles'].items():
        if lang == 'en':
            ok, errs = check_title_en(title)
        else:
            ok, errs = check_title_non_en(title, lang)
        if not ok:
            errors.append(f'DOC_SPECS \"{doc_id}\" [{lang}]: \"{title}\" -> {errs}')

# Phase 2: Dev Hub BP_CATALOG titles
print('  [2/5] Checking Dev Hub BP_CATALOG blueprint titles (12 models x 6 langs = 72 titles)...')
for bp_id, bp in BP_CATALOG.items():
    for lang in ['en', 'et', 'fi', 'sv', 'lv', 'lt']:
        if lang in bp:
            title = bp[lang][0]
            if lang == 'en':
                ok, errs = check_title_en(title)
            else:
                ok, errs = check_title_non_en(title, lang)
            if not ok:
                errors.append(f'BP_CATALOG BP {bp_id} [{lang}]: \"{title}\" -> {errs}')

# Phase 3: Catalog Markdown Headings
print('  [3/5] Checking catalog documentation files H1 headings (126 views)...')
for doc in DOC_SPECS:
    doc_id = doc['id']
    for lang, rel_file in doc.get('files', {}).items():
        h1 = find_h1(rel_file)
        if not h1:
            errors.append(f'Missing H1 heading in file: {rel_file}')
            continue
        file_lang = detect_file_lang(rel_file)
        if file_lang == 'en':
            ok, errs = check_title_en(h1)
        else:
            ok, errs = check_title_non_en(h1, file_lang)
        if not ok:
            errors.append(f'H1 heading in {rel_file} [{file_lang}]: \"{h1}\" -> {errs}')

# Phase 4: Localized Repository Markdown Files
print('  [4/5] Checking localized markdown documentation files across repository (*.{et,fi,sv,lv,lt}.md & docs/*/*.md)...')
for l in ['et', 'fi', 'sv', 'lv', 'lt']:
    patterns = [
        os.path.join(WORKSPACE, f'docs/{l}/*.md'),
        os.path.join(WORKSPACE, f'**/*.{l}.md')
    ]
    seen = set()
    for pat in patterns:
        for abs_p in sorted(glob.glob(pat, recursive=True)):
            rel_p = os.path.relpath(abs_p, WORKSPACE)
            if rel_p in seen or rel_p.startswith('.agents/') or rel_p.startswith('.git/'):
                continue
            seen.add(rel_p)
            h1 = find_h1(rel_p)
            if h1:
                ok, errs = check_title_non_en(h1, l)
                if not ok:
                    errors.append(f'H1 heading in {rel_p} [{l}]: \"{h1}\" -> {errs}')

# Phase 5: Canonical Root and Subfolder README Headings
print('  [5/5] Checking canonical English README.md files across repository...')
for abs_p in sorted(glob.glob(os.path.join(WORKSPACE, '**/README.md'), recursive=True)):
    rel_p = os.path.relpath(abs_p, WORKSPACE)
    if rel_p.startswith('.agents/') or rel_p.startswith('.git/') or '/et/' in rel_p or '/fi/' in rel_p or '/sv/' in rel_p or '/lv/' in rel_p or '/lt/' in rel_p:
        continue
    h1 = find_h1(rel_p)
    if h1:
        ok, errs = check_title_en(h1)
        if not ok:
            errors.append(f'H1 heading in {rel_p} [en]: \"{h1}\" -> {errs}')

if errors:
    print(f'❌ Title capitalization audit failed with {len(errors)} error(s):', file=sys.stderr)
    for err in errors:
        print(f'   - {err}', file=sys.stderr)
    sys.exit(1)

print('     ✅ 100% of titles and headings adhere to English Title Case and Localized Sentence Case rules.')
EOF

echo "✅ Title capitalization validation successful!"
