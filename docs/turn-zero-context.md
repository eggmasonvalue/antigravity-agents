# Turn-0 Context Breakdown & Agent Subsets (`agy v1.2.2`)

> **Interactive Visualization**: Open [`docs/turn-zero-context.html`](turn-zero-context.html) in your browser for an interactive, color-coded overlay comparing the Turn-0 system prompt and tool definitions across all three agents.

---

## Executive Summary

Every Antigravity CLI session starts with **Turn 0**: the base system instructions, user/environment metadata, and tool parameter schemas injected into the model's context window before your first prompt is evaluated.

On `agy v1.2.2`, the default agent injects **`13,728` input tokens** on Turn 0. `better-agy` and `lean-agy` are **strict functional subsets** of this baseline, pruning verbose tool schemas and using the `excludeDefaultComponents: true` frontmatter flag (introduced in `v1.2.1`) to opt out of boilerplate prompt sections while preserving full execution capabilities and lifecycle hooks.

| Agent Profile | Turn-0 Tokens | Context Tax Reduction | Retained Capabilities | Subagent Delegation |
| :--- | :---: | :---: | :--- | :--- |
| **Default Agent** | `13,728` tokens | Baseline | 17 tools + all 8 default prompt sections | Native UI panels & built-in tools |
| **`better-agy`** | **`6,196` tokens** | **-7,532 tokens (~54.9% cut)** | 11 tools + minimal prompt + principles | Native UI panels & built-in tools |
| **`lean-agy`** | **`4,078` tokens** | **-9,650 tokens (~70.3% cut)** | 6 core tools + minimal prompt + principles | On-demand via `agy-subagents` skill |

---

## Component & Tool Subset Matrix

Because both custom agents are strict subsets of the default agent, every capability falls into one of three tiers:
- 🟩 **Core Tier**: Retained in all agents (`lean-agy`, `better-agy`, Default).
- 🟦 **Subagent Orchestration Tier**: Retained in `better-agy` and Default; offloaded to skill in `lean-agy`.
- ⬜ **Default-Only Tier**: Excluded in both custom agents via `excludeDefaultComponents: true` and tool pruning.

