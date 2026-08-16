# Antigravity Agents

> **Eliminate up to ~51% of Antigravity's hidden turn-zero context tax with near-zero loss in functionality.**

Every time you launch a default Google Antigravity session, the platform silently injects **~15,000 input tokens** of verbose tool descriptor schemas, prescriptive web-styling rules, and unused feature manifests before you even write your first prompt.

This repository provides two high-performance, context-disciplined custom agents tailored for maximum token runway while retaining all native Google Antigravity OAuth subscription benefits.

---

### Turn-0 Benchmark (`agy v1.1.13`)

```bash
# Verify programmatically on your own machine:
agy --agent better-agy --output-format json -p "Output 'PONG' and nothing else"
agy --agent lean-agy   --output-format json -p "Output 'PONG' and nothing else"
```

| Agent Configuration | Turn-0 Base Tokens | Context Tax Reduction | Architecture & Trade-Off |
| :--- | :---: | :---: | :--- |
| **Default Antigravity Agent** | `14,999` tokens | Baseline | 16 built-in tools with full schema overhead |
| **`better-agy`** | **`9,572` tokens** | **-5,427 tokens (~36.2% cut)** | 11 tools; retains native IDE subagent orchestration tools & UI panels |
| **`lean-agy`** | **`7,301` tokens** | **-7,698 tokens (~51.3% cut)** | 6 core tools; subagent delegation offloaded to on-demand `agy-subagents` skill |

*(Run the `/context` slash command inside any interactive session to inspect your live breakdown).*

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
* **Pruned (5)**: `list_dir`, `grep_search` (subsumed by shell), `ask_question` (plain chat/artifacts), `generate_image`, `schedule`.

### 2. `lean-agy` (Ultra-Minimal Shell-First + Skill-Driven Subagents)
An ultra-lean agent for maximum context runway. Drops all built-in subagent tool schemas from the system prompt on Turn 0. When delegation or parallelization is needed, it dynamically leverages the `agy-subagents` skill via `run_command`.
* **Tools Kept (6)**: `run_command`, `view_file`, `replace_file_content`, `write_to_file`, `search_web`, `read_url_content`.
* **Pruned (10)**: All subagent orchestration schemas and non-essential tools.

---

## Included Skills

### `agy-subagents`
A recipe-backed skill for orchestrating isolated CLI subagents, multi-turn steerable sessions (`--conversation`), background workers, and isolated git worktrees via `run_command`. Automatically installed and bound to `lean-agy`.

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
