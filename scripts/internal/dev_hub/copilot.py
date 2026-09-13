#!/usr/bin/env python3
"""
Oracle DevOps Platform - Developer Hub GitHub Copilot Engine (scripts/internal/dev_hub/copilot.py)
Provides zero-trust sanitized RAG context, GitHub Copilot / Models API integration,
offline deterministic fallback search, and VS Code Copilot Chat deep-linking.
"""

import os
import sys
import re
import json
import shutil
import subprocess
import urllib.request
import urllib.error
import urllib.parse

# Ensure scripts/internal is in sys.path
INTERNAL_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
WORKSPACE_DIR = os.path.abspath(os.path.join(INTERNAL_DIR, "../.."))
if INTERNAL_DIR not in sys.path:
    sys.path.insert(0, INTERNAL_DIR)

try:
    from dev_hub.catalog import DOC_SPECS, BP_CATALOG
except Exception:
    DOC_SPECS = []
    BP_CATALOG = []

# Regex patterns for Zero-Trust Sanitizer (Rule 5)
SENSITIVE_PATTERNS = [
    (re.compile(r'(?i)(password|passwd|pwd|secret|auth_token|bearer)\s*[:=]\s*["\']?[^"\'\s,;]+["\']?'), r'\1=[REDACTED_SECRET]'),
    (re.compile(r'(?i)IDENTIFIED\s+BY\s+["\']?[^"\'\s;]+["\']?'), r'IDENTIFIED BY "[REDACTED_PASSWORD]"'),
    (re.compile(r'(?i)(cwallet\.sso|ewallet\.p12|keystore\.jks)'), r'\1 [SEPS_ENCRYPTED_STORE]'),
    (re.compile(r'-----BEGIN [A-Z ]*PRIVATE KEY-----[a-zA-Z0-9+/=\s]+-----END [A-Z ]*PRIVATE KEY-----'), r'[REDACTED_PRIVATE_KEY]'),
    (re.compile(r'gh[pousr]_[a-zA-Z0-9]{20,255}'), r'[REDACTED_GITHUB_TOKEN]'),
    (re.compile(r'github_pat_[a-zA-Z0-9_]{82}'), r'[REDACTED_GITHUB_TOKEN]'),
]


def sanitize_text(text: str) -> str:
    """Masks credentials, private keys, and SEPS Wallet passwords to adhere to Rule 5 Zero-Trust."""
    if not text:
        return ""
    sanitized = text
    for pattern, replacement in SENSITIVE_PATTERNS:
        sanitized = pattern.sub(replacement, sanitized)
    return sanitized


def get_copilot_token() -> tuple:
    """
    Resolves GitHub token in-memory using priority:
    1. GITHUB_TOKEN or COPILOT_TOKEN environment variable (process memory only).
    2. gh auth token via local GitHub CLI (memory only via subprocess stdout).
    Returns (token_or_none, auth_type_str).
    """
    env_token = os.environ.get("GITHUB_TOKEN") or os.environ.get("COPILOT_TOKEN")
    if env_token and env_token.strip():
        return env_token.strip(), "env_token"

    # Try gh auth token
    gh_bin = os.environ.get("GH_BIN") or "gh"
    try:
        res = subprocess.run([gh_bin, "auth", "token"], capture_output=True, text=True, timeout=4)
        if res.returncode == 0 and res.stdout.strip():
            return res.stdout.strip(), "gh_cli"
    except Exception:
        pass

    return None, "none"


def get_copilot_status() -> dict:
    """Returns the current availability status of GitHub Copilot / Models API."""
    token, auth_type = get_copilot_token()
    active_bp = get_active_blueprint_id()
    username = "developer"
    is_valid = bool(token)
    if auth_type == "gh_cli":
        try:
            gh_bin = os.environ.get("GH_BIN") or "gh"
            res = subprocess.run([gh_bin, "api", "user", "--jq", ".login"], capture_output=True, text=True, timeout=3)
            if res.returncode == 0 and res.stdout.strip():
                username = res.stdout.strip()
            else:
                is_valid = False
        except Exception:
            is_valid = False

    return {
        "status": "ok",
        "available": is_valid,
        "auth_type": auth_type,
        "username": username,
        "model": "gpt-4o",
        "active_blueprint": active_bp,
        "offline_ready": True
    }


