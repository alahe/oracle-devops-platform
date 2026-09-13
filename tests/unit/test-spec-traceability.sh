#!/usr/bin/env bash
# ==============================================================================
# Unit Test: Spec-Driven Development (SDD), SCS & Assembly Line Traceability
# Enforces Rules 17, 18, and 19:
# 1. Spec Triad integrity (requirements.md, design.md, tasks.md)
# 2. Template verification (docs/specs/templates/)
# 3. Requirement ID uniqueness & Contradiction Analysis
# 4. SCS Bounded Context & Architecture in design.md
# 5. Requirement-to-Task Traceability Matrix in tasks.md
# 6. Session Trails & Intent logging in .agents/trails/
# 7. AI Skill & Governance Rules 17, 18, 19 in .agents/AGENTS.md
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "📋 Testing Spec-Driven Development (SDD) & SCS Traceability..."

# 1. Verify Templates
echo "  [1/7] Verifying canonical SDD templates in docs/specs/templates/..."
TEMPLATES_DIR="$WORKSPACE_DIR/docs/specs/templates"
if [ ! -d "$TEMPLATES_DIR" ]; then
  echo "❌ Error: Templates directory docs/specs/templates does not exist!"
  exit 1
fi

REQUIRED_TEMPLATES=("requirements.template.md" "design.template.md" "tasks.template.md")
for tmpl in "${REQUIRED_TEMPLATES[@]}"; do
  if [ ! -f "$TEMPLATES_DIR/$tmpl" ]; then
    echo "❌ Error: Missing required template $TEMPLATES_DIR/$tmpl"
    exit 1
  fi
done
echo "    ✓ All 3 canonical templates verified"

# 2. Verify Domain Specifications Triad
echo "  [2/7] Auditing domain specifications in docs/specs/..."
SPECS_DIR="$WORKSPACE_DIR/docs/specs"
DOMAIN_COUNT=0

for domain_dir in "$SPECS_DIR"/*; do
  if [ -d "$domain_dir" ] && [ "$(basename "$domain_dir")" != "templates" ]; then
    DOMAIN_NAME="$(basename "$domain_dir")"
    DOMAIN_COUNT=$((DOMAIN_COUNT + 1))
    
    echo "    -> Auditing domain spec: $DOMAIN_NAME"
    
    # Must have requirements.md, design.md, tasks.md
    for f in requirements.md design.md tasks.md; do
      if [ ! -f "$domain_dir/$f" ]; then
        echo "❌ Error: Domain '$DOMAIN_NAME' missing required file: $f"
        exit 1
      fi
    done
    
    # Size check (< 500 lines to ensure AI context window efficiency per Martinelli)
    for f in requirements.md design.md tasks.md; do
      LINE_COUNT=$(wc -l < "$domain_dir/$f" | tr -d ' ')
      if [ "$LINE_COUNT" -gt 600 ]; then
        echo "⚠️ Warning: $DOMAIN_NAME/$f is $LINE_COUNT lines (Martinelli SCS context guideline recommends < 300-500 lines)"
      fi
    done
  fi
done

if [ "$DOMAIN_COUNT" -eq 0 ]; then
  echo "❌ Error: No domain specifications found under docs/specs/!"
  exit 1
fi
echo "    ✓ Verified $DOMAIN_COUNT domain specification(s)"

# 3. Verify Requirement IDs & Contradiction Analysis
echo "  [3/7] Auditing requirement IDs and Contradiction Analysis..."
for domain_dir in "$SPECS_DIR"/*; do
  if [ -d "$domain_dir" ] && [ "$(basename "$domain_dir")" != "templates" ]; then
    REQ_FILE="$domain_dir/requirements.md"
    
    # Check for REQ- IDs
    REQ_IDS=$(grep -oE 'REQ-[A-Z0-9_-]+' "$REQ_FILE" | sort | uniq || true)
    if [ -z "$REQ_IDS" ]; then
      echo "❌ Error: No [REQ-...] IDs found in $REQ_FILE"
      exit 1
    fi
    
    # Check for duplicate REQ definitions (headers)
    DUPES=$(grep -E '^###.*\[REQ-[A-Z0-9_-]+\]' "$REQ_FILE" | sed -E 's/.*\[(REQ-[A-Z0-9_-]+)\].*/\1/' | sort | uniq -d || true)
    if [ -n "$DUPES" ]; then
      echo "❌ Error: Duplicate requirement definitions found in $REQ_FILE: $DUPES"
      exit 1
    fi
    
    # Check for Contradiction Analysis (Wood SDD core requirement)
    if ! grep -qiE "Contradiction.*Analysis" "$REQ_FILE" && ! grep -qi "Vastuolude" "$REQ_FILE"; then
      echo "❌ Error: Missing Contradiction Analysis section in $REQ_FILE (Rule 17 invariant)"
      exit 1
    fi
  fi
done
echo "    ✓ Requirement IDs unique and Contradiction Analysis present"

