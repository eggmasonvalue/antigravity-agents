---
name: agent-maintenance
description: Audit, review, and synchronize custom Antigravity agents and skills following agy version upgrades or tool schema changes.
---

# Antigravity Agent & Skill Maintenance Runbook

Use this skill when auditing, updating, or synchronizing the custom agents (`clean`, `bare`, and `clean`'s private `worker`) and private skills in this repository—especially after upgrading the Antigravity CLI (`agy update`) or encountering tool/frontmatter changes.

---

## 0. Load Philosophy & Past Decisions (Required First Step)

Before proposing or making any changes, **MUST read [docs/decisions.md](../../../docs/decisions.md)** to absorb:
- The repository's **Core Philosophy & Upgrade Evaluation Rubric** (good-manager model, zero tool overlap, empirical verification, zero global pollution, pruning obsolete workarounds).
- All settled **Decision Records (`DR-*`)** and their **Revisit Triggers**, so you know *why* each trade-off exists and what upstream harness change justifies revisiting it.

---

## 1. Version Baseline Inspection

1. Check the local `agy` binary version:
   ```bash
   agy --version
   ```
2. Compare against the documented baseline in `README.md`.
3. If a version bump occurred, review release notes:
   ```bash
   agy changelog
   ```
   Or fetch `https://antigravity.google/docs/changelog.md`.

---

## 2. Toolset, Frontmatter & CLI Capability Audit

### A. Tool Schema Audit (Active Context Window)
The **active session's context window (the tool declarations block)** is the sole authoritative ground truth for currently available built-in tools and their parameter schemas.

> [!IMPORTANT]
> Do **not** rely on outdated web docs or CLI help flags to infer tool schemas; inspect the live runtime tool declarations directly.

- **`agents/clean/agent.md` (Daily Driver + Programmable Workflows — 7 Tools)**:
  - Verify it includes the 6 core tools (`read_file`, `edit_file`, `write_file`, `run_command`, `manage_task`, `search_web`) + `run_workflow`.
  - Ensure overlapping/UI-only tools (`invoke_subagent`, `define_subagent`, `send_message`, `manage_subagents`, `ask_question`, `schedule`, `swarm`, `update_steps`) remain excluded.
  - Ensure `excludeDefaultComponents` is **not** set (so `<user_information>`, `AGENTS.md`/`GEMINI.md` rules, `<skills>`, and MCP remain active).
  - Verify private bundle declarations: `agents: [worker.md]` and `skills: [skills/run-workflow, skills/agy-subagents]`.
  - Verify `mainAgent: true` and `subagent: false`.
- **`agents/clean/worker.md` (Private Bare Workflow Worker — 6 Tools)**:
  - Verify `mainAgent: false`, `subagent: true`, `excludeDefaultComponents: true`, `inheritMcp: false`.
  - Verify it strictly includes the 6 core tools (the harness auto-injects `finish` inside `run_workflow`).
- **`agents/bare.md` (Standalone Bare-Metal Executor — 6 Tools)**:
  - Verify `mainAgent: true`, `subagent: false`, `excludeDefaultComponents: true`, `inheritMcp: false`.
  - Verify it strictly includes the 6 core tools and retains operational compensations (Path Grounding, Async Discipline, Execution Efficiency).

### B. CLI Capability Audit (`agy --help`)
1. Inspect available flags and subcommands:
   ```bash
   agy --help
   ```
2. Compare against the parameter matrix in `agents/clean/skills/agy-subagents/SKILL.md`.
3. Check whether Antigravity added any new custom-agent frontmatter controls (e.g. granular component filtering or skill denylisting) that improve restriction capabilities.

---

## 3. Local Installation & Verification

1. **Sync Local Changes**:
   - **Linux / macOS**: `./scripts/install.sh --local`
   - **Windows**: `.\scripts\install.ps1 -Local`
2. **Verify Agent Discovery & Isolation**:
   ```bash
   agy agents
   ```
   Confirm `clean` and `bare` appear (and `worker` does **not** appear as a top-level main agent or in the Default agent's `<subagents>` list, and `agy-subagents` does **not** appear in the Default agent's `<skills>` list).
3. **End-to-End Workflow Smoke Test**:
   Confirm `clean` can execute `run_workflow` with `type_name="worker"` and receive a schema-validated `finish` output.

---

## 4. Token Benchmarking

Run the non-interactive Turn-0 benchmark to verify exact token overhead:

```bash
agy --output-format json -p "Output 'PONG' and nothing else"
agy --agent clean --output-format json -p "Output 'PONG' and nothing else"
agy --agent bare  --output-format json -p "Output 'PONG' and nothing else"
```

Compare `usage.input_tokens` across all three profiles.

---

## 5. Documentation & Turn-0 Context Sync

Whenever tool schemas, prompt components, or baseline versions change:

1. **Update `docs/turn-zero-context.md`**:
   - Update the baseline `agy` version and Turn-0 token metrics in the summary table.
   - Update the Subset Matrix and verbatim schemas/XML sections to match the live runtime context.
2. **Update `docs/index.html`** (Single Source of Truth):
   - Update the title, header version tag, and overlay button token counts (`Default`, `clean`, `bare`).
   - Keep `data-tiers` attributes (`core`, `clean`, `bare`, `default`) synced with every tool and prompt section.
3. **Update `README.md`**:
   - Update the Turn-0 Benchmark table metrics, baseline CLI version, and headline reduction percentage.
   - Confirm links to `docs/turn-zero-context.md`, `docs/decisions.md`, and `docs/index.html` (GitHub Pages) remain intact.
4. **Update `docs/decisions.md`**:
   - Append a new Decision Record (`DR-XXX`) or update an existing one whenever a harness change alters tool selection, frontmatter behavior, scoping boundaries, or custom directives.