def get_antigravity_status() -> dict:
    """Returns availability of Google Antigravity CLI and Desktop Apps."""
    agy_bin = os.environ.get("AGY_BIN") or shutil.which("agy")
    app_installed = os.path.exists("/Applications/Antigravity.app") or os.path.exists("/Applications/Antigravity IDE.app")
    version_str = "Antigravity 2.0"
    if agy_bin:
        try:
            res = subprocess.run([agy_bin, "--version"], capture_output=True, text=True, timeout=3)
            if res.returncode == 0 and res.stdout.strip():
                version_str = res.stdout.strip()
        except Exception:
            pass

    return {
        "status": "ok",
        "available": bool(agy_bin) or app_installed,
        "has_cli": bool(agy_bin),
        "app_installed": app_installed,
        "cli_path": agy_bin or "",
        "version": version_str,
        "offline_ready": True
    }


def get_ai_status() -> dict:
    """Unified status reporting for both GitHub Copilot and Google Antigravity."""
    copilot_st = get_copilot_status()
    antigravity_st = get_antigravity_status()
    active_bp = get_active_blueprint_id()
    default_prov = "copilot"
    if not copilot_st["available"] and antigravity_st["available"]:
        default_prov = "antigravity"

    return {
        "status": "ok",
        "active_blueprint": active_bp,
        "providers": {
            "copilot": copilot_st,
            "antigravity": antigravity_st
        },
        "default_provider": default_prov
    }


def get_active_blueprint_id() -> int:
    """Reads .active_blueprint file or falls back to default 0."""
    bp_file = os.path.join(WORKSPACE_DIR, ".active_blueprint")
    if os.path.isfile(bp_file):
        try:
            with open(bp_file, "r", encoding="utf-8") as f:
                content = f.read().strip()
                match = re.search(r"\d+", content)
                if match:
                    return int(match.group(0))
        except Exception:
            pass
    return 0


def get_smart_rag_context(query: str, current_lang: str = "en") -> dict:
    """
    Extracts Top-K relevant documentation snippets and current platform state
    based on keywords in query. Context is budget-limited to ~1500 tokens.
    """
    active_bp = get_active_blueprint_id()
    q_lower = query.lower()
    
    # 1. Blueprint context
    bp_meta = BP_CATALOG.get(active_bp) if isinstance(BP_CATALOG, dict) else None
    bp_info = f"Active Blueprint: #{active_bp}"
    if bp_meta:
        title_tuple = bp_meta.get(current_lang) or bp_meta.get("en")
        title_str = title_tuple[0] if isinstance(title_tuple, (tuple, list)) else str(title_tuple)
        conts = bp_meta.get("conts", "")
        bp_info += f" ({title_str}) - Containers: {conts}"

    # 2. Extract matching snippets from documentation
    sources = []
    snippets = []
    
    # Keyword-to-document heuristic mapping
    doc_scores = []
    for doc in DOC_SPECS:
        doc_rel = doc.get("rel", "")
        doc_id = doc.get("id", "")
        titles = doc.get("titles", {})
        title = titles.get(current_lang) or titles.get("en") or doc_rel
        
        score = 0
        words = re.findall(r'\w+', q_lower)
        for w in words:
            if len(w) < 3:
                continue
            if w in doc_rel.lower() or w in doc_id.lower() or w in title.lower():
                score += 3
        
        # Domain keyword weighting
        if any(k in q_lower for k in ["rtf", "publisher", "arve", "invoice", "xml", "accessibility", "ua-1"]) and "publisher" in doc_rel.lower():
            score += 5
        if any(k in q_lower for k in ["wallet", "parool", "password", "saladus", "seps", "mkstore"]) and "wallet" in doc_rel.lower():
            score += 5
        if any(k in q_lower for k in ["test", "ci", "kontroll", "katvus", "raport"]) and "test" in doc_rel.lower():
            score += 5
        if any(k in q_lower for k in ["blueprint", "arhitektuur", "port", "konteiner", "podman"]) and "blueprint" in doc_rel.lower():
            score += 5

        if score > 0:
            doc_scores.append((score, doc))

    doc_scores.sort(key=lambda x: x[0], reverse=True)
    top_docs = [d[1] for d in doc_scores[:3]]

    for doc in top_docs:
        doc_rel = doc.get("rel", "")
        # Resolve localized file if available
        candidates = [
            os.path.join(WORKSPACE_DIR, f"docs/{current_lang}", os.path.basename(doc_rel)),
            os.path.join(WORKSPACE_DIR, doc_rel),
            os.path.join(WORKSPACE_DIR, f"docs/{doc_rel}")
        ]
        chosen_path = None
        for c in candidates:
            if os.path.isfile(c):
                chosen_path = c
                break
        
        if chosen_path:
            try:
                with open(chosen_path, "r", encoding="utf-8", errors="ignore") as f:
                    content = f.read()
                # Take up to first 1200 characters of meaningful content
                clean_content = re.sub(r'```[\s\S]*?```', '[code example omitted]', content[:1500])
                clean_content = sanitize_text(clean_content.strip()[:800])
                title = doc.get("title", {}).get(current_lang, doc.get("title", {}).get("en", doc_rel))
                snippets.append(f"### Doc: {title} ({doc_rel})\n{clean_content}...")
                sources.append({"id": doc.get("id"), "title": title, "path": doc_rel})
            except Exception:
                pass

    return {
        "active_blueprint_summary": bp_info,
        "snippets": snippets,
        "sources": sources
    }


