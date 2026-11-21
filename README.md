# Antigravity Agents

> **Cut Turn-0 overhead by up to ~77% and keep multi-turn context lean with a zero-overlap, workflow-first Antigravity harness.**

Modern frontier models don't need walls of prescriptive boilerplate or overlapping delegation tools—they need clean context windows and sharp, non-overlapping primitives. Every default Google Antigravity session injects **~8,700 input tokens** of built-in tool schemas (including 5 overlapping orchestration tools), built-in skill manifests, and redundant prompt sections before your first message—and unconstrained shell output can compound that cost rapidly over a multi-turn session.

This repository provides two purpose-built, context-disciplined custom agents—**`clean`** and **`bare`**—retaining all native Google Antigravity OAuth subscription benefits:

- **`clean`** — Your daily-driver interactive software engineering agent & programmable workflow orchestrator. Keeps full workspace awareness (`AGENTS.md`/`GEMINI.md`, skills, MCP), replaces overlapping native subagent tools with **`run_workflow`** as the single first-class orchestration primitive, and privately bundles its own bare **`worker`** plus scoped skills with **zero global pollution**.
- **`bare`** — Bare-metal leaf executor (`excludeDefaultComponents: true`, `inheritMcp: false`) stripped to the 6 core tools and ~160 tokens of operational principles. Built for headless `-p` / CI automation, CLI subagent workers, and maximum solo context runway.

---

### Turn-0 Benchmark (`agy v1.5.13`)

```bash
# Verify programmatically on your own machine:
agy               --output-format json -p "Output 'PONG' and nothing else"
agy --agent clean --output-format json -p "Output 'PONG' and nothing else"
agy --agent bare  --output-format json -p "Output 'PONG' and nothing else"
```

| Agent Configuration | Turn-0 Base Tokens | Context Tax Reduction | Architecture & Role |
| :--- | :---: | :---: | :--- |
| **Default Antigravity Agent** | `8,676` tokens | Baseline | 14 built-in tools + 11 XML prompt sections + built-in skills & subagents |
| **`clean`** | **`4,401` tokens** | **-4,275 tokens (~49.3% cut)** | 7 non-overlapping tools (6 core + `run_workflow`); full rules/skills/MCP; privately scoped `worker`, `run-workflow`, & `agy-subagents` |
| **`bare`** | **`2,019` tokens** | **-6,657 tokens (~76.7% cut)** | 6 leaf tools; `excludeDefaultComponents: true` + `inheritMcp: false`; zero boilerplate for headless/CI/workers/solo runway |

*(Run `/context` inside any interactive session to inspect your live breakdown.)*

---

## Beyond Turn 0: Through-Session Savings

Turn-0 savings only matter if you don't immediately burn them on Turn 2. Both profiles compound savings across the full session in three ways:

- **Bounding `run_command` and chat dumps (`Context Discipline`)**: Every tool output and reply stays in history and is re-processed on every subsequent turn. `run_command` executes unpaged (`PAGER=cat`) and truncates past ~10 KB (~2.5k–3k tokens), dropping the middle of the output and saving the full stream to disk. Preferring bounded or quiet commands (`git log -n`, `rg -l`, summary flags—without hiding errors or breaking exit codes) and avoiding pasting code blocks or raw diffs of edits already written to disk prevents redundant output from wiping out Turn-0 gains.
- **Fewer round-trips (`Execution Efficiency`)**: Batching independent reads/edits in parallel and chaining shell commands reduces how many times the growing conversation history is re-sent.
- **Compounding fan-out savings (`run_workflow` + bare `worker`)**: Every child agent spawned by `clean`'s `run_workflow` runs on the bare `worker` (~2k Turn-0 tokens) instead of the ~8.7k-token default agent—saving ~6.6k tokens per child (~130k+ tokens in a 20-worker fan-out) while keeping intermediate traces out of the parent context.

---

## 🔍 Verbatim Turn-0 Context, Decisions & Subsets

Both custom agents are strict functional subsets of the `agy v1.5.13` runtime context:

- 📄 **[Turn-0 Context Specification](docs/turn-zero-context.md)**: Verbatim dump and token accounting for all 14 tool parameter schemas and 11 system prompt XML blocks.
- 🧭 **[Philosophy & Decision Records](docs/decisions.md)**: Upgrade evaluation rubric and architectural decision log (`DR-001`–`DR-006`) with revisit triggers.
- 🎨 **[Interactive Turn-0 Overlay](https://eggmasonvalue.github.io/antigravity-agents/)** ([`docs/index.html`](docs/index.html)): Interactive visualizer with segmented toggles to compare verbatim Turn-0 context across `Default`, `clean`, and `bare`.

---

## ⚡ 1-Line Installation

### Linux / macOS
```bash
curl -fsSL https://raw.githubusercontent.com/eggmasonvalue/antigravity-agents/main/scripts/install.sh | bash
```

### Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/eggmasonvalue/antigravity-agents/main/scripts/install.ps1 | iex
```

*(Upgrading from `v0.1`/`v0.2`? The installer automatically removes legacy `better-agy.md`, `lean-agy.md`, and the old global `skills/agy-subagents/` directory so nothing pollutes your Default agent.)*

---

## Included Agents

### 1. `clean` (Daily Driver + Programmable Workflows)
A full Antigravity citizen that drops built-in noise and overlapping delegation tools while retaining workspace rules (`AGENTS.md`/`GEMINI.md`), user/workspace skills, and MCP servers.

- **Tools Kept (7)**: `read_file`, `edit_file`, `write_file`, `run_command`, `manage_task`, `search_web`, `run_workflow`.
- **Pruned (7)**: `invoke_subagent`, `define_subagent`, `send_message`, `manage_subagents`, `swarm`, `schedule`, `ask_question`.
- **Prompt & Skills Trimmed**: Automatically drops `<identity>`, `<conversation_transcript>`, `<work_efficiently>`, `<slash_commands>`, `<subagents>`, and all built-in skills (`agy-customizations`, `antigravity-guide`, `run-workflow`, `swarm_monitor`, `swarm_pane`).
- **Privately Scoped Bundle** (`~/.gemini/config/agents/clean/`):
  - **`worker.md`** (`mainAgent: false`, `subagent: true`, `excludeDefaultComponents: true`, `inheritMcp: false`): A bare-metal leaf worker (~2k tokens/child) invoked via `run_workflow(..., type_name="worker")`. In a 20-agent parallel fan-out, this saves ~130,000+ input tokens compared to the default agent's `type_name="self"`.
  - **`skills/run-workflow/SKILL.md`**: Concise workflow primitive guide instructing `clean` to target `type_name="worker"` and brief workers explicitly with paths and relevant repo rules.
  - **`skills/agy-subagents/SKILL.md`**: On-demand CLI orchestration skill for steerable `--conversation` / `--input-format stream-json` runs or explicit `--model`/`--effort`/`--sandbox` flags (targeting `--agent bare`).

> [!NOTE]
> **Per-Agent Scoping in `agy v1.3.1+`**: Antigravity resolves relative `skills:` and `agents:` paths against the custom agent's own directory (`~/.gemini/config/agents/clean/`). Co-locating `worker.md`, `skills/run-workflow/`, and `skills/agy-subagents/` inside `clean/` scopes them strictly to `clean` with **zero bleed** into the Default agent or `bare`. Both private skills also set `disable-slash-command: true` to keep your `/` menu clean.

### 2. `bare` (Bare-Metal Pure Executor)
An ultra-minimal, deterministic execution substrate using `excludeDefaultComponents: true` and `inheritMcp: false`. Strips all built-in XML sections (`<user_information>`, `<user_rules>`, `<skills>`, `<artifacts>`, `<communication_style>`, `<messaging>`, `<guidelines>`) and replaces only the load-bearing operational mechanics in ~180 tokens (`pwd` path grounding, async no-polling, parallel/chained batching, context discipline).

- **Tools Kept (6)**: `read_file`, `edit_file`, `write_file`, `run_command`, `manage_task`, `search_web`.
- **Ideal For**:
  - Headless `-p` / CI scripts and `--json-schema` structured extraction.
  - Ultra-cheap leaf worker target for `agy-subagents` (`agy --agent bare -p ...`).
  - Maximum-runway solo debugging and large refactors with zero ambient prompt bias.

---

## Maintainer Skill

### `agent-maintenance` (Repo-Local)
Located in [`.agents/skills/agent-maintenance/SKILL.md`](.agents/skills/agent-maintenance/SKILL.md) (not installed globally). Audits live tool declarations, frontmatter behavior, scoping isolation, end-to-end workflow smoke tests, Turn-0 benchmarks, and docs sync after `agy` upgrades.

---

## Usage

Launch directly as your primary session agent:
```bash
# Daily-driver coding & programmable workflows
agy --agent clean

# Bare-metal solo / headless / scripted execution
agy --agent bare
agy --agent bare --output-format json -p "Audit the staged git diff for bugs."
```
Or switch between `clean` and `bare` via the interactive `/agents` panel inside the CLI.

---

## Local Development & Testing

Install from a local checkout:
- **Linux / macOS**: `./scripts/install.sh --local`
- **Windows**: `.\scripts\install.ps1 -Local`
