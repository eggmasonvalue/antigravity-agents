# Antigravity Agents

Curated, context-disciplined custom agents for Google Antigravity (`agy`).

**Baseline Target**: `agy v1.1.13`

---

## Installation

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
- **Mechanism**: Drastically cuts per-turn token overhead by stripping unused tool descriptor schemas from the context window (16 default tools pruned down to 11 essential tools) and enforcing strict output-bounding discipline.
- **Tools (11)**: `run_command`, `view_file`, `replace_file_content`, `write_to_file`, `search_web`, `read_url_content`, `invoke_subagent`, `define_subagent`, `send_message`, `manage_subagents`, `manage_task`.
- **Pruned (5)**: `ask_question`, `list_dir`, `grep_search`, `generate_image`, `schedule`.

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