def generate_offline_response(query: str, current_lang: str, rag: dict) -> str:
    """Generates an intelligent structured response when GitHub API is unreachable."""
    q_lower = query.lower()
    bp_info = rag.get("active_blueprint_summary", "Oracle DevOps Platform")
    
    # Tailored offline expert responses based on topic
    if any(k in q_lower for k in ["blueprint", "käivita", "start", "switch", "aktiveeri", "kavand"]):
        return (
            f"**[Lokaalne Teadmusbaas / Offline Režiim]**\n\n"
            f"📍 **Hetke olek:** `{bp_info}`\n\n"
            f"Blueprinti käivitamiseks või vahetamiseks kasuta käsku:\n"
            f"```bash\n"
            f"./scripts/deploy-blueprint.sh -b <NUMBRIT> --lang {current_lang}\n"
            f"```\n"
            f"- **Uuendamine/taaskäivitus olemasolevas keskkonnas:** `./scripts/deploy-blueprint.sh -b <N> -u`\n"
            f"- **Eelvaade (Dry-Run):** `./scripts/deploy-blueprint.sh -b <N> --dry-run`\n"
            f"- **Kõikide blueprintide loend:** `./scripts/deploy-blueprint.sh --list`\n\n"
            f"*(GitHub Copilot API pole hetkel ühendatud või puudub internet. Vastus genereeritud lokaalsest dokumentatsioonist).* "
        )
    elif any(k in q_lower for k in ["parool", "password", "wallet", "seps", "salasõna"]):
        return (
            f"**[Lokaalne Teadmusbaas / Offline Režiim]**\n\n"
            f"🔒 **Oracle SEPS Auto-Login Wallet (Reegel 5 Zero-Trust):**\n"
            f"Platvorm ei kirjuta paroole kettale plaintextina. Kõik paroolid genereeritakse mälupõhiselt ja talletatakse krüpteeritud SEPS Walletis.\n\n"
            f"Parooli pärimiseks otse mälust käivita:\n"
            f"```bash\n"
            f"./scripts/get-password.sh <ALIAS>\n"
            f"```\n"
            f"Levinumad aliased: `DB_ADMIN_SYS`, `DB_APEX_ADMIN`, `ORDS_ADMIN`.\n\n"
            f"*(GitHub Copilot API pole hetkel ühendatud. Vastus genereeritud lokaalsest dokumentatsioonist).* "
        )
    elif any(k in q_lower for k in ["rtf", "publisher", "arve", "invoice", "accessibility", "pdf"]):
        return (
            f"**[Lokaalne Teadmusbaas / Offline Režiim]**\n\n"
            f"📄 **Oracle Analytics Publisher RTF mallide standardid:**\n"
            f"- **Väljad:** `<?FIELD_NAME?>` või suhteline tee `<?SELLER/COMPANY_NAME?>`\n"
            f"- **Korduvad read:** esimesse lahtrisse `<?for-each:LINES/LINE?><?LINE_NUM?>` ja viimasesse `<?format-number(LINE_TOTAL, '#,##0.00')?><?end for-each?>`\n"
            f"- **Format:** `<?format-number(FIELD, '#,##0.00')?> EUR` ja `<?format-date(FIELD, 'YYYY-MM-DD')?>`\n"
            f"- **Näidisandmed:** `templates/publisher/samples/arve_test_andmed.xml`\n"
            f"- **Testrenderdus:** `./scripts/publisher/test-render.sh templates/publisher/samples/arve_test_standard.rtf`\n\n"
            f"*(GitHub Copilot API pole hetkel ühendatud. Vastus genereeritud lokaalsest dokumentatsioonist).* "
        )
    elif any(k in q_lower for k in ["test", "ci", "kontroll"]):
        return (
            f"**[Lokaalne Teadmusbaas / Offline Režiim]**\n\n"
            f"🧪 **Testraamistik (155+ testi):**\n"
            f"- **Lokaalne CI simulaator:** `./tests/test-local-ci.sh`\n"
            f"- **Ühiktestid:** `./tests/unit/test-dev-hub-generation.sh`, `./tests/unit/test-filename-portability.sh`\n"
            f"- **6-keele sümmeetria:** `./tests/unit/test-multilingual-support.sh`\n\n"
            f"*(GitHub Copilot API pole hetkel ühendatud. Vastus genereeritud lokaalsest dokumentatsioonist).* "
        )

    # General offline fallback with sources
    source_names = ", ".join([s["title"] for s in rag.get("sources", [])]) or "README.md"
    return (
        f"**[Lokaalne Teadmusbaas / Offline Režiim]**\n\n"
        f"Küsimuse teema: *\"{query}\"*\n"
        f"Aktiivne keskkond: **{bp_info}**\n\n"
        f"Asjakohased dokumendid repositooriumis:\n"
        + "".join([f"- **{s['title']}** (`{s['path']}`)\n" for s in rag.get("sources", [])])
        + f"\n💡 *Täieliku GitHub Copilot AI vastuse saamiseks kontrolli, et arvutis oleks käivitatud `gh auth login` või lisatud `GITHUB_TOKEN`.*"
    )


