# Antigravity Agents

> **Eliminate ~36% of Antigravity's hidden turn-zero context tax with near-zero loss in functionality.**

Every time you launch a default Google Antigravity session, the platform silently injects **~15,000 input tokens** of verbose tool descriptor schemas, prescriptive web-styling rules, and unused feature manifests before you even write your first prompt.

`better-agy` strips **5,400+ tokens of schema bloat on Turn 0 alone** by pruning redundant tools down to a high-signal, shell-first toolkit. You lose virtually zero real-world capability: filesystem searches and directory listings are handled more powerfully via the shell (`rg`, `fd`, `dir`), questions are asked directly in chat, and non-coding media generators are eliminated. Meanwhile, surgical code edits, atomic file writes, live web retrieval, rich interactive artifacts, and full subagent orchestration remain 100% intact.

Combined with strict context-discipline principles, these token savings compound across every turn of your workflow—delivering faster model responses, lower token consumption, and significantly longer conversation runway while retaining all native Google Antigravity OAuth subscription benefits.

---

### Turn-0 Benchmark (`agy v1.1.13`)

```bash
# Verify it yourself programmatically:
agy --agent better-agy --output-format json -p "Output 'PONG' and nothing else"
```

| Agent Configuration | Turn-0 Base Tokens | Overhead Reduction | Real-World Capability Loss |
| :--- | :--- | :--- | :--- |
| **Default Antigravity Agent** | `14,999` tokens | Baseline | — |
| **`better-agy`** | **`9,572` tokens** | **-5,427 tokens (~36.2% cut)** | **Zero (subsumed by shell/chat)** |

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

### `better-agy`
A lightweight, shell-first software engineering agent.
- **Mechanism**: Strips heavy, unused tool descriptor schemas from the context window (16 default tools pruned down to 11 essential tools) and enforces strict output bounding.
- **Tools Kept (11)**: `run_command`, `view_file`, `replace_file_content`, `write_to_file`, `search_web`, `read_url_content`, `invoke_subagent`, `define_subagent`, `send_message`, `manage_subagents`, `manage_task`.
- **Tools Pruned (5)**:
  - `list_dir`, `grep_search` $\rightarrow$ natively subsumed by `run_command` (`Get-ChildItem`, `rg`, `fd`, `dir`).
  - `ask_question` $\rightarrow$ replaced by natural chat and interactive artifact reviews.
  - `generate_image`, `schedule` $\rightarrow$ non-essential coding overhead removed.

---

## Usage

Launch directly as your primary session agent:
```bash
agy --agent better-agy
```
Or select it via the interactive `/agents` panel inside the CLI.

---

## Local Development & Maintenance

To test or install from a local checkout:
- **Linux**: `./scripts/install.sh --local`
- **Windows**: `.\scripts\install.ps1 -Local`

To audit and update agents following `agy` version bumps, reference the workspace skill at `.agents/skills/agent-maintenance/SKILL.md`.
