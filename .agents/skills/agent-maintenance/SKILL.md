---
name: agent-maintenance
description: Audit, review, and synchronize custom Antigravity agents and skills following agy version upgrades or tool schema changes.
---

# Antigravity Agent & Skill Maintenance Runbook

Use this skill when auditing, updating, or synchronizing agent definitions and skills in this repository—especially after updating the Antigravity CLI (`agy update`) or encountering tool/flag changes.

---

## 1. Version Baseline Inspection

1. Check the local `agy` binary version:
   ```bash
   agy --version
   ```
2. Compare against the documented baseline in `README.md`.
3. If a version bump occurred, review release notes and changes:
   ```bash
   agy changelog
   ```
   Or fetch live changelogs: `https://antigravity.google/changelog`.

---

## 2. Toolset & CLI Capability Audit

### A. Tool Schema Audit (Active Context Window)
The **active session's context window (the tool declarations block)** is the sole authoritative ground truth for all currently available built-in tools and their parameter schemas.

> [!IMPORTANT]
> Do **not** conduct web searches or inspect CLI help flags to discover tool schemas; only runtime context declarations expose them.

- **`agents/better-agy.md` (Balanced 11 Tools)**:
  - Verify it includes the 6 core tools (`run_command`, `view_file`, `replace_file_content`, `write_to_file`, `search_web`, `read_url_content`) + 5 subagent orchestration tools (`invoke_subagent`, `define_subagent`, `send_message`, `manage_subagents`, `manage_task`).
  - Ensure pruned tools (`list_dir`, `grep_search`, `find_by_name`, `ask_question`, `generate_image`, `schedule`) remain excluded.
  - Verify `excludeDefaultComponents: true` is set in frontmatter.
- **`agents/lean-agy.md` (Ultra-Minimal 6 Tools)**:
  - Verify it strictly includes only the 6 core tools.
  - Verify `excludeDefaultComponents: true` is set in frontmatter.
- **Agent Roles**: Ensure both agents have `mainAgent: true` and `subagent: false` to prevent polluting other sessions' turn-0 subagent registries.

### B. CLI Capability Audit (`agy --help`)
1. Inspect available flags and subcommands:
   ```bash
   agy --help
   ```
2. Compare against the parameter matrix in `.agents/skills/agy-subagents/SKILL.md`.
3. Update `SKILL.md` if `agy` introduces new execution flags, output formats, or sandbox options.

---

## 3. Local Installation & Verification

1. **Sync Local Changes**:
   - **Linux / macOS**: `./scripts/install.sh --local`
   - **Windows**: `.\scripts\install.ps1 -Local`

2. **Verify Agent Discovery**:
   ```bash
   agy agents
   ```
   Confirm `better-agy` and `lean-agy` appear in the discovered agents list.

---

## 4. Token Benchmarking

Run the non-interactive Turn-0 benchmark to verify exact token overhead:

1. **Benchmark Default Agent**:
   ```bash
   agy --output-format json -p "Output 'PONG' and nothing else"
   ```
2. **Benchmark `better-agy`**:
   ```bash
   agy --agent better-agy --output-format json -p "Output 'PONG' and nothing else"
   ```
3. **Benchmark `lean-agy`**:
   ```bash
   agy --agent lean-agy --output-format json -p "Output 'PONG' and nothing else"
   ```
4. Compare `usage.input_tokens` across all three outputs.

---

## 5. Documentation & Turn-0 Context Sync

Whenever tool schemas, prompt components, or baseline versions change:

1. **Update `docs/turn-zero-context.md`**:
   - Update the baseline `agy` version and Turn-0 token metrics in the summary table.
   - Update the Component & Tool Subset Matrix and verbatim schemas if upstream added or modified built-in tools or prompt blocks.

2. **Update `docs/turn-zero-context.html` & `docs/index.html`**:
   - Update the title and header to the new `agy` version tag.
   - Update the stat card token figures (`Default`, `better-agy`, `lean-agy`).
   - If new tools or prompt sections were introduced, add them with appropriate `data-tiers` attributes (`core`, `better`, `lean`, `default`).
   - Mirror updates to `docs/index.html` (`cp docs/turn-zero-context.html docs/index.html`) to keep the live GitHub Pages deployment in sync.

3. **Update `README.md`**:
   - Update the Turn-0 Benchmark table metrics and baseline CLI version.
   - Update the headline context reduction percentage (e.g. `~70%`).
   - Confirm links to `docs/turn-zero-context.md` and the GitHub Pages deployment remain intact.
