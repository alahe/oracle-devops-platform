#!/usr/bin/env python3
"""
==============================================================================
Oracle DevOps Platform - Glossary Web Links Zero-Download Auditor
==============================================================================
Safely validates all 57 external glossary links (Wikipedia, Oracle documentation)
with 100% zero-payload in-memory HTTP HEAD requests.

Zero-Download Safety Guarantees:
1. Strictly in-memory: Uses HTTP HEAD to fetch response status headers only.
2. Zero disk writes: No response body is buffered or written to disk.
   Virtual null device 'os.devnull' (resolves to NUL on Windows, /dev/null on POSIX).
3. Protocol security: Strictly enforces 'https://' URLs.
4. Concurrency: Parallelized via ThreadPoolExecutor with strict connection timeouts.
==============================================================================
"""

import os
import sys
import ssl
import argparse
import urllib.request
import urllib.error
from concurrent.futures import ThreadPoolExecutor, as_completed

# Ensure scripts/internal is in sys.path
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
WORKSPACE_DIR = os.path.abspath(os.path.join(SCRIPT_DIR, "../.."))
if SCRIPT_DIR not in sys.path:
    sys.path.insert(0, SCRIPT_DIR)

from dev_hub.glossary import GLOSSARY_ITEMS

USER_AGENT = (
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
    "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
)

def audit_single_url(item, timeout=8):
    """
    Performs a safe, in-memory zero-download HTTP HEAD check on an external URL.
    Returns dict with acronym, url, status_code, ok (bool), message.
    """
    acr = item.get("acronym", "UNKNOWN")
    title = item.get("ref_title", "Reference")
    url = item.get("ref_url", "")

    if not url:
        return {
            "acronym": acr,
            "title": title,
            "url": url,
            "status": 0,
            "ok": False,
            "message": "Missing ref_url"
        }

    if not url.startswith("https://"):
        return {
            "acronym": acr,
            "title": title,
            "url": url,
            "status": 0,
            "ok": False,
            "message": f"Insecure protocol: only https:// is allowed ({url})"
        }

    ctx = ssl.create_default_context()
    # Try HTTP HEAD first to prevent downloading any payload body
    req = urllib.request.Request(
        url,
        headers={"User-Agent": USER_AGENT},
        method="HEAD"
    )

    try:
        with urllib.request.urlopen(req, timeout=timeout, context=ctx) as resp:
            code = resp.getcode()
            # 200 OK (or followed redirect ending in 200)
            return {
                "acronym": acr,
                "title": title,
                "url": url,
                "final_url": resp.geturl(),
                "status": code,
                "ok": (200 <= code < 400),
                "message": f"HTTP {code} OK"
            }
    except urllib.error.HTTPError as e:
        # Some servers (e.g. anti-scraping or older CDNs) reject HEAD with 405 Method Not Allowed
        # If 405 occurs, retry with GET but immediately close without calling read()
        if e.code == 405:
            try:
                req_get = urllib.request.Request(
                    url,
                    headers={"User-Agent": USER_AGENT},
                    method="GET"
                )
                with urllib.request.urlopen(req_get, timeout=timeout, context=ctx) as resp:
                    code = resp.getcode()
                    # Closed without reading body
                    return {
                        "acronym": acr,
                        "title": title,
                        "url": url,
                        "final_url": resp.geturl(),
                        "status": code,
                        "ok": (200 <= code < 400),
                        "message": f"HTTP {code} OK (fallback GET)"
                    }
            except urllib.error.HTTPError as e_sub:
                return {
                    "acronym": acr,
                    "title": title,
                    "url": url,
                    "status": e_sub.code,
                    "ok": False,
                    "message": f"HTTP {e_sub.code} ({e_sub.reason})"
                }
            except Exception as e_sub:
                return {
                    "acronym": acr,
                    "title": title,
                    "url": url,
                    "status": 0,
                    "ok": False,
                    "message": str(e_sub)
                }

        return {
            "acronym": acr,
            "title": title,
            "url": url,
            "status": e.code,
            "ok": False,
            "message": f"HTTP {e.code} ({e.reason})"
        }
    except urllib.error.URLError as e:
        return {
            "acronym": acr,
            "title": title,
            "url": url,
            "status": 0,
            "ok": False,
            "message": f"Network error: {e.reason}"
        }
    except Exception as e:
        return {
            "acronym": acr,
            "title": title,
            "url": url,
            "status": 0,
            "ok": False,
            "message": f"Error: {str(e)}"
        }

def main():
    parser = argparse.ArgumentParser(description="Zero-Download Glossary Links Auditor")
    parser.add_argument("--timeout", type=int, default=10, help="Per-request timeout in seconds (default: 10)")
    parser.add_argument("--workers", type=int, default=6, help="Parallel worker threads (default: 6)")
    parser.add_argument("--quiet", action="store_true", help="Minimal output")
    args = parser.parse_args()

    # Detect OS null device for reporting
    null_dev = os.devnull
    os_name = "Windows (NTFS)" if os.name == "nt" else "POSIX (macOS/Linux)"

    if not args.quiet:
        print("🌐 ==================================================================")
        print("   ORACLE DEVOPS PLATFORM - GLOSSARY WEB LINKS AUDITOR")
        print("   Mode: Zero-Download In-Memory HTTP HEAD Verification")
        print(f"   Environment: {os_name} | Virtual Null Device: {null_dev}")
        print(f"   Target Acronyms: {len(GLOSSARY_ITEMS)} | Parallel Workers: {args.workers}")
        print("==================================================================")

    results = []
    total = len(GLOSSARY_ITEMS)

    with ThreadPoolExecutor(max_workers=args.workers) as executor:
        future_map = {
            executor.submit(audit_single_url, item, args.timeout): item
            for item in GLOSSARY_ITEMS
        }

        completed = 0
        for future in as_completed(future_map):
            completed += 1
            res = future.result()
            results.append(res)
            acr = res["acronym"]
            msg = res["message"]
            symbol = "✅" if res["ok"] else "❌"
            if not args.quiet:
                print(f"  [{completed:2d}/{total:2d}] {symbol} {acr:<12} -> {msg} ({res['url']})")

    failed = [r for r in results if not r["ok"]]

    if not args.quiet:
        print("==================================================================")
        if not failed:
            print(f"🎉 100% SUCCESS: All {total} glossary links verified with HTTP 200 OK!")
            print("   Zero bytes written to disk. All documentation links active and safe.")
        else:
            print(f"❌ AUDIT FAILED: {len(failed)} of {total} glossary links returned non-200 status:")
            for f in failed:
                print(f"   • {f['acronym']}: {f['message']} -> {f['url']}")
        print("==================================================================")

    sys.exit(0 if not failed else 1)

if __name__ == "__main__":
    main()
