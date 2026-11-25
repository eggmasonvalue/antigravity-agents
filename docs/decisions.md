# Architecture Philosophy & Decision Records

Single source of truth for how this repository evaluates Antigravity (`agy`) harness changes and why the current agents are shaped the way they are.

---

## Core Philosophy & Upgrade Evaluation Rubric

Frontier models are capable—a good harness acts like a **good manager**: keep context clean, provide sharp non-overlapping primitives, and get out of the way instead of micromanaging tone or bolting on redundant tools.

Apply these five checks whenever auditing a new `agy` release:

1. **Zero-overlap primitive filter**: Add a tool to `tools:` only if it introduces a genuinely distinct capability not subsumed by shell (`run_command`), `run_workflow`, or plain chat. Overlapping tools waste Turn-0 tokens and create decision ambiguity.
2. **Right-size the tier**:
   - Always-needed primitives → `tools:`.
   - Rare, flag-heavy, or situational workflows → private co-located skill (`disable-slash-command: true`).
   - UI-only widgets, quota-heavy orchestrators, or redundant search wrappers → prune.
3. **Verify empirically, never trust docs or changelogs**: Test frontmatter fields, tool name resolution, `excludeDefaultComponents` side effects, and end-to-end `run_workflow` child execution in a scratch workspace before committing changes.
4. **Zero global pollution**: Standalone main agents keep `subagent: false` so they never leak into the Default agent's `<subagents>` registry. Private workers and skills live inside their owning agent's folder (e.g., `agents/clean/`), never in global `~/.gemini/config/skills/`.
5. **Don't micromanage, and prune obsolete workarounds**: Only add `# Principles` directives for concrete runtime gaps (like `run_command`'s unpaged ~10 KB truncation or duplicate diff echoing)—never police conversational tone. If upstream fixes a gap or exposes finer-grained controls, simplify or remove our workaround.

---

## Decision Records

### DR-001: Make `run_workflow` the Single Native Orchestration Primitive (`agy v1.5.13`)
- **Decision**: Drop `invoke_subagent`, `define_subagent`, `send_message`, and `manage_subagents` from the primary agent; expose `run_workflow` instead, keeping `agy-subagents` as a private on-demand CLI skill.
- **Why**: `run_workflow` (~395 Turn-0 tokens, 1 tool) covers parallel fan-out, staged pipelines, stateful multi-turn children, isolated Git worktrees (`workspace="branch"`), typed JSON-Schema returns (`finish`), and live `/tasks` UI visibility. Native subagent tools (~1,200+ tokens across 4 tools) only add unscripted conversational ping-pong, and keeping both creates overlapping delegation paths. Rare CLI-specific needs (exact model slugs, `--effort`, `--sandbox`, `--conversation`) live in the private `agy-subagents` skill at ~40 Turn-0 tokens.
- **Revisit if**: Antigravity merges subagents and workflows into a single tool or adds a compelling native capability unreachable via `run_workflow` + CLI.

### DR-002: Collapse `better-agy` and `lean-agy` into `clean` and `bare` (`agy v1.5.13`)
- **Decision**: Ship two distinct roles—**`clean`** (daily-driver human-facing engineer & workflow manager) and **`bare`** (bare-metal leaf executor for headless `-p`/CI, CLI workers, and max solo runway).
- **Why**: Once overlapping native subagent tools are removed, the old split between `better-agy` (native subagents) and `lean-agy` (no native subagents) disappears. The remaining real boundary is **full workspace citizen** (`clean`: rules, skills, MCP, `run_workflow`) vs **stripped execution substrate** (`bare`: `excludeDefaultComponents: true`, `inheritMcp: false`, 6 leaf tools).
- **Revisit if**: A third genuinely non-overlapping operational mode emerges.