def call_github_copilot_api(messages: list, token: str) -> str:
    """
    Calls GitHub Copilot API / Models API over TLS.
    Defaults to official endpoint: https://api.githubcopilot.com/chat/completions (model: gpt-4o)
    """
    endpoint = os.environ.get("COPILOT_API_ENDPOINT") or "https://api.githubcopilot.com/chat/completions"
    model = os.environ.get("COPILOT_MODEL") or "gpt-4o"

    payload = {
        "model": model,
        "messages": messages,
        "temperature": 0.3,
        "max_tokens": 1200
    }
    
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {token}",
        "User-Agent": "Oracle-DevOps-DevHub-Copilot/1.0"
    }

    req = urllib.request.Request(endpoint, data=json.dumps(payload).encode("utf-8"), headers=headers, method="POST")
    with urllib.request.urlopen(req, timeout=15) as resp:
        data = json.loads(resp.read().decode("utf-8"))
        choices = data.get("choices", [])
        if choices and "message" in choices[0]:
            return choices[0]["message"].get("content", "").strip()
        return "Vastust ei õnnestunud parsida."


def ask_copilot(query: str, history: list = None, current_lang: str = "en") -> dict:
    """
    Main entry point for handling user question with RAG, sanitization, and fallback.
    """
    if not query or not query.strip():
        return {"status": "error", "message": "Päring ei tohi olla tühi."}

    sanitized_query = sanitize_text(query.strip())
    token, auth_type = get_copilot_token()
    rag = get_smart_rag_context(sanitized_query, current_lang)

    # If no token, return high quality deterministic offline response immediately
    if not token or auth_type == "none":
        reply = generate_offline_response(sanitized_query, current_lang, rag)
        return {
            "status": "ok",
            "reply": reply,
            "offline": True,
            "auth_type": "none",
            "sources": rag.get("sources", []),
            "model": "offline-knowledge-base"
        }

    # Construct System Prompt with Zero-Trust guidelines and RAG context
    system_prompt = (
        "You are the specialized GitHub Copilot AI Assistant embedded inside the Oracle DevOps Platform Developer Hub.\n"
        "Your role is to assist developers with Oracle Database 23ai Free, APEX, ORDS, Liquibase, BI Publisher (Pixel Perfect RTF), "
        "WebLogic, and the 13 platform architecture blueprints.\n\n"
        "MANDATORY PLATFORM RULES:\n"
        "1. Rule 5 (Zero-Trust): NEVER ask for, display, or generate fake passwords. Always refer to `./scripts/get-password.sh <ALIAS>`.\n"
        "2. Rule 6 (SQLcl only): Always recommend modern SQLcl (`sql`), NEVER legacy SQL*Plus.\n"
        "3. Language Rule: Respond naturally in the language of the user's question (supports EN, ET, FI, SV, LV, LT), matching platform terminology.\n"
        "4. Tone: Concise, developer-focused, accurate, with copyable shell/SQL code blocks.\n\n"
        f"CURRENT ENVIRONMENT:\n{rag.get('active_blueprint_summary')}\n\n"
        "<retrieved_context>\n"
        + "\n\n".join(rag.get("snippets", []))
        + "\n</retrieved_context>\n"
    )

    messages = [{"role": "system", "content": system_prompt}]
    
    # Add recent history (up to 4 turns for context budget)
    if history and isinstance(history, list):
        for turn in history[-4:]:
            role = "user" if turn.get("sender") == "user" else "assistant"
            content = sanitize_text(turn.get("text", ""))
            if content:
                messages.append({"role": role, "content": content})

    messages.append({"role": "user", "content": sanitized_query})

    try:
        reply = call_github_copilot_api(messages, token)
        return {
            "status": "ok",
            "reply": reply,
            "offline": False,
            "auth_type": auth_type,
            "sources": rag.get("sources", []),
            "model": "gpt-4o"
        }
    except Exception as err:
        # Graceful fallback on network/rate-limit error
        fallback_reply = generate_offline_response(sanitized_query, current_lang, rag)
        return {
            "status": "ok",
            "reply": f"{fallback_reply}\n\n*(GitHub API päring ebaõnnestus: {sanitize_text(str(err))})*",
            "offline": True,
            "auth_type": auth_type,
            "sources": rag.get("sources", []),
            "model": "offline-fallback"
        }