# 4. Verify SCS Bounded Context & Architecture in design.md
echo "  [4/7] Auditing SCS boundaries and Architecture diagrams..."
for domain_dir in "$SPECS_DIR"/*; do
  if [ -d "$domain_dir" ] && [ "$(basename "$domain_dir")" != "templates" ]; then
    DESIGN_FILE="$domain_dir/design.md"
    
    # Check for SCS / Bounded Context
    if ! grep -qi "Self-Contained System" "$DESIGN_FILE" && ! grep -qi "Bounded Context" "$DESIGN_FILE"; then
      echo "❌ Error: Missing Self-Contained System / Bounded Context definition in $DESIGN_FILE (Rule 18 invariant)"
      exit 1
    fi
    
    # Check for Mermaid architecture diagram
    if ! grep -q '```mermaid' "$DESIGN_FILE"; then
      echo "❌ Error: Missing Mermaid architecture diagram in $DESIGN_FILE"
      exit 1
    fi
    
    # Check for Zero-Trust or Wallet security definition
    if ! grep -qi "Zero-Trust" "$DESIGN_FILE" && ! grep -qi "Wallet" "$DESIGN_FILE"; then
      echo "❌ Error: Missing Zero-Trust / Wallet security architecture in $DESIGN_FILE (Rule 5 & 18)"
      exit 1
    fi
  fi
done
echo "    ✓ SCS boundaries, Mermaid diagrams, and Zero-Trust architecture verified"

# 5. Verify Traceability Matrix in tasks.md
echo "  [5/7] Auditing Traceability Matrix and Ralph Loop verification..."
for domain_dir in "$SPECS_DIR"/*; do
  if [ -d "$domain_dir" ] && [ "$(basename "$domain_dir")" != "templates" ]; then
    TASKS_FILE="$domain_dir/tasks.md"
    REQ_FILE="$domain_dir/requirements.md"
    
    # Check for Traceability Matrix header
    if ! grep -qi "Traceability Matrix" "$TASKS_FILE" && ! grep -qi "Jälgitavuse maatriks" "$TASKS_FILE"; then
      echo "❌ Error: Missing Traceability Matrix in $TASKS_FILE (Rule 17 invariant)"
      exit 1
    fi
    
    # Verify that defined REQs appear in tasks.md
    DEFINED_REQS=$(grep -E '^###.*\[REQ-[A-Z0-9_-]+\]' "$REQ_FILE" | sed -E 's/.*\[(REQ-[A-Z0-9_-]+)\].*/\1/' || true)
    for req in $DEFINED_REQS; do
      if ! grep -q "$req" "$TASKS_FILE"; then
        echo "❌ Error: Requirement $req from $REQ_FILE is not mapped in $TASKS_FILE traceability matrix!"
        exit 1
      fi
    done
    
    # Check for Ralph Loop instructions
    if ! grep -qi "Ralph Loop" "$TASKS_FILE" && ! grep -qi "Autonomous Loop" "$TASKS_FILE"; then
      echo "❌ Error: Missing Ralph Loop instructions in $TASKS_FILE (Rule 19 invariant)"
      exit 1
    fi
  fi
done
echo "    ✓ Full requirement-to-task traceability and Ralph Loop verified"

# 6. Verify Session Trails in .agents/trails/
echo "  [6/7] Auditing Agent Session Trails (.agents/trails/)..."
TRAILS_DIR="$WORKSPACE_DIR/.agents/trails"
if [ ! -d "$TRAILS_DIR" ]; then
  echo "❌ Error: .agents/trails directory does not exist!"
  exit 1
fi

if [ ! -f "$TRAILS_DIR/README.md" ]; then
  echo "❌ Error: Missing .agents/trails/README.md"
  exit 1
fi

TRAIL_FILES=$(find "$TRAILS_DIR" -maxdepth 1 -type f -name "*.md" ! -name "README.md" | wc -l | tr -d ' ')
if [ "$TRAIL_FILES" -eq 0 ]; then
  echo "❌ Error: No session trail files found in .agents/trails/!"
  exit 1
fi

# Verify at least one trail contains intent and evaluation gates
LATEST_TRAIL=$(find "$TRAILS_DIR" -maxdepth 1 -type f -name "*.md" ! -name "README.md" | sort | tail -n 1)
if ! grep -qi "intent" "$LATEST_TRAIL"; then
  echo "❌ Error: Latest trail $LATEST_TRAIL missing 'intent' declaration (Rule 19 invariant)"
  exit 1
fi

if ! grep -qiE "Evaluation Gates|Quality Gates|Release Gates|Kvaliteediväravad" "$LATEST_TRAIL"; then
  echo "❌ Error: Latest trail $LATEST_TRAIL missing 5 Quality Evaluation Gates (Rule 19 invariant)"
  exit 1
fi
echo "    ✓ Verified $TRAIL_FILES session trail(s) with Intent & 5 Quality Gates"

# 7. Verify Governance Rules in .agents/AGENTS.md & Skill
echo "  [7/7] Auditing Governance Rules 17-19 and AI Skill..."
AGENTS_FILE="$WORKSPACE_DIR/.agents/AGENTS.md"
if ! grep -q "17. Spec-Driven Development" "$AGENTS_FILE"; then
  echo "❌ Error: Rule 17 missing from .agents/AGENTS.md"
  exit 1
fi

if ! grep -q "18. Self-Contained Systems" "$AGENTS_FILE"; then
  echo "❌ Error: Rule 18 missing from .agents/AGENTS.md"
  exit 1
fi

if ! grep -q "19. Agentic Assembly Line" "$AGENTS_FILE"; then
  echo "❌ Error: Rule 19 missing from .agents/AGENTS.md"
  exit 1
fi

SKILL_FILE="$WORKSPACE_DIR/.agents/skills/sdd_assembly_line/SKILL.md"
if [ ! -f "$SKILL_FILE" ]; then
  echo "❌ Error: Missing AI Skill $SKILL_FILE"
  exit 1
fi
echo "    ✓ Governance Rules 17, 18, 19 and sdd_assembly_line skill verified"

echo "=================================================================="
echo "✅ ALL SPEC-DRIVEN DEVELOPMENT & ASSEMBLY LINE AUDITS PASSED!"
echo "=================================================================="
exit 0
