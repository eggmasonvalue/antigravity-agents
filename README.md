# Antigravity Agents

> **Eliminate up to ~70% of Antigravity's hidden turn-zero context tax with near-zero loss in functionality.**

Every time you launch a default Google Antigravity session, the platform silently injects **~14,000 input tokens** of verbose tool descriptor schemas, prescriptive web-styling rules, and unused feature manifests before you even write your first prompt.

This repository provides two high-performance, context-disciplined custom agents tailored for maximum token runway while retaining all native Google Antigravity OAuth subscription benefits.

---

### Turn-0 Benchmark (`agy v1.2.2`)

```bash
# Verify programmatically on your own machine:
agy --agent better-agy --output-format json -p "Output 'PONG' and nothing else"
agy --agent lean-agy   --output-format json -p "Output 'PONG' and nothing else"
```

| Agent Configuration | Turn-0 Base Tokens | Context Tax Reduction | Architecture & Trade-Off |
| :--- | :---: | :---: | :--- |
| **Default Antigravity Agent** | `13,728` tokens | Baseline | 17 built-in tools with full schema overhead + default boilerplate |
| **`better-agy`** | **`6,196` tokens** | **-7,532 tokens (~54.9% cut)** | 11 tools; retains native IDE subagent orchestration tools & UI panels; excludes prompt boilerplate |
| **`lean-agy`** | **`4,078` tokens** | **-9,650 tokens (~70.3% cut)** | 6 core tools; excludes prompt boilerplate; subagent delegation offloaded to on-demand `agy-subagents` skill |

*(Run the `/context` slash command inside any interactive session to inspect your live breakdown).*

---

## 🔍 Turn-0 Context Transparency & Interactive Overlay

Both custom agents are **strict functional subsets** of the default Antigravity agent. To inspect every prompt section and tool schema retained or pruned:

- 📄 **[Turn-0 Context Breakdown Guide](docs/turn-zero-context.md)**: A complete markdown matrix comparing all 17 tools and prompt sections, with detailed rationale addressing user anxiety.
- 🎨 **[Interactive Turn-0 Overlay (HTML)](docs/turn-zero-context.html)**: A single-page, color-coded visualizer where you can toggle between the Default baseline and overlays for `better-agy` and `lean-agy` to see exactly what remains active and what is pruned.

---

## ⚡ 1-Line Installation

### Linux
```bash
curl -fsSL https://raw.githubusercontent.com/eggmasonvalue/antigravity-agents/main/scripts/install.sh | bash
```

### Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/eggmasonvalue/antigravity-agents/main/scripts/install.ps1 | iex
```

---

## Included Agents

### 1. `better-agy` (Balanced + UI Subagents)
A lightweight software engineering agent for users who want token savings while keeping native subagent tools and IDE side-panel integration.
* **Tools Kept (11)**: `run_command`, `view_file`, `replace_file_content`, `write_to_file`, `search_web`, `read_url_content`, `invoke_subagent`, `define_subagent`, `send_message`, `manage_subagents`, `manage_task`.
* **Pruned (6)**: `list_dir`, `grep_search`, `find_by_name` (subsumed by shell), `ask_question` (plain chat), `generate_image`, `schedule`.
* **System Prompt**: Uses `excludeDefaultComponents: true` to prune ~3,000 tokens of verbose formatting rules.

### 2. `lean-agy` (Ultra-Minimal Shell-First + Skill-Driven Subagents)
An ultra-lean agent for maximum context runway. Drops all built-in subagent tool schemas from the system prompt on Turn 0. When delegation or parallelization is needed, it dynamically leverages the `agy-subagents` skill via `run_command`.
* **Tools Kept (6)**: `run_command`, `view_file`, `replace_file_content`, `write_to_file`, `search_web`, `read_url_content`.
* **Pruned (11)**: All subagent orchestration schemas and non-essential tools.
* **System Prompt**: Uses `excludeDefaultComponents: true` to prune ~3,000 tokens of verbose formatting rules.

---

## Included Skills

### `agy-subagents`
A recipe-backed skill for orchestrating isolated CLI subagents, multi-turn steerable sessions (`--conversation`), background workers, and isolated git worktrees via `run_command`.

> [!NOTE]
> **Skill Scoping in Antigravity**: Antigravity discovers and registers skills globally (`~/.gemini/config/skills/`) or per-workspace (`.agents/skills/`) across all active agent profiles (including `better-agy` and the default agent), as the platform does not currently support per-agent skill scoping or frontmatter filtering. However, thanks to **progressive disclosure**, only the skill name and short description are injected on Turn 0 (~50 tokens), avoiding the heavy ~2,000+ token tax of native subagent tool schemas.

### `agent-maintenance`
An audit and synchronization skill to review and update agent configurations following `agy` CLI version upgrades or tool schema adjustments.

---

## Usage

Launch directly as your primary session agent:
```bash
# Launch balanced agent
agy --agent better-agy

# Launch ultra-minimal agent
agy --agent lean-agy
```
Or select either agent via the interactive `/agents` panel inside the CLI.

---

## Local Development & Testing

To test or install from a local checkout:
- **Linux**: `./scripts/install.sh --local`
- **Windows**: `.\scripts\install.ps1 -Local`
