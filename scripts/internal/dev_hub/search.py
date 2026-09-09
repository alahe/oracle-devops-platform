"""
Oracle DevOps Platform - Developer Hub (SPA) Universal Omnisearch Indexer
Generates pre-indexed searchable catalog for offline client search across:
- Markdown documentation & section headings (docs/, README.md)
- Architecture Blueprints (.env.0 .. .env.11)
- YAML Profiles (config/profiles/**/*.yaml)
- Shell & automation scripts (scripts/**/*.sh, scripts/certs/*)
- Test suites (tests/*.sh, tests/unit/*.sh)
- Architecture Glossary & Acronyms
- Platform FAQs
- AI Skills (.agents/skills/*/SKILL.md)
- Official Oracle Resources

Supports Option A: Multilingual indexing across all 6 platform languages:
🇬🇧 EN | 🇪🇪 ET | 🇫🇮 FI | 🇸🇪 SV | 🇱🇻 LV | 🇱🇹 LT
"""
import os
import glob
import re
import sys

if __package__ is None or __package__ == '':
    parent_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    if parent_dir not in sys.path:
        sys.path.insert(0, parent_dir)
    from dev_hub.catalog import DOC_SPECS, BP_CATALOG
    from dev_hub.glossary import get_glossary_catalog
    from dev_hub.faq import get_faq_catalog
    from dev_hub.skills import get_skills_catalog
    from dev_hub.oracle_resources import get_oracle_resources_catalog
    from dev_hub.topology import get_all_profiles_metadata
else:
    from .catalog import DOC_SPECS, BP_CATALOG
    from .glossary import get_glossary_catalog
    from .faq import get_faq_catalog
    from .skills import get_skills_catalog
    from .oracle_resources import get_oracle_resources_catalog
    from .topology import get_all_profiles_metadata

LANGUAGES = ["en", "et", "fi", "sv", "lv", "lt"]


def _slugify(text):
    """Generate simple URL anchor slug from heading text."""
    slug = text.lower().strip()
    slug = re.sub(r'[^\w\s-]', '', slug)
    slug = re.sub(r'[\s_]+', '-', slug)
    return slug


def _extract_script_description(filepath):
    """Extract first comment block or synopsis from a shell script or python file."""
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            lines = f.readlines()
        comments = []
        for line in lines[:30]:
            line_str = line.strip()
            if line_str.startswith('#!') or line_str == '#':
                continue
            if line_str.startswith('#'):
                cleaned = line_str.lstrip('#').strip()
                if cleaned and not cleaned.startswith('===') and not cleaned.startswith('---'):
                    comments.append(cleaned)
                    if len(comments) >= 2:
                        break
            elif comments:
                break
        if comments:
            return ' '.join(comments)
    except Exception:
        pass
    return ''


