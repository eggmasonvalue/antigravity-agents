---
name: agent-maintenance
description: Audit, review, and synchronize custom Antigravity agents following agy version upgrades or tool schema changes.
---

# Antigravity Agent Maintenance & Audit Runbook

Use this skill when auditing, updating, or maintaining custom agent definitions within this repository—especially after upgrading the Antigravity CLI (`agy update`) or encountering tool deprecations/additions.

---

## 1. Version Baseline Inspection

1. Check the local `agy` binary version:
   ```bash
   agy --version
   ```
2. Compare against the documented baseline in `README.md`.
3. If a version bump has occurred, review release notes via:
   ```bash
   agy changelog
   ```
   Or fetch live changelogs: `https://antigravity.google/changelog`.

---

## 2. Toolset & Schema Audit

1. **Authoritative Source of Tools**:
   The **active session's context window (the tool declarations block)** is the sole authoritative, ground-truth source for all currently available built-in tools and their exact parameter schemas.
   > [!IMPORTANT]
   > Do **not** conduct web searches, parse remote documentation, or attempt to inspect CLI help flags (`agy help`, `agy agent`) to discover tool schemas. The CLI surface does not expose tool JSON schemas; only your runtime context declarations do.

2. **Diff Against Agent Tool Manifests**:
   Compare the active tool declarations directly against the `tools:` frontmatter lists in `agents/*.md`.

3. **Evaluation Criteria for Tool Pruning vs Inclusion**:
   - **Keep**: High-leverage, non-redundant primitives (e.g., core execution, surgical edits, subagent orchestration).
   - **Prune**: 
     - Tools fully subsumed by `run_command` (e.g. `list_dir`, `grep_search`).
     - Heavy interactive or modal tools easily replaced by plain text communication (e.g. `ask_question`).
     - Specialized media generators irrelevant to coding workflows (e.g. `generate_image`).

4. **Token Overhead Assessment**:
   Every kept tool injects its parameter schema into the system context. Strive to keep the active tool count minimal to protect the model's working window.

---

## 3. Agent Definition Updates

1. Edit target files in `agents/<agent-name>.md`.
2. Ensure YAML frontmatter maintains:
   - `name`: Matches filename basename.
   - `mainAgent: true` (for root session agents) and/or `subagent: true`.
   - `model: inherit` (default) or explicit tier (`pro`, `flash`).
   - `tools:` Alphabetized or grouped explicit list.
3. Keep `# Principles` concise, imperative, and aligned with context conservation.

---

## 4. Verification & Testing

1. **Local Test Installation**:
   - **Linux**: `./scripts/install.sh --local`
   - **Windows**: `.\scripts\install.ps1 -Local`
2. **Verify Agent Discovery**:
   ```bash
   agy agents
   ```
   Confirm that the updated agent appears in the discovered list.
3. **Session Smoke Test**:
   ```bash
   agy --agent <agent-name> -p "respond with 'pong'"
   ```

---

## 5. Token Benchmarking & Comparison

To measure token overhead and verify schema savings programmatically without manual TUI interaction:

1. **Benchmark Default Agent**:
   ```bash
   agy --output-format json -p "respond with 'pong'"
   ```
2. **Benchmark Custom Agent**:
   ```bash
   agy --agent <agent-name> --output-format json -p "respond with 'pong'"
   ```
3. Compare `usage.input_tokens` in both outputs to quantify exact baseline token savings.

*(In interactive CLI sessions, users can also type `/context` to inspect active token usage breakdown in the TUI).*

