---
name: mermaid_diagram_design
description: Guidelines and architectural contracts for designing responsive, visually balanced, multi-line Mermaid diagrams that fit cleanly on standard screens without shrinking text.
---

# Mermaid Diagram Design & Responsive Layout Skill

This skill enforces best practices for authoring **Mermaid diagrams** (flowcharts, state machines, sequence diagrams, and architecture blueprints) across all repository documentation and the Dev Hub portal.

---

## 1. When to Use & Negative Routing

### Positive Triggers (Activate this skill when:)
- Writing or editing Mermaid diagrams in Markdown files (`README.md`, `docs/**/*.md`, `config/blueprints/README.md`).
- Designing architecture flowcharts, decision trees, or sequence diagrams.
- Fixing unreadable, shrunk, or micro-font diagrams on laptop screens (13"–16").
- Fixing horizontal sprawl or layout overflow in Mermaid diagrams.
- Developing dynamic Mermaid diagram generators in Python (`scripts/internal/dev_hub/topology.py`).
- Resolving SVG text clipping or line-height expansion inside `<foreignObject>`.

### Negative Routing (What NOT to do here:)
| Request / Intent | Do NOT handle here | Route to Skill |
|---|---|---|
| Editing Dev Hub web assets or UI layout | `devhub_architecture` | Use [devhub_architecture](file:///.agents/skills/devhub_architecture/SKILL.md) |
| Defining blueprint components or port assignments | `blueprints_and_topology` | Use [blueprints_and_topology](file:///.agents/skills/blueprints_and_topology/SKILL.md) |
| Managing container lifecycle or Docker/Podman compose | `oracle_containers` | Use [oracle_containers](file:///.agents/skills/oracle_containers/SKILL.md) |
| Writing APEX application specifications or data models | `apexlang_app_generation` | Use [apexlang_app_generation](file:///.agents/skills/apexlang_app_generation/SKILL.md) |

---

## 2. Decision Diamond Formatting Contract (`{...}`)

> [!IMPORTANT]
> **Multi-Line Decision Diamonds are Mandatory:**
> Text inside decision diamonds (`{...}` or `{"..."}`) **MUST NEVER be written as a single long line**.

1. **Line Length Limit:**
   - Any single line segment inside a diamond MUST NOT exceed **25–28 characters**.
2. **Multi-Line Splitting (`<br/>`):**
   - Questions and conditions must be broken into **2 to 4 concise lines** using `<br/>` tags.
   - Example:
     ```mermaid
     %% BAD (stretches diamond horizontally and ruins proportions):
     CheckSnap{"Kas lokaalne snapshot on olemas ja versioon klapib?"}

     %% GOOD (compact, balanced, readable):
     CheckSnap{"Kas lokaalne snapshot<br/>on olemas ja<br/>versioon klapib?"}
     ```
3. **Quoting Invariant:**
   - Text containing numbers, spaces, colons, or `<br/>` MUST be enclosed in double quotes: `NodeId{"Line 1<br/>Line 2"}`.

4. **Maximum Vertical Node Density (Max 3–4 Lines per Box):**
   - Boxes (`[...]`, `(...)`, `[(...)]`) **MUST NOT contain more than 4 lines of text** (max 3 `<br/>` tags).
   - **Prohibition of In-Box Bullet Point Dumping:** Never dump 5+ bulleted specification lines or full descriptions into a single diagram node.
   - Keep node labels concise (system name, port, core function). Detailed narrative lists belong in markdown tables below the diagram.

---

## 3. Responsive Screen Width & Font Scaling Contract

When Mermaid renders diagrams inside web browsers or documentation viewers, the entire SVG is scaled to fit the width of the parent container. **Excessively wide horizontal diagrams cause SVG scaling to shrink text to a microscopic, unreadable size.**

To prevent unreadable, tiny fonts on laptops and tablets (13"–16" screens):

1. **Limit Nodes per Horizontal Row:**
   - In horizontal flowcharts (`direction LR`), DO NOT chain more than **3 to 4 nodes in a single row**.
   - When a process has 5 or more sequential steps:
     - Prefer **Top-to-Bottom flow (`flowchart TB` or `direction TB`)**.
     - Or wrap steps into a 2D grid using labeled `subgraph` blocks (e.g. 2–3 nodes per row).
2. **Node Box Proportions (`[...]`, `(...)`, `[(...)]`):**
   - Long labels must be broken into 2–3 lines using `<br/>` tags.
   - Maximum recommended line length inside boxes: **30–35 characters**.
   - Example:
     ```mermaid
     %% BAD (causes extreme horizontal width):
     Step4["Samm 4: Genereeri Podman Secrets (/run/secrets/) ja käivita compose"]

     %% GOOD (compact and readable):
     Step4["Samm 4: Genereeri Podman Secrets<br/>(/run/secrets/) ja käivita compose"]
     ```
3. **Avoid Giant Single-Line Text Blocks in Subgraph Titles:**
   - Keep subgraph titles concise (under 40 characters) or use `<br/>` when necessary.

4. **Subgraph Grid Layout & Multi-Tier Architecture (Preventing Horizontal Sprawl):**
   - **Limit Parallel Sibling Subgraphs:** Do not place more than **2 to 3 subgraphs** in parallel horizontally.
   - **Internal Direction (`direction TB`):** Any multi-node subgraph containing 3 or more nodes must declare `direction TB` or link its nodes vertically so Dagre stacks them vertically instead of spreading them into a 1500px+ horizontal line.
   - **2x2 Multi-Tier Pattern:** When displaying multiple subsystem groups (such as 4 architecture tiers or groups):
     - Wrap them into rows using tier subgraphs (e.g. `subgraph Tier1 ["ROW 1: ..."]` and `subgraph Tier2 ["ROW 2: ..."]`), or
     - Link upper-tier nodes to lower-tier nodes (`Tier1_Node --> Tier2_Node`) rather than fanning out 4+ parallel arrows from a single root node.
     - Example:
       ```mermaid
       flowchart TD
           subgraph Default ["⭐ CANONICAL DEFAULT"]
               BP0["BP 0: Core Stack"]
           end

           subgraph Tier1 ["ROW 1: CORE ARCHITECTURE (1–7)"]
               subgraph Group1 ["🗄️ GROUP 1 (1–4)"]
                   direction TB
                   BP1["BP 1"]
                   BP2["BP 2"]
               end
               subgraph Group2 ["🏢 GROUP 2 (5–7)"]
                   direction TB
                   BP5["BP 5"]
                   BP6["BP 6"]
               end
           end

           subgraph Tier2 ["ROW 2: EXTENSIONS & EDGE (8–11)"]
               subgraph Group3 ["💻 GROUP 3 (8–9)"]
                   direction TB
                   BP8["BP 8"]
                   BP9["BP 9"]
               end
               subgraph Group4 ["🌐 GROUP 4 (10–11)"]
                   direction TB
                   BP10["BP 10"]
                   BP11["BP 11"]
               end
           end

           BP0 --> BP1
           BP0 --> BP5
           BP1 --> BP8
           BP5 --> BP10
       ```

5. **CSS Line-Height Containment Contract (Preventing Vertical Clipping):**
   - In web portals and documentation viewers, diagrams must be rendered inside containers enforcing:
     ```css
     .mermaid-render-target svg foreignObject div,
     .mermaid-render-target svg .label,
     .mermaid-render-target svg .node text {
         line-height: 1.25 !important;
         font-family: inherit;
     }
     ```
   - Uncontained document line-heights (e.g. `1.6` or `1.7`) cause multi-line node text inside `<foreignObject>` to expand by 35–45% vertically, pushing the bottom lines outside the fixed SVG `<rect>` boundaries.

---

## 4. High-Contrast Semantic Flow & Branching

1. **Explicit Connector Labels:**
   - All decision branches must feature clear, high-contrast labels:
     - `-->|JAH / Kehtiv|` vs `-->|EI / Puudub|`
     - `-->|Success|` vs `-->|Fallback|`
2. **Logical Subgraphs:**
   - Group related steps into clean, semantic `subgraph` clusters (e.g. `subgraph "1. Eeltööd"`, `subgraph "2. Paigaldus"`, `subgraph "3. Verifitseerimine"`).
3. **Style Classes for Visual Hierarchy:**
   - Use standard CSS classes or Mermaid style declarations (`classDef`) for:
     - Primary / entry nodes (high contrast).
     - Automated steps (subtle borders).
     - Fallback / error paths (warning colors).

---

## 5. Operational Playbooks & Step-by-Step Execution

### 5.1 Verifying Diagram Compliance Across Codebase
Run the automated layout & character-count verification script:
```bash
./tests/unit/test-devhub-mermaid-rendering.sh
```
What it checks:
- Scans all `.md` files in `docs/` and `config/blueprints/`.
- Validates that decision diamonds `{...}` do not exceed 28 characters per line.
- Validates that box nodes `[...]` do not exceed 38 characters per line.
- Ensures all diagram syntax parses cleanly.

### 5.2 Dynamic Blueprint Diagram Generation
Mermaid diagrams for the 12 architecture blueprints are compiled dynamically:
```bash
python3 -c "from scripts.internal.dev_hub.topology import generate_all_blueprint_diagrams; print('OK')"
```

---

## 6. Prohibited Anti-Patterns

- ❌ **Single-Line Long Decision Diamonds:** Never write `{Long question exceeding 28 characters}` without `<br/>` tags.
- ❌ **Horizontal Sprawl (`direction LR` with > 4 nodes):** Never chain 5+ nodes in a horizontal row, which forces SVG zoom out and makes font size microscopic (< 8px).
- ❌ **Bullet Point Dumping Inside Diagram Nodes:** Never dump 5+ bulleted lines into a single box node. Put detailed lists into Markdown tables below the diagram.
- ❌ **Static DOM IDs in Async Mermaid Rendering:** In JavaScript, never render with static DOM IDs like `mermaid-svg`. Always use randomized IDs (`mermaid-${Date.now()}-${Math.random()}`).
- ❌ **Uncontained Container Line-Height:** Never omit `line-height: 1.25 !important;` on `.label` / `foreignObject div`.

---

## 7. Diagnostic Signatures & 1-Line Remedies

| Symptom / Error | Root Cause | 1-Line Remediation |
|---|---|---|
| Microscopic, unreadable text on 13"–15" laptop screens | Diagram too wide horizontally (`direction LR` or > 4 parallel nodes) | Switch to `direction TB` or wrap nodes into 2-column `subgraph` tiers. |
| Diamond stretched wide with disproportionate shape | Diamond line length > 28 chars | Insert `<br/>` every 20–25 chars and enclose label in double quotes `{"..."}`. |
| Node text clipped at bottom of box rect | Document `line-height` (`1.6`+) expands text outside SVG `<rect>` | Apply `line-height: 1.25 !important;` to `.mermaid-render-target svg foreignObject div`. |
| `Syntax error in graph` on node with colon or brackets | Special characters unescaped or unquoted | Enclose node label in double quotes: `Node["Key: Value (Detail)"]`. |
| Mermaid v10 re-render displays stale or corrupted SVG | Reusing identical DOM ID in `mermaid.render()` | Pass unique randomized SVG ID on every render: `render("svg-" + uuid(), code)`. |
