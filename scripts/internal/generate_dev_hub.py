#!/usr/bin/env python3
"""
==============================================================================
Oracle DevOps Platform - Developer Hub (SPA) HTML Generator
CLI Orchestrator & Backward Compatibility Wrapper
==============================================================================
"""
import os
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
if SCRIPT_DIR not in sys.path:
    sys.path.insert(0, SCRIPT_DIR)

# Re-export key components for backward compatibility
from dev_hub.catalog import BP_CATALOG, DOC_SPECS, BP_COLOR_THEMES, SLIDES_CONTENT
from dev_hub.topology import load_yaml_profile, generate_active_blueprint_mermaid
from dev_hub.parser import parse_blueprint_env_and_metadata
from dev_hub.diagnostics import load_all_passwords, load_benchmarks_and_logs, get_ords_version
from dev_hub.compiler import build_dev_hub

WORKSPACE_DIR = os.path.abspath(os.path.join(SCRIPT_DIR, "../.."))
OUTPUT_FILE = sys.argv[1] if len(sys.argv) > 1 else os.path.join(WORKSPACE_DIR, "docs/dev-hub.html")

if __name__ == "__main__":
    build_dev_hub(OUTPUT_FILE, WORKSPACE_DIR)