def generate_vscode_deeplink(query: str, current_lang: str = "en") -> dict:
    """
    Builds a VS Code deep-link URI and full markdown context for clipboard.
    Prevents URL overflow by placing short prompt in URL and rich context on clipboard.
    """
    rag = get_smart_rag_context(query, current_lang)
    short_query = (query or "").strip()
    if len(short_query) > 120:
        short_query = short_query[:117] + "..."

    encoded_msg = urllib.parse.quote(f"@workspace {short_query}")
    vscode_url = f"vscode://github.copilot/chat?message={encoded_msg}"

    clipboard_payload = (
        f"## Context: Oracle DevOps Platform ({rag.get('active_blueprint_summary')})\n\n"
        f"### User Question:\n{query}\n\n"
        f"### Relevant Platform Documentation:\n"
        + "\n\n".join(rag.get("snippets", []))
        + "\n\n### Platform Instructions:\n"
        "- Zero plaintext passwords (Rule 5): Use `./scripts/get-password.sh <ALIAS>`.\n"
        "- Modern SQLcl only (Rule 6.6).\n"
    )

    return {
        "status": "ok",
        "vscode_url": vscode_url,
        "clipboard_content": clipboard_payload,
        "short_query": short_query,
        "target": "vscode"
    }


def ask_antigravity(query: str, history: list = None, current_lang: str = "en") -> dict:
    """
    Executes a query against Google Antigravity using local agy CLI if available,
    with Zero-Trust sanitization (Rule 5) and instant offline fallback.
    """
    if not query or not query.strip():
        return {"status": "error", "message": "Päring ei tohi olla tühi."}

    sanitized_query = sanitize_text(query.strip())
    rag = get_smart_rag_context(sanitized_query, current_lang)
    agy_bin = os.environ.get("AGY_BIN") or shutil.which("agy")

    # If agy binary is available, run one-shot query
    if agy_bin:
        try:
            rag_summary = "\n".join(rag.get("snippets", []))
            prompt_payload = (
                f"Context from Oracle DevOps Platform ({rag.get('active_blueprint_summary')}):\n"
                f"{rag_summary}\n\n"
                f"User Question: {sanitized_query}"
            )
            res = subprocess.run(
                [agy_bin, "--prompt", prompt_payload],
                capture_output=True,
                text=True,
                timeout=25
            )
            if res.returncode == 0 and res.stdout.strip():
                clean_reply = sanitize_text(res.stdout.strip())
                return {
                    "status": "ok",
                    "reply": clean_reply,
                    "offline": False,
                    "provider": "antigravity",
                    "sources": rag.get("sources", []),
                    "model": "Antigravity CLI (agy)"
                }
        except Exception:
            pass

    # Fallback to intelligent local knowledge base
    offline_reply = generate_offline_response(sanitized_query, current_lang, rag)
    note = (
        "\n\n*(Vastus genereeritud lokaalsest teadmusbaasist. Antigravity rakenduse süvalink ja lõikelaud on kättesaadavad nupu 'Ava Antigravitys' kaudu).* "
        if current_lang == "et"
        else "\n\n*(Response generated from local platform knowledge base. Antigravity Desktop App bridge is available via 'Open in Antigravity').* "
    )
    return {
        "status": "ok",
        "reply": f"{offline_reply}{note}",
        "offline": True,
        "provider": "antigravity",
        "sources": rag.get("sources", []),
        "model": "Antigravity Local KB"
    }


