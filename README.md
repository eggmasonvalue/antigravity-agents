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
| **`better-agy`** | **`6,259` tokens** | **-7,469 tokens (~54.4% cut)** | 11 tools; retains native IDE subagent orchestration tools & UI panels; excludes prompt boilerplate |
| **`lean-agy`** | **`4,141` tokens** | **-9,587 tokens (~69.8% cut)** | 6 core tools; excludes prompt boilerplate; subagent delegation offloaded to on-demand `agy-subagents` skill |

*(Run the `/context` slash command inside any interactive session to inspect your live breakdown).*

---

## 🔍 Verbatim Turn-0 Context & Subsets

Both custom agents are **strict functional subsets** of the default Antigravity runtime context:

- 📄 **[Turn-0 Context Specification](docs/turn-zero-context.md)**: Verbatim dump and token accounting for all 17 tool parameter schemas and system prompt XML blocks.
- 🎨 **[Interactive Turn-0 Overlay](https://eggmasonvalue.github.io/antigravity-agents/)** ([`docs/index.html`](docs/index.html)): Interactive visualizer with segmented toggles to inspect verbatim Turn-0 context and active/pruned subsets across all three profiles.

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

## 🛡️ Beyond Turn 0: Through-Session Economics & Why The Principles Earn Their Place

While Turn-0 optimization slashes initial overhead by up to **~70%**, Turn-0 savings are only the opening salvo. In interactive coding sessions, **context is cumulative**: every token emitted by tool calls and agent responses is permanently appended to the conversation history and re-processed as input tokens on every subsequent turn.

To prevent context runway from decaying over multi-turn interactions, both `better-agy` and `lean-agy` inject two tightly formulated directives under `# Principles`: **Context Discipline** and **Direct Communication**.

### 1. The Anatomy of Tool Output & The `run_command` Vulnerability

Antigravity's runtime features strict, hardcoded guardrails on its dedicated inspection tools:
- **`view_file`**: Hard-capped at 800 lines and 46,080 bytes (~45 KB) per call, with explicit slice parameters (`StartLine`, `EndLine`, `ContentOffset`).
- **`grep_search`**: Hard-capped at 50 matches.
- **`find_by_name`**: Hard-capped at 50 matches.

**By contrast, `run_command` has NO context-defensive design for synchronous shell execution.**
Unlike resilient agent tool runners that aggressively truncate command outputs (e.g., retaining only the first/last 50 lines) and automatically redirect the complete stream to a scratch log file on disk (`[Output truncated. Full log saved to /tmp/...]`), Antigravity's `run_command` has **no automatic truncation and no automatic log redirection** when a command completes synchronously within `WaitMsBeforeAsync`.

Furthermore, Antigravity forces `PAGER=cat` on every shell command. Terminal tools that normally paginate to protect terminal buffers (e.g., `git log`, `git diff`, test runners, package managers) will dump their entire unabridged output straight into stdout. 

**The Gemini Model Blindspot**: Foundation models (including Gemini) are pre-trained across diverse tool benchmarks and virtual environments where pagers, auto-truncators, or sandbox monitors safely buffer terminal overflows. Consequently, **Gemini models are not inherently mindful of Antigravity's missing safety harness**. Left unprompted, an agent will reflexively execute unadorned commands (`npm test`, `cargo build`, `pytest`, `git log`, or wide `grep` searches), expecting the environment to handle pagination or truncation—only to have thousands of lines of verbose terminal output dumped straight into the conversation history as a tool response.

### 2. The Compounding Math of Through-Session Context Pollution

Because conversation history is re-sent on every subsequent turn, the true cost of unmetered output is **multiplied across the remaining session life**:

$$\text{Cumulative Token Cost} = \text{Output Tokens} \times (\text{Total Session Turns} - \text{Turn of Execution})$$

- **The Math in Practice**: An agent runs an unconstrained `git log` or build command on **Turn 3** that dumps **5,000 tokens** of output into context. In a typical 25-turn session:
  $$\text{Waste} = 5,000 \text{ tokens} \times (25 - 3) = \mathbf{110,000\text{ tokens}}$$
A single unmetered command obliterates the entire 9,650 Turn-0 token saving by more than **11×**, crowding out model reasoning capacity, inducing attention degradation ("needle in a haystack" loss), and triggering premature context exhaustion.

### 3. The "Pruning Paradox": Why Tool Pruning Demands Behavioral Guardrails

To achieve massive Turn-0 reductions, `better-agy` and `lean-agy` deliberately prune redundant discovery tools (`grep_search`, `find_by_name`, `list_dir`), routing all searches and listings through `run_command` (`grep`/`rg`, `find`/`fd`, `ls`).

**The Paradox**: The pruned built-in tools had hardcoded 50-match safety caps; raw shell commands have **none**. 

If you prune the guarded tools without providing cognitive guardrails, an agent will run unconstrained commands (`find .`, `grep -rn "TODO" .`) across large codebases, generating far more context bloat than the pruned tools ever would. **`Context Discipline` is the behavioral guardrail that replaces the hardcoded safety caps of the pruned tools without paying their Turn-0 schema overhead.**

### 4. Scope: It Applies Beyond `run_command` Too

While `run_command` is the highest-risk unmetered pipe, `Context Discipline` governs the agent's entire operational footprint:
- **Shell Execution (`run_command`)**: Pipe outputs (`| head -n 30`), bound searches (`rg -m 20`), and redirect voluminous operations (test runs, builds) to disk (`> /tmp/build.log`) to inspect defensively via `tail` or `grep`.
- **File Reads (`view_file`)**: Even with an 800-line tool cap, 800 lines consumes ~4,000–5,000 tokens. Agents must request narrow line ranges (`StartLine`/`EndLine`) rather than dumping entire files.
- **Web Content (`read_url_content` / `search_web`)**: Target specific documentation sections rather than pulling sprawling web pages.
- **Directory Discovery & Queries**: Restrict traversal depths (`find -maxdepth 2`, `ls -1 | head -n 30`) and bound database/API queries.

### 5. Direct Communication: Stopping Output Bloat at the Root

Pruning Antigravity's default prompt blocks (`excludeDefaultComponents: true`) removes ~3,000 tokens of boilerplate, but also removes `<communication_style>`. Without an explicit directive, models default to chatty assistant tropes: polite pleasantries, verbose restatements of tasks, pre-action chatter, and multi-paragraph recaps of modified files.

In a 30-turn session, 150 tokens of filler per response wastes **~4,500 generation tokens** and **~45,000+ cumulative prompt tokens**. **`Direct Communication`** ensures the agent communicates with zero-fluff precision.

---

### 6. The Anatomy of the Principles: How Each Clause Earns Its Place

Both `better-agy` and `lean-agy` ship with the following tightly formulated directives:

```markdown
# Principles

- **Context Discipline**: Context window capacity is finite and irreversible. Every token emitted by tools or responses persists in conversation history and is re-billed on every subsequent turn. Tools like `run_command` have no built-in output limits or defensive auto-truncation (`PAGER=cat`). All shell commands, searches, listings, queries, and file reads must be strictly bounded before execution (e.g., pipe to `head`/`tail`, use `--max-count`, narrow file view slice ranges). Never emit unmetered or verbose output into context; redirect large outputs (builds, tests, logs) to disk and inspect defensively with targeted filters.
- **Direct Communication**: Deliver concise, precise responses. Omit conversational filler, polite pleasantries, pre-action chatter, and unsolicited post-action recaps of edited files.
```

At under **150 base tokens**, this compact block provides massive through-session leverage by systematically dismantling standard model failure modes:

| Directive Phrase | Runtime Flaw / Model Bias Addressed | Operational Behavior Enforced |
| :--- | :--- | :--- |
| *"Context window capacity is finite and irreversible."* | Models treat context as an elastic scratchpad rather than a fixed operational runway. | Instills the invariant that spent tokens cannot be recovered. |
| *"Every token emitted by tools or responses persists in conversation history and is re-billed on every subsequent turn."* | Models overlook cumulative multi-turn re-billing ($\text{Cost} = \text{Tokens} \times \text{Remaining Turns}$). | Prevents early-session output dumps that degrade attention and waste budget on every subsequent turn. |
| *"Tools like `run_command` have no built-in output limits or defensive auto-truncation (`PAGER=cat`)."* | Models assume tool runners truncate or paginate long command outputs. | Eliminates the false assumption of environment safety buffers. |
| *"All shell commands, searches, listings, queries, and file reads must be strictly bounded before execution (e.g., pipe to `head`/`tail`, use `--max-count`...)"* | Pruned discovery tools (`grep_search`, `find_by_name`, `list_dir`) had 50-match safety caps; raw shell commands have none. | Replaces missing runtime safety limits across all tools without paying their Turn-0 schema overhead. |
| *"Never emit unmetered or verbose output into context; redirect large outputs (builds, tests, logs) to disk and inspect defensively..."* | Tool runner does not automatically truncate long outputs or redirect full streams to log files. | Compels the model to redirect outputs to disk (`> /tmp/build.log 2>&1`) and inspect via `grep`, `head`, or `tail`. |
| *"Deliver concise, precise responses. Omit conversational filler..."* | `excludeDefaultComponents: true` prunes `<communication_style>`, leaving models prone to conversational pleasantries. | Stops ~150 tokens/turn of conversational fluff (~45,000+ tokens over a 30-turn session). |

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