| Component / Tool | Type | Default | `better-agy` | `lean-agy` | Why Pruning Is Safe (Zero Functionality Loss) |
| :--- | :--- | :---: | :---: | :---: | :--- |
| **`run_command`** | Tool | ✅ | ✅ | ✅ | Core terminal command runner; executes bash/shell commands. |
| **`view_file`** | Tool | ✅ | ✅ | ✅ | Core file viewer; reads files defensively with line slicing. |
| **`replace_file_content`** | Tool | ✅ | ✅ | ✅ | Core surgical file editor; exact string replacements. |
| **`write_to_file`** | Tool | ✅ | ✅ | ✅ | Core file creator / overwrite tool. |
| **`search_web`** | Tool | ✅ | ✅ | ✅ | Core search tool for external documentation and research. |
| **`read_url_content`** | Tool | ✅ | ✅ | ✅ | Core HTTP fetcher for documentation URLs. |
| **`invoke_subagent`** | Tool | ✅ | ✅ | ❌ *(Skill)* | Spawns background subagents. In `lean-agy`, dynamically handled via `run_command` and `agy-subagents`. |
| **`define_subagent`** | Tool | ✅ | ✅ | ❌ *(Skill)* | Registers transient subagents. In `lean-agy`, replaced by standalone subagent invocations. |
| **`send_message`** | Tool | ✅ | ✅ | ❌ *(Skill)* | Inter-agent messaging. In `lean-agy`, handled via multi-turn session flags (`--conversation`). |
| **`manage_subagents`** | Tool | ✅ | ✅ | ❌ *(Skill)* | Lists/kills subagents. In `lean-agy`, managed via shell/CLI (`/agents` panel or process management). |
| **`manage_task`** | Tool | ✅ | ✅ | ❌ *(Auto)* | Background task status/kill. Handled transparently by runtime when running async commands. |
| **`list_dir`** | Tool | ✅ | ❌ | ❌ | Subsumed by `run_command` with `ls -la`. Faster, formatted, and strictly bounded. |
| **`grep_search`** | Tool | ✅ | ❌ | ❌ | Subsumed by `run_command` with `grep` or `ripgrep` (`rg`). Avoids heavy JSON parameter bloat. |
| **`find_by_name`** | Tool | ✅ | ❌ | ❌ | Subsumed by `run_command` with `find` or `fd`. Avoids schema token overhead. |
| **`ask_question`** | Tool | ✅ | ❌ | ❌ | Model naturally asks questions in regular chat; rigid multi-choice UI schema is unnecessary. |
| **`generate_image`** | Tool | ✅ | ❌ | ❌ | Niche image generation tool; irrelevent to standard software engineering tasks. |
| **`schedule`** | Tool | ✅ | ❌ | ❌ | Niche cron scheduler tool; standard jobs are run via shell or user CLI scheduling. |
| **`<identity>` & `<user_information>`** | Prompt | ✅ | ✅ | ✅ | Essential platform identity, workspace path mapping, and OS metadata. |
| **`<artifacts>`** | Prompt | ✅ | ❌ | ❌ | ~1,250 tokens of styling advice and Mermaid rules. UI renders markdown and diagrams automatically. |
| **`<slash_commands>`** | Prompt | ✅ | ❌ | ❌ | ~420 tokens describing `/goal`, `/plan`, `/boost`. CLI parses slash commands client-side. |
| **`<conversation_transcript>`** | Prompt | ✅ | ❌ | ❌ | ~360 tokens explaining JSONL logs. Logging is handled by the backend daemon without model advice. |
| **`<subagents>` Prompt Guidance** | Prompt | ✅ | ❌ | ❌ | ~210 tokens of conversational delegation advice. Native tools or skills handle execution. |
| **`<messaging>` & `<guidelines>`** | Prompt | ✅ | ❌ | ❌ | ~330 tokens of boilerplate instructions. Replaced by concise custom principles. |
| **Agent `# Principles`** | Prompt | ❌ | ✅ | ✅ | Context Discipline & Direct Communication directives (~80 tokens). |

---

## Addressing User Anxiety: What Gets Dropped & Why

### 1. "Can the agent still create Artifacts and Mermaid diagrams?"
**Yes, 100%.**
The default `<artifacts>` section contains ~1,250 tokens explaining when to use artifacts, markdown formatting tips, GitHub alert styles (`[!NOTE]`, `[!TIP]`), and Mermaid syntax. However, the Antigravity UI renders artifacts and Mermaid code blocks natively on the client whenever the model outputs standard fenced markdown blocks. Stripping this boilerplate does not disable artifact rendering; it simply stops spending 1,250 tokens every turn reminding frontier models how to write markdown.

### 2. "Why drop `list_dir`, `grep_search`, and `find_by_name`?"
**The shell is faster, strictly bounded, and has zero schema tax.**
The dedicated filesystem search tools inject thousands of tokens of OpenAPI parameter definitions into the context window on Turn 0. By utilizing `run_command` with standard shell utilities (`ls`, `find`, `rg`), search output is filtered at the source before entering the context window, preventing accidental buffer dumps while preserving identical file navigation capabilities.

### 3. "How does `lean-agy` run subagents without subagent tools?"
**Through Progressive Disclosure.**
`lean-agy` drops all subagent tool schemas from Turn 0, saving ~2,120 tokens. When multi-agent decomposition or long-running parallel tasks are needed, it dynamically invokes the `agy-subagents` skill. Antigravity loads skills on-demand, meaning subagent orchestration knowledge is pulled into context only when needed rather than penalizing every single turn.

### 4. "What about post-invocation hooks and safety rules?"
**Preserved intact.**
The `excludeDefaultComponents: true` frontmatter flag specifically opts out of default prompt sections and tool injections while **preserving post-invocation hooks, safety filters, and permission rules**.

---

## How to View the Interactive Overlay

Open the companion HTML document locally:

```bash
# Open in your default browser:
xdg-open docs/turn-zero-context.html   # Linux
open docs/turn-zero-context.html       # macOS
Start-Process docs/turn-zero-context.html # Windows PowerShell
```