### DR-003: Remove `excludeDefaultComponents: true` from `clean`; Keep It on `bare` and `worker` (`agy v1.5.13`)
- **Decision**: Do not set `excludeDefaultComponents: true` on `clean`; retain it on `bare` and `clean`'s private `worker.md`.
- **Why (empirically verified)**: In `v1.2.2`, `excludeDefaultComponents: true` preserved `<identity>`, `<user_information>`, and `<skills>`. By `v1.5.13`, it strips **all** default components—including `<user_information>`, `<user_rules>` (`AGENTS.md`/`GEMINI.md`), and `<skills>` (even explicit frontmatter `skills:`). Omitting it on `clean` still drops `<identity>`, `<conversation_transcript>`, `<work_efficiently>`, `<slash_commands>`, `<subagents>`, and all built-in skills automatically (~49% Turn-0 cut) while keeping workspace rules and private skills working. On `bare` and `worker`, stripping human UI scaffolding (`<artifacts>`, `<communication_style>`, `<slash_commands>`) is a net win (~76% cut), and missing workspace/async mechanics are compensated in ~4 lines of `# Principles` (with `clean` briefing `worker` explicitly).
- **Revisit if**: Antigravity adds granular component opt-out (e.g., excluding `<artifacts>` / `<communication_style>` without dropping `<user_information>`, `<user_rules>`, or `<skills>`).

### DR-004: Privately Co-Locate `worker.md` and Skills Inside `agents/clean/` (`agy v1.5.13`)
- **Decision**: Bundle `worker.md` (`mainAgent: false`, `subagent: true`) and `skills/{run-workflow,agy-subagents}/SKILL.md` (`disable-slash-command: true`) inside `agents/clean/` and bind them via relative frontmatter paths (`agents:` / `skills:`).
- **Why (empirically verified)**:
  1. `agy v1.3.1+` resolves relative `skills:` and `agents:` paths against the custom agent's directory, enabling opt-in per-agent scoping with zero bleed into Default or `bare`.
  2. Custom agents cannot invoke built-in `"self"` or `"research"` (fails with `subagent "self" not found`), and `subagent: false` blocks `run_workflow`—so a private co-located `worker.md` (`subagent: true`) is required for `run_workflow` to work without polluting Default's subagent list.
  3. Custom agents drop the built-in `run-workflow` skill, so `clean` needs a private `run-workflow` skill that also instructs `type_name="worker"`.
  4. Note: Antigravity still lacks per-agent negative filtering (denylisting global/workspace skills from one agent while keeping `<skills>` enabled); opt-in co-location is the cleanest boundary available.
- **Revisit if**: Antigravity exposes built-in `"self"` to custom agents, supports per-agent skill denylists, or natively scopes plugin skills per agent.

### DR-005: Set `inheritMcp: false` on `bare` and `worker`, Keep Inheritance on `clean` (`agy v1.5.13`)
- **Decision**: Lock `inheritMcp: false` on `bare` and `worker`; let `clean` inherit user/workspace MCP servers.
- **Why**: Connected MCP servers can inject thousands of tool schema tokens silently. `clean` is the daily driver where users expect configured MCP tools to work; `bare` and leaf `worker` instances prioritize deterministic ~2k Turn-0 cost.
- **Revisit if**: Antigravity moves all MCP tools strictly to zero-Turn-0 lazy discovery.

### DR-006: Scope `# Principles` to Concrete Context Leaks, Not Conversational Tone (`agy v1.5.13`)
- **Decision**: Focus `Context Discipline` on `run_command`'s unpaged ~10 KB middle-dropping output (`PAGER=cat`) using safe native bounds (`git log -n`, `rg -l`, summary flags) without hiding errors or breaking exit codes, plus avoiding pasting code blocks/raw diffs/file recaps already written to disk—with **no** directive restricting conversational tone or micromanaging `read_file` (which already enforces its own 800-line / 46 KB cap).
- **Why**: Tool outputs and echoed code blocks persist in conversation history and compound across every subsequent turn, whereas prescribing `| head`/`| tail` or aggressive `read_file` slicing risks `SIGPIPE`, masked exit codes, and extra round-trips. Conversational style with a human belongs to the model and project context, not the harness.
- **Revisit if**: `run_command` gains tighter context-friendly defaults that eliminate middle-truncation surprises and ~10 KB history churn.

### DR-007: Prune `update_steps` UI Checklist Tool (`agy v1.5.17`)
- **Decision**: Exclude `update_steps` (added in `agy v1.5.16`) from `clean`, `bare`, and `worker`.
- **Why**: `update_steps` is a UI-only live step checklist widget rendered above the CLI prompt. Its verbose schema costs ~620 Turn-0 tokens and instructs the model to emit extra step-transition tool calls (including a trailing all-done call before the final reply) alongside mandatory per-step progress narration—violating both the zero-overlap / UI-widget filter and anti-micromanagement principles.
- **Revisit if**: `update_steps` becomes required for durable checkpoint/resume semantics or sheds its Turn-0 schema bloat and mandatory narration turns.