def generate_search_index(workspace_dir):
    """
    Compile complete searchable repository index for DevHub client-side search.
    Returns a list of dict items structured for fast fuzzy filtering and navigation
    with multilingual titles and keywords across EN, ET, FI, SV, LV, LT.
    """
    ws = os.path.abspath(workspace_dir)
    items = []

    # 1. Documentation Guides & Headings
    for idx, spec in enumerate(DOC_SPECS):
        doc_id = spec["id"]
        rel_path = spec.get("rel", "")
        titles = spec.get("titles", {})
        default_title = titles.get("en", rel_path)
        all_titles_str = ' '.join(str(v) for v in titles.values())
        
        # Read file to extract summary and headings
        full_path = os.path.join(ws, rel_path)
        content = ""
        if os.path.isfile(full_path):
            try:
                with open(full_path, "r", encoding="utf-8", errors="ignore") as f:
                    content = f.read()
            except Exception:
                pass

        # First paragraph as doc summary
        summary = ""
        paragraphs = [p.strip() for p in content.split("\n\n") if p.strip() and not p.strip().startswith("#") and not p.strip().startswith("```") and not p.strip().startswith("|")]
        if paragraphs:
            summary = paragraphs[0].replace("\n", " ")[:180]

        # Add document root entry
        items.append({
            "id": f"doc-{doc_id}",
            "type": "doc",
            "category": "docs",
            "title": default_title,
            "titles": titles,
            "path": rel_path,
            "summary": summary or f"Documentation guide: {rel_path}",
            "keywords": f"{doc_id} {rel_path} doc guide {all_titles_str}",
            "target": {
                "action": "navigate_doc",
                "docIdx": idx,
                "docId": doc_id,
                "path": rel_path
            }
        })

        # Extract Headings (##, ###) for deep link jumps
        if content:
            for match in re.finditer(r'^(#{2,3})\s+(.+)$', content, re.MULTILINE):
                heading_raw = match.group(2).strip()
                heading_title = re.sub(r'\[([^\]]+)\]\([^\)]+\)', r'\1', heading_raw)
                heading_title = heading_title.replace('`', '').strip()
                if not heading_title:
                    continue
                anchor = _slugify(heading_title)
                
                sec_titles = {lang: f"{heading_title} ({titles.get(lang, default_title)})" for lang in LANGUAGES}
                items.append({
                    "id": f"doc-{doc_id}-{anchor}",
                    "type": "doc_section",
                    "category": "docs",
                    "title": heading_title,
                    "titles": sec_titles,
                    "parentTitle": default_title,
                    "path": f"{rel_path}#{anchor}",
                    "summary": f"Section in {default_title} ({rel_path})",
                    "keywords": f"{heading_title} {doc_id} section {all_titles_str}",
                    "target": {
                        "action": "navigate_doc",
                        "docIdx": idx,
                        "docId": doc_id,
                        "anchor": anchor,
                        "path": rel_path
                    }
                })

    # 2. Canonical Architecture Blueprints (0..11)
    bp_files = sorted(glob.glob(os.path.join(ws, "config/blueprints/.env.*")))
    for bp_file in bp_files:
        b_base = os.path.basename(bp_file)
        m = re.search(r"\.env\.(\d+)", b_base)
        if not m:
            continue
        b_num = int(m.group(1))
        info = BP_CATALOG.get(b_num, {})
        rel_path = os.path.relpath(bp_file, ws)
        bp_ram = info.get("ram", "~3.0 GB")
        bp_conts = info.get("conts", 1)

        bp_titles = {lang: f"BP #{b_num}: {info.get(lang, info.get('en', [f'Blueprint #{b_num}', '']))[0]}" for lang in LANGUAGES}
        bp_summaries = {lang: f"{info.get(lang, info.get('en', ['', '']))[1]} | RAM: {bp_ram} | Containers: {bp_conts}" for lang in LANGUAGES}
        all_bp_kw = ' '.join(bp_titles.values()) + ' ' + ' '.join(bp_summaries.values())

        items.append({
            "id": f"bp-{b_num}",
            "type": "blueprint",
            "category": "blueprints",
            "title": bp_titles["en"],
            "titles": bp_titles,
            "summary": bp_summaries["en"],
            "summaries": bp_summaries,
            "path": rel_path,
            "keywords": f"blueprint {b_num} bp{b_num} {b_base} env {all_bp_kw}",
            "target": {
                "action": "navigate_tab",
                "tabId": "tab-services",
                "section": "blueprints",
                "bpNum": b_num,
                "path": rel_path
            }
        })

    # 3. YAML Profiles (config/profiles/**/*.yaml)
    try:
        profiles_meta = get_all_profiles_metadata(ws=ws, include_content=False)
        for prof in profiles_meta:
            prof_name = prof.get("name", "")
            prof_cat = prof.get("category", "database")
            rel_path = prof.get("rel_path", f"config/profiles/databases/{prof_name}.yaml")
            services = ", ".join(prof.get("services", []))
            summary_parts = []
            if prof.get("version"):
                summary_parts.append(f"Oracle {prof.get('version')}")
            if services:
                summary_parts.append(f"Services: {services}")
            if prof.get("port"):
                summary_parts.append(f"Port: {prof.get('port')}")
            summary = " | ".join(summary_parts) or f"{prof_cat.capitalize()} Profile: {prof_name}"

            items.append({
                "id": f"prof-{prof_name}",
                "type": "profile",
                "category": "profiles",
                "title": f"Profile: {prof_name} ({prof_cat.upper()})",
                "path": rel_path,
                "summary": summary,
                "keywords": f"profile {prof_name} yaml {prof_cat} {services}",
                "target": {
                    "action": "view_preview",
                    "path": rel_path,
                    "title": f"Profile: {prof_name}.yaml",
                    "fileType": "yaml"
                }
            })
    except Exception:
        pass

    # 4. User CLI & Automation Scripts
    script_patterns = [
        "scripts/*.sh",
        "scripts/snapshots/*.sh",
        "scripts/certs/*.sh",
        "scripts/certs/*.cmd",
        "scripts/certs/*.ps1",
        "scripts/publisher/*.sh",
        "scripts/internal/*.sh"
    ]
    seen_scripts = set()
    for pat in script_patterns:
        full_pat = os.path.join(ws, pat)
        for s_file in sorted(glob.glob(full_pat)):
            rel_path = os.path.relpath(s_file, ws)
            if rel_path in seen_scripts:
                continue
            seen_scripts.add(rel_path)
            
            s_name = os.path.basename(s_file)
            desc = _extract_script_description(s_file)
            items.append({
                "id": f"script-{s_name}",
                "type": "script",
                "category": "scripts",
                "title": f"Script: {s_name}",
                "path": rel_path,
                "summary": desc or f"Automation script in {os.path.dirname(rel_path)}",
                "keywords": f"script bash sh {s_name} {os.path.dirname(rel_path)}",
                "target": {
                    "action": "view_preview",
                    "path": rel_path,
                    "title": s_name,
                    "fileType": "bash"
                }
            })

    # 5. Testing Suites & Unit Tests
    test_files = sorted(glob.glob(os.path.join(ws, "tests/*.sh")) + glob.glob(os.path.join(ws, "tests/unit/*.sh")))
    for t_file in test_files:
        rel_path = os.path.relpath(t_file, ws)
        t_name = os.path.basename(t_file)
        desc = _extract_script_description(t_file)
        items.append({
            "id": f"test-{t_name}",
            "type": "test",
            "category": "tests",
            "title": f"Test: {t_name}",
            "path": rel_path,
            "summary": desc or f"Automated test suite {t_name}",
            "keywords": f"test suite unit ci {t_name}",
            "target": {
                "action": "navigate_tab",
                "tabId": "tab-testing",
                "suiteName": t_name,
                "path": rel_path
            }
        })

    # 6. Architecture Glossary & Acronyms (Multilingual Definitions)
    try:
        glossary_list = get_glossary_catalog()
        for item in glossary_list:
            acronym = item.get("acronym") or item.get("term", "")
            expansion = item.get("expansion") or item.get("fullName", "")
            cat = item.get("category", "")
            defs = item.get("def", {})
            roles = item.get("project_role", {})
            
            g_titles = {lang: f"{acronym} – {expansion}" if expansion else acronym for lang in LANGUAGES}
            g_summaries = {lang: defs.get(lang, defs.get("en", ""))[:180] for lang in LANGUAGES}
            all_def_kw = ' '.join(defs.values()) + ' ' + ' '.join(roles.values())

            items.append({
                "id": f"glossary-{acronym}",
                "type": "glossary",
                "category": "glossary",
                "title": f"{acronym} – {expansion}" if expansion else acronym,
                "titles": g_titles,
                "summary": g_summaries.get("en", ""),
                "summaries": g_summaries,
                "path": "docs/architecture-glossary.md",
                "keywords": f"glossary acronym term {acronym} {expansion} {cat} {all_def_kw}",
                "target": {
                    "action": "open_glossary",
                    "term": acronym,
                    "path": "docs/architecture-glossary.md"
                }
            })
    except Exception:
        pass

    # 7. Platform FAQs (Multilingual Q&A)
    try:
        faq_list = get_faq_catalog()
        for f_item in faq_list:
            f_id = f_item.get("id", "")
            q_dict = f_item.get("question", {}) if isinstance(f_item.get("question"), dict) else {"en": f_item.get("q_en") or f_item.get("question") or ""}
            a_dict = f_item.get("answer", {}) if isinstance(f_item.get("answer"), dict) else {"en": f_item.get("a_en") or f_item.get("answer") or ""}
            cat = f_item.get("category", "faq")

            faq_titles = {lang: f"FAQ: {q_dict.get(lang, q_dict.get('en', ''))}" for lang in LANGUAGES}
            clean_a_dict = {lang: re.sub(r'\s+', ' ', re.sub(r'<[^>]+>', ' ', a_dict.get(lang, a_dict.get('en', '')))).strip()[:180] for lang in LANGUAGES}
            all_faq_kw = ' '.join(q_dict.values()) + ' ' + ' '.join(clean_a_dict.values())

            items.append({
                "id": f"faq-{f_id}",
                "type": "faq",
                "category": "faq",
                "title": faq_titles.get("en", ""),
                "titles": faq_titles,
                "summary": clean_a_dict.get("en", ""),
                "summaries": clean_a_dict,
                "path": "docs/faq.md",
                "keywords": f"faq question answer {f_id} {cat} {all_faq_kw}",
                "target": {
                    "action": "open_faq",
                    "faqId": f_id,
                    "path": "docs/faq.md"
                }
            })
    except Exception:
        pass

    # 8. AI Skills (.agents/skills/*/SKILL.md)
    try:
        skills_list = get_skills_catalog(ws)
        for s in skills_list:
            s_id = s.get("id", "")
            s_name = s.get("name", s_id)
            rel_path = s.get("rel_path", f".agents/skills/{s_id}/SKILL.md")
            desc = s.get("desc", "")
            tier = s.get("tier", 1)
            items.append({
                "id": f"skill-{s_id}",
                "type": "skill",
                "category": "skills",
                "title": f"AI Skill: {s_name} (Tier {tier})",
                "path": rel_path,
                "summary": desc,
                "keywords": f"skill agent ai prompt {s_id} {s_name}",
                "target": {
                    "action": "navigate_tab",
                    "tabId": "tab-skills",
                    "skillId": s_id,
                    "path": rel_path
                }
            })
    except Exception:
        pass

    # 9. Official Oracle Resources
    try:
        res_list = get_oracle_resources_catalog()
        for r in res_list:
            r_title = r.get("title", "")
            r_cat = r.get("category", "")
            r_desc = r.get("desc", "")
            r_url = r.get("url", "")
            items.append({
                "id": f"res-{_slugify(r_title)}",
                "type": "resource",
                "category": "resources",
                "title": f"Oracle Resource: {r_title}",
                "path": r_url,
                "summary": f"{r_cat.upper()} | {r_desc}",
                "keywords": f"oracle container image registry download docs {r_title}",
                "target": {
                    "action": "open_url",
                    "url": r_url,
                    "path": r_url
                }
            })
    except Exception:
        pass

    return items