def generate_antigravity_deeplink(query: str, current_lang: str = "en") -> dict:
    """
    Builds an Antigravity deep-link URI and rich markdown context for clipboard.
    Uses antigravity:// URL scheme and formats detailed platform metadata.
    """
    rag = get_smart_rag_context(query, current_lang)
    short_query = (query or "").strip()
    if len(short_query) > 120:
        short_query = short_query[:117] + "..."

    encoded_msg = urllib.parse.quote(short_query)
    antigravity_url = f"antigravity://chat?message={encoded_msg}"

    clipboard_payload = (
        f"## Context: Oracle DevOps Platform ({rag.get('active_blueprint_summary')})\n\n"
        f"### User Question:\n{query}\n\n"
        f"### Relevant Platform Documentation:\n"
        + "\n\n".join(rag.get("snippets", []))
        + "\n\n### Platform Guidelines:\n"
        "- Zero plaintext passwords (Rule 5): Use `./scripts/get-password.sh <ALIAS>`.\n"
        "- Modern SQLcl CLI only (Rule 6.6).\n"
        "- Dual-stream terminal UX & live benchmarks (Rule 1 & Rule 7).\n"
    )

    return {
        "status": "ok",
        "antigravity_url": antigravity_url,
        "clipboard_content": clipboard_payload,
        "short_query": short_query,
        "target": "antigravity"
    }


def ask_ai(provider: str, query: str, history: list = None, current_lang: str = "en") -> dict:
    """Dispatches chat query to either github_copilot or google_antigravity."""
    if provider == "antigravity":
        return ask_antigravity(query, history, current_lang)
    return ask_copilot(query, history, current_lang)


def generate_ai_deeplink(target: str, query: str, current_lang: str = "en") -> dict:
    """Dispatches deeplink generator to target ('vscode' or 'antigravity')."""
    if target == "antigravity":
        return generate_antigravity_deeplink(query, current_lang)
    return generate_vscode_deeplink(query, current_lang)


if __name__ == "__main__":
    print("Testing copilot.py status...")
    st = get_copilot_status()
    print(json.dumps(st, indent=2))
    test_rag = get_smart_rag_context("Kuidas muuta publisher arve rtf malli?")
    print(f"RAG Snippets: {len(test_rag['snippets'])}, Sources: {len(test_rag['sources'])}")
